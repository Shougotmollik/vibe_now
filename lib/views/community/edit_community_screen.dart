import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/community_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/helper/helper.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/category.dart';
import 'package:vibe_now/model/community.dart';
import 'package:vibe_now/utils.dart' as utils;
import 'package:vibe_now/views/common/confirmation_dialog.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_time_picker.dart';
import 'package:vibe_now/views/common/custom_date_picker.dart';
import 'package:vibe_now/views/community/widgets/community_animated_dialog.dart';
import 'package:vibe_now/views/community/widgets/edit_community_action.dart';
import 'package:vibe_now/views/event/widgets/edit_event_action.dart';
import 'package:vibe_now/views/event/widgets/user_profile_tile.dart';

class EditCommunityScreen extends StatefulWidget {
  const EditCommunityScreen({super.key, required this.community});
  final Community community;

  @override
  State<EditCommunityScreen> createState() => _EditCommunityScreenState();
}

class _EditCommunityScreenState extends State<EditCommunityScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _rulesController;
  late TextEditingController _maxAttendeesController;
  late TextEditingController _locationController;
  final TextEditingController _categoryController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _selectedImage;
  double? _selectedLatitude;
  double? _selectedLongitude;
  CommunityAccessType _accessType = CommunityAccessType.public;
  String? _activeParentForSub;

  final CommunityController communityController =
      Get.find<CommunityController>();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(3100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  List<String> categories = [
    'Music',
    'Art',
    'Games',
    'Sports',
    'Food',
    'Movies',
    'Travel',
  ];
  String? selectedCategory;
  Set<String> selectedCategories = {};

  @override
  void initState() {
    super.initState();
    communityController.selectedSubcategories.clear();

    _titleController = TextEditingController(text: widget.community.title);
    _descriptionController = TextEditingController(text: widget.community.description);
    _rulesController = TextEditingController(text: widget.community.rules);
    _maxAttendeesController = TextEditingController(
      text: widget.community.maxAttendees?.toString() ?? '10',
    );
    _locationController = TextEditingController(text: widget.community.address ?? '');

    _selectedLatitude = widget.community.latitude;
    _selectedLongitude = widget.community.longitude;

    _accessType = widget.community.isPrivate
        ? CommunityAccessType.private
        : CommunityAccessType.public;

    if (widget.community.communityDate != null && widget.community.communityDate!.isNotEmpty) {
      final parts = widget.community.communityDate!.split('-');
      if (parts.length == 3) {
        _selectedDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    }

    if (widget.community.communityTime != null && widget.community.communityTime!.isNotEmpty) {
      try {
        final timeParts = widget.community.communityTime!.split(' ');
        if (timeParts.length == 2) {
          final hourMin = timeParts[0].split(':');
          int hour = int.parse(hourMin[0]);
          final minute = int.parse(hourMin[1]);
          final isPM = timeParts[1].toUpperCase() == 'PM';
          if (isPM && hour != 12) hour += 12;
          if (!isPM && hour == 12) hour = 0;
          _selectedTime = TimeOfDay(hour: hour, minute: minute);
        }
      } catch (e) {
        debugPrint('Error parsing time: $e');
      }
    }

    if (widget.community.categories != null) {
      for (final cat in widget.community.categories!) {
        if (cat.subcategories != null) {
          communityController.selectedSubcategories.addAll(cat.subcategories!);
        }
      }
    }

    _descriptionController.addListener(() {
      setState(() {});
    });

    _rulesController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    _maxAttendeesController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomAppBar(title: loc.translate('communityInfo')),
                    GestureDetector(
                      onTap: () {
                        editCommunityAction(
                          context: context,
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return ConfirmationDialog(
                                  title: loc.translate('deleteEventConfirm'),
                                  confirmBtnText: loc.translate('delete'),
                                  onConfirm: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  onCancel: () {
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            );
                          },
                          onArchive: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return ConfirmationDialog(
                                  title: loc.translate('archiveConfirm'),
                                  confirmBtnText: loc.translate('yes'),
                                  onConfirm: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  onCancel: () {
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            );
                          },
                          onCancel: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                        );
                      },
                      child: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                _buildAdminCard(loc),
                SizedBox(height: 16.h),
                _buildImageUploadSection(context, loc),
                SizedBox(height: 24.h),
                _buildCommunityTitle(loc),
                SizedBox(height: 24.h),
                _buildCommunityDescription(loc),
                SizedBox(height: 24.h),
                _buildCommunityCategory(loc),
                SizedBox(height: 24.h),
                _buildSelectLocation(loc),
                SizedBox(height: 24.h),
                _buildDateTimeRow(loc),
                SizedBox(height: 24.h),
                _buildMaxAttendees(loc),
                SizedBox(height: 24.h),
                _buildCommunityRules(loc),
                SizedBox(height: 24.h),
                Obx(() => PrimaryButton.text(
                  onPressed: () {
                    if (!communityController.isLoading.value) {
                      _handleUpdate(loc);
                    }
                  },
                  text: communityController.isLoading.value ? loc.translate('updating') : loc.translate('update'),
                )),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpdate(loc) async {
    if (widget.community.id == null) {
      AppSnackbar.show(
        message: loc.translate('invalidCommunity'),
        type: SnackType.error,
      );
      return;
    }

    if (_titleController.text.isEmpty) {
      AppSnackbar.show(
        message: 'Please enter a title',
        type: SnackType.warning,
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      AppSnackbar.show(
        message: 'Please enter a description',
        type: SnackType.warning,
      );
      return;
    }

    if (_locationController.text.isEmpty) {
      AppSnackbar.show(
        message: 'Please select a location',
        type: SnackType.warning,
      );
      return;
    }

    if (_selectedDate == null) {
      AppSnackbar.show(
        message: 'Please select a date',
        type: SnackType.warning,
      );
      return;
    }

    if (_selectedTime == null) {
      AppSnackbar.show(
        message: 'Please select a time',
        type: SnackType.warning,
      );
      return;
    }

    final dateStr = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    final timeStr = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    final List<Map<String, dynamic>> categoryJson = [];

    for (final group in communityController.categoryGroups) {
      final selectedSubs = group.children
          .where(
            (sub) => communityController.selectedSubcategories.contains(sub),
          )
          .toList();

      if (selectedSubs.isNotEmpty) {
        categoryJson.add({"name": group.parent, "subcategories": selectedSubs});
      }
    }

    final categories = jsonEncode(categoryJson);

    final success = await communityController.updateCommunity(
      id: widget.community.id!,
      coverImage: _selectedImage,
      title: _titleController.text,
      description: _descriptionController.text,
      rules: _rulesController.text,
      categories: categories,
      address: _locationController.text,
      latitude: _selectedLatitude?.toString() ?? '',
      longitude: _selectedLongitude?.toString() ?? '',
      communityDate: dateStr,
      communityTime: timeStr,
      maxAttendees: _maxAttendeesController.text,
    );

    if (success && mounted) {
      AppSnackbar.show(
        message: loc.translate('communityUpdatedSuccess'),
        type: SnackType.success,
      );
      Navigator.pop(context);
    } else if (mounted) {
      AppSnackbar.show(
        message: loc.translate('failedToUpdateCommunity'),
        type: SnackType.error,
      );
    }
  }

  Widget _buildAdminCard(loc) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradientRotated,
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Row(
        spacing: 8.w,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(20.r),
            child: Image.asset(
              "assets/images/profile_picture.jpg",
              height: 30.w,
              width: 30.w,
              fit: BoxFit.cover,
            ),
          ),
          Text(
            loc.translate('youAreAdmin'),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 20.w),
        ],
      ),
    );
  }

  Widget _buildMaxAttendees(loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('maxAttendees'),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _maxAttendeesController,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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

  Widget _buildDateTimeRow(loc) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('communityDate'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? loc.translate('select')
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('communityTime'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showTimePicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime == null
                            ? loc.translate('select')
                            : _selectedTime!.format(context),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomTimePicker(
        onTimeSelected: (time) {
          setState(() => _selectedTime = time);
        },
      ),
    );
  }

  Widget _buildSelectLocation(loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('selectLocation'),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _locationController.text.isNotEmpty
                        ? _locationController.text
                        : loc.translate('selectAddress'),
                    style: TextStyle(
                      color: _locationController.text.isNotEmpty
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityCategory(loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('communityCategoryLabel'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        Obx(() {
          return Column(
            children: communityController.categoryGroups.map((group) {
              final isExpanded = communityController.expandedParents.contains(
                group.parent,
              );
              final isSelected = communityController.isParentSelected(group);
              final isPartial = communityController.isParentPartiallySelected(
                group,
              );

              return Column(
                children: [
                  GestureDetector(
                    onTap: () => communityController.toggleExpand(group.parent),
                    child: newMethod(isSelected, isPartial, group, isExpanded),
                  ),

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
                                  final selected = communityController
                                      .selectedSubcategories
                                      .contains(sub);

                                  return GestureDetector(
                                    onTap: () => communityController
                                        .toggleSubcategory(sub, group.parent),
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
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        sub,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: selected
                                              ? Colors.white
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6.0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      _activeParentForSub = group.parent;
                                      _showAddCategoryDialog(loc);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        border: Border.all(
                                          color: Theme.of(context).dividerColor,
                                          width: 1.5,
                                        ),
                                        gradient:
                                            AppColors.primaryGradientRotated,
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
        GestureDetector(
          onTap: () {
            _buildNewCategoryDialog(loc);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 12.h),
            width: 160.w,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradientRotated,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: Text(
                loc.translate('addNewCategory'),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<dynamic> _buildNewCategoryDialog(loc) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            loc.translate('addNewCategory'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: _categoryController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: loc.translate('enterCategoryName'),
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _categoryController.clear();
                Navigator.pop(context);
              },
              child: Text(
                loc.translate('cancel'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                final text = _categoryController.text.trim();
                if (text.isEmpty) return;

                if (text.isNotEmpty) {
                  communityController.addParentCategory(text);
                }

                _categoryController.clear();
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  loc.translate('addCategory'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog(loc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            loc.translate('addNewCategory'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: _categoryController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: loc.translate('enterCategoryName'),
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _categoryController.clear();
                Navigator.pop(context);
              },
              child: Text(
                loc.translate('cancel'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_categoryController.text.trim().isNotEmpty) {
                  setState(() {
                    final newCategory = _categoryController.text.trim();
                    if (!categories.contains(newCategory)) {
                      categories.add(newCategory);
                      selectedCategory = newCategory;
                    }
                  });
                  _categoryController.clear();
                  Navigator.pop(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  loc.translate('addCategory'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommunityDescription(loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('description'),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'What is this community about?',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${_descriptionController.value.text.length} / 200",
            style: TextStyle(
              fontSize: 12,
              color: _descriptionController.text.length > 200
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityRules(loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('communityRules'),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _rulesController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'What are the rules of this community?',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${_rulesController.value.text.length} / 500",
            style: TextStyle(
              fontSize: 12,
              color: _rulesController.text.length > 500
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityTitle(loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('communityTitle'),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'e.g. Music Lovers',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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

  Widget _buildImageUploadSection(BuildContext context, loc) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _selectedImage != null
              ? Image.file(
                  _selectedImage!,
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  AppCredentials.fixurl(widget.community.coverImage),
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160.h,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

          Container(
            height: 160.0,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Theme.of(context).shadowColor.withOpacity(0.5),
                ],
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
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
                  AppSnackbar.show(
                    message: loc.translate('failedToPickImage'),
                    type: SnackType.warning,
                  );
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_camera_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    loc.translate('changePhoto'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget newMethod(
    bool isSelected,
    bool isPartial,
    CategoryGroup group,
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
