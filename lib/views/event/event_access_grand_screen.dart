import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';

class EventAccessGrandScreen extends StatelessWidget {
  const EventAccessGrandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SafeArea(
              child: CustomAppBar(title: "Event Access Granted", canBack: true),
            ),
            SizedBox(height: 100.h),
            Image.asset(
              "assets/images/celebration.png",
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ),

            SizedBox(height: 10.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  style: BorderStyle.solid,
                  width: 1.w,
                  color: Color(0xff_E6E6E6),
                ),
              ),
              child: Column(
                spacing: 8.h,
                children: [
                  Text(
                    "Club House",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Text(
                    "Your request accessed to attend this event!",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: AppColors.subText,
                    ),
                  ),
                  SizedBox(
                    width: 220.w,
                    child: Text(
                      "Remember to scan the QR code on arrival to check in",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: AppColors.subText,
                      ),
                    ),
                  ),

                  Divider(color: Colors.grey[300], height: 1.h),

                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff_EFF6FF), Color(0xff_FAF5FF)],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),

                    child: Column(
                      children: [
                        _buildInfoCard(
                          icons: Assets.icons.calendarColor,
                          title: "250m - 3 Min Walk",
                        ),
                        _buildInfoCard(
                          icons: Assets.icons.colorClock,
                          title: "Arrive within: 19:45",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),
            PrimaryButton.text(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              text: "Ok",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required SvgGenImage icons, required String title}) {
    return Row(
      spacing: 6.w,
      children: [
        // Assets.icons.calendarColor.svg(width: 16.w, height: 16.h),
        icons.svg(width: 18.w, height: 18.h),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18.sp,
            color: AppColors.subText,
          ),
        ),
      ],
    );
  }
}
