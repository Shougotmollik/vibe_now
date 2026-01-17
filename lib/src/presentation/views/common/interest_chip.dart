import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class InterestChip extends StatelessWidget {
  const InterestChip({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  final SvgGenImage icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: !isSelected ? Colors.grey.shade300 : null,
        gradient: isSelected ? AppColors.primaryGradientRotated : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon.svg(
            height: 16.h,
            width: 16.h,
            color: !isSelected ? Colors.black : Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: !isSelected ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
