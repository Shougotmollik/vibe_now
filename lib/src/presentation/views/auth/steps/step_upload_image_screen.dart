import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/step_page.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/step_title.dart';

class StepUploadImageScreen extends StatefulWidget {
  final int step;
  const StepUploadImageScreen({this.step = 1, super.key});

  @override
  State<StepUploadImageScreen> createState() => _StepUploadImageScreenState();
}

class _StepUploadImageScreenState extends State<StepUploadImageScreen> {
  @override
  Widget build(BuildContext context) {
    return StepPage(
      currentStep: widget.step,
      footer: PrimaryButton.text(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (_, __, ___) =>
                  StepUploadImageScreen(step: widget.step + 1),
            ),
          );
        },
        text: 'Continue',
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 32.h),

            const StepTitle(
              title: 'Upload Photos',
              subtitle:
                  "You're almost there! Add at least one pictures. Also can upload picture later.",
            ),

            SizedBox(height: 32.h),
            DottedBorder(
              options: RoundedRectDottedBorderOptions(
                radius: Radius.circular(16.r),
                color: Color(0XFFDBDBDB),
                strokeWidth: 4.w,
                dashPattern: [8, 4], // [dash length, gap length]
                borderPadding: EdgeInsets.zero,
                padding: EdgeInsets.zero,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: Color(0XFFffffff),
                ),
                width: 102.w,
                height: 124.h,
                child: Center(
                  child: Assets.icons.imagePicker.svg(
                    width: 32.w,
                    height: 32.h,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30.h),

            Row(
              spacing: 12.w,
              children: List.generate(
                3,
                (index) => _buildImageBox(context, hasImage: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBox(
    BuildContext context, {
    required bool hasImage,
    File? imageFile,
    VoidCallback? onDelete,
  }) {
    final double boxWidth = 100.w;
    final double boxHeight = 130.h;

    if (hasImage) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: boxWidth,
            height: boxHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              image: DecorationImage(
                image: FileImage(imageFile!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(3),
                child: const Icon(Icons.close, size: 18, color: Colors.black54),
              ),
            ),
          ),
        ],
      );
    } else {
      return DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: Radius.circular(16.r),
          color: Color(0XFFDBDBDB),
          strokeWidth: 4.w,
          dashPattern: [8, 4], // [dash length, gap length]
          borderPadding: EdgeInsets.zero,
          padding: EdgeInsets.zero,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: Color(0XFFffffff),
          ),
          width: 102.w,
          height: 124.h,
          child: Center(
            child: Assets.icons.imagePicker.svg(width: 32.w, height: 32.h),
          ),
        ),
      );
    }
  }
}
