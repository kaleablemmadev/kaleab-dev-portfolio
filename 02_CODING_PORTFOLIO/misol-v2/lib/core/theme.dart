import 'package:flutter/material.dart';

class AppTheme {
  // Dark premium color palette
  static const Color backgroundDark = Color(0xFF0D0D0D);
  static const Color backgroundLight = Color(0xFF121212);
  static const Color surfaceGlass = Color(0xB31E1E1E); // 0.7 opacity
  static const Color borderDark = Color(0xFF2D2D2D);

  static const Color primaryViolet = Color(0xFF6C3CE1);
  static const Color primaryIndigo = Color(0xFFA78BFA);
  static const Color secondaryMint = Color(0xFF34D399);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textHint = Color(0xFF71717A);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryViolet,
      colorScheme: const ColorScheme.dark(
        primary: primaryViolet,
        secondary: secondaryMint,
        surface: Color(0xFF1E1E1E),
        error: Color(0xFFEF4444),
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: textPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 32),
        displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 24),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: Color(0xFFD4D4D8), fontSize: 14, fontWeight: FontWeight.w400),
        labelSmall: TextStyle(color: textHint, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Handled by ink container
          foregroundColor: textPrimary,
          elevation: 4,
          shadowColor: primaryViolet.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: surfaceGlass,
        foregroundColor: primaryViolet,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryViolet, width: 2),
        ),
        hintStyle: const TextStyle(color: textHint),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
    );
  }
}
