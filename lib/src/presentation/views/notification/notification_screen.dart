import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/common/custom_app_bar.dart';
import 'package:vibe_now/src/presentation/views/notification/widgets/community_notification_card.dart';
import 'package:vibe_now/src/presentation/views/notification/widgets/event_notification_card.dart';
import 'package:vibe_now/src/presentation/views/notification/widgets/wave_notification_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<String> notificationTabs = ['Wave', 'Event', 'Community'];
  int selectedTapIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: "Notification"),

            SizedBox(height: 12.h),

            _buildTapBarSection(),
            SizedBox(height: 24.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.w),
              child: Column(
                children: List.generate(5, (index) {
                  switch (selectedTapIndex) {
                    case 0:
                      return const WaveNotificationCard();
                    case 1:
                      return const EventNotificationCard();
                    case 2:
                      return const CommunityNotificationCard();
                    default:
                      return const WaveNotificationCard();
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTapBarSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        spacing: 8.w,
        children: List.generate(notificationTabs.length, (index) {
          bool isTapSelected = selectedTapIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedTapIndex = index),
            child: Container(
              height: 32.h,
              width: 110.w,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: isTapSelected
                    ? AppColors.primaryGradientRotated
                    : LinearGradient(colors: [Colors.white, Colors.white]),
                border: Border.all(
                  color: isTapSelected
                      ? Colors.transparent
                      : const Color(0xffEAEAEA),
                ),
              ),
              child: Expanded(
                child: Text(
                  notificationTabs[index],
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: isTapSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
