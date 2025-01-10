import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dewinter_gallery/core/widgets/annotation_scaffold.dart';
import 'package:flutter/rendering.dart';

class AnnotationPage extends StatefulWidget {
  final String imagePath;

  const AnnotationPage({super.key, required this.imagePath});

  @override
  State<AnnotationPage> createState() => _AnnotationPageState();
}

class _AnnotationPageState extends State<AnnotationPage> {
  final GlobalKey repaintBoundaryKey = GlobalKey();
  final ValueNotifier<String?> selectedShapeNotifier =
      ValueNotifier<String?>(null);

  // Drawing state variables
  final List<Offset?> _points = [];
  final List<Map<String, Object>> _annotations = [];
  Rect? _currentRect;
  Offset? _circleCenter, _circleRadiusPoint;
  Offset? _lineStart, _lineEnd;
  Offset? _textPosition;
  String? _text;

  /// Save annotations based on the selected shape
  void saveAnnotations() {
    setState(() {
      switch (selectedShapeNotifier.value) {
        case 'Freehand':
          if (_points.isNotEmpty) {
            _annotations.add({
              'type': 'Freehand',
              'points': List<Offset?>.from(_points),
            });
            _points.clear();
          }
          break;
        case 'Rectangle':
          if (_currentRect != null) {
            _annotations.add({'type': 'Rectangle', 'rect': _currentRect!});
            _currentRect = null;
          }
          break;
        case 'Circle':
          if (_circleCenter != null && _circleRadiusPoint != null) {
            _annotations.add({
              'type': 'Circle',
              'center': _circleCenter!,
              'radiusPoint': _circleRadiusPoint!
            });
            _circleCenter = null;
            _circleRadiusPoint = null;
          }
          break;
        case 'Line':
          if (_lineStart != null && _lineEnd != null) {
            _annotations.add({
              'type': 'Line',
              'start': _lineStart!,
              'end': _lineEnd!,
            });
            _lineStart = null;
            _lineEnd = null;
          }
          break;
        case 'Horizontal Line':
          if (_lineStart != null) {
            _annotations.add({'type': 'Horizontal Line', 'start': _lineStart!});
            _lineStart = null;
          }
          break;
        case 'Vertical Line':
          if (_lineStart != null) {
            _annotations.add({'type': 'Vertical Line', 'start': _lineStart!});
            _lineStart = null;
          }
          break;
        case 'Text':
          if (_textPosition != null && _text != null) {
            _annotations.add({
              'type': 'Text',
              'position': _textPosition!,
              'text': _text!,
            });
            _textPosition = null;
            _text = null;
          }
          break;
      }
    });
  }

