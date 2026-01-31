import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/helper/helper.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/src/presentation/views/common/custom_app_bar.dart';
import 'package:vibe_now/src/presentation/views/common/custom_time_picker.dart';
import 'package:vibe_now/src/presentation/views/common/custom_date_picker.dart';
import 'package:vibe_now/src/presentation/views/event/widgets/event_animated_dialog.dart';

// enum EventAccessType { public, private }

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

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _selectedImage;
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

  EventAccessType _accessType = EventAccessType.public;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomAppBar(title: 'Create Event'),
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
        const Text(
          'Access Level',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              _accessToggleItem(
                label: 'Public',
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
                label: 'Private',
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
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
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
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
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
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.group_outlined, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Build a space where people with shared interests can connect and grow together',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
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
        final File? image = await CustomImagePicker.pickImage();
        if (image != null) {
          setState(() {
            _selectedImage = image;
          });
        }
      },
      child: Container(
        width: double.infinity,
        height: 172.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0XFFEFF6FF), Color(0XFFECFEFF)],
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
                        color: Color(0XFF364153),
                      ),
                    ),
                    Text(
                      "Click to browse",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0XFF4A5565),
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
        const Text(
          'Event Title',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'e.g. Music Lovers',
            hintStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
            filled: true,
            fillColor: Colors.grey[100],
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
        const Text(
          'Select Location',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.grey[700],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Select address',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Date',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
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
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.grey[700],
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Select'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
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
              const Text(
                'Time',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
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
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        color: Colors.grey[700],
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime == null
                            ? 'Select'
                            : _selectedTime!.format(context),
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
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

  Widget _buildMaxAttendees() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Max Attendees',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _maxAttendeesController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
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
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradientRotated,
              borderRadius: BorderRadius.circular(30),
            ),
            child: ElevatedButton(
              onPressed: () {
                // final event ={
                //   'title': _titleController.text,
                //   'description': _descriptionController.text,
                //   'location': _locationController.text,
                //   'date': _selectedDate,
                //   'time': _selectedTime,
                //   'maxAttendees': int.parse(_maxAttendeesController.text),
                //   'category': selectedCategories,
                //   'acessibility': _accessType,
                // };
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
                          content:
                              'Congratulations! Your event has been created.',
                        ),
                      ),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Create',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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

  Widget _buildEventCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Category',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...categories.map((e) {
                final bool isSelected = selectedCategories.contains(e);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedCategories.remove(e);
                      } else {
                        selectedCategories.add(e);
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: isSelected
                          ? AppColors.primaryGradientRotated
                          : LinearGradient(
                              colors: [Colors.grey[100]!, Colors.grey[100]!],
                            ),
                    ),
                    child: Text(
                      e,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: isSelected ? Colors.white : Color(0xff555555),
                      ),
                    ),
                  ),
                );
              }).toList(),
              // Add Category Button
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: GestureDetector(
                  onTap: () => _showAddCategoryDialog(),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey[400]!, width: 1.5),
                      gradient: AppColors.primaryGradientRotated,
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 20.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
          backgroundColor: Colors.white,
          title: const Text(
            'Add New Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: _categoryController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter category name',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
              filled: true,
              fillColor: Colors.grey[100],
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
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
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
}
