import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    background: AppColors.background,
  ),
  textTheme: AppTypography.textTheme,
  scaffoldBackgroundColor: AppColors.background,
);
