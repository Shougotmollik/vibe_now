import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';

class RequestSentDialog extends StatelessWidget {
  const RequestSentDialog({super.key, required this.onWithDrawTap});
  final VoidCallback onWithDrawTap;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
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
              'Request Sent',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Status: Pending approval',
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            SizedBox(height: 24.h),
            Text(
              'You\'ll be invited to a real-life meetup\nbefore becoming a member.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            WithdrawButton(onPressed: onWithDrawTap),
          ],
        ),
      ),
    );
  }
}

class WithdrawButton extends StatelessWidget {
  final VoidCallback onPressed;

  const WithdrawButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF80D0FF), Color(0xFFC489FF)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(1.5.r),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.5.r),
            ),
          ),
          child: Text(
            'Withdraw Request',
            style: TextStyle(
              fontSize: 18.sp,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
