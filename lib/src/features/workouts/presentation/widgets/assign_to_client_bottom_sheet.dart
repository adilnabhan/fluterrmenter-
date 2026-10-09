import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_reports_screen.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_details_screen.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_group_details_screen.dart';
import 'package:mentor_mobile_app/core/services/holiday/gym_holiday_service.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_client_stats_screen.dart';

class AssignToClientBottomSheet extends StatefulWidget {
  final int planId;
  final String planTitle;
  final bool isMultiDayGroup;

  const AssignToClientBottomSheet({
    required this.planId,
    required this.planTitle,
    this.isMultiDayGroup = false,
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

  /// Clears the in-memory clients cache when needed.
  static void clearCache() {}

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
          if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

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
              return {
                ...map,
                'is_assigned': false,
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
              return {
                ...map,
                'is_assigned': false,
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

  DateTime? _parseAnyDate(String? str) {
    if (str == null || str.isEmpty || str == 'null') return null;
    try {
      final trimmed = str.trim();
      if (trimmed.length >= 10 && trimmed[4] == '-' && trimmed[7] == '-') {
        final parts = trimmed.substring(0, 10).split('-');
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
      return DateTime.parse(trimmed);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _evaluateClientStatus(Map<String, dynamic> client) {
    final List<Map<String, dynamic>> allMemberships = [];

    final rawList = client['memberships'] ?? client['all_memberships'];
    if (rawList is List) {
      for (var item in rawList) {
        if (item is Map) {
          allMemberships.add(Map<String, dynamic>.from(item));
        }
      }
    }

    if (client['membership_details'] is Map) {
      allMemberships.add(
        Map<String, dynamic>.from(client['membership_details'] as Map),
      );
    }

    if (client['active_membership'] is Map) {
      allMemberships.add(
        Map<String, dynamic>.from(client['active_membership'] as Map),
      );
    }

    if (client['customer_membership'] is Map) {
      allMemberships.add(
        Map<String, dynamic>.from(client['customer_membership'] as Map),
      );
    }

    // Direct Boolean Flags
    final bool? isActiveMember =
        client['is_active_member'] as bool? ??
        client['is_membership_active'] as bool?;
    final bool? isUserActive = client['is_active'] as bool?;

    DateTime? latestEndDate;
    String? latestStatus;

    // Check root client fields
    final rootEndStr = (client['membership_end_date'] ??
            client['end_date'] ??
            client['expiry_date'] ??
            client['expire_date'] ??
            client['valid_to'])
        ?.toString();
    final parsedRootEnd = _parseAnyDate(rootEndStr);
    if (parsedRootEnd != null) {
      latestEndDate = parsedRootEnd;
    }

    final rootStatus = (client['membership_status'] ?? client['status'])
        ?.toString()
        .toLowerCase();
    if (rootStatus != null && rootStatus.isNotEmpty && rootStatus != 'null') {
      latestStatus = rootStatus;
    }

    for (var mem in allMemberships) {
      final endStr = (mem['end_date'] ??
              mem['membership_end_date'] ??
              mem['expiry_date'] ??
              mem['expire_date'] ??
              mem['valid_to'])
          ?.toString();
      final parsedEnd = _parseAnyDate(endStr);
      if (parsedEnd != null) {
        if (latestEndDate == null || parsedEnd.isAfter(latestEndDate)) {
          latestEndDate = parsedEnd;
        }
      }
      final status = (mem['status'] ?? mem['membership_status'])
          ?.toString()
          .toLowerCase();
      if (status != null && status.isNotEmpty && status != 'null') {
        latestStatus = status;
      }
    }

    final String resolvedStatus = (client['resolved_status'] ?? client['status'])
        ?.toString()
        .toLowerCase()
        .trim() ?? '';

    // Check frozen / paused / hold
    if (resolvedStatus == 'frozen' ||
        resolvedStatus == 'paused' ||
        resolvedStatus == 'hold' ||
        latestStatus == 'frozen' ||
        latestStatus == 'paused' ||
        latestStatus == 'hold') {
      return {
        'text': 'Frozen',
        'color': const Color(0xff0288D1),
        'bgColor': const Color(0xffE1F5FE),
        'isExpired': false,
      };
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Explicit status expired / inactive / completed or isActiveMember == false
    if (resolvedStatus == 'expired' ||
        latestStatus == 'expired' ||
        latestStatus == 'inactive' ||
        latestStatus == 'completed' ||
        isActiveMember == false ||
        isUserActive == false) {
      return {
        'text': 'Expired',
        'color': const Color(0xffD32F2F),
        'bgColor': const Color(0xffFFEBEE),
        'isExpired': true,
      };
    }

    // End date checking
    if (latestEndDate != null) {
      final endDay = DateTime(
        latestEndDate.year,
        latestEndDate.month,
        latestEndDate.day,
      );
      if (endDay.isBefore(today)) {
        return {
          'text': 'Expired',
          'color': const Color(0xffD32F2F),
          'bgColor': const Color(0xffFFEBEE),
          'isExpired': true,
        };
      }
    }

    if (isActiveMember == true ||
        resolvedStatus == 'active' ||
        latestStatus == 'active') {
      return {
        'text': 'Active',
        'color': const Color(0xff2E7D32),
        'bgColor': const Color(0xffE8F5E9),
        'isExpired': false,
      };
    }

    if (latestEndDate != null) {
      return {
        'text': 'Active',
        'color': const Color(0xff2E7D32),
        'bgColor': const Color(0xffE8F5E9),
        'isExpired': false,
      };
    }

    return {
      'text': 'Active',
      'color': const Color(0xff2E7D32),
      'bgColor': const Color(0xffE8F5E9),
      'isExpired': false,
    };
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
    final client = _clients.firstWhere(
      (c) => c['customer_id'] == customerId || c['id'] == customerId,
      orElse: () => <String, dynamic>{},
    );
    final int? clientOrgId =
        client['organization_id'] as int? ?? client['gym_id'] as int?;

    final titleController = TextEditingController(text: widget.planTitle);
    final notesController = TextEditingController();
    DateTime? selectedDate = widget.isMultiDayGroup ? DateTime.now() : null;
    String? holidayWarning;
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
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isMultiDayGroup)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          widget.planTitle,
                          style: AppStyles.text14Px.poppins.w600.copyWith(
                            color: AppColors.textDark,
                          ),
                        ),
                      )
                    else
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
                    RichText(
                      text: TextSpan(
                        text: 'Start Date ',
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: AppColors.textDark,
                        ),
                        children: [
                          if (widget.isMultiDayGroup)
                            TextSpan(
                              text: '*',
                              style: AppStyles.text12Px.poppins.w600.copyWith(
                                color: AppColors.primary,
                              ),
                            )
                          else
                            TextSpan(
                              text: '(Optional)',
                              style: AppStyles.text12Px.poppins.w400.copyWith(
                                color: AppColors.textGrey,
                              ),
                            ),
                        ],
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
                          final hol = await GymHolidayService.getHolidayName(
                            picked,
                            orgId: clientOrgId,
                          );
                          setStateDialog(() {
                            selectedDate = picked;
                            holidayWarning = hol;
                          });
                          if (hol != null) {
                            Dialogs.showSnack(
                              msg:
                                  'Selected date is a gym holiday ($hol). Workouts cannot be assigned on holidays.',
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                holidayWarning != null
                                    ? const Color(0xffD32F2F)
                                    : Colors.grey.shade400,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                selectedDate != null
                                    ? "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}"
                                    : (widget.isMultiDayGroup
                                        ? 'Select start date'
                                        : 'Select start date (Default: Today)'),
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
                    if (holidayWarning != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xffEF5350).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xffD32F2F),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Cannot assign workout: $holidayWarning is a gym holiday.',
                                style: AppStyles.text12Px.poppins.w500.copyWith(
                                  color: const Color(0xffD32F2F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, 'cancel'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Cancel',
                        style: AppStyles.text14Px.poppins.w500.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(dialogContext, 'customize'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Customize',
                        style: AppStyles.text14Px.poppins.w500.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.isMultiDayGroup && selectedDate == null) {
                          Dialogs.showSnack(
                            msg:
                                'Please select a start date for multi-day workout',
                          );
                          return;
                        }
                        Navigator.pop(dialogContext, 'assign');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    setState(() {
      _submittingMap[customerId] = true;
    });

    try {
      final dio = DioClient().dio;

      if (action == 'customize') {
        int targetPlanId = widget.planId;
        if (widget.isMultiDayGroup) {
          try {
            dynamic groupPlansRes;
            try {
              groupPlansRes = await dio.get<dynamic>(
                ApiUris.multiDayWorkouts,
                queryParameters: {'group': widget.planId},
                options: Options(headers: {'X-Platform': platformSource}),
              );
            } catch (_) {
              groupPlansRes = await dio.get<dynamic>(
                ApiUris.workoutPlans,
                queryParameters: {'group': widget.planId},
                options: Options(headers: {'X-Platform': platformSource}),
              );
            }
            if (groupPlansRes.statusCode == 200) {
              List plansList = [];
              if (groupPlansRes.data is List) {
                plansList = groupPlansRes.data as List;
              } else if (groupPlansRes.data is Map &&
                  groupPlansRes.data['results'] is List) {
                plansList = groupPlansRes.data['results'] as List;
              }
              if (plansList.isNotEmpty) {
                targetPlanId = plansList[0]['id'] as int;
              }
            }
          } catch (_) {}
        }

        dynamic response;
        try {
          if (widget.isMultiDayGroup) {
            try {
              response = await dio.post<dynamic>(
                ApiUris.copyMultiDayWorkout(targetPlanId),
                data: {'is_assignment': true},
                options: Options(headers: {'X-Platform': platformSource}),
              );
            } catch (_) {
              response = await dio.post<dynamic>(
                ApiUris.copyWorkoutPlan(targetPlanId),
                data: {'is_assignment': true},
                options: Options(headers: {'X-Platform': platformSource}),
              );
            }
          } else {
            response = await dio.post<dynamic>(
              ApiUris.copyWorkoutPlan(targetPlanId),
              data: {'is_assignment': true},
              options: Options(headers: {'X-Platform': platformSource}),
            );
          }
        } catch (_) {}

        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          final data = response.data as Map<String, dynamic>;
          final newPlanId = data['id'] as int;
          if (!mounted) return;
          setState(() {
            _submittingMap[customerId] = false;
          });

          if (widget.isMultiDayGroup) {
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder:
                    (context) => WorkoutGroupDetailsScreen(
                      groupId: newPlanId,
                      groupTitle: finalTitle,
                      groupType: 'multi_day',
                      assignToCustomerId: customerId,
                    ),
              ),
            );
          } else {
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
          }
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
      final DateTime startDate = selectedDate ?? DateTime.now();
      final holCheck = await GymHolidayService.getHolidayName(
        startDate,
        orgId: clientOrgId,
      );
      if (holCheck != null) {
        if (!mounted) return;
        setState(() {
          _submittingMap[customerId] = false;
        });
        Dialogs.showSnack(
          msg:
              'Cannot assign workout on a holiday: $holCheck. Please choose another date.',
        );
        return;
      }
      List<Map<String, dynamic>> assignDays = [];
      DateTime calculatedEndDate = startDate.add(const Duration(days: 6));
      int? foundMasterPlanId;

      if (widget.isMultiDayGroup) {
        try {
          dynamic groupPlansRes;
          try {
            groupPlansRes = await dio.get<dynamic>(
              ApiUris.multiDayWorkouts,
              queryParameters: {'group': widget.planId},
              options: Options(headers: {'X-Platform': platformSource}),
            );
          } catch (_) {
            groupPlansRes = await dio.get<dynamic>(
              ApiUris.workoutPlans,
              queryParameters: {'group': widget.planId},
              options: Options(headers: {'X-Platform': platformSource}),
            );
          }

          List<dynamic> plansList = [];
          if (groupPlansRes.statusCode == 200) {
            if (groupPlansRes.data is List) {
              plansList = groupPlansRes.data as List;
            } else if (groupPlansRes.data is Map && groupPlansRes.data['results'] is List) {
              plansList = groupPlansRes.data['results'] as List;
            }
          }

          if (plansList.isNotEmpty) {
            final masterPlanId = plansList[0]['id'] as int;
            foundMasterPlanId = masterPlanId;

            dynamic planDetailRes;
            try {
              planDetailRes = await dio.get<dynamic>(
                ApiUris.multiDayWorkoutDetail(masterPlanId),
                options: Options(headers: {'X-Platform': platformSource}),
              );
            } catch (_) {
              planDetailRes = await dio.get<dynamic>(
                ApiUris.workoutPlanDetail(masterPlanId),
                options: Options(headers: {'X-Platform': platformSource}),
              );
            }

            if (planDetailRes.statusCode == 200 && planDetailRes.data is Map) {
              final rawDays = planDetailRes.data['days'] as List? ?? [];
              if (rawDays.isNotEmpty) {
                assignDays = [];
                for (int i = 0; i < rawDays.length; i++) {
                  final dayMap = Map<String, dynamic>.from(rawDays[i] as Map);
                  final dayDate = startDate.add(Duration(days: i));
                  final String dayDateStr =
                      "${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}";
                  final int pId = (dayMap['child_plan_id'] as int?) ??
                      ((dayMap['child_plan'] is Map)
                          ? (dayMap['child_plan']['id'] as int?)
                          : null) ??
                      (dayMap['plan'] as int?) ??
                      (dayMap['plan_id'] as int?) ??
                      (dayMap['id'] as int);

                  final String dayTitle =
                      (dayMap['effective_title'] as String?) ??
                      (dayMap['child_plan_title'] as String?) ??
                      ((dayMap['child_plan'] is Map)
                          ? ((dayMap['child_plan']['name'] ??
                                  dayMap['child_plan']['title'] ??
                                  dayMap['child_plan']['plan_name'])
                              as String?)
                          : null) ??
                      (dayMap['plan_name'] as String?) ??
                      (dayMap['name'] as String?) ??
                      (dayMap['title'] as String?) ??
                      'Day ${i + 1}';

                  assignDays.add({
                    'date': dayDateStr,
                    'title': dayTitle,
                    'plan_name': dayTitle,
                    'plan_id': pId,
                    'is_rest_day': dayMap['is_rest_day'] ?? false,
                  });
                  calculatedEndDate = dayDate;
                }
              }
            }
          }
        } catch (_) {}
      }

      final String startDateStr =
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      final String endDateStr =
          "${calculatedEndDate.year}-${calculatedEndDate.month.toString().padLeft(2, '0')}-${calculatedEndDate.day.toString().padLeft(2, '0')}";

      dynamic response;
      if (widget.isMultiDayGroup) {
        if (foundMasterPlanId != null) {
          try {
            response = await dio.post<dynamic>(
              ApiUris.assignMultiDayWorkout(foundMasterPlanId),
              data: {
                'customer_id': customerId,
                'title': finalTitle,
                'start_date': startDateStr,
                'end_date': endDateStr,
                if (notesController.text.trim().isNotEmpty)
                  'notes': notesController.text.trim(),
                if (assignDays.isNotEmpty) 'days': assignDays,
              },
              options: Options(headers: {'X-Platform': platformSource}),
            );
          } catch (_) {
            response = await dio.post<dynamic>(
              ApiUris.multiDayAssign,
              data: {
                'customer_id': customerId,
                'group_id': widget.planId,
                'plan_name': finalTitle,
                'plan_type': 'custom_range',
                'start_date': startDateStr,
                'end_date': endDateStr,
                if (notesController.text.trim().isNotEmpty)
                  'notes': notesController.text.trim(),
                'conflict_resolution': 'replace',
                if (assignDays.isNotEmpty) 'days': assignDays,
              },
              options: Options(headers: {'X-Platform': platformSource}),
            );
          }
        } else {
          response = await dio.post<dynamic>(
            ApiUris.multiDayAssign,
            data: {
              'customer_id': customerId,
              'group_id': widget.planId,
              'plan_name': finalTitle,
              'plan_type': 'custom_range',
              'start_date': startDateStr,
              'end_date': endDateStr,
              if (notesController.text.trim().isNotEmpty)
                'notes': notesController.text.trim(),
              'conflict_resolution': 'replace',
              if (assignDays.isNotEmpty) 'days': assignDays,
            },
            options: Options(headers: {'X-Platform': platformSource}),
          );
        }
      } else {
        try {
          response = await dio.post<dynamic>(
            ApiUris.assignSingleDayWorkout(widget.planId),
            data: {
              'customer_id': customerId,
              'title': finalTitle,
              if (notesController.text.trim().isNotEmpty)
                'notes': notesController.text.trim(),
              if (selectedDate != null) 'start_date': startDateStr,
            },
            options: Options(headers: {'X-Platform': platformSource}),
          );
        } catch (_) {
          response = await dio.post<dynamic>(
            ApiUris.assignWorkoutPlan(widget.planId),
            data: {
              'customer_id': customerId,
              'title': finalTitle,
              if (notesController.text.trim().isNotEmpty)
                'notes': notesController.text.trim(),
              if (selectedDate != null) 'start_date': startDateStr,
            },
            options: Options(headers: {'X-Platform': platformSource}),
          );
        }
      }

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
        final errorMsg =
            response.data is Map
                ? (response.data['error'] ??
                        response.data['message'] ??
                        response.data['detail'] ??
                        'Failed to assign plan')
                    .toString()
                : 'Failed to assign plan';
        Dialogs.showSnack(msg: errorMsg);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submittingMap[customerId] = false;
      });
      String errorMsg = 'Failed to assign plan';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          errorMsg =
              (data['error'] ?? data['message'] ?? data['detail'] ?? errorMsg)
                  .toString();
        } else if (data is String && data.isNotEmpty) {
          errorMsg = data;
        }
      } else {
        errorMsg = e.toString();
      }
      Dialogs.showSnack(msg: errorMsg);
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

                        final statusInfo = _evaluateClientStatus(client);
                        final String statusText = statusInfo['text'] as String;
                        final Color statusColor = statusInfo['color'] as Color;
                        final Color statusBgColor = statusInfo['bgColor'] as Color;

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
                              MaterialPageRoute<void>(
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
                                      GestureDetector(
                                        onTap: () {
                                          if (imgUrl != null &&
                                              (imgUrl as String).trim().isNotEmpty) {
                                            Dialogs.showEnlargedProfilePhoto(
                                              context,
                                              (imgUrl as String).trim(),
                                              name: name,
                                            );
                                          } else {
                                            unawaited(Dialogs.showSnack(
                                              msg: 'No profile photo uploaded for $name',
                                            ));
                                          }
                                        },
                                        child: CircleAvatar(
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
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    name,
                                                    style: AppStyles
                                                        .text14Px
                                                        .poppins
                                                        .w600
                                                        .dark,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: statusBgColor,
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    statusText,
                                                    style: AppStyles
                                                        .text10Px
                                                        .poppins
                                                        .w600
                                                        .copyWith(
                                                      color: statusColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              organizationName,
                                              style: AppStyles
                                                  .text12Px
                                                  .poppins
                                                  .w400
                                                  .copyWith(
                                                    color: AppColors.textGrey,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                                          MaterialPageRoute<void>(
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
