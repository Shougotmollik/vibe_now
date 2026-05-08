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
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required Widget child,
    this.radius,
    this.gradient,
    this.isEnabled = true,
    this.isLoading = false,
  }) : _child = child,
       _text = null;

  const PrimaryButton.text({
    super.key,
    required this.onPressed,
    required String text,
    this.gradient,
    this.radius,
    this.isEnabled = true,
    this.isLoading = false,
  }) : _child = null,
       _text = text;

  @override
  Widget build(BuildContext context) {
    final bool isButtonDisabled = !isEnabled || isLoading;

    final Widget content = isLoading
        ? SizedBox(
            height: 20.h,
            width: 20.h,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : (_child ??
              Text(
                _text ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ));

    final height = 48.h;

    final Gradient effectiveGradient = gradient ?? AppColors.primaryGradient;

    final decorationGradient = isButtonDisabled
        ? LinearGradient(
            colors: effectiveGradient.colors
                .map((color) => color.withOpacity(0.5))
                .toList(),
            begin: effectiveGradient is LinearGradient
                ? (effectiveGradient).begin
                : Alignment.centerLeft,
            end: effectiveGradient is LinearGradient
                ? (effectiveGradient).end
                : Alignment.centerRight,
          )
        : effectiveGradient;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: decorationGradient,
        borderRadius: BorderRadius.circular(radius ?? 24.r),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(height),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 24.r),
          ),
        ),
        onPressed: isButtonDisabled ? null : onPressed,
        child: content,
      ),
    );
  }
}
