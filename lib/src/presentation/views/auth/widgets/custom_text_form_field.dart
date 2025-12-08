import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFormField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  const CustomTextFormField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(label!, style: Theme.of(context).textTheme.bodyLarge),
        if (label != null) SizedBox(height: 8.h),
        TextFormField(
          controller: controller,

          decoration: InputDecoration(
            // contentPadding: EdgeInsets.only(top: 12, bottom: 12),
            contentPadding: EdgeInsets.fromLTRB(12, 20, 12, 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide.none,
            ),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.black38, fontSize: 15.sp),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
