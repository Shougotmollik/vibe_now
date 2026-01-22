import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/src/presentation/views/common/custom_elevated_button.dart';

class HomeCommunityFilter extends StatefulWidget {
  const HomeCommunityFilter({super.key});

  @override
  State<HomeCommunityFilter> createState() => _HomeCommunityFilterState();
}

class _HomeCommunityFilterState extends State<HomeCommunityFilter> {
  // Filter states
  double distance = 100;
  String selectedDate = 'Today';
  List<String> selectedCategories = [];

  // Options
  final List<String> dateOptions = ['Today', 'This Week', 'This Month'];
  final List<String> categories = [
    'Music',
    'Sports',
    'Food',
    'Art',
    'Tech',
    'Wellness',
  ];

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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
                final isSelected = selectedCategories.contains(category);
                return GestureDetector(
                  onTap: () => toggleCategory(category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
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
        ),
      ),
    );
  }
}
