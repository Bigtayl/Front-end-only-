import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// Centralized theme configuration for the application
class AppTheme {
  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      scaffoldBackgroundColor: AppColors.whiteSmoke,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepFern.withValues(alpha: 0.95),
        elevation: 0,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.deepFern,
        secondary: AppColors.tropicalLime,
        surface: AppColors.whiteSmoke,
        onSurface: AppColors.midnightBlue,
      ),
      cardTheme: CardTheme(
        color: AppColors.whiteSmoke,
        elevation: AppConstants.defaultElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: AppColors.midnightBlue,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepFern.withValues(alpha: 0.95),
        elevation: 0,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.deepFern,
        brightness: Brightness.dark,
        secondary: AppColors.tropicalLime,
        surface: AppColors.midnightBlue.withValues(alpha: 0.8),
        onSurface: AppColors.whiteSmoke,
      ),
      cardTheme: CardTheme(
        color: AppColors.midnightBlue.withValues(alpha: 0.8),
        elevation: AppConstants.defaultElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.midnightBlue.withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
    );
  }
}
