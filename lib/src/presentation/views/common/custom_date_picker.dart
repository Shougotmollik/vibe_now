import 'package:flutter/material.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';

class CustomDatePicker extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const CustomDatePicker({super.key, required this.onDateSelected});

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime _currentMonth;
  late DateTime _today;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _currentMonth = DateTime(now.year, now.month);
    _selectedDate = _today;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildWeekDays(),
              const SizedBox(height: 12),
              _buildCalendar(),
              const SizedBox(height: 20),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _goToPreviousMonth,
        ),
        GestureDetector(
          onTap: _openMonthYearPicker,
          child: Row(
            children: [
              Text(
                '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 20),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _goToNextMonth,
        ),
      ],
    );
  }

  // ================= WEEK DAYS =================

  Widget _buildWeekDays() {
    const weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays
          .map(
            (day) => SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ================= CALENDAR =================

  Widget _buildCalendar() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday % 7;

    final prevMonthDays = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      0,
    ).day;

    final List<Widget> dayWidgets = [];

    // PREVIOUS MONTH DAYS
    for (int i = startWeekday - 1; i >= 0; i--) {
      dayWidgets.add(_buildDayCell(prevMonthDays - i, isOtherMonth: true));
    }

    // CURRENT MONTH DAYS
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      dayWidgets.add(_buildDayCell(day, date: date));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }

  // ================= DAY CELL =================

  Widget _buildDayCell(int day, {bool isOtherMonth = false, DateTime? date}) {
    bool isPastDate = false;

    if (date != null) {
      final d = DateTime(date.year, date.month, date.day);
      isPastDate = d.isBefore(_today);
    }

    final isSelected =
        date != null &&
        _selectedDate != null &&
        date.year == _selectedDate!.year &&
        date.month == _selectedDate!.month &&
        date.day == _selectedDate!.day;

    return GestureDetector(
      onTap: (date != null && !isPastDate)
          ? () => setState(() => _selectedDate = date)
          : null,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              color: isOtherMonth || isPastDate
                  ? Colors.grey[300]
                  : isSelected
                  ? Colors.white
                  : Colors.black87,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // ================= FOOTER =================

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: () {
            if (_selectedDate != null) {
              widget.onDateSelected(_selectedDate!);
            }
            Navigator.pop(context);
          },
          child: const Text(
            'Save',
            style: TextStyle(
              color: Color(0xFFB794F6),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ================= MONTH / YEAR PICKER =================

  Future<void> _openMonthYearPicker() async {
    int tempYear = _currentMonth.year;
    int tempMonth = _currentMonth.month;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select month'),
              content: SizedBox(
                height: 240,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => setDialogState(() => tempYear--),
                        ),
                        Text(
                          '$tempYear',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => setDialogState(() => tempYear++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        itemCount: 12,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          final isSelected = month == tempMonth;

                          return GestureDetector(
                            onTap: () =>
                                setDialogState(() => tempMonth = month),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFB794F6)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getMonthName(month).substring(0, 3),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final lastDay = DateTime(tempYear, tempMonth + 1, 0).day;
                    final selectedDay = _selectedDate?.day ?? 1;

                    setState(() {
                      _currentMonth = DateTime(tempYear, tempMonth);
                      _selectedDate = DateTime(
                        tempYear,
                        tempMonth,
                        selectedDay.clamp(1, lastDay),
                      );
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= HELPERS =================

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
