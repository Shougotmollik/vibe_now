import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/services/local_storage.dart';
import 'package:vibe_now/views/auth/widgets/animated_value.dart';
import 'package:vibe_now/views/auth/widgets/animated_ball.dart';
import 'package:vibe_now/views/auth/widgets/animated_fade_up_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final balls = [
    AnimatedBall(
      delay: 200,
      begin: -550,
      alignType: AlignmentType.bottom,
      gradient: const LinearGradient(
        colors: [Color(0xFFA195FC), Color(0xFFA195FC)],
      ),
    ),
    AnimatedBall(
      delay: 800,
      begin: -1000,
      alignType: AlignmentType.left,
      gradient: const LinearGradient(
        colors: [
          Color(0xFF5CBFF2),
          Color(0xFF5CBBF2),
          Color(0xFF5EAFF3),
          Color(0xFF619CF5),
          Color(0xFF6581F9),
          Color(0xFF677AFA),
        ],
      ),
    ),
    AnimatedBall(
      delay: 800,
      begin: -1000,
      alignType: AlignmentType.right,
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xF2FB72D4), Color(0xFFCD72F5)],
      ),
    ),
    AnimatedBall(
      delay: 1500,
      begin: -500,
      alignType: AlignmentType.top,
      gradient: const LinearGradient(
        colors: [Color(0xFFD771F8), Color(0xFF9164FD)],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    AnimationConfig.enabled = true;
    AnimationConfig.speedMultiplier = 2.0;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          SizedBox(height: 375.h, width: double.infinity),

          AnimatedValue(
            option: AnimateOption(
              delay: 2000,
              duration: 700,
              begin: 1,
              end: -1,
            ),
            builder: (context, value) {
              final offsetValue = remap(value: value, toBegin: 0, toEnd: -50);
              final scaleValue = remap(value: value, toBegin: 1, toEnd: 1.33);
              return Transform.translate(
                offset: Offset(0, offsetValue),
                child: Transform.scale(
                  scale: scaleValue,
                  child: SizedBox(
                    width: 66.w,
                    height: 62.w,
                    child: Stack(clipBehavior: Clip.none, children: balls),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 70.h),

          AnimatedFadeUpText(
            delay: 2000,
            text: 'vybin',
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
          ),

          SizedBox(height: 24.h),

          AnimatedFadeUpText(
            delay: 2200,
            text: loc.translate('welcomeTo'),
            fontSize: 14.sp,
          ),

          const Spacer(),
          AnimatedValue(
            option: AnimateOption(
              delay: 2400,
              duration: 600,
              begin: 1,
              end: -1,
            ),
            builder: (context, value) {
              final offsetY = remap(value: value, toBegin: 80, toEnd: 0);
              final opacityValue = remap(value: value, toBegin: 0, toEnd: 1);

              return Transform.translate(
                offset: Offset(0, offsetY),
                child: FadeTransition(
                  opacity: AlwaysStoppedAnimation(opacityValue),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: PrimaryButton.text(
                      onPressed: () {
                        context.pushNamed(RouteNames.chooseLanguageScreen);
                      },
                      text: loc.translate('getStarted'),
                    ),
                  ),
                ),
              );
            },
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
