import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'package:path/path.dart' as p;
import '../../platform/platform_service.dart';
import '../../data/config_service.dart';

final screenshotServiceProvider = Provider<ScreenshotService>((ref) {
  return ScreenshotService(ref);
});

class ScreenshotService {
  final Ref _ref;
  final PlatformService _platformService = PlatformService();

  ScreenshotService(this._ref);

  // 截图状态
  CapturedData? _lastCapture;
  Uint8List? _lastImageBytes;

  CapturedData? get lastCapture => _lastCapture;
  Uint8List? get lastImageBytes => _lastImageBytes;

  Future<String> _getSavePath() async {
    final configService = _ref.read(configServiceProvider);
    final dir = await configService.getScreenshotSavePath();
    await Directory(dir).create(recursive: true);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return p.join(dir, 'screenshot_$timestamp.png');
  }

  // 区域截图
  Future<CapturedData?> captureRegion() async {
    final imagePath = await _getSavePath();
    final result = await _platformService.captureScreen(
      mode: CaptureMode.region,
      imagePath: imagePath,
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
    final imagePath = await _getSavePath();
    final result = await _platformService.captureScreen(
      mode: CaptureMode.screen,
      imagePath: imagePath,
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
    final imagePath = await _getSavePath();
    final result = await _platformService.captureScreen(
      mode: CaptureMode.window,
      imagePath: imagePath,
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
