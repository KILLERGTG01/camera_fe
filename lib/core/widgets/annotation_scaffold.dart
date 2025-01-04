import 'package:dewinter_gallery/core/widgets/annotation_top_bar.dart';
import 'package:dewinter_gallery/core/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class AnnotationScaffold extends StatelessWidget {
  final Widget body;
  final ValueNotifier<String?> selectedShapeNotifier;
  final VoidCallback onRevert;

  const AnnotationScaffold({
    required this.body,
    required this.selectedShapeNotifier,
    required this.onRevert,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AnnotationTopBar(
        selectedShapeNotifier: selectedShapeNotifier,
        onRevert: onRevert,
      ),
      bottomNavigationBar: const BottomNavBar(),
      body: body,
    );
  }
}
