import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/helper/helper.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/common/interest_chip.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController bioController = TextEditingController();
  final TextEditingController nameController = TextEditingController(
    text: 'John Gomes',
  );
  final TextEditingController passwordController = TextEditingController(
    text: '********',
  );

  List<String> selectedInterests = [];
  File? _selectedImage;

  final List<Map<String, dynamic>> allInterests = [
    {"label": "Coffee", "icon": Assets.icons.coffee},
    {"label": "Music", "icon": Assets.icons.music},
    {"label": "Books", "icon": Assets.icons.book},
    {"label": "Gaming", "icon": Assets.icons.aiGame},
    {"label": "Calendar", "icon": Assets.icons.calender},
    {"label": "Travel", "icon": Assets.icons.book},
    {"label": "Fitness", "icon": Assets.icons.creationStar},
    {"label": "Cooking", "icon": Assets.icons.gift},
    {"label": "Art", "icon": Assets.icons.community},
    {"label": "Photography", "icon": Assets.icons.camera},
  ];

  @override
  void initState() {
    super.initState();
    bioController.text =
        "Coffee enthusiast. Music lover. Avid traveler. Foodie.";
    selectedInterests = ["Coffee", "Music"]; // Pre-selected interests
  }

  @override
  void dispose() {
    bioController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(title: AppLocalizations.of(context).translate('settings')),
              SizedBox(height: 20),
              _buildProfileSection(),
              SizedBox(height: 28.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('profileCompletion'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '60%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              _buildProgressIndicator(),
              SizedBox(height: 28.h),

              // Name
              _buildHeadingText(text: AppLocalizations.of(context).translate('name')),
              SizedBox(height: 12.h),
              _buildInputField(hint: 'John Gomes', controller: nameController),
              SizedBox(height: 28.h),

              // Bio
              _buildHeadingText(text: AppLocalizations.of(context).translate('bio')),
              SizedBox(height: 12.h),
              _buildBioField(),
              SizedBox(height: 28.h),

              // Password
              _buildHeadingText(text: AppLocalizations.of(context).translate('password')),
              SizedBox(height: 12.h),
              _buildInputField(
                hint: '********',
                controller: passwordController,
                obscureText: true,
              ),
              SizedBox(height: 28.h),

              // Interests
              _buildHeadingText(text: AppLocalizations.of(context).translate('selectUpTo5')),
              SizedBox(height: 16.h),
              _buildInterestSection(),
              SizedBox(height: 84.h),
              CustomElevatedButton(
                onTap: () {
                  AppSnackbar.show(
                    message: 'Profile updated successfully',
                    type: SnackType.success,
                  );
                },
                buttonText: AppLocalizations.of(context).translate('save'),
              ),
              SizedBox(height: 74.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeadingText({required String text}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildInputField({
    required String hint,
    TextEditingController? controller,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 12.h,
            horizontal: 16.w,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: TextFormField(
            controller: bioController,
            maxLines: 4,
            maxLength: 70,
            decoration: InputDecoration(
              counterText: "",
              hintText:
                  "Coffee enthusiast. Music lover. Avid traveler. Foodie.",
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 12.h,
                horizontal: 16.w,
              ),
              border: InputBorder.none,
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 4.h, right: 4.w),
          child: Text(
            "${bioController.text.length}/70",
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50.r),
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        width: 78.w,
                        height: 78.w,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
                        width: 78.w,
                        height: 78.w,
                        fit: BoxFit.cover,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    final pickedImage = CustomImagePicker.pickImage();
                    pickedImage.then((value) {
                      setState(() {
                        _selectedImage = value;
                      });
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Assets.icons.camera2.svg(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'John Gomes',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Assets.icons.coffeeColor.svg(height: 16.h),
              SizedBox(width: 4.w),
              Text(
                'Coffee enthusiast |',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(width: 8.w),
              Assets.icons.musicColor.svg(height: 16.h),
              SizedBox(width: 4.w),
              Text(
                'Music lover',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 4.h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(color: Theme.of(context).dividerColor),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestSection() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: allInterests.map((item) {
        final String label = item["label"];
        final icon = item["icon"];
        final isSelected = selectedInterests.contains(label);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedInterests.remove(label);
              } else {
                if (selectedInterests.length < 5) {
                  selectedInterests.add(label);
                } else {
                  AppSnackbar.show(
                    message: 'You can select a maximum of 5 interests',
                    type: SnackType.info,
                  );
                }
              }
            });
          },
          child: InterestChip(
            icon: icon,
            label: label,
            isSelected: !isSelected,
          ),
        );
      }).toList(),
    );
  }
}
