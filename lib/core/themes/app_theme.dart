import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.teal,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
