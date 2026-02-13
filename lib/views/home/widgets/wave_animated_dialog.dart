import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';

class WaveAnimatedDialog extends StatefulWidget {
  final String content;
  const WaveAnimatedDialog({super.key, required this.content});

  @override
  State<WaveAnimatedDialog> createState() => _WaveAnimatedDialogState();
}

class _WaveAnimatedDialogState extends State<WaveAnimatedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Fade animation
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Slide animation (slightly up from bottom)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // start slightly below
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Scale animation for subtle pop effect
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Animate in
    _controller.forward();

    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.reverse().then((_) => Navigator.of(context).pop());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 300.w,
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: AppColors.backgroundVariant,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      "assets/lottie/Hello Lottie.json",
                      width: 140.w,
                      height: 140.h,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      widget.content,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff555555),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
