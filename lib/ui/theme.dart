import 'package:flutter/material.dart';

class AppTheme {
  // 2026 Liquid Palette
  static const Color cyan = Color(0xFF00E5FF);
  static const Color deepNavy = Color(0xFF050510);
  static const Color glassWhite = Colors.white;
  static const Color severeRed = Color(0xFFFF2A68);
  static const Color warningAmber = Color(0xFFFFC107);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: deepNavy,
    primaryColor: cyan,
    colorScheme: const ColorScheme.dark(
      primary: cyan,
      secondary: severeRed,
      surface: Color(0xFF0A0A1F),
      background: deepNavy,
      error: severeRed,
    ),

    // Typography
    textTheme: TextTheme(
      displayLarge: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: glassWhite),
      headlineMedium: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: glassWhite),
      bodyLarge: TextStyle(
          fontFamily: 'monospace',
          fontSize: 16,
          color: glassWhite.withOpacity(0.9)),
      bodyMedium: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: glassWhite.withOpacity(0.7)),
    ),

    // Other Themes
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
          fontFamily: 'monospace', fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );
}
