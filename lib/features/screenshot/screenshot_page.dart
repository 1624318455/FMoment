import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'screenshot_service.dart';
import 'screenshot_editor.dart';

class ScreenshotPage extends ConsumerStatefulWidget {
  const ScreenshotPage({super.key});

  @override
  ConsumerState<ScreenshotPage> createState() => _ScreenshotPageState();
}

class _ScreenshotPageState extends ConsumerState<ScreenshotPage> {
  @override
  void initState() {
    super.initState();
    _registerHotkeys();
  }

  void _registerHotkeys() {
    // 注册 PrintScreen 快捷键
    final printScreenHotKey = HotKey(
      key: PhysicalKeyboardKey.printScreen,
      scope: HotKeyScope.system,
    );
    hotKeyManager.register(
      printScreenHotKey,
      keyDownHandler: (hotKey) {
        _captureRegion();
      },
    );

    // 注册 ALT+A 快捷键
    final altAHotKey = HotKey(
      key: LogicalKeyboardKey.keyA,
      modifiers: [HotKeyModifier.alt],
      scope: HotKeyScope.system,
    );
    hotKeyManager.register(
      altAHotKey,
      keyDownHandler: (hotKey) {
        _captureRegion();
      },
    );
  }

  Future<void> _captureRegion() async {
    final screenshotService = ref.read(screenshotServiceProvider);
    final result = await screenshotService.captureRegion();
    if (result != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScreenshotEditor(
            imageBytes: result.imageBytes!,
          ),
        ),
      );
    }
  }

  Future<void> _captureFullScreen() async {
    final screenshotService = ref.read(screenshotServiceProvider);
    final result = await screenshotService.captureFullScreen();
    if (result != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScreenshotEditor(
            imageBytes: result.imageBytes!,
          ),
        ),
      );
    }
  }

  Future<void> _captureWindow() async {
    final screenshotService = ref.read(screenshotServiceProvider);
    final result = await screenshotService.captureWindow();
    if (result != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScreenshotEditor(
            imageBytes: result.imageBytes!,
          ),
        ),
      );
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
            '截图工具',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '按 PrintScreen 或 ALT+A 开始截图',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '截图后可进行标注、取色等操作',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: _captureRegion,
                        icon: const Icon(Icons.crop),
                        label: const Text('区域截图'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: _captureFullScreen,
                        icon: const Icon(Icons.fullscreen),
                        label: const Text('全屏截图'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: _captureWindow,
                        icon: const Icon(Icons.window),
                        label: const Text('窗口截图'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // 注销热键
    hotKeyManager.unregisterAll();
    super.dispose();
  }
}
