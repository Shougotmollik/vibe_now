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
  });

  final FontWeight? fontWeight;
  final VoidCallback onTap;
  final String buttonText;
  final Color? btnColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        // padding: EdgeInsets.symmetric(vertical: 12.h),
        width: double.infinity,
        decoration: BoxDecoration(
          color: btnColor ?? Color(0xff2A2A2A),
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 16.sp,
              color: textColor ?? Color(0xFFfefefe),
              fontWeight: fontWeight ?? FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
