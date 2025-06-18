import 'package:flutter/material.dart';

class AppColors {
  static const cyan = Color(0xFF00CCFF);
  static const green = Color(0xFF067D31);
  static const orange = Color(0xFFFF6A00);
  static const darkGray = Color(0xFF595959);
  static const gray = Color(0xFF999999);
  static const lightGray = Color(0xFFE0E0E0);
  static const white = Colors.white;
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
    return ThemeData.dark().copyWith(
      primaryColor: AppColors.cyan,
      colorScheme: const ColorScheme.dark().copyWith(primary: AppColors.cyan),
      snackBarTheme: const SnackBarThemeData(backgroundColor: AppColors.cyan),
    );
  }
}
