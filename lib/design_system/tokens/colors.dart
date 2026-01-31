import 'dart:math';

import 'package:flutter/material.dart';

// Design token colors
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6750A4);
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color disableBtn = Color(0xffC4A8FF);

  static const Color primaryText = Color(0xFF242424);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundVariant = Color(0xFFEDF3F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF000000);
  // static const Color text = Color(0xFFblack);
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
