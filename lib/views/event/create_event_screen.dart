import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/event_controller.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/helper/helper.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/env.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/category.dart';
import 'package:vibe_now/utils.dart' as utils;
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/common/custom_time_picker.dart';
import 'package:vibe_now/views/common/custom_date_picker.dart';
import 'package:vibe_now/views/common/location_selection_screen.dart';
import 'package:vibe_now/views/event/widgets/event_animated_dialog.dart';
import 'package:vibe_now/views/home/widgets/google_map.dart';
import 'package:vibe_now/localization/app_localizations.dart';

enum EventAccessType { public, private }

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _maxAttendeesController = TextEditingController(
    text: '10',
  );
  final TextEditingController _categoryController = TextEditingController();
  final EventController eventController = Get.find<EventController>();
  final TextEditingController locationController = TextEditingController();
  double? selectedLatitude;
  double? selectedLongitude;

  String? _activeParentForSub;

  DateTime? _startingDate;
  TimeOfDay? _startingTime;
  DateTime? _endingDate;
  TimeOfDay? _endingTime;
  File? _selectedImage;

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

  EventAccessType _accessType = EventAccessType.public;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(title: AppLocalizations.of(context).translate('createEvent')),
                const SizedBox(height: 24),
                _buildHeaderCard(),
                const SizedBox(height: 24),
                _buildImageUploadSection(),
                const SizedBox(height: 24),
                _buildEventTitle(),
                const SizedBox(height: 20),
                _buildEventCategory(),
                const SizedBox(height: 20),
                _buildAccessLevel(),
                const SizedBox(height: 20),
                _buildSelectLocation(),
                const SizedBox(height: 20),
                _buildDateTimeRow(),
                const SizedBox(height: 20),
                _buildMaxAttendees(),
                const SizedBox(height: 32),
                _buildActionButtons(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('accessLevel'),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              _accessToggleItem(
                label: AppLocalizations.of(context).translate('public'),
                icon: Icons.people_alt_outlined,
                isSelected: _accessType == EventAccessType.public,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _accessType = EventAccessType.public;
                  });
                },
              ),
              _accessToggleItem(
                label: AppLocalizations.of(context).translate('private'),
                icon: Icons.lock_person_outlined,
                isSelected: _accessType == EventAccessType.private,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _accessType = EventAccessType.private;
                  });
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _accessType == EventAccessType.public
                ? 'Anyone can discover and join this event instantly without approval.'
                : 'People will need your approval before they can join this event.',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _accessToggleItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeInOutCubic,
              alignment: isSelected ? Alignment.center : Alignment.center,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1 : 0,
                child: Container(
                  height: 42.h,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradientRotated,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20.sp,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.1),
            Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.group_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Build a space where people with shared interests can connect and grow together',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return GestureDetector(
      onTap: () async {
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
            AppSnackbar.show(message: 'Failed to pick image');
          }
        });
      },
      child: Container(
        width: double.infinity,
        height: 172.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.1),
              Theme.of(
                context,
              ).colorScheme.secondaryContainer.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: _selectedImage != null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8.w,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(24, 23, 24, 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16.w,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.icons.uploadImage.svg(width: 40.w, height: 40.h),
                    SizedBox(height: 8.h),

                    Text(
                      "Upload Cover Image",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      "Click to browse",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEventTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('eventTitle'),
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
              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
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

  Widget _buildSelectLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('selectLocation'),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocationSelectionScreen(
                  apiKey: EnvHandler.google_map_api_key,
                  onLocationSelect: (location) {
                    setState(() {
                      locationController.text = location.name;
                      selectedLatitude = location.position.latitude;
                      selectedLongitude = location.position.longitude;
                    });

                    print(
                      'Selected location: $selectedLatitude, $selectedLongitude',
                    );
                    print('Location name: ${location.name}');
                  },
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    locationController.text.isEmpty
                        ? 'Select address'
                        : locationController.text,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildDateTimeRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('eventDateTime'),
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
                label: AppLocalizations.of(context).translate('startingDate'),
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
                label: AppLocalizations.of(context).translate('startingTime'),
                time: _startingTime,
                onTap: () => _showTimePicker(context, (time) => _startingTime = time),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: AppLocalizations.of(context).translate('endingDate'),
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
                label: AppLocalizations.of(context).translate('endingTime'),
                time: _endingTime,
                onTap: () => _showTimePicker(context, (time) => _endingTime = time),
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
                      ? 'Select'
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
                      ? 'Select'
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

  Widget _buildMaxAttendees() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('maxAttendees'),
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomElevatedButton(
            height: 48.h,
            onTap: () => Navigator.of(context).maybePop(),
            buttonText: "Cancel",
            textColor: Theme.of(context).colorScheme.onSurface,
            btnColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ),
        const SizedBox(width: 18),
        Obx(
          () => Expanded(
            child: PrimaryButton.text(
              onPressed: onCreate,
              text: 'Create',
              isLoading: eventController.isLoading.value,
            ),
          ),
        ),
        // Expanded(
        //   child: Container(
        //     decoration: BoxDecoration(
        //       gradient: AppColors.primaryGradientRotated,
        //       borderRadius: BorderRadius.circular(30),
        //     ),
        //     child: ElevatedButton(
        //       onPressed: () {
        //         // final event ={
        //         //   'title': _titleController.text,
        //         //   'description': _descriptionController.text,
        //         //   'location': _locationController.text,
        //         //   'date': _selectedDate,
        //         //   'time': _selectedTime,
        //         //   'maxAttendees': int.parse(_maxAttendeesController.text),
        //         //   'category': selectedCategories,
        //         //   'acessibility': _accessType,
        //         // };
        //         Navigator.pop(context);
        //         showDialog(
        //           context: context,
        //           barrierDismissible: true,
        //           builder: (context) {
        //             return Center(
        //               child: Dialog(
        //                 shape: RoundedRectangleBorder(
        //                   borderRadius: BorderRadius.circular(20.r),
        //                 ),
        //                 elevation: 0,
        //                 backgroundColor: Colors.transparent,
        //                 child: EventAnimatedDialog(
        //                   content: 'Your event is live.',
        //                 ),
        //               ),
        //             );
        //           },
        //         );
        //       },
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Colors.transparent,
        //         shadowColor: Colors.transparent,
        //         padding: const EdgeInsets.symmetric(vertical: 16),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(30),
        //         ),
        //       ),
        //       child: const Text(
        //         'Create',
        //         style: TextStyle(
        //           color: Colors.white,
        //           fontSize: 15,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
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

  Widget _buildEventCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('eventCategoryLabel'),
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
                  // Parent
                  GestureDetector(
                    onTap: () => eventController.toggleExpand(group.parent),
                    child: newMethod(isSelected, isPartial, group, isExpanded),
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
                                      _showAddCategoryDialog();
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
            _buildNewCategoryDialog();
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
                "Add New Category",
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

  Future<dynamic> _buildNewCategoryDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            AppLocalizations.of(context).translate('addNewCategory'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: _categoryController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter category name',
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
                'Cancel',
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
                child: const Text(
                  'Add',
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

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            AppLocalizations.of(context).translate('addSubCategory'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: _categoryController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter category name',
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
                'Cancel',
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
                child: const Text(
                  'Add',
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

  void onCreate() async {
    if (_selectedImage == null) {
      AppSnackbar.show(message: AppLocalizations.of(context).translate('uploadCoverImage'));
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      AppSnackbar.show(message: AppLocalizations.of(context).translate('eventTitle'));
      return;
    }

    if (_startingDate == null) {
      AppSnackbar.show(message: 'Please select starting date');
      return;
    }

    if (_startingTime == null) {
      AppSnackbar.show(message: 'Please select starting time');
      return;
    }

    if (_endingDate == null) {
      AppSnackbar.show(message: 'Please select ending date');
      return;
    }

    if (_endingTime == null) {
      AppSnackbar.show(message: 'Please select ending time');
      return;
    }

    /// Build categories json
    final List<Map<String, dynamic>> categoryJson = [];

    for (final group in eventController.categoryGroups) {
      final selectedSubs = group.children
          .where((sub) => eventController.selectedSubcategories.contains(sub))
          .toList();

      if (selectedSubs.isNotEmpty) {
        categoryJson.add({"name": group.parent, "subcategories": selectedSubs});
      }
    }
    // String formatTimeOfDay(TimeOfDay time, BuildContext context) {
    //   final now = DateTime.now();
    //   final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    //   final formatted = TimeOfDay.fromDateTime(dt).format(context);
    //   return formatted;
    // }

    final success = await eventController.createEvent(
      coverImage: _selectedImage!,
      title: _titleController.text.trim(),
      categories: jsonEncode(categoryJson),
      accessLevel: _accessType == EventAccessType.public ? 'public' : 'private',
      address: locationController.text,
      latitude: selectedLatitude.toString(),
      longitude: selectedLongitude.toString(),
      eventStartingDate: _startingDate != null
          ? "${_startingDate!.year}-${_startingDate!.month.toString().padLeft(2, '0')}-${_startingDate!.day.toString().padLeft(2, '0')}"
          : '',
      eventStartingTime: _startingTime != null ? _startingTime!.format(context) : '',
      eventEndingDate: _endingDate != null
          ? "${_endingDate!.year}-${_endingDate!.month.toString().padLeft(2, '0')}-${_endingDate!.day.toString().padLeft(2, '0')}"
          : '',
      eventEndingTime: _endingTime != null ? _endingTime!.format(context) : '',
      maxAttendees: _maxAttendeesController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pop(context);

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Center(
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: EventAnimatedDialog(
                content: 'Your event is submitted for approval.',
              ),
            ),
          );
        },
      );
    } else {
      AppSnackbar.show(message: AppLocalizations.of(context).translate('failed'));
    }
  }
}
