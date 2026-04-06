import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Border-radius constants matching the POC design tokens.
class AppRadius {
  AppRadius._();

  /// Cards, sheets — 14px
  static const double card = 14.0;
  static final BorderRadius cardBR = BorderRadius.circular(card);

  /// Buttons, small cards — 10px
  static const double sm = 10.0;
  static final BorderRadius smBR = BorderRadius.circular(sm);

  /// Pill tabs, search bar, CTAs — 100px
  static const double pill = 100.0;
  static final BorderRadius pillBR = BorderRadius.circular(pill);
}

/// Shadow constants matching the POC design tokens.
class AppShadow {
  AppShadow._();

  static const BoxShadow sm = BoxShadow(
    offset: Offset(0, 1),
    blurRadius: 3,
    color: Color(0x0A000000), // rgba(0,0,0,0.04)
  );

  static const List<BoxShadow> card = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 8,
      color: Color(0x0A000000), // rgba(0,0,0,0.04)
    ),
    BoxShadow(
      offset: Offset.zero,
      blurRadius: 1,
      color: Color(0x0F000000), // rgba(0,0,0,0.06)
    ),
  ];

  static const BoxShadow lg = BoxShadow(
    offset: Offset(0, 8),
    blurRadius: 30,
    color: Color(0x14000000), // rgba(0,0,0,0.08)
  );
}

class AppTheme {
  AppTheme._();

  // ── Light Theme ────────────────────────────────────────────
  static ThemeData get lightTheme {
    const colors = AppColors.light;
    final base = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: colors.red,
      scaffoldBackgroundColor: colors.bg,
      colorScheme: ColorScheme.light(
        primary: colors.red,
        onPrimary: Colors.white,
        secondary: colors.redDark,
        surface: colors.card,
        onSurface: colors.ink,
        error: colors.redDot,
      ),
      textTheme: base.copyWith(
        headlineLarge: base.headlineLarge?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: colors.ink,
        ),
        headlineMedium: base.headlineMedium?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: colors.ink,
        ),
        headlineSmall: base.headlineSmall?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: colors.ink,
        ),
        titleLarge: base.titleLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: colors.ink,
        ),
        titleMedium: base.titleMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: colors.ink,
        ),
        titleSmall: base.titleSmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: colors.ink,
        ),
        bodyLarge: base.bodyLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colors.ink,
        ),
        bodyMedium: base.bodyMedium?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colors.ink80,
        ),
        bodySmall: base.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: colors.ink60,
        ),
        labelLarge: base.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        labelMedium: base.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.ink40,
        ),
        labelSmall: base.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.08 * 10, // 0.08em at 10px
          color: colors.ink20,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.card,
        foregroundColor: colors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: colors.ink,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.red,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.pillBR,
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.red,
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(color: colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.pillBR,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.pillBR,
          borderSide: BorderSide(color: colors.ink10, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.pillBR,
          borderSide: BorderSide(color: colors.ink10, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.pillBR,
          borderSide: BorderSide(color: colors.red, width: 1.5),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colors.ink20,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardBR,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.card,
        selectedItemColor: colors.red,
        unselectedItemColor: colors.ink40,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.ink05,
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppColors.light,
      ],
    );
  }

  // ── Dark Theme ─────────────────────────────────────────────
  static ThemeData get darkTheme {
    const colors = AppColors.dark;
    final base = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: colors.red,
      scaffoldBackgroundColor: colors.bg,
      colorScheme: ColorScheme.dark(
        primary: colors.red,
        onPrimary: Colors.white,
        secondary: colors.redDark,
        surface: colors.card,
        onSurface: colors.ink,
        error: colors.redDot,
      ),
      textTheme: base.copyWith(
        headlineLarge: base.headlineLarge?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: colors.ink,
        ),
        headlineMedium: base.headlineMedium?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: colors.ink,
        ),
        headlineSmall: base.headlineSmall?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: colors.ink,
        ),
        titleLarge: base.titleLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: colors.ink,
        ),
        titleMedium: base.titleMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: colors.ink,
        ),
        titleSmall: base.titleSmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: colors.ink,
        ),
        bodyLarge: base.bodyLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colors.ink,
        ),
        bodyMedium: base.bodyMedium?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colors.ink80,
        ),
        bodySmall: base.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: colors.ink60,
        ),
        labelLarge: base.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        labelMedium: base.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.ink40,
        ),
        labelSmall: base.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.08 * 10,
          color: colors.ink20,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.card,
        foregroundColor: colors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: colors.ink,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.red,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.pillBR,
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.red,
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(color: colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.pillBR,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.pillBR,
          borderSide: BorderSide(color: colors.ink10, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.pillBR,
          borderSide: BorderSide(color: colors.ink10, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.pillBR,
          borderSide: BorderSide(color: colors.red, width: 1.5),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colors.ink20,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardBR,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.card,
        selectedItemColor: colors.red,
        unselectedItemColor: colors.ink40,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.ink05,
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppColors.dark,
      ],
    );
  }
}
