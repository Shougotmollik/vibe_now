import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class CommunityWelcomeScreen extends StatelessWidget {
  const CommunityWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 150.h,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/Confetti - Full Screen.json',
                      width: double.infinity,
                      repeat: true,
                      fit: BoxFit.cover,
                    ),
                    const Text("🥳", style: TextStyle(fontSize: 80)),
                  ],
                ),
              ),

              const Text(
                "Welcome To\nRunning Club!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "You're now an official member,\nFeel free to say hi to the group",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.4),
              ),

              SizedBox(height: 24.h),

              _buildFeaturesCard(context: context),
              const SizedBox(height: 24),

              _buildTrustNote(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesCard({required BuildContext context}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF5EFF6),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(Assets.icons.chatting, "Chats"),
          _buildListTile(Assets.icons.calendarColor, "Events"),
          _buildListTile(Assets.icons.communityColor, "Members"),
          const SizedBox(height: 24),

          PrimaryButton.text(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            text: "Enter Community",
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(SvgGenImage icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F7FF),
              shape: BoxShape.circle,
            ),
            child: icon.svg(height: 24, width: 24),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3142),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Assets.icons.shieldColor.svg(width: 24.h, height: 24.h),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        '"Pending meetups not completed may affect your Respect Score." ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                      fontSize: 14.sp,
                    ),
                  ),
                  TextSpan(
                    text:
                        'This connects Communities with your Trust ecosystem.',
                    style: TextStyle(
                      color: AppColors.subText,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
