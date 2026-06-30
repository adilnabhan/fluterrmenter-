import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({super.key});

  @override
  CustomCalendarState createState() => CustomCalendarState();
}

class CustomCalendarState extends State<CustomCalendar> {
  DateTime _currentDate = DateTime.now(); // Start with the current date
  int _selectedDay = DateTime.now().day; // Default to today's day

  // Get the number of days in the current month
  int _daysInMonth(DateTime date) {
    final firstDayOfNextMonth = DateTime(date.year, date.month + 1, 1);
    return firstDayOfNextMonth.subtract(Duration(days: 1)).day;
  }

  // Navigate to the previous month
  void _previousMonth() {
    if (!mounted) return;
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      _selectedDay = 1; // Reset selected day
    });
  }

  // Navigate to the next month
  void _nextMonth() {
    if (!mounted) return;
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      _selectedDay = 1; // Reset selected day
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _daysInMonth(_currentDate);
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1).weekday;

    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: Icon(Icons.arrow_left, color: Colors.grey), onPressed: _previousMonth),
            Row(
              children: [
                Text(DateFormat('MMMM').format(_currentDate), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
                SizedBox(width: 5),
                Text(DateFormat('yyyy').format(_currentDate), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
            IconButton(icon: Icon(Icons.arrow_right, color: Colors.grey), onPressed: _nextMonth),
          ],
        ),
        SizedBox(height: 10),
        // Weekday labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) => Text(day, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))).toList(),
        ),
        SizedBox(height: 10),
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // 7 days in a week
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: daysInMonth + firstDayOfMonth - 1,
          itemBuilder: (context, index) {
            if (index < firstDayOfMonth - 1) {
              return Container(); // Empty cells for days before the first day of the month
            }
            final day = index - firstDayOfMonth + 2;
            final isSelected = day == _selectedDay;
            final isFutureDate = DateTime(_currentDate.year, _currentDate.month, day).isAfter(DateTime.now());

            return GestureDetector(
              onTap:
                  isFutureDate
                      ? null // Disable tap for future dates
                      : () {
                        if (!mounted) return;
                        setState(() {
                          _selectedDay = day;
                        });
                      },
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isFutureDate
                          ? Colors.grey[300] // Greyed out for future dates
                          : isSelected
                          ? Colors.red
                          : Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color:
                          isFutureDate
                              ? Colors
                                  .grey // Grey text for future dates
                              : isSelected
                              ? Colors.white
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
