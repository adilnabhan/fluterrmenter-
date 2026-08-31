import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';

class TrainerClientWorkoutHistoryCalendar extends StatefulWidget {
  const TrainerClientWorkoutHistoryCalendar({
    super.key,
    required this.customerId,
    this.startDate,
    required this.workoutHistory,
    this.showTitle = true,
  });

  final int customerId;
  final DateTime? startDate;
  final List<Map<String, dynamic>> workoutHistory;
  final bool showTitle;

  @override
  State<TrainerClientWorkoutHistoryCalendar> createState() =>
      _TrainerClientWorkoutHistoryCalendarState();
}

enum CalendarDayState {
  verified,
  assigned,
  missed,
  rest,
  future,
}

class _TrainerClientWorkoutHistoryCalendarState
    extends State<TrainerClientWorkoutHistoryCalendar> {
  final GlobalKey _calendarCardKey = GlobalKey();
  DateTime _focusedDay = DateTime.now();
  final Map<String, CalendarDayState> _dayStates = {};

  DateTime get _firstWorkoutDate {
    return widget.startDate ?? DateTime.now().subtract(const Duration(days: 30));
  }

  @override
  void initState() {
    super.initState();
    _computeDayStates();
  }

  @override
  void didUpdateWidget(covariant TrainerClientWorkoutHistoryCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workoutHistory != widget.workoutHistory) {
      _computeDayStates();
    }
  }

  /// Derives calendar day states locally from the workout history data.
  /// - Entries with is_verified == true → verified (double tick)
  /// - Entries with is_rest_day == true or status == 'rest' → rest
  /// - Other entries (assigned but not verified) → assigned (single tick)
  /// - Past dates with no entry → missed (cross)
  /// - Today and future dates → future (no indicator)
  void _computeDayStates() {
    _dayStates.clear();

    // Build a lookup from the workout history list
    final Map<String, Map<String, dynamic>> historyByDate = {};
    for (final entry in widget.workoutHistory) {
      final dateStr = entry['date'] as String? ?? '';
      if (dateStr.isEmpty) continue;
      final date = DateTime.tryParse(dateStr);
      if (date == null) continue;
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      historyByDate[dateKey] = entry;
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final startDate = _firstWorkoutDate;
    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);

    // Process all days of the focused month
    final year = _focusedDay.year;
    final month = _focusedDay.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateOnly = DateTime(date.year, date.month, date.day);
      final dateKey = DateFormat('yyyy-MM-dd').format(dateOnly);

      // Future dates (strictly after today) → no indicator
      if (dateOnly.isAfter(todayOnly)) {
        _dayStates[dateKey] = CalendarDayState.future;
        continue;
      }

      // Before membership start → no indicator
      if (dateOnly.isBefore(startDateOnly)) {
        _dayStates[dateKey] = CalendarDayState.future;
        continue;
      }

      // Check if there's a workout history entry for this date
      final historyEntry = historyByDate[dateKey];
      if (historyEntry != null) {
        // historyEntry format: { "date": "...", "logs": [ { ... } ] }
        final logs = historyEntry['logs'] as List<dynamic>? ?? [];

        // Check if any log is a rest day
        final isRestDay = logs.any((log) {
          if (log is! Map) return false;
          return log['is_rest_day'] == true ||
              log['is_rest_day'] == 'true' ||
              (log['status'] as String?)?.toLowerCase() == 'rest';
        });

        if (isRestDay) {
          _dayStates[dateKey] = CalendarDayState.rest;
          continue;
        }

        // Check if any log is verified
        final isVerified = logs.any((log) {
          if (log is! Map) return false;
          return log['is_verified'] == true ||
              log['is_verified'] == 'true' ||
              (log['verification_status'] as String?)?.toLowerCase() == 'verified';
        });

        if (isVerified) {
          _dayStates[dateKey] = CalendarDayState.verified;
        } else {
          // Assigned but not yet verified
          _dayStates[dateKey] = CalendarDayState.assigned;
        }
      } else {
        // Past date with no entry → missed
        _dayStates[dateKey] = CalendarDayState.missed;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final joinDate = _firstWorkoutDate;
    final joinMonth = DateTime(joinDate.year, joinDate.month, 1);
    final currentMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final canGoPrev = currentMonth.isAfter(joinMonth) || currentMonth.isAtSameMomentAs(joinMonth);

    final today = DateTime.now();
    final todayMonth = DateTime(today.year, today.month, 1);
    final canGoNext = currentMonth.isBefore(todayMonth);

    int assignedCount = 0;
    int missedCount = 0;
    int restCount = 0;

    final year = _focusedDay.year;
    final month = _focusedDay.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final state = _dayStates[dateKey] ?? CalendarDayState.future;

      if (state == CalendarDayState.assigned || state == CalendarDayState.verified) {
        assignedCount++;
      } else if (state == CalendarDayState.missed) {
        missedCount++;
      } else if (state == CalendarDayState.rest) {
        restCount++;
      }
    }

    final totalScheduled = assignedCount + missedCount;
    final percent = totalScheduled == 0 ? 0.0 : assignedCount / totalScheduled;
    final percentInt = (percent * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle) ...[
            Text(
              "Workout Journey",
              style: AppStyles.text18Px.poppins.w600,
            ),
            const SizedBox(height: 12),
          ],
          _buildCalendarCard(
            canGoPrev,
            canGoNext,
            percent,
            percentInt,
            assignedCount,
            missedCount,
            restCount,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(
    bool canGoPrev,
    bool canGoNext,
    double percent,
    int percentInt,
    int assignedCount,
    int missedCount,
    int restCount,
  ) {
    return Container(
      key: _calendarCardKey,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(canGoPrev, canGoNext),
          const SizedBox(height: 12),
          _buildCalendar(),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildColorHint(const Color(0xFF019C37), 'Verified'),
              _buildColorHint(const Color(0xFFD1AC19), 'Assigned'),
              _buildColorHint(const Color(0xFF3949AB), 'Rest'),
              _buildColorHint(const Color(0xFFCF0B10), 'Missed'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey.shade200, thickness: 1),
          ),
          _buildProgress(percent, percentInt, assignedCount, missedCount, restCount),
        ],
      ),
    );
  }

  Widget _buildHeader(bool canGoPrev, bool canGoNext) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: canGoPrev ? AppColors.primary : Colors.grey.shade400,
              ),
              onPressed: canGoPrev
                  ? () {
                      setState(() {
                        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                      });
                      _computeDayStates();
                    }
                  : null,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('yyyy').format(_focusedDay),
                  style: AppStyles.text12Px.poppins.w500.copyWith(
                    color: AppColors.primary.withOpacity(.7),
                  ),
                ),
                Text(
                  DateFormat('MMMM').format(_focusedDay),
                  style: AppStyles.text14Px.poppins.w600.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: canGoNext ? AppColors.primary : Colors.grey.shade400,
              ),
              onPressed: canGoNext
                  ? () {
                      setState(() {
                        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                      });
                      _computeDayStates();
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerVisible: false,
      rowHeight: 42,
      daysOfWeekHeight: 26,
      availableGestures: AvailableGestures.none,
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        _computeDayStates();
      },
      calendarBuilders: CalendarBuilders(
        dowBuilder: (context, day) {
          return Container(
            alignment: Alignment.center,
            child: Text(
              DateFormat.E().format(day).substring(0, 3),
              style: AppStyles.text12Px.poppins.w600.copyWith(color: Colors.grey.shade700),
            ),
          );
        },
        defaultBuilder: (context, day, focusedDay) => _buildDayCell(day),
        todayBuilder: (context, day, focusedDay) => _buildDayCell(day, isToday: true),
        outsideBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildProgress(
    double percent,
    int percentInt,
    int assigned,
    int missed,
    int rest,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 50,
            lineWidth: 10,
            percent: percent,
            animation: true,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: AppColors.primary,
            backgroundColor: Colors.grey.shade200,
            center: Text(
              "$percentInt%\nTotal Done",
              textAlign: TextAlign.center,
              style: AppStyles.text12Px.poppins.w700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                _summaryItem("Completed Days", "$assigned Days", Colors.green.shade100, AppColors.dark),
                const SizedBox(height: 6),
                _summaryItem("Rest Days", "$rest Days", Colors.blue.shade100, AppColors.dark),
                const SizedBox(height: 6),
                _summaryItem("Missed Days", "$missed Days", Colors.red.shade100, AppColors.dark),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _summaryItem(String title, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppStyles.text12Px.poppins.w500)),
          Text(value, style: AppStyles.text12Px.poppins.w700.copyWith(color: textColor)),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime day, {bool isToday = false}) {
    final dateOnly = DateTime(day.year, day.month, day.day);
    final dateKey = DateFormat('yyyy-MM-dd').format(dateOnly);
    final state = _dayStates[dateKey] ?? CalendarDayState.future;

    if (state == CalendarDayState.verified) {
      return _dayState(
        day: day,
        bgColor: const Color(0xFF238644),
        borderColor: isToday ? const Color(0xFFFF9800) : Colors.transparent,
        textColor: const Color(0xFFD3EED8),
      );
    }

    if (state == CalendarDayState.assigned) {
      return _dayState(
        day: day,
        bgColor: const Color(0xFFD1AC19),
        borderColor: isToday ? const Color(0xFFFF9800) : Colors.transparent,
        textColor: const Color(0xFFF6F0D6),
      );
    }

    if (state == CalendarDayState.missed) {
      return _dayState(
        day: day,
        bgColor: const Color(0xFFD32F2F),
        borderColor: isToday ? const Color(0xFFFF9800) : Colors.transparent,
        textColor: const Color(0xFFF9D8DA),
      );
    }

    final isRest = state == CalendarDayState.rest;
    if (isRest) {
      return _dayState(
        day: day,
        bgColor: const Color(0xFF3949AB),
        borderColor: isToday ? const Color(0xFFFF9800) : Colors.transparent,
        textColor: const Color(0xFFE2EAF8),
      );
    }

    final startDateOnly = DateTime(_firstWorkoutDate.year, _firstWorkoutDate.month, _firstWorkoutDate.day);
    final isBeforeStart = dateOnly.isBefore(startDateOnly);
    final isFuture = dateOnly.isAfter(DateTime.now());

    final bgColor = (isBeforeStart || isFuture) ? const Color(0xFFFAFAFA) : const Color(0xFFD32F2F);
    final dayTextColor = (isBeforeStart || isFuture) ? Colors.grey.shade400 : const Color(0xFFF9D8DA);

    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: isToday ? Border.all(color: const Color(0xFFFF9800), width: 1.5) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: AppStyles.text13Px.poppins.w600.copyWith(color: dayTextColor),
      ),
    );
  }

  Widget _dayState({
    required DateTime day,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: borderColor != Colors.transparent ? Border.all(color: borderColor, width: 1.5) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: AppStyles.text13Px.poppins.w600.copyWith(color: textColor),
      ),
    );
  }

  Widget _buildColorHint(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppStyles.text13Px.poppins.w500.copyWith(color: AppColors.textDark),
        ),
      ],
    );
  }
}