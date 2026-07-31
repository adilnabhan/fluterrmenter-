import 'dart:math' as math;
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/domain/model/client_workout_calendar_model.dart';

class ClientWorkoutCalendarWidget extends StatefulWidget {
  final int orgId;
  const ClientWorkoutCalendarWidget({super.key, required this.orgId});

  @override
  State<ClientWorkoutCalendarWidget> createState() => _ClientWorkoutCalendarWidgetState();
}

class _ClientWorkoutCalendarWidgetState extends State<ClientWorkoutCalendarWidget> {
  DateTime _currentMonth = DateTime.now();
  bool _isLoading = true;
  WorkoutCalendarMonthResponse? _monthData;

  @override
  void initState() {
    super.initState();
    _fetchMonthData();
  }

  Future<void> _fetchMonthData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final monthStr = DateFormat('yyyy-MM').format(_currentMonth);
      final url = '${ApiUris.clientWorkoutCalendar}?organization_id=${widget.orgId}&month=$monthStr';
      final response = await DioClient().dio.get<dynamic>(
        url,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 && response.data is Map) {
        if (mounted) {
          setState(() {
            _monthData = WorkoutCalendarMonthResponse.fromJson(response.data as Map<String, dynamic>);
          });
        }
      }
    } catch (e) {
      // Silently handle error or show snack
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _changeMonth(int increment) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + increment, 1);
    });
    _fetchMonthData();
  }

  void _onDateTapped(String dateStr) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _DateDetailsBottomSheet(
        orgId: widget.orgId,
        dateStr: dateStr,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Color(0xffD32F2F), size: 24),
                onPressed: () => _changeMonth(-1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('yyyy').format(_currentMonth),
                    style: AppStyles.text12Px.poppins.w500.copyWith(color: const Color(0xffE53935)),
                  ),
                  Text(
                    DateFormat('MMMM').format(_currentMonth),
                    style: AppStyles.text18Px.poppins.w700.copyWith(color: const Color(0xffD32F2F)),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Color(0xffD32F2F), size: 24),
                onPressed: () => _changeMonth(1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            if (_monthData != null) _buildSummaryRow(_monthData!.summary),
            const SizedBox(height: 16),
            _buildCalendarGrid(),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(WorkoutCalendarSummary summary) {
    String highestDateText = 'N/A';
    if (summary.highestAttendance != null && summary.highestAttendance!.date.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(summary.highestAttendance!.date);
        highestDateText = '${DateFormat('MMM dd').format(parsedDate)} (${summary.highestAttendance!.clientsCount})';
      } catch (_) {
        highestDateText = '${summary.highestAttendance!.date} (${summary.highestAttendance!.clientsCount})';
      }
    }

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Active',
            '${summary.activeClients}',
            const Color(0xff9C51BF),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Avg Daily',
            '${summary.averageDailyAttendance}',
            const Color(0xff27AE60),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Peak Day',
            highestDateText,
            const Color(0xffE67E22),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.text10Px.poppins.w500.copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppStyles.text13Px.poppins.w700.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday; // 1 = Mon, 7 = Sun

    // Create map for quick lookup: "yyyy-MM-dd" -> WorkoutCalendarDay
    final dayMap = <String, WorkoutCalendarDay>{};
    if (_monthData != null) {
      for (final item in _monthData!.calendar) {
        dayMap[item.date] = item;
      }
    }

    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        // Weekday header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdays
              .map((w) => SizedBox(
                    width: 36,
                    child: Text(
                      w,
                      textAlign: TextAlign.center,
                      style: AppStyles.text12Px.poppins.w500.copyWith(color: const Color(0xff8E8E93)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        // Days Grid
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.95,
          ),
          itemCount: (daysInMonth + firstWeekday - 1),
          itemBuilder: (context, index) {
            if (index < firstWeekday - 1) {
              return const SizedBox.shrink();
            }

            final dayNum = index - (firstWeekday - 1) + 1;
            final dateObj = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
            final dateStr = DateFormat('yyyy-MM-dd').format(dateObj);
            final dayData = dayMap[dateStr];

            final clientsCount = dayData?.clientsCount ?? 0;
            final isFuture = dateObj.isAfter(DateTime.now());

            final hasData = clientsCount > 0;
            final bgColor = hasData
                ? const Color(0xffF0F4FF)
                : isFuture
                    ? const Color(0xffF9FAFB)
                    : const Color(0xffF2F2F7);

            final borderColor = hasData
                ? const Color(0xffDBEAFE)
                : Colors.transparent;

            final dayTextColor = hasData
                ? const Color(0xff1D4ED8)
                : isFuture
                    ? Colors.grey.shade400
                    : const Color(0xff3A3A3C);

            return InkWell(
              onTap: isFuture || dayData == null || clientsCount == 0
                  ? null
                  : () => _onDateTapped(dateStr),
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Text(
                      '$dayNum',
                      style: AppStyles.text14Px.poppins.w600.copyWith(color: dayTextColor),
                    ),
                  ),
                  if (hasData)
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xff2563EB),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$clientsCount',
                          style: AppStyles.text10Px.poppins.w700.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DateDetailsBottomSheet extends StatefulWidget {
  final int orgId;
  final String dateStr;
  const _DateDetailsBottomSheet({required this.orgId, required this.dateStr});

  @override
  State<_DateDetailsBottomSheet> createState() => _DateDetailsBottomSheetState();
}

class _DateDetailsBottomSheetState extends State<_DateDetailsBottomSheet> {
  bool _isLoading = true;
  WorkoutDateDetailResponse? _dateDetail;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final url = '${ApiUris.clientWorkoutCalendarDetail(widget.dateStr)}?organization_id=${widget.orgId}';
      final response = await DioClient().dio.get<dynamic>(
        url,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 && response.data is Map) {
        if (mounted) {
          setState(() {
            _dateDetail = WorkoutDateDetailResponse.fromJson(response.data as Map<String, dynamic>);
          });
        }
      }
    } catch (e) {
      // Error handling
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = widget.dateStr;
    try {
      formattedDate = DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.parse(widget.dateStr));
    } catch (_) {}

    final clients = _dateDetail?.clients ?? [];
    final filteredClients = clients.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) || c.trainer.toLowerCase().contains(q);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Text(
            formattedDate,
            style: AppStyles.text16Px.poppins.w600.dark,
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_dateDetail == null)
            Expanded(
              child: Center(
                child: Text(
                  'Failed to load details for this date.',
                  style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
                ),
              ),
            )
          else ...[
            // Stats summary row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffF7F8FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailStat('Clients', '${_dateDetail!.clientsCount}', const Color(0xff3B5998)),
                  _buildDetailStat('Sessions', '${_dateDetail!.completedSessions}', const Color(0xff27AE60)),
                  _buildDetailStat('Peak Hour', _dateDetail!.peakHour, const Color(0xffE67E22)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search Input
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search client or trainer...',
                hintStyle: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textGrey),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor: const Color(0xffF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xffEEEEEE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xffEEEEEE)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Client List
            Expanded(
              child: filteredClients.isEmpty
                  ? Center(
                      child: Text(
                        'No clients found.',
                        style: AppStyles.text13Px.poppins.w400.copyWith(color: AppColors.textGrey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredClients.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xffF0F0F0)),
                      itemBuilder: (context, index) {
                        final client = filteredClients[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                            child: Text(
                              client.name.isNotEmpty ? client.name[0].toUpperCase() : 'C',
                              style: AppStyles.text14Px.poppins.w700.primary,
                            ),
                          ),
                          title: Text(
                            client.name,
                            style: AppStyles.text14Px.poppins.w600.dark,
                          ),
                          subtitle: Text(
                            'Trainer: ${client.trainer}',
                            style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
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
}
