import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/profile_controller.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/model/interest_model.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';

class HomeVibeFilter extends StatefulWidget {
  const HomeVibeFilter({super.key});

  @override
  State<HomeVibeFilter> createState() => _HomeVibeFilterState();
}

class _HomeVibeFilterState extends State<HomeVibeFilter> {
  // Filter states
  RangeValues ageRange = const RangeValues(18, 70);
  double distance = 100;
  String selectedDate = 'Today';
  List<String> selectedCategories = [];
  String selectedGender = 'Women';

  final ProfileController profileController = Get.put(ProfileController());

  // Options
  final List<String> lookingForOptions = [
    'Friendship',
    'Relationship',
    "I'm not sure yet",
  ];
  // void toggleCategory(String category) {
  //   setState(() {
  //     if (selectedCategories.contains(category)) {
  //       selectedCategories.remove(category);
  //     } else {
  //       selectedCategories.add(category);
  //     }
  //   });
  // }

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
            SizedBox(height: 16.h),

            // Distance Slider with gradient track
            _buildDistanceSection(),

            SizedBox(height: 16.h),

            _buildGenderSection(),
            SizedBox(height: 16.h),
            Text(
              'Age',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16.h),
            _buildAgeSlider(),
            SizedBox(height: 24.h),

            // Date Filter (Radio)
            _buildLookingForSection(),
            const SizedBox(height: 16),
            _buildInterestSection(context: context),
          ],
        ),
      ),
    );
  }

  Widget _buildLookingForSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Looking For',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Column(
          children: lookingForOptions.map((date) {
            return _buildRadioOption(date, selectedDate, (value) {
              setState(() {
                selectedDate = value;
              });
            });
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Column(
          children: [
            _buildRadioOption('Women', selectedGender, (value) {
              setState(() => selectedGender = value);
            }),
            _buildRadioOption('Men', selectedGender, (value) {
              setState(() => selectedGender = value);
            }),
            _buildRadioOption('Beyond Binary', selectedGender, (value) {
              setState(() => selectedGender = value);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildDistanceSection() {
    return Column(
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
                    onChanged: (value) => setState(() => distance = value),
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
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                      : Theme.of(context).dividerColor,
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
            Text(
              value,
              style: TextStyle(
                fontSize: 15.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeSlider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalRange = 100 - 14;
        final selectedStart = (ageRange.start - 14) / totalRange;
        final selectedEnd = (ageRange.end - 14) / totalRange;

        return Column(
          children: [
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
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
                    min: 14,
                    max: 100,
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
                  '${ageRange.start.round()}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${ageRange.end.round()}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildInterestSection({required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        Obx(() {
          return Column(
            children: profileController.interestGroups.map((group) {
              final isExpanded = profileController.expandedParents.contains(
                group.parent,
              );
              final isSelected = profileController.isParentSelected(group);

              final isPartial = profileController.isParentPartiallySelected(
                group,
              );

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  children: [
                    // Parent
                    GestureDetector(
                      onTap: () => profileController.toggleExpand(group.parent),
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
                                alignment: WrapAlignment.start,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ...group.children.map((sub) {
                                    final selected = profileController
                                        .selectedSubcategories
                                        .contains(sub.name);

                                    return GestureDetector(
                                      onTap: () =>
                                          profileController.toggleSubcategory(
                                            sub.name,
                                            group.parent,
                                          ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: selected
                                              ? AppColors.primaryGradientRotated
                                              : null,
                                          color: selected
                                              ? null
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.surfaceVariant,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          spacing: 4.w,
                                          children: [
                                            sub.icon.svg(
                                              height: 16.h,
                                              width: 16.h,
                                              color: selected
                                                  ? Colors.white
                                                  : Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                            ),
                                            Text(
                                              sub.name,
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: selected
                                                    ? Colors.white
                                                    : Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),

                    SizedBox(height: 12.h),
                  ],
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget newMethod(
    bool isSelected,
    bool isPartial,
    Interest group,
    bool isExpanded,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              group.parent,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}
