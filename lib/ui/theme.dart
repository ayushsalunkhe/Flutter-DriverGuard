import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00E5FF), // Neon Cyan
      secondary: Color(0xFFFF2A68), // Neon Red
      tertiary: Color(0xFFFFC107), // Neon Amber
      surface: Color(0xFF1E1E2C), // Deep Navy
      background: Colors.black,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.5),
      headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF00E5FF), // Cyan
          letterSpacing: 1.2),
      bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white54, fontSize: 14),
    ),
  );
}
