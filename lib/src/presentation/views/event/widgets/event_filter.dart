import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/src/presentation/views/common/custom_elevated_button.dart';

class EventFilterDialog extends StatefulWidget {
  const EventFilterDialog({super.key});

  @override
  State<EventFilterDialog> createState() => _EventFilterDialogState();
}

class _EventFilterDialogState extends State<EventFilterDialog> {
  // Events filters
  String selectedEventType = 'All Events';
  DateTime? selectedDate;
  String selectedLocation = 'Nearby';
  List<String> selectedEventCategories = [];

  final List<String> eventTypes = [
    // 'All Events',
    // 'Workshops',
    // 'Meetups',
    // 'Parties',
    // 'Concerts',
    "100 m",
    "200 m",
    "300 m",
    "400 m",
    "1 km",
  ];
  RangeValues ageRange = const RangeValues(100, 1000);
  final List<String> eventCategories = [
    'Music',
    'Sports',
    'Food',
    'Art',
    'Tech',
    'Wellness',
  ];

  void toggleEventCategory(String category) {
    setState(() {
      if (selectedEventCategories.contains(category)) {
        selectedEventCategories.remove(category);
      } else {
        selectedEventCategories.add(category);
      }
    });
  }

  void clearFilters() {
    setState(() {
      selectedEventType = 'All Events';
      selectedDate = null;
      selectedLocation = 'Nearby';
      selectedEventCategories.clear();
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
                    'Event Filter',
                    style: TextStyle(
                      fontSize: 24.sp,
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

              // Events Content
              _buildEventsContent(),

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

  // Events Tab Content
  Widget _buildEventsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Range',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        _buildAgeSlider(),
        // Column(
        //   children: eventTypes.map((type) {
        //     return _buildRadioOption(type, selectedEventType, (value) {
        //       setState(() => selectedEventType = value);
        //     });
        //   }).toList(),
        // ),
        const SizedBox(height: 12),

        Text(
          'Categories',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: eventCategories.map((category) {
            final isSelected = selectedEventCategories.contains(category);
            return GestureDetector(
              onTap: () => toggleEventCategory(category),
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
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
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

  Widget _buildAgeSlider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalRange = 1000 - 100;
        final selectedStart = (ageRange.start - 18) / totalRange;
        final selectedEnd = (ageRange.end - 18) / totalRange;

        return Column(
          children: [
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Positioned(
                  left: constraints.maxWidth * selectedStart,
                  child: Container(
                    width: constraints.maxWidth * (selectedEnd - selectedStart),
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradientRotated,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: const Color(0xFF9C27B0),
                    overlayColor: const Color(
                      0xFF9C27B0,
                    ).withValues(alpha: 0.2),
                    trackHeight: 4,
                    rangeThumbShape: const RoundRangeSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                    overlappingShapeStrokeColor: Colors.white,
                  ),
                  child: RangeSlider(
                    values: ageRange,
                    min: 100,
                    max: 1000,
                    divisions: 47,
                    onChanged: (values) {
                      setState(() => ageRange = values);
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${ageRange.start.round()} m',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${ageRange.end.round()} m',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
