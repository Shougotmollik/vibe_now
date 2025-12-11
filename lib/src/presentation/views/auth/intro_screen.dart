import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class IntroTileModel {
  final String title;
  final SvgGenImage icon;
  final Color iconColor;

  IntroTileModel({
    required this.title,
    required this.icon,
    this.iconColor = const Color(0xff4DBEFF),
  });
}

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  // List of intro tiles
  List<IntroTileModel> get introItems => [
    IntroTileModel(
      title: "Discover vibes happening around you",
      icon: Assets.icons.location,
    ),
    IntroTileModel(
      title: "Make spontaneous real-life connections",
      icon: Assets.icons.user,
    ),
    IntroTileModel(
      title: "Create your own events",
      icon: Assets.icons.calender,
    ),
    IntroTileModel(
      title: "Create your own community's",
      icon: Assets.icons.usersColor,
    ),
    IntroTileModel(
      title: "Safe & privacy-first by design",
      icon: Assets.icons.shieldColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Connect with real people nearby",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff202020),
                ),
              ),
              SizedBox(height: 32.h),

              Column(
                children: introItems
                    .map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: buildIntroTile(item),
                      ),
                    )
                    .toList(),
              ),

              SizedBox(height: 100.h),

              PrimaryButton.text(onPressed: () {}, text: 'Get Started'),
            ],
          ),
        ),
      ),
    );
  }

  // Intro tile widget
  Widget buildIntroTile(IntroTileModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xffF7F9FB),
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Row(
        spacing: 8.w,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xffEAF0FB),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: model.icon.svg(
              width: 24.w,
              height: 24.h,
              color: model.iconColor,
            ),
          ),
          Expanded(
            child: Text(
              model.title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xff171135),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
