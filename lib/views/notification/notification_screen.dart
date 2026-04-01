import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/community_notification.dart';
import 'package:vibe_now/model/notification.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/community/community_awaiting_qrscreen.dart';
import 'package:vibe_now/views/community/community_details_screen.dart';
import 'package:vibe_now/views/notification/community_notification_screen.dart';
import 'package:vibe_now/views/notification/event_notification_screen.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';
import 'package:vibe_now/views/notification/widgets/community_notification_card.dart';
import 'package:vibe_now/views/notification/widgets/event_notification_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

final List<NotificationModel> events = [
  NotificationModel(
    title: 'Jenny smith is interested in your event',
    distance: '160',
  ),
  NotificationModel(
    title: 'Engin Accepted your event join request',
    distance: '90',
  ),
  NotificationModel(title: 'Metin joined in your event', distance: '20'),
];

final List<NotificationModel> communities = [
  NotificationModel(
    title: 'Jenny smith is interested in your community',
    distance: '160',
  ),
  NotificationModel(
    title: 'Engin Accepted your community join request',
    distance: '90',
  ),
  NotificationModel(
    title: 'Metin invited you join to community meetup',
    distance: '20',
    invitation: true,
  ),
];

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SafeArea(child: CustomAppBar(title: "Notification")),
            SizedBox(height: 24.h),
            _buildEventSection(),
            SizedBox(height: 28.h),
            _buildCommunitySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border(
          top: BorderSide(color: const Color(0xffE0E0E0), width: 1.w),
          bottom: BorderSide(color: const Color(0xffE0E0E0), width: 1.w),
          left: BorderSide(color: const Color(0xffE0E0E0), width: 1.w),
          right: BorderSide(color: const Color(0xffE0E0E0), width: 1.w),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 8.h,
        children: [
          Container(
            height: 50.h,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xfffbadd8), Color(0xffdeb5fe)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              border: Border(
                bottom: BorderSide(color: const Color(0xffE0E0E0), width: 1.w),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8.w,
              children: [
                Assets.icons.calendarColor.svg(width: 20.w, height: 20.h),
                Text(
                  "Events",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 60.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Center(
                    child: Text(
                      "3 more",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 250.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),

            child: Column(
              // spacing: 8.h,
              children: [
                ...List.generate(
                  3,
                  (index) => EventNotificationCard(notification: events[index]),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventNotificationScreen(),
                    ),
                  ),
                  child: Row(
                    spacing: 4.w,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "See All",
                        style: TextStyle(color: AppColors.primary),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.primary,
                        size: 12.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunitySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border(
          top: BorderSide(color: const Color(0xffE0E0E0), width: 1.w),
          bottom: BorderSide(color: const Color(0xffE0E0E0), width: 1.w),
          left: BorderSide(color: const Color(0xffE0E0E0), width: 1.w),
          right: BorderSide(color: const Color(0xffE0E0E0), width: 1.w),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 8.h,
        children: [
          Container(
            height: 50.h,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff99e2f1), Color(0xffaaccff)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              border: Border(
                bottom: BorderSide(color: const Color(0xffE0E0E0), width: 1.w),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8.w,
              children: [
                Assets.icons.communityColor.svg(width: 20.w, height: 20.h),
                Text(
                  "Communities",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 60.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Center(
                    child: Text(
                      "2 more",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 250.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),

            child: Column(
              // spacing: 8.h,
              children: [
                ...List.generate(
                  3,
                  (index) => CommunityNotificationCard(
                    notification: communities[index],
                    acceptOnTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          return Center(
                            child: Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              child: AnimatedDialogContent(
                                content:
                                    'You have accepted metin\'s invitation.',
                                accept: true,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    rejectOnTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          return Center(
                            child: Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              child: AnimatedDialogContent(
                                content:
                                    'You have rejected metin\'s invitation.',
                                accept: false,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommunityNotificationScreen(),
                    ),
                  ),
                  child: Row(
                    spacing: 4.w,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "See All",
                        style: TextStyle(color: AppColors.primary),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.primary,
                        size: 12.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
