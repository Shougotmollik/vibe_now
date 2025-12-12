import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';

class CustomTimePicker extends StatefulWidget {
  final Function(TimeOfDay) onTimeSelected;

  const CustomTimePicker({super.key, required this.onTimeSelected});

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  int _selectedHour = 4;
  int _selectedMinute = 14;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildScrollPicker(
              items: List.generate(
                24,
                (index) => index.toString().padLeft(2, '0'),
              ),
              selectedIndex: _selectedHour,
              onChanged: (index) => setState(() => _selectedHour = index),
            ),
          ),
          Expanded(
            child: _buildScrollPicker(
              items: List.generate(
                60,
                (index) => index.toString().padLeft(2, '0'),
              ),
              selectedIndex: _selectedMinute,
              onChanged: (index) => setState(() => _selectedMinute = index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollPicker({
    required List<String> items,
    required int selectedIndex,
    required Function(int) onChanged,
  }) {
    return Stack(
      children: [
        Center(
          child: Container(
            height: 45.h,
            width: 80.w,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,

              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        ListWheelScrollView.useDelegate(
          controller: FixedExtentScrollController(initialItem: selectedIndex),
          itemExtent: 45,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: onChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) {
              if (index < 0 || index >= items.length) return null;
              final isSelected = index == selectedIndex;
              return Center(
                child: Text(
                  items[index],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                ),
              );
            },
            childCount: items.length,
          ),
        ),
      ],
    );
  }
}
