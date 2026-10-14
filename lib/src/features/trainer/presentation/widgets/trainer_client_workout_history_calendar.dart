import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/core/services/holiday/gym_holiday_service.dart';
import 'package:table_calendar/table_calendar.dart';

class TrainerClientWorkoutHistoryCalendar extends StatefulWidget {
  const TrainerClientWorkoutHistoryCalendar({
    required this.customerId,
    required this.workoutHistory,
    this.startDate,
    this.showTitle = true,
    this.assignedWorkouts,
    this.organizationId,
    super.key,
  });

  final int customerId;
  final DateTime? startDate;
  final List<Map<String, dynamic>> workoutHistory;
  final bool showTitle;
  final List<dynamic>? assignedWorkouts;
  final int? organizationId;

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
  DateTime? _selectedDay;
  final Map<String, CalendarDayState> _dayStates = {};
  List<dynamic> _internalAssignedWorkouts = [];
  Map<String, String> _monthHolidays = {};

  DateTime get _firstWorkoutDate {
    DateTime earliest =
        widget.startDate ?? DateTime.now().subtract(const Duration(days: 30));
    for (final entry in widget.workoutHistory) {
      final dateStr = entry['date'] as String? ?? '';
      if (dateStr.isEmpty) continue;
      final cleanDateStr = dateStr.split('T').first;
      final parsed =
          DateTime.tryParse(cleanDateStr) ?? DateTime.tryParse(dateStr);
      if (parsed != null && parsed.isBefore(earliest)) {
        earliest = parsed;
      }
    }
    return earliest;
  }

  @override
  void initState() {
    super.initState();
    _fetchHolidaysAndComputeDayStates();
    _fetchAssignedWorkoutsIfNeeded();
  }

  Future<void> _fetchHolidaysAndComputeDayStates() async {
    _computeDayStates();
    try {
      final holidays = await GymHolidayService.getMonthHolidays(
        _focusedDay,
        orgId: widget.organizationId,
      );
      if (mounted) {
        setState(() {
          _monthHolidays = holidays;
          _computeDayStates();
        });
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(
    covariant TrainerClientWorkoutHistoryCalendar oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workoutHistory != widget.workoutHistory ||
        oldWidget.organizationId != widget.organizationId) {
      _fetchHolidaysAndComputeDayStates();
    }
    if (oldWidget.assignedWorkouts != widget.assignedWorkouts) {
      if (widget.assignedWorkouts == null || widget.assignedWorkouts!.isEmpty) {
        _fetchAssignedWorkoutsIfNeeded();
      }
    }
  }

  Future<void> _fetchAssignedWorkoutsIfNeeded() async {
    if (widget.assignedWorkouts != null && widget.assignedWorkouts!.isNotEmpty) {
      return;
    }
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerClientAssignedWorkouts(widget.customerId),
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> list = [];
        if (response.data is List) {
          list = response.data as List<dynamic>;
        } else if (response.data is Map) {
          final m = response.data as Map;
          if (m['results'] is List) {
            list = m['results'] as List;
          } else if (m['data'] is List) {
            list = m['data'] as List;
          }
        }
        if (mounted && list.isNotEmpty) {
          setState(() {
            _internalAssignedWorkouts = list;
          });
        }
      }
    } catch (_) {}
  }

