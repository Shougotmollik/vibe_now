import 'package:flutter/material.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/notification/notification_screen.dart';

class CommunityNotificationScreen extends StatelessWidget {
  const CommunityNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SafeArea(child: CustomAppBar(title: "Community Notification")),

            ...List.generate(
              2,
              (index) => CommunityNotificationCard(
                acceptOnTap: () {},
                rejectOnTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
