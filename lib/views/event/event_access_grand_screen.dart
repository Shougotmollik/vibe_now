import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';

class EventAccessGrandScreen extends StatelessWidget {
  const EventAccessGrandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SafeArea(
              child: CustomAppBar(title: loc.translate('eventAccessGranted'), canBack: true),
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
                  color: Theme.of(context).colorScheme.outlineVariant,
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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    loc.translate('yourRequestHasBeenSent'),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(
                    width: 220.w,
                    child: Text(
                      loc.translate('qrCodeDescription'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  Divider(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    height: 1.h,
                  ),

                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12.r),
                    ),

                    child: Column(
                      children: [
                        _buildInfoCard(
                          icons: Assets.icons.calendarColor,
                          title: "250m - 3 Min Walk",
                          context: context,
                        ),
                        _buildInfoCard(
                          icons: Assets.icons.colorClock,
                          title: "Arrive within: 19:45",
                          context: context,
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
              text: loc.translate('ok'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required SvgGenImage icons,
    required String title,
    required BuildContext context,
  }) {
    return Row(
      spacing: 6.w,
      children: [
        icons.svg(width: 18.w, height: 18.h),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
