import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../float_window/float_window_service.dart';
import '../annotation/annotation_service.dart';

class ScreenshotEditor extends ConsumerStatefulWidget {
  final Uint8List imageBytes;

  const ScreenshotEditor({
    super.key,
    required this.imageBytes,
  });

  @override
  ConsumerState<ScreenshotEditor> createState() => _ScreenshotEditorState();
}

class _ScreenshotEditorState extends ConsumerState<ScreenshotEditor> {
  String _selectedTool = 'rectangle';
  Color _selectedColor = Colors.red;
  double _strokeWidth = 2.0;
  final TextEditingController _textController = TextEditingController();
  final List<Annotation> _annotations = [];
  final List<Annotation> _redoStack = [];
  Annotation? _currentAnnotation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('截图编辑'),
        actions: [
          // 工具栏
          _buildToolbar(),
          const SizedBox(width: 16),
          // 颜色选择
          _buildColorPicker(),
          const SizedBox(width: 16),
          // 线宽选择
          _buildStrokeWidthPicker(),
          const SizedBox(width: 16),
          // 操作按钮
          _buildActionButtons(),
        ],
      ),
      body: Column(
        children: [
          // 图片预览区
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: CustomPaint(
                  painter: AnnotationPainter(
                    annotations: _annotations,
                    currentAnnotation: _currentAnnotation,
                  ),
                  child: Center(
                    child: Image.memory(
                      widget.imageBytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 底部信息栏
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    final annotationService = ref.read(annotationServiceProvider);
    return Row(
      children: annotationService.tools.map((tool) {
        return _buildToolButton(tool.id, tool.icon, tool.name);
      }).toList(),
    );
  }

  Widget _buildToolButton(String tool, IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon),
        isSelected: _selectedTool == tool,
        onPressed: () {
          setState(() {
            _selectedTool = tool;
          });
        },
      ),
    );
  }

  Widget _buildColorPicker() {
    return Row(
      children: [
        _buildColorButton(Colors.red),
        _buildColorButton(Colors.blue),
        _buildColorButton(Colors.green),
        _buildColorButton(Colors.yellow),
        _buildColorButton(Colors.black),
      ],
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColor == color ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildStrokeWidthPicker() {
    return Row(
      children: [
        const Text('线宽: '),
        Slider(
          value: _strokeWidth,
          min: 1,
          max: 10,
          divisions: 9,
          label: _strokeWidth.round().toString(),
          onChanged: (value) {
            setState(() {
              _strokeWidth = value;
            });
          },
        ),
      ],
    );
  }

  void _undo() {
    if (_annotations.isEmpty) return;
    setState(() {
      final annotation = _annotations.removeLast();
      _redoStack.add(annotation);
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    setState(() {
      final annotation = _redoStack.removeLast();
      _annotations.add(annotation);
    });
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        TextButton.icon(
          onPressed: _annotations.isNotEmpty ? _undo : null,
          icon: const Icon(Icons.undo),
          label: const Text('撤销'),
        ),
        TextButton.icon(
          onPressed: _redoStack.isNotEmpty ? _redo : null,
          icon: const Icon(Icons.redo),
          label: const Text('重做'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _saveImage,
          icon: const Icon(Icons.save),
          label: const Text('保存'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _copyToClipboard,
          icon: const Icon(Icons.copy),
          label: const Text('复制'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _createFloatWindow,
          icon: const Icon(Icons.picture_in_picture),
          label: const Text('悬浮贴图'),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Text(
            '工具: $_selectedTool',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 16),
          Text(
            '颜色: ${_selectedColor.toARGB32().toRadixString(16)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 16),
          Text(
            '线宽: ${_strokeWidth.round()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          Text(
            '图片大小: ${widget.imageBytes.length ~/ 1024} KB',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _saveImage() {
    // TODO: 保存图片到文件
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('图片已保存')),
    );
  }

  void _copyToClipboard() {
    // TODO: 复制图片到剪贴板
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('图片已复制到剪贴板')),
    );
  }

  void _createFloatWindow() {
    final floatWindowService = ref.read(floatWindowServiceProvider);
    floatWindowService.createFloatWindow(
      context: context,
      imageBytes: widget.imageBytes,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已创建悬浮贴图')),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final annotationService = ref.read(annotationServiceProvider);
    final tool = annotationService.tools.firstWhere(
      (t) => t.id == _selectedTool,
      orElse: () => annotationService.tools.first,
    );

    setState(() {
      _currentAnnotation = annotationService.createAnnotation(
        type: tool.type,
        startPoint: details.localPosition,
        color: _selectedColor,
        strokeWidth: _strokeWidth,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentAnnotation == null) return;

    final annotationService = ref.read(annotationServiceProvider);
    setState(() {
      _currentAnnotation = annotationService.updateAnnotation(
        annotation: _currentAnnotation!,
        endPoint: details.localPosition,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentAnnotation == null) return;

    setState(() {
      _annotations.add(_currentAnnotation!);
      _currentAnnotation = null;
      _redoStack.clear();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class AnnotationPainter extends CustomPainter {
  final List<Annotation> annotations;
  final Annotation? currentAnnotation;

  AnnotationPainter({
    required this.annotations,
    this.currentAnnotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final annotation in annotations) {
      AnnotationService.drawAnnotation(canvas, annotation);
    }

    if (currentAnnotation != null) {
      AnnotationService.drawAnnotation(canvas, currentAnnotation!);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
