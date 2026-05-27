import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'database.dart';

final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService();
});

class ConfigService {
  static const _screenshotSavePathKey = 'screenshot_save_path';

  Future<String> getString(String key, {String defaultValue = ''}) async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      'config',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return defaultValue;
    return rows.first['value'] as String? ?? defaultValue;
  }

  Future<void> setString(String key, String value) async {
    final db = await AppDatabase.database;
    await db.insert(
      'config',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String> getScreenshotSavePath() async {
    final saved = await getString(_screenshotSavePathKey);
    if (saved.isNotEmpty) return saved;
    // 默认路径: 用户文档/FMoment/Screenshots
    final docs = await getApplicationDocumentsDirectory();
    return p.join(docs.path, 'FMoment', 'Screenshots');
  }

  Future<void> setScreenshotSavePath(String path) async {
    await setString(_screenshotSavePathKey, path);
  }
}
