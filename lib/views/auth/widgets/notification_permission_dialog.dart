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
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Stay updated on new vibes, waves, and real-time connections.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  btnColor: Theme.of(context).colorScheme.surfaceVariant,
                  textColor: Theme.of(context).colorScheme.onSurfaceVariant,
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
