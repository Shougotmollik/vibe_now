import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../tokens/tokens.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget? _child;
  final String? _text;
  final Gradient? gradient;
  final bool isEnabled;
  final double? radius;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required Widget child,
    this.radius,
    this.gradient,
    this.isEnabled = true,
  }) : _child = child,
       _text = null;

  const PrimaryButton.text({
    super.key,
    required this.onPressed,
    required String text,
    this.gradient,
    this.radius,
    this.isEnabled = true,
  }) : _child = null,
       _text = text;

  @override
  Widget build(BuildContext context) {
    final child =
        _child ??
        Text(
          _text!,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isEnabled ? Colors.white : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        );
    final height = 48.h;
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? (gradient ?? AppColors.primaryGradient)
            : AppColors.primaryGradient.withOpacity(0.5),
        // color: isEnabled ? null : Color(0xffC4A8FF),
        borderRadius: BorderRadius.circular(radius ?? 24.r),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(height),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 24.r),
          ),
        ),
        onPressed: isEnabled ? onPressed : null,
        child: child,
      ),
    );
  }
}
