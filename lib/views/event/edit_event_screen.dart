import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vibe_now/controller/event_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/env.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/category.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/utils.dart' as utils;
import 'package:vibe_now/views/common/confirmation_dialog.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/common/custom_time_picker.dart';
import 'package:vibe_now/views/common/location_selection_screen.dart';
import 'package:vibe_now/views/event/widgets/edit_event_action.dart';
import 'package:vibe_now/views/event/widgets/event_animated_dialog.dart';
import 'package:vibe_now/views/event/widgets/user_profile_tile.dart';

enum EventAccessType { public, private }

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({super.key, required this.event});
  final Event event;

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  File? _selectedImage;
  String? _activeParentForSub;
  DateTime? _startingDate;
  TimeOfDay? _startingTime;
  DateTime? _endingDate;
  TimeOfDay? _endingTime;
  late TextEditingController _titleController;
  final TextEditingController _categoryController = TextEditingController();
  final EventController eventController = Get.find<EventController>();
  late TextEditingController _maxAttendeesController;
  final TextEditingController _locationController = TextEditingController();
  double? _selectedLatitude;
  double? _selectedLongitude;
  EventAccessType _accessType = EventAccessType.public;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _maxAttendeesController = TextEditingController(
      text: widget.event.maxAttendees?.toString() ?? '10',
    );
    _locationController.text = widget.event.address ?? '';
    _selectedLatitude = widget.event.latitude;
    _selectedLongitude = widget.event.longitude;
    _accessType = widget.event.accessLevel == 'private'
        ? EventAccessType.private
        : EventAccessType.public;

    if (widget.event.eventStartingDate != null &&
        widget.event.eventStartingDate!.isNotEmpty) {
      final parts = widget.event.eventStartingDate!.split('-');
      if (parts.length == 3) {
        _startingDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    } else if (widget.event.eventDate != null &&
        widget.event.eventDate!.isNotEmpty) {
      final parts = widget.event.eventDate!.split('-');
      if (parts.length == 3) {
        _startingDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    }

    if (widget.event.eventEndingDate != null &&
        widget.event.eventEndingDate!.isNotEmpty) {
      final parts = widget.event.eventEndingDate!.split('-');
      if (parts.length == 3) {
        _endingDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    }

    void parseTime(String? timeStr, Function(TimeOfDay) assign) {
      if (timeStr == null || timeStr.isEmpty) return;
      try {
        final timeParts = timeStr.split(' ');
        if (timeParts.length == 2) {
          final hourMin = timeParts[0].split(':');
          int hour = int.parse(hourMin[0]);
          final minute = int.parse(hourMin[1]);
          final isPM = timeParts[1].toUpperCase() == 'PM';
          if (isPM && hour != 12) hour += 12;
          if (!isPM && hour == 12) hour = 0;
          assign(TimeOfDay(hour: hour, minute: minute));
        }
      } catch (e) {
        debugPrint('Error parsing time: $e');
      }
    }

    parseTime(widget.event.eventStartingTime, (time) => _startingTime = time);
    if (_startingTime == null) {
      parseTime(widget.event.eventTime, (time) => _startingTime = time);
    }
    parseTime(widget.event.eventEndingTime, (time) => _endingTime = time);

    if (widget.event.categories != null) {
      for (final cat in widget.event.categories!) {
        if (cat.subcategories != null) {
          eventController.selectedSubcategories.addAll(cat.subcategories!);
        }
      }
    }
  }

  @override
  void dispose() {
    eventController.clear();
    super.dispose();
  }

  Future<void> _selectDate({
    required BuildContext context,
    required Function(DateTime) onSelected,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(3100),
    );
    if (picked != null) {
      setState(() {
        onSelected(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomAppBar(title: loc.translate('editEvent')),
                  GestureDetector(
                    onTap: () {
                      editEventAction(
                        context: context,
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ConfirmationDialog(
                                title: loc.translate('deleteEventConfirm'),
                                confirmBtnText: loc.translate('delete'),
                                onConfirm: () async {
                                  final success = await eventController
                                      .deleteEvent(id: widget.event.id ?? 0);
                                  if (success) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    AppSnackbar.show(
                                      message: loc.translate('youDeletedEvent'),
                                    );
                                  }
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
                        },
                      );
                    },
                    child: Icon(Icons.more_vert),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _buildAdminCard(loc),
              SizedBox(height: 12.h),
              _buildImageUploadSection(context, loc),
              const SizedBox(height: 24),
              _buildEventTitle(loc),
              const SizedBox(height: 24),
              _buildEventCategory(loc),
              const SizedBox(height: 20),
              _buildSelectLocation(loc),
              const SizedBox(height: 20),
              _buildDateTimeRow(loc),
              const SizedBox(height: 20),
              _buildMaxAttendees(loc),
              const SizedBox(height: 20),
              Obx(
                () => PrimaryButton.text(
                  onPressed: eventController.isLoading.value
                      ? () {}
                      : () {
                          _showUpdateConfirmationDialog(loc);
                        },
                  text: loc.translate('update'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventMember(loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('membersCount'),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Column(children: List.generate(3, (index) => UserProfileTile())),
      ],
    );
  }

  Widget _buildDateTimeRow(loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('eventDateTime'),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: loc.translate('startingDate'),
                date: _startingDate,
                onTap: () => _selectDate(
                  context: context,
                  onSelected: (date) => _startingDate = date,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeField(
                label: loc.translate('startingTime'),
                time: _startingTime,
                onTap: () =>
                    _showTimePicker(context, (time) => _startingTime = time),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: loc.translate('endingDate'),
                date: _endingDate,
                onTap: () => _selectDate(
                  context: context,
                  onSelected: (date) => _endingDate = date,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeField(
                label: loc.translate('endingTime'),
                time: _endingTime,
                onTap: () =>
                    _showTimePicker(context, (time) => _endingTime = time),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  date == null
                      ? AppLocalizations.of(context).translate('select')
                      : '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  time == null
                      ? AppLocalizations.of(context).translate('select')
                      : time.format(context),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showTimePicker(BuildContext context, Function(TimeOfDay) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomTimePicker(
        onTimeSelected: (time) {
          setState(() => onSelected(time));
        },
      ),
    );
  }

  Widget _buildEventCategory(loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('eventCategoryLabel'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
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
                  GestureDetector(
                    onTap: () => eventController.toggleExpand(group.parent),
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
                                  final selected = eventController
                                      .selectedSubcategories
                                      .contains(sub);

                                  return GestureDetector(
                                    onTap: () => eventController
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
                                                ).colorScheme.onSurface,
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
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outlineVariant,
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
                loc.translate('newCategory'),
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
          onTap: () => _selectLocation(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
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
                    _locationController.text.isEmpty
                        ? loc.translate('selectAddress')
                        : _locationController.text,
                    style: TextStyle(
                      color: _locationController.text.isEmpty
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectLocation(BuildContext context) async {
    LatLng? initialPosition;
    if (_selectedLatitude != null && _selectedLongitude != null) {
      initialPosition = LatLng(_selectedLatitude!, _selectedLongitude!);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSelectionScreen(
          apiKey: EnvHandler.google_map_api_key,
          initialPosition: initialPosition,
          onLocationSelect: (location) {
            setState(() {
              _locationController.text = location.name;
              _selectedLatitude = location.position.latitude;
              _selectedLongitude = location.position.longitude;
            });
          },
        ),
      ),
    );
  }

  Widget _buildEventTitle(loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('eventTitle'),
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
                  AppCredentials.fixurl(widget.event.coverImage),
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160.h,
                    color: Colors.grey[900],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
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
                  Colors.black.withValues(alpha: 0.5),
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
                border: Border.all(color: Colors.white24),
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
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurface,
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
            loc.translate('newCategory'),
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
                  eventController.addParentCategory(text);
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
            loc.translate('addSubCategory'),
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
                  eventController.addSubCategory(
                    parent: _activeParentForSub!,
                    subCategory: text,
                  );
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

  void _showUpdateConfirmationDialog(loc) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Container(
                padding: EdgeInsets.all(18.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loc.translate('updateEventConfirm'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: CustomElevatedButton(
                            onTap: () => Navigator.pop(dialogContext),
                            buttonText: loc.translate('cancel'),
                            btnColor: Theme.of(
                              context,
                            ).colorScheme.surfaceVariant,
                            textColor: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Obx(
                            () => PrimaryButton.text(
                              onPressed: eventController.isLoading.value
                                  ? () {}
                                  : () {
                                      Navigator.pop(dialogContext);
                                      _updateEvent(loc);
                                    },
                              text: loc.translate('yes'),
                              isLoading: eventController.isLoading.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateEvent(loc) async {
    if (_titleController.text.trim().isEmpty) {
      AppSnackbar.show(
        message: 'Please enter event title',
        type: SnackType.info,
      );
      return;
    }

    if (_locationController.text.isEmpty) {
      AppSnackbar.show(message: 'Please select location', type: SnackType.info);
      return;
    }

    if (_startingDate == null) {
      AppSnackbar.show(
        message: 'Please select starting date',
        type: SnackType.info,
      );
      return;
    }

    if (_startingTime == null) {
      AppSnackbar.show(
        message: 'Please select starting time',
        type: SnackType.info,
      );
      return;
    }

    if (_endingDate == null) {
      AppSnackbar.show(
        message: 'Please select ending date',
        type: SnackType.info,
      );
      return;
    }

    if (_endingTime == null) {
      AppSnackbar.show(
        message: 'Please select ending time',
        type: SnackType.info,
      );
      return;
    }

    final categoryJson = <Map<String, dynamic>>[];
    for (final group in eventController.categoryGroups) {
      final selectedSubs = group.children
          .where((c) => eventController.selectedSubcategories.contains(c))
          .toList();
      if (selectedSubs.isNotEmpty) {
        categoryJson.add({'name': group.parent, 'subcategories': selectedSubs});
      }
    }

    final success = await eventController.updateEvent(
      id: widget.event.id!,
      coverImage: _selectedImage,
      title: _titleController.text.trim(),
      categories: jsonEncode(categoryJson),
      accessLevel: _accessType == EventAccessType.public ? 'public' : 'private',
      address: _locationController.text,
      latitude: _selectedLatitude?.toString() ?? '',
      longitude: _selectedLongitude?.toString() ?? '',
      eventStartingDate: _startingDate != null
          ? "${_startingDate!.year}-${_startingDate!.month.toString().padLeft(2, '0')}-${_startingDate!.day.toString().padLeft(2, '0')}"
          : '',
      eventStartingTime: _startingTime != null
          ? _startingTime!.format(context)
          : '',
      eventEndingDate: _endingDate != null
          ? "${_endingDate!.year}-${_endingDate!.month.toString().padLeft(2, '0')}-${_endingDate!.day.toString().padLeft(2, '0')}"
          : '',
      eventEndingTime: _endingTime != null ? _endingTime!.format(context) : '',
      maxAttendees: _maxAttendeesController.text.trim(),
    );

    if (success && mounted) {
      AppSnackbar.show(
        message: loc.translate('eventUpdated'),
        type: SnackType.info,
      );
      Navigator.pop(context);
    } else {
      AppSnackbar.show(message: 'Failed to update event', type: SnackType.info);
    }
  }
}
