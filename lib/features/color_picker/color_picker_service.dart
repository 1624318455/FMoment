import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/color/color_utils.dart';

final colorPickerServiceProvider = Provider<ColorPickerService>((ref) {
  return ColorPickerService();
});

class ColorPickerService {

  // 取色历史
  final List<Color> _colorHistory = [];
  List<Color> get colorHistory => List.unmodifiable(_colorHistory);

  // 获取屏幕指定位置的颜色
  // TODO: 实现屏幕取色功能
  Future<Color> getColorAtPosition(Offset position) async {
    // 暂时返回默认颜色
    return Colors.blue;
  }

  // 添加到取色历史
  void addToHistory(Color color) {
    _colorHistory.insert(0, color);
    if (_colorHistory.length > 100) {
      _colorHistory.removeLast();
    }
  }

  // 清除取色历史
  void clearHistory() {
    _colorHistory.clear();
  }

  // 获取颜色的各种格式
  Map<String, String> getColorFormats(Color color) {
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);

    final hex = ColorUtils.rgbToHex(r, g, b);
    final hsl = ColorUtils.rgbToHsl(r, g, b);

    return {
      'HEX': hex,
      'RGB': 'rgb($r, $g, $b)',
      'HSL': 'hsl(${hsl['h']}, ${hsl['s']}%, ${hsl['l']}%)',
      'R': r.toString(),
      'G': g.toString(),
      'B': b.toString(),
      'H': hsl['h'].toString(),
      'S': hsl['s'].toString(),
      'L': hsl['l'].toString(),
    };
  }

  // 获取互补色
  Color getComplementary(Color color) {
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);

    final complementary = ColorUtils.complementary(r, g, b);
    return Color.fromARGB(
      255,
      complementary['r']!,
      complementary['g']!,
      complementary['b']!,
    );
  }

  // 获取邻近色
  List<Color> getAnalogous(Color color) {
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);

    final analogous = ColorUtils.analogous(r, g, b);
    return analogous
        .map((c) => Color.fromARGB(255, c['r']!, c['g']!, c['b']!))
        .toList();
  }

  // 获取暗黑主题配色
  Color getDarkTheme(Color color) {
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);

    final dark = ColorUtils.darkTheme(r, g, b);
    return Color.fromARGB(255, dark['r']!, dark['g']!, dark['b']!);
  }

  // 检查 WCAG 对比度
  Map<String, dynamic> checkContrast(Color foreground, Color background) {
    final fr = (foreground.r * 255.0).round().clamp(0, 255);
    final fg = (foreground.g * 255.0).round().clamp(0, 255);
    final fb = (foreground.b * 255.0).round().clamp(0, 255);

    final br = (background.r * 255.0).round().clamp(0, 255);
    final bg = (background.g * 255.0).round().clamp(0, 255);
    final bb = (background.b * 255.0).round().clamp(0, 255);

    return ColorUtils.checkWCAG(fr, fg, fb, br, bg, bb);
  }
}
