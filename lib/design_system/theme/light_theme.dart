import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    background: AppColors.background,
    surface: AppColors.surface,
    brightness: Brightness.light,
  ),
  textTheme: AppTypography.textTheme,
  scaffoldBackgroundColor: AppColors.background,
);
