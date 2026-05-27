import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'color_card_service.dart';

class ColorCardPage extends ConsumerStatefulWidget {
  const ColorCardPage({super.key});

  @override
  ConsumerState<ColorCardPage> createState() => _ColorCardPageState();
}

class _ColorCardPageState extends ConsumerState<ColorCardPage> {
  int? _selectedGroupId;
  int? _selectedCardId;
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _cards = [];
  List<Map<String, dynamic>> _colors = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final colorCardService = ref.read(colorCardServiceProvider);
    final groups = await colorCardService.getGroups();
    final cards = await colorCardService.getCards(groupId: _selectedGroupId);

    setState(() {
      _groups = groups;
      _cards = cards;
    });

    if (_selectedCardId != null) {
      final colors = await colorCardService.getColors(_selectedCardId!);
      setState(() {
        _colors = colors;
      });
    }
  }

  Future<void> _createGroup() async {
    final name = await _showInputDialog('新建分组', '请输入分组名称');
    if (name != null && name.isNotEmpty) {
      final colorCardService = ref.read(colorCardServiceProvider);
      await colorCardService.createGroup(name);
      await _loadData();
    }
  }

  Future<void> _createCard() async {
    final name = await _showInputDialog('新建色卡', '请输入色卡名称');
    if (name != null && name.isNotEmpty) {
      final colorCardService = ref.read(colorCardServiceProvider);
      await colorCardService.createCard(
        name: name,
        groupId: _selectedGroupId,
      );
      await _loadData();
    }
  }

  Future<void> _deleteGroup(int id) async {
    final confirmed = await _showConfirmDialog('删除分组', '确定要删除该分组吗？分组内的色卡将移到默认分组。');
    if (confirmed) {
      final colorCardService = ref.read(colorCardServiceProvider);
      await colorCardService.deleteGroup(id);
      if (_selectedGroupId == id) {
        _selectedGroupId = null;
      }
      await _loadData();
    }
  }

  Future<void> _deleteCard(int id) async {
    final confirmed = await _showConfirmDialog('删除色卡', '确定要删除该色卡吗？色卡内的颜色将被删除。');
    if (confirmed) {
      final colorCardService = ref.read(colorCardServiceProvider);
      await colorCardService.deleteCard(id);
      if (_selectedCardId == id) {
        _selectedCardId = null;
        _colors = [];
      }
      await _loadData();
    }
  }

  Future<void> _addColorToCard() async {
    if (_selectedCardId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择一个色卡')),
      );
      return;
    }

    // TODO: 打开颜色选择器
    // 这里暂时使用固定颜色
    final colorCardService = ref.read(colorCardServiceProvider);
    await colorCardService.addColor(
      cardId: _selectedCardId!,
      color: Colors.blue,
    );
    await _loadData();
  }

  Future<void> _deleteColor(int id) async {
    final colorCardService = ref.read(colorCardServiceProvider);
    await colorCardService.deleteColor(id);
    await _loadData();
  }

  Future<void> _exportCard() async {
    if (_selectedCardId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择一个色卡')),
      );
      return;
    }

    final colorCardService = ref.read(colorCardServiceProvider);
    final data = await colorCardService.exportCard(_selectedCardId!);
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

    await Clipboard.setData(ClipboardData(text: jsonStr));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('色卡 JSON 已复制到剪贴板')),
      );
    }
  }

  Future<void> _importCard() async {
    final jsonStr = await _showInputDialog('导入色卡', '请粘贴色卡 JSON 数据');
    if (jsonStr == null || jsonStr.isEmpty) return;

    try {
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final colorCardService = ref.read(colorCardServiceProvider);
      await colorCardService.importCard(data);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('色卡导入成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  Future<String?> _showInputDialog(String title, String hint) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '色卡管理',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _importCard,
                icon: const Icon(Icons.upload),
                label: const Text('导入'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _exportCard,
                icon: const Icon(Icons.download),
                label: const Text('导出'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _createCard,
                icon: const Icon(Icons.add),
                label: const Text('新建色卡'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧：分组列表
                SizedBox(
                  width: 200,
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Text(
                                '分组',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.add, size: 20),
                                onPressed: _createGroup,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _groups.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return ListTile(
                                  leading: const Icon(Icons.folder),
                                  title: const Text('全部'),
                                  selected: _selectedGroupId == null,
                                  onTap: () {
                                    setState(() {
                                      _selectedGroupId = null;
                                    });
                                    _loadData();
                                  },
                                );
                              }

                              final group = _groups[index - 1];
                              return ListTile(
                                leading: const Icon(Icons.folder),
                                title: Text(group['name'] as String),
                                selected: _selectedGroupId == group['id'],
                                onTap: () {
                                  setState(() {
                                    _selectedGroupId = group['id'] as int;
                                  });
                                  _loadData();
                                },
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, size: 16),
                                  onPressed: () => _deleteGroup(group['id'] as int),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 中间：色卡列表
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            '色卡列表',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Expanded(
                          child: _cards.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.palette_outlined,
                                        size: 48,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '暂无色卡',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '点击"新建色卡"开始创建',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _cards.length,
                                  itemBuilder: (context, index) {
                                    final card = _cards[index];
                                    return ListTile(
                                      title: Text(card['name'] as String),
                                      subtitle: card['desc'] != null
                                          ? Text(card['desc'] as String)
                                          : null,
                                      selected: _selectedCardId == card['id'],
                                      onTap: () {
                                        setState(() {
                                          _selectedCardId = card['id'] as int;
                                        });
                                        _loadData();
                                      },
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete, size: 16),
                                        onPressed: () => _deleteCard(card['id'] as int),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 右侧：颜色列表
                Expanded(
                  flex: 3,
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Text(
                                '颜色列表',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              if (_selectedCardId != null)
                                FilledButton.icon(
                                  onPressed: _addColorToCard,
                                  icon: const Icon(Icons.add),
                                  label: const Text('添加颜色'),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _colors.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.color_lens_outlined,
                                        size: 48,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _selectedCardId == null ? '请选择一个色卡' : '暂无颜色',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _colors.length,
                                  itemBuilder: (context, index) {
                                    final color = _colors[index];
                                    final hex = color['hex'] as String;
                                    final r = color['rgb_r'] as int;
                                    final g = color['rgb_g'] as int;
                                    final b = color['rgb_b'] as int;

                                    return ListTile(
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(255, r, g, b),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: Theme.of(context).colorScheme.outline,
                                          ),
                                        ),
                                      ),
                                      title: Text(hex),
                                      subtitle: Text('RGB($r, $g, $b)'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.copy, size: 16),
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(text: hex));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('已复制: $hex')),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 16),
                                            onPressed: () => _deleteColor(color['id'] as int),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
