import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_reports_screen.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_details_screen.dart';

import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_client_stats_screen.dart';

class AssignToClientBottomSheet extends StatefulWidget {
  final int planId;
  final String planTitle;

  const AssignToClientBottomSheet({
    required this.planId,
    required this.planTitle,
    super.key,
  });

  @override
  State<AssignToClientBottomSheet> createState() =>
      _AssignToClientBottomSheetState();
}

class _AssignToClientBottomSheetState extends State<AssignToClientBottomSheet> {
  List<Map<String, dynamic>> _clients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedGymFilter = 'All';
  final Map<int, bool> _submittingMap = {};

  String? _nextUrl;
  bool _isFetchingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchClients();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _fetchMoreClients();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchClients() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _nextUrl = null;
    });

    try {
      // 1. Fetch clients list
      final clientsResponse = await DioClient().dio.get<dynamic>(
        ApiUris.trainerCustomers,
        queryParameters: {
          'page_size': 10000,
          if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      // 2. Fetch already assigned client IDs for this specific plan
      final assignedResponse = await DioClient().dio.get<dynamic>(
        ApiUris.assignWorkoutPlan(widget.planId),
        options: Options(headers: {'X-Platform': platformSource}),
      );

      final Set<int> assignedCustomerIds = {};
      if (assignedResponse.statusCode == 200 && assignedResponse.data is List) {
        final List<dynamic> assignedList =
            assignedResponse.data as List<dynamic>;
        final now = DateTime.now();
        for (var item in assignedList) {
          final map = Map<String, dynamic>.from(item as Map);
          if (map['is_assigned'] == true) {
            bool isRecent = true;
            final dateStr =
                map['assigned_at'] ??
                map['created_at'] ??
                map['date'] ??
                map['updated_at'];
            if (dateStr != null && dateStr is String && dateStr.isNotEmpty) {
              final parsedDate = DateTime.tryParse(dateStr);
              if (parsedDate != null) {
                if (now.difference(parsedDate).inHours >= 12) {
                  isRecent = false;
                }
              }
            }
            if (isRecent) {
              assignedCustomerIds.add(map['customer_id'] as int);
            }
          }
        }
      }

      if (clientsResponse.statusCode == 200) {
        final data = clientsResponse.data;
        List<dynamic> results = [];
        if (data is Map) {
          results = List<dynamic>.from(data['results'] as List? ?? []);
          _nextUrl = data['next']?.toString();
        } else if (data is List) {
          results = data;
          _nextUrl = null;
        }

        final parsedClients =
            results.map((e) {
              final map = Map<String, dynamic>.from(e as Map);
              final customerId = map['customer_id'] as int;
              return {
                ...map,
                'is_assigned': assignedCustomerIds.contains(customerId),
              };
            }).toList();

        if (!mounted) return;
        setState(() {
          _clients = parsedClients;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load clients');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading clients: ${e.toString()}');
    }
  }

  Future<void> _fetchMoreClients() async {
    if (_isFetchingMore || _nextUrl == null || !mounted) return;

    setState(() {
      _isFetchingMore = true;
    });

    try {
      final clientsResponse = await DioClient().dio.get<dynamic>(
        _nextUrl!,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      final assignedResponse = await DioClient().dio.get<dynamic>(
        ApiUris.assignWorkoutPlan(widget.planId),
        options: Options(headers: {'X-Platform': platformSource}),
      );

      final Set<int> assignedCustomerIds = {};
      if (assignedResponse.statusCode == 200 && assignedResponse.data is List) {
        final List<dynamic> assignedList =
            assignedResponse.data as List<dynamic>;
        final now = DateTime.now();
        for (var item in assignedList) {
          final map = Map<String, dynamic>.from(item as Map);
          if (map['is_assigned'] == true) {
            bool isRecent = true;
            final dateStr =
                map['assigned_at'] ??
                map['created_at'] ??
                map['date'] ??
                map['updated_at'];
            if (dateStr != null && dateStr is String && dateStr.isNotEmpty) {
              final parsedDate = DateTime.tryParse(dateStr);
              if (parsedDate != null) {
                if (now.difference(parsedDate).inHours >= 12) {
                  isRecent = false;
                }
              }
            }
            if (isRecent) {
              assignedCustomerIds.add(map['customer_id'] as int);
            }
          }
        }
      }

      if (clientsResponse.statusCode == 200) {
        final data = clientsResponse.data;
        List<dynamic> results = [];
        if (data is Map) {
          results = List<dynamic>.from(data['results'] as List? ?? []);
          _nextUrl = data['next']?.toString();
        } else if (data is List) {
          results = data;
          _nextUrl = null;
        }

        final parsedClients =
            results.map((e) {
              final map = Map<String, dynamic>.from(e as Map);
              final customerId = map['customer_id'] as int;
              return {
                ...map,
                'is_assigned': assignedCustomerIds.contains(customerId),
              };
            }).toList();

        if (!mounted) return;
        setState(() {
          _clients.addAll(parsedClients);
          _isFetchingMore = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetchingMore = false;
      });
    }
  }

  List<String> get _gymFilters {
    final Set<String> gyms = {'All'};
    for (var client in _clients) {
      final orgName = client['organization_name'] as String?;
      if (orgName != null && orgName.isNotEmpty) {
        gyms.add(orgName);
      }
    }
    return gyms.toList();
  }

  List<Map<String, dynamic>> get _filteredClients {
    return _clients.where((client) {
      final name = (client['name'] as String? ?? '').toLowerCase();
      if (_searchQuery.trim().isNotEmpty &&
          !name.contains(_searchQuery.trim().toLowerCase())) {
        return false;
      }
      final orgName = client['organization_name'] ?? 'Direct Client';
      if (_selectedGymFilter != 'All' && orgName != _selectedGymFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _assignPlan(
    int customerId,
    String customerName,
    bool isAssignedToMe,
  ) async {
    final titleController = TextEditingController(text: widget.planTitle);
    final notesController = TextEditingController();
    DateTime? selectedDate;
    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Assign Workout',
                style: AppStyles.text16Px.poppins.w600,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter workout title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      hintText: 'Trainer notes (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Start Date (Optional)',
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedDate != null
                                  ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
                                  : 'Select start date (Default: Today)',
                              style: AppStyles.text14Px.poppins.w400.copyWith(
                                color:
                                    selectedDate != null
                                        ? AppColors.textDark
                                        : Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, 'cancel'),
                  child: Text(
                    'Cancel',
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, 'customize'),
                  child: Text(
                    'Customize',
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, 'assign'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Assign',
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (action == null || action == 'cancel') return;

    final enteredTitle = titleController.text.trim();
    final String finalTitle =
        enteredTitle.isNotEmpty ? enteredTitle : widget.planTitle;

    if (!mounted) return;
    // ignore: use_build_context_synchronously
    final trainerId = context.read<AppCubit>().state.currentUser?.mentor?.id;
    if (trainerId == null) {
      Dialogs.showSnack(msg: 'Trainer profile not found.');
      return;
    }

    if (!mounted) return;
    setState(() {
      _submittingMap[customerId] = true;
    });

    try {
      final dio = DioClient().dio;

      if (action == 'customize') {
        final response = await dio.post<dynamic>(
          ApiUris.copyWorkoutPlan(widget.planId),
          data: {'is_assignment': true},
          options: Options(headers: {'X-Platform': platformSource}),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data as Map<String, dynamic>;
          final newPlanId = data['id'] as int;
          if (!mounted) return;
          setState(() {
            _submittingMap[customerId] = false;
          });
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder:
                  (context) => WorkoutPlanDetailsScreen(
                    planId: newPlanId,
                    planTitle: finalTitle,
                    assignToCustomerId: customerId,
                  ),
            ),
          );
          return;
        } else {
          Dialogs.showSnack(msg: 'Failed to copy plan');
        }
        if (!mounted) return;
        setState(() {
          _submittingMap[customerId] = false;
        });
        return;
      }

      // 2. Assign workout plan
      final response = await dio.post<dynamic>(
        ApiUris.assignWorkoutPlan(widget.planId),
        data: {
          'customer_id': customerId,
          'title': finalTitle,
          if (notesController.text.trim().isNotEmpty)
            'notes': notesController.text.trim(),
          if (selectedDate != null)
            'start_date':
                "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (!mounted) return;
      setState(() {
        _submittingMap[customerId] = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        reportsRefreshTrigger.value++;
        Dialogs.showSnack(msg: 'Plan assigned successfully to $customerName');
        if (!mounted) return;
        setState(() {
          final idx = _clients.indexWhere(
            (c) => c['customer_id'] == customerId,
          );
          if (idx != -1) {
            _clients[idx]['is_assigned'] = true;
          }
        });
      } else {
        Dialogs.showSnack(msg: 'Failed to assign plan');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submittingMap[customerId] = false;
      });
      Dialogs.showSnack(msg: 'Error assigning plan: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredClients;
    final gyms = _gymFilters;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assign Workout',
                style: AppStyles.text18Px.poppins.w600.dark,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search Bar
          TextField(
            onChanged: (val) {
              if (!mounted) return;
              setState(() {
                _searchQuery = val;
              });
              EasyDebounce.debounce(
                'assign-clients-search',
                const Duration(milliseconds: 400),
                () => _fetchClients(),
              );
            },
            decoration: InputDecoration(
              hintText: "Search by client's name",
              hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                color: AppColors.textGrey,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textGrey,
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Gym select chips
          if (gyms.length > 1)
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    gyms.map((gymName) {
                      final isSelected = _selectedGymFilter == gymName;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            if (!mounted) return;
                            setState(() {
                              _selectedGymFilter = gymName;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                gymName,
                                style: AppStyles.text12Px.poppins.w600.copyWith(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : AppColors.textDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                    ? Center(
                      child: Text(
                        'No clients found',
                        style: AppStyles.text14Px.poppins.w400.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    )
                    : ListView.separated(
                      controller: _scrollController,
                      itemCount: filtered.length + (_isFetchingMore ? 1 : 0),
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == filtered.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final client = filtered[index];
                        final int customerId = client['customer_id'] as int;
                        final String name =
                            client['name'] as String? ?? 'Client';
                        final String organizationName =
                            client['organization_name'] as String? ??
                            'Direct Client';
                        final bool isAssigned =
                            client['is_assigned'] as bool? ?? false;
                        final bool isAssignedToMe =
                            client['is_assigned_to_me'] as bool? ?? false;
                        final bool isSubmitting =
                            _submittingMap[customerId] ?? false;
                        final imgUrl = client['profile_picture'];

                        final String? todayWorkoutName =
                            client['today_workout_name'] as String?;
                        final String? previousWorkoutName =
                            client['previous_workout_name'] as String?;
                        final String? previousWorkoutTime =
                            client['previous_workout_time'] as String?;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => TrainerClientStatsScreen(
                                      customerId: customerId,
                                      showAppBar: false,
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderGrey),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.iconBackground,
                                      backgroundImage:
                                          imgUrl != null
                                              ? NetworkImage(imgUrl as String)
                                              : null,
                                      child:
                                          imgUrl == null
                                              ? const Icon(
                                                Icons.person,
                                                color: AppColors.primary,
                                              )
                                              : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style:
                                                AppStyles
                                                    .text14Px
                                                    .poppins
                                                    .w600
                                                    .dark,
                                          ),
                                          Text(
                                            organizationName,
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
                                    const SizedBox(width: 8),
                                    isSubmitting
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : isAssigned
                                        ? InkWell(
                                          onTap:
                                              () => _assignPlan(
                                                customerId,
                                                name,
                                                isAssignedToMe,
                                              ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: const Color(0xFFE57373),
                                              ),
                                            ),
                                            child: Text(
                                              'Assigned',
                                              style: AppStyles
                                                  .text12Px
                                                  .poppins
                                                  .w600
                                                  .copyWith(
                                                    color: const Color(
                                                      0xFFD32F2F,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        )
                                        : ElevatedButton(
                                          onPressed:
                                              () => _assignPlan(
                                                customerId,
                                                name,
                                                isAssignedToMe,
                                              ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFD30000,
                                            ), // Match the red from screenshot
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            elevation: 0,
                                          ),
                                          child: Text(
                                            'Assign',
                                            style:
                                                AppStyles.text12Px.poppins.w600,
                                          ),
                                        ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                RichText(
                                  text: TextSpan(
                                    text: 'Today: ',
                                    style: AppStyles.text12Px.poppins.w400
                                        .copyWith(color: AppColors.textGrey),
                                    children: [
                                      TextSpan(
                                        text:
                                            todayWorkoutName ?? 'not assigned',
                                        style:
                                            AppStyles
                                                .text12Px
                                                .poppins
                                                .w600
                                                .dark,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'Previous: ',
                                          style: AppStyles.text12Px.poppins.w400
                                              .copyWith(
                                                color: AppColors.textGrey,
                                              ),
                                          children: [
                                            if (previousWorkoutName !=
                                                null) ...[
                                              TextSpan(
                                                text: previousWorkoutName,
                                                style:
                                                    AppStyles
                                                        .text12Px
                                                        .poppins
                                                        .w600
                                                        .dark,
                                              ),
                                              if (previousWorkoutTime != null)
                                                TextSpan(
                                                  text:
                                                      ' ($previousWorkoutTime)',
                                                  style: AppStyles
                                                      .text12Px
                                                      .poppins
                                                      .w400
                                                      .copyWith(
                                                        color:
                                                            AppColors.textGrey,
                                                      ),
                                                ),
                                            ] else
                                              TextSpan(
                                                text: 'no history',
                                                style:
                                                    AppStyles
                                                        .text12Px
                                                        .poppins
                                                        .w600
                                                        .dark,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => TrainerClientStatsScreen(
                                                  customerId: customerId,
                                                  showAppBar: false,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF1F1F1),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(
                                          Icons.history,
                                          size: 16,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                  ],
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
