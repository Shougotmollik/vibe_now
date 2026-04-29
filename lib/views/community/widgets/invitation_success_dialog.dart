import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';

class InviteSuccessDialog extends StatefulWidget {
  const InviteSuccessDialog({super.key});

  @override
  State<InviteSuccessDialog> createState() => _InviteSuccessDialogState();
}

class _InviteSuccessDialogState extends State<InviteSuccessDialog> {
  @override
  void initState() {
    super.initState();
    // Closes the dialog automatically after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 120.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie/Confetti - Full Screen.json',
                    repeat: true,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Text('🥳', style: TextStyle(fontSize: 60.sp)),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Invite Sent!',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your invite has been sent successfully.',
              textAlign: TextAlign.center,
               style: TextStyle(
                fontSize: 15.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
