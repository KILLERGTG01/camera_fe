import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:dewinter_gallery/core/widgets/annotation_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

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
  final ValueNotifier<Color> selectedColorNotifier =
      ValueNotifier<Color>(Colors.red); // Default color
  final ValueNotifier<double> selectedThicknessNotifier =
      ValueNotifier<double>(4.0); // Default thickness

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
              'color': selectedColorNotifier.value,
              'thickness': selectedThicknessNotifier.value,
            });
            _points.clear();
          }
          break;
        case 'Rectangle':
          if (_currentRect != null) {
            _annotations.add({
              'type': 'Rectangle',
              'rect': _currentRect!,
              'color': selectedColorNotifier.value,
              'thickness': selectedThicknessNotifier.value,
            });
            _currentRect = null;
          }
          break;
        case 'Circle':
          if (_circleCenter != null && _circleRadiusPoint != null) {
            _annotations.add({
              'type': 'Circle',
              'center': _circleCenter!,
              'radiusPoint': _circleRadiusPoint!,
              'color': selectedColorNotifier.value,
              'thickness': selectedThicknessNotifier.value,
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
              'color': selectedColorNotifier.value,
              'thickness': selectedThicknessNotifier.value,
            });
            _lineStart = null;
            _lineEnd = null;
          }
          break;
        case 'Text':
          if (_textPosition != null && _text != null) {
            _annotations.add({
              'type': 'Text',
              'position': _textPosition!,
              'text': _text!,
              'color': selectedColorNotifier.value,
            });
            _textPosition = null;
            _text = null;
          }
          break;
      }
    });
  }

  Future<void> saveImage() async {
    try {
      debugPrint('Attempting to retrieve RepaintBoundary...');
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception(
            'Failed to retrieve RepaintBoundary. Ensure it is part of the widget tree.');
      }

      debugPrint('Converting RepaintBoundary to image...');
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert image to ByteData.');
      }

      final Uint8List imageBytes = byteData.buffer.asUint8List();

      debugPrint('Saving image to PathPlus directory...');
      final directory = await getApplicationDocumentsDirectory();
      final pathPlusFolder = Directory('${directory.path}/Annotated');
      if (!await pathPlusFolder.exists()) {
        debugPrint('Creating PathPlus directory...');
        await pathPlusFolder.create();
      }

      final filePath =
          '${pathPlusFolder.path}/annotated_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);
      debugPrint('Image saved to PathPlus directory: $filePath');

      debugPrint('Saving image to device gallery...');
      final galleryResult = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: 'annotated_image_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (galleryResult['isSuccess'] == true) {
        debugPrint('Image successfully saved to gallery.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Image saved to PathPlus and gallery: $filePath')),
          );
        }
      } else {
        debugPrint('Failed to save image to gallery.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save image to gallery')),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error occurred while saving image: $e');
      debugPrint(stackTrace.toString());
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
      selectedColorNotifier: selectedColorNotifier,
      selectedThicknessNotifier: selectedThicknessNotifier,
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
                    selectedShape: selectedShapeNotifier.value,
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
  final String? selectedShape; // Add selected shape parameter

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
    required this.selectedShape, // Include it in the constructor
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Render saved annotations
    for (var annotation in annotations) {
      final paint = Paint()
        ..color = annotation['color'] as Color? ?? Colors.red
        ..strokeWidth = annotation['thickness'] as double? ?? 4.0
        ..style = PaintingStyle.stroke;

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
            style: TextStyle(color: annotation['color'] as Color, fontSize: 16),
          );
          textPainter.layout();
          textPainter.paint(canvas, position);
          break;
      }
    }

    // Draw current shapes
    if (rect != null) {
      final paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke;
      canvas.drawRect(rect!, paint);
    }
    if (circleCenter != null && circleRadiusPoint != null) {
      final paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(
          circleCenter!, (circleCenter! - circleRadiusPoint!).distance, paint);
    }
    if (lineStart != null && lineEnd != null) {
      final paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke;
      if (selectedShape == 'Horizontal Line') {
        canvas.drawLine(
          Offset(0, lineStart!.dy),
          Offset(size.width, lineStart!.dy),
          paint,
        );
      } else if (selectedShape == 'Vertical Line') {
        canvas.drawLine(
          Offset(lineStart!.dx, 0),
          Offset(lineStart!.dx, size.height),
          paint,
        );
      } else {
        canvas.drawLine(lineStart!, lineEnd!, paint);
      }
    }
    if (textPosition != null && text != null) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(color: Colors.red, fontSize: 16),
      );
      textPainter.layout();
      textPainter.paint(canvas, textPosition!);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
