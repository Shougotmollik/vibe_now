import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/helper/helper.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';

class CreateVibeScreen extends StatefulWidget {
  const CreateVibeScreen({super.key});

  @override
  State<CreateVibeScreen> createState() => _CreateVibeScreenState();
}

class _CreateVibeScreenState extends State<CreateVibeScreen> {
  final TextEditingController _titleController = TextEditingController();

  File? _selectedImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // CustomAppBar(title: "Create Vibe", canBack: false),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  spacing: 16.h,
                  children: [
                    _buildVibeHeaderSection(),

                    _buildImageUploadSection(),

                    _buildVibeTitle(),

                    _buildInfoCard(
                      icons: Assets.icons.calenderHistory,
                      title: "Active for 4 hours",
                      subtitle:
                          "Your vibe will automatically expire after hours. You can end it anytime.",
                    ),

                    _buildInfoCard(
                      icons: Assets.icons.lock,
                      title: "Privacy First",
                      subtitle:
                          "Your exact location is only shared with people you wave to and accept",
                    ),
                    _buildActionButtons(),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,

              borderRadius: BorderRadius.circular(30),
            ),
            child: ElevatedButton(
              onPressed: () {
                AppSnackbar.show(
                  message: 'Your vibe has been created',
                  type: SnackType.success,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Create',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required SvgGenImage icons,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Color(0xffF7F9FB),
        borderRadius: BorderRadius.circular(12.r),
      ),

      child: Column(
        spacing: 8.h,
        children: [
          Row(
            spacing: 5.w,
            children: [
              icons.svg(width: 24.w, height: 24.h),

              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff484848),
                ),
              ),
            ],
          ),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xff484848),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVibeTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vibe Title',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'e.g. Sunday coffee vibes — who’s in? 🌞',
            hintStyle: TextStyle(color: Color(0xff717182), fontSize: 14.sp),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return GestureDetector(
      onTap: () async {
        final File? image = await CustomImagePicker.pickImage();
        if (image != null) {
          setState(() {
            _selectedImage = image;
          });
        }
      },
      child: Container(
        width: double.infinity,
        height: 172.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0XFFEFF6FF), Color(0XFFECFEFF)],
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: _selectedImage != null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8.w,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(24, 23, 24, 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16.w,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.icons.uploadImage.svg(width: 40.w, height: 40.h),
                    SizedBox(height: 8.h),

                    Text(
                      "Upload Cover Image",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0XFF364153),
                      ),
                    ),
                    Text(
                      "Click to browse",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0XFF4A5565),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildVibeHeaderSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0XFFEFF6FF), Color(0XFFECFEFF)],
        ),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        spacing: 8.h,
        children: [
          Row(
            spacing: 12.w,
            children: [
              Assets.icons.creationStar.svg(
                width: 24.w,
                height: 24.h,
                color: Color(0xff0A0A0A),
              ),
              Text(
                "Create Vibe",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff0A0A0A),
                ),
              ),
            ],
          ),
          Text(
            "Real-life first connections start here. Find real people in real places.",
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xff364153),
            ),
          ),
        ],
      ),
    );
  }
}
