import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Claude night-mode inspired design system.
///
/// Warm dark tones with the signature terracotta accent.
class AppTheme {
  AppTheme._();

  // ── Core Palette ──────────────────────────────────────────────────────
  static const Color background = Color(0xFF2B2A27);
  static const Color surface = Color(0xFF3B3A37);
  static const Color surfaceElevated = Color(0xFF4A4945);
  static const Color surfaceHover = Color(0xFF525150);

  static const Color accent = Color(0xFFD97757);
  static const Color accentHover = Color(0xFFE5896A);
  static const Color accentPressed = Color(0xFFC2694D);

  static const Color textPrimary = Color(0xFFECECEC);
  static const Color textSecondary = Color(0xFFA3A29E);
  static const Color textTertiary = Color(0xFF7A7974);

  static const Color border = Color(0xFF4A4945);
  static const Color borderFocused = Color(0xFFD97757);

  static const Color error = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFF3D2020);

  static const Color success = Color(0xFF22C55E);

  // ── Gradients ─────────────────────────────────────────────────────────
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD97757), Color(0xFFE89B7D)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF323130), Color(0xFF2B2A27)],
  );

  // ── Radii ─────────────────────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // ── Spacing ───────────────────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacing2xl = 48.0;

  // ── Shadows ───────────────────────────────────────────────────────────
  static List<BoxShadow> get elevationLow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevationMedium => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get accentGlow => [
        BoxShadow(
          color: accent.withValues(alpha: 0.3),
          blurRadius: 20,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
      ];

  // ── Typography ────────────────────────────────────────────────────────
  static TextStyle get headingLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get headingMedium => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.3,
        height: 1.3,
      );

  static TextStyle get headingSmall => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textTertiary,
        height: 1.4,
      );

  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.2,
      );

  static TextStyle get labelText => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.3,
      );

  // ── ThemeData ─────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          surface: surface,
          primary: accent,
          secondary: accentHover,
          error: error,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: headingSmall,
          iconTheme: const IconThemeData(color: textPrimary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: error),
          ),
          hintStyle: bodyMedium,
          labelStyle: labelText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingMd,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: spacingLg,
              vertical: spacingMd,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            textStyle: buttonText,
            elevation: 0,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: surfaceElevated,
          contentTextStyle: bodyMedium.copyWith(color: textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
