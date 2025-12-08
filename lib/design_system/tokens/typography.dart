import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Typography tokens
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Roboto';

  static final TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16.sp),
    bodyMedium: TextStyle(fontSize: 14.sp),
    bodySmall: TextStyle(fontSize: 12.sp),
  );
}
