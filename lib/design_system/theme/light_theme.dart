import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    onSurface: AppColors.primaryText,
    error: AppColors.error,
    onBackground: AppColors.onBackground,
    background: AppColors.background,
    surfaceVariant: AppColors.surfaceVariantLight,
    onSurfaceVariant: AppColors.subText,
  ),
  // textTheme: AppTypography.textTheme.apply(
  //   bodyColor: AppColors.primaryText,
  //   displayColor: AppColors.primaryText,
  // ),
  scaffoldBackgroundColor: AppColors.background,
  dividerColor: AppColors.border,
  cardTheme: CardThemeData(
    color: AppColors.cardBackground,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
