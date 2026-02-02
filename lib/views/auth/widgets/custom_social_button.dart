import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class CustomSocialButton extends StatelessWidget {
  const CustomSocialButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.fontSize,
    this.fontWeight,
  });

  final double? fontSize;
  final SvgGenImage icon;
  final String title;
  final VoidCallback onTap;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xfffcfcfc),
          borderRadius: BorderRadius.circular(40.r),
          boxShadow: [
            BoxShadow(
              color: Color(0xff000000).withValues(alpha: 0.02),
              spreadRadius: 0,
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Row(
            spacing: 4.w,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon.svg(width: 16.w, height: 16.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: fontSize ?? 14.sp,
                  fontWeight: fontWeight ?? FontWeight.w600,
                  color: Color(0xff1a1a23),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
