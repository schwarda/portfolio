import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  const AppColors._();

  static const bgStart = Color(0xFF08111A);
  static const bgMiddle = Color(0xFF0E1D2A);
  static const bgEnd = Color(0xFF101926);

  static const surface = Color(0xAA0C1722);
  static const surfaceStrong = Color(0xCC122232);
  static const stroke = Color(0xFF284156);

  static const textPrimary = Color(0xFFF2F6FA);
  static const textSecondary = Color(0xFFB7C8D6);

  static const accentBlue = Color(0xFF5BA6FF);
  static const accentTeal = Color(0xFF40DFC9);
  static const accentCoral = Color(0xFFFF886B);
}

class AppTheme {
  const AppTheme._();

  static ThemeData build() {
    final textTheme = GoogleFonts.spaceGroteskTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accentBlue,
        brightness: Brightness.dark,
      ),
      textTheme: textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: Colors.transparent,
    );
  }
}
