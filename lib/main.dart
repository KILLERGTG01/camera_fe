import 'package:dewinter/pages/start_page.dart';
import 'package:flutter/material.dart';
import 'widgets/top_app_bar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simplified App',
      theme: ThemeData.dark(),
      home: const Scaffold(
        appBar: TopAppBar(),
        bottomNavigationBar: BottomNavBar(),
        body: Center(child: StartPage()),
      ),
    );
  }
}
