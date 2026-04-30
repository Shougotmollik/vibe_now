import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/model/notification.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/community/community_awaiting_qrscreen.dart';
import 'package:vibe_now/views/notification/notification_screen.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';
import 'package:vibe_now/views/notification/widgets/community_notification_card.dart';

class CommunityNotificationScreen extends StatefulWidget {
  const CommunityNotificationScreen({super.key});

  @override
  State<CommunityNotificationScreen> createState() =>
      _CommunityNotificationScreenState();
}

class _CommunityNotificationScreenState
    extends State<CommunityNotificationScreen> {
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
      title: 'Metin invited you to community meetup',
      distance: '20',
      invitation: true,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SafeArea(child: CustomAppBar(title: "Community Notifications")),
            SizedBox(height: 18.h),

            ...List.generate(
              2,
              (index) => CommunityNotificationCard(
                notification: communities[index],
                acceptOnTap: () async {
                  await showDialog(
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
                                'You have accepted jenny smith\'s community join request.',
                            accept: true,
                          ),
                        ),
                      );
                    },
                  );

                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommunityAwaitingQrScreen(),
                      ),
                    );
                  }
                },

                rejectOnTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
