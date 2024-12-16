import 'package:flutter/material.dart';
import 'widgets/top_app_bar.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  runApp(const MyApp());
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
        body: Center(
          child: Text(
            'Top Bar and Navigation Bar Only',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
