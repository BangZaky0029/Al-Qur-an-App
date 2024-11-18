import 'package:flutter/material.dart';
import 'colors.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.textPrimary,
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: AppBarTheme(
    color: AppColors.textPrimary,
    toolbarTextStyle: const TextTheme(
      bodyMedium: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    ).bodyText2,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
);

extension on TextTheme {
  get bodyText2 => null;
}
