import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                    ListTile(
                      title: const Text('版本'),
                      subtitle: const Text('1.0.0'),
                    ),
                    ListTile(
                      title: const Text('项目地址'),
                      subtitle: const Text('github.com/memeflyfly/FMoment'),
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
