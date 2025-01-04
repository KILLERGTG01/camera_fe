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
  final List<Offset?> _points = [];
  final List<Map<String, Object>> _annotations = []; // Explicit typing
  Rect? _currentRect;
  Offset? _circleCenter;
  Offset? _circleRadiusPoint;
  Offset? _lineStart;
  Offset? _lineEnd;

  void saveAnnotations() {
    setState(() {
      if (selectedShapeNotifier.value == 'Freehand' && _points.isNotEmpty) {
        _annotations.add({'type': 'Freehand', 'points': List.from(_points)});
        _points.clear();
      } else if (selectedShapeNotifier.value == 'Rectangle' &&
          _currentRect != null) {
        _annotations.add({'type': 'Rectangle', 'rect': _currentRect!});
        _currentRect = null;
      } else if (selectedShapeNotifier.value == 'Circle' &&
          _circleCenter != null &&
          _circleRadiusPoint != null) {
        _annotations.add({
          'type': 'Circle',
          'center': _circleCenter!,
          'radiusPoint': _circleRadiusPoint!
        });
        _circleCenter = null;
        _circleRadiusPoint = null;
      } else if (selectedShapeNotifier.value == 'Line' &&
          _lineStart != null &&
          _lineEnd != null) {
        _annotations.add({
          'type': 'Line',
          'start': _lineStart!,
          'end': _lineEnd!,
        });
        _lineStart = null;
        _lineEnd = null;
      }
    });
  }

  Future<void> _saveImage() async {
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

  void revertLastAnnotation() {
    setState(() {
      if (_annotations.isNotEmpty) {
        _annotations.removeLast();
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
            Image.file(
              File(widget.imagePath),
              fit: BoxFit.contain,
              width: double.infinity,
            ),
            Positioned.fill(
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    switch (selectedShapeNotifier.value) {
                      case 'Freehand':
                        _points.add(details.localPosition);
                        break;
                      case 'Rectangle':
                        _currentRect = Rect.fromPoints(
                          details.localPosition,
                          details.localPosition,
                        );
                        break;
                      case 'Circle':
                        _circleCenter = details.localPosition;
                        _circleRadiusPoint = details.localPosition;
                        break;
                      case 'Line':
                        _lineStart = details.localPosition;
                        _lineEnd = details.localPosition;
                        break;
                    }
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    switch (selectedShapeNotifier.value) {
                      case 'Freehand':
                        _points.add(details.localPosition);
                        break;
                      case 'Rectangle':
                        _currentRect = Rect.fromPoints(
                          _currentRect!.topLeft,
                          details.localPosition,
                        );
                        break;
                      case 'Circle':
                        _circleRadiusPoint = details.localPosition;
                        break;
                      case 'Line':
                        _lineEnd = details.localPosition;
                        break;
                    }
                  });
                },
                onPanEnd: (_) {
                  saveAnnotations();
                },
                child: CustomPaint(
                  painter: ShapePainter(
                    points: _points,
                    annotations: _annotations,
                    rect: _currentRect,
                    circleCenter: _circleCenter,
                    circleRadiusPoint: _circleRadiusPoint,
                    lineStart: _lineStart,
                    lineEnd: _lineEnd,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: _saveImage,
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
  final Offset? circleCenter;
  final Offset? circleRadiusPoint;
  final Offset? lineStart;
  final Offset? lineEnd;

  ShapePainter({
    required this.points,
    required this.annotations,
    required this.rect,
    required this.circleCenter,
    required this.circleRadiusPoint,
    required this.lineStart,
    required this.lineEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    // Draw saved annotations
    for (var annotation in annotations) {
      if (annotation['type'] == 'Freehand') {
        final points = (annotation['points'] as List<Offset?>);
        for (int i = 0; i < points.length - 1; i++) {
          if (points[i] != null && points[i + 1] != null) {
            canvas.drawLine(points[i]!, points[i + 1]!, paint);
          }
        }
      } else if (annotation['type'] == 'Rectangle') {
        final rect = annotation['rect'] as Rect;
        canvas.drawRect(rect, paint);
      } else if (annotation['type'] == 'Circle') {
        final center = annotation['center'] as Offset;
        final radiusPoint = annotation['radiusPoint'] as Offset;
        final radius = (center - radiusPoint).distance;
        canvas.drawCircle(center, radius, paint);
      } else if (annotation['type'] == 'Line') {
        final start = annotation['start'] as Offset;
        final end = annotation['end'] as Offset;
        canvas.drawLine(start, end, paint);
      }
    }

    // Draw current shapes
    if (rect != null) canvas.drawRect(rect!, paint);
    if (circleCenter != null && circleRadiusPoint != null) {
      final radius = (circleCenter! - circleRadiusPoint!).distance;
      canvas.drawCircle(circleCenter!, radius, paint);
    }
    if (lineStart != null && lineEnd != null) {
      canvas.drawLine(lineStart!, lineEnd!, paint);
    }
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
