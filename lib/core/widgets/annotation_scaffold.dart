import 'package:dewinter_gallery/core/widgets/bottom_nav_bar.dart';
import 'package:dewinter_gallery/core/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';

class AnnotationScaffold extends StatelessWidget {
  final Widget body;

  const AnnotationScaffold({required this.body, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(),
      bottomNavigationBar: const BottomNavBar(),
      body: body,
    );
  }
}
