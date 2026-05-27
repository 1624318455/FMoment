import 'dart:math';

class ColorUtils {
  // HEX 转 RGB
  static Map<String, int> hexToRgb(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 3) {
      hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
    }
    return {
      'r': int.parse(hex.substring(0, 2), radix: 16),
      'g': int.parse(hex.substring(2, 4), radix: 16),
      'b': int.parse(hex.substring(4, 6), radix: 16),
    };
  }

  // RGB 转 HEX
  static String rgbToHex(int r, int g, int b) {
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  // RGB 转 HSL
  static Map<String, int> rgbToHsl(int r, int g, int b) {
    final rf = r / 255.0;
    final gf = g / 255.0;
    final bf = b / 255.0;

    final max = [rf, gf, bf].reduce((a, b) => a > b ? a : b);
    final min = [rf, gf, bf].reduce((a, b) => a < b ? a : b);
    final delta = max - min;

    double h = 0;
    double s = 0;
    final l = (max + min) / 2;

    if (delta != 0) {
      s = l > 0.5 ? delta / (2 - max - min) : delta / (max + min);

      if (max == rf) {
        h = ((gf - bf) / delta + (gf < bf ? 6 : 0)) * 60;
      } else if (max == gf) {
        h = ((bf - rf) / delta + 2) * 60;
      } else {
        h = ((rf - gf) / delta + 4) * 60;
      }
    }

    return {
      'h': h.round(),
      's': (s * 100).round(),
      'l': (l * 100).round(),
    };
  }

  // HSL 转 RGB
  static Map<String, int> hslToRgb(int h, int s, int l) {
    final hf = h / 360.0;
    final sf = s / 100.0;
    final lf = l / 100.0;

    if (sf == 0) {
      final gray = (lf * 255).round();
      return {'r': gray, 'g': gray, 'b': gray};
    }

    final q = lf < 0.5 ? lf * (1 + sf) : lf + sf - lf * sf;
    final p = 2 * lf - q;

    double hueToRgb(double p, double q, double t) {
      if (t < 0) t += 1;
      if (t > 1) t -= 1;
      if (t < 1 / 6) return p + (q - p) * 6 * t;
      if (t < 1 / 2) return q;
      if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
      return p;
    }

    return {
      'r': (hueToRgb(p, q, hf + 1 / 3) * 255).round(),
      'g': (hueToRgb(p, q, hf) * 255).round(),
      'b': (hueToRgb(p, q, hf - 1 / 3) * 255).round(),
    };
  }

  // 互补色
  static Map<String, int> complementary(int r, int g, int b) {
    final hsl = rgbToHsl(r, g, b);
    final newH = (hsl['h']! + 180) % 360;
    return hslToRgb(newH, hsl['s']!, hsl['l']!);
  }

  // 邻近色
  static List<Map<String, int>> analogous(int r, int g, int b) {
    final hsl = rgbToHsl(r, g, b);
    return [
      hslToRgb((hsl['h']! - 30 + 360) % 360, hsl['s']!, hsl['l']!),
      {'r': r, 'g': g, 'b': b},
      hslToRgb((hsl['h']! + 30) % 360, hsl['s']!, hsl['l']!),
    ];
  }

  // 暗黑主题配色
  static Map<String, int> darkTheme(int r, int g, int b) {
    final hsl = rgbToHsl(r, g, b);
    return hslToRgb(hsl['h']!, (hsl['s']! * 0.8).round(), (hsl['l']! * 0.3).round());
  }

  // WCAG 对比度计算
  static double contrastRatio(int r1, int g1, int b1, int r2, int g2, int b2) {
    final l1 = _relativeLuminance(r1, g1, b1);
    final l2 = _relativeLuminance(r2, g2, b2);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _relativeLuminance(int r, int g, int b) {
    final rf = _srgbToLinear(r / 255.0);
    final gf = _srgbToLinear(g / 255.0);
    final bf = _srgbToLinear(b / 255.0);
    return 0.2126 * rf + 0.7152 * gf + 0.0722 * bf;
  }

  static double _srgbToLinear(double value) {
    return value <= 0.03928 ? value / 12.92 : _pow((value + 0.055) / 1.055, 2.4);
  }

  static double _pow(double base, double exponent) => pow(base, exponent).toDouble();

  // WCAG 合规检查
  static Map<String, dynamic> checkWCAG(int r1, int g1, int b1, int r2, int g2, int b2) {
    final ratio = contrastRatio(r1, g1, b1, r2, g2, b2);
    return {
      'ratio': ratio,
      'AA_normal': ratio >= 4.5,
      'AA_large': ratio >= 3,
      'AAA_normal': ratio >= 7,
      'AAA_large': ratio >= 4.5,
    };
  }
}
