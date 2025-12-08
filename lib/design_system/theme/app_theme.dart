import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => lightTheme;
  static ThemeData dark() => darkTheme;
}
