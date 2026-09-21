import 'dart:math' as math;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_client_detail_screen.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/presentation/screens/member/member_detials_screen.dart';

class ClientAttendanceScreen extends StatefulWidget {
  final int orgId;
  final bool isTrainer;

  const ClientAttendanceScreen({
    super.key,
    required this.orgId,
    this.isTrainer = false,
  });

  static void clearCache() {}

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
  Timer? _searchDebounceTimer;
  bool _isSearching = false;

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
    _searchDebounceTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    final trimmed = query.trim();
    setState(() {
      _searchQuery = trimmed;
      if (trimmed.isNotEmpty) {
        _isSearching = true;
      }
    });

    if (trimmed.isEmpty) {
      setState(() => _isSearching = true);
      _fetchAttendance(silent: true).then((_) {
        if (mounted) {
          setState(() => _isSearching = false);
        }
      });
      return;
    }

    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      await _fetchAttendance(silent: true);
      if (mounted) {
        setState(() => _isSearching = false);
      }
    });
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

  Future<void> _fetchAttendance({
    bool silent = false,
    bool forceRefresh = false,
  }) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _clients = [];
        _dashboard = {};
      });
    }
    _currentPage = 1;
    _hasMore = true;

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      String url =
          widget.isTrainer
              ? '${ApiUris.trainerClientAttendance}?date=$dateStr&include_expired=true&page=1'
              : '${ApiUris.clientAttendance}?date=$dateStr&include_expired=true&page=1';
      if (_statusFilter != 'all') {
        if (_statusFilter == 'present' ||
            _statusFilter == 'absent' ||
            _statusFilter == 'unmarked') {
          url += '&status=$_statusFilter';
        } else if (_statusFilter == 'active' || _statusFilter == 'expired') {
          url += '&membership_status=$_statusFilter';
        } else if (_statusFilter == 'pending_fee') {
          url += '&pending_fee=true';
        } else if (_statusFilter == 'active_present') {
          url += '&status=present&membership_status=active';
        } else if (_statusFilter == 'expired_present') {
          url += '&status=present&membership_status=expired';
        } else if (_statusFilter == 'pending_fee_present') {
          url += '&status=present&pending_fee=true';
        }
      }
      if (_searchQuery.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(_searchQuery)}';
      }

      final response = await DioClient().dio.get<dynamic>(
        url,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        if (response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          
          List<dynamic> rawClientsList = [];
          bool hasNext = false;
          int? totalCount;

          final clientsRaw = data['clients'];
          if (clientsRaw is List) {
            rawClientsList = clientsRaw;
            hasNext = data['next'] != null;
            totalCount = (data['count'] ?? data['total_clients_count']) as int?;
          } else if (clientsRaw is Map) {
            final clientsMap = Map<String, dynamic>.from(clientsRaw as Map);
            rawClientsList = (clientsMap['results'] ?? clientsMap['data'] ?? []) as List<dynamic>;
            hasNext = clientsMap['next'] != null || data['next'] != null;
            totalCount = (clientsMap['count'] ?? data['count'] ?? data['total_clients_count']) as int?;
          } else if (data['results'] is List) {
            rawClientsList = data['results'] as List<dynamic>;
            hasNext = data['next'] != null;
            totalCount = (data['count'] ?? data['total_clients_count']) as int?;
          } else if (data['data'] is List) {
            rawClientsList = data['data'] as List<dynamic>;
            hasNext = data['next'] != null;
            totalCount = (data['count'] ?? data['total_clients_count']) as int?;
          }

          final dashboard =
              (data['dashboard'] ?? data['summary'] ?? data)
                  as Map<String, dynamic>;

          final isHolidayRoot =
              data['is_holiday'] == true ||
              data['is_holiday'] == 1 ||
              data['is_holiday'] == 'true' ||
              data['holiday'] == true ||
              data['status']?.toString().toLowerCase() == 'holiday';
          if (isHolidayRoot) {
            dashboard['is_holiday'] = true;
            dashboard['holiday_name'] =
                data['holiday_title'] ??
                data['holiday_name'] ??
                data['title'] ??
                'Gym Holiday';
          }

          final newClients = rawClientsList.map((e) => Map<String, dynamic>.from(e as Map)).toList();

          if (mounted) {
            setState(() {
              _clients = newClients;
              _dashboard = Map<String, dynamic>.from(dashboard);
              _hasMore =
                  hasNext ||
                  (totalCount != null
                      ? newClients.length < totalCount
                      : newClients.length >= 10);
            });
          }
        } else if (response.data is List) {
          final newClients =
              (response.data as List<dynamic>).map((e) => Map<String, dynamic>.from(e as Map)).toList();
          if (mounted) {
            setState(() {
              _clients = newClients;
              _hasMore = false;
            });
          }
        }
      }

      if (_monthHolidays.isEmpty || forceRefresh) {
        try {
          final monthStr = DateFormat('yyyy-MM').format(_selectedDate);
          final orgParam =
              widget.orgId != 0 ? '&organization_id=${widget.orgId}' : '';
          final holResp = await DioClient().dio.get<dynamic>(
            '${ApiUris.gymHolidays}?month=$monthStr$orgParam',
            options: Options(headers: {'X-Platform': platformSource}),
          );
          if (holResp.statusCode == 200) {
            final holList =
                holResp.data is List
                    ? (holResp.data as List<dynamic>)
                    : (holResp.data is Map && holResp.data['results'] is List)
                    ? (holResp.data['results'] as List<dynamic>)
                    : [];
            final Map<String, String> monthHolMap = {};
            for (final h in holList) {
              if (h is Map && h['date'] != null) {
                final d = h['date'].toString();
                final name =
                    (h['title'] ?? h['name'] ?? h['description'] ?? 'Gym Holiday')
                        .toString();
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
      } else if (_monthHolidays.containsKey(dateStr)) {
        _dashboard['is_holiday'] = true;
        _dashboard['holiday_name'] = _monthHolidays[dateStr];
      }
    } catch (e, stackTrace) {
      debugPrint('❌ _fetchAttendance error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
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
      String url =
          widget.isTrainer
              ? '${ApiUris.trainerClientAttendance}?date=$dateStr&include_expired=true&page=$nextPage'
              : '${ApiUris.clientAttendance}?date=$dateStr&include_expired=true&page=$nextPage';
      if (_statusFilter != 'all') {
        if (_statusFilter == 'present' ||
            _statusFilter == 'absent' ||
            _statusFilter == 'unmarked') {
          url += '&status=$_statusFilter';
        } else if (_statusFilter == 'active' || _statusFilter == 'expired') {
          url += '&membership_status=$_statusFilter';
        } else if (_statusFilter == 'pending_fee') {
          url += '&pending_fee=true';
        } else if (_statusFilter == 'active_present') {
          url += '&status=present&membership_status=active';
        } else if (_statusFilter == 'expired_present') {
          url += '&status=present&membership_status=expired';
        } else if (_statusFilter == 'pending_fee_present') {
          url += '&status=present&pending_fee=true';
        }
      }
      if (_searchQuery.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(_searchQuery)}';
      }

      final response = await DioClient().dio.get<dynamic>(
        url,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        List<dynamic> rawClientsList = [];
        bool hasNext = false;
        int? totalCount;

        final clientsRaw = data['clients'];
        if (clientsRaw is List) {
          rawClientsList = clientsRaw;
          hasNext = data['next'] != null;
          totalCount = (data['count'] ?? data['total_clients_count']) as int?;
        } else if (clientsRaw is Map) {
          final clientsMap = Map<String, dynamic>.from(clientsRaw as Map);
          rawClientsList = (clientsMap['results'] ?? clientsMap['data'] ?? []) as List<dynamic>;
          hasNext = clientsMap['next'] != null || data['next'] != null;
          totalCount = (clientsMap['count'] ?? data['count'] ?? data['total_clients_count']) as int?;
        } else if (data['results'] is List) {
          rawClientsList = data['results'] as List<dynamic>;
          hasNext = data['next'] != null;
          totalCount = (data['count'] ?? data['total_clients_count']) as int?;
        }

        final newClients = rawClientsList.map((e) => Map<String, dynamic>.from(e as Map)).toList();

        if (mounted) {
          setState(() {
            _clients.addAll(newClients);
            _currentPage = nextPage;
            _hasMore =
                hasNext ||
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
          final cId =
              _clients[i]['client_id'] ??
              _clients[i]['customer_id'] ??
              _clients[i]['id'];
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
      if (checkOut != null && checkOut.isNotEmpty)
        payload['check_out'] = checkOut;

      dynamic response;
      if (widget.isTrainer) {
        response = await DioClient().dio.post<dynamic>(
          ApiUris.trainerClientAttendanceMark,
          data: payload,
          options: Options(headers: {'X-Platform': platformSource}),
        );
      } else {
        if (attendanceId != null) {
          response = await DioClient().dio.patch<dynamic>(
            ApiUris.clientAttendanceDetail(attendanceId),
            data: payload,
            options: Options(headers: {'X-Platform': platformSource}),
          );
        } else {
          response = await DioClient().dio.post<dynamic>(
            ApiUris.clientAttendance,
            data: payload,
            options: Options(headers: {'X-Platform': platformSource}),
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
              final cId =
                  _clients[i]['client_id'] ??
                  _clients[i]['customer_id'] ??
                  _clients[i]['id'];
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
        options: Options(headers: {'X-Platform': platformSource}),
      );
      Dialogs.showSnack(msg: 'Attendance record deleted.');
      _fetchAttendance();
    } catch (e) {
      Dialogs.showSnack(msg: 'Failed to delete attendance.');
    }
  }

  Future<void> _saveHoliday({
    List<DateTime>? dates,
    DateTime? date,
    required String title,
    Map<String, String>? customTitles,
    String? description,
    int? holidayId,
  }) async {
    try {
      final List<DateTime> targetDates = [];
      if (dates != null && dates.isNotEmpty) {
        targetDates.addAll(dates);
      } else if (date != null) {
        targetDates.add(date);
      }

      if (targetDates.isEmpty) {
        Dialogs.showSnack(msg: 'Please select at least one date.');
        return;
      }

      if (holidayId != null) {
        final d = targetDates.first;
        final dateStr = DateFormat('yyyy-MM-dd').format(d);
        await DioClient().dio.patch<dynamic>(
          ApiUris.gymHolidayDetail(holidayId),
          data: {
            'organization_id': widget.orgId,
            'date': dateStr,
            'title': title,
            if (description != null && description.isNotEmpty)
              'description': description,
          },
          options: Options(headers: {'X-Platform': platformSource}),
        );
      } else {
        // Group dates by title (uses custom title for that date if set, otherwise common title)
        final Map<String, List<String>> titleToDates = {};
        for (final d in targetDates) {
          final dStr = DateFormat('yyyy-MM-dd').format(d);
          final t = (customTitles != null &&
                  customTitles[dStr]?.trim().isNotEmpty == true)
              ? customTitles[dStr]!.trim()
              : title.trim();
          titleToDates.putIfAbsent(t, () => []).add(dStr);
        }

        final futures = <Future>[];
        for (final entry in titleToDates.entries) {
          final groupTitle = entry.key;
          final groupDates = entry.value..sort();
          final payload = <String, dynamic>{
            'organization_id': widget.orgId,
            'dates': groupDates,
            'date': groupDates.first,
            'title': groupTitle,
          };
          if (description != null && description.isNotEmpty) {
            payload['description'] = description;
          }

          futures.add(
            DioClient().dio.post<dynamic>(
              ApiUris.gymHolidays,
              data: payload,
              options: Options(headers: {'X-Platform': platformSource}),
            ),
          );
        }

        await Future.wait(futures);
      }

      final count = targetDates.length;
      Dialogs.showSnack(
        msg: count > 1
            ? '$count holidays saved successfully!'
            : 'Holiday saved successfully!',
      );
      _fetchAttendance();
    } catch (e) {
      Dialogs.showSnack(msg: 'Failed to save holiday.');
    }
  }

  Future<void> _deleteHoliday(int holidayId) async {
    try {
      await DioClient().dio.delete<dynamic>(
        ApiUris.gymHolidayDetail(holidayId),
        options: Options(headers: {'X-Platform': platformSource}),
      );
      Dialogs.showSnack(msg: 'Holiday deleted successfully.');
      _fetchAttendance();
    } catch (e) {
      Dialogs.showSnack(msg: 'Failed to delete holiday.');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMonthlyHolidays([
    DateTime? month,
  ]) async {
    try {
      final target = month ?? _selectedDate;
      final monthStr = DateFormat('yyyy-MM').format(target);
      final orgParam =
          widget.orgId != 0 ? '&organization_id=${widget.orgId}' : '';
      final response = await DioClient().dio.get<dynamic>(
        '${ApiUris.gymHolidays}?month=$monthStr$orgParam',
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
        } else if (response.data is Map && response.data['results'] is List) {
          return (response.data['results'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
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
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
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
                          'Gym Holidays (${DateFormat('MMM yyyy').format(_selectedDate)})',
                          style: AppStyles.text16Px.poppins.w600.dark,
                        ),
                        if (!widget.isTrainer)
                          ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await _showSetHolidaySheet();
                              _showHolidaysManagementSheet();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff2471A3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
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
                          style: AppStyles.text14Px.poppins.w400.copyWith(
                            color: AppColors.textGrey,
                          ),
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
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, index) {
                            final hol = holidays[index];
                            final title =
                                hol['title']?.toString() ?? 'Gym Holiday';
                            final dateStr = hol['date']?.toString() ?? '';
                            final desc = hol['description']?.toString() ?? '';
                            final id = hol['id'] as int?;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xffEAF2F8),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(
                                    0xff2471A3,
                                  ).withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.beach_access,
                                    color: Color(0xff2471A3),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: AppStyles.text14Px.poppins.w600
                                              .copyWith(
                                                color: const Color(0xff2471A3),
                                              ),
                                        ),
                                        Text(
                                          dateStr,
                                          style:
                                              AppStyles
                                                  .text12Px
                                                  .poppins
                                                  .w500
                                                  .dark,
                                        ),
                                        if (desc.isNotEmpty)
                                          Text(
                                            desc,
                                            style: AppStyles
                                                .text12Px
                                                .poppins
                                                .w400
                                                .copyWith(
                                                  color: AppColors.textGrey,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (!widget.isTrainer) ...[
                                    IconButton(
                                      onPressed: () async {
                                        Navigator.pop(ctx);
                                        await _showSetHolidaySheet(
                                          existingHoliday: hol,
                                        );
                                        _showHolidaysManagementSheet();
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    if (id != null)
                                      IconButton(
                                        onPressed: () async {
                                          Navigator.pop(ctx);
                                          await _deleteHoliday(id);
                                          _showHolidaysManagementSheet();
                                        },
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 20,
                                        ),
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

  Future<void> _showSetHolidaySheet({
    Map<String, dynamic>? existingHoliday,
  }) async {
    if (existingHoliday == null && _isHoliday) {
      existingHoliday = {
        'id': _dashboard['holiday_id'] ?? _dashboard['id'],
        'title': _holidayName,
        'description':
            _dashboard['holiday_description'] ??
            _dashboard['description'] ??
            '',
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      };
    }

    final titleController = TextEditingController(
      text: existingHoliday?['title']?.toString() ?? '',
    );
    final descController = TextEditingController(
      text: existingHoliday?['description']?.toString() ?? '',
    );

    // Selected dates set (normalized to midnight)
    final Set<DateTime> selectedDates = <DateTime>{};
    // Map of custom titles for specific dates: 'YYYY-MM-DD' -> 'Custom Title'
    final Map<String, String> customTitles = {};

    if (existingHoliday != null && existingHoliday['date'] != null) {
      final parsed = DateTime.tryParse(existingHoliday['date'].toString());
      if (parsed != null) {
        final d = DateTime(parsed.year, parsed.month, parsed.day);
        selectedDates.add(d);
        if (existingHoliday['title'] != null) {
          customTitles[DateFormat('yyyy-MM-dd').format(d)] =
              existingHoliday['title'].toString();
        }
      }
    } else {
      selectedDates.add(
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
      );
    }

    // Current viewed month in calendar
    DateTime calendarMonth = selectedDates.isNotEmpty
        ? DateTime(selectedDates.first.year, selectedDates.first.month, 1)
        : DateTime(_selectedDate.year, _selectedDate.month, 1);

    // Range selection mode state
    bool isRangeMode = false;
    DateTime? rangeStart;
    DateTime? rangeEnd;

    // Cache of holidays for months viewed: 'YYYY-MM-DD' -> 'Title'
    final Map<String, String> holidaysCache = Map<String, String>.from(
      _monthHolidays,
    );
    // Detailed map of holidays: 'YYYY-MM-DD' -> full holiday map (with id, title, desc)
    final Map<String, Map<String, dynamic>> existingHolidaysMap = {};

    void checkAndFetchMonthHolidays(
      DateTime mMonth,
      StateSetter setModalState,
    ) {
      final mKey = DateFormat('yyyy-MM').format(mMonth);
      final hasCached = holidaysCache.keys.any((k) => k.startsWith(mKey));
      if (!hasCached) {
        _fetchMonthlyHolidays(mMonth).then((list) {
          if (list.isNotEmpty && mounted) {
            setModalState(() {
              for (final h in list) {
                if (h['date'] != null) {
                  final d = h['date'].toString();
                  existingHolidaysMap[d] = h;
                  holidaysCache[d] =
                      (h['title'] ?? h['name'] ?? 'Gym Holiday').toString();
                }
              }
            });
          }
        });
      }
    }

    // Initial fetch of current calendar month details
    _fetchMonthlyHolidays(calendarMonth).then((list) {
      if (list.isNotEmpty && mounted) {
        for (final h in list) {
          if (h['date'] != null) {
            final d = h['date'].toString();
            existingHolidaysMap[d] = h;
            holidaysCache[d] =
                (h['title'] ?? h['name'] ?? 'Gym Holiday').toString();
          }
        }
      }
    });

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            // Month calculation
            final year = calendarMonth.year;
            final month = calendarMonth.month;
            final firstDayOfMonth = DateTime(year, month, 1);
            final daysInMonth = DateTime(year, month + 1, 0).day;
            final leadingOffset = firstDayOfMonth.weekday - 1;
            final prevMonthDays = DateTime(year, month, 0).day;

            final totalCells = leadingOffset + daysInMonth;
            final totalRows = (totalCells / 7).ceil();

            // Sorted list of selected dates for display
            final sortedSelectedDates = selectedDates.toList()
              ..sort((a, b) => a.compareTo(b));

            // Dialog to set custom title for a specific date chip
            void showCustomTitleSheet(DateTime d, String dKey) {
              final dateFormatted = DateFormat('EEEE, MMM dd, yyyy').format(d);
              final customController = TextEditingController(
                text: customTitles[dKey] ??
                    (titleController.text.trim().isNotEmpty
                        ? titleController.text.trim()
                        : ''),
              );

              showModalBottomSheet<void>(
                context: ctx,
                backgroundColor: Colors.white,
                isScrollControlled: true,
                useSafeArea: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (customCtx) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 16,
                      bottom: MediaQuery.of(customCtx).viewInsets.bottom + 20,
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
                        const SizedBox(height: 12),
                        Text(
                          'Custom Title for $dateFormatted',
                          style: AppStyles.text14Px.poppins.w600.dark,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sets a specific holiday name for this day instead of the common title.',
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: customController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'e.g., Vijayadashami, Annual Maintenance',
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
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xff2471A3)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          style: AppStyles.text14Px.poppins.w400.dark,
                        ),
                        const SizedBox(height: 12),
                        // Presets - Horizontal scrollable
                        SizedBox(
                          height: 32,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: const [
                              'Sunday',
                              'Vijayadashami',
                              'Mahanavami',
                              'Ayudha Pooja',
                              'Festival',
                              'Maintenance',
                            ].length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 6),
                            itemBuilder: (subCtx, subIdx) {
                              final pList = const [
                                'Sunday',
                                'Vijayadashami',
                                'Mahanavami',
                                'Ayudha Pooja',
                                'Festival',
                                'Maintenance',
                              ];
                              final preset = pList[subIdx];
                              return ActionChip(
                                label: Text(
                                  preset,
                                  style: AppStyles.text10Px.poppins.w500
                                      .copyWith(
                                        color: const Color(0xff2471A3),
                                      ),
                                ),
                                backgroundColor: const Color(0xffEAF2F8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 0,
                                ),
                                side: BorderSide(
                                  color: const Color(0xff2471A3)
                                      .withValues(alpha: 0.2),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                onPressed: () {
                                  customController.text = preset;
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (customTitles.containsKey(dKey)) ...[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setModalState(() {
                                      customTitles.remove(dKey);
                                    });
                                    Navigator.pop(customCtx);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text('Reset to Common'),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final val = customController.text.trim();
                                  if (val.isNotEmpty) {
                                    setModalState(() {
                                      customTitles[dKey] = val;
                                    });
                                  }
                                  Navigator.pop(customCtx);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff2471A3),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Apply Custom Title'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            // Modal to view/edit/delete an existing saved holiday clicked on the calendar
            void showEditExistingHolidaySheet(DateTime d, String dKey) {
              final dateFormatted = DateFormat('EEEE, MMM dd, yyyy').format(d);
              final existingData = existingHolidaysMap[dKey];
              final holId = existingData?['id'] as int?;
              final curTitle =
                  (existingData?['title'] ?? holidaysCache[dKey] ?? 'Gym Holiday')
                      .toString();
              final curDesc = (existingData?['description'] ?? '').toString();

              final editTitleController = TextEditingController(text: curTitle);
              final editDescController = TextEditingController(text: curDesc);

              showModalBottomSheet<void>(
                context: ctx,
                backgroundColor: Colors.white,
                isScrollControlled: true,
                useSafeArea: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (holCtx) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 16,
                      bottom: MediaQuery.of(holCtx).viewInsets.bottom + 20,
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
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Edit Saved Holiday',
                                  style: AppStyles.text16Px.poppins.w600.dark,
                                ),
                                Text(
                                  dateFormatted,
                                  style: AppStyles.text12Px.poppins.w400
                                      .copyWith(color: AppColors.textGrey),
                                ),
                              ],
                            ),
                            if (holId != null)
                              IconButton(
                                onPressed: () async {
                                  Navigator.pop(holCtx);
                                  await _deleteHoliday(holId);
                                  setModalState(() {
                                    holidaysCache.remove(dKey);
                                    existingHolidaysMap.remove(dKey);
                                    selectedDates.remove(d);
                                    customTitles.remove(dKey);
                                  });
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                tooltip: 'Delete Holiday',
                              ),
                          ],
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
                          controller: editTitleController,
                          decoration: InputDecoration(
                            hintText: 'e.g., Sunday, Festival',
                            filled: true,
                            fillColor: const Color(0xffF8F9FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xffEEEEEE)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          style: AppStyles.text14Px.poppins.w400.dark,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Description (Optional)',
                          style: AppStyles.text12Px.poppins.w500.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: editDescController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Details...',
                            filled: true,
                            fillColor: const Color(0xffF8F9FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xffEEEEEE)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          style: AppStyles.text14Px.poppins.w400.dark,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setModalState(() {
                                    if (!selectedDates.contains(d)) {
                                      selectedDates.add(d);
                                    }
                                  });
                                  Navigator.pop(holCtx);
                                },
                                icon: const Icon(Icons.playlist_add, size: 18),
                                label: const Text('Add to Batch'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xff2471A3),
                                  side: const BorderSide(
                                    color: Color(0xff2471A3),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final newTitle =
                                      editTitleController.text.trim();
                                  if (newTitle.isEmpty) {
                                    Dialogs.showSnack(
                                      msg: 'Please enter a holiday title',
                                    );
                                    return;
                                  }
                                  Navigator.pop(holCtx);
                                  await _saveHoliday(
                                    date: d,
                                    title: newTitle,
                                    description: editDescController.text.trim(),
                                    holidayId: holId,
                                  );
                                  setModalState(() {
                                    holidaysCache[dKey] = newTitle;
                                    if (existingData != null) {
                                      existingHolidaysMap[dKey] = {
                                        ...existingData,
                                        'title': newTitle,
                                        'description':
                                            editDescController.text.trim(),
                                      };
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff2471A3),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Update Title'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.9,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xff2471A3,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.beach_access,
                                  color: Color(0xff2471A3),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    existingHoliday != null
                                        ? 'Edit Gym Holiday'
                                        : 'Set Gym Holidays',
                                    style: AppStyles.text16Px.poppins.w600.dark,
                                  ),
                                  Text(
                                    selectedDates.length > 1
                                        ? '${selectedDates.length} days selected'
                                        : selectedDates.length == 1
                                        ? '1 day selected'
                                        : 'Select days on calendar',
                                    style: AppStyles.text12Px.poppins.w400
                                        .copyWith(color: AppColors.textGrey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _showHolidaysManagementSheet();
                                },
                                icon: const Icon(
                                  Icons.list_alt_rounded,
                                  color: Color(0xff2471A3),
                                  size: 22,
                                ),
                                tooltip: 'View Holiday List',
                              ),
                              if (existingHoliday != null &&
                                  existingHoliday['id'] != null)
                                IconButton(
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    await _deleteHoliday(
                                      existingHoliday!['id'] as int,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 22,
                                  ),
                                  tooltip: 'Delete Holiday',
                                ),
                              IconButton(
                                onPressed: () => Navigator.pop(ctx),
                                icon: const Icon(
                                  Icons.close,
                                  color: AppColors.textGrey,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Calendar Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xffF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xffE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            // Month Navigation Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setModalState(() {
                                      calendarMonth = DateTime(
                                        calendarMonth.year,
                                        calendarMonth.month - 1,
                                        1,
                                      );
                                      checkAndFetchMonthHolidays(
                                        calendarMonth,
                                        setModalState,
                                      );
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.chevron_left,
                                    color: Color(0xff2471A3),
                                  ),
                                  splashRadius: 20,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      DateFormat(
                                        'MMMM yyyy',
                                      ).format(calendarMonth),
                                      style:
                                          AppStyles.text14Px.poppins.w600.dark,
                                    ),
                                    if (calendarMonth.year != now.year ||
                                        calendarMonth.month != now.month) ...[
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () {
                                          setModalState(() {
                                            calendarMonth = DateTime(
                                              now.year,
                                              now.month,
                                              1,
                                            );
                                            checkAndFetchMonthHolidays(
                                              calendarMonth,
                                              setModalState,
                                            );
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(6),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xff2471A3,
                                            ).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            'Today',
                                            style: AppStyles
                                                .text10Px
                                                .poppins
                                                .w600
                                                .copyWith(
                                                  color: const Color(
                                                    0xff2471A3,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    setModalState(() {
                                      calendarMonth = DateTime(
                                        calendarMonth.year,
                                        calendarMonth.month + 1,
                                        1,
                                      );
                                      checkAndFetchMonthHolidays(
                                        calendarMonth,
                                        setModalState,
                                      );
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xff2471A3),
                                  ),
                                  splashRadius: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Multi-Select vs Range Mode switch & Sunday Shortcut & Clear All
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setModalState(() {
                                              isRangeMode = false;
                                              rangeStart = null;
                                              rangeEnd = null;
                                            });
                                          },
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  !isRangeMode
                                                      ? const Color(0xff2471A3)
                                                      : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color:
                                                    !isRangeMode
                                                        ? const Color(
                                                          0xff2471A3,
                                                        )
                                                        : const Color(
                                                          0xffCBD5E1,
                                                        ),
                                              ),
                                            ),
                                            child: Text(
                                              'Multi-Days',
                                              style: AppStyles
                                                  .text10Px
                                                  .poppins
                                                  .w500
                                                  .copyWith(
                                                    color:
                                                        !isRangeMode
                                                            ? Colors.white
                                                            : AppColors
                                                                .textGrey,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        InkWell(
                                          onTap: () {
                                            setModalState(() {
                                              isRangeMode = true;
                                              rangeStart = null;
                                              rangeEnd = null;
                                            });
                                          },
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isRangeMode
                                                      ? const Color(0xff2471A3)
                                                      : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color:
                                                    isRangeMode
                                                        ? const Color(
                                                          0xff2471A3,
                                                        )
                                                        : const Color(
                                                          0xffCBD5E1,
                                                        ),
                                              ),
                                            ),
                                            child: Text(
                                              'Date Range',
                                              style: AppStyles
                                                  .text10Px
                                                  .poppins
                                                  .w500
                                                  .copyWith(
                                                    color:
                                                        isRangeMode
                                                            ? Colors.white
                                                            : AppColors
                                                                .textGrey,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        // Sunday Shortcut [⚡ All Sundays]
                                        Builder(
                                          builder: (_) {
                                            final sundays = <DateTime>[];
                                            for (
                                              int d = 1;
                                              d <= daysInMonth;
                                              d++
                                            ) {
                                              final dt = DateTime(
                                                year,
                                                month,
                                                d,
                                              );
                                              if (dt.weekday ==
                                                  DateTime.sunday) {
                                                sundays.add(dt);
                                              }
                                            }
                                            final allSundaysActive =
                                                sundays.isNotEmpty &&
                                                sundays.every(
                                                  selectedDates.contains,
                                                );

                                            return InkWell(
                                              onTap: () {
                                                setModalState(() {
                                                  if (allSundaysActive) {
                                                    selectedDates.removeAll(
                                                      sundays,
                                                    );
                                                    for (final s in sundays) {
                                                      customTitles.remove(
                                                        DateFormat(
                                                          'yyyy-MM-dd',
                                                        ).format(s),
                                                      );
                                                    }
                                                  } else {
                                                    selectedDates.addAll(
                                                      sundays,
                                                    );
                                                    if (titleController.text
                                                        .trim()
                                                        .isEmpty) {
                                                      titleController.text =
                                                          'Sunday';
                                                    }
                                                  }
                                                });
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      allSundaysActive
                                                          ? const Color(
                                                            0xffF39C12,
                                                          )
                                                          : const Color(
                                                            0xffFEF9E7,
                                                          ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xffF39C12,
                                                    ).withValues(alpha: 0.6),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.bolt,
                                                      size: 13,
                                                      color:
                                                          allSundaysActive
                                                              ? Colors.white
                                                              : const Color(
                                                                0xffD68910,
                                                              ),
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      'All Sundays',
                                                      style: AppStyles
                                                          .text10Px
                                                          .poppins
                                                          .w600
                                                          .copyWith(
                                                            color:
                                                                allSundaysActive
                                                                    ? Colors
                                                                        .white
                                                                    : const Color(
                                                                      0xffB7950B,
                                                                    ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (selectedDates.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        selectedDates.clear();
                                        customTitles.clear();
                                        rangeStart = null;
                                        rangeEnd = null;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      child: Text(
                                        'Clear All',
                                        style: AppStyles.text10Px.poppins.w600
                                            .copyWith(color: Colors.red),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Weekday Titles (Mon - Sun)
                            Row(
                              children:
                                  ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                                      .map(
                                        (d) => Expanded(
                                          child: Center(
                                            child: Text(
                                              d,
                                              style: AppStyles
                                                  .text12Px
                                                  .poppins
                                                  .w600
                                                  .copyWith(
                                                    color: AppColors.textGrey,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                            const SizedBox(height: 6),

                            // Calendar Days Grid
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: totalRows * 7,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 7,
                                    mainAxisSpacing: 4,
                                    crossAxisSpacing: 4,
                                    childAspectRatio: 1.1,
                                  ),
                              itemBuilder: (cGridCtx, i) {
                                // Previous month trailing days
                                if (i < leadingOffset) {
                                  final dayNum =
                                      prevMonthDays - leadingOffset + 1 + i;
                                  return Center(
                                    child: Text(
                                      '$dayNum',
                                      style: AppStyles.text12Px.poppins.w400
                                          .copyWith(
                                            color: Colors.grey.shade300,
                                          ),
                                    ),
                                  );
                                }

                                // Next month leading days
                                if (i >= leadingOffset + daysInMonth) {
                                  final dayNum =
                                      i - (leadingOffset + daysInMonth) + 1;
                                  return Center(
                                    child: Text(
                                      '$dayNum',
                                      style: AppStyles.text12Px.poppins.w400
                                          .copyWith(
                                            color: Colors.grey.shade300,
                                          ),
                                    ),
                                  );
                                }

                                // Current month day
                                final dayNum = i - leadingOffset + 1;
                                final cellDate = DateTime(year, month, dayNum);
                                final isSelected = selectedDates.contains(
                                  cellDate,
                                );
                                final isTodayDate =
                                    cellDate.year == today.year &&
                                    cellDate.month == today.month &&
                                    cellDate.day == today.day;
                                final dateStr = DateFormat(
                                  'yyyy-MM-dd',
                                ).format(cellDate);
                                final hasExisting = holidaysCache.containsKey(
                                  dateStr,
                                );

                                return GestureDetector(
                                  onTap: () {
                                    if (isRangeMode) {
                                      setModalState(() {
                                        if (rangeStart == null ||
                                            (rangeStart != null &&
                                                rangeEnd != null)) {
                                          rangeStart = cellDate;
                                          rangeEnd = null;
                                          selectedDates.clear();
                                          customTitles.clear();
                                          selectedDates.add(cellDate);
                                        } else {
                                          rangeEnd = cellDate;
                                          final start =
                                              rangeStart!.isBefore(rangeEnd!)
                                                  ? rangeStart!
                                                  : rangeEnd!;
                                          final end =
                                              rangeStart!.isBefore(rangeEnd!)
                                                  ? rangeEnd!
                                                  : rangeStart!;
                                          final newDates = <DateTime>{};
                                          var cur = start;
                                          while (!cur.isAfter(end)) {
                                            newDates.add(
                                              DateTime(
                                                cur.year,
                                                cur.month,
                                                cur.day,
                                              ),
                                            );
                                            cur = cur.add(
                                              const Duration(days: 1),
                                            );
                                          }
                                          selectedDates.clear();
                                          selectedDates.addAll(newDates);
                                        }
                                      });
                                    } else {
                                      // Multi-Days mode
                                      if (isSelected) {
                                        // Untoggle from current selection
                                        setModalState(() {
                                          selectedDates.remove(cellDate);
                                          customTitles.remove(dateStr);
                                        });
                                      } else if (hasExisting) {
                                        // Existing holiday clicked individually on calendar -> opens edit sheet!
                                        showEditExistingHolidaySheet(
                                          cellDate,
                                          dateStr,
                                        );
                                      } else {
                                        // Regular date toggle
                                        setModalState(() {
                                          selectedDates.add(cellDate);
                                        });
                                      }
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? const Color(0xff2471A3)
                                              : hasExisting
                                              ? const Color(0xffFDEDEC)
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? const Color(0xff2471A3)
                                                : hasExisting
                                                ? const Color(
                                                  0xffE74C3C,
                                                ).withValues(alpha: 0.45)
                                                : isTodayDate
                                                ? AppColors.primary
                                                : const Color(0xffE2E8F0),
                                        width:
                                            isSelected
                                                ? 1.5
                                                : isTodayDate
                                                ? 1.5
                                                : 1,
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Text(
                                          '$dayNum',
                                          style: AppStyles.text12Px.poppins
                                              .copyWith(
                                                fontWeight:
                                                    isSelected ||
                                                            isTodayDate ||
                                                            hasExisting
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                color:
                                                    isSelected
                                                        ? Colors.white
                                                        : hasExisting
                                                        ? const Color(
                                                          0xffC0392B,
                                                        )
                                                        : isTodayDate
                                                        ? AppColors.primary
                                                        : AppColors.dark,
                                              ),
                                        ),
                                        if (hasExisting && !isSelected)
                                          Positioned(
                                            bottom: 2,
                                            child: Container(
                                              width: 4,
                                              height: 4,
                                              decoration: const BoxDecoration(
                                                color: Color(0xffE74C3C),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),

                            // Calendar Legend
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xff2471A3),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Selected',
                                      style: AppStyles.text10Px.poppins.w500
                                          .copyWith(color: AppColors.textGrey),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xffE74C3C),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Saved Holiday',
                                      style: AppStyles.text10Px.poppins.w500
                                          .copyWith(color: AppColors.textGrey),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Today',
                                      style: AppStyles.text10Px.poppins.w500
                                          .copyWith(color: AppColors.textGrey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Selected Dates Chips Display (Horizontal scrollable)
                      if (sortedSelectedDates.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Selected Dates (${sortedSelectedDates.length})',
                              style: AppStyles.text12Px.poppins.w600.dark,
                            ),
                            Text(
                              'Tap date to rename',
                              style: AppStyles.text10Px.poppins.w500.copyWith(
                                color: const Color(0xff2471A3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 34,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: sortedSelectedDates.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(width: 6),
                            itemBuilder: (cChipsCtx, idx) {
                              final d = sortedSelectedDates[idx];
                              final dKey = DateFormat('yyyy-MM-dd').format(d);
                              final hasCustom = customTitles.containsKey(dKey);
                              final cTitle = customTitles[dKey];

                              return InkWell(
                                onTap: () => showCustomTitleSheet(d, dKey),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        hasCustom
                                            ? const Color(0xffD4E6F1)
                                            : const Color(0xffEAF2F8),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xff2471A3).withValues(
                                        alpha: hasCustom ? 0.7 : 0.3,
                                      ),
                                      width: hasCustom ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        hasCustom
                                            ? Icons.label_important_rounded
                                            : Icons.edit_outlined,
                                        size: 13,
                                        color: const Color(0xff2471A3),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        hasCustom
                                            ? '${DateFormat('E, MMM dd').format(d)}: $cTitle'
                                            : DateFormat('E, MMM dd').format(d),
                                        style: AppStyles.text12Px.poppins
                                            .copyWith(
                                              fontWeight:
                                                  hasCustom
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                              color: const Color(0xff2471A3),
                                            ),
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () {
                                          setModalState(() {
                                            selectedDates.remove(d);
                                            customTitles.remove(dKey);
                                          });
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Color(0xff2471A3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Holiday Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Common Holiday Title *',
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: AppColors.textGrey,
                            ),
                          ),
                          if (customTitles.isNotEmpty)
                            Text(
                              '${customTitles.length} custom title${customTitles.length == 1 ? '' : 's'} set',
                              style: AppStyles.text10Px.poppins.w500.copyWith(
                                color: const Color(0xff2471A3),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: titleController,
                        onChanged: (_) => setModalState(() {}),
                        decoration: InputDecoration(
                          hintText:
                              'e.g., Sunday, Diwali Vacation, Maintenance',
                          hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                            color: AppColors.textGrey,
                          ),
                          filled: true,
                          fillColor: const Color(0xffF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xffEEEEEE),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xffEEEEEE),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xff2471A3),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        style: AppStyles.text14Px.poppins.w400.dark,
                      ),
                      const SizedBox(height: 8),

                      // Preset Suggestion Chips (Horizontal scrollable with Active Filled State)
                      SizedBox(
                        height: 32,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: const [
                            'Sunday',
                            'Holiday',
                            'Festival',
                            'Maintenance',
                            'National Holiday',
                          ].length,
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 6),
                          itemBuilder: (pCtx, pIdx) {
                            final presets = const [
                              'Sunday',
                              'Holiday',
                              'Festival',
                              'Maintenance',
                              'National Holiday',
                            ];
                            final preset = presets[pIdx];
                            final isPresetSelected =
                                titleController.text.trim().toLowerCase() ==
                                preset.toLowerCase();

                            return InkWell(
                              onTap: () {
                                setModalState(() {
                                  if (isPresetSelected) {
                                    titleController.clear();
                                  } else {
                                    titleController.text = preset;
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isPresetSelected
                                          ? const Color(0xff2471A3)
                                          : const Color(0xffF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        isPresetSelected
                                            ? const Color(0xff2471A3)
                                            : const Color(0xffCBD5E1),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isPresetSelected) ...[
                                      const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      preset,
                                      style: AppStyles.text10Px.poppins
                                          .copyWith(
                                            fontWeight:
                                                isPresetSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                            color:
                                                isPresetSelected
                                                    ? Colors.white
                                                    : const Color(0xff2471A3),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description (Optional)
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
                            borderSide: const BorderSide(
                              color: Color(0xffEEEEEE),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xffEEEEEE),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xff2471A3),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        style: AppStyles.text14Px.poppins.w400.dark,
                      ),
                      const SizedBox(height: 18),

                      // Dynamic Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              selectedDates.isEmpty
                                  ? null
                                  : () async {
                                    final commonTitle =
                                        titleController.text.trim();
                                    // Check if any date relies on common title and it is empty
                                    final hasNonCustomDates = selectedDates.any(
                                      (d) {
                                        final dKey = DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(d);
                                        return !customTitles.containsKey(dKey);
                                      },
                                    );
                                    if (hasNonCustomDates &&
                                        commonTitle.isEmpty) {
                                      Dialogs.showSnack(
                                        msg:
                                            'Please enter a common holiday title',
                                      );
                                      return;
                                    }

                                    Navigator.pop(ctx);
                                    await _saveHoliday(
                                      dates: selectedDates.toList(),
                                      title:
                                          commonTitle.isNotEmpty
                                              ? commonTitle
                                              : (customTitles.values
                                                      .firstOrNull ??
                                                  'Gym Holiday'),
                                      customTitles: customTitles,
                                      description: descController.text.trim(),
                                      holidayId: existingHoliday?['id'] as int?,
                                    );
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff2471A3),
                            disabledBackgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            selectedDates.isEmpty
                                ? 'Select Dates to Save'
                                : selectedDates.length == 1
                                ? 'Save Holiday'
                                : 'Save ${selectedDates.length} Holidays',
                            style: AppStyles.text14Px.poppins.w600.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
  bool get _isHoliday {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    if (_monthHolidays.containsKey(dateStr)) return true;
    if (_dashboard['is_holiday'] == true ||
        _dashboard['is_holiday'] == 1 ||
        _dashboard['is_holiday'] == 'true')
      return true;
    if (_clients.isNotEmpty &&
        _clients.every((c) {
          final st = c['status']?.toString().toLowerCase();
          return st == 'holiday' ||
              c['is_holiday'] == true ||
              c['is_holiday'] == 1;
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
    if (c['has_marked'] == true ||
        c['is_marked'] == true ||
        c['marked'] == true)
      return true;
    final checkIn = c['check_in']?.toString();
    if (checkIn != null && checkIn.isNotEmpty && checkIn != 'null') return true;
    return false;
  }

  String _getClientStatus(Map<String, dynamic> c) {
    final clientIsHoliday =
        c['is_holiday'] == true ||
        (c['status'] ?? '').toString().toLowerCase() == 'holiday' ||
        _isHoliday;
    if (clientIsHoliday) return 'holiday';

    final isMarked = _isClientMarked(c);
    if (!isMarked) return 'unmarked';

    final s = (c['status'] ?? 'unmarked').toString().toLowerCase();
    if (s == 'not_marked' || s == 'unmarked' || s.isEmpty) return 'unmarked';
    return s;
  }

  // --- Member status & filter helpers ---
  bool _isClientExpired(Map<String, dynamic> c) {
    final bool? isActiveMember = c['is_active_member'] as bool?;
    if (isActiveMember == false) return true;

    final memStatus =
        (c['membership_status'] ??
                c['membership']?['status'] ??
                c['membership']?['membership_status'] ??
                c['status'])
            ?.toString()
            .toLowerCase();
    if (memStatus == 'expired' ||
        memStatus == 'inactive' ||
        memStatus == 'completed') {
      return true;
    }

    final endDateStr =
        (c['membership_end_date'] ??
                c['end_date'] ??
                c['valid_to'] ??
                c['membership']?['end_date'] ??
                c['membership']?['expiry_date'])
            ?.toString();
    if (endDateStr != null && endDateStr.isNotEmpty) {
      final end = DateTime.tryParse(endDateStr);
      if (end != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final endDay = DateTime(end.year, end.month, end.day);
        if (endDay.isBefore(today)) return true;
      }
    }
    return false;
  }

  bool _isClientActive(Map<String, dynamic> c) {
    if (_isClientExpired(c)) return false;
    final bool? isActiveMember = c['is_active_member'] as bool?;
    if (isActiveMember == true) return true;

    final memStatus =
        (c['membership_status'] ??
                c['membership']?['status'] ??
                c['membership']?['membership_status'] ??
                c['status'])
            ?.toString()
            .toLowerCase();
    if (memStatus == 'active' || memStatus == 'running') return true;

    return true;
  }

  bool _isClientPendingFee(Map<String, dynamic> c) {
    final payStatus =
        (c['payment_status'] ??
                c['fee_status'] ??
                c['membership']?['payment_status'] ??
                c['membership_payment_status'] ??
                '')
            .toString()
            .toLowerCase();
    if (payStatus == 'pending' ||
        payStatus == 'unpaid' ||
        payStatus == 'partial' ||
        payStatus == 'due' ||
        payStatus == 'overdue') {
      return true;
    }

    if (c['has_pending_fee'] == true ||
        c['pending_fee'] == true ||
        c['is_fee_pending'] == true) {
      return true;
    }

    final pendingAmount = double.tryParse(
      (c['pending_amount'] ?? c['due_amount'] ?? c['fee_due'] ?? 0).toString(),
    );
    if (pendingAmount != null && pendingAmount > 0) {
      return true;
    }

    return false;
  }

  int get _presentCount =>
      (_dashboard['present_count'] ?? _dashboard['clients_present_today']) as int? ??
      _clients.where((c) => _getClientStatus(c) == 'present').length;

  int get _absentCount =>
      (_dashboard['absent_count'] ?? _dashboard['clients_absent_today']) as int? ??
      _clients.where((c) => _getClientStatus(c) == 'absent').length;

  int get _unmarkedCount =>
      _dashboard['unmarked_count'] as int? ??
      _clients
          .where(
            (c) =>
                _getClientStatus(c) == 'unmarked' ||
                _getClientStatus(c) == 'not_marked',
          )
          .length;

  int get _holidayCount =>
      (_dashboard['holiday_count'] ?? _dashboard['clients_holiday'] ?? _dashboard['clients_on_holiday']) as int? ??
      _clients.where((c) => _getClientStatus(c) == 'holiday').length;

  int get _activeMembersCount =>
      (_dashboard['active_clients_count'] ??
          _dashboard['total_active_clients']) as int? ??
      _clients.where(_isClientActive).length;

  int get _expiredMembersCount =>
      _dashboard['expired_clients_count'] as int? ??
      _clients.where(_isClientExpired).length;

  int get _pendingFeeCount =>
      _dashboard['pending_fee_count'] as int? ??
      _clients.where(_isClientPendingFee).length;

  int get _activePresentCount =>
      (_dashboard['active_present_count'] ??
          _dashboard['active_clients_present_today']) as int? ??
      _clients
          .where((c) => _isClientActive(c) && _getClientStatus(c) == 'present')
          .length;

  int get _expiredPresentCount =>
      (_dashboard['expired_present_count'] ??
          _dashboard['expired_clients_present_today']) as int? ??
      _clients
          .where((c) => _isClientExpired(c) && _getClientStatus(c) == 'present')
          .length;

  int get _pendingFeePresentCount =>
      (_dashboard['pending_fee_present_count'] ??
          _dashboard['pending_fee_clients_present_today']) as int? ??
      _clients
          .where(
            (c) => _isClientPendingFee(c) && _getClientStatus(c) == 'present',
          )
          .length;

  double get _attendancePercentage {
    final raw =
        _dashboard['attendance_percentage'] ?? _dashboard['present_percentage'];
    if (raw != null) {
      final parsed = double.tryParse(raw.toString());
      if (parsed != null) return parsed;
    }
    final activeTotal = _activeMembersCount;
    if (activeTotal > 0) {
      return (_activePresentCount / activeTotal) * 100;
    }
    final present = _presentCount;
    final total = (_dashboard['total_clients_count'] as int?) ??
        (_dashboard['count'] as int?) ??
        (present + _absentCount + _unmarkedCount + _holidayCount);
    return total > 0 ? (present / total) * 100 : 0.0;
  }

  List<Map<String, dynamic>> get _filteredClients {
    var list = _clients;
    if (_statusFilter != 'all') {
      list =
          list.where((c) {
            switch (_statusFilter) {
              case 'active':
                return _isClientActive(c);
              case 'active_present':
                return _isClientActive(c) && _getClientStatus(c) == 'present';
              case 'expired':
                return _isClientExpired(c);
              case 'expired_present':
                return _isClientExpired(c) && _getClientStatus(c) == 'present';
              case 'pending_fee':
                return _isClientPendingFee(c);
              case 'pending_fee_present':
                return _isClientPendingFee(c) &&
                    _getClientStatus(c) == 'present';
              case 'present':
                return _getClientStatus(c) == 'present';
              case 'absent':
                return _getClientStatus(c) == 'absent';
              case 'holiday':
                return _getClientStatus(c) == 'holiday';
              case 'unmarked':
              case 'not_marked':
                return _getClientStatus(c) == 'unmarked' ||
                    _getClientStatus(c) == 'not_marked';
              default:
                return true;
            }
          }).toList();
    }
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    final filtered =
        list.where((c) {
          final name =
              (c['name'] ??
                      c['customer_name'] ??
                      c['client_name'] ??
                      c['full_name'] ??
                      '${c['first_name'] ?? ''} ${c['last_name'] ?? ''}')
                  .toString()
                  .toLowerCase();
          final mobile =
              (c['mobile'] ??
                      c['phone'] ??
                      c['mobile_number'] ??
                      c['phone_number'] ??
                      '')
                  .toString()
                  .toLowerCase();
          final plan =
              (c['plan_name'] ?? c['membership_plan'] ?? '')
                  .toString()
                  .toLowerCase();
          final email = (c['email'] ?? '').toString().toLowerCase();
          final id =
              (c['customer_id'] ?? c['client_id'] ?? c['id'] ?? '')
                  .toString()
                  .toLowerCase();
          return name.contains(q) ||
              mobile.contains(q) ||
              plan.contains(q) ||
              email.contains(q) ||
              id.contains(q);
        }).toList();

    int getRelevanceScore(Map<String, dynamic> c) {
      final name =
          (c['name'] ??
                  c['customer_name'] ??
                  c['client_name'] ??
                  c['full_name'] ??
                  '${c['first_name'] ?? ''} ${c['last_name'] ?? ''}')
              .toString()
              .toLowerCase()
              .trim();

      // Priority 0: Name starts directly with the query (e.g. "DIFIN", "Dilna")
      if (name.startsWith(q)) return 0;

      // Priority 1: Any individual word in the name starts with query (e.g. "Ananya G Divakaran")
      final words = name.split(RegExp(r'\s+'));
      if (words.any((w) => w.startsWith(q))) return 1;

      // Priority 2: Phone number starts with query
      final mobile =
          (c['mobile'] ??
                  c['phone'] ??
                  c['mobile_number'] ??
                  c['phone_number'] ??
                  '')
              .toString()
              .toLowerCase()
              .trim();
      if (mobile.startsWith(q)) return 2;

      // Priority 3: Substring match inside a word (e.g. "Adithya", "ambadi")
      return 3;
    }

    filtered.sort((a, b) {
      final scoreA = getRelevanceScore(a);
      final scoreB = getRelevanceScore(b);
      if (scoreA != scoreB) {
        return scoreA.compareTo(scoreB);
      }
      final nameA =
          (a['name'] ??
                  a['customer_name'] ??
                  a['client_name'] ??
                  a['full_name'] ??
                  '')
              .toString()
              .toLowerCase();
      final nameB =
          (b['name'] ??
                  b['customer_name'] ??
                  b['client_name'] ??
                  b['full_name'] ??
                  '')
              .toString()
              .toLowerCase();
      return nameA.compareTo(nameB);
    });

    return filtered;
  }

  // --- Status helpers ---
  ({Color bg, Color fg, String label}) _statusStyle(String status) {
    switch (status) {
      case 'present':
        return (
          bg: const Color(0xffE8F8F5),
          fg: const Color(0xff27AE60),
          label: 'Present',
        );
      case 'absent':
        return (
          bg: const Color(0xffFDEDEC),
          fg: AppColors.primary,
          label: 'Absent',
        );
      case 'holiday':
        return (
          bg: const Color(0xffEAF2F8),
          fg: const Color(0xff2471A3),
          label: 'Holiday',
        );
      case 'unmarked':
      case 'not_marked':
      default:
        return (
          bg: const Color(0xffF2F4F4),
          fg: const Color(0xff7F8C8D),
          label: 'Unmarked',
        );
    }
  }

  void _showMarkAttendanceSheet(Map<String, dynamic> client) {
    final clientId =
        client['client_id'] as int? ??
        client['customer_id'] as int? ??
        client['id'] as int? ??
        0;
    final clientName =
        (client['name'] ?? client['customer_name'] ?? 'Client').toString();
    final currentStatus = _getClientStatus(client);
    final attendanceId = client['attendance_id'] as int?;

    final clientIsHoliday =
        client['is_holiday'] == true ||
        currentStatus == 'holiday' ||
        _isHoliday;
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
      (
        value: 'present',
        label: 'Present',
        color: const Color(0xff27AE60),
        icon: Icons.check_circle_outline,
      ),
      (
        value: 'absent',
        label: 'Absent',
        color: AppColors.primary,
        icon: Icons.cancel_outlined,
      ),
    ];

    String selectedStatus =
        currentStatus == 'unmarked' || currentStatus == 'not_marked'
            ? 'present'
            : currentStatus;
    String? checkIn = client['check_in']?.toString();
    String? checkOut = client['check_out']?.toString();

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
                      style: AppStyles.text14Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? status.color.withValues(alpha: 0.1)
                                      : const Color(0xffF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? status.color
                                        : const Color(0xffEEEEEE),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  status.icon,
                                  color: status.color,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    status.label,
                                    style:
                                        isSelected
                                            ? AppStyles.text14Px.poppins.w600
                                                .copyWith(color: status.color)
                                            : AppStyles
                                                .text14Px
                                                .poppins
                                                .w400
                                                .dark,
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: status.color,
                                    size: 20,
                                  ),
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
                              onChanged:
                                  (v) => setModalState(() => checkIn = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TimePickerField(
                              label: 'Check-out',
                              value: checkOut,
                              onChanged:
                                  (v) => setModalState(() => checkOut = v),
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
              onPressed: () => _showSetHolidaySheet(),
              icon: const Icon(
                Icons.free_cancellation_outlined,
                color: Color(0xff2471A3),
              ),
              tooltip: 'Set Gym Holiday',
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

          // Summary Pie Chart & Metrics
          _buildAttendancePieChartSummary(),

          if (_isHoliday)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: InkWell(
                onTap: () => _showSetHolidaySheet(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
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
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xff2471A3),
                        size: 13,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Search Bar & Active Filter Bar
          _buildSearchBar(),

          // Client List
          Expanded(
            child:
                _isLoading
                    ? _buildAttendanceShimmer()
                    : _isSearching
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
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
                                : _statusFilter != 'all'
                                ? 'No clients found for "${_getFilterLabel(_statusFilter)}"'
                                : 'No clients found for this date',
                            style: AppStyles.text14Px.poppins.w500.copyWith(
                              color: AppColors.textGrey,
                            ),
                          ),
                          if (_statusFilter != 'all') ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                setState(() => _statusFilter = 'all');
                                _fetchAttendance();
                              },
                              child: const Text('Clear Filter'),
                            ),
                          ],
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: () => _fetchAttendance(forceRefresh: true),
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount:
                            _filteredClients.length + (_isLoadingMore ? 1 : 0),
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
              children:
                  dates.map((date) {
                    final isSelected =
                        date.year == _selectedDate.year &&
                        date.month == _selectedDate.month &&
                        date.day == _selectedDate.day;
                    final isToday =
                        date.year == today.year &&
                        date.month == today.month &&
                        date.day == today.day;
                    final dateStr = DateFormat('yyyy-MM-dd').format(date);
                    final isHolidayDay =
                        _monthHolidays.containsKey(dateStr) ||
                        (isSelected && _isHoliday);

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(date),
                        child: Container(
                          height: 72,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? (isHolidayDay
                                        ? const Color(0xff486CC2)
                                        : AppColors.primary)
                                    : isToday
                                    ? AppColors.primary.withValues(alpha: 0.08)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                isSelected
                                    ? null
                                    : isToday
                                    ? Border.all(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                    )
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
                                    DateFormat(
                                      'E',
                                    ).format(date).substring(0, 3),
                                    style: AppStyles.text12Px.poppins.w500
                                        .copyWith(
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : AppColors.textGrey,
                                        ),
                                  ),
                                  if (isHolidayDay) ...[
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.beach_access,
                                      size: 10,
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : AppColors.textGrey,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${date.day}',
                                style: AppStyles.text18Px.poppins.w700.copyWith(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : AppColors.dark,
                                ),
                              ),
                              Text(
                                DateFormat('MMM').format(date),
                                style: AppStyles.text10Px.poppins.w400.copyWith(
                                  color:
                                      isSelected
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

  /// Interactive Attendance Pie Chart & Summary Card
  Widget _buildAttendancePieChartSummary() {
    if (_isHoliday) {
      return const SizedBox.shrink();
    }

    final present = _presentCount;
    final absent = _absentCount;
    final unmarked = _unmarkedCount;
    final holiday = _holidayCount;

    final total = (_dashboard['total_clients_count'] as int?) ??
        (_dashboard['count'] as int?) ??
        (present + absent + unmarked + holiday);

    final presentPct = _attendancePercentage;

    final slices = [
      (
        label: 'Present',
        count: present,
        percentage: present.toDouble(),
        color: const Color(0xff27AE60),
        key: 'present',
      ),
      (
        label: 'Absent',
        count: absent,
        percentage: absent.toDouble(),
        color: AppColors.primary,
        key: 'absent',
      ),
      (
        label: 'Unmarked',
        count: unmarked,
        percentage: unmarked.toDouble(),
        color: const Color(0xff95A5A6),
        key: 'unmarked',
      ),
      if (holiday > 0)
        (
          label: 'Holiday',
          count: holiday,
          percentage: holiday.toDouble(),
          color: const Color(0xff2471A3),
          key: 'holiday',
        ),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xffF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffEEEEEE)),
        ),
        child: Row(
          children: [
            // Donut Pie Chart with central Attendance %
            SizedBox(
              width: 86,
              height: 86,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(86, 86),
                    painter: _ClientAttendancePieChartPainter(
                      slices:
                          slices
                              .map(
                                (s) => (
                                  percentage: s.percentage,
                                  color: s.color,
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${presentPct.toStringAsFixed(0)}%',
                        style: AppStyles.text14Px.poppins.w700.copyWith(
                          color: const Color(0xff27AE60),
                        ),
                      ),
                      Text(
                        'Present',
                        style: AppStyles.text10Px.poppins.w500.copyWith(
                          color: AppColors.textGrey,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Slices summary & Quick Filter Chips
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attendance Report',
                        style: AppStyles.text12Px.poppins.w600.dark,
                      ),
                      GestureDetector(
                        onTap: _showAttendanceReportSheet,
                        child: Text(
                          'View Details >',
                          style: AppStyles.text10Px.poppins.w600.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        slices.map((s) {
                          final isSelected = _statusFilter == s.key;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _statusFilter = isSelected ? 'all' : s.key;
                              });
                              _fetchAttendance();
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? s.color.withValues(alpha: 0.18)
                                        : s.color.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? s.color
                                          : s.color.withValues(alpha: 0.25),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 3.5,
                                    backgroundColor: s.color,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${s.label}: ${s.count}',
                                    style: AppStyles.text10Px.poppins.w600
                                        .copyWith(color: s.color),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final hasFilter = _statusFilter != 'all';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search clients...',
                      hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textGrey,
                        size: 20,
                      ),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: AppColors.textGrey,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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
                  color:
                      hasFilter ? AppColors.primary : const Color(0xffF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _showStatusFilterSheet,
                  icon: Icon(
                    Icons.tune,
                    color: hasFilter ? Colors.white : AppColors.textGrey,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          if (hasFilter) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Filtered by: ',
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getFilterLabel(_statusFilter),
                        style: AppStyles.text12Px.poppins.w600.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() => _statusFilter = 'all');
                          _fetchAttendance();
                        },
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getFilterLabel(String key) {
    switch (key) {
      case 'active':
        return 'Active Members';
      case 'active_present':
        return 'Active (Present)';
      case 'expired':
        return 'Expired Members';
      case 'expired_present':
        return 'Expired (Present)';
      case 'pending_fee':
        return 'Pending Fee';
      case 'pending_fee_present':
        return 'Pending Fee (Present)';
      case 'present':
        return 'Present';
      case 'absent':
        return 'Absent';
      case 'unmarked':
        return 'Unmarked';
      case 'holiday':
        return 'Holiday';
      default:
        return 'All';
    }
  }

  void _openClientDetail(Map<String, dynamic> client) {
    final customerId =
        client['customer_id'] as int? ??
        client['client_id'] as int? ??
        client['id'] as int? ??
        client['user_id'] as int? ??
        0;
    if (customerId == 0) return;

    if (widget.isTrainer) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder:
              (context) => TrainerClientDetailScreen(customerId: customerId),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder:
              (context) => MemberDetialsScreen(
                memberId: customerId,
                orgId: widget.orgId,
              ),
        ),
      );
    }
  }

  /// Client Tile - Tap card to view details, tap 'Unmarked' badge to mark attendance
  Widget _buildClientTile(Map<String, dynamic> client) {
    final name =
        (client['name'] ?? client['customer_name'] ?? 'Unknown').toString();
    final plan =
        (client['plan_name'] ?? client['membership_plan'] ?? '').toString();
    final status = _getClientStatus(client);
    final clientIsHoliday = status == 'holiday';
    final isUnmarked = status == 'unmarked' || status == 'not_marked';
    final checkIn = (client['check_in'] ?? '').toString();
    final checkOut = (client['check_out'] ?? '').toString();
    final profilePic = client['profile_picture'] as String?;
    final style = _statusStyle(status);

    final hasTimings = checkIn.isNotEmpty && checkIn != 'null';
    String timingText = '';
    if (clientIsHoliday) {
      timingText =
          (client['holiday_name'] ?? client['holiday_title'] ?? _holidayName)
              .toString();
    } else if (hasTimings) {
      timingText = _formatTime(checkIn);
      if (checkOut.isNotEmpty && checkOut != 'null') {
        timingText += ' - ${_formatTime(checkOut)}';
      }
    }

    final isExpired = _isClientExpired(client);
    final isActive = _isClientActive(client);

    return InkWell(
      onTap: () => _openClientDetail(client),
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
              child: ProfileImage(isEdit: false, url: profilePic, radius: 48),
            ),
            const SizedBox(width: 12),

            // Name, Plan & Membership/Fee tags
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
                      if (isExpired) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Expired',
                            style: AppStyles.text10Px.poppins.w600.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ] else if (isActive &&
                          (_statusFilter == 'active' ||
                              _statusFilter == 'active_present')) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffE8F8F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Active',
                            style: AppStyles.text10Px.poppins.w600.copyWith(
                              color: const Color(0xff27AE60),
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

            // Status action button: ONLY "Unmarked" allows tap to mark attendance
            if (isUnmarked) ...[
              InkWell(
                onTap: () => _showMarkAttendanceSheet(client),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF2F4F4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xffBDC3C7)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Unmarked',
                        style: AppStyles.text12Px.poppins.w600.copyWith(
                          color: const Color(0xff7F8C8D),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Color(0xff7F8C8D),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Already marked status - tapping badge allows edit, tapping card opens details
              GestureDetector(
                onTap: () => _showMarkAttendanceSheet(client),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: style.bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        style.label,
                        style: AppStyles.text12Px.poppins.w600.copyWith(
                          color: style.fg,
                        ),
                      ),
                    ),
                    if (clientIsHoliday || hasTimings) ...[
                      const SizedBox(height: 4),
                      Text(
                        timingText,
                        style: AppStyles.text10Px.poppins.w400.copyWith(
                          color:
                              clientIsHoliday
                                  ? const Color(0xff2471A3)
                                  : AppColors.textGrey,
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
              ),
            ],

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
        return '$hour:${minute.toString().padLeft(2, '0')} $period';
      }
    } catch (_) {}
    return time;
  }

  /// Filter Bottom Sheet - includes Active, Expired, Pending Fee, and attendance statuses
  void _showStatusFilterSheet() {
    final filterOptions = [
      (
        value: 'all',
        label: 'All Clients',
        count: (_dashboard['total_clients_count'] ?? _dashboard['count']) as int? ?? _clients.length,
        color: AppColors.primary,
        icon: Icons.people_outline,
      ),
      (
        value: 'active',
        label: 'Active Members',
        count: _activeMembersCount,
        color: const Color(0xff27AE60),
        icon: Icons.check_circle_outline,
      ),
      (
        value: 'expired',
        label: 'Expired Members',
        count: _expiredMembersCount,
        color: AppColors.primary,
        icon: Icons.cancel_outlined,
      ),
      (
        value: 'pending_fee',
        label: 'Pending Fee',
        count: _pendingFeeCount,
        color: const Color(0xffE67E22),
        icon: Icons.payment_outlined,
      ),
      (
        value: 'present',
        label: 'Present Today',
        count: _presentCount,
        color: const Color(0xff27AE60),
        icon: Icons.person_add_alt_1_outlined,
      ),
      (
        value: 'absent',
        label: 'Absent Today',
        count: _absentCount,
        color: AppColors.primary,
        icon: Icons.person_off_outlined,
      ),
      (
        value: 'unmarked',
        label: 'Unmarked',
        count: _unmarkedCount,
        color: const Color(0xff7F8C8D),
        icon: Icons.help_outline,
      ),
      if (_holidayCount > 0)
        (
          value: 'holiday',
          label: 'Gym Holiday',
          count: _holidayCount,
          color: const Color(0xff2471A3),
          icon: Icons.beach_access_outlined,
        ),
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                Text(
                  'Filter Clients',
                  style: AppStyles.text16Px.poppins.w600.dark,
                ),
                const SizedBox(height: 4),
                Text(
                  'Select status or membership state to filter',
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 12),
                ...filterOptions.map((opt) {
                  final isSelected = _statusFilter == opt.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _statusFilter = opt.value;
                        });
                        _fetchAttendance();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? opt.color.withValues(alpha: 0.1)
                                  : const Color(0xffF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? opt.color
                                    : const Color(0xffEEEEEE),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(opt.icon, color: opt.color, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                opt.label,
                                style:
                                    isSelected
                                        ? AppStyles.text14Px.poppins.w600
                                            .copyWith(color: opt.color)
                                        : AppStyles.text14Px.poppins.w400.dark,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? opt.color.withValues(alpha: 0.2)
                                        : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${opt.count}',
                                style: AppStyles.text12Px.poppins.w600.copyWith(
                                  color:
                                      isSelected ? opt.color : AppColors.dark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Full Attendance Report Bottom Sheet with Pie Chart
  void _showAttendanceReportSheet() {
    final present = _presentCount;
    final absent = _absentCount;
    final unmarked = _unmarkedCount;
    final holiday = _holidayCount;

    final total = (_dashboard['total_clients_count'] as int?) ??
        (_dashboard['count'] as int?) ??
        (present + absent + unmarked + holiday);

    final presentPct = _attendancePercentage;
    final absentPct = (_dashboard['absent_percentage'] != null)
        ? (double.tryParse(_dashboard['absent_percentage'].toString()) ?? 0.0)
        : (total > 0 ? (absent / total) * 100 : 0.0);
    final unmarkedPct = (_dashboard['unmarked_percentage'] != null)
        ? (double.tryParse(_dashboard['unmarked_percentage'].toString()) ?? 0.0)
        : (total > 0 ? (unmarked / total) * 100 : 0.0);

    final slices = [
      (
        label: 'Present',
        count: present,
        percentage: present.toDouble(),
        color: const Color(0xff27AE60),
      ),
      (
        label: 'Absent',
        count: absent,
        percentage: absent.toDouble(),
        color: AppColors.primary,
      ),
      (
        label: 'Unmarked',
        count: unmarked,
        percentage: unmarked.toDouble(),
        color: const Color(0xff95A5A6),
      ),
      if (holiday > 0)
        (
          label: 'Holiday',
          count: holiday,
          percentage: holiday.toDouble(),
          color: const Color(0xff2471A3),
        ),
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                      'Attendance Analytics',
                      style: AppStyles.text16Px.poppins.w600.dark,
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Large Pie Chart
                Center(
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(140, 140),
                          painter: _ClientAttendancePieChartPainter(
                            strokeWidth: 26.0,
                            slices:
                                slices
                                    .map(
                                      (s) => (
                                        percentage: s.percentage,
                                        color: s.color,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${presentPct.toStringAsFixed(0)}%',
                              style: AppStyles.text20Px.poppins.w700.copyWith(
                                color: const Color(0xff27AE60),
                              ),
                            ),
                            Text(
                              'Attendance Rate',
                              style: AppStyles.text10Px.poppins.w500.copyWith(
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Breakdown list
                _buildReportBreakdownRow(
                  label: 'Present',
                  count: present,
                  percentage: presentPct,
                  color: const Color(0xff27AE60),
                  icon: Icons.check_circle_outline,
                ),
                const SizedBox(height: 10),
                _buildReportBreakdownRow(
                  label: 'Absent',
                  count: absent,
                  percentage: absentPct,
                  color: AppColors.primary,
                  icon: Icons.cancel_outlined,
                ),
                const SizedBox(height: 10),
                _buildReportBreakdownRow(
                  label: 'Unmarked',
                  count: unmarked,
                  percentage: unmarkedPct,
                  color: const Color(0xff95A5A6),
                  icon: Icons.help_outline,
                ),
                if (holiday > 0) ...[
                  const SizedBox(height: 10),
                  _buildReportBreakdownRow(
                    label: 'Gym Holiday',
                    count: holiday,
                    percentage: total > 0 ? (holiday / total) * 100 : 0.0,
                    color: const Color(0xff2471A3),
                    icon: Icons.beach_access_outlined,
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(color: Color(0xffEEEEEE)),
                const SizedBox(height: 12),

                // Membership summary info for present clients
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniMetric('Total Clients', '$total', AppColors.dark),
                    _buildMiniMetric(
                      'Active',
                      '$_activePresentCount',
                      const Color(0xff27AE60),
                      onTap: _activePresentCount > 0
                          ? () {
                              Navigator.pop(ctx);
                              setState(() => _statusFilter = 'active_present');
                              _fetchAttendance();
                            }
                          : null,
                    ),
                    _buildMiniMetric(
                      'Expired',
                      '$_expiredPresentCount',
                      const Color(0xffE74C3C),
                      onTap: _expiredPresentCount > 0
                          ? () {
                              Navigator.pop(ctx);
                              setState(() => _statusFilter = 'expired_present');
                              _fetchAttendance();
                            }
                          : null,
                    ),
                    _buildMiniMetric(
                      'Balance',
                      '$_pendingFeePresentCount',
                      const Color(0xffE67E22),
                      onTap: _pendingFeePresentCount > 0
                          ? () {
                              Navigator.pop(ctx);
                              setState(() => _statusFilter = 'pending_fee_present');
                              _fetchAttendance();
                            }
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportBreakdownRow({
    required String label,
    required int count,
    required double percentage,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xffF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffEEEEEE)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: AppStyles.text14Px.poppins.w500.dark),
          ),
          Text(
            '$count (${percentage.toStringAsFixed(1)}%)',
            style: AppStyles.text14Px.poppins.w600.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color color, {VoidCallback? onTap}) {
    final content = Column(
      children: [
        Text(
          value,
          style: AppStyles.text16Px.poppins.w700.copyWith(color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppStyles.text10Px.poppins.w500.copyWith(
            color: onTap != null ? color : AppColors.textGrey,
            decoration: onTap != null ? TextDecoration.underline : null,
            decorationColor: onTap != null ? color : null,
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(height: 2),
          Icon(Icons.chevron_right, size: 14, color: color),
        ],
      ],
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: content,
      ),
    );
  }
  Widget _buildAttendanceShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              const KShimmer(width: 48, height: 48, radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    KShimmer(width: 130, height: 14, radius: 4),
                    SizedBox(height: 6),
                    KShimmer(width: 90, height: 12, radius: 4),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const KShimmer(width: 80, height: 32, radius: 16),
            ],
          ),
        );
      },
    );
  }
}

/// Custom Donut Pie Chart Painter
class _ClientAttendancePieChartPainter extends CustomPainter {
  final List<({double percentage, Color color})> slices;
  final double strokeWidth;

  _ClientAttendancePieChartPainter({
    required this.slices,
    this.strokeWidth = 14.0,
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
      final bgPaint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..color = const Color(0xffE5E7EB);
      canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);
      return;
    }

    var startAngle = -math.pi / 2;

    for (final slice in slices) {
      if (slice.percentage <= 0) continue;
      final sweepAngle = (slice.percentage / total) * 2 * math.pi;
      final paint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..color = slice.color
            ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _ClientAttendancePieChartPainter oldDelegate) {
    return oldDelegate.slices != slices ||
        oldDelegate.strokeWidth != strokeWidth;
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
                      color:
                          value != null ? AppColors.dark : AppColors.textGrey,
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
