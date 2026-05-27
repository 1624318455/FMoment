import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_capturer/screen_capturer.dart';
import '../../platform/platform_service.dart';

final screenshotServiceProvider = Provider<ScreenshotService>((ref) {
  return ScreenshotService();
});

class ScreenshotService {
  final PlatformService _platformService = PlatformService();

  // 截图状态
  CapturedData? _lastCapture;
  Uint8List? _lastImageBytes;

  CapturedData? get lastCapture => _lastCapture;
  Uint8List? get lastImageBytes => _lastImageBytes;

  // 区域截图
  Future<CapturedData?> captureRegion() async {
    final result = await _platformService.captureScreen(
      mode: CaptureMode.region,
      silent: false,
    );
    if (result != null) {
      _lastCapture = result;
      _lastImageBytes = result.imageBytes;
    }
    return result;
  }

  // 全屏截图
  Future<CapturedData?> captureFullScreen() async {
    final result = await _platformService.captureScreen(
      mode: CaptureMode.screen,
      silent: true,
    );
    if (result != null) {
      _lastCapture = result;
      _lastImageBytes = result.imageBytes;
    }
    return result;
  }

  // 窗口截图
  Future<CapturedData?> captureWindow() async {
    final result = await _platformService.captureScreen(
      mode: CaptureMode.window,
      silent: false,
    );
    if (result != null) {
      _lastCapture = result;
      _lastImageBytes = result.imageBytes;
    }
    return result;
  }

  // 清除截图
  void clearCapture() {
    _lastCapture = null;
    _lastImageBytes = null;
  }
}
