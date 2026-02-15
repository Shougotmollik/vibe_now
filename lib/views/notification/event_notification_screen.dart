import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/notification/notification_screen.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';
import 'package:vibe_now/views/notification/widgets/event_notification_card.dart';

class EventNotificationScreen extends StatelessWidget {
  const EventNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SafeArea(child: CustomAppBar(title: "Event Notifications")),
            Column(
              spacing: 8.h,
              children: [
                ...List.generate(
                  3,
                  (index) => EventNotificationCard(
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
                                    'You have accepted jenny smith\'s event request.',
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
                                    'You have rejected jenny smith\'s event request.',
                                accept: false,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
