import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Radius tokens
class AppRadius {
  AppRadius._();

  static const BorderRadius small = BorderRadius.all(Radius.circular(4));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(8));
  static const BorderRadius large = BorderRadius.all(Radius.circular(16));
  static final BorderRadius extraLarge = BorderRadius.all(
    Radius.circular(24.r),
  );
}
