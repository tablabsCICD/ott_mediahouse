import 'package:flutter/material.dart';

class AppTheme {
  static const Color _brandRed = Color(0xFFE50914);

  static ThemeData _baseTheme({
    required Brightness brightness,
    required Color scaffoldColor,
    required Color canvasColor,
    required Color cardColor,
    required Color borderColor,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _brandRed,
      brightness: brightness,
      primary: _brandRed,
      surface: cardColor,
      onSurface: canvasColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: _brandRed,
      scaffoldBackgroundColor: scaffoldColor,
      canvasColor: canvasColor,
      cardColor: cardColor,
      colorScheme: colorScheme,
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: canvasColor,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: canvasColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: canvasColor,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1.5,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        hintStyle: TextStyle(fontSize: 14, color: canvasColor.withValues(alpha: 0.65)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _brandRed, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _brandRed,
          side: const BorderSide(color: _brandRed),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _brandRed,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        selectedColor: _brandRed,
        disabledColor: borderColor,
        side: BorderSide(color: borderColor),
        labelStyle: TextStyle(color: canvasColor, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      dividerColor: borderColor,
    );
  }

  static final ThemeData lightTheme = _baseTheme(
    brightness: Brightness.light,
    scaffoldColor: const Color(0xFFF8F9FB),
    canvasColor: const Color(0xFF111111),
    cardColor: const Color(0xFFFFFFFF),
    borderColor: const Color(0xFFE4E6EB),
  );

  static final ThemeData darkTheme = _baseTheme(
    brightness: Brightness.dark,
    scaffoldColor: const Color(0xFF0C0D10),
    canvasColor: const Color(0xFFF4F4F4),
    cardColor: const Color(0xFF171A1F),
    borderColor: const Color(0xFF2B2F36),
  );
}
