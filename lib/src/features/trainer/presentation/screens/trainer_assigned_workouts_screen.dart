import 'package:mentor_mobile_app/imports_bindings.dart';
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

  List<Map<String, dynamic>> _assignedWorkouts = [];
  String _searchQuery = '';

  // Filter & Sort State
  String _dateFilter = 'today'; // 'today', 'all', 'custom'
  DateTime? _customSelectedDate;
  bool _sortNewestFirst = true; // true = newest first, false = oldest first

  @override
  void initState() {
    super.initState();
    _loadAssignedWorkouts();
  }

  Future<void> _loadAssignedWorkouts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    if (widget.customerId != null) {
      final workouts = await _fetchAssignedWorkoutsForClient(
        widget.customerId!,
        widget.customerName ?? 'Client',
      );
      if (mounted) {
        setState(() {
          _assignedWorkouts = workouts;
          _isLoading = false;
        });
      }
      return;
    }

    // Fetch for all clients of the trainer
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
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
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
      final listData = data['assigned_plans'] ??
          data['assigned_workouts'] ??
          data['results'] ??
          data['data'] ??
          data['plans'];
      if (listData is List) {
        list = listData.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    }

    for (final item in list) {
      item['client_name'] = item['client_name'] ??
          item['customer_name'] ??
          item['customer']?['name'] ??
          clientName;
      item['customer_id'] = item['customer_id'] ?? customerId;
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
            onPressed: _loadAssignedWorkouts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips & Sort Controls
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                // Filter Chip: Today
                ChoiceChip(
                  label: Text('Today (${DateFormat('MMM d').format(DateTime.now())})'),
                  selected: _dateFilter == 'today',
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _dateFilter == 'today' ? Colors.white : AppColors.dark,
                    fontWeight: _dateFilter == 'today' ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: _dateFilter == 'today' ? AppColors.primary : const Color(0xffEEEEEE),
                  ),
                  onSelected: (selected) {
                    if (selected && _dateFilter != 'today') {
                      setState(() {
                        _dateFilter = 'today';
                        _customSelectedDate = null;
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),

                // Filter Chip: All Workouts
                ChoiceChip(
                  label: const Text('All Workouts'),
                  selected: _dateFilter == 'all',
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _dateFilter == 'all' ? Colors.white : AppColors.dark,
                    fontWeight: _dateFilter == 'all' ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: _dateFilter == 'all' ? AppColors.primary : const Color(0xffEEEEEE),
                  ),
                  onSelected: (selected) {
                    if (selected && _dateFilter != 'all') {
                      setState(() {
                        _dateFilter = 'all';
                        _customSelectedDate = null;
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),

                // Filter Chip: Select Date
                ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        _customSelectedDate != null
                            ? DateFormat('MMM d').format(_customSelectedDate!)
                            : 'Pick Date',
                      ),
                    ],
                  ),
                  selected: _dateFilter == 'custom',
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _dateFilter == 'custom' ? Colors.white : AppColors.dark,
                    fontWeight: _dateFilter == 'custom' ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: _dateFilter == 'custom' ? AppColors.primary : const Color(0xffEEEEEE),
                  ),
                  onSelected: (selected) async {
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
                    }
                  },
                ),

                const SizedBox(width: 8),

                // Date Sort Toggle Button
                InkWell(
                  onTap: () {
                    setState(() {
                      _sortNewestFirst = !_sortNewestFirst;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xffEEEEEE)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _sortNewestFirst ? Icons.arrow_downward : Icons.arrow_upward,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _sortNewestFirst ? 'Newest' : 'Oldest',
                          style: AppStyles.text12Px.poppins.w600.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by workout name or client...',
                hintStyle: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textGrey),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xffEEEEEE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xffEEEEEE)),
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
                                },
                                child: const Text('View All Workouts', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredWorkouts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
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
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xffEEEEEE)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.fitness_center,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                title,
                                                style: AppStyles.text14Px.poppins.w600.dark,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: status.toLowerCase() == 'active'
                                                    ? Colors.green.withValues(alpha: 0.12)
                                                    : AppColors.primary.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                status.toUpperCase(),
                                                style: AppStyles.text10Px.poppins.w700.copyWith(
                                                  color: status.toLowerCase() == 'active'
                                                      ? Colors.green
                                                      : AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.person_outline, size: 14, color: AppColors.primary),
                                            const SizedBox(width: 4),
                                            Text(
                                              clientName,
                                              style: AppStyles.text12Px.poppins.w500.dark,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          routinesCount > 0
                                              ? '$routinesCount Workout Routines / Days'
                                              : 'Workout Plan Details',
                                          style: AppStyles.text12Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                        ),
                                        if (assignedDate.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'Assigned: $assignedDate',
                                            style: AppStyles.text10Px.poppins.w400.copyWith(color: AppColors.textGrey),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: AppColors.textGrey,
                                    size: 20,
                                  ),
                                ],
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
