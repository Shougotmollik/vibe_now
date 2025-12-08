import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/animated_value.dart';

class AnimatedBall extends StatelessWidget {
  final int delay;
  final double begin;
  final Gradient gradient;
  final AlignmentType alignType;

  const AnimatedBall({
    super.key,
    required this.delay,
    required this.begin,
    required this.gradient,
    required this.alignType,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedValue(
      option: AnimateOption(delay: delay, duration: 700, begin: begin, end: 0),
      builder: (context, value) {
        switch (alignType) {
          case AlignmentType.bottom:
            return Positioned(
              bottom: value * -1,
              left: 0,
              right: 0,
              child: GuffBoll(gradient: gradient as LinearGradient),
            );
          case AlignmentType.left:
            return Positioned(
              top: value + 12.h,
              bottom: 0,
              left: 0,
              child: GuffBoll(gradient: gradient as LinearGradient),
            );
          case AlignmentType.right:
            return Positioned(
              top: value + 12.h,
              bottom: 0,
              right: 0,
              child: GuffBoll(gradient: gradient as LinearGradient),
            );
          case AlignmentType.top:
            return Positioned(
              top: value,
              left: 0,
              right: 0,
              child: GuffBoll(gradient: gradient as LinearGradient),
            );
        }
      },
    );
  }
}

enum AlignmentType { top, bottom, left, right }

class GuffBoll extends StatelessWidget {
  final LinearGradient gradient;
  const GuffBoll({required this.gradient, super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.9,
      child: Container(
        height: 38.w,
        width: 38.w,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),
      ),
    );
  }
}
