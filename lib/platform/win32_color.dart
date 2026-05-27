import 'package:win32/win32.dart';

class Win32Color {
  static int getColorAt(int x, int y) {
    final hdc = GetDC(NULL);
    if (hdc == 0) return 0xFF000000;

    final pixel = GetPixel(hdc, x, y);
    ReleaseDC(NULL, hdc);

    if (pixel == -1) return 0xFF000000;

    final r = GetRValue(pixel);
    final g = GetGValue(pixel);
    final b = GetBValue(pixel);

    return (0xFF << 24) | (r << 16) | (g << 8) | b;
  }

  static int getRValue(int color) => (color >> 16) & 0xFF;
  static int getGValue(int color) => (color >> 8) & 0xFF;
  static int getBValue(int color) => color & 0xFF;
}
