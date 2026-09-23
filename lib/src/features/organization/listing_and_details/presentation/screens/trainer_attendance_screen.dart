import 'dart:math' as math;
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/domain/model/trainer_attendance_model.dart';

class TrainerAttendanceScreen extends StatefulWidget {
  final int orgId;
  const TrainerAttendanceScreen({super.key, required this.orgId});

  @override
  State<TrainerAttendanceScreen> createState() => _TrainerAttendanceScreenState();
}

class _TrainerAttendanceScreenState extends State<TrainerAttendanceScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  
  // Daily tab state
  DateTime _selectedDate = DateTime.now();
  bool _isDailyLoading = true;
  List<TrainerAttendanceDay> _dailyRecords = [];
  final Set<int> _expandedTrainerIds = {};

  // Reports tab state
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isReportLoading = true;
  TrainerAttendanceReport? _reportData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && _reportData == null) {
        _fetchReports();
      }
    });
    _fetchDailyAttendance();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDailyAttendance() async {
    setState(() {
      _isDailyLoading = true;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final response = await DioClient().dio.get<dynamic>(
        '${ApiUris.trainerAttendance}?organization_id=${widget.orgId}&date=$dateStr',
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final list = data['trainers'] as List<dynamic>? ?? [];
        setState(() {
          _dailyRecords = list.map((e) => TrainerAttendanceDay.fromJson(e as Map<String, dynamic>)).toList();
        });
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Failed to load trainer attendance.');
    } finally {
      setState(() {
        _isDailyLoading = false;
      });
    }
  }

  Future<void> _fetchReports() async {
    setState(() {
      _isReportLoading = true;
    });

    try {
      final startStr = DateFormat('yyyy-MM-dd').format(_startDate);
      final endStr = DateFormat('yyyy-MM-dd').format(_endDate);
      final response = await DioClient().dio.get<dynamic>(
        '${ApiUris.trainerAttendanceReports}?organization_id=${widget.orgId}&start_date=$startStr&end_date=$endStr',
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 && response.data is Map) {
        setState(() {
          _reportData = TrainerAttendanceReport.fromJson(response.data as Map<String, dynamic>);
        });
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Failed to load attendance summary.');
    } finally {
      setState(() {
        _isReportLoading = false;
      });
    }
  }

  Future<void> _saveBulkAttendance() async {
    setState(() {
      _isDailyLoading = true;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final payload = {
        'organization_id': widget.orgId,
        'date': dateStr,
        'attendance': _dailyRecords.map((e) => e.toJson()).toList(),
      };

      final response = await DioClient().dio.post<dynamic>(
        ApiUris.trainerAttendance,
        data: payload,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(msg: 'Trainer attendance saved successfully!');
        _fetchDailyAttendance();
        if (_tabController.index == 1 || _reportData != null) {
          _fetchReports();
        }
      } else {
        Dialogs.showSnack(msg: 'Failed to save attendance.');
        setState(() => _isDailyLoading = false);
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error saving attendance.');
      setState(() => _isDailyLoading = false);
    }
  }

  Future<void> _deleteSession(int recordIndex, int sessionId) async {
    setState(() {
      _isDailyLoading = true;
    });

    try {
      final response = await DioClient().dio.delete<dynamic>(
        ApiUris.trainerAttendanceSessionDelete(sessionId),
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Dialogs.showSnack(msg: 'Session deleted.');
        _fetchDailyAttendance();
      } else {
        Dialogs.showSnack(msg: 'Failed to delete session.');
        setState(() => _isDailyLoading = false);
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error deleting session.');
      setState(() => _isDailyLoading = false);
    }
  }

  void _showStatusSelector(int recordIndex) {
    final record = _dailyRecords[recordIndex];
    final statuses = [
      (value: 'full_day', label: 'Full Day', color: const Color(0xff27AE60)),
      (value: 'half_day', label: 'Half Day', color: const Color(0xffF39C12)),
      (value: 'leave', label: 'Leave', color: const Color(0xffC0392B)),
      (value: 'holiday', label: 'Holiday', color: const Color(0xff2980B9)),
      (value: 'not_marked', label: 'Not Marked', color: const Color(0xff7F8C8D)),
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mark Attendance: ${record.trainerName}',
                style: AppStyles.text14Px.poppins.w600.dark,
              ),
              const SizedBox(height: 12),
              ...statuses.map((status) {
                final isSelected = record.status == status.value;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 8,
                    backgroundColor: status.color,
                  ),
                  title: Text(
                    status.label,
                    style: isSelected 
                        ? AppStyles.text14Px.poppins.w600.copyWith(color: status.color)
                        : AppStyles.text14Px.poppins.w400.dark,
                  ),
                  trailing: isSelected ? Icon(Icons.check, color: status.color) : null,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _dailyRecords[recordIndex] = record.copyWith(status: status.value);
                    });
                  },
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addTimeSession(int recordIndex) async {
    final checkIn = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Select Check-in Time',
    );
    if (checkIn == null) return;

    if (!mounted) return;
    final checkOut = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 17, minute: 0),
      helpText: 'Select Check-out Time',
    );
    if (checkOut == null) return;

    final formatCheckIn = '${checkIn.hour.toString().padLeft(2, '0')}:${checkIn.minute.toString().padLeft(2, '0')}';
    final formatCheckOut = '${checkOut.hour.toString().padLeft(2, '0')}:${checkOut.minute.toString().padLeft(2, '0')}';

    final record = _dailyRecords[recordIndex];
    final updatedSessions = List<AttendanceSession>.from(record.sessions)
      ..add(AttendanceSession(checkIn: formatCheckIn, checkOut: formatCheckOut));

    setState(() {
      _dailyRecords[recordIndex] = record.copyWith(sessions: updatedSessions);
    });
  }

  Widget _getStatusPill(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'full_day':
        bg = const Color(0xffE8F8F5);
        fg = const Color(0xff117A65);
        label = 'Full Day';
        break;
      case 'half_day':
        bg = const Color(0xffFEF5E7);
        fg = const Color(0xffD35400);
        label = 'Half Day';
        break;
      case 'leave':
        bg = const Color(0xffFDEDEC);
        fg = const Color(0xffC0392B);
        label = 'Leave';
        break;
      case 'holiday':
        bg = const Color(0xffEAF2F8);
        fg = const Color(0xff2471A3);
        label = 'Holiday';
        break;
      default:
        bg = const Color(0xffF2F4F4);
        fg = const Color(0xff7F8C8D);
        label = 'Not Marked';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppStyles.text12Px.poppins.w600.copyWith(color: fg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const PopButton().center,
        title: Text(
          'Trainer Attendance',
          style: AppStyles.text18Px.poppins.w600.dark,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGrey,
          labelStyle: AppStyles.text14Px.poppins.w600,
          unselectedLabelStyle: AppStyles.text14Px.poppins.w400,
          tabs: const [
            Tab(text: 'Daily Log'),
            Tab(text: 'Summary & Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildDailyTab() {
    return Column(
      children: [
        // Date selector
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                  });
                  _fetchDailyAttendance();
                },
                icon: const Icon(Icons.arrow_back_ios, size: 16, color: AppColors.textGrey),
              ),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                    _fetchDailyAttendance();
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                      style: AppStyles.text14Px.poppins.w600.dark,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                  });
                  _fetchDailyAttendance();
                },
                icon: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xffEEEEEE)),
        // Daily list
        Expanded(
          child: _isDailyLoading
              ? const Center(child: CircularProgressIndicator())
              : _dailyRecords.isEmpty
                  ? Center(
                      child: Text(
                        'No trainers assigned to this organization',
                        style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _dailyRecords.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final record = _dailyRecords[index];
                        final isExpanded = _expandedTrainerIds.contains(record.trainerId);

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xffEEEEEE)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.01),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top info row
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    ClipOval(
                                      child: ProfileImage(
                                        isEdit: false,
                                        canViewFullImage: true,
                                        name: record.trainerName,
                                        url: record.profileImage ?? '',
                                        radius: 40,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            record.trainerName,
                                            style: AppStyles.text14Px.poppins.w600.dark,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            record.designation,
                                            style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _showStatusSelector(index),
                                      borderRadius: BorderRadius.circular(20),
                                      child: _getStatusPill(record.status),
                                    ),
                                  ],
                                ),
                              ),
                              // Expanded section for time sessions
                              const Divider(height: 1, color: Color(0xffEEEEEE)),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isExpanded) {
                                      _expandedTrainerIds.remove(record.trainerId);
                                    } else {
                                      _expandedTrainerIds.add(record.trainerId);
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.timer_outlined, size: 16, color: AppColors.dark),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Sessions (${record.sessions.length}) • ${record.workingHours} hrs worked',
                                            style: AppStyles.text12Px.poppins.w500.dark,
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                        size: 18,
                                        color: AppColors.dark,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isExpanded)
                                Container(
                                  color: const Color(0xffFAFFAF),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Column(
                                    children: [
                                      ...record.sessions.asMap().entries.map((entry) {
                                        final sessionIndex = entry.key;
                                        final session = entry.value;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${session.checkIn} - ${session.checkOut}',
                                                style: AppStyles.text12Px.poppins.w600.dark,
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                                onPressed: () {
                                                  if (session.id != null) {
                                                    _deleteSession(index, session.id!);
                                                  } else {
                                                    setState(() {
                                                      final updatedSessions = List<AttendanceSession>.from(record.sessions)
                                                        ..removeAt(sessionIndex);
                                                      _dailyRecords[index] = record.copyWith(sessions: updatedSessions);
                                                    });
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 8),
                                      TextButton.icon(
                                        onPressed: () => _addTimeSession(index),
                                        icon: const Icon(Icons.add, size: 16),
                                        label: const Text('Add Time Session'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                          textStyle: AppStyles.text12Px.poppins.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
        // Action buttons bottom bar
        if (_dailyRecords.isNotEmpty)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Button.filled(
              title: 'Save Attendance',
              ontap: _saveBulkAttendance,
              buttonColor: AppColors.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildReportsTab() {
    return Column(
      children: [
        // Date range picker
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked.start;
                        _endDate = picked.end;
                      });
                      _fetchReports();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffEEEEEE)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.date_range, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              '${DateFormat('MMM dd').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
                              style: AppStyles.text12Px.poppins.w600.dark,
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textGrey),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xffEEEEEE)),
        // Summary & Report View
        Expanded(
          child: _isReportLoading
              ? const Center(child: CircularProgressIndicator())
              : _reportData == null
                  ? Center(
                      child: Text(
                        'No attendance records found for this period.',
                        style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Attendance Overview Pie Chart
                        _buildTrainerAttendancePieChart(_reportData!.summary),
                        const SizedBox(height: 16),

                        // Summary Grid
                        GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.1,
                          children: [
                            _buildSummaryCard('Trainers', _reportData!.summary.totalTrainers.toString(), const Color(0xff9C51BF)),
                            _buildSummaryCard('Full Day', _reportData!.summary.fullDay.toString(), const Color(0xff27AE60)),
                            _buildSummaryCard('Half Day', _reportData!.summary.halfDay.toString(), const Color(0xffF39C12)),
                            _buildSummaryCard('Leave', _reportData!.summary.leave.toString(), const Color(0xffC0392B)),
                            _buildSummaryCard('Holiday', _reportData!.summary.holiday.toString(), const Color(0xff2980B9)),
                            _buildSummaryCard('Not Marked', _reportData!.summary.notMarked.toString(), const Color(0xff7F8C8D)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Detailed List
                        Text(
                          'Trainer Performance Reports',
                          style: AppStyles.text14Px.poppins.w600.dark,
                        ),
                        const SizedBox(height: 12),
                        ..._reportData!.trainers.map((trainer) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xffEEEEEE)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipOval(
                                      child: ProfileImage(
                                        isEdit: false,
                                        canViewFullImage: true,
                                        name: trainer.trainerName,
                                        url: trainer.profileImage ?? '',
                                        radius: 36,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            trainer.trainerName,
                                            style: AppStyles.text14Px.poppins.w600.dark,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            trainer.designation,
                                            style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Attendance percentage circle
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: trainer.attendancePercentage >= 80
                                            ? const Color(0xffE8F8F5)
                                            : const Color(0xffFEF9E7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${trainer.attendancePercentage.toStringAsFixed(1)}%',
                                        style: AppStyles.text12Px.poppins.w700.copyWith(
                                          color: trainer.attendancePercentage >= 80
                                              ? const Color(0xff117A65)
                                              : const Color(0xffD35400),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(height: 1, color: Color(0xffF2F2F2)),
                                const SizedBox(height: 12),
                                // Metrics grid row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildCompactStat('Full', trainer.fullDays, const Color(0xff27AE60)),
                                    _buildCompactStat('Half', trainer.halfDays, const Color(0xffF39C12)),
                                    _buildCompactStat('Leave', trainer.leaveDays, const Color(0xffC0392B)),
                                    _buildCompactStat('Holiday', trainer.holidayDays, const Color(0xff2980B9)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1, color: Color(0xffF2F2F2)),
                                const SizedBox(height: 12),
                                // Working hours row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Working Hours:',
                                      style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                    ),
                                    Text(
                                      '${trainer.totalWorkingHours} hrs (Avg: ${trainer.averageWorkingHours}/day)',
                                      style: AppStyles.text12Px.poppins.w600.dark,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppStyles.text18Px.poppins.w800.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppStyles.text10Px.poppins.w500.copyWith(color: AppColors.textGrey),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: AppStyles.text14Px.poppins.w700.copyWith(color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppStyles.text10Px.poppins.w500.copyWith(color: AppColors.textGrey),
        ),
      ],
    );
  }

  Widget _buildTrainerAttendancePieChart(TrainerAttendanceReportSummary summary) {
    final total = summary.fullDay + summary.halfDay + summary.leave + summary.holiday + summary.notMarked;
    final attended = summary.fullDay + summary.halfDay;
    final rate = total > 0 ? (attended / total) * 100 : 0.0;

    final slices = [
      (label: 'Full Day', count: summary.fullDay, color: const Color(0xff27AE60)),
      (label: 'Half Day', count: summary.halfDay, color: const Color(0xffF39C12)),
      (label: 'Leave', count: summary.leave, color: AppColors.primary),
      (label: 'Holiday', count: summary.holiday, color: const Color(0xff2980B9)),
      (label: 'Not Marked', count: summary.notMarked, color: const Color(0xff7F8C8D)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance Distribution',
                style: AppStyles.text14Px.poppins.w600.dark,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: rate >= 80 ? const Color(0xffE8F8F5) : const Color(0xffFEF9E7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${rate.toStringAsFixed(1)}% Attended',
                  style: AppStyles.text12Px.poppins.w700.copyWith(
                    color: rate >= 80 ? const Color(0xff117A65) : const Color(0xffD35400),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(100, 100),
                      painter: _TrainerAttendancePieChartPainter(
                        slices: slices
                            .map((s) => (percentage: s.count.toDouble(), color: s.color))
                            .toList(),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
                          style: AppStyles.text16Px.poppins.w700.dark,
                        ),
                        Text(
                          'Records',
                          style: AppStyles.text10Px.poppins.w400.copyWith(
                            color: AppColors.textGrey,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: slices.map((s) {
                    final pct = total > 0 ? (s.count / total) * 100 : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 4, backgroundColor: s.color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.label,
                              style: AppStyles.text12Px.poppins.w400.dark,
                            ),
                          ),
                          Text(
                            '${s.count} (${pct.toStringAsFixed(0)}%)',
                            style: AppStyles.text12Px.poppins.w600.copyWith(color: s.color),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom Donut Pie Chart Painter for Trainer Attendance
class _TrainerAttendancePieChartPainter extends CustomPainter {
  final List<({double percentage, Color color})> slices;
  final double strokeWidth;

  _TrainerAttendancePieChartPainter({
    required this.slices,
    this.strokeWidth = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (sum, item) => sum + item.percentage);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    if (total <= 0) {
      final bgPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = const Color(0xffEEEEEE);
      canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);
      return;
    }

    var startAngle = -math.pi / 2;

    for (final slice in slices) {
      if (slice.percentage <= 0) continue;
      final sweepAngle = (slice.percentage / total) * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = slice.color
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _TrainerAttendancePieChartPainter oldDelegate) {
    return oldDelegate.slices != slices || oldDelegate.strokeWidth != strokeWidth;
  }
}
