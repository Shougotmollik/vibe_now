import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';

import 'package:vibe_now/core/constant/credential.dart';

class CommunityAwaitingQrScreen extends StatelessWidget {
  const CommunityAwaitingQrScreen({
    super.key,
    required this.memberName,
    required this.memberAvatar,
    this.scheduledAt,
    this.qrCodeValue,
    this.qrCodeImage,
  });

  final String memberName;
  final String memberAvatar;
  final String? scheduledAt;
  final String? qrCodeValue;
  final String? qrCodeImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: CustomAppBar(title: "Awaiting QR", canBack: true),
              ),
            ),

            SizedBox(height: 60.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 8,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(24.w, 50.h, 24.w, 24.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: memberName,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20.sp,
                                  ),
                              ),
                              TextSpan(
                                text: ' has been approved!',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20.sp,
                                  ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16.sp,
                               color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              scheduledAt ?? 'Wed, 12 at 4:00 PM',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 14.sp,
                                ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        Container(
                          width: 180.w,
                          height: 180.w,
                          color: Colors.white,
                          child: qrCodeImage != null
                              ? Image.network(
                                  AppCredentials.fixurl(qrCodeImage!),
                                  fit: BoxFit.contain,
                                )
                              : qrCodeValue != null
                                  ? Center(
                                      child: Text(
                                        qrCodeValue!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.qr_code_2,
                                      size: 180,
                                      color: Colors.black,
                                    ),
                        ),
                        SizedBox(height: 30.h),

                        Container(
                          padding: EdgeInsets.all(14.w),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 8.w,
                            children: [
                              Assets.icons.scan.svg(
                                height: 20.w,
                                width: 24.w,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              Text(
                                "Scan QR Code",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: -40.h,
                    child: Container(
                      width: 80.h,
                      height: 80.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).colorScheme.surface, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          AppCredentials.fixurl(memberAvatar),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: const Column(
                children: [
                  _InfoBullet(
                    text:
                        'QR code must be scanned in person to become a member',
                  ),
                  SizedBox(height: 12),
                  _InfoBullet(text: 'You can cancel this meetup anytime'),
                ],
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}

class _InfoBullet extends StatelessWidget {
  final String text;

  const _InfoBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
