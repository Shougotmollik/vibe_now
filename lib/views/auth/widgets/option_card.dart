import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class OptionCard extends StatelessWidget {
  final OptionModel model;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionCard({
    required this.model,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFF8663F6),
                    Color(0xFFC470F5),
                    Color(0XFF57C2FF),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                )
              : null,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xffFEFEFE),
            borderRadius: BorderRadius.circular(22.r),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                model.icon.svg(
                  width: 32.w,
                  height: 32.h,
                  color: Color(0xff6E6E6E),
                ),
                SizedBox(height: 7.h),
                Text(
                  model.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff6E6E6E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OptionModel {
  final SvgGenImage icon;
  final String title;

  OptionModel({required this.icon, required this.title});
}
