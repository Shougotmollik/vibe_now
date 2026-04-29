import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key, this.onFilterTap, required this.hintText});
  final VoidCallback? onFilterTap;
  final String hintText;
  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return Container(
      height: 38.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            suffixIcon: GestureDetector(
              onTap: onFilterTap,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Assets.icons.filter.svg(
                  width: 12.w,
                  height: 12.h,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