  String? _resolvePlanName(
    DateTime date,
    Map<String, dynamic>? historyEntry,
    List<dynamic> logs,
  ) {
    // 1. Check historyEntry level fields
    if (historyEntry != null) {
      final candidates = [
        historyEntry['plan_name'],
        historyEntry['workout_plan_name'],
        historyEntry['plan_title'],
        historyEntry['routine_name'],
        historyEntry['day_title'],
        historyEntry['day_name'],
        historyEntry['title'],
        if (historyEntry['plan'] is Map) ...[
          historyEntry['plan']['plan_name'],
          historyEntry['plan']['name'],
          historyEntry['plan']['title'],
        ],
        if (historyEntry['plan'] is String) historyEntry['plan'],
        if (historyEntry['workout_plan'] is Map) ...[
          historyEntry['workout_plan']['plan_name'],
          historyEntry['workout_plan']['name'],
          historyEntry['workout_plan']['title'],
        ],
        if (historyEntry['workout_plan'] is String)
          historyEntry['workout_plan'],
        if (historyEntry['customer_workout_plan'] is Map) ...[
          historyEntry['customer_workout_plan']['plan_name'],
          historyEntry['customer_workout_plan']['title'],
          historyEntry['customer_workout_plan']['name'],
        ],
        if (historyEntry['day'] is Map) ...[
          historyEntry['day']['title'],
          historyEntry['day']['name'],
          historyEntry['day']['plan_name'],
        ],
      ];
      for (final c in candidates) {
        if (c != null &&
            c.toString().trim().isNotEmpty &&
            c.toString() != 'null') {
          return c.toString().trim();
        }
      }
    }

    // 2. Check logs level fields
    for (final l in logs) {
      if (l is Map) {
        final candidates = [
          l['plan_name'],
          l['workout_plan_name'],
          l['plan_title'],
          l['routine_name'],
          l['day_title'],
          l['day_name'],
          if (l['plan'] is Map) ...[
            l['plan']['plan_name'],
            l['plan']['name'],
            l['plan']['title'],
          ],
          if (l['plan'] is String) l['plan'],
          if (l['workout_plan'] is Map) ...[
            l['workout_plan']['plan_name'],
            l['workout_plan']['name'],
            l['workout_plan']['title'],
          ],
          if (l['workout_plan'] is String) l['workout_plan'],
          if (l['customer_workout_plan'] is Map) ...[
            l['customer_workout_plan']['plan_name'],
            l['customer_workout_plan']['title'],
            l['customer_workout_plan']['name'],
          ],
          if (l['day'] is Map) ...[
            l['day']['title'],
            l['day']['name'],
            l['day']['plan_name'],
          ],
        ];
        for (final c in candidates) {
          if (c != null &&
              c.toString().trim().isNotEmpty &&
              c.toString() != 'null') {
            return c.toString().trim();
          }
        }
      }
    }

    // 3. Check assigned workouts
    final assigned = (widget.assignedWorkouts != null && widget.assignedWorkouts!.isNotEmpty)
        ? widget.assignedWorkouts!
        : _internalAssignedWorkouts;
    if (assigned.isNotEmpty) {
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      for (final p in assigned) {
        if (p is Map) {
          final pDate =
              (p['scheduled_date'] ?? p['date'] ?? p['assigned_date'] ?? '')
                  .toString()
                  .split('T')
                  .first;
          if (pDate == dateKey) {
            final name = p['plan_name'] ?? p['title'] ?? p['name'];
            if (name != null &&
                name.toString().trim().isNotEmpty &&
                name.toString() != 'null') {
              return name.toString().trim();
            }
          }
        }
      }

      for (final p in assigned) {
        if (p is Map) {
          final startStr = (p['start_date'] ??
                  p['assigned_date'] ??
                  p['created_at'])
              ?.toString()
              .split('T')
              .first;
          final endStr = (p['end_date'] ?? p['expiry_date'])
              ?.toString()
              .split('T')
              .first;
          final startDate =
              startStr != null ? DateTime.tryParse(startStr) : null;
          final endDate = endStr != null ? DateTime.tryParse(endStr) : null;
          final totalDays = (p['total_days'] as num?)?.toInt();

          if (startDate != null &&
              (endDate != null || (totalDays != null && totalDays > 1))) {
            final effectiveEnd = endDate ??
                startDate.add(
                  Duration(days: totalDays! - 1),
                );
            final checkDate = DateTime(date.year, date.month, date.day);
            final checkStart =
                DateTime(startDate.year, startDate.month, startDate.day);
            final checkEnd =
                DateTime(effectiveEnd.year, effectiveEnd.month, effectiveEnd.day);

            if (!checkDate.isBefore(checkStart) && !checkDate.isAfter(checkEnd)) {
              final name = p['plan_name'] ?? p['title'] ?? p['name'];
              if (name != null &&
                  name.toString().trim().isNotEmpty &&
                  name.toString() != 'null') {
                return name.toString().trim();
              }
            }
          }
        }
      }
    }

    return null;
  }