  /// Save the current canvas as an image
  Future<void> saveImage() async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Failed to retrieve RepaintBoundary.');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            '${directory.path}/annotated_image_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(filePath);
        await file.writeAsBytes(byteData.buffer.asUint8List());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image saved to $filePath')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: $e')),
        );
      }
    }
  }

  /// Revert the last annotation
  void revertLastAnnotation() {
    setState(() {
      if (_annotations.isNotEmpty) {
        _annotations.removeLast();
      }
    });
  }

  /// Gesture handlers
  void onPanStart(DragStartDetails details) {
    setState(() {
      switch (selectedShapeNotifier.value) {
        case 'Freehand':
          _points.add(details.localPosition);
          break;
        case 'Rectangle':
          _currentRect =
              Rect.fromPoints(details.localPosition, details.localPosition);
          break;
        case 'Circle':
          _circleCenter = details.localPosition;
          _circleRadiusPoint = details.localPosition;
          break;
        case 'Line':
        case 'Horizontal Line':
        case 'Vertical Line':
          _lineStart = details.localPosition;
          _lineEnd = details.localPosition;
          break;
        case 'Text':
          _textPosition = details.localPosition;
          _text = 'Sample Text';
          break;
      }
    });
  }

  void onPanUpdate(DragUpdateDetails details) {
    setState(() {
      switch (selectedShapeNotifier.value) {
        case 'Freehand':
          _points.add(details.localPosition);
          break;
        case 'Rectangle':
          _currentRect =
              Rect.fromPoints(_currentRect!.topLeft, details.localPosition);
          break;
        case 'Circle':
          _circleRadiusPoint = details.localPosition;
          break;
        case 'Line':
        case 'Horizontal Line':
        case 'Vertical Line':
          _lineEnd = details.localPosition;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotationScaffold(
      selectedShapeNotifier: selectedShapeNotifier,
      onRevert: revertLastAnnotation,
      body: RepaintBoundary(
        key: repaintBoundaryKey,
        child: Stack(
          children: [
            // Background image
            Image.file(
              File(widget.imagePath),
              fit: BoxFit.contain,
              width: double.infinity,
            ),
            // Gesture detector for drawing
            Positioned.fill(
              child: GestureDetector(
                onPanStart: onPanStart,
                onPanUpdate: onPanUpdate,
                onPanEnd: (_) => saveAnnotations(),
                child: CustomPaint(
                  painter: ShapePainter(
                    points: _points,
                    annotations: _annotations,
                    rect: _currentRect,
                    circleCenter: _circleCenter,
                    circleRadiusPoint: _circleRadiusPoint,
                    lineStart: _lineStart,
                    lineEnd: _lineEnd,
                    textPosition: _textPosition,
                    text: _text,
                  ),
                ),
              ),
            ),
            // Save button
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: saveImage,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final List<Offset?> points;
  final List<Map<String, Object>> annotations;
  final Rect? rect;
  final Offset? circleCenter,
      circleRadiusPoint,
      lineStart,
      lineEnd,
      textPosition;
  final String? text;

  ShapePainter({
    required this.points,
    required this.annotations,
    required this.rect,
    required this.circleCenter,
    required this.circleRadiusPoint,
    required this.lineStart,
    required this.lineEnd,
    required this.textPosition,
    required this.text,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Render saved annotations
    for (var annotation in annotations) {
      switch (annotation['type']) {
        case 'Freehand':
          final points = annotation['points'] as List<Offset?>;
          for (int i = 0; i < points.length - 1; i++) {
            if (points[i] != null && points[i + 1] != null) {
              canvas.drawLine(points[i]!, points[i + 1]!, paint);
            }
          }
          break;
        case 'Rectangle':
          canvas.drawRect(annotation['rect'] as Rect, paint);
          break;
        case 'Circle':
          final center = annotation['center'] as Offset;
          final radiusPoint = annotation['radiusPoint'] as Offset;
          canvas.drawCircle(center, (center - radiusPoint).distance, paint);
          break;
        case 'Line':
          canvas.drawLine(annotation['start'] as Offset,
              annotation['end'] as Offset, paint);
          break;
        case 'Horizontal Line':
          final start = annotation['start'] as Offset;
          canvas.drawLine(
              Offset(0, start.dy), Offset(size.width, start.dy), paint);
          break;
        case 'Vertical Line':
          final start = annotation['start'] as Offset;
          canvas.drawLine(
              Offset(start.dx, 0), Offset(start.dx, size.height), paint);
          break;
        case 'Text':
          final position = annotation['position'] as Offset;
          final text = annotation['text'] as String;
          textPainter.text = TextSpan(
            text: text,
            style: TextStyle(color: Colors.red, fontSize: 16),
          );
          textPainter.layout();
          textPainter.paint(canvas, position);
          break;
      }
    }

    // Draw current shapes
    if (rect != null) canvas.drawRect(rect!, paint);
    if (circleCenter != null && circleRadiusPoint != null) {
      canvas.drawCircle(
          circleCenter!, (circleCenter! - circleRadiusPoint!).distance, paint);
    }
    if (lineStart != null && lineEnd != null) {
      canvas.drawLine(lineStart!, lineEnd!, paint);
    }
    if (textPosition != null && text != null) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(color: Colors.red, fontSize: 16),
      );
      textPainter.layout();
      textPainter.paint(canvas, textPosition!);
    }
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
