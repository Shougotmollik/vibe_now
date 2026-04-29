import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.primaryTextDark,
    error: AppColors.error,
    onBackground: AppColors.onBackgroundDark,
    background: AppColors.backgroundDark,
    surfaceVariant: AppColors.surfaceVariantDark,
    onSurfaceVariant: AppColors.subTextDark,
  ),
  textTheme: AppTypography.textTheme.apply(
    bodyColor: AppColors.primaryTextDark,
    displayColor: AppColors.primaryTextDark,
  ),
  scaffoldBackgroundColor: AppColors.backgroundDark,
  dividerColor: AppColors.borderDark,
  cardTheme: CardThemeData(
    color: AppColors.cardBackgroundDark,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