  /// Derives calendar day states locally from the workout history data.
  void _computeDayStates() {
    _dayStates.clear();

    // Build a lookup from the workout history list
    final Map<String, Map<String, dynamic>> historyByDate = {};
    for (final entry in widget.workoutHistory) {
      final dateStr = entry['date'] as String? ?? '';
      if (dateStr.isEmpty) continue;
      final cleanDateStr = dateStr.split('T').first;
      final date =
          DateTime.tryParse(cleanDateStr) ?? DateTime.tryParse(dateStr);
      if (date == null) continue;
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      historyByDate[dateKey] = entry;
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final startDate = _firstWorkoutDate;
    final startDateOnly =
        DateTime(startDate.year, startDate.month, startDate.day);

    // Process all days of the focused month
    final year = _focusedDay.year;
    final month = _focusedDay.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateOnly = DateTime(date.year, date.month, date.day);
      final dateKey = DateFormat('yyyy-MM-dd').format(dateOnly);

      // 1. FIRST: Check if there's a workout history entry for this date!
      // If a workout exists, it takes highest precedence regardless of membership start or future date.
      final historyEntry = historyByDate[dateKey];
      if (historyEntry != null) {
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
              (log['verification_status'] as String?)?.toLowerCase() ==
                  'verified';
        });

        if (isVerified) {
          _dayStates[dateKey] = CalendarDayState.verified;
        } else {
          // Assigned / Logged but not yet verified
          _dayStates[dateKey] = CalendarDayState.assigned;
        }
        continue;
      }

      // 2. Gym holiday check!
      // If the fitness center set a holiday on this date, it is a scheduled rest day (Blue)
      final isGymHoliday = _monthHolidays.containsKey(dateKey);
      if (isGymHoliday) {
        _dayStates[dateKey] = CalendarDayState.rest;
        continue;
      }

      // 3. Only if NO workout history and NOT a gym holiday:
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

      // Past date within membership period with no workout logged → missed
      _dayStates[dateKey] = CalendarDayState.missed;
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
    final canGoPrev =
        currentMonth.isAfter(joinMonth) ||
        currentMonth.isAtSameMomentAs(joinMonth);

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

