import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/themes/app_theme_colors.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:intl/intl.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_details_screen.dart';

class TrainerAssignedWorkoutsScreen extends StatefulWidget {
  final int? customerId;
  final String? customerName;

  const TrainerAssignedWorkoutsScreen({
    this.customerId,
    this.customerName,
    super.key,
  });

  static void clearCache() {}

  @override
  State<TrainerAssignedWorkoutsScreen> createState() =>
      _TrainerAssignedWorkoutsScreenState();
}

class _TrainerAssignedWorkoutsScreenState
    extends State<TrainerAssignedWorkoutsScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _hasFetchedAll = false;
  int _currentPage = 1;
  static const int _pageSize = 20;

  late final ScrollController _scrollController;

  List<Map<String, dynamic>> _assignedWorkouts = [];
  String _searchQuery = '';

  // Filter & Sort State
  DateTime _selectedDate = DateTime.now();
  bool _sortNewestFirst = true; // true = newest first, false = oldest first

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _loadAssignedWorkouts(resetPage: true, forceRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreAssignedWorkouts();
    }
  }

  void _selectDate(DateTime date) {
    if (!mounted) return;
    setState(() {
      _selectedDate = date;
    });
    _loadAssignedWorkouts(resetPage: true, forceRefresh: true);
  }

  Future<void> _loadMoreAssignedWorkouts() async {
    if (!mounted || _isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await _loadAssignedWorkouts(resetPage: false);
  }

  Future<void> _loadAssignedWorkouts({
    bool resetPage = true,
    bool forceRefresh = false,
  }) async {
    if (!mounted) return;

    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    if (resetPage) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _hasMore = true;
        _assignedWorkouts = [];
        _hasFetchedAll = false;
      });
    }

    if (widget.customerId != null) {
      final workouts = await _fetchAssignedWorkoutsForClient(
        widget.customerId!,
        widget.customerName ?? 'Client',
        dateStr: selectedDateStr,
      );
      if (mounted) {
        setState(() {
          _assignedWorkouts = workouts;
          _isLoading = false;
          _isLoadingMore = false;
          _hasMore = false;
          _hasFetchedAll = true;
        });
      }
      return;
    }

    final Map<String, dynamic> queryParams = {
      'date': selectedDateStr,
      'status': 'all',
      'page': _currentPage,
      'page_size': _pageSize,
    };

    // Fetch for all clients of the trainer using single endpoint
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerAssignedWorkouts,
        queryParameters: queryParams,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        final workouts = _parseWorkoutsResponse(response.data, 'Client', 0);
        if (mounted) {
          setState(() {
            if (resetPage) {
              _assignedWorkouts = workouts;
            } else {
              _assignedWorkouts.addAll(workouts);
            }
            _hasMore = workouts.length >= _pageSize;
            _isLoading = false;
            _isLoadingMore = false;
          });
        }
        return;
      }
    } catch (_) {}

    // Fallback: Fetch per client if single endpoint is unavailable
    if (resetPage) {
      try {
        final clientsRes = await DioClient().dio.get<dynamic>(
          ApiUris.trainerCustomers,
          options: Options(headers: {'X-Platform': platformSource}),
        );

        if (clientsRes.statusCode == 200) {
          List<dynamic> dataList = [];
          if (clientsRes.data is List) {
            dataList = clientsRes.data as List;
          } else if (clientsRes.data is Map &&
              clientsRes.data['results'] is List) {
            dataList = clientsRes.data['results'] as List;
          }

          final clients =
              dataList.map((e) => Map<String, dynamic>.from(e as Map)).toList();

          final List<Future<List<Map<String, dynamic>>>> futures = [];
          for (final client in clients) {
            final profile = client['profile'] as Map? ?? client;
            final cid = client['id'] as int? ?? client['customer_id'] as int?;
            final cname =
                profile['name']?.toString() ??
                profile['first_name']?.toString() ??
                'Client';
            if (cid != null) {
              futures.add(_fetchAssignedWorkoutsForClient(cid, cname, dateStr: selectedDateStr));
            }
          }

          final results = await Future.wait(futures);
          final List<Map<String, dynamic>> combinedWorkouts = [];
          for (final res in results) {
            combinedWorkouts.addAll(res);
          }

          if (mounted) {
            setState(() {
              _assignedWorkouts = combinedWorkouts;
              _isLoading = false;
              _isLoadingMore = false;
              _hasMore = false;
              _hasFetchedAll = true;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _isLoadingMore = false;
              _hasMore = false;
            });
          }
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isLoadingMore = false;
            _hasMore = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _hasMore = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _parseWorkoutsResponse(
    dynamic data,
    String clientName,
    int customerId,
  ) {
    List<Map<String, dynamic>> list = [];
    if (data is List) {
      list = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } else if (data is Map) {
      if (data['results'] is List && (data['results'] as List).isNotEmpty) {
        list = (data['results'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } else {
        final plans = data['assigned_plans'] is List
            ? (data['assigned_plans'] as List)
            : [];
        final sessions = data['assigned_sessions'] is List
            ? (data['assigned_sessions'] as List)
            : [];
        final workouts = data['assigned_workouts'] is List
            ? (data['assigned_workouts'] as List)
            : [];
        final genericPlans =
            data['plans'] is List ? (data['plans'] as List) : [];
        final dataItems =
            data['data'] is List ? (data['data'] as List) : [];

        final combined = [
          ...plans,
          ...sessions,
          ...workouts,
          ...genericPlans,
          ...dataItems,
        ];
        if (combined.isNotEmpty) {
          list = combined
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      }
    }

    for (final item in list) {
      item['client_name'] =
          item['client_name'] ??
          item['customer_name'] ??
          item['customer']?['name'] ??
          item['client']?['name'] ??
          (clientName != 'Client' ? clientName : null) ??
          'Client';
      item['customer_id'] =
          item['customer_id'] ??
          item['client_id'] ??
          (customerId > 0 ? customerId : null);
    }

    return list;
  }

  Future<List<Map<String, dynamic>>> _fetchAssignedWorkoutsForClient(
    int customerId,
    String clientName, {
    String? dateStr,
  }) async {
    List<Map<String, dynamic>> workoutsList = [];
    bool fetched = false;

    // 1. Primary Endpoint with server-side date filtering
    try {
      String url = ApiUris.trainerClientAssignedWorkouts(customerId);
      if (dateStr != null && dateStr.isNotEmpty) {
        url += '?date=$dateStr';
      }
      final response = await DioClient().dio.get<dynamic>(
        url,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200) {
        workoutsList = _parseWorkoutsResponse(
          response.data,
          clientName,
          customerId,
        );
        if (workoutsList.isNotEmpty) fetched = true;
      }
    } catch (_) {}

    // 2. Fallback Endpoint
    if (!fetched) {
      try {
        final response = await DioClient().dio.get<dynamic>(
          ApiUris.customerAssignedWorkouts(customerId),
          options: Options(headers: {'X-Platform': platformSource}),
        );
        if (response.statusCode == 200) {
          workoutsList = _parseWorkoutsResponse(
            response.data,
            clientName,
            customerId,
          );
          if (workoutsList.isNotEmpty) fetched = true;
        }
      } catch (_) {}
    }

    // 3. Fallback Endpoint All
    if (!fetched) {
      try {
        final response = await DioClient().dio.get<dynamic>(
          ApiUris.customerAssignedWorkoutsAll(customerId),
          options: Options(headers: {'X-Platform': platformSource}),
        );
        if (response.statusCode == 200) {
          workoutsList = _parseWorkoutsResponse(
            response.data,
            clientName,
            customerId,
          );
          if (workoutsList.isNotEmpty) fetched = true;
        }
      } catch (_) {}
    }

    return workoutsList;
  }

  String _extractDateString(Map<String, dynamic> item) {
    final raw =
        (item['scheduled_date'] ??
                item['session_date'] ??
                item['start_date'] ??
                item['assigned_date'] ??
                item['date'] ??
                item['created_at'] ??
                '')
            .toString();
    if (raw.length >= 10) {
      return raw.substring(0, 10);
    }
    return raw;
  }

  Widget _buildDateHeader() {
    final today = DateTime.now();
    final isToday =
        _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;

    final dateDisplay =
        isToday
            ? 'Today (${DateFormat('dd MMM, yyyy').format(_selectedDate)})'
            : DateFormat('EEEE, dd MMM yyyy').format(_selectedDate);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xffF8F9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                _selectDate(_selectedDate.subtract(const Duration(days: 1)));
              },
              icon: const Icon(
                Icons.chevron_left,
                color: AppColors.dark,
                size: 26,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  _selectDate(picked);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateDisplay,
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: AppColors.dark,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                _selectDate(_selectedDate.add(const Duration(days: 1)));
              },
              icon: const Icon(
                Icons.chevron_right,
                color: AppColors.dark,
                size: 26,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // 1. Apply Date Filter & Search Query
    final filteredWorkouts =
        _assignedWorkouts.where((item) {
          final itemDate = _extractDateString(item);
          if (itemDate.isNotEmpty && itemDate != selectedStr) return false;

          // Search Query Filtering (by Workout Title or Client Name)
          if (_searchQuery.trim().isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            final title =
                (item['plan_name'] ??
                        item['title'] ??
                        item['name'] ??
                        item['workout_plan_name'] ??
                        '')
                    .toString()
                    .toLowerCase();
            final clientName =
                (item['client_name'] ?? '').toString().toLowerCase();
            return title.contains(q) || clientName.contains(q);
          }

          return true;
        }).toList();

    // 2. Apply Date Sorting
    filteredWorkouts.sort((a, b) {
      final dateA = _extractDateString(a);
      final dateB = _extractDateString(b);
      return _sortNewestFirst ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        leading: const PopButton().center,
        title: Text(
          widget.customerName != null
              ? 'Assigned Workouts (${widget.customerName})'
              : 'Assigned Workouts',
          style: AppStyles.text16Px.poppins.w600.dark,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.dark),
            onPressed: () => _loadAssignedWorkouts(resetPage: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Header with Center Selected Date & Arrows
          _buildDateHeader(),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xffE2E8F0)),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: AppStyles.text14Px.poppins.w500.dark,
                decoration: InputDecoration(
                  hintText: 'Search by workout name or client...',
                  hintStyle: AppStyles.text13Px.poppins.w400.copyWith(
                    color: const Color(0xffA0AEC0),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: Color(0xff718096),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),

          // Main Workouts List
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredWorkouts.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No assigned workouts for ${DateFormat('dd MMM, yyyy').format(_selectedDate)}",
                            style: AppStyles.text14Px.poppins.w500.copyWith(
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          filteredWorkouts.length + (_isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == filteredWorkouts.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          );
                        }
                        final workout = filteredWorkouts[index];
                        final planId =
                            workout['plan_id'] as int? ??
                            workout['customer_workout_plan_id'] as int? ??
                            workout['workout_plan_id'] as int? ??
                            workout['id'] as int? ??
                            0;
                        final title =
                            (workout['plan_name'] ??
                                    workout['title'] ??
                                    workout['name'] ??
                                    workout['workout_plan_name'] ??
                                    'Workout Plan')
                                .toString();
                        final clientName =
                            (workout['client_name'] ?? 'Client').toString();
                        final status =
                            (workout['status'] ??
                                    workout['assignment_status'] ??
                                    'Active')
                                .toString();
                        final assignedDate = _extractDateString(workout);
                        final routinesCount =
                            workout['total_days'] as int? ??
                            workout['days_count'] as int? ??
                            (workout['days'] as List?)?.length ??
                            (workout['routines'] as List?)?.length ??
                            (workout['workout_days'] as List?)?.length ??
                            0;
                        final isActive = status.toLowerCase() == 'active';

                        return InkWell(
                          onTap:
                              planId > 0
                                  ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                WorkoutPlanDetailsScreen(
                                                  planId: planId,
                                                  planTitle: title,
                                                ),
                                      ),
                                    );
                                  }
                                  : null,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xffE2E8F0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  border:
                                      isActive
                                          ? const Border(
                                            left: BorderSide(
                                              color: Color(0xff27AE60),
                                              width: 4,
                                            ),
                                          )
                                          : null,
                                ),
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Top Row: Icon Avatar + Title & Client + Status Badge
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color:
                                                isActive
                                                    ? const Color(0xffFFDCDA)
                                                    : const Color(0xffE2E8F0),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.fitness_center_rounded,
                                            color:
                                                isActive
                                                    ? const Color(0xffC53030)
                                                    : const Color(0xff4A5568),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style:
                                                    AppStyles
                                                        .text15Px
                                                        .poppins
                                                        .w600
                                                        .dark,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.person_outline,
                                                    size: 13,
                                                    color: Color(0xff718096),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      clientName,
                                                      style: AppStyles
                                                          .text12Px
                                                          .poppins
                                                          .w400
                                                          .copyWith(
                                                            color: const Color(
                                                              0xff4A5568,
                                                            ),
                                                          ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isActive
                                                    ? const Color(0xffC6F6D5)
                                                    : const Color(0xffE2E8F0),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            status.toUpperCase(),
                                            style: AppStyles
                                                .text10Px
                                                .poppins
                                                .w700
                                                .copyWith(
                                                  color:
                                                      isActive
                                                          ? const Color(
                                                            0xff22543D,
                                                          )
                                                          : const Color(
                                                            0xff4A5568,
                                                          ),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),
                                    const Divider(
                                      height: 1,
                                      color: Color(0xffEDF2F7),
                                    ),
                                    const SizedBox(height: 10),

                                    // Bottom Row: Routines/Days + Date + Chevron
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              routinesCount > 0
                                                  ? '$routinesCount Workout Routines / Days'
                                                  : 'Workout Plan Details',
                                              style: AppStyles
                                                  .text12Px
                                                  .poppins
                                                  .w500
                                                  .copyWith(
                                                    color: const Color(
                                                      0xff4A5568,
                                                    ),
                                                  ),
                                            ),
                                            if (assignedDate.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                'Assigned: $assignedDate',
                                                style: AppStyles
                                                    .text10Px
                                                    .poppins
                                                    .w500
                                                    .copyWith(
                                                      color: const Color(
                                                        0xff718096,
                                                      ),
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          color: Color(0xff718096),
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
