class Thresholds {
  // 内存阈值 (MB)
  static const int maxHeapMB = 200;
  static const int idleMemoryMB = 50;

  // 资源闲置释放时间 (ms)
  static const int idleTimeoutMs = 30000;

  // 截图相关
  static const int maxScreenshotWidth = 7680;
  static const int maxScreenshotHeight = 4320;
  static const int screenshotQuality = 90;

  // 取色器相关
  static const int colorPickerZoomLevel = 10;
  static const int colorPickerGridSize = 15;

  // 色卡相关
  static const int maxColorsPerCard = 100;
  static const int maxCardsPerGroup = 50;
  static const int maxGroups = 20;

  // 渐变编辑器
  static const int maxGradientStops = 10;
  static const int minGradientStops = 2;

  // 标注工具
  static const int maxAnnotationFontSize = 72;
  static const int minAnnotationFontSize = 8;
  static const int maxMosaicBlockSize = 20;
  static const int minMosaicBlockSize = 5;
}
