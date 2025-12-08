import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
  ),
  textTheme: AppTypography.textTheme,
);
