import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class CommunityNotificationCard extends StatefulWidget {
  const CommunityNotificationCard({super.key});

  @override
  State<CommunityNotificationCard> createState() =>
      _CommunityNotificationCardState();
}

class _CommunityNotificationCardState extends State<CommunityNotificationCard> {
  bool _isTapped = false;

  void _handleTap() {
    setState(() {
      _isTapped = true;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isTapped = false;
      });

      context.pushNamed(RouteNames.communityScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: const Color(0xffEAEAEA), width: 1.w),
          ),
          gradient: _isTapped
              ? LinearGradient(
                  colors: [
                    const Color(0xff8663F6).withValues(alpha: 0.15),
                    const Color(0xffC470F5).withValues(alpha: 0.15),
                    const Color(0xff57C2FF).withValues(alpha: 0.15),
                  ],
                  stops: [0.16, 0.54, 0.92],
                  transform: GradientRotation(pi - 0.7),
                )
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50.r),
              child: Image.network(
                'https://images.unsplash.com/photo-1525026198548-4baa812f1183?q=80&w=1034&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                width: 48.w,
                height: 48.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Jenny Smith",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff303030),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Assets.icons.location.svg(
                        width: 16.w,
                        height: 16.h,
                        color: const Color(0xff707070),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        '300km away',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff707070),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Assets.icons.calendarColor.svg(
                        width: 16.w,
                        height: 16.h,
                        color: const Color(0xff707070),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        '8PM, 21 Nov',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff707070),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
