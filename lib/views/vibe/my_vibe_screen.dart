import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/vibe_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/model/vibe_model.dart';
import 'package:vibe_now/views/common/cancel_button.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/vibe/widgets/vibe_shimmer_loading.dart';

class MyVibeScreen extends StatelessWidget {
  final Vibe? vibe;
  MyVibeScreen({super.key, this.vibe});

  final VibeController _vibeController = Get.find<VibeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Obx(() {
              // Read observable variable immediately to ensure GetX registers this Obx
              final loading = _vibeController.isVibesLoading.value;
              final displayVibe = vibe ?? _vibeController.ownVibe.value;

              if (displayVibe == null) {
                if (loading) {
                  return const OwnVibeShimmer();
                } else {
                  return const Center(child: Text("No active vibe found."));
                }
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VibeCard(vibe: displayVibe),
                ],
              );
            }),
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
                Text(
                  'End Vibe Early?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Vibe will disappear immediately from the map',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: CustomElevatedButton(
                          onTap: () => Navigator.pop(context),
                          buttonText: 'Cancel',
                          btnColor: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant,
                          textColor: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: SizedBox(
                        height: 48.h,
                        child: Obx(() {
                          return PrimaryButton.text(
                            isLoading: _vibeController.isLoading.value,
                            onPressed: () async {
                              final displayVibe = vibe ?? _vibeController.ownVibe.value;
                              if (displayVibe?.id != null) {
                                final success = await _vibeController.endVibe(displayVibe!.id!);
                                if (success) {
                                  if (context.mounted) {
                                    Navigator.pop(context); // Pop the dialog
                                    Navigator.pop(context); // Navigate back to previous screen
                                  }
                                }
                              }
                            },
                            radius: 50.r,
                            text: "End Now",
                          );
                        }),
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
  final Vibe vibe;
  const VibeCard({super.key, required this.vibe});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                child: vibe.coverImage != null
                    ? Image.network(
                        AppCredentials.fixurl(vibe.coverImage),
                        height: 180.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.network(
                          'https://content3.jdmagicbox.com/comp/def_content/coffee_shops/default-coffee-shops-7.jpg',
                          height: 180.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.network(
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
                        vibe.status?.toUpperCase() ?? 'LIVE',
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
                      vibe.title ?? 'No Title',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vibe.createdBy?.fullName ?? ""} - ${vibe.duration ?? ""}',
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
                  '${vibe.duration} left',
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
