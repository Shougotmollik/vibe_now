import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/common/custom_time_picker.dart';
import 'package:vibe_now/src/presentation/views/common/custom_date_picker.dart';

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
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Create Event',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 24),
              _buildImageUploadSection(),
              const SizedBox(height: 24),
              _buildEventTitle(),
              const SizedBox(height: 20),
              _buildSelectLocation(),
              const SizedBox(height: 20),
              _buildDateTimeRow(),
              const SizedBox(height: 20),
              _buildMaxAttendees(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.group_outlined, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Create Event',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Build a space where people with shared interests can connect and grow together',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      padding: EdgeInsets.all(38.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0XFFEFF6FF), Color(0XFFECFEFF)],
        ),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Center(
        child: Column(
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
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
                color: Colors.grey[400],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Select address',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
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
                onTap: () => _showDatePicker(context),
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
                        color: Colors.grey[400],
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Select'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
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
                        color: Colors.grey[400],
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime == null
                            ? 'Select'
                            : _selectedTime!.format(context),
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
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
            onPressed: () {},
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
              gradient: const LinearGradient(
                colors: [Color(0xFF6DD5ED), Color(0xFFB794F6)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: ElevatedButton(
              onPressed: () {},
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

  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomDatePicker(
        onDateSelected: (date) {
          setState(() => _selectedDate = date);
        },
      ),
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
}

// class _DatePickerModal extends StatefulWidget {
//   final Function(DateTime) onDateSelected;

//   const _DatePickerModal({required this.onDateSelected});

//   @override
//   State<_DatePickerModal> createState() => _DatePickerModalState();
// }

// class _DatePickerModalState extends State<_DatePickerModal> {
//   DateTime _currentMonth = DateTime(2025, 11);
//   DateTime? _selectedDate = DateTime(2025, 11, 16);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const SizedBox(width: 40),
//               Row(
//                 children: [
//                   Text(
//                     '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   const Icon(Icons.keyboard_arrow_down, size: 20),
//                 ],
//               ),
//               const SizedBox(width: 40),
//             ],
//           ),
//           const SizedBox(height: 20),
//           _buildWeekDays(),
//           const SizedBox(height: 12),
//           _buildCalendar(),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(
//                   'Cancel',
//                   style: TextStyle(color: Colors.grey[600], fontSize: 15),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               TextButton(
//                 onPressed: () {
//                   if (_selectedDate != null) {
//                     widget.onDateSelected(_selectedDate!);
//                   }
//                   Navigator.pop(context);
//                 },
//                 child: const Text(
//                   'Save',
//                   style: TextStyle(
//                     color: Color(0xFFB794F6),
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWeekDays() {
//     const weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: weekDays
//           .map(
//             (day) => SizedBox(
//               width: 40,
//               child: Center(
//                 child: Text(
//                   day,
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//           )
//           .toList(),
//     );
//   }

//   Widget _buildCalendar() {
//     final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
//     final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
//     final daysInMonth = lastDay.day;
//     final startWeekday = firstDay.weekday % 7;

//     final prevMonthDays = DateTime(
//       _currentMonth.year,
//       _currentMonth.month,
//       0,
//     ).day;
//     final List<Widget> dayWidgets = [];

//     // Previous month days
//     for (int i = startWeekday - 1; i >= 0; i--) {
//       dayWidgets.add(_buildDayCell(prevMonthDays - i, isOtherMonth: true));
//     }

//     // Current month days
//     for (int day = 1; day <= daysInMonth; day++) {
//       final date = DateTime(_currentMonth.year, _currentMonth.month, day);
//       dayWidgets.add(_buildDayCell(day, date: date));
//     }

//     return GridView.count(
//       crossAxisCount: 7,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       children: dayWidgets,
//     );
//   }

//   Widget _buildDayCell(int day, {bool isOtherMonth = false, DateTime? date}) {
//     final isSelected =
//         date != null &&
//         _selectedDate != null &&
//         date.year == _selectedDate!.year &&
//         date.month == _selectedDate!.month &&
//         date.day == _selectedDate!.day;

//     return GestureDetector(
//       onTap: date != null
//           ? () {
//               setState(() => _selectedDate = date);
//             }
//           : null,
//       child: Container(
//         margin: const EdgeInsets.all(4),
//         decoration: BoxDecoration(
//           gradient: isSelected
//               ? const LinearGradient(
//                   colors: [Color(0xFF6DD5ED), Color(0xFFB794F6)],
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                 )
//               : null,
//           shape: BoxShape.circle,
//         ),
//         child: Center(
//           child: Text(
//             '$day',
//             style: TextStyle(
//               color: isOtherMonth
//                   ? Colors.grey[300]
//                   : isSelected
//                   ? Colors.white
//                   : Colors.black87,
//               fontSize: 14,
//               fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   String _getMonthName(int month) {
//     const months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];
//     return months[month - 1];
//   }
// }

// class _TimePickerModal extends StatefulWidget {
//   final Function(TimeOfDay) onTimeSelected;

//   const _TimePickerModal({required this.onTimeSelected});

//   @override
//   State<_TimePickerModal> createState() => _TimePickerModalState();
// }

// class _TimePickerModalState extends State<_TimePickerModal> {
//   int _selectedHour = 4;
//   int _selectedMinute = 14;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 300,
//       padding: const EdgeInsets.symmetric(vertical: 20),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildScrollPicker(
//               items: List.generate(
//                 24,
//                 (index) => index.toString().padLeft(2, '0'),
//               ),
//               selectedIndex: _selectedHour,
//               onChanged: (index) => setState(() => _selectedHour = index),
//             ),
//           ),
//           Expanded(
//             child: _buildScrollPicker(
//               items: List.generate(
//                 60,
//                 (index) => index.toString().padLeft(2, '0'),
//               ),
//               selectedIndex: _selectedMinute,
//               onChanged: (index) => setState(() => _selectedMinute = index),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildScrollPicker({
//     required List<String> items,
//     required int selectedIndex,
//     required Function(int) onChanged,
//   }) {
//     return Stack(
//       children: [
//         Center(
//           child: Container(
//             height: 45,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF6DD5ED), Color(0xFFB794F6)],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//         ),
//         ListWheelScrollView.useDelegate(
//           controller: FixedExtentScrollController(initialItem: selectedIndex),
//           itemExtent: 45,
//           physics: const FixedExtentScrollPhysics(),
//           onSelectedItemChanged: onChanged,
//           childDelegate: ListWheelChildBuilderDelegate(
//             builder: (context, index) {
//               if (index < 0 || index >= items.length) return null;
//               final isSelected = index == selectedIndex;
//               return Center(
//                 child: Text(
//                   items[index],
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: isSelected
//                         ? FontWeight.w600
//                         : FontWeight.normal,
//                     color: isSelected ? Colors.white : Colors.black54,
//                   ),
//                 ),
//               );
//             },
//             childCount: items.length,
//           ),
//         ),
//       ],
//     );
//   }
// }
