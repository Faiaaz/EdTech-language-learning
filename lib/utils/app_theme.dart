import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────
  static const navyBg     = Color(0xFF0F172A); // scaffold / page bg
  static const navyCard   = Color(0xFF1E293B); // card surface
  static const navyCardAlt= Color(0xFF162032); // slightly darker card variant
  static const navyBorder = Color(0xFF334155); // card / divider borders

  // ── Text ─────────────────────────────────────────────────────
  static const textPrimary = Colors.white;
  static const textMuted   = Color(0xFF94A3B8); // secondary / hint text
  static const textDim     = Color(0xFF64748B); // very dimmed labels

  // ── Accents ───────────────────────────────────────────────────
  static const accentBlue   = Color(0xFF3B82F6); // links, highlights
  static const accentYellow = Color(0xFFFFE000); // primary CTA / selected
  static const accentGreen  = Color(0xFF10B981);
  static const accentPink   = Color(0xFFEC4899);
  static const accentPurple = Color(0xFF6366F1);

  // ── Semantic ─────────────────────────────────────────────────
  static const correct = Color(0xFF14B86A);
  static const wrong   = Color(0xFFE53935);
}

/// Global dark-navy ThemeData used in main.dart.
ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.navyBg,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.navyBg,
      primary: AppColors.accentBlue,
      secondary: AppColors.accentYellow,
      onSurface: Colors.white,
    ),
    cardColor: AppColors.navyCard,
    dividerColor: AppColors.navyBorder,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navyBg,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(color: AppColors.textMuted),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.navyCard,
      selectedItemColor: AppColors.accentYellow,
      unselectedItemColor: AppColors.textMuted,
    ),
    iconTheme: const IconThemeData(color: AppColors.textMuted),
    textTheme: const TextTheme(
      bodyLarge:  TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall:  TextStyle(color: AppColors.textMuted),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      titleMedium:TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.navyCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.navyBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.navyBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
      ),
      hintStyle: const TextStyle(color: AppColors.textDim),
      labelStyle: const TextStyle(color: AppColors.textMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
