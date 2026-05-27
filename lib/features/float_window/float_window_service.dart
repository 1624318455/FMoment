import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final floatWindowServiceProvider = Provider<FloatWindowService>((ref) {
  return FloatWindowService();
});

class FloatWindowService {
  // 悬浮窗口列表
  final List<OverlayEntry> _floatWindows = [];

  // 创建悬浮贴图窗口
  Future<void> createFloatWindow({
    required BuildContext context,
    required Uint8List imageBytes,
    Offset? position,
    Size? size,
  }) async {
    // 创建一个新的悬浮窗口
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => FloatWindowWidget(
        imageBytes: imageBytes,
        initialPosition: position ?? const Offset(100, 100),
        initialSize: size ?? const Size(300, 200),
        onClose: () {
          entry.remove();
          _floatWindows.remove(entry);
        },
      ),
    );

    overlay.insert(entry);
    _floatWindows.add(entry);
  }

  // 关闭所有悬浮窗口
  void closeAll() {
    for (final entry in _floatWindows) {
      entry.remove();
    }
    _floatWindows.clear();
  }
}

class FloatWindowWidget extends StatefulWidget {
  final Uint8List imageBytes;
  final Offset initialPosition;
  final Size initialSize;
  final VoidCallback onClose;

  const FloatWindowWidget({
    super.key,
    required this.imageBytes,
    required this.initialPosition,
    required this.initialSize,
    required this.onClose,
  });

  @override
  State<FloatWindowWidget> createState() => _FloatWindowWidgetState();
}

class _FloatWindowWidgetState extends State<FloatWindowWidget> {
  late Offset _position;
  late Size _size;
  double _opacity = 1.0;
  bool _isAlwaysOnTop = true;
  bool _isMouseTransparent = false;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    _size = widget.initialSize;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        child: MouseRegion(
          opaque: !_isMouseTransparent,
          child: Opacity(
            opacity: _opacity,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: _size.width,
                height: _size.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Column(
                  children: [
                    // 标题栏
                    _buildTitleBar(),
                    // 图片内容
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                        child: Image.memory(
                          widget.imageBytes,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(
            '悬浮贴图',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const Spacer(),
          // 缩放控制
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            onPressed: () {
              setState(() {
                _size = Size(
                  _size.width * 0.9,
                  _size.height * 0.9,
                );
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            onPressed: () {
              setState(() {
                _size = Size(
                  _size.width * 1.1,
                  _size.height * 1.1,
                );
              });
            },
          ),
          // 透明度控制
          IconButton(
            icon: Icon(
              _opacity < 1.0 ? Icons.visibility_off : Icons.visibility,
              size: 16,
            ),
            onPressed: () {
              setState(() {
                _opacity = _opacity < 1.0 ? 1.0 : 0.5;
              });
            },
          ),
          // 置顶控制
          IconButton(
            icon: Icon(
              _isAlwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined,
              size: 16,
            ),
            onPressed: () {
              setState(() {
                _isAlwaysOnTop = !_isAlwaysOnTop;
              });
              // TODO: 设置窗口置顶
            },
          ),
          // 鼠标穿透控制
          IconButton(
            icon: Icon(
              _isMouseTransparent ? Icons.mouse : Icons.mouse_outlined,
              size: 16,
            ),
            onPressed: () {
              setState(() {
                _isMouseTransparent = !_isMouseTransparent;
              });
            },
          ),
          // 关闭按钮
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }
}
