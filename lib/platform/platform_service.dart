import 'dart:ui';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'package:window_manager/window_manager.dart';
import 'package:system_tray/system_tray.dart';

class PlatformService {
  static final PlatformService _instance = PlatformService._();
  factory PlatformService() => _instance;
  PlatformService._();

  // 屏幕信息
  Future<Size> getScreenSize() async {
    final display = await ScreenRetriever.instance.getPrimaryDisplay();
    return Size(display.size.width, display.size.height);
  }

  // 截图
  Future<CapturedData?> captureScreen({
    required CaptureMode mode,
    String? imagePath,
    bool copyToClipboard = true,
    bool silent = true,
  }) async {
    final capturer = ScreenCapturer.instance;
    return await capturer.capture(
      mode: mode,
      imagePath: imagePath,
      copyToClipboard: copyToClipboard,
      silent: silent,
    );
  }

  // 窗口管理
  Future<void> setWindowAlwaysOnTop(bool onTop) async {
    await windowManager.setAlwaysOnTop(onTop);
  }

  Future<void> setWindowOpacity(double opacity) async {
    await windowManager.setOpacity(opacity);
  }

  Future<void> setWindowSize(Size size) async {
    await windowManager.setSize(size);
  }

  Future<void> setWindowPosition(Offset position) async {
    await windowManager.setPosition(position);
  }

  Future<void> hideWindow() async {
    await windowManager.hide();
  }

  Future<void> showWindow() async {
    await windowManager.show();
  }

  // 系统托盘
  Future<void> initSystemTray({
    required String iconPath,
    required String title,
    required Menu menu,
  }) async {
    final tray = SystemTray();
    await tray.initSystemTray(
      iconPath: iconPath,
      title: title,
    );
    await tray.setContextMenu(menu);
  }
}
