import 'package:flutter/material.dart';

// Add custom ThemeExtensions here as needed
class CustomColors extends ThemeExtension<CustomColors> {
  final Color? brand;

  const CustomColors({this.brand});

  @override
  CustomColors copyWith({Color? brand}) =>
      CustomColors(brand: brand ?? this.brand);

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(brand: Color.lerp(brand, other.brand, t));
  }
}
