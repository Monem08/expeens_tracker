import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Carbon Mint — modern dark theme for expeens_tracker.
///
/// Palette:
///   Primary (Mint):   0xFF00FFC2
///   Background:       0xFF2D3436
///   Accent (Indigo):  0xFF5758BB
class AppColors {
  const AppColors._();

  static const Color mint = Color(0xFF00FFC2);
  static const Color carbon = Color(0xFF2D3436);
  static const Color indigo = Color(0xFF5758BB);

  static const Color surface = Color(0xFF202527);
  static const Color surfaceHigh = Color(0xFF2A3032);
  static const Color outline = Color(0xFF3A4044);

  static const Color onMint = Color(0xFF00261C);
  static const Color onCarbon = Color(0xFFE8ECEE);
  static const Color onIndigo = Color(0xFFFFFFFF);

  static const Color positive = Color(0xFF00FFC2);
  static const Color negative = Color(0xFFFF6B6B);
}

class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.mint,
      onPrimary: AppColors.onMint,
      primaryContainer: Color(0xFF003D30),
      onPrimaryContainer: AppColors.mint,
      secondary: AppColors.indigo,
      onSecondary: AppColors.onIndigo,
      secondaryContainer: Color(0xFF2A2C6E),
      onSecondaryContainer: Color(0xFFE0E1FF),
      tertiary: Color(0xFF7DFFE0),
      onTertiary: AppColors.onMint,
      error: AppColors.negative,
      onError: Color(0xFF2A0000),
      surface: AppColors.carbon,
      onSurface: AppColors.onCarbon,
      surfaceContainerLowest: Color(0xFF1A1D1E),
      surfaceContainerLow: Color(0xFF23282A),
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.surfaceHigh,
      surfaceContainerHighest: Color(0xFF32383A),
      onSurfaceVariant: Color(0xFFB8BEC1),
      outline: AppColors.outline,
      outlineVariant: Color(0xFF2F3538),
      inverseSurface: Color(0xFFE8ECEE),
      onInverseSurface: AppColors.carbon,
      inversePrimary: Color(0xFF006B55),
      shadow: Colors.black,
      scrim: Colors.black,
    );

    final textTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: AppColors.onCarbon, displayColor: AppColors.onCarbon);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.carbon,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.carbon,
        foregroundColor: AppColors.onCarbon,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.onCarbon,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outline, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: AppColors.onMint,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mint,
          side: const BorderSide(color: AppColors.mint, width: 1.2),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.mint),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.mint,
        foregroundColor: AppColors.onMint,
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: GoogleFonts.inter(color: const Color(0xFF8A9094)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.mint, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.onCarbon),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: GoogleFonts.inter(color: AppColors.onCarbon),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceHigh,
        labelStyle: GoogleFonts.inter(color: AppColors.onCarbon),
        side: const BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
