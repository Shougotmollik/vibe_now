import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StepTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const StepTitle({required this.title, required this.subtitle, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 24.h),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12.sp,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
