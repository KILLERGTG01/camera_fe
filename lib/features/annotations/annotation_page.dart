import 'package:flutter/material.dart';
import 'dart:io';

class AnnotationPage extends StatefulWidget {
  final String imagePath;

  const AnnotationPage({super.key, required this.imagePath});

  @override
  State<AnnotationPage> createState() => _AnnotationPageState();
}

class _AnnotationPageState extends State<AnnotationPage> {
  List<Offset?> points = []; // Points for freehand drawing

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annotate Image'),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            points.add(details.localPosition);
          });
        },
        onPanEnd: (_) {
          points.add(null); // Break for new strokes
        },
        child: Stack(
          children: [
            Image.file(
              File(widget.imagePath),
              fit: BoxFit.contain,
              width: double.infinity,
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: AnnotationPainter(points),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnnotationPainter extends CustomPainter {
  final List<Offset?> points;

  AnnotationPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

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
