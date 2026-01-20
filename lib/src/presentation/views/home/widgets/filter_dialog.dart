import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/src/presentation/views/common/custom_elevated_button.dart';
import 'package:vibe_now/src/presentation/views/event/widgets/event_filter.dart';
import 'package:vibe_now/src/presentation/views/home/widgets/home_community_filter.dart';
import 'package:vibe_now/src/presentation/views/home/widgets/home_event_filter.dart';
import 'package:vibe_now/src/presentation/views/home/widgets/home_vibe_filter.dart';

class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String selectedTab = 'Vibe';

  // Friendship filters
  String selectedGender = 'Women';
  RangeValues ageRange = const RangeValues(18, 35);
  List<String> selectedInterests = ['Social'];

  // Events filters
  String selectedEventType = 'All Events';
  DateTime? selectedDate;
  String selectedLocation = 'Nearby';
  List<String> selectedEventCategories = [];

  // Community filters
  String selectedCommunitySize = 'Any Size';
  List<String> selectedCommunityTypes = [];
  bool onlineOnly = false;

  final List<String> tabs = ['Vibe', 'Events', 'Community'];

  final List<String> interests = [
    'Social',
    'Music',
    'Wellness',
    'Sports',
    'Learning',
    'Food',
    'Art',
    'Tech',
    'Gaming',
  ];

  final List<String> eventTypes = [
    'All Events',
    'Workshops',
    'Meetups',
    'Parties',
    'Concerts',
  ];

  final List<String> eventCategories = [
    'Music',
    'Sports',
    'Food',
    'Art',
    'Tech',
    'Wellness',
  ];

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
  ];

  void toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else {
        selectedInterests.add(interest);
      }
    });
  }

  void toggleEventCategory(String category) {
    setState(() {
      if (selectedEventCategories.contains(category)) {
        selectedEventCategories.remove(category);
      } else {
        selectedEventCategories.add(category);
      }
    });
  }

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
      if (selectedTab == 'Friendship') {
        selectedGender = 'Women';
        ageRange = const RangeValues(18, 35);
        selectedInterests.clear();
      } else if (selectedTab == 'Events') {
        selectedEventType = 'All Events';
        selectedDate = null;
        selectedLocation = 'Nearby';
        selectedEventCategories.clear();
      } else if (selectedTab == 'Community') {
        selectedCommunitySize = 'Any Size';
        selectedCommunityTypes.clear();
        onlineOnly = false;
      }
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
                    'Filter',
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
              SizedBox(height: 24.h),

              // Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: tabs.map((tab) {
                    final isSelected = selectedTab == tab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedTab = tab),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.w,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? AppColors.primaryGradientRotated
                                : null,
                            color: isSelected ? null : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tab,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 24.h),

              // Tab Content
              if (selectedTab == 'Vibe') HomeVibeFilter(),
              if (selectedTab == 'Events') HomeEventFilter(),
              if (selectedTab == 'Community') HomeCommunityFilter(),

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

  // Friendship Tab Content
  Widget _buildFriendshipContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.h),
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
        SizedBox(height: 24.h),

        Text(
          'Age',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.h),
        _buildAgeSlider(),
        SizedBox(height: 24.h),

        Text(
          'Interests',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.sp),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: interests.map((interest) {
            final isSelected = selectedInterests.contains(interest);
            return GestureDetector(
              onTap: () => toggleInterest(interest),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? AppColors.primaryGradientRotated
                      : null,
                  color: isSelected ? null : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  interest,
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

  // Events Tab Content
  Widget _buildEventsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Type',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Column(
          children: eventTypes.map((type) {
            return _buildRadioOption(type, selectedEventType, (value) {
              setState(() => selectedEventType = value);
            });
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Text(
        //   'Location',
        //   style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        // ),
        // const SizedBox(height: 12),
        // Column(
        //   children: [
        //     _buildRadioOption('Nearby', selectedLocation, (value) {
        //       setState(() => selectedLocation = value);
        //     }),
        //     _buildRadioOption('Within 5km', selectedLocation, (value) {
        //       setState(() => selectedLocation = value);
        //     }),
        //     _buildRadioOption('Within 10km', selectedLocation, (value) {
        //       setState(() => selectedLocation = value);
        //     }),
        //     _buildRadioOption('Anywhere', selectedLocation, (value) {
        //       setState(() => selectedLocation = value);
        //     }),
        //   ],
        // ),
        // const SizedBox(height: 24),
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
          'Community Type',
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

  Widget _buildAgeSlider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalRange = 65 - 18;
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
                    min: 18,
                    max: 65,
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${ageRange.end.round()}',
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
