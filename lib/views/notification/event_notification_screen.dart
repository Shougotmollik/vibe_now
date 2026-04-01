import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/model/notification.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/community/community_awaiting_qrscreen.dart';
import 'package:vibe_now/views/notification/notification_screen.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';
import 'package:vibe_now/views/notification/widgets/event_notification_card.dart';

class EventNotificationScreen extends StatefulWidget {
  const EventNotificationScreen({super.key});

  @override
  State<EventNotificationScreen> createState() =>
      _EventNotificationScreenState();
}

class _EventNotificationScreenState extends State<EventNotificationScreen> {
  final List<NotificationModel> events = [
    NotificationModel(
      title: 'Jenny smith is interested in your event',
      distance: '160',
    ),
    NotificationModel(
      title: 'Engin Accepted your event join request',
      distance: '90',
    ),
    NotificationModel(title: 'Metin Sent you a Wave', distance: '20'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SafeArea(child: CustomAppBar(title: "Event Notifications")),
            SizedBox(height: 18.h),
            Column(
              spacing: 8.h,
              children: [
                ...List.generate(
                  3,
                  (index) => EventNotificationCard(notification: events[index]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
