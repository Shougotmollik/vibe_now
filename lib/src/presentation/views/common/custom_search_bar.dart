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
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            hintText: hintText,
            contentPadding: EdgeInsets.all(6.w),
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,

            suffixIcon: GestureDetector(
              onTap: onFilterTap,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: SizedBox(
                  child: Assets.icons.filter.svg(width: 12.w, height: 12.h),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
