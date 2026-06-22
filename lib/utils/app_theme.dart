import 'package:flutter/material.dart';

/// EZ TRAINZ brand palette — light "sky blue → golden yellow" theme.
///
/// Page backgrounds use [pageGradient] (sky blue at the top fading to golden
/// yellow at the bottom). Cards sit on top in white / warm cream with dark
/// navy text. Sky-blue and gold are the accent colors.
abstract class AppColors {
  // ── Brand gradient (page backgrounds) ────────────────────────
  static const skyTop     = Color(0xFF7DD3FC); // sky blue — top of gradient
  static const skyMid     = Color(0xFFCDEBFB); // soft transition
  static const goldBottom = Color(0xFFFFE34D); // golden yellow — bottom

  /// Sky-blue → golden-yellow page background. Use via [SkyGoldBackground].
  static const pageGradient = LinearGradient(
    colors: [skyTop, skyMid, goldBottom],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Surfaces ─────────────────────────────────────────────────
  static const bg      = Color(0xFFE8F4FD); // flat light fallback background
  static const card    = Colors.white;      // primary card surface
  static const cardAlt = Color(0xFFFFFBEA);  // warm cream card variant
  static const border  = Color(0xFFD6E4F0);  // light borders / dividers

  // ── Text (dark on light) ─────────────────────────────────────
  static const textPrimary = Color(0xFF0F2233); // dark navy text
  static const textMuted   = Color(0xFF52617A); // secondary / hint text
  static const textDim     = Color(0xFF8294A8); // very dimmed labels

  // ── Accents ──────────────────────────────────────────────────
  static const accentBlue   = Color(0xFF0EA5E9); // sky-blue accent / links
  static const accentBlueDk = Color(0xFF0284C7); // deeper blue for contrast
  static const accentYellow = Color(0xFFFFD000); // golden CTA / selected
  static const accentGreen  = Color(0xFF10B981);
  static const accentPink   = Color(0xFFEC4899);
  static const accentPurple = Color(0xFF6366F1);

  /// Vibrant pink → purple → blue sweep for lesson titles.
  /// Apply to text via a [ShaderMask] (the Text color must be white).
  static const vibrantTitleGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFF8B5CF6), Color(0xFF3B82F6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ── Semantic ─────────────────────────────────────────────────
  static const correct = Color(0xFF14B86A);
  static const wrong   = Color(0xFFE53935);

  // ── Cohesive light-UI tokens ─────────────────────────────────
  // Used by the gradient game screens so display text stays readable
  // against the sky-blue → golden-yellow background.
  static const display     = Color(0xFF0F172A); // deep midnight navy — large display text
  static const instruction = Color(0xFF334155); // slate charcoal — instructional / prompt text
  static const tabActive   = Color(0xFF2563EB); // royal blue — active nav tab
  static const audio       = Color(0xFFEA580C); // deep amber/coral — speaker & mic buttons
  static const timerTrack  = Color(0xFF1E293B); // dark blue-gray — countdown track

  // ── Legacy aliases ───────────────────────────────────────────
  // Old code referenced navy* tokens; keep them pointing at the new light
  // surfaces so everything compiles while screens are migrated.
  static const navyBg      = bg;
  static const navyCard    = card;
  static const navyCardAlt = cardAlt;
  static const navyBorder  = border;
}

/// Paints the sky-blue → golden-yellow brand gradient behind [child].
///
/// Use as a [Scaffold] body so the gradient fills the viewport and stays
/// fixed while content scrolls over it:
/// ```dart
/// Scaffold(body: SkyGoldBackground(child: SafeArea(child: ...)));
/// ```
class SkyGoldBackground extends StatelessWidget {
  const SkyGoldBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.pageGradient),
      child: SizedBox.expand(child: child),
    );
  }
}

/// Global light "sky / gold" [ThemeData] used in main.dart.
ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.light,
    // Transparent so the global sky→gold gradient (painted once in main.dart's
    // builder) shows through every screen that doesn't set its own background.
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.light(
      surface: AppColors.card,
      primary: AppColors.accentBlue,
      secondary: AppColors.accentYellow,
      onSurface: AppColors.textPrimary,
    ),
    cardColor: AppColors.card,
    dividerColor: AppColors.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.accentBlueDk,
      unselectedItemColor: AppColors.textMuted,
    ),
    iconTheme: const IconThemeData(color: AppColors.textMuted),
    textTheme: const TextTheme(
      bodyLarge:  TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      bodySmall:  TextStyle(color: AppColors.textMuted),
      titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
      titleMedium:TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
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
