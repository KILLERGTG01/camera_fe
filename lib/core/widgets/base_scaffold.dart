import 'package:flutter/material.dart';
import 'top_app_bar.dart';
import 'bottom_nav_bar.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;

  const BaseScaffold({required this.body, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(),
      bottomNavigationBar: const BottomNavBar(),
      body: body,
    );
  }
}
