import 'package:fluttertoast/fluttertoast.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class ClientAttendanceScreen extends StatefulWidget {
  final int orgId;
  final bool isTrainer;

  const ClientAttendanceScreen({
    super.key,
    required this.orgId,
    this.isTrainer = false,
  });

  @override
  State<ClientAttendanceScreen> createState() => _ClientAttendanceScreenState();
}

class _ClientAttendanceScreenState extends State<ClientAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  List<Map<String, dynamic>> _clients = [];
  Map<String, dynamic> _dashboard = {};
  Map<String, String> _monthHolidays = {};
  String _searchQuery = '';
  String _statusFilter = 'all';
  final _searchController = TextEditingController();

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchAttendance();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreAttendance();
    }
  }

  Future<void> _fetchAttendance({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    _currentPage = 1;
    _hasMore = true;

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      String url = widget.isTrainer
          ? '${ApiUris.trainerClientAttendance}?date=$dateStr&include_expired=true&page=1'
          : '${ApiUris.clientAttendance}?date=$dateStr&include_expired=true&page=1';
      if (_searchQuery.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(_searchQuery)}';
      }

      final response = await DioClient().dio.get<dynamic>(
        url,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200) {
        if (response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          final clients =
              (data['clients'] ?? data['results'] ?? data['data'] ?? []) as List<dynamic>;
          final dashboard =
              (data['dashboard'] ?? data['summary'] ?? data) as Map<String, dynamic>;

          final isHolidayRoot = data['is_holiday'] == true ||
              data['is_holiday'] == 1 ||
              data['is_holiday'] == 'true' ||
              data['holiday'] == true ||
              data['status']?.toString().toLowerCase() == 'holiday';
          if (isHolidayRoot) {
            dashboard['is_holiday'] = true;
            dashboard['holiday_name'] =
                data['holiday_title'] ?? data['holiday_name'] ?? data['title'] ?? 'Gym Holiday';
          }

          final hasNext = data['next'] != null;
          final totalCount = (data['count'] ?? data['total_clients_count']) as int?;
          final newClients = clients.cast<Map<String, dynamic>>();

          if (mounted) {
            setState(() {
              _clients = newClients;
              _dashboard = Map<String, dynamic>.from(dashboard);
              _hasMore = hasNext ||
                  (totalCount != null
                      ? newClients.length < totalCount
                      : newClients.length >= 10);
            });
          }
        } else if (response.data is List) {
          final newClients = (response.data as List<dynamic>).cast<Map<String, dynamic>>();
          if (mounted) {
            setState(() {
              _clients = newClients;
              _hasMore = false;
            });
          }
        }
      }

      try {
        final monthStr = DateFormat('yyyy-MM').format(_selectedDate);
        final orgParam = widget.orgId != 0 ? '&organization_id=${widget.orgId}' : '';
        final holResp = await DioClient().dio.get<dynamic>(
          '${ApiUris.gymHolidays}?month=$monthStr$orgParam',
          options: Options(headers: {'X-Platform': platformSource}).token,
        );
        if (holResp.statusCode == 200) {
          final holList = holResp.data is List
              ? (holResp.data as List<dynamic>)
              : (holResp.data is Map && holResp.data['results'] is List)
                  ? (holResp.data['results'] as List<dynamic>)
                  : [];
          final Map<String, String> monthHolMap = {};
          for (final h in holList) {
            if (h is Map && h['date'] != null) {
              final d = h['date'].toString();
              final name = (h['title'] ?? h['name'] ?? h['description'] ?? 'Gym Holiday').toString();
              monthHolMap[d] = name;
            }
          }

          if (mounted) {
            setState(() {
              _monthHolidays = monthHolMap;
              if (monthHolMap.containsKey(dateStr)) {
                _dashboard['is_holiday'] = true;
                _dashboard['holiday_name'] = monthHolMap[dateStr];
              }
            });
          }
        }
      } catch (_) {}
    } catch (e) {
      if (!silent) Dialogs.showSnack(msg: 'Failed to load client attendance.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreAttendance() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      String url = widget.isTrainer
          ? '${ApiUris.trainerClientAttendance}?date=$dateStr&include_expired=true&page=$nextPage'
          : '${ApiUris.clientAttendance}?date=$dateStr&include_expired=true&page=$nextPage';
      if (_searchQuery.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(_searchQuery)}';
      }

      final response = await DioClient().dio.get<dynamic>(
        url,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final newClientsRaw =
            (data['clients'] ?? data['results'] ?? data['data'] ?? []) as List<dynamic>;
        final newClients = newClientsRaw.cast<Map<String, dynamic>>();
        final hasNext = data['next'] != null;
        final totalCount = (data['count'] ?? data['total_clients_count']) as int?;

        if (mounted) {
          setState(() {
            _clients.addAll(newClients);
            _currentPage = nextPage;
            _hasMore = hasNext ||
                (totalCount != null
                    ? _clients.length < totalCount
                    : newClients.isNotEmpty);
            _isLoadingMore = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasMore = false;
            _isLoadingMore = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasMore = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _markAttendance({
    required int clientId,
    required String status,
    String? checkIn,
    String? checkOut,
    int? attendanceId,
  }) async {
    // Optimistically update target client item in local state immediately
    if (mounted) {
      setState(() {
        for (var i = 0; i < _clients.length; i++) {
          final cId = _clients[i]['client_id'] ?? _clients[i]['customer_id'] ?? _clients[i]['id'];
          if (cId == clientId) {
            _clients[i]['status'] = status.toLowerCase();
            _clients[i]['has_marked'] = true;
            _clients[i]['is_marked'] = true;
            if (checkIn != null && checkIn.isNotEmpty) {
              _clients[i]['check_in'] = checkIn;
            }
            if (checkOut != null && checkOut.isNotEmpty) {
              _clients[i]['check_out'] = checkOut;
            }
            break;
          }
        }
      });
    }

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final payload = <String, dynamic>{
        'client_id': clientId,
        'date': dateStr,
        'status': status.toLowerCase(),
      };
      if (checkIn != null && checkIn.isNotEmpty) payload['check_in'] = checkIn;
      if (checkOut != null && checkOut.isNotEmpty) payload['check_out'] = checkOut;

      dynamic response;
      if (widget.isTrainer) {
        response = await DioClient().dio.post<dynamic>(
          ApiUris.trainerClientAttendanceMark,
          data: payload,
          options: Options(headers: {'X-Platform': platformSource}).token,
        );
      } else {
        if (attendanceId != null) {
          response = await DioClient().dio.patch<dynamic>(
            ApiUris.clientAttendanceDetail(attendanceId),
            data: payload,
            options: Options(headers: {'X-Platform': platformSource}).token,
          );
        } else {
          response = await DioClient().dio.post<dynamic>(
            ApiUris.clientAttendance,
            data: payload,
            options: Options(headers: {'X-Platform': platformSource}).token,
          );
        }
      }

      // Map newly assigned attendance_id locally if returned
      if (response != null && response.data is Map) {
        final resData = response.data as Map<String, dynamic>;
        final newId = resData['id'] ?? resData['attendance_id'];
        if (newId != null && mounted) {
          setState(() {
            for (var i = 0; i < _clients.length; i++) {
              final cId = _clients[i]['client_id'] ?? _clients[i]['customer_id'] ?? _clients[i]['id'];
              if (cId == clientId) {
                _clients[i]['attendance_id'] = newId;
                break;
              }
            }
          });
        }
      }

      Dialogs.showSnack(msg: 'Attendance marked successfully!');
    } catch (e) {
      Dialogs.showSnack(msg: 'Failed to mark attendance.');
      _fetchAttendance(silent: true);
    }
  }

  Future<void> _deleteAttendance(int attendanceId) async {
    try {
      await DioClient().dio.delete<dynamic>(
        ApiUris.clientAttendanceDetail(attendanceId),
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      Dialogs.showSnack(msg: 'Attendance record deleted.');
      _fetchAttendance();
    } catch (e) {
      Dialogs.showSnack(msg: 'Failed to delete attendance.');
    }
  }

  Future<void> _saveHoliday({
    required DateTime date,
    required String title,
    String? description,
    int? holidayId,
  }) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final payload = <String, dynamic>{
        'organization_id': widget.orgId,
        'date': dateStr,
        'title': title,
      };
      if (description != null && description.isNotEmpty) {
        payload['description'] = description;
      }

      if (holidayId != null) {
        await DioClient().dio.patch<dynamic>(
          ApiUris.gymHolidayDetail(holidayId),
          data: payload,
          options: Options(headers: {'X-Platform': platformSource}).token,
        );
      } else {
        await DioClient().dio.post<dynamic>(
          ApiUris.gymHolidays,
          data: payload,
          options: Options(headers: {'X-Platform': platformSource}).token,
        );
      }

      Dialogs.showSnack(msg: 'Holiday saved successfully!');
      _fetchAttendance();
    } catch (e) {
      Dialogs.showSnack(msg: 'Failed to save holiday.');
    }
  }

  Future<void> _deleteHoliday(int holidayId) async {
    try {
      await DioClient().dio.delete<dynamic>(
        ApiUris.gymHolidayDetail(holidayId),
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      Dialogs.showSnack(msg: 'Holiday deleted successfully.');
      _fetchAttendance();
    } catch (e) {
      Dialogs.showSnack(msg: 'Failed to delete holiday.');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMonthlyHolidays() async {
    try {
      final monthStr = DateFormat('yyyy-MM').format(_selectedDate);
      final response = await DioClient().dio.get<dynamic>(
        '${ApiUris.gymHolidays}?month=$monthStr&organization_id=${widget.orgId}',
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
        } else if (response.data is Map && response.data['results'] is List) {
          return (response.data['results'] as List<dynamic>).cast<Map<String, dynamic>>();
        }
      }
    } catch (_) {}
    return [];
  }

  void _showHolidaysManagementSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchMonthlyHolidays(),
          builder: (ctx, snapshot) {
            final holidays = snapshot.data ?? [];
            final isLoading = snapshot.connectionState == ConnectionState.waiting;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gym Holidays (${DateFormat('MMM yyyy').format(_selectedDate)})',
                          style: AppStyles.text16Px.poppins.w600.dark,
                        ),
                        if (!widget.isTrainer)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _showSetHolidaySheet();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff2471A3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Holiday'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (holidays.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xffF8F9FA),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'No holidays scheduled for ${DateFormat('MMMM yyyy').format(_selectedDate)}',
                          style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: holidays.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, index) {
                            final hol = holidays[index];
                            final title = hol['title']?.toString() ?? 'Gym Holiday';
                            final dateStr = hol['date']?.toString() ?? '';
                            final desc = hol['description']?.toString() ?? '';
                            final id = hol['id'] as int?;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xffEAF2F8),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xff2471A3).withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.beach_access, color: Color(0xff2471A3), size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: AppStyles.text14Px.poppins.w600.copyWith(color: const Color(0xff2471A3)),
                                        ),
                                        Text(
                                          dateStr,
                                          style: AppStyles.text12Px.poppins.w500.dark,
                                        ),
                                        if (desc.isNotEmpty)
                                          Text(
                                            desc,
                                            style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (!widget.isTrainer) ...[
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _showSetHolidaySheet(existingHoliday: hol);
                                      },
                                      icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                    ),
                                    if (id != null)
                                      IconButton(
                                        onPressed: () async {
                                          Navigator.pop(ctx);
                                          _deleteHoliday(id);
                                        },
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSetHolidaySheet({Map<String, dynamic>? existingHoliday}) {
    if (existingHoliday == null && _isHoliday) {
      existingHoliday = {
        'id': _dashboard['holiday_id'] ?? _dashboard['id'],
        'title': _holidayName,
        'description': _dashboard['holiday_description'] ?? _dashboard['description'] ?? '',
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      };
    }

    final titleController = TextEditingController(
      text: existingHoliday?['title']?.toString() ?? '',
    );
    final descController = TextEditingController(
      text: existingHoliday?['description']?.toString() ?? '',
    );
    DateTime holidayDate = _selectedDate;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          existingHoliday != null
                              ? 'Edit Gym Holiday'
                              : 'Set Gym Holiday',
                          style: AppStyles.text16Px.poppins.w600.dark,
                        ),
                        if (existingHoliday != null &&
                            existingHoliday['id'] != null)
                          IconButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              _deleteHoliday(existingHoliday!['id'] as int);
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Holiday Date',
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: holidayDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setModalState(() => holidayDate = picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xffEEEEEE)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat(
                                'EEEE, MMM dd, yyyy',
                              ).format(holidayDate),
                              style: AppStyles.text14Px.poppins.w500.dark,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      'Holiday Title *',
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Independence Day, Maintenance',
                        hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                          color: AppColors.textGrey,
                        ),
                        filled: true,
                        fillColor: const Color(0xffF8F9FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xffEEEEEE)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xffEEEEEE)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      style: AppStyles.text14Px.poppins.w400.dark,
                    ),
                    const SizedBox(height: 14),

                    Text(
                      'Description (Optional)',
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Add details about the holiday...',
                        hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                          color: AppColors.textGrey,
                        ),
                        filled: true,
                        fillColor: const Color(0xffF8F9FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xffEEEEEE)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xffEEEEEE)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      style: AppStyles.text14Px.poppins.w400.dark,
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final title = titleController.text.trim();
                          if (title.isEmpty) {
                            Dialogs.showSnack(msg: 'Please enter holiday title');
                            return;
                          }
                          Navigator.pop(ctx);
                          _saveHoliday(
                            date: holidayDate,
                            title: title,
                            description: descController.text.trim(),
                            holidayId: existingHoliday?['id'] as int?,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2471A3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Save Holiday',
                          style: AppStyles.text14Px.poppins.w600.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Date helpers ---
  List<DateTime> get _weekDates {
    return List.generate(5, (i) => _selectedDate.add(Duration(days: i - 2)));
  }

  void _goToPreviousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    _fetchAttendance();
  }

  void _goToNextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    _fetchAttendance();
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = date);
    _fetchAttendance();
  }

  // --- Dashboard data helpers ---
  bool get _isFutureDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    return selectedDay.isAfter(today);
  }

  bool get _isHoliday {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    if (_monthHolidays.containsKey(dateStr)) return true;
    if (_dashboard['is_holiday'] == true ||
        _dashboard['is_holiday'] == 1 ||
        _dashboard['is_holiday'] == 'true') return true;
    if (_clients.isNotEmpty &&
        _clients.every((c) {
          final st = c['status']?.toString().toLowerCase();
          return st == 'holiday' || c['is_holiday'] == true || c['is_holiday'] == 1;
        })) {
      return true;
    }
    return false;
  }

  String get _holidayName {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    if (_monthHolidays.containsKey(dateStr)) {
      return _monthHolidays[dateStr]!;
    }
    final name =
        _dashboard['holiday_name'] ??
        _dashboard['holiday_title'] ??
        _dashboard['title'] ??
        (_clients.isNotEmpty
            ? _clients.first['holiday_name'] ?? _clients.first['holiday_title']
            : null);
    return name?.toString().isNotEmpty == true
        ? name.toString()
        : 'Gym Holiday';
  }

  bool _isClientMarked(Map<String, dynamic> c) {
    if (c['attendance_id'] != null) return true;
    if (c['has_marked'] == true || c['is_marked'] == true || c['marked'] == true) return true;
    final checkIn = c['check_in']?.toString();
    if (checkIn != null && checkIn.isNotEmpty && checkIn != 'null') return true;
    return false;
  }

  String _getClientStatus(Map<String, dynamic> c) {
    final clientIsHoliday = c['is_holiday'] == true ||
        (c['status'] ?? '').toString().toLowerCase() == 'holiday' ||
        _isHoliday;
    if (clientIsHoliday) return 'holiday';

    final isMarked = _isClientMarked(c);
    if (!isMarked) return 'unmarked';

    final s = (c['status'] ?? 'unmarked').toString().toLowerCase();
    if (s == 'not_marked' || s == 'unmarked' || s.isEmpty) return 'unmarked';
    return s;
  }

  int get _presentCount => _clients.where((c) => _getClientStatus(c) == 'present').length;
  int get _absentCount => _clients.where((c) => _getClientStatus(c) == 'absent').length;
  int get _unmarkedCount => _clients.where((c) => _getClientStatus(c) == 'unmarked' || _getClientStatus(c) == 'not_marked').length;
  int get _holidayCount => _dashboard['clients_on_holiday'] as int? ?? _clients.where((c) => _getClientStatus(c) == 'holiday').length;

  List<Map<String, dynamic>> get _filteredClients {
    var list = _clients;
    if (_statusFilter != 'all') {
      list = list.where((c) {
        final st = _getClientStatus(c);
        if (_statusFilter == 'unmarked' || _statusFilter == 'not_marked') {
          return st == 'unmarked' || st == 'not_marked';
        }
        return st == _statusFilter;
      }).toList();
    }
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((c) {
      final name = (c['name'] ?? c['customer_name'] ?? '').toString().toLowerCase();
      final mobile = (c['mobile'] ?? '').toString().toLowerCase();
      return name.contains(q) || mobile.contains(q);
    }).toList();
  }

  // --- Status helpers ---
  ({Color bg, Color fg, String label}) _statusStyle(String status) {
    switch (status) {
      case 'present':
        return (bg: const Color(0xffE8F8F5), fg: const Color(0xff27AE60), label: 'Present');
      case 'absent':
        return (bg: const Color(0xffFDEDEC), fg: const Color(0xffE74C3C), label: 'Absent');
      case 'holiday':
        return (bg: const Color(0xffEAF2F8), fg: const Color(0xff2471A3), label: 'Holiday');
      case 'unmarked':
      case 'not_marked':
      default:
        return (bg: const Color(0xffF2F4F4), fg: const Color(0xff7F8C8D), label: 'Unmarked');
    }
  }

  void _showMarkAttendanceSheet(Map<String, dynamic> client) {
    final clientId = client['client_id'] as int? ?? client['customer_id'] as int? ?? client['id'] as int? ?? 0;
    final clientName = (client['name'] ?? client['customer_name'] ?? 'Client').toString();
    final currentStatus = _getClientStatus(client);
    final attendanceId = client['attendance_id'] as int?;

    final clientIsHoliday = client['is_holiday'] == true || currentStatus == 'holiday' || _isHoliday;
    if (clientIsHoliday) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: 'Cannot be able to mark attendance on holiday',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFF4B5563),
        textColor: Colors.white,
        fontSize: 12,
      );
      return;
    }

    final statuses = [
      (value: 'present', label: 'Present', color: const Color(0xff27AE60), icon: Icons.check_circle_outline),
      (value: 'absent', label: 'Absent', color: const Color(0xffE74C3C), icon: Icons.cancel_outlined),
    ];

    String selectedStatus = currentStatus;
    String? checkIn;
    String? checkOut;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
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
                      'Mark Attendance',
                      style: AppStyles.text16Px.poppins.w600.dark,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      clientName,
                      style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 20),

                    // Status options
                    ...statuses.map((status) {
                      final isSelected = selectedStatus == status.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setModalState(() => selectedStatus = status.value);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? status.color.withValues(alpha: 0.1) : const Color(0xffF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? status.color : const Color(0xffEEEEEE),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(status.icon, color: status.color, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    status.label,
                                    style: isSelected
                                        ? AppStyles.text14Px.poppins.w600.copyWith(color: status.color)
                                        : AppStyles.text14Px.poppins.w400.dark,
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle, color: status.color, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    // Time pickers for "present"
                    if (selectedStatus == 'present') ...[
                      Row(
                        children: [
                          Expanded(
                            child: _TimePickerField(
                              label: 'Check-in',
                              value: checkIn,
                              onChanged: (v) => setModalState(() => checkIn = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TimePickerField(
                              label: 'Check-out',
                              value: checkOut,
                              onChanged: (v) => setModalState(() => checkOut = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _markAttendance(
                            clientId: clientId,
                            status: selectedStatus,
                            checkIn: checkIn,
                            checkOut: checkOut,
                            attendanceId: attendanceId,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Save Attendance',
                          style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: const PopButton().center,
        title: Text(
          'Client Attendance',
          style: AppStyles.text18Px.poppins.w600.dark,
        ),
        actions: [
          if (!widget.isTrainer)
            IconButton(
              onPressed: () => _showHolidaysManagementSheet(),
              icon: const Icon(
                Icons.free_cancellation_outlined,
                color: Color(0xff2471A3),
              ),
              tooltip: 'Gym Holidays',
            ),
          IconButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) _selectDate(picked);
            },
            icon: const Icon(Icons.calendar_month, color: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          // Horizontal Date Picker
          _buildDatePicker(),

          // Summary Cards
          _buildSummaryCards(),

          if (_isHoliday)
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xffEAF2F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xff2471A3).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.beach_access,
                    color: Color(0xff2471A3),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Gym Holiday: $_holidayName',
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: const Color(0xff2471A3),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Search Bar
          _buildSearchBar(),

          // Client List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredClients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 48,
                              color: AppColors.textGrey.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No clients match your search'
                                  : 'No clients found for this date',
                              style: AppStyles.text14Px.poppins.w500.copyWith(
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchAttendance,
                        child: ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredClients.length + (_isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            if (index == _filteredClients.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return _buildClientTile(_filteredClients[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    final dates = _weekDates;
    final today = DateTime.now();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: _goToPreviousWeek,
            icon: const Icon(Icons.chevron_left, color: AppColors.textGrey),
          ),
          Expanded(
            child: Row(
              children: dates.map((date) {
                final isSelected = date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day;
                final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;
                final dateStr = DateFormat('yyyy-MM-dd').format(date);
                final isHolidayDay = _monthHolidays.containsKey(dateStr) ||
                    (isSelected && _isHoliday);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(date),
                    child: Container(
                      height: 72,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isHolidayDay ? const Color(0xff486CC2) : AppColors.primary)
                            : isToday
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? null
                            : isToday
                                ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                                : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('E').format(date).substring(0, 3),
                                style: AppStyles.text12Px.poppins.w500.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textGrey,
                                ),
                              ),
                              if (isHolidayDay) ...[
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.beach_access,
                                  size: 10,
                                  color: isSelected ? Colors.white : AppColors.textGrey,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${date.day}',
                            style: AppStyles.text18Px.poppins.w700.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.dark,
                            ),
                          ),
                          Text(
                            DateFormat('MMM').format(date),
                            style: AppStyles.text10Px.poppins.w400.copyWith(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          IconButton(
            onPressed: _goToNextWeek,
            icon: const Icon(Icons.chevron_right, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (_isHoliday) {
      return const SizedBox.shrink();
    }

    final cards = [
      (label: 'Present', count: _presentCount, color: const Color(0xff27AE60), icon: Icons.people_alt_outlined, value: 'present'),
      (label: 'Absent', count: _absentCount, color: const Color(0xffE74C3C), icon: Icons.person_off_outlined, value: 'absent'),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Row(
        children: cards.map((card) {
          final filterVal = card.value;
          final isFiltered = _statusFilter == filterVal;

          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _statusFilter = isFiltered ? 'all' : filterVal;
                });
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: card.color.withValues(alpha: isFiltered ? 0.2 : 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: isFiltered
                      ? Border.all(color: card.color, width: 1.5)
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(card.icon, color: card.color, size: 24),
                    const SizedBox(height: 6),
                    Text(
                      '${card.count}',
                      style: AppStyles.text18Px.poppins.w700.copyWith(color: card.color),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card.label,
                      style: AppStyles.text10Px.poppins.w500.copyWith(color: card.color),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xffF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search clients...',
                  hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                    color: AppColors.textGrey,
                  ),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textGrey, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: AppStyles.text14Px.poppins.w400.dark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xffF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                _showStatusFilterSheet();
              },
              icon: const Icon(Icons.tune, color: AppColors.textGrey, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientTile(Map<String, dynamic> client) {
    final name = (client['name'] ?? client['customer_name'] ?? 'Unknown').toString();
    final plan = (client['plan_name'] ?? client['membership_plan'] ?? '').toString();
    final status = _getClientStatus(client);
    final clientIsHoliday = status == 'holiday';
    final checkIn = (client['check_in'] ?? '').toString();
    final checkOut = (client['check_out'] ?? '').toString();
    final profilePic = client['profile_picture'] as String?;
    final style = _statusStyle(status);

    final hasTimings = checkIn.isNotEmpty && checkIn != 'null';
    String timingText = '';
    if (clientIsHoliday) {
      timingText = (client['holiday_name'] ?? client['holiday_title'] ?? _holidayName).toString();
    } else if (hasTimings) {
      timingText = _formatTime(checkIn);
      if (checkOut.isNotEmpty && checkOut != 'null') {
        timingText += ' - ${_formatTime(checkOut)}';
      }
    }

    final memStatus = (client['membership_status'] ?? '').toString().toLowerCase();
    final isExpiredMem = memStatus == 'expired';

    return InkWell(
      onTap: () => _showMarkAttendanceSheet(client),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffEEEEEE)),
        ),
        child: Row(
          children: [
            // Avatar
            ClipOval(
              child: ProfileImage(
                isEdit: false,
                url: profilePic,
                radius: 48,
              ),
            ),
            const SizedBox(width: 12),

            // Name & Plan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: AppStyles.text14Px.poppins.w600.dark,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isExpiredMem) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffFDEDEC),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Expired',
                            style: AppStyles.text10Px.poppins.w600.copyWith(
                              color: const Color(0xffE74C3C),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (plan.isNotEmpty && plan != 'null')
                    Text(
                      plan,
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Status + Timing/Holiday Name
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: style.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    style.label,
                    style: AppStyles.text12Px.poppins.w600.copyWith(color: style.fg),
                  ),
                ),
                if (clientIsHoliday || hasTimings) ...[
                  const SizedBox(height: 4),
                  Text(
                    timingText,
                    style: AppStyles.text10Px.poppins.w400.copyWith(
                      color: clientIsHoliday ? const Color(0xff2471A3) : AppColors.textGrey,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  Text(
                    '—',
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textGrey.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        var hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final period = hour >= 12 ? 'PM' : 'AM';
        if (hour > 12) hour -= 12;
        if (hour == 0) hour = 12;
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      }
    } catch (_) {}
    return time;
  }

  void _showStatusFilterSheet() {
    final statuses = [
      (value: 'all', label: 'All Clients', color: AppColors.primary),
      (value: 'present', label: 'Present', color: const Color(0xff27AE60)),
      (value: 'absent', label: 'Absent', color: const Color(0xffE74C3C)),
      (value: 'holiday', label: 'Holiday', color: const Color(0xff2471A3)),
      (value: 'unmarked', label: 'Unmarked', color: const Color(0xff7F8C8D)),
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
                'Filter by Status',
                style: AppStyles.text16Px.poppins.w600.dark,
              ),
              const SizedBox(height: 8),
              ...statuses.map((status) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 8,
                    backgroundColor: status.color,
                  ),
                  title: Text(
                    status.label,
                    style: AppStyles.text14Px.poppins.w400.dark,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _statusFilter = status.value;
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
}

class _TimePickerField extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;

  const _TimePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 6, minute: 0),
          helpText: 'Select $label Time',
        );
        if (picked != null) {
          onChanged(
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xffF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffEEEEEE)),
        ),
        child: Row(
          children: [
            Icon(
              label == 'Check-in' ? Icons.login : Icons.logout,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppStyles.text10Px.poppins.w500.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value ?? 'Select',
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: value != null ? AppColors.dark : AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
