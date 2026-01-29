import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/src/presentation/views/chat/chat_screen.dart';
import 'package:vibe_now/src/presentation/views/common/custom_elevated_button.dart';

class WaveScreen extends StatefulWidget {
  const WaveScreen({super.key});

  @override
  State<WaveScreen> createState() => _WaveScreenState();
}

class _WaveScreenState extends State<WaveScreen> {
  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Chat;
    final name = extra.name;
    final avatar = extra.avatar;
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
                  avatar,
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
                '$name sent you a wave!',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              Text(
                'Would you like to start chatting?',
                style: TextStyle(fontSize: 14.sp, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 56.h),

              Column(
                spacing: 12.w,
                children: [
                  PrimaryButton.text(
                    onPressed: () {
                      context.pushNamed(
                        RouteNames.chatInboxScreen,
                        extra: extra,
                      );
                    },
                    text: 'Accept',
                  ),
                  CustomElevatedButton(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    buttonText: 'Reject',
                    btnColor: Colors.grey.shade300,
                    textColor: Color(0xff181818),
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
