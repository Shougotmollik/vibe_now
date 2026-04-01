import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/notification.dart';

class EventNotificationCard extends StatelessWidget {
  final NotificationModel notification;
  const EventNotificationCard({
    super.key,
    required this.notification,
    // required this.acceptOnTap,
    // required this.rejectOnTap,
  });
  // final VoidCallback acceptOnTap;
  // final VoidCallback rejectOnTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xffE0E0E0), width: 1.w),
        ),
      ),
      child: Row(
        spacing: 8.w,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50.r),
            child: Image.asset(
              "assets/images/profile_picture.jpg",
              width: 50.w,
              height: 50.w,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff1E1E1E),
                  ),
                ),
                SizedBox(
                  width: 180.w,
                  child: Row(
                    children: [
                      Assets.icons.location.svg(
                        width: 16.w,
                        height: 16.h,
                        color: Colors.black54,
                      ),
                      Text(
                        "${notification.distance} km away",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // SizedBox(
          //   child: Row(
          //     spacing: 8.w,
          //     children: [
          //       GestureDetector(
          //         onTap: acceptOnTap,
          //         child: Assets.icons.accept.svg(
          //           width: 20.w,
          //           height: 20.h,
          //           color: AppColors.primary,
          //         ),
          //       ),
          //       GestureDetector(
          //         onTap: rejectOnTap,
          //         child: Assets.icons.decline.svg(
          //           width: 22.w,
          //           height: 22.h,
          //           // color: AppColors.primary,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
