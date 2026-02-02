import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/auth/widgets/step_page.dart';
import 'package:vibe_now/views/auth/widgets/step_title.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/home/home_screen.dart';

class StepLocationScreen extends StatefulWidget {
  final int step;
  const StepLocationScreen({this.step = 1, super.key});

  @override
  State<StepLocationScreen> createState() => _StepLocationScreenState();
}

class _StepLocationScreenState extends State<StepLocationScreen> {
  @override
  Widget build(BuildContext context) {
    return StepPage(
      currentStep: widget.step,
      footer: Row(
        spacing: 28.w,
        children: [
          Expanded(
            child: CustomElevatedButton(
              onTap: () {
                context.pushNamed(RouteNames.mainNavBar);
              },
              buttonText: 'Not Now',
            ),
          ),
          Expanded(
            child: PrimaryButton.text(
              onPressed: () {
                context.pushReplacementNamed(RouteNames.mainNavBar);
              },
              text: 'Allow',
            ),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 32.h),

            const StepTitle(title: 'Choose Location', subtitle: ""),

            SizedBox(height: 68.h),

            // SizedBox(height: 115.h),

            // Assets.icons.locationIc.svg(width: 100.w, height: 100.h),
            Lottie.asset(
              'assets/lottie/Location Pin.json',
              height: 200.w,
              width: 300.w,
              delegates: LottieDelegates(
                values: [
                  // All fills
                  ValueDelegate.color([
                    '**',
                    'Fill *',
                  ], value: Color(0xFF6750A4)),

                  // All strokes
                  ValueDelegate.color([
                    '**',
                    'Stroke *',
                  ], value: Color(0xFF6750A4)),
                ],
              ),
            ),

            // SizedBox(height: 24.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                'Allow location to connect with people, events, and communities around you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff727272),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'We only use your location while you’re using the app.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xff727272),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
