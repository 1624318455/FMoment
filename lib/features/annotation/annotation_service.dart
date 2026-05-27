import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final annotationServiceProvider = Provider<AnnotationService>((ref) {
  return AnnotationService();
});

class AnnotationService {
  // 标注工具类型
  final List<AnnotationTool> _tools = [
    AnnotationTool(
      id: 'rectangle',
      name: '矩形',
      icon: Icons.rectangle_outlined,
      type: AnnotationType.rectangle,
    ),
    AnnotationTool(
      id: 'arrow',
      name: '箭头',
      icon: Icons.arrow_right_alt,
      type: AnnotationType.arrow,
    ),
    AnnotationTool(
      id: 'text',
      name: '文字',
      icon: Icons.text_fields,
      type: AnnotationType.text,
    ),
    AnnotationTool(
      id: 'highlight',
      name: '高亮',
      icon: Icons.highlight,
      type: AnnotationType.highlight,
    ),
    AnnotationTool(
      id: 'mosaic',
      name: '马赛克',
      icon: Icons.grid_on,
      type: AnnotationType.mosaic,
    ),
    AnnotationTool(
      id: 'ellipse',
      name: '椭圆',
      icon: Icons.circle_outlined,
      type: AnnotationType.ellipse,
    ),
    AnnotationTool(
      id: 'line',
      name: '直线',
      icon: Icons.line_axis,
      type: AnnotationType.line,
    ),
    AnnotationTool(
      id: 'freehand',
      name: '画笔',
      icon: Icons.brush,
      type: AnnotationType.freehand,
    ),
  ];

  List<AnnotationTool> get tools => _tools;

  // 创建标注
  Annotation createAnnotation({
    required AnnotationType type,
    required Offset startPoint,
    required Color color,
    required double strokeWidth,
    String? text,
  }) {
    return Annotation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      startPoint: startPoint,
      endPoint: startPoint,
      color: color,
      strokeWidth: strokeWidth,
      text: text,
    );
  }

  // 更新标注
  Annotation updateAnnotation({
    required Annotation annotation,
    Offset? endPoint,
    String? text,
  }) {
    return annotation.copyWith(
      endPoint: endPoint ?? annotation.endPoint,
      text: text ?? annotation.text,
    );
  }

  // 绘制标注
  void drawAnnotation(Canvas canvas, Annotation annotation) {
    switch (annotation.type) {
      case AnnotationType.rectangle:
        _drawRectangle(canvas, annotation);
        break;
      case AnnotationType.arrow:
        _drawArrow(canvas, annotation);
        break;
      case AnnotationType.text:
        _drawText(canvas, annotation);
        break;
      case AnnotationType.highlight:
        _drawHighlight(canvas, annotation);
        break;
      case AnnotationType.mosaic:
        _drawMosaic(canvas, annotation);
        break;
      case AnnotationType.ellipse:
        _drawEllipse(canvas, annotation);
        break;
      case AnnotationType.line:
        _drawLine(canvas, annotation);
        break;
      case AnnotationType.freehand:
        _drawFreehand(canvas, annotation);
        break;
    }
  }

  Paint _strokePaint(Annotation annotation) => Paint()
    ..color = annotation.color
    ..strokeWidth = annotation.strokeWidth
    ..style = PaintingStyle.stroke;

  void _drawRectangle(Canvas canvas, Annotation annotation) {
    final rect = Rect.fromPoints(annotation.startPoint, annotation.endPoint);
    canvas.drawRect(rect, _strokePaint(annotation));
  }

  void _drawArrow(Canvas canvas, Annotation annotation) {
    final start = annotation.startPoint;
    final end = annotation.endPoint;

    canvas.drawLine(start, end, _strokePaint(annotation));

    final arrowSize = annotation.strokeWidth * 3;
    final diff = end - start;
    final length = sqrt(diff.dx * diff.dx + diff.dy * diff.dy);
    if (length == 0) return;
    final direction = Offset(diff.dx / length, diff.dy / length);
    final perpendicular = Offset(-direction.dy, direction.dx);

    final arrowPoint1 = end - direction * arrowSize + perpendicular * arrowSize / 2;
    final arrowPoint2 = end - direction * arrowSize - perpendicular * arrowSize / 2;

    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
      ..close();

    final fillPaint = Paint()
      ..color = annotation.color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
  }

  void _drawText(Canvas canvas, Annotation annotation) {
    if (annotation.text == null || annotation.text!.isEmpty) return;

    final textPainter = TextPainter(
      text: TextSpan(
        text: annotation.text,
        style: TextStyle(
          color: annotation.color,
          fontSize: annotation.strokeWidth * 6,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, annotation.startPoint);
  }

  void _drawHighlight(Canvas canvas, Annotation annotation) {
    final rect = Rect.fromPoints(annotation.startPoint, annotation.endPoint);
    final paint = Paint()
      ..color = annotation.color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);
  }

  void _drawMosaic(Canvas canvas, Annotation annotation) {
    final rect = Rect.fromPoints(annotation.startPoint, annotation.endPoint);
    final blockSize = annotation.strokeWidth * 2;

    for (double x = rect.left; x < rect.right; x += blockSize) {
      for (double y = rect.top; y < rect.bottom; y += blockSize) {
        final blockRect = Rect.fromLTWH(x, y, blockSize, blockSize);
        final paint = Paint()
          ..color = annotation.color.withValues(alpha: 0.5)
          ..style = PaintingStyle.fill;
        canvas.drawRect(blockRect, paint);
      }
    }
  }

  void _drawEllipse(Canvas canvas, Annotation annotation) {
    final rect = Rect.fromPoints(annotation.startPoint, annotation.endPoint);
    canvas.drawOval(rect, _strokePaint(annotation));
  }

  void _drawLine(Canvas canvas, Annotation annotation) {
    canvas.drawLine(annotation.startPoint, annotation.endPoint, _strokePaint(annotation));
  }

  void _drawFreehand(Canvas canvas, Annotation annotation) {
    canvas.drawLine(annotation.startPoint, annotation.endPoint, _strokePaint(annotation));
  }
}

enum AnnotationType {
  rectangle,
  arrow,
  text,
  highlight,
  mosaic,
  ellipse,
  line,
  freehand,
}

class AnnotationTool {
  final String id;
  final String name;
  final IconData icon;
  final AnnotationType type;

  AnnotationTool({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
  });
}

class Annotation {
  final String id;
  final AnnotationType type;
  final Offset startPoint;
  final Offset endPoint;
  final Color color;
  final double strokeWidth;
  final String? text;

  Annotation({
    required this.id,
    required this.type,
    required this.startPoint,
    required this.endPoint,
    required this.color,
    required this.strokeWidth,
    this.text,
  });

  Annotation copyWith({
    Offset? endPoint,
    String? text,
  }) {
    return Annotation(
      id: id,
      type: type,
      startPoint: startPoint,
      endPoint: endPoint ?? this.endPoint,
      color: color,
      strokeWidth: strokeWidth,
      text: text ?? this.text,
    );
  }
}
