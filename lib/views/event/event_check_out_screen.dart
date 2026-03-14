import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';

class EventCheckOutScreen extends StatelessWidget {
  const EventCheckOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CustomAppBar(title: "Event Check• In"),
              SizedBox(height: 20.h),
              Assets.icons.eventCheckOut.svg(
                width: double.infinity,
                height: 200.h,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 20.h),
              Text(
                "Left Event Zone",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 24.sp,
                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(
                width: 280.w,
                child: Text(
                  "You've left the Event Zone Returning tc the map....",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              Spacer(),
              PrimaryButton.text(
                onPressed: () {
                  context.pushNamed(RouteNames.mainNavBar);
                },
                text: "Continue",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
