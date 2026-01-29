import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/auth/steps/step_location_screen.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/step_page.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/step_title.dart';
import 'package:vibe_now/utils.dart' as utils;

class StepUploadImageScreen extends StatefulWidget {
  final int step;
  const StepUploadImageScreen({this.step = 1, super.key});

  @override
  State<StepUploadImageScreen> createState() => _StepUploadImageScreenState();
}

class _StepUploadImageScreenState extends State<StepUploadImageScreen> {
  final List<File> _selectedImages = [];
  final int _maxImages = 4;

  Future<void> _pickImage() async {
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum $_maxImages images allowed')),
      );
      return;
    }

    try {
      utils.showImagePickerOptions(context, (imageSource) async {
        final file = await utils.pickSingleImage(
          context: context,
          source: imageSource,
        );

        if (file != null) {
          setState(() {
            _selectedImages.add(file);
          });
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _deleteImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StepPage(
        currentStep: widget.step,
        footer: PrimaryButton.text(
          onPressed: () {
            if (_selectedImages.isNotEmpty) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  pageBuilder: (_, __, ___) =>
                      StepLocationScreen(step: widget.step + 1),
                ),
              );
            } else {
              AppSnackbar.show(
                message: 'Please upload at least one image to continue',
                type: SnackType.info,
              );
            }
          },
          text: 'Continue',
          isEnabled: _selectedImages.isNotEmpty,
        ),
        isSkippable: false,
        onSkip: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (_, __, ___) =>
                  StepLocationScreen(step: widget.step + 1),
            ),
          );
        },

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

              // Main image picker (first image)
              GestureDetector(
                onTap: _pickImage,
                child: _selectedImages.isNotEmpty
                    ? _buildImageBox(
                        context,
                        hasImage: true,
                        imageFile: _selectedImages[0],
                        onDelete: () => _deleteImage(0),
                      )
                    : DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: Radius.circular(16.r),
                          color: Color(0XFFDBDBDB),
                          strokeWidth: 4.w,
                          dashPattern: [8, 4],
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
              ),

              SizedBox(height: 30.h),

              // Additional image pickers (3 more slots)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12.w,
                children: List.generate(3, (index) {
                  final imageIndex = index + 1;
                  final hasImage = imageIndex < _selectedImages.length;

                  return GestureDetector(
                    onTap: hasImage ? null : _pickImage,
                    child: _buildImageBox(
                      context,
                      hasImage: hasImage,
                      imageFile: hasImage ? _selectedImages[imageIndex] : null,
                      onDelete: hasImage
                          ? () => _deleteImage(imageIndex)
                          : null,
                    ),
                  );
                }),
              ),
            ],
          ),
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
          dashPattern: [8, 4],
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
