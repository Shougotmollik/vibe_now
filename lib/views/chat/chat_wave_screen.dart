import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/model/chat.dart';
import 'package:vibe_now/views/chat/chat_screen.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';
import 'package:vibe_now/views/vibe/vibe_connect_screen.dart';

class ChatWaveScreen extends StatefulWidget {
  const ChatWaveScreen({super.key});

  @override
  State<ChatWaveScreen> createState() => _ChatWaveScreenState();
}

class _ChatWaveScreenState extends State<ChatWaveScreen> {
  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Chat;
    final name = extra.name;
    final avatar = extra.avatars;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(50.r),
                child: Image.network(
                  avatar[0],
                  width: 80.w,
                  height: 80.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person, size: 40.sp),
                    );
                  },
                ),
              ),
              // SizedBox(height: 56.h),

              // Text('👋', style: TextStyle(fontSize: 84.sp)),
              Lottie.asset(
                "assets/lottie/Hello Lottie.json",
                height: 200.w,
                fit: BoxFit.cover,
                reverse: false,
              ),

              // SizedBox(height: 16.h),
              Text(
                '$name wants to meet you.',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Accept to suggest a time and place for a quick meetup',
                style: TextStyle(fontSize: 14.sp, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 56.h),

              Column(
                spacing: 12.w,
                children: [
                  PrimaryButton.text(
                    onPressed: () {
                      // context.pushNamed(
                      //   RouteNames.chatInboxScreen,
                      //   extra: extra,
                      // );

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => VibeConnectScreen(),
                        ),
                      );
                    },
                    text: 'Accept',
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: Color(0xffAEAEAE), width: 1.w),
                    ),
                    child: CustomElevatedButton(
                      onTap: () {
                        Navigator.pop(context);

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
                                      'You have rejected Sammy Smith Wave request.',
                                  accept: false,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      buttonText: 'Reject',
                      btnColor: Colors.white,
                      textColor: Color(0xff181818),
                    ),
                  ),

                  // SizedBox(width: 18.w),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
