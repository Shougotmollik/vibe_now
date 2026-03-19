import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/helper/helper.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/utils.dart' as utils;
import 'package:vibe_now/views/common/cancel_button.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/vibe/vibe_animated_dialog.dart';

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
                    VibeDurationSelector(),
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
          child: CancelButton(
            btnText: "Cancel",
            onTap: () => Navigator.of(context).maybePop(),
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
                // Navigator.pop(context);
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return Center(
                      child: Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        child: VibeAnimatedDialog(
                          content: "Your Vibe is now live.",
                        ),
                      ),
                    );
                  },
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
        border: Border.all(color: Colors.grey.shade300, width: 1.w),
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
        utils.showImagePickerOptions(context, (imageSource) async {
          final image = await utils.pickSingleImage(
            context: context,
            source: imageSource,
          );

          if (image != null) {
            setState(() {
              _selectedImage = image;
            });
          } else {
            AppSnackbar.show(message: 'Failed to pick image');
          }
        });
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

class VibeDurationSelector extends StatefulWidget {
  const VibeDurationSelector({super.key});

  @override
  State<VibeDurationSelector> createState() => _VibeDurationSelectorState();
}

class _VibeDurationSelectorState extends State<VibeDurationSelector> {
  int _selectedIndex = 2;

  final List<String> _durations = ['30m', '1hr', '2hrs', '4hrs'];

  // Colors
  // static const _activeGradientStart = Color(0xFF818CF8);
  // static const _activeGradientEnd = Color(0xFFA855F7);
  static const _inactiveColor = Color(0xFFF3F4F6);
  static const _connectorColor = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Color(0xff_F7F9FB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.icons.calenderHistory.svg(width: 24.w, height: 24.h),
              const SizedBox(width: 8),
              const Text(
                'Vibe Duration',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: FixedTimeline.tileBuilder(
              theme: TimelineThemeData(
                direction: Axis.horizontal,
                connectorTheme: const ConnectorThemeData(
                  color: _connectorColor,
                  thickness: 2,
                ),
              ),
              builder: TimelineTileBuilder.connected(
                itemCount: _durations.length,
                connectionDirection: ConnectionDirection.before,
                connectorBuilder: (context, index, type) => const SizedBox(
                  width: 8,
                  child: SolidLineConnector(
                    color: _connectorColor,
                    thickness: 2,
                  ),
                ),

                indicatorBuilder: (context, index) {
                  final isSelected = index == _selectedIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      width: 60.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppColors.primaryGradientRotated
                            : null,
                        color: isSelected ? null : _inactiveColor,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (Colors.grey.shade300),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6B7280),
                          letterSpacing: -0.1,
                        ),
                        child: Text(_durations[index]),
                      ),
                    ),
                  );
                },
                contentsBuilder: (_, __) => const SizedBox.shrink(),
                oppositeContentsBuilder: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
