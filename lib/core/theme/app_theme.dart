import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF0B1220);
  static const Color surface = Color(0xFF121A2B);
  static const Color surfaceAlt = Color(0xFF182235);
  static const Color border = Color(0xFF26324A);

  static const Color primary = Color(0xFF00D1FF);
  static const Color accent = Color(0xFFFFD76A);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB3C0D9);
  static const Color textMuted = Color(0xFF7F8CA5);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          surface: surface,
          primary: primary,
          secondary: accent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        cardColor: surface,
        dividerColor: border,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w900,
          ),
          headlineMedium: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w800,
          ),
          titleLarge: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w800,
          ),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
        ),
      );

}