import 'package:flutter/material.dart';

export 'colors.dart';

class AppColors {
  static const marineBluePrimary = Color(0xFF0B3D91);
  static const redSecondary = Color(0xFFFF1E00);
  static const lightTealAccent = Color(0xFF64DFDF);
  static const offWhite = Color(0xFFF8F9FA);
  static const darkGray = Color(0xFF212529);
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.marineBluePrimary,
      primary: AppColors.marineBluePrimary,
      secondary: AppColors.redSecondary,
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.marineBluePrimary,
      primary: AppColors.marineBluePrimary,
      secondary: AppColors.redSecondary,
      brightness: Brightness.dark,
    ),
  );
}
