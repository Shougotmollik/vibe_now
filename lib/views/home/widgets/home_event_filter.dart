import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/event_controller.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/model/category.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';

class HomeEventFilter extends StatefulWidget {
  const HomeEventFilter({super.key});

  @override
  State<HomeEventFilter> createState() => _HomeEventFilterState();
}

class _HomeEventFilterState extends State<HomeEventFilter> {
  // Filter states
  double distance = 100;
  String selectedDate = 'All';
  List<String> selectedCategories = [];

  // Options
  final List<String> dateOptions = ['All', 'Today', 'This Week', 'This Month'];
  final List<String> categories = [
    'Music',
    'Sports',
    'Food',
    'Art',
    'Tech',
    'Wellness',
  ];

  final EventController eventController = Get.put(EventController());
  void toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  void clearFilters() {
    setState(() {
      distance = 100;
      selectedDate = 'Today';
      selectedCategories.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      // padding: EdgeInsets.all(24.w),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       'Event Filter',
            //       style: TextStyle(
            //         fontSize: 24.sp,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //     IconButton(
            //       icon: const Icon(Icons.close),
            //       onPressed: () => Navigator.of(context).pop(),
            //       padding: EdgeInsets.zero,
            //       constraints: const BoxConstraints(),
            //     ),
            //   ],
            // ),
            SizedBox(height: 16.h),

            // Distance Slider with gradient track
            Column(
              children: [
                Row(
                  spacing: 8.w,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Distance',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Text(
                      distance < 1000
                          ? 'under: ${distance.round()} m'
                          : 'under: ${(distance / 1000).toStringAsFixed(1)} km',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Show selected distance
                LayoutBuilder(
                  builder: (context, constraints) {
                    final trackWidth = constraints.maxWidth;
                    final thumbPercent = (distance - 100) / (10000 - 100);

                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Full track (gray)
                        Container(
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Gradient track up to thumb
                        Container(
                          width: trackWidth * thumbPercent,
                          height: 4.h,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradientRotated,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Slider itself
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: Colors.transparent,
                            inactiveTrackColor: Colors.transparent,
                            thumbColor: AppColors.primaryGradient.colors.first,
                            overlayColor: AppColors.primaryGradient.colors.first
                                .withOpacity(0.2),
                            trackHeight: 4.h,
                            rangeThumbShape: const RoundRangeSliderThumbShape(
                              enabledThumbRadius: 10,
                            ),
                          ),
                          child: Slider(
                            min: 100,
                            max: 10000,
                            divisions: 49,
                            value: distance,
                            label: distance < 1000
                                ? '${distance.round()} m'
                                : '${(distance / 1000).toStringAsFixed(1)} km',
                            onChanged: (value) =>
                                setState(() => distance = value),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [Text('100 m'), Text('10 km')],
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Categories
            Text(
              'Categories',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Obx(() {
              return Column(
                children: eventController.categoryGroups.map((group) {
                  final isExpanded = eventController.expandedParents.contains(
                    group.parent,
                  );
                  final isSelected = eventController.isParentSelected(group);
                  final isPartial = eventController.isParentPartiallySelected(
                    group,
                  );

                  return Column(
                    children: [
                      // Parent
                      GestureDetector(
                        onTap: () => eventController.toggleExpand(group.parent),
                        child: newMethod(
                          isSelected,
                          isPartial,
                          group,
                          isExpanded,
                        ),
                      ),

                      // Subcategories
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: isExpanded
                              ? Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.start,

                                  children: group.children.map((sub) {
                                    final selected = eventController
                                        .selectedSubcategories
                                        .contains(sub);

                                    return GestureDetector(
                                      onTap: () => eventController
                                          .toggleSubcategory(sub, group.parent),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14.w,
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: selected
                                              ? AppColors.primaryGradientRotated
                                              : null,
                                          color: selected
                                              ? null
                                              : Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          sub,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: selected
                                                ? Colors.white
                                                : Colors.grey[800],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),

                      SizedBox(height: 12.h),
                    ],
                  );
                }).toList(),
              );
            }),
            SizedBox(height: 16.h),

            // Date Filter (Radio)
            Text(
              'Date',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Column(
              children: dateOptions.map((date) {
                return _buildRadioOption(date, selectedDate, (value) {
                  setState(() {
                    selectedDate = value;
                  });
                });
              }).toList(),
            ),

            // SizedBox(height: 32.h),

            // // Action Buttons
            // SizedBox(
            //   height: 44.h,
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: CustomElevatedButton(
            //           btnColor: Colors.grey[200],
            //           textColor: Colors.black87,
            //           onTap: clearFilters,
            //           buttonText: 'Clear',
            //         ),
            //       ),
            //       SizedBox(width: 16.w),
            //       Expanded(
            //         child: PrimaryButton.text(
            //           text: 'Apply',
            //           onPressed: () {
            //             Navigator.of(context).pop({
            //               'distance': distance,
            //               'date': selectedDate,
            //               'categories': selectedCategories,
            //             });
            //           },
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Container newMethod(
    bool isSelected,
    bool isPartial,
    CategoryGroup group,
    bool isExpanded,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: isSelected ? AppColors.primaryGradientRotated : null,
        color: isSelected
            ? null
            : isPartial
            ? Colors.transparent
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              group.parent,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          ),
        ],
      ),
    );
  }

  // Radio Option Widget
  Widget _buildRadioOption(
    String value,
    String groupValue,
    Function(String) onChanged,
  ) {
    final bool isSelected = value == groupValue;
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
                  color: isSelected
                      ? const Color(0xFFC2E3FF)
                      : const Color(0xFFE0E0E0),
                  width: 2,
                ),
              ),
              child: isSelected
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
