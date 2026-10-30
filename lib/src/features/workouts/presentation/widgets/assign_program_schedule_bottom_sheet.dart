import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/core/services/holiday/gym_holiday_service.dart';

class ProgramScheduleResult {
  final String action; // 'assign', 'customize', 'cancel'
  final int targetPlanId;
  final DateTime startDate;
  final DateTime endDate;
  final List<Map<String, dynamic>> scheduleDays;
  final String notes;

  ProgramScheduleResult({
    required this.action,
    required this.targetPlanId,
    required this.startDate,
    required this.endDate,
    required this.scheduleDays,
    this.notes = '',
  });
}

class _ScheduledDayInfo {
  final DateTime date;
  final bool isRestDay;
  final Map<String, dynamic>? workout;

  _ScheduledDayInfo({
    required this.date,
    required this.isRestDay,
    this.workout,
  });
}

class AssignProgramScheduleBottomSheet extends StatefulWidget {
  final int programId;
  final String programTitle;
  final List<Map<String, dynamic>>? preloadedDays;
  final int? clientOrgId;
  final bool showCustomize;

  const AssignProgramScheduleBottomSheet({
    required this.programId,
    required this.programTitle,
    this.preloadedDays,
    this.clientOrgId,
    this.showCustomize = true,
    super.key,
  });

  static Future<ProgramScheduleResult?> show({
    required BuildContext context,
    required int programId,
    required String programTitle,
    List<Map<String, dynamic>>? preloadedDays,
    int? clientOrgId,
    bool showCustomize = true,
  }) {
    return showModalBottomSheet<ProgramScheduleResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AssignProgramScheduleBottomSheet(
        programId: programId,
        programTitle: programTitle,
        preloadedDays: preloadedDays,
        clientOrgId: clientOrgId,
        showCustomize: showCustomize,
      ),
    );
  }

  @override
  State<AssignProgramScheduleBottomSheet> createState() =>
      _AssignProgramScheduleBottomSheetState();
}

