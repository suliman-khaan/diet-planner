import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// AppTheme builds light and dark ThemeData instances honoring design/spec.md.
abstract class AppTheme {
  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      primaryContainer: AppColors.lightPrimarySoft,
      onPrimaryContainer: AppColors.lightPrimary,
      secondary: AppColors.lightPrimary,
      onSecondary: AppColors.lightOnPrimary,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightInk,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorderStrong,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: AppTypography.fontLatin,
      cardTheme: const CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,
          side: BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.titleMedium,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.lightPrimary,
        unselectedItemColor: AppColors.lightMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: AppTypography.bodyStrong,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          backgroundColor: AppColors.lightSurface,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.lightPrimary, width: 1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadii.control)),
          ),
          textStyle: AppTypography.bodyStrong,
        ),
      ),
    );
  }

  static ThemeData get dark {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      primaryContainer: AppColors.darkPrimarySoft,
      onPrimaryContainer: AppColors.darkPrimary,
      secondary: AppColors.darkPrimary,
      onSecondary: AppColors.darkOnPrimary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkInk,
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorderStrong,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: AppTypography.fontLatin,
      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,
          side: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.titleMedium,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: AppTypography.bodyStrong,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          backgroundColor: AppColors.darkSurface,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.darkPrimary, width: 1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadii.control)),
          ),
          textStyle: AppTypography.bodyStrong,
        ),
      ),
    );
  }
}
