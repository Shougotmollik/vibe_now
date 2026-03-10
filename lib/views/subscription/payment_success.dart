import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';

class PaymentSuccess extends StatefulWidget {
  const PaymentSuccess({super.key});

  @override
  State<PaymentSuccess> createState() => _PaymentSuccessState();
}

class _PaymentSuccessState extends State<PaymentSuccess>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1)),
    );

    slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1)),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Spacer(),

          /// Animated Success Icon
          ScaleTransition(
            scale: scaleAnimation,
            child: Container(
              height: 100.w,
              width: 100.w,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: SvgPicture.asset(
                "assets/icons/succes.svg",
                height: 80.w,
                width: 80.w,
              ),
            ),
          ),

          SizedBox(height: 30.h),

          /// Animated Text
          FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Text(
                  "Your payment has been successfully done",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff202020),
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          /// Button
          FadeTransition(
            opacity: fadeAnimation,
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: PrimaryButton.text(
                onPressed: () {
                  context.pushNamed(RouteNames.mainNavBar);
                },
                text: "Home",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
