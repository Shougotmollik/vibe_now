import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:vibe_now/localization/app_localizations.dart'; // Added Lottie import
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';

class EventCheckOutScreen extends StatelessWidget {
  const EventCheckOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CustomAppBar(title: loc.translate('eventCheckout')),
                  SizedBox(height: 120.h),
                  Assets.icons.checkboxGradient.svg(width: 60.h, height: 60.h),
                  SizedBox(height: 20.h),
                  Text(
                    loc.translate('leftEventZone'),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 24.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(
                    width: 280.w,
                    child: Text(
                      loc.translate('leftEventDesc'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Spacer(),
                  PrimaryButton.text(
                    onPressed: () {
                      context.pushNamed(RouteNames.mainNavBar);
                    },
                    text: loc.translate('continueText'),
                  ),
                ],
              ),
            ),
          ),

          IgnorePointer(
            child: Lottie.asset(
              'assets/lottie/Confetti.json',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
        ],
      ),
    );
  }
}
