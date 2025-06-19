import 'package:flutter/material.dart';

class AppColors {
  static const cyan = Color(0xFF00CCFF);
  static const green = Color(0xFF067D31);
  static const orange = Color(0xFFFF6A00);
  static const darkGray = Color(0xFF595959);
  static const gray = Color(0xFF999999);
  static const lightGray = Color(0xFFE0E0E0);
  static const white = Colors.white;
  static const darkBg = Color(0xFF1F1F24);
  static const darkSurface = Color(0xFF2B2B31);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      primaryColor: AppColors.cyan,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.cyan).copyWith(
        primary: AppColors.cyan,
        secondary: AppColors.green,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.cyan,
      brightness: Brightness.dark,
    ).copyWith(
      background: AppColors.darkBg,
      surface: AppColors.darkSurface,
      primary: AppColors.cyan,
      secondary: AppColors.green,
    );

    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      primaryColor: AppColors.cyan,
      scaffoldBackgroundColor: AppColors.darkBg,
      canvasColor: AppColors.darkSurface,
      cardColor: AppColors.darkSurface,
      dialogBackgroundColor: AppColors.darkSurface,
      colorScheme: scheme,
      snackBarTheme:
          const SnackBarThemeData(backgroundColor: AppColors.darkGray),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        titleMedium: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
      ),
    );
  }
}
