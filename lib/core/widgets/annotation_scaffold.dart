import 'package:dewinter_gallery/core/widgets/annotation_top_bar.dart';
import 'package:dewinter_gallery/core/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class AnnotationScaffold extends StatelessWidget {
  final Widget body;
  final ValueNotifier<String?> selectedShapeNotifier;
  final VoidCallback onRevert;
  final ValueNotifier<Color> selectedColorNotifier; // For annotation color
  final ValueNotifier<double>
      selectedThicknessNotifier; // For annotation thickness

  const AnnotationScaffold({
    required this.body,
    required this.selectedShapeNotifier,
    required this.onRevert,
    required this.selectedColorNotifier,
    required this.selectedThicknessNotifier,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AnnotationTopBar(
        selectedShapeNotifier: selectedShapeNotifier,
        onRevert: onRevert,
        selectedColorNotifier: selectedColorNotifier,
        selectedThicknessNotifier: selectedThicknessNotifier,
      ),
      bottomNavigationBar: const BottomNavBar(),
      body: body,
    );
  }
}
