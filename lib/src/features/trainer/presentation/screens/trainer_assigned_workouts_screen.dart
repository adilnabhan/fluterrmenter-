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
  String _dateFilter = 'today'; // 'today', 'all', 'custom'
  DateTime? _customSelectedDate;
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

  Future<void> _loadMoreAssignedWorkouts() async {
    if (!mounted || _isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await _loadAssignedWorkouts(resetPage: false, fetchAll: true);
  }

  Future<void> _loadAssignedWorkouts({
    bool resetPage = true,
    bool forceRefresh = false,
    bool fetchAll = false,
  }) async {
    if (!mounted) return;

    // If all workouts are already in memory and user is just toggling tabs, switch instantly without reloading
    if (!forceRefresh && _hasFetchedAll && resetPage) {
      return;
    }

    if (resetPage) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _hasMore = true;
        if (forceRefresh) {
          _assignedWorkouts = [];
          _hasFetchedAll = false;
        }
      });
    }

    if (widget.customerId != null) {
      final workouts = await _fetchAssignedWorkoutsForClient(
        widget.customerId!,
        widget.customerName ?? 'Client',
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

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final Map<String, dynamic> queryParams = {
      'page': _currentPage,
      'page_size': _pageSize,
    };

    if (fetchAll || _dateFilter == 'all') {
      queryParams['status'] = 'all';
    } else if (_dateFilter == 'today') {
      queryParams['date'] = todayStr;
      queryParams['status'] = 'active';
    } else if (_dateFilter == 'custom' && _customSelectedDate != null) {
      queryParams['date'] = DateFormat('yyyy-MM-dd').format(_customSelectedDate!);
    } else {
      queryParams['status'] = 'all';
    }

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
            if (fetchAll || _dateFilter == 'all') {
              _hasFetchedAll = true;
            }
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
          } else if (clientsRes.data is Map && clientsRes.data['results'] is List) {
            dataList = clientsRes.data['results'] as List;
          }

          final clients =
              dataList.map((e) => Map<String, dynamic>.from(e as Map)).toList();

          final List<Future<List<Map<String, dynamic>>>> futures = [];
          for (final client in clients) {
            final profile = client['profile'] as Map? ?? client;
            final cid = client['id'] as int? ?? client['customer_id'] as int?;
            final cname = profile['name']?.toString() ??
                profile['first_name']?.toString() ??
                'Client';
            if (cid != null) {
              futures.add(_fetchAssignedWorkoutsForClient(cid, cname));
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
      final listData = data['results'] ??
          data['assigned_plans'] ??
          data['assigned_workouts'] ??
          data['plans'] ??
          data['data'];
      if (listData is List) {
        list = listData.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    }

    for (final item in list) {
      item['client_name'] = item['client_name'] ??
          item['customer_name'] ??
          item['customer']?['name'] ??
          item['client']?['name'] ??
          (clientName != 'Client' ? clientName : null) ??
          'Client';
      item['customer_id'] = item['customer_id'] ??
          item['client_id'] ??
          (customerId > 0 ? customerId : null);
    }

    return list;
  }

  Future<List<Map<String, dynamic>>> _fetchAssignedWorkoutsForClient(
    int customerId,
    String clientName,
  ) async {
    List<Map<String, dynamic>> workoutsList = [];
    bool fetched = false;

    // 1. Primary Endpoint
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerClientAssignedWorkouts(customerId),
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200) {
        workoutsList = _parseWorkoutsResponse(response.data, clientName, customerId);
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
          workoutsList = _parseWorkoutsResponse(response.data, clientName, customerId);
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
          workoutsList = _parseWorkoutsResponse(response.data, clientName, customerId);
          if (workoutsList.isNotEmpty) fetched = true;
        }
      } catch (_) {}
    }

    return workoutsList;
  }

  String _extractDateString(Map<String, dynamic> item) {
    final raw = (item['start_date'] ??
            item['created_at'] ??
            item['assigned_date'] ??
            item['session_date'] ??
            '')
        .toString();
    if (raw.length >= 10) {
      return raw.substring(0, 10);
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 1. Apply Date Filter & Search Query
    final filteredWorkouts = _assignedWorkouts.where((item) {
      // Date Filtering (Instant local filtering)
      final itemDate = _extractDateString(item);
      if (_dateFilter == 'today') {
        if (itemDate.isNotEmpty && itemDate != todayStr) return false;
      } else if (_dateFilter == 'custom' && _customSelectedDate != null) {
        final selectedStr = DateFormat('yyyy-MM-dd').format(_customSelectedDate!);
        if (itemDate.isNotEmpty && itemDate != selectedStr) return false;
      }

      // Search Query Filtering (by Workout Title or Client Name)
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final title = (item['plan_name'] ??
                item['title'] ??
                item['name'] ??
                item['workout_plan_name'] ??
                '')
            .toString()
            .toLowerCase();
        final clientName = (item['client_name'] ?? '').toString().toLowerCase();
        return title.contains(q) || clientName.contains(q);
      }

      return true;
    }).toList();

    // 2. Apply Date Sorting
    filteredWorkouts.sort((a, b) {
      final dateA = _extractDateString(a);
      final dateB = _extractDateString(b);
      return _sortNewestFirst
          ? dateB.compareTo(dateA)
          : dateA.compareTo(dateB);
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
          // Filter Segment Bar & Calendar Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xffE2E8F0).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Today Filter
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (_dateFilter != 'today') {
                                setState(() {
                                  _dateFilter = 'today';
                                  _customSelectedDate = null;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _dateFilter == 'today' ? const Color(0xffE53E3E) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_dateFilter == 'today') ...[
                                    const Icon(Icons.check, size: 16, color: Colors.white),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    'Today',
                                    style: AppStyles.text13Px.poppins.w600.copyWith(
                                      color: _dateFilter == 'today' ? Colors.white : const Color(0xff4A5568),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // All Workouts Filter
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (_dateFilter != 'all') {
                                setState(() {
                                  _dateFilter = 'all';
                                  _customSelectedDate = null;
                                });
                                if (!_hasFetchedAll) {
                                  _loadAssignedWorkouts(resetPage: true, fetchAll: true);
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _dateFilter == 'all' ? const Color(0xffE53E3E) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_dateFilter == 'all') ...[
                                    const Icon(Icons.check, size: 16, color: Colors.white),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    'All Workouts',
                                    style: AppStyles.text13Px.poppins.w600.copyWith(
                                      color: _dateFilter == 'all' ? Colors.white : const Color(0xff4A5568),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Calendar Picker Box
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _customSelectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        _customSelectedDate = picked;
                        _dateFilter = 'custom';
                      });
                      if (!_hasFetchedAll) {
                        _loadAssignedWorkouts(resetPage: true);
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _dateFilter == 'custom' ? const Color(0xffE53E3E) : const Color(0xffE2E8F0),
                        width: _dateFilter == 'custom' ? 1.5 : 1,
                      ),
                    ),
                    child: Icon(
                      Icons.calendar_month_outlined,
                      size: 22,
                      color: _dateFilter == 'custom' ? const Color(0xffE53E3E) : const Color(0xff2D3748),
                    ),
                  ),
                ),
              ],
            ),
          ),

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
                  hintStyle: AppStyles.text13Px.poppins.w400.copyWith(color: const Color(0xffA0AEC0)),
                  prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xff718096)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),

          // Main Workouts List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredWorkouts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fitness_center_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              _dateFilter == 'today'
                                  ? "No assigned workouts for Today"
                                  : "No assigned workouts found",
                              style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.textGrey),
                            ),
                            if (_dateFilter == 'today') ...[
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() => _dateFilter = 'all');
                                  if (!_hasFetchedAll) {
                                    _loadAssignedWorkouts(resetPage: true, fetchAll: true);
                                  }
                                },
                                child: const Text('View All Workouts', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredWorkouts.length + (_isLoadingMore ? 1 : 0),
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
                          final planId = workout['plan_id'] as int? ??
                              workout['customer_workout_plan_id'] as int? ??
                              workout['workout_plan_id'] as int? ??
                              workout['id'] as int? ??
                              0;
                          final title = (workout['plan_name'] ??
                                  workout['title'] ??
                                  workout['name'] ??
                                  workout['workout_plan_name'] ??
                                  'Workout Plan')
                              .toString();
                          final clientName = (workout['client_name'] ?? 'Client').toString();
                          final status = (workout['status'] ??
                                  workout['assignment_status'] ??
                                  'Active')
                              .toString();
                          final assignedDate = _extractDateString(workout);
                          final routinesCount = workout['total_days'] as int? ??
                              workout['days_count'] as int? ??
                              (workout['days'] as List?)?.length ??
                              (workout['routines'] as List?)?.length ??
                              (workout['workout_days'] as List?)?.length ??
                              0;
                          final isActive = status.toLowerCase() == 'active';

                          return InkWell(
                            onTap: planId > 0
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WorkoutPlanDetailsScreen(
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
                                border: Border.all(color: const Color(0xffE2E8F0)),
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
                                    border: isActive
                                        ? const Border(
                                            left: BorderSide(color: Color(0xff27AE60), width: 4),
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
                                              color: isActive
                                                  ? const Color(0xffFFDCDA)
                                                  : const Color(0xffE2E8F0),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.fitness_center_rounded,
                                              color: isActive ? const Color(0xffC53030) : const Color(0xff4A5568),
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  title,
                                                  style: AppStyles.text15Px.poppins.w600.dark,
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
                                                        style: AppStyles.text12Px.poppins.w400.copyWith(
                                                          color: const Color(0xff4A5568),
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
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
                                              color: isActive
                                                  ? const Color(0xffC6F6D5)
                                                  : const Color(0xffE2E8F0),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              status.toUpperCase(),
                                              style: AppStyles.text10Px.poppins.w700.copyWith(
                                                color: isActive
                                                    ? const Color(0xff22543D)
                                                    : const Color(0xff4A5568),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 10),
                                      const Divider(height: 1, color: Color(0xffEDF2F7)),
                                      const SizedBox(height: 10),

                                      // Bottom Row: Routines/Days + Date + Chevron
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                routinesCount > 0
                                                    ? '$routinesCount Workout Routines / Days'
                                                    : 'Workout Plan Details',
                                                style: AppStyles.text12Px.poppins.w500.copyWith(
                                                  color: const Color(0xff4A5568),
                                                ),
                                              ),
                                              if (assignedDate.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Assigned: $assignedDate',
                                                  style: AppStyles.text10Px.poppins.w500.copyWith(
                                                    color: const Color(0xff718096),
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
