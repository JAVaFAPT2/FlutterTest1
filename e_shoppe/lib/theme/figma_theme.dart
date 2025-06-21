// Color & typography constants generated from Figma v2
// Update imports and usage gradually across the app.

import 'package:flutter/material.dart';

class FigmaColors {
  // Dominant palette
  static const darkGray = Color(0xFF595959); // Dominant/DarkGray
  static const gray = Color(0xFF999999); // Dominant/Gray
  static const white = Color(0xFFFFFFFF); // Dominant/white

  // Accent (reuse existing cyan until new accent is provided)
  static const accent = Color(0xFF00CCFF);
}

class FigmaTextStyles {
  // Phone/Header2 – 20 bold
  static const header2 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.0, // 100% line-height in Figma
    color: FigmaColors.darkGray,
  );

  // Phone/Subhead – 14 semi-bold
  static const subhead = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: FigmaColors.darkGray,
  );

  // Phone/Body – 16 regular
  static const body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.0,
    color: FigmaColors.darkGray,
  );
}

/// Material [ThemeData] that wires the new Figma colors & type ramp.
ThemeData figmaLightTheme() {
  return ThemeData(
    useMaterial3: true,
    primaryColor: FigmaColors.accent,
    scaffoldBackgroundColor: FigmaColors.white,
    colorScheme: ColorScheme.fromSeed(seedColor: FigmaColors.accent).copyWith(
      primary: FigmaColors.accent,
      surface: FigmaColors.white,
      background: FigmaColors.white,
    ),
    textTheme: const TextTheme(
      titleLarge: FigmaTextStyles.header2,
      titleMedium: FigmaTextStyles.body,
      bodyMedium: FigmaTextStyles.body,
      bodySmall: FigmaTextStyles.subhead,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: FigmaColors.white,
      foregroundColor: FigmaColors.darkGray,
      elevation: 0,
      titleTextStyle: FigmaTextStyles.header2,
    ),
  );
}
