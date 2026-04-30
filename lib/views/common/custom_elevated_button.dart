import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.onTap,
    required this.buttonText,
    this.btnColor,
    this.textColor,
    this.fontWeight,
    this.height,
  });

  final FontWeight? fontWeight;
  final VoidCallback onTap;
  final String buttonText;
  final Color? btnColor;
  final Color? textColor;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 48.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: btnColor ?? Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(40.r),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            width: 1.w,
          ),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 16.sp,
              color: textColor ?? Theme.of(context).colorScheme.onPrimary,
              fontWeight: fontWeight ?? FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
