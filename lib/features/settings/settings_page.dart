import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/config_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _hotkeyScreenshot = 'PrintScreen';
  String _hotkeyColorPicker = 'ALT+C';
  bool _autoStart = false;
  bool _minimizeToTray = true;
  String _screenshotSavePath = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final configService = ref.read(configServiceProvider);
    final path = await configService.getScreenshotSavePath();
    if (mounted) {
      setState(() {
        _screenshotSavePath = path;
      });
    }
  }

  Future<void> _pickScreenshotPath() async {
    final controller = TextEditingController(text: _screenshotSavePath);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置截图保存路径'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入完整路径，如 D:\\Screenshots',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 用资源管理器打开当前路径
              final path = controller.text.isNotEmpty
                  ? controller.text
                  : _screenshotSavePath;
              if (Directory(path).existsSync()) {
                Process.run('explorer', [path]);
              }
            },
            child: const Text('打开文件夹'),
          ),
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

    if (result != null && result.isNotEmpty) {
      final configService = ref.read(configServiceProvider);
      await configService.setScreenshotSavePath(result);
      await Directory(result).create(recursive: true);
      if (mounted) {
        setState(() {
          _screenshotSavePath = result;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '设置',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildSection(
                  context,
                  title: '截图',
                  children: [
                    ListTile(
                      title: const Text('截图保存路径'),
                      subtitle: Text(
                        _screenshotSavePath.isEmpty ? '加载中...' : _screenshotSavePath,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: TextButton(
                        onPressed: _pickScreenshotPath,
                        child: const Text('修改'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  title: '快捷键',
                  children: [
                    _buildHotkeySetting(
                      context,
                      title: '截图快捷键',
                      value: _hotkeyScreenshot,
                      onChanged: (value) {
                        setState(() {
                          _hotkeyScreenshot = value;
                        });
                      },
                    ),
                    _buildHotkeySetting(
                      context,
                      title: '取色快捷键',
                      value: _hotkeyColorPicker,
                      onChanged: (value) {
                        setState(() {
                          _hotkeyColorPicker = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  title: '通用',
                  children: [
                    SwitchListTile(
                      title: const Text('开机自启'),
                      subtitle: const Text('Windows 启动时自动运行 FMoment'),
                      value: _autoStart,
                      onChanged: (value) {
                        setState(() {
                          _autoStart = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('最小化到托盘'),
                      subtitle: const Text('关闭窗口时最小化到系统托盘'),
                      value: _minimizeToTray,
                      onChanged: (value) {
                        setState(() {
                          _minimizeToTray = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  title: '关于',
                  children: [
                    const ListTile(
                      title: Text('版本'),
                      subtitle: Text('1.0.0'),
                    ),
                    ListTile(
                      title: const Text('项目地址'),
                      subtitle: const Text('github.com/1624318455/FMoment'),
                      onTap: () {
                        // TODO: 打开链接
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildHotkeySetting(
    BuildContext context, {
    required String title,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
      trailing: TextButton(
        onPressed: () {
          // TODO: 修改快捷键
        },
        child: const Text('修改'),
      ),
    );
  }
}
