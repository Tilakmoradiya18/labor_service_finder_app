import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = _buildLightTheme();

  static ThemeData _buildLightTheme() {
    const Color primary = Color(0xFF5E81F4);
    const Color surface = Color(0xFFFFFFFF);
    const Color background = Color(0xFFF7F9FC);

    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      useMaterial3: true,
      scaffoldBackgroundColor: background,
    );

    final roundedShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1,
        shape: roundedShape,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: roundedShape,
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: roundedShape,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: Colors.grey.shade300),
          foregroundColor: primary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: roundedShape,
        tileColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      dividerColor: Colors.grey.shade200,
      splashFactory: InkRipple.splashFactory,
    );
  }
}