      if (state == CalendarDayState.assigned ||
          state == CalendarDayState.verified) {
        assignedCount++;
      } else if (state == CalendarDayState.missed) {
        missedCount++;
      } else if (state == CalendarDayState.rest) {
        restCount++;
      }
    }

    final totalScheduled = assignedCount + missedCount;
    final percent =
        totalScheduled == 0 ? 0.0 : assignedCount / totalScheduled;
    final percentInt = (percent * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle) ...[
            Text('Workout Journey', style: AppStyles.text18Px.poppins.w600),
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
            color: Colors.black.withValues(alpha: .04),
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
          _buildProgress(
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

  Widget _buildHeader(bool canGoPrev, bool canGoNext) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.chevron_left,
                color:
                    canGoPrev ? AppColors.primary : Colors.grey.shade400,
              ),
              onPressed:
                  canGoPrev
                      ? () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month - 1,
                            1,
                          );
                        });
                        _fetchHolidaysAndComputeDayStates();
                      }
                      : null,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('yyyy').format(_focusedDay),
                  style: AppStyles.text12Px.poppins.w500.copyWith(
                    color: AppColors.primary.withValues(alpha: .7),
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
                color:
                    canGoNext ? AppColors.primary : Colors.grey.shade400,
              ),
              onPressed:
                  canGoNext
                      ? () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month + 1,
                            1,
                          );
                        });
                        _fetchHolidaysAndComputeDayStates();
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
      rowHeight: 38,
      daysOfWeekHeight: 24,
      availableGestures: AvailableGestures.none,
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        _fetchHolidaysAndComputeDayStates();
      },
      calendarBuilders: CalendarBuilders<dynamic>(
        dowBuilder: (context, day) {
          return Container(
            alignment: Alignment.center,
            child: Text(
              DateFormat.E().format(day).substring(0, 3),
              style: AppStyles.text12Px.poppins.w600.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          );
        },
        defaultBuilder: (context, day, focusedDay) => _buildDayCell(day),
        todayBuilder:
            (context, day, focusedDay) => _buildDayCell(day, isToday: true),
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
              '$percentInt%\nTotal Done',
              textAlign: TextAlign.center,
              style: AppStyles.text12Px.poppins.w700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                _summaryItem(
                  'Completed Days',
                  '$assigned Days',
                  Colors.green.shade100,
                  AppColors.dark,
                ),
                const SizedBox(height: 6),
                _summaryItem(
                  'Rest Days',
                  '$rest Days',
                  Colors.blue.shade100,
                  AppColors.dark,
                ),
                const SizedBox(height: 6),
                _summaryItem(
                  'Missed Days',
                  '$missed Days',
                  Colors.red.shade100,
                  AppColors.dark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
    String title,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppStyles.text12Px.poppins.w500),
          ),
          Text(
            value,
            style: AppStyles.text12Px.poppins.w700.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime day, {bool isToday = false}) {
    final dateOnly = DateTime(day.year, day.month, day.day);
    final dateKey = DateFormat('yyyy-MM-dd').format(dateOnly);
    final state = _dayStates[dateKey] ?? CalendarDayState.future;
    final isSelected =
        _selectedDay != null && isSameDay(_selectedDay, day);

    if (state == CalendarDayState.verified) {
      return _dayState(
        day: day,
        bgColor: const Color(0xFF238644),
        borderColor: isToday ? Colors.black : Colors.transparent,
        textColor: const Color(0xFFD3EED8),
        isSelected: isSelected,
      );
    }

    if (state == CalendarDayState.assigned) {
      return _dayState(
        day: day,
        bgColor: const Color(0xFFD1AC19),
        borderColor: isToday ? Colors.black : Colors.transparent,
        textColor: const Color(0xFFF6F0D6),
        isSelected: isSelected,
      );
    }

    if (state == CalendarDayState.missed) {
      return _dayState(
        day: day,
        bgColor: const Color(0xFFD32F2F),
        borderColor: isToday ? Colors.black : Colors.transparent,
        textColor: const Color(0xFFF9D8DA),
        isSelected: isSelected,
      );
    }

    final isRest = state == CalendarDayState.rest;
    if (isRest) {
      return _dayState(
        day: day,
        bgColor: const Color(0xFF3949AB),
        borderColor: isToday ? Colors.black : Colors.transparent,
        textColor: const Color(0xFFE2EAF8),
        isSelected: isSelected,
      );
    }

    final startDateOnly = DateTime(
      _firstWorkoutDate.year,
      _firstWorkoutDate.month,
      _firstWorkoutDate.day,
    );
    final isBeforeStart = dateOnly.isBefore(startDateOnly);
    final isFuture = dateOnly.isAfter(DateTime.now());

    final bgColor =
        (isBeforeStart || isFuture)
            ? const Color(0xFFFAFAFA)
            : const Color(0xFFD32F2F);
    final dayTextColor =
        (isBeforeStart || isFuture)
            ? Colors.grey.shade400
            : const Color(0xFFF9D8DA);

    return _dayState(
      day: day,
      bgColor: bgColor,
      borderColor: isToday ? Colors.black : Colors.transparent,
      textColor: dayTextColor,
      isSelected: isSelected,
    );
  }

  Widget _dayState({
    required DateTime day,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    bool isSelected = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedDay = day;
        });
        _showDayWorkoutBottomSheet(day);
      },
      child: Center(
        child: Container(
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border:
                isSelected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : (borderColor != Colors.transparent
                        ? Border.all(color: borderColor, width: 1.5)
                        : null),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                    : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: AppStyles.text13Px.poppins.w600.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }

  void _showDayWorkoutBottomSheet(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);

    // Find the history entry for this date
    Map<String, dynamic>? historyEntry;
    for (final entry in widget.workoutHistory) {
      final dateStr = entry['date'] as String? ?? '';
      if (dateStr.isEmpty) continue;
      final cleanDateStr = dateStr.split('T').first;
      final entryDate =
          DateTime.tryParse(cleanDateStr) ?? DateTime.tryParse(dateStr);
      if (entryDate != null &&
          entryDate.year == date.year &&
          entryDate.month == date.month &&
          entryDate.day == date.day) {
        historyEntry = entry;
        break;
      }
    }

    final logs = (historyEntry?['logs'] as List<dynamic>?) ?? [];
    final state = _dayStates[dateKey] ??
        (historyEntry != null
            ? CalendarDayState.assigned
            : CalendarDayState.future);
    final planName = _resolvePlanName(date, historyEntry, logs);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header with Date and Status badge
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMM d, yyyy').format(date),
                            style: AppStyles.text16Px.poppins.w600.dark,
                          ),
                          const SizedBox(height: 2),
                          if (planName != null && planName.isNotEmpty) ...[
                            Text(
                              planName,
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                          ] else if (_monthHolidays[dateKey] != null) ...[
                            Text(
                              _monthHolidays[dateKey]!,
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: const Color(0xFF3949AB),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            'Workout History Details',
                            style: AppStyles.text12Px.poppins.w400.textGrey,
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(
                      state,
                      hasLogs: logs.isNotEmpty,
                      isHoliday: _monthHolidays.containsKey(dateKey),
                    ),
                  ],
                ),
              ),

              const Divider(height: 24, thickness: 1),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: _buildDayWorkoutContent(
                    date,
                    state,
                    logs,
                    historyEntry,
                    planName: planName,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(
    CalendarDayState state, {
    bool hasLogs = false,
    bool isHoliday = false,
  }) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    switch (state) {
      case CalendarDayState.verified:
        bgColor = const Color(0xffE8F5E9);
        textColor = const Color(0xFF238644);
        icon = Icons.check_circle;
        label = 'Verified';
      case CalendarDayState.assigned:
        bgColor = const Color(0xffFFF8E1);
        textColor = const Color(0xFFD1AC19);
        icon = Icons.schedule;
        label = hasLogs ? 'Logged' : 'Assigned';
      case CalendarDayState.rest:
        bgColor = const Color(0xffE8EAF6);
        textColor = const Color(0xFF3949AB);
        icon = Icons.nightlight_round;
        label = isHoliday ? 'Gym Holiday' : 'Rest Day';
      case CalendarDayState.missed:
        bgColor = const Color(0xffFFEBEE);
        textColor = const Color(0xFFD32F2F);
        icon = Icons.cancel;
        label = 'Missed';
      case CalendarDayState.future:
        if (isHoliday) {
          bgColor = const Color(0xffE8EAF6);
          textColor = const Color(0xFF3949AB);
          icon = Icons.beach_access_rounded;
          label = 'Gym Holiday';
        } else {
          bgColor = const Color(0xffF5F5F5);
          textColor = Colors.grey.shade600;
          icon = Icons.event;
          label = 'Upcoming';
        }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppStyles.text12Px.poppins.w600.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDayWorkoutContent(
    DateTime date,
    CalendarDayState state,
    List<dynamic> logs,
    Map<String, dynamic>? historyEntry, {
    String? planName,
  }) {
    if (state == CalendarDayState.rest) {
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final holidayName = _monthHolidays[dateKey];
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xffE8EAF6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF3949AB).withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                holidayName != null ? Icons.beach_access_rounded : Icons.nightlight_round,
                color: const Color(0xFF3949AB),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              holidayName != null && holidayName.isNotEmpty
                  ? 'Gym Holiday: $holidayName'
                  : 'Rest & Recovery Day',
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: const Color(0xFF3949AB),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              holidayName != null && holidayName.isNotEmpty
                  ? 'Gym was closed on this day for $holidayName.'
                  : 'Scheduled rest day for muscle recovery and adaptation.',
              textAlign: TextAlign.center,
              style: AppStyles.text12Px.poppins.w400.textGrey,
            ),
          ],
        ),
      );
    }

    if (logs.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (planName != null && planName.isNotEmpty) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xffF9F9F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WORKOUT PLAN',
                          style: AppStyles.text10Px.poppins.w600.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          planName,
                          style: AppStyles.text15Px.poppins.w600.dark,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              const Icon(
                Icons.fitness_center,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Exercises (${logs.length})',
                style: AppStyles.text14Px.poppins.w600.dark,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...logs.map((log) {
            final logMap =
                log is Map ? Map<String, dynamic>.from(log) : <String, dynamic>{};
            final workoutName =
                logMap['workout_name'] ?? logMap['exercise_name'] ?? 'Exercise';
            final isVerified =
                logMap['is_verified'] == true ||
                logMap['is_verified'] == 'true' ||
                (logMap['verification_status'] as String?)?.toLowerCase() ==
                    'verified';
            final setLogs =
                (logMap['set_logs'] as List<dynamic>?) ??
                (logMap['sets'] as List<dynamic>?) ??
                [];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xffF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isVerified
                          ? const Color(0xFF238644).withValues(alpha: 0.25)
                          : Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          workoutName as String,
                          style: AppStyles.text14Px.poppins.w600.dark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isVerified
                                  ? const Color(0xffE8F5E9)
                                  : const Color(0xffFFF8E1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isVerified
                                  ? Icons.check_circle
                                  : Icons.schedule,
                              size: 12,
                              color:
                                  isVerified
                                      ? const Color(0xFF238644)
                                      : const Color(0xFFD1AC19),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isVerified ? 'Verified' : 'Logged',
                              style: AppStyles.text10Px.poppins.w600.copyWith(
                                color:
                                    isVerified
                                        ? const Color(0xFF238644)
                                        : const Color(0xFFD1AC19),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (setLogs.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < setLogs.length; i++) ...[
                            () {
                              final setMap =
                                  setLogs[i] is Map
                                      ? Map<String, dynamic>.from(
                                        setLogs[i] as Map,
                                      )
                                      : <String, dynamic>{};
                              final setNum =
                                  setMap['set_number'] ?? (i + 1);
                              final reps = setMap['reps'] ?? 0;
                              final weight =
                                  setMap['weight_kg'] ??
                                  setMap['weight'] ??
                                  0.0;
                              final isSetVerified =
                                  setMap['is_verified'] == true;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 4,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Set $setNum',
                                        style: AppStyles
                                            .text10Px
                                            .poppins
                                            .w600
                                            .copyWith(
                                              color: AppColors.primary,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '$weight kg × $reps reps',
                                        style:
                                            AppStyles
                                                .text12Px
                                                .poppins
                                                .w500
                                                .dark,
                                      ),
                                    ),
                                    if (isSetVerified)
                                      const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Color(0xFF238644),
                                      ),
                                  ],
                                ),
                              );
                            }(),
                            if (i < setLogs.length - 1)
                              const Divider(height: 6, thickness: 0.5),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      );
    }

    // No logs
    if (state == CalendarDayState.missed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xffFFEBEE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD32F2F).withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_outlined,
                color: Color(0xFFD32F2F),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Missed Workout',
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: const Color(0xFFD32F2F),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No workout session was logged on this day.',
              textAlign: TextAlign.center,
              style: AppStyles.text12Px.poppins.w400.textGrey,
            ),
          ],
        ),
      );
    }

    if (state == CalendarDayState.assigned) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xffFFF8E1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD1AC19).withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.schedule,
                color: Color(0xFFD1AC19),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              planName != null && planName.isNotEmpty
                  ? planName
                  : 'Assigned Workout',
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: const Color(0xFFD1AC19),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              planName != null && planName.isNotEmpty
                  ? 'Plan "$planName" assigned for this day, awaiting completion/verification.'
                  : 'Workout plan assigned for this day, awaiting completion/verification.',
              textAlign: TextAlign.center,
              style: AppStyles.text12Px.poppins.w400.textGrey,
            ),
          ],
        ),
      );
    }

    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final holidayName = _monthHolidays[dateKey];
    if (holidayName != null && holidayName.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xffE8EAF6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF3949AB).withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.beach_access_rounded,
                color: Color(0xFF3949AB),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upcoming Gym Holiday',
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: const Color(0xFF3949AB),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fitness center is closed for $holidayName.',
              textAlign: TextAlign.center,
              style: AppStyles.text12Px.poppins.w400.textGrey,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available,
              color: Colors.grey.shade600,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Upcoming Schedule',
            style: AppStyles.text16Px.poppins.w600.dark,
          ),
          const SizedBox(height: 4),
          Text(
            'No workout history logged yet for this future date.',
            textAlign: TextAlign.center,
            style: AppStyles.text12Px.poppins.w400.textGrey,
          ),
        ],
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
          style: AppStyles.text13Px.poppins.w500.copyWith(
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}