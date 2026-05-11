import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/views/common/cancel_button.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/event/event_access_grand_screen.dart';

class EventRequestScreen extends StatelessWidget {
  const EventRequestScreen({super.key, required this.event});
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SafeArea(
                  child: CustomAppBar(
                    title: "Event Request Sent",
                    canBack: true,
                  ),
                ),
                SizedBox(height: 100.h),
                Image.asset(
                  "assets/images/celebration.png",
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 10.h),
                Text(
                  event.title ?? "",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 10.h),

                _buildEventInfoCard(
                  context,
                  icon: Assets.icons.location,
                  location: event.address ?? "",
                ),
                SizedBox(height: 8.h),
                _buildEventInfoCard(
                  context,
                  icon: Assets.icons.colorClock,
                  location: "${event.eventDate} ${event.eventTime}",
                ),
                Spacer(),
                Text(
                  "Your request has been sent!",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: 12.h),
                PrimaryButton.text(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventAccessGrandScreen(),
                      ),
                    );
                  },
                  text: "OK",
                ),
                SizedBox(height: 12.h),
                CancelButton(onTap: () {}, btnText: "Withdraw Request"),

                SizedBox(height: 48.h),
              ],
            ),
          ),
          IgnorePointer(
            child: Lottie.asset(
              'assets/lottie/Confetti - Full Screen.json',
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

  Widget _buildEventInfoCard(
    BuildContext context, {
    required SvgGenImage icon,
    required String location,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon.svg(width: 16.w, height: 16.h, color: Theme.of(context).colorScheme.onSurfaceVariant),
        SizedBox(width: 5.w),

        Text(
          location,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
