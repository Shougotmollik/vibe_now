import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';

class NotificationPermissionDialog extends StatelessWidget {
  final BuildContext parentContext;
  const NotificationPermissionDialog({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 225.h,
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'vibe.now wants to send you notifications',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xff2a2a2a),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Stay updated on new vibes, waves, and real-time connections.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xff707070),
            ),
          ),
          SizedBox(height: 32.h),
      
          Row(
            spacing: 8.w,
            children: [
              Expanded(
                child: CustomElevatedButton(
                  onTap: () {
                    Navigator.of(parentContext, rootNavigator: true).pop();
                    parentContext.pushNamed(RouteNames.stepNameScreen);
                  },
                  buttonText: "Don't Allow",
                  btnColor: Color(0xffEDF3F8),
                  textColor: Color(0xff202020),
                ),
              ),
              Expanded(
                child: PrimaryButton.text(
                  onPressed: () {
                    Navigator.of(parentContext, rootNavigator: true).pop();
                    parentContext.pushNamed(RouteNames.stepNameScreen);
                  },
                  text: 'Allow',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
