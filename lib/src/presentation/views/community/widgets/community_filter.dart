import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/src/presentation/views/common/custom_elevated_button.dart';

class CommunityFilterDialog extends StatefulWidget {
  const CommunityFilterDialog({super.key});

  @override
  State<CommunityFilterDialog> createState() => _CommunityFilterDialogState();
}

class _CommunityFilterDialogState extends State<CommunityFilterDialog> {
  // Community filters
  String selectedCommunitySize = 'Any Size';
  List<String> selectedCommunityTypes = [];
  bool onlineOnly = false;

  final List<String> communitySizes = [
    'Any Size',
    'Small (< 50)',
    'Medium (50-200)',
    'Large (200+)',
  ];

  final List<String> communityTypes = [
    'Book Club',
    'Fitness Group',
    'Professional',
    'Hobby',
    'Support Group',
    "Wellness",
    "Music",
    "Fitness",
    "Food",
    "Movies",
    "Travel",
  ];

  void toggleCommunityType(String type) {
    setState(() {
      if (selectedCommunityTypes.contains(type)) {
        selectedCommunityTypes.remove(type);
      } else {
        selectedCommunityTypes.add(type);
      }
    });
  }

  void clearFilters() {
    setState(() {
      selectedCommunitySize = 'Any Size';
      selectedCommunityTypes.clear();
      onlineOnly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Community Filter',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // Tab Content
              _buildCommunityContent(),

              SizedBox(height: 32.h),

              // Action Buttons
              SizedBox(
                height: 44.h,
                child: Row(
                  spacing: 18.w,
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        btnColor: Colors.grey[200],
                        textColor: Colors.black87,

                        onTap: clearFilters,
                        buttonText: 'Clear',
                      ),
                    ),

                    Expanded(
                      child: PrimaryButton.text(
                        text: 'Apply',
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Community Tab Content
  Widget _buildCommunityContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Community Size',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.h),
        Column(
          children: communitySizes.map((size) {
            return _buildRadioOption(size, selectedCommunitySize, (value) {
              setState(() => selectedCommunitySize = value);
            });
          }).toList(),
        ),
        SizedBox(height: 24.h),
        Text(
          'Community categories',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: communityTypes.map((type) {
            final isSelected = selectedCommunityTypes.contains(type);
            return GestureDetector(
              onTap: () => toggleCommunityType(type),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? AppColors.primaryGradientRotated
                      : null,
                  color: isSelected ? null : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRadioOption(
    String value,
    String groupValue,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: groupValue == value
                      ? const Color(0xFFC2E3FF)
                      : const Color(0xFFE0E0E0),
                  width: 2,
                ),
              ),
              child: groupValue == value
                  ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.h,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(value, style: TextStyle(fontSize: 15.sp)),
          ],
        ),
      ),
    );
  }
}
