import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/home/widgets/wave_animated_dialog.dart';
import 'package:vibe_now/views/vibe/my_vibe_screen.dart';

class UserVibeScreen extends StatefulWidget {
  const UserVibeScreen({super.key});

  @override
  State<UserVibeScreen> createState() => _UserVibeScreenState();
}

class _UserVibeScreenState extends State<UserVibeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(title: "All Vibes"),
              SizedBox(height: 20.h),
              VibeCard(),
              SizedBox(height: 12.h),

              Text(
                "Other Vibes",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12.h),
              Column(
                spacing: 12.h,
                children: List.generate(4, (index) => UserVibeCard()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserVibeCard extends StatefulWidget {
  const UserVibeCard({super.key});

  @override
  State<UserVibeCard> createState() => _UserVibeCardState();
}

class _UserVibeCardState extends State<UserVibeCard> {
  bool isWaved = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        spacing: 8.w,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50.r),
            child: Image.asset(
              "assets/images/profile_picture.jpg",
              width: 50.w,
              height: 50.w,
              fit: BoxFit.cover,
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Janny kosdowski",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText,
                ),
              ),
              Text(
                "Coffee break ☕",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.subText,
                ),
              ),
              Text(
                "Expires in 20min",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.subText,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() => isWaved = true);

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
                      child: WaveAnimatedDialog(
                        content: "You waved to Jenny Kosdowski",
                      ),
                    ),
                  );
                },
              );

              // showDialog(
              //   context: context,
              //   barrierColor: Colors.black.withOpacity(0.2),
              //   builder: (context) {
              //     Future.delayed(const Duration(seconds: 2), () {
              //       if (Navigator.canPop(context)) Navigator.pop(context);
              //     });

              //     return Center(
              //       child: Container(
              //         margin: EdgeInsets.all(24.w),
              //         padding: EdgeInsets.symmetric(
              //           vertical: 20.h,
              //           horizontal: 16.w,
              //         ),
              //         decoration: BoxDecoration(
              //           color: AppColors.background,
              //           borderRadius: BorderRadius.circular(24.r),
              //           boxShadow: [
              //             BoxShadow(
              //               color: Colors.black.withOpacity(0.1),
              //               blurRadius: 20,
              //               spreadRadius: 5,
              //             ),
              //           ],
              //         ),
              //         child: Column(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Lottie.asset(
              //               "assets/lottie/Hello Lottie.json",
              //               height: 120.h,
              //               repeat: false,
              //             ),
              //             SizedBox(height: 12.h),
              //             Text(
              //               "Wave Sent!",
              //               style: TextStyle(
              //                 fontSize: 18.sp,
              //                 fontWeight: FontWeight.bold,
              //                 color: AppColors.primaryText,
              //               ),
              //             ),
              //             SizedBox(height: 4.h),
              //             Text(
              //               "You have sent a wave to Janny Kosdowski",
              //               textAlign: TextAlign.center,
              //               style: TextStyle(
              //                 fontSize: 14.sp,
              //                 color: Colors.grey[600],
              //               ),
              //             ),
              //             SizedBox(height: 4.h),
              //           ],
              //         ),
              //       ),
              //     );
              //   },
              // );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: isWaved
                    ? AppColors.primaryGradientRotated.withOpacity(0.5)
                    : AppColors.primaryGradientRotated,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                isWaved ? "Waved" : "Wave",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
