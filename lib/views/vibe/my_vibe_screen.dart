import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/views/common/cancel_button.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';

class MyVibeScreen extends StatelessWidget {
  const MyVibeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomAppBar(title: "My Vibe"),
                  GestureDetector(
                    onTap: () => showEndVibeDialog(context: context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.h,
                        horizontal: 16.w,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        gradient: AppColors.primaryGradientRotated,
                      ),
                      child: Text(
                        "End Vibe",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [...List.generate(1, (index) => const VibeCard())],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: PrimaryButton.text(
            onPressed: () => Navigator.pop(context),
            text: "View on Map",
          ),
        ),
      ),
    );
  }

  void showEndVibeDialog({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'End Vibe Early?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your Vibe will disappear immediately from the map',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: CancelButton(
                          onTap: () => Navigator.pop(context),
                          btnText: "Cancel",
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: SizedBox(
                        height: 48.h,
                        child: PrimaryButton.text(
                          onPressed: () => Navigator.pop(context),
                          radius: 50.r,
                          text: "End Now",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class VibeCard extends StatelessWidget {
  const VibeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                child: Image.network(
                  'https://content3.jdmagicbox.com/comp/def_content/coffee_shops/default-coffee-shops-7.jpg',
                  height: 180.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.r),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF68B695),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coffee Break',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sunday coffee vibes - who’s in?',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.purple.shade300,
                  size: 28.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  '18 min left',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 18.sp,
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
