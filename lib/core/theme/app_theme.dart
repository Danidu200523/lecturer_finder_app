import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: AppColors.background,

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w500, // Medium
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w500, // Medium
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w500, // Medium
      ),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w500, // Medium
      ),
    ),
  );
}
