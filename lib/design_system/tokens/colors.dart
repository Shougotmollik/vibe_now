import 'dart:math';

import 'package:flutter/material.dart';

// Design token colors
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF6750A4);
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color disableBtn = Color(0xffC4A8FF);

  // Light Mode Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF242424);
  static const Color secondaryText = Color(0xFF9D9D9D);
  static const Color subText = Color(0xff707070);
  static const Color cardBackground = Color(0xFFF8F9FA);
  static const Color border = Color(0xFFE0E0E0);
  static const Color surfaceVariantLight = Color(0xFFF7F9FB);

  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color primaryTextDark = Color(0xFFE1E1E1);
  static const Color secondaryTextDark = Color(0xFFA0A0A0);
  static const Color subTextDark = Color(0xFF808080);
  static const Color cardBackgroundDark = Color(0xFF2C2C2C);
  static const Color borderDark = Color(0xFF333333);
  static const Color surfaceVariantDark = Color(0xFF242424);

  // Status Colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF000000);
  static const Color onBackgroundDark = Color(0xFFFFFFFF);

  static const Color backgroundVariant = Color(0xFFEDF3F8);

  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8663F6), Color(0xFFC470F5), Color(0xFF57C2FF)],
    stops: [0.16, 0.54, 0.92],
    transform: GradientRotation(pi + 0.5),
  );
  static const Gradient primaryGradientRotated = LinearGradient(
    colors: [Color(0xFF8663F6), Color(0xFFC470F5), Color(0xFF57C2FF)],
    stops: [0.16, 0.54, 0.92],
    transform: GradientRotation(pi - 0.7),
  );
}
