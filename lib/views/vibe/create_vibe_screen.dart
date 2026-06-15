import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/state_manager.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:vibe_now/controller/vibe_controller.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/helper/helper.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/utils.dart' as utils;
import 'package:vibe_now/views/common/cancel_button.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/vibe/vibe_animated_dialog.dart';

class CreateVibeScreen extends StatefulWidget {
  const CreateVibeScreen({super.key});

  @override
  State<CreateVibeScreen> createState() => _CreateVibeScreenState();
}

class _CreateVibeScreenState extends State<CreateVibeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final VibeController controller = Get.find<VibeController>();
  String _selectedDuration = '2h';

  File? _selectedImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  spacing: 16.h,
                  children: [
                    _buildVibeHeaderSection(),

                    _buildImageUploadSection(),

                    _buildVibeTitle(),
                    VibeDurationSelector(
                      onDurationChanged: (duration) {
                        setState(() {
                          _selectedDuration = duration;
                        });
                      },
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
          child: CustomElevatedButton(
            height: 55.h,
            onTap: () => Navigator.of(context).maybePop(),
            buttonText: "Cancel",
            textColor: Theme.of(context).colorScheme.onSurface,
            btnColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 55.h,
            child: Obx(
              () => PrimaryButton.text(
                onPressed: controller.isLoading.value
                    ? () {}
                    : () async {
                        if (_selectedImage == null) {
                          AppSnackbar.show(
                            message: 'Please select cover image',
                          );
                          return;
                        }

                        if (_titleController.text.trim().isEmpty) {
                          AppSnackbar.show(message: 'Please enter vibe title');
                          return;
                        }
                        final success = await controller.createVibe(
                          coverImage: _selectedImage!,
                          title: _titleController.text,
                          duration: _selectedDuration,
                        );
                        if (success) {
                          await showDialog(
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
                          Navigator.of(context).maybePop();
                        }
                      },
                text: "Create",
                radius: 30.r,
                isLoading: controller.isLoading.value,
              ),
            ),
          ),
        ),
        // Expanded(
        //   child: Container(
        //     decoration: BoxDecoration(
        //       gradient: AppColors.primaryGradient,

        //       borderRadius: BorderRadius.circular(30),
        //     ),
        //     child: ElevatedButton(
        //       onPressed: () {
        //         // Navigator.pop(context);
        //         showDialog(
        //           context: context,
        //           barrierDismissible: true,
        //           builder: (context) {
        //             return Center(
        //               child: Dialog(
        //                 shape: RoundedRectangleBorder(
        //                   borderRadius: BorderRadius.circular(20.r),
        //                 ),
        //                 elevation: 0,
        //                 backgroundColor: Colors.transparent,
        //                 child: VibeAnimatedDialog(
        //                   content: "Your Vibe is now live.",
        //                 ),
        //               ),
        //             );
        //           },
        //         );
        //       },
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Colors.transparent,
        //         shadowColor: Colors.transparent,
        //         padding: const EdgeInsets.symmetric(vertical: 16),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(30),
        //         ),
        //       ),
        //       child: const Text(
        //         'Create',
        //         style: TextStyle(
        //           color: Colors.white,
        //           fontSize: 15,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          width: 1.w,
        ),
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        Text(
          'Vibe Title',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14.sp,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Sunday coffee vibes — who’s in? 🌞',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14.sp,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
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
            colors: [
              Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.1),
              Theme.of(
                context,
              ).colorScheme.secondaryContainer.withValues(alpha: 0.1),
            ],
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
                          color: Colors.black.withValues(alpha: 0.3),
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
                    Assets.icons.uploadImage.svg(
                      width: 40.w,
                      height: 40.h,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    Text(
                      "Upload Cover Image",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      "Click to browse",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          colors: [
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.1),
            Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: 0.1),
          ],
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
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              Text(
                "Create Vibe",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Text(
            "Real-life first connections start here. Find real people in real places.",
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class VibeDurationSelector extends StatefulWidget {
  const VibeDurationSelector({super.key, required this.onDurationChanged});

  final Function(String) onDurationChanged;

  @override
  State<VibeDurationSelector> createState() => _VibeDurationSelectorState();
}

class _VibeDurationSelectorState extends State<VibeDurationSelector> {
  int _selectedIndex = 2;

  final List<String> _durations = ['30m', '1h', '2h', '4h'];

  @override
  void initState() {
    super.initState();
    // Notify initial duration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDurationChanged(_durations[_selectedIndex]);
    });
  }

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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          width: 1.w,
        ),
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
              Text(
                'Vibe Duration',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
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
                  connectorBuilder: (context, index, type) => SizedBox(
                    width: 8,
                    child: SolidLineConnector(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      thickness: 2,
                    ),
                  ),

                  indicatorBuilder: (context, index) {
                    final isSelected = index == _selectedIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedIndex = index);
                        widget.onDurationChanged(_durations[index]);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                        width: 60.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? AppColors.primaryGradientRotated
                              : null,
                          color: isSelected
                              ? null
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Theme.of(context).colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.4),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
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
          ),
        ],
      ),
    );
  }
}
