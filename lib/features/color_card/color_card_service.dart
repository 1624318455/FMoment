import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database.dart';
import '../../utils/color/color_utils.dart';

final colorCardServiceProvider = Provider<ColorCardService>((ref) {
  return ColorCardService();
});

class ColorCardService {
  // 获取所有分组
  Future<List<Map<String, dynamic>>> getGroups() async {
    final db = await AppDatabase.database;
    return await db.query('color_group', orderBy: 'sort ASC');
  }

  // 创建分组
  Future<int> createGroup(String name) async {
    final db = await AppDatabase.database;
    return await db.insert('color_group', {
      'name': name,
      'sort': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // 更新分组
  Future<void> updateGroup(int id, String name) async {
    final db = await AppDatabase.database;
    await db.update(
      'color_group',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 删除分组
  Future<void> deleteGroup(int id) async {
    final db = await AppDatabase.database;
    // 将该分组下的色卡移到默认分组
    await db.update(
      'color_card',
      {'group_id': null},
      where: 'group_id = ?',
      whereArgs: [id],
    );
    await db.delete(
      'color_group',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 获取色卡列表
  Future<List<Map<String, dynamic>>> getCards({int? groupId}) async {
    final db = await AppDatabase.database;
    if (groupId != null) {
      return await db.query(
        'color_card',
        where: 'group_id = ?',
        whereArgs: [groupId],
        orderBy: 'update_time DESC',
      );
    }
    return await db.query('color_card', orderBy: 'update_time DESC');
  }

  // 创建色卡
  Future<int> createCard({
    required String name,
    String? desc,
    int? groupId,
  }) async {
    final db = await AppDatabase.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    return await db.insert('color_card', {
      'name': name,
      'desc': desc,
      'group_id': groupId,
      'create_time': now,
      'update_time': now,
    });
  }

  // 更新色卡
  Future<void> updateCard({
    required int id,
    String? name,
    String? desc,
    int? groupId,
  }) async {
    final db = await AppDatabase.database;
    final updates = <String, dynamic>{
      'update_time': DateTime.now().millisecondsSinceEpoch,
    };
    if (name != null) updates['name'] = name;
    if (desc != null) updates['desc'] = desc;
    if (groupId != null) updates['group_id'] = groupId;

    await db.update(
      'color_card',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 删除色卡
  Future<void> deleteCard(int id) async {
    final db = await AppDatabase.database;
    // 先删除关联的颜色项
    await db.delete(
      'color_item',
      where: 'card_id = ?',
      whereArgs: [id],
    );
    await db.delete(
      'color_card',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 获取色卡中的颜色
  Future<List<Map<String, dynamic>>> getColors(int cardId) async {
    final db = await AppDatabase.database;
    return await db.query(
      'color_item',
      where: 'card_id = ?',
      whereArgs: [cardId],
      orderBy: 'sort ASC',
    );
  }

  // 添加颜色到色卡
  Future<int> addColor({
    required int cardId,
    required Color color,
  }) async {
    final db = await AppDatabase.database;
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);
    final hsl = ColorUtils.rgbToHsl(r, g, b);

    // 获取当前最大排序值
    final result = await db.rawQuery(
      'SELECT MAX(sort) as max_sort FROM color_item WHERE card_id = ?',
      [cardId],
    );
    final maxSort = result.first['maxSort'] as int? ?? 0;

    final id = await db.insert('color_item', {
      'card_id': cardId,
      'hex': ColorUtils.rgbToHex(r, g, b),
      'rgb_r': r,
      'rgb_g': g,
      'rgb_b': b,
      'hsl_h': hsl['h'],
      'hsl_s': hsl['s'],
      'hsl_l': hsl['l'],
      'sort': maxSort + 1,
    });

    // 更新色卡的更新时间
    await db.update(
      'color_card',
      {'update_time': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [cardId],
    );

    return id;
  }

  // 删除颜色
  Future<void> deleteColor(int id) async {
    final db = await AppDatabase.database;
    await db.delete(
      'color_item',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 导出色卡为 JSON
  Future<Map<String, dynamic>> exportCard(int cardId) async {
    final db = await AppDatabase.database;
    final card = await db.query(
      'color_card',
      where: 'id = ?',
      whereArgs: [cardId],
    );
    final colors = await db.query(
      'color_item',
      where: 'card_id = ?',
      whereArgs: [cardId],
      orderBy: 'sort ASC',
    );

    return {
      'card': card.first,
      'colors': colors,
    };
  }

  // 导入色卡
  Future<void> importCard(Map<String, dynamic> data) async {
    final db = await AppDatabase.database;
    final cardData = data['card'] as Map<String, dynamic>;
    final colorsData = data['colors'] as List<dynamic>;

    // 创建色卡
    final cardId = await db.insert('color_card', {
      'name': cardData['name'] ?? '导入的色卡',
      'desc': cardData['desc'],
      'group_id': cardData['group_id'],
      'create_time': DateTime.now().millisecondsSinceEpoch,
      'update_time': DateTime.now().millisecondsSinceEpoch,
    });

    // 导入颜色
    for (final colorData in colorsData) {
      await db.insert('color_item', {
        'card_id': cardId,
        'hex': colorData['hex'],
        'rgb_r': colorData['rgb_r'],
        'rgb_g': colorData['rgb_g'],
        'rgb_b': colorData['rgb_b'],
        'hsl_h': colorData['hsl_h'],
        'hsl_s': colorData['hsl_s'],
        'hsl_l': colorData['hsl_l'],
        'sort': colorData['sort'],
      });
    }
  }
}
