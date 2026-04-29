import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/community_controller.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/model/category.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';

class HomeCommunityFilter extends StatefulWidget {
  const HomeCommunityFilter({super.key});

  @override
  State<HomeCommunityFilter> createState() => _HomeCommunityFilterState();
}

class _HomeCommunityFilterState extends State<HomeCommunityFilter> {
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

  final CommunityController communityController = Get.put(
    CommunityController(),
  );

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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    Text(
                      distance < 1000
                          ? 'under: ${distance.round()} m'
                          : 'under: ${(distance / 1000).toStringAsFixed(1)} km',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                            color: Theme.of(context).dividerColor,
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
                                .withValues(alpha: 0.2),
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
                  children: [
                    Text(
                      '100 m',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                    Text(
                      '10 km',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Categories
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            Obx(() {
              return Column(
                children: communityController.categoryGroups.map((group) {
                  final isExpanded = communityController.expandedParents
                      .contains(group.parent);
                  final isSelected = communityController.isParentSelected(
                    group,
                  );
                  final isPartial = communityController
                      .isParentPartiallySelected(group);

                  return Column(
                    children: [
                      // Parent
                      GestureDetector(
                        onTap: () =>
                            communityController.toggleExpand(group.parent),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: newMethod(
                            isSelected,
                            isPartial,
                            group,
                            isExpanded,
                          ),
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
                                    final selected = communityController
                                        .selectedSubcategories
                                        .contains(sub);

                                    return GestureDetector(
                                      onTap: () => communityController
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
                                              : Theme.of(context).colorScheme.surfaceVariant,
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
                                                : Theme.of(context).colorScheme.onSurfaceVariant,
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
          ],
        ),
      ),
    );
  }

  Widget newMethod(
    bool isSelected,
    bool isPartial,
    CategoryGroup group,
    bool isExpanded,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            group.parent,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ],
    );
  }
}