class _AssignProgramScheduleBottomSheetState
    extends State<AssignProgramScheduleBottomSheet> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _workouts = [];
  final TextEditingController _notesController = TextEditingController();

  int? _targetPlanId;
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final Set<String> _restDates = {}; // YYYY-MM-DD
  Map<String, String> _monthHolidays = {};

  @override
  void initState() {
    super.initState();
    if (widget.preloadedDays != null && widget.preloadedDays!.isNotEmpty) {
      _extractWorkoutsAndRestDays(widget.preloadedDays!);
    } else {
      _fetchProgramDetails();
    }
    _fetchHolidaysForMonth(_focusedMonth);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _extractWorkoutsAndRestDays(List<dynamic> rawDays) {
    _workouts = [];
    _restDates.clear();

    for (int i = 0; i < rawDays.length; i++) {
      final map = Map<String, dynamic>.from(rawDays[i] as Map);
      final bool isRest = map['is_rest_day'] == true;
      if (isRest) {
        final assignedDate = _startDate.add(Duration(days: i));
        _restDates.add(_formatDateKey(assignedDate));
      } else {
        _workouts.add(map);
      }
    }

    if (_workouts.isEmpty && rawDays.isNotEmpty) {
      // In case all were marked rest or empty, treat all as items
      _workouts = rawDays.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    setState(() {});
  }

  Future<void> _fetchProgramDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dio = DioClient().dio;
      dynamic groupPlansRes;
      try {
        groupPlansRes = await dio.get<dynamic>(
          ApiUris.multiDayWorkouts,
          queryParameters: {'group': widget.programId},
          options: Options(headers: {'X-Platform': platformSource}),
        );
      } catch (_) {
        groupPlansRes = null;
      }

      List plansList = [];
      if (groupPlansRes != null && groupPlansRes.statusCode == 200) {
        if (groupPlansRes.data is List) {
          plansList = groupPlansRes.data as List;
        } else if (groupPlansRes.data is Map && groupPlansRes.data['results'] is List) {
          plansList = groupPlansRes.data['results'] as List;
        }
      }

      if (plansList.isEmpty) {
        try {
          final wpRes = await dio.get<dynamic>(
            ApiUris.workoutPlans,
            queryParameters: {'group': widget.programId},
            options: Options(headers: {'X-Platform': platformSource}),
          );
          if (wpRes.statusCode == 200) {
            if (wpRes.data is List) {
              plansList = wpRes.data as List;
            } else if (wpRes.data is Map && wpRes.data['results'] is List) {
              plansList = wpRes.data['results'] as List;
            }
          }
        } catch (_) {}
      }

      final int targetId = plansList.isNotEmpty ? (plansList[0]['id'] as int) : widget.programId;
      _targetPlanId = targetId;

      dynamic planDetailRes;
      try {
        planDetailRes = await dio.get<dynamic>(
          ApiUris.multiDayWorkoutDetail(targetId),
          options: Options(headers: {'X-Platform': platformSource}),
        );
      } catch (_) {
        try {
          planDetailRes = await dio.get<dynamic>(
            ApiUris.workoutPlanDetail(targetId),
            options: Options(headers: {'X-Platform': platformSource}),
          );
        } catch (_) {}
      }

      if (planDetailRes != null && planDetailRes.statusCode == 200 && planDetailRes.data is Map) {
        final rawDays = planDetailRes.data['days'] as List? ?? [];
        if (rawDays.isNotEmpty) {
          _extractWorkoutsAndRestDays(rawDays);
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchHolidaysForMonth(DateTime month) async {
    try {
      final holidays = await GymHolidayService.getMonthHolidays(
        month,
        orgId: widget.clientOrgId,
      );
      if (mounted) {
        setState(() {
          _monthHolidays = holidays;
        });
      }
    } catch (_) {}
  }

  String _formatDateKey(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  List<_ScheduledDayInfo> _calculateSchedule() {
    final List<_ScheduledDayInfo> schedule = [];
    if (_workouts.isEmpty) return schedule;

    DateTime current = _startDate;
    int workoutIndex = 0;

    // Guard against infinite loop with max 180 days limit
    int iterations = 0;
    while (workoutIndex < _workouts.length && iterations < 180) {
      final key = _formatDateKey(current);
      if (_restDates.contains(key)) {
        schedule.add(_ScheduledDayInfo(
          date: current,
          isRestDay: true,
        ));
      } else {
        schedule.add(_ScheduledDayInfo(
          date: current,
          isRestDay: false,
          workout: _workouts[workoutIndex],
        ));
        workoutIndex++;
      }
      current = current.add(const Duration(days: 1));
      iterations++;
    }

    return schedule;
  }

  void _onDateCellTapped(DateTime date) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (date.isBefore(today)) {
      Dialogs.showSnack(msg: 'Cannot schedule workouts on past dates');
      return;
    }

    final schedule = _calculateSchedule();
    if (schedule.isEmpty) return;

    final firstDate = schedule.first.date;
    final lastDate = schedule.last.date;
    final dateKey = _formatDateKey(date);

    final isWithinRange = !date.isBefore(firstDate) && !date.isAfter(lastDate);

    setState(() {
      if (!isWithinRange) {
        // Tapped outside range: Shift the entire program to start from this date
        _startDate = date;
        _restDates.clear();
      } else {
        // Tapped within current schedule range: Toggle rest / workout
        if (_restDates.contains(dateKey)) {
          // It was a rest day, turn it back into a workout day
          _restDates.remove(dateKey);
        } else {
          // It was a workout day, mark it as a rest day (subsequent workouts shift +1 day)
          _restDates.add(dateKey);
        }
      }
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + offset, 1);
    });
    _fetchHolidaysForMonth(_focusedMonth);
  }

  @override
  Widget build(BuildContext context) {
    final schedule = _calculateSchedule();
    final DateTime? endDate = schedule.isNotEmpty ? schedule.last.date : null;
    final int totalDays = schedule.length;
    final int workoutCount = _workouts.length;
    final int restCount = schedule.where((s) => s.isRestDay).length;

    // Check if start date or any workout date hits gym holidays
    final holidayWarnings = <String>[];
    for (final s in schedule) {
      final key = _formatDateKey(s.date);
      if (!s.isRestDay && _monthHolidays.containsKey(key)) {
        holidayWarnings.add("${DateFormat('d MMM').format(s.date)} (${_monthHolidays[key]})");
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet Header with Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assign schedule',
                      style: AppStyles.text18Px.poppins.w600.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Plan workouts. Make room for rest.',
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else ...[
              // Calendar Card
              _buildCalendarCard(schedule, endDate, totalDays),
              const SizedBox(height: 14),

              // Holiday warning banner if any workout falls on a gym holiday
              if (holidayWarnings.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCD34D)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFD97706)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Gym holiday on: ${holidayWarnings.join(", ")}. Tap that date to mark as a rest day.',
                          style: AppStyles.text12Px.poppins.w500.copyWith(
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Info Tip Box
              _buildInfoTipBox(schedule, restCount),
              const SizedBox(height: 16),

              // Summary Section
              _buildSummarySection(workoutCount, restCount, schedule),
              const SizedBox(height: 16),

              // Trainer Notes Field (Optional)
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Trainer notes (Optional)',
                  hintStyle: AppStyles.text12Px.poppins.w400.copyWith(
                    color: AppColors.textGrey,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Actions (Customize & Assign)
              Row(
                children: [
                  if (widget.showCustomize) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            ProgramScheduleResult(
                              action: 'customize',
                              targetPlanId: _targetPlanId ?? widget.programId,
                              startDate: _startDate,
                              endDate: endDate ?? _startDate,
                              scheduleDays: _buildPayloadDays(schedule),
                              notes: _notesController.text.trim(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Customize',
                          style: AppStyles.text14Px.poppins.w600.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: widget.showCustomize ? 2 : 1,
                    child: ElevatedButton(
                      onPressed: () {
                        if (schedule.isEmpty) return;
                        Navigator.pop(
                          context,
                          ProgramScheduleResult(
                            action: 'assign',
                            targetPlanId: _targetPlanId ?? widget.programId,
                            startDate: _startDate,
                            endDate: endDate ?? _startDate,
                            scheduleDays: _buildPayloadDays(schedule),
                            notes: _notesController.text.trim(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Assign',
                        style: AppStyles.text14Px.poppins.w600.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _buildPayloadDays(List<_ScheduledDayInfo> schedule) {
    final List<Map<String, dynamic>> result = [];
    int wCount = 1;

    for (final item in schedule) {
      final dateStr = _formatDateKey(item.date);
      if (item.isRestDay) {
        result.add({
          'date': dateStr,
          'title': 'Rest Day',
          'plan_name': 'Rest Day',
          'plan_id': 0,
          'is_rest_day': true,
        });
      } else {
        final workout = item.workout ?? {};
        final int pId = (workout['child_plan_id'] as int?) ??
            ((workout['child_plan'] is Map)
                ? (workout['child_plan']['id'] as int?)
                : null) ??
            (workout['plan'] as int?) ??
            (workout['plan_id'] as int?) ??
            (workout['id'] as int? ?? 0);

        final String dayTitle = (workout['effective_title'] as String?) ??
            (workout['child_plan_title'] as String?) ??
            ((workout['child_plan'] is Map)
                ? ((workout['child_plan']['name'] ??
                        workout['child_plan']['title'] ??
                        workout['child_plan']['plan_name']) as String?)
                : null) ??
            (workout['plan_name'] as String?) ??
            (workout['name'] as String?) ??
            (workout['title'] as String?) ??
            'Day $wCount';

        result.add({
          'date': dateStr,
          'title': dayTitle,
          'plan_name': dayTitle,
          'plan_id': pId,
          'is_rest_day': false,
        });
        wCount++;
      }
    }
    return result;
  }

  Widget _buildCalendarCard(
    List<_ScheduledDayInfo> schedule,
    DateTime? endDate,
    int totalDays,
  ) {
    final monthName = DateFormat('MMMM').format(_focusedMonth);
    final yearStr = DateFormat('yyyy').format(_focusedMonth);

    String rangeStr = '';
    if (endDate != null) {
      if (_startDate.month == endDate.month) {
        rangeStr = "${_startDate.day}–${endDate.day} ${DateFormat('MMMM').format(_startDate)} · $totalDays days";
      } else {
        rangeStr = "${_startDate.day} ${DateFormat('MMM').format(_startDate)} – ${endDate.day} ${DateFormat('MMM').format(endDate)} · $totalDays days";
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Year & Navigation Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$monthName ',
                      style: AppStyles.text16Px.poppins.w700.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    TextSpan(
                      text: yearStr,
                      style: AppStyles.text16Px.poppins.w700.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _changeMonth(-1),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        size: 20,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _changeMonth(1),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (rangeStr.isNotEmpty)
            Text(
              'Selected range: $rangeStr',
              style: AppStyles.text12Px.poppins.w400.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
          const SizedBox(height: 16),

          // Weekdays Mon - Sun
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _WeekdayLabel('Mon'),
              _WeekdayLabel('Tue'),
              _WeekdayLabel('Wed'),
              _WeekdayLabel('Thu'),
              _WeekdayLabel('Fri'),
              _WeekdayLabel('Sat'),
              _WeekdayLabel('Sun'),
            ],
          ),
          const SizedBox(height: 8),

          // Days Grid
          _buildDaysGrid(schedule),

          const Divider(color: Color(0xFFF3F4F6), height: 24, thickness: 1),

          // Legend
          Row(
            children: [
              const Icon(Icons.check, size: 14, color: Color(0xFFDC2626)),
              const SizedBox(width: 6),
              Text(
                'Workout',
                style: AppStyles.text12Px.poppins.w500.copyWith(
                  color: const Color(0xFF374151),
                ),
              ),
              const SizedBox(width: 24),
              const Icon(Icons.nightlight_round, size: 13, color: Color(0xFF2563EB)),
              const SizedBox(width: 6),
              Text(
                'Rest day',
                style: AppStyles.text12Px.poppins.w500.copyWith(
                  color: const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaysGrid(List<_ScheduledDayInfo> schedule) {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final int leadingEmptyDays = (firstDayOfMonth.weekday - 1) % 7; // Monday = 1

    final prevMonthLastDay = DateTime(_focusedMonth.year, _focusedMonth.month, 0).day;

    final scheduleMap = <String, _ScheduledDayInfo>{};
    for (final s in schedule) {
      scheduleMap[_formatDateKey(s.date)] = s;
    }

    final totalCells = ((leadingEmptyDays + daysInMonth + 6) ~/ 7) * 7;
    final rowsCount = totalCells ~/ 7;

    return Column(
      children: List.generate(rowsCount, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayOffset = cellIndex - leadingEmptyDays + 1;

              DateTime date;
              bool isCurrentMonth = true;

              if (dayOffset < 1) {
                // Leading days from previous month
                final prevDay = prevMonthLastDay + dayOffset;
                date = DateTime(_focusedMonth.year, _focusedMonth.month - 1, prevDay);
                isCurrentMonth = false;
              } else if (dayOffset > daysInMonth) {
                // Trailing days from next month
                final nextDay = dayOffset - daysInMonth;
                date = DateTime(_focusedMonth.year, _focusedMonth.month + 1, nextDay);
                isCurrentMonth = false;
              } else {
                date = DateTime(_focusedMonth.year, _focusedMonth.month, dayOffset);
              }

              final dateKey = _formatDateKey(date);
              final scheduledInfo = scheduleMap[dateKey];

              return _buildDayCell(date, scheduledInfo, isCurrentMonth);
            }),
          ),
        );
      }),
    );
  }

  Widget _buildDayCell(
    DateTime date,
    _ScheduledDayInfo? scheduledInfo,
    bool isCurrentMonth,
  ) {
    final bool isScheduled = scheduledInfo != null;
    final bool isRest = scheduledInfo?.isRestDay ?? false;

    Color? bgColor;
    Color textColor = isCurrentMonth ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF);
    BoxBorder? border;

    if (isScheduled) {
      if (isRest) {
        bgColor = const Color(0xFFEFF6FF); // Soft blue
        textColor = const Color(0xFF2563EB); // Blue text
        border = Border.all(color: const Color(0xFF93C5FD), width: 1.2);
      } else {
        bgColor = const Color(0xFFFFECEF); // Soft pink
        textColor = const Color(0xFFB91C1C); // Red text
      }
    }

    return GestureDetector(
      onTap: () => _onDateCellTapped(date),
      child: Container(
        width: 38,
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: border,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: AppStyles.text13Px.poppins.copyWith(
                fontWeight: isScheduled ? FontWeight.w700 : FontWeight.w400,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            if (isScheduled) ...[
              if (isRest)
                const Icon(
                  Icons.nightlight_round,
                  size: 11,
                  color: Color(0xFF2563EB),
                )
              else
                const Icon(
                  Icons.check,
                  size: 12,
                  color: Color(0xFFDC2626),
                ),
            ] else ...[
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTipBox(List<_ScheduledDayInfo> schedule, int restCount) {
    String tip;
    if (restCount == 0) {
      if (schedule.isNotEmpty) {
        final startStr = DateFormat('d').format(schedule.first.date);
        final endStr = DateFormat('d MMMM').format(schedule.last.date);
        tip = 'Tap a date from $startStr–$endStr to mark it as a rest day. Tap again for a workout.';
      } else {
        tip = 'Tap any workout date to mark it as a rest day.';
      }
    } else {
      tip = 'Tap a workout date to add rest. Later workouts shift one day.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: Color(0xFF6B7280),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: AppStyles.text12Px.poppins.w400.copyWith(
                color: const Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
    int workoutCount,
    int restCount,
    List<_ScheduledDayInfo> schedule,
  ) {
    String subtitle;
    if (restCount == 0) {
      subtitle = 'All $workoutCount selected dates are workout days.';
    } else {
      final restDays = schedule.where((s) => s.isRestDay).toList();
      final restDatesStr = restDays
          .map((r) => "${r.date.day} ${DateFormat('MMMM').format(r.date)}")
          .join(', ');

      final lastRestDate = restDays.last.date;
      final remainingWorkouts = schedule
          .where((s) => !s.isRestDay && s.date.isAfter(lastRestDate))
          .toList();

      if (remainingWorkouts.isNotEmpty) {
        final firstNext = remainingWorkouts.first.date;
        final lastNext = remainingWorkouts.last.date;
        String contRange;
        if (firstNext.month == lastNext.month) {
          contRange = "${firstNext.day}–${lastNext.day} ${DateFormat('MMMM').format(lastNext)}";
        } else {
          contRange = "${firstNext.day} ${DateFormat('MMM').format(firstNext)} – ${lastNext.day} ${DateFormat('MMM').format(lastNext)}";
        }
        subtitle = '$restDatesStr is rest. Workouts continue $contRange.';
      } else {
        subtitle = '$restDatesStr is rest.';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$workoutCount workouts · $restCount ${restCount == 1 ? 'rest day' : 'rest days'}',
          style: AppStyles.text14Px.poppins.w600.copyWith(
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppStyles.text12Px.poppins.w400.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      child: Center(
        child: Text(
          label,
          style: AppStyles.text12Px.poppins.w400.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
