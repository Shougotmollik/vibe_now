import 'package:flutter/material.dart';
import 'package:vibe_now/views/auth/widgets/animated_value.dart';

class AnimatedFadeUpText extends StatelessWidget {
  final int delay;
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  const AnimatedFadeUpText({
    super.key,
    required this.delay,
    required this.text,
    required this.fontSize,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedValue(
      option: AnimateOption(delay: delay, duration: 700, begin: 1, end: -1),
      builder: (context, value) {
        final opacityValue = remap(value: value, toBegin: 0, toEnd: 1);
        final translateValue = remap(value: value, toBegin: 0, toEnd: -100);

        return Opacity(
          opacity: opacityValue,
          child: Transform.translate(
            offset: Offset(0, translateValue),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
            ),
          ),
        );
      },
    );
  }
}
