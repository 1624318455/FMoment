import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../platform/win32_color.dart';
import '../../utils/color/color_utils.dart';

class ColorPickerOverlay extends ConsumerStatefulWidget {
  final void Function(Color color) onColorPicked;
  final VoidCallback onCancel;

  const ColorPickerOverlay({
    super.key,
    required this.onColorPicked,
    required this.onCancel,
  });

  @override
  ConsumerState<ColorPickerOverlay> createState() => _ColorPickerOverlayState();
}

class _ColorPickerOverlayState extends ConsumerState<ColorPickerOverlay> {
  Offset _cursorPosition = Offset.zero;
  Color _currentColor = Colors.black;
  Timer? _timer;
  final int _gridSize = 15;
  final double _pixelSize = 12;
  final List<List<Color>> _gridColors = [];

  @override
  void initState() {
    super.initState();
    _gridColors.clear();
    for (int i = 0; i < _gridSize; i++) {
      _gridColors.add(List.filled(_gridSize, Colors.black));
    }
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _updateColor();
    });
  }

  void _updateColor() {
    final cursorPos = _getCursorPos();
    final x = cursorPos.dx.toInt();
    final y = cursorPos.dy.toInt();

    final centerColor = Win32Color.getColorAt(x, y);
    final r = Win32Color.getRValue(centerColor);
    final g = Win32Color.getGValue(centerColor);
    final b = Win32Color.getBValue(centerColor);

    final half = _gridSize ~/ 2;
    for (int dy = -half; dy <= half; dy++) {
      for (int dx = -half; dx <= half; dx++) {
        final px = x + dx;
        final py = y + dy;
        final colorInt = Win32Color.getColorAt(px, py);
        final pr = Win32Color.getRValue(colorInt);
        final pg = Win32Color.getGValue(colorInt);
        final pb = Win32Color.getBValue(colorInt);
        _gridColors[dy + half][dx + half] = Color.fromARGB(255, pr, pg, pb);
      }
    }

    setState(() {
      _cursorPosition = Offset(x.toDouble(), y.toDouble());
      _currentColor = Color.fromARGB(255, r, g, b);
    });
  }

  Offset _getCursorPos() {
    final pos = _cursorPosition;
    return pos;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = (_currentColor.r * 255.0).round().clamp(0, 255);
    final g = (_currentColor.g * 255.0).round().clamp(0, 255);
    final b = (_currentColor.b * 255.0).round().clamp(0, 255);

    final hex = ColorUtils.rgbToHex(r, g, b);
    final hsl = ColorUtils.rgbToHsl(r, g, b);

    return Stack(
      children: [
        // 全屏透明层，捕获点击和键盘事件
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              widget.onColorPicked(_currentColor);
            },
            child: Container(color: Colors.transparent),
          ),
        ),
        // 键盘事件
        KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.escape) {
                widget.onCancel();
              } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                widget.onColorPicked(_currentColor);
              }
            }
          },
          child: const SizedBox.expand(),
        ),
        // 放大镜跟随鼠标
        Positioned(
          left: _cursorPosition.dx + 20,
          top: _cursorPosition.dy + 20,
          child: _buildMagnifier(hex, hsl),
        ),
        // 颜色值显示
        Positioned(
          left: _cursorPosition.dx + 20,
          top: _cursorPosition.dy + 20 + (_gridSize * _pixelSize) + 60,
          child: _buildColorInfo(hex, hsl),
        ),
        // 顶部提示
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '点击取色 | ESC 取消 | ENTER 确认',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMagnifier(String hex, Map<String, int> hsl) {
    final magnifierSize = _gridSize * _pixelSize;

    return Container(
      width: magnifierSize + 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 放大网格
          SizedBox(
            width: magnifierSize,
            height: magnifierSize,
            child: CustomPaint(
              painter: _GridPainter(
                gridColors: _gridColors,
                gridSize: _gridSize,
                pixelSize: _pixelSize,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 中心颜色预览
          Container(
            width: magnifierSize,
            height: 24,
            decoration: BoxDecoration(
              color: _currentColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorInfo(String hex, Map<String, int> hsl) {
    final r = (_currentColor.r * 255.0).round().clamp(0, 255);
    final g = (_currentColor.g * 255.0).round().clamp(0, 255);
    final b = (_currentColor.b * 255.0).round().clamp(0, 255);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _infoRow('HEX', hex),
          const SizedBox(height: 4),
          _infoRow('RGB', 'rgb($r, $g, $b)'),
          const SizedBox(height: 4),
          _infoRow('HSL', 'hsl(${hsl['h']}, ${hsl['s']}%, ${hsl['l']}%)'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 32,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final List<List<Color>> gridColors;
  final int gridSize;
  final double pixelSize;

  _GridPainter({
    required this.gridColors,
    required this.gridSize,
    required this.pixelSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final half = gridSize ~/ 2;
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final paint = Paint()..color = gridColors[y][x];
        final rect = Rect.fromLTWH(
          x * pixelSize,
          y * pixelSize,
          pixelSize,
          pixelSize,
        );
        canvas.drawRect(rect, paint);

        // 网格线
        final gridPaint = Paint()
          ..color = Colors.white12
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
        canvas.drawRect(rect, gridPaint);
      }
    }

    // 中心十字标记
    final center = half * pixelSize + pixelSize / 2;
    final crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(center - pixelSize, center),
      Offset(center + pixelSize, center),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center, center - pixelSize),
      Offset(center, center + pixelSize),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
