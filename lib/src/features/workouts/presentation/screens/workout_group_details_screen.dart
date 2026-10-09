import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/widgets/create_group_button.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_details_screen.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/assign_workout_plan_screen.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/widgets/assign_to_client_bottom_sheet.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:intl/intl.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/multi_day_plan_reorder_screen.dart';
import 'package:mentor_mobile_app/core/services/holiday/gym_holiday_service.dart';

class WorkoutGroupDetailsScreen extends StatefulWidget {
  const WorkoutGroupDetailsScreen({
    required this.groupId,
    required this.groupTitle,
    this.source,
    this.groupType,
    this.assignToCustomerId,
    super.key,
  });

  final int groupId;
  final String groupTitle;
  final String? source;
  final String? groupType;
  final int? assignToCustomerId;

  @override
  State<WorkoutGroupDetailsScreen> createState() =>
      _WorkoutGroupDetailsScreenState();
}

class _WorkoutGroupDetailsScreenState extends State<WorkoutGroupDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final FieldData<dynamic> _planName;

  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int? _masterPlanId;
  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
    _planName = FieldData(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Plan Name',
      requiredLabel: true,
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'Plan name is required';
        }
        return null;
      },
      controller: TextEditingController(),
      focusNode: FocusNode(),
      decoration: const InputDecoration(
        hintText: 'Enter plan name',
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _planName.controller?.dispose();
    _planName.focusNode?.dispose();
    super.dispose();
  }

  Future<void> _fetchPlans({bool silent = false}) async {
    if (!mounted) return;
    if (!silent) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final dio = DioClient().dio;
      dynamic response;

      // Always query workoutPlans by group first to fetch plans belonging to this group
      try {
        response = await dio.get<dynamic>(
          ApiUris.workoutPlans,
          queryParameters: {
            'group': widget.groupId,
            if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
          },
          options: Options(headers: {'X-Platform': platformSource}),
        );
      } catch (_) {
        response = null;
      }

      List<dynamic> data = [];
      if (response != null && response.statusCode == 200) {
        if (response.data is List) {
          data = response.data as List<dynamic>;
        } else if (response.data is Map && response.data['results'] is List) {
          data = response.data['results'] as List<dynamic>;
        }
      }

      // If workoutPlans returned empty, query dedicated multi-day or single-day endpoints
      if (data.isEmpty) {
        try {
          final dedicatedUrl =
              widget.groupType == 'multi_day'
                  ? ApiUris.multiDayWorkouts
                  : ApiUris.singleDayWorkouts;
          final fallbackRes = await dio.get<dynamic>(
            dedicatedUrl,
            queryParameters: {
              'group': widget.groupId,
              if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
            },
            options: Options(headers: {'X-Platform': platformSource}),
          );
          if (fallbackRes.statusCode == 200) {
            if (fallbackRes.data is List &&
                (fallbackRes.data as List).isNotEmpty) {
              data = fallbackRes.data as List<dynamic>;
            } else if (fallbackRes.data is Map &&
                fallbackRes.data['results'] is List &&
                (fallbackRes.data['results'] as List).isNotEmpty) {
              data = fallbackRes.data['results'] as List<dynamic>;
            }
          }
        } catch (_) {}
      }

      // If data is still empty (e.g. cloned ad-hoc workout plan where group is null), query direct detail by ID:
      if (data.isEmpty) {
        try {
          dynamic directRes;
          try {
            directRes = await dio.get<dynamic>(
              ApiUris.multiDayWorkoutDetail(widget.groupId),
              options: Options(headers: {'X-Platform': platformSource}),
            );
          } catch (_) {
            directRes = await dio.get<dynamic>(
              ApiUris.workoutPlanDetail(widget.groupId),
              options: Options(headers: {'X-Platform': platformSource}),
            );
          }
          if (directRes != null && directRes.statusCode == 200 && directRes.data is Map) {
            final Map<String, dynamic> directMap =
                Map<String, dynamic>.from(directRes.data as Map);
            data = [directMap];
          }
        } catch (_) {}
      }

      if (data.isNotEmpty || response?.statusCode == 200) {
        final fetchedPlans =
            data.map((e) => Map<String, dynamic>.from(e as Map)).toList();

        if (widget.groupType == 'multi_day' && fetchedPlans.isNotEmpty) {
          final int masterPlanId = fetchedPlans[0]['id'] as int;
          _masterPlanId = masterPlanId;
          try {
            dynamic detailResponse;
            try {
              detailResponse = await dio.get<dynamic>(
                ApiUris.multiDayWorkoutDetail(masterPlanId),
                options: Options(headers: {'X-Platform': platformSource}),
              );
            } catch (_) {
              detailResponse = await dio.get<dynamic>(
                ApiUris.workoutPlanDetail(masterPlanId),
                options: Options(headers: {'X-Platform': platformSource}),
              );
            }

            if (detailResponse.statusCode == 200 &&
                detailResponse.data is Map) {
              final Map<String, dynamic> planDetail = Map<String, dynamic>.from(
                detailResponse.data as Map,
              );
              final List<dynamic> rawDays =
                  planDetail['days'] as List<dynamic>? ?? [];

              final parsedDaysAsPlans =
                  rawDays.map((d) {
                    final Map<String, dynamic> dayMap =
                        Map<String, dynamic>.from(d as Map);
                    final List<dynamic> exercises =
                        dayMap['exercises'] as List<dynamic>? ?? [];
                    int exCount = 0;
                    if (dayMap['exercise_count'] != null) {
                      exCount =
                          int.tryParse(dayMap['exercise_count'].toString()) ??
                          0;
                    } else if (dayMap['total_exercises'] != null) {
                      exCount =
                          int.tryParse(dayMap['total_exercises'].toString()) ??
                          0;
                    } else if (dayMap['child_plan_exercise_count'] != null) {
                      exCount =
                          int.tryParse(
                            dayMap['child_plan_exercise_count'].toString(),
                          ) ??
                          0;
                    } else if (dayMap['child_plan'] is Map) {
                      final cp = dayMap['child_plan'] as Map;
                      if (cp['exercise_count'] != null) {
                        exCount =
                            int.tryParse(cp['exercise_count'].toString()) ?? 0;
                      } else if (cp['total_exercises'] != null) {
                        exCount =
                            int.tryParse(cp['total_exercises'].toString()) ?? 0;
                      } else if (cp['exercises'] is List) {
                        exCount = (cp['exercises'] as List).length;
                      }
                    } else {
                      exCount = exercises.length;
                    }

                    int targetPlanId = 0;
                    if (dayMap['child_plan_id'] != null) {
                      targetPlanId =
                          int.tryParse(dayMap['child_plan_id'].toString()) ?? 0;
                    } else if (dayMap['child_plan'] is Map &&
                        dayMap['child_plan']['id'] != null) {
                      targetPlanId =
                          int.tryParse(dayMap['child_plan']['id'].toString()) ??
                          0;
                    } else if (dayMap['child_plan'] is int) {
                      targetPlanId = dayMap['child_plan'] as int;
                    } else if (dayMap['plan_id'] != null) {
                      targetPlanId =
                          int.tryParse(dayMap['plan_id'].toString()) ?? 0;
                    } else if (dayMap['plan'] != null) {
                      targetPlanId =
                          int.tryParse(dayMap['plan'].toString()) ?? 0;
                    } else if (dayMap['id'] != null) {
                      targetPlanId = int.tryParse(dayMap['id'].toString()) ?? 0;
                    }

                    final String resolvedTitle =
                        (dayMap['effective_title'] as String?) ??
                        (dayMap['child_plan_title'] as String?) ??
                        ((dayMap['child_plan'] is Map)
                            ? ((dayMap['child_plan']['name'] ??
                                    dayMap['child_plan']['title'] ??
                                    dayMap['child_plan']['plan_name'])
                                as String?)
                            : null) ??
                        (dayMap['title'] as String?) ??
                        (dayMap['plan_name'] as String?) ??
                        (dayMap['name'] as String?) ??
                        'Day Routine';

                    int dayNum = 1;
                    if (dayMap['day_number'] != null) {
                      dayNum =
                          int.tryParse(dayMap['day_number'].toString()) ?? 1;
                    } else if (dayMap['day'] != null) {
                      dayNum = int.tryParse(dayMap['day'].toString()) ?? 1;
                    } else if (dayMap['order'] != null) {
                      dayNum = int.tryParse(dayMap['order'].toString()) ?? 1;
                    }

                    int? planDayId;
                    if (dayMap['plan_day_id'] != null) {
                      planDayId =
                          int.tryParse(dayMap['plan_day_id'].toString());
                    } else if (dayMap['day_id'] != null) {
                      planDayId =
                          int.tryParse(dayMap['day_id'].toString());
                    } else if (dayMap['id'] != null) {
                      planDayId = int.tryParse(dayMap['id'].toString());
                    }

                    return <String, dynamic>{
                      'id': targetPlanId != 0 ? targetPlanId : planDetail['id'],
                      'plan_day_id': planDayId,
                      'plan_name': resolvedTitle,
                      'title': resolvedTitle,
                      'day_number': dayNum,
                      'exercise_count': exCount,
                      'created_at':
                          dayMap['created_at'] ?? planDetail['created_at'],
                      'source': planDetail['source'] ?? widget.source,
                      'is_preset': planDetail['is_preset'] ?? false,
                    };
                  }).toList();

              // Strictly sort days in ascending order (Day 1, Day 2, Day 3, ...)
              parsedDaysAsPlans.sort((a, b) {
                final int aDay =
                    (a['day_number'] is int)
                        ? a['day_number'] as int
                        : int.tryParse(a['day_number']?.toString() ?? '') ?? 0;
                final int bDay =
                    (b['day_number'] is int)
                        ? b['day_number'] as int
                        : int.tryParse(b['day_number']?.toString() ?? '') ?? 0;
                return aDay.compareTo(bDay);
              });

              // Dynamically fetch exercise counts for any child plans showing 0 exercises
              await Future.wait(
                parsedDaysAsPlans.map((p) async {
                  final int pId = (p['id'] as int?) ?? 0;
                  if ((p['exercise_count'] as int? ?? 0) == 0 &&
                      pId != 0 &&
                      pId != masterPlanId) {
                    try {
                      dynamic childRes;
                      try {
                        childRes = await dio.get<dynamic>(
                          ApiUris.singleDayWorkoutDetail(pId),
                          options: Options(
                            headers: {'X-Platform': platformSource},
                          ),
                        );
                      } catch (_) {
                        childRes = await dio.get<dynamic>(
                          ApiUris.workoutPlanDetail(pId),
                          options: Options(
                            headers: {'X-Platform': platformSource},
                          ),
                        );
                      }
                      if (childRes != null &&
                          childRes.statusCode == 200 &&
                          childRes.data is Map) {
                        final cData = childRes.data as Map;
                        final cDays = cData['days'] as List<dynamic>? ?? [];
                        int cCount = 0;
                        if (cData['exercise_count'] != null) {
                          cCount =
                              int.tryParse(
                                cData['exercise_count'].toString(),
                              ) ??
                              0;
                        } else if (cData['total_exercises'] != null) {
                          cCount =
                              int.tryParse(
                                cData['total_exercises'].toString(),
                              ) ??
                              0;
                        } else if (cDays.isNotEmpty &&
                            cDays[0] is Map &&
                            cDays[0]['exercises'] is List) {
                          cCount = (cDays[0]['exercises'] as List).length;
                        }
                        p['exercise_count'] = cCount;
                      }
                    } catch (_) {}
                  }
                }),
              );

              if (!mounted) return;
              setState(() {
                _plans = parsedDaysAsPlans;
                _isLoading = false;
              });
              return;
            }
          } catch (_) {}
        }

        if (!mounted) return;
        setState(() {
          _plans = fetchedPlans;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load workout plans');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading plans: ${e.toString()}');
    }
  }

  Future<void> _saveReorderedDays() async {
    if (widget.groupType != 'multi_day' || _masterPlanId == null) return;
    try {
      final dio = DioClient().dio;
      final int containerId = _masterPlanId!;

      final List<int> dayIds = [];
      final List<Map<String, dynamic>> daysPayload = [];

      for (int i = 0; i < _plans.length; i++) {
        final plan = _plans[i];
        final int? dayId =
            (plan['plan_day_id'] as int?) ?? (plan['id'] as int?);
        if (dayId != null) {
          dayIds.add(dayId);
          daysPayload.add({
            'id': dayId,
            'day_number': i + 1,
            'position': i + 1,
            'order': i + 1,
          });
        }
      }

      // 1. Dedicated atomic reorder endpoint
      try {
        final response = await dio.post<dynamic>(
          ApiUris.multiDayWorkoutReorder(containerId),
          data: {'day_ids': dayIds, 'days': daysPayload, 'order': dayIds},
          options: Options(headers: {'X-Platform': platformSource}),
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          return;
        }
      } catch (_) {}

      // 2. Legacy fallback
      for (int i = 0; i < _plans.length; i++) {
        final plan = _plans[i];
        final int? dayId =
            (plan['plan_day_id'] as int?) ?? (plan['id'] as int?);
        if (dayId != null) {
          await dio.put<dynamic>(
            '${ApiUris.workoutPlans}$containerId/days/$dayId/',
            data: {
              'day_number': i + 1,
              'title': plan['plan_name'] ?? plan['title'],
            },
            options: Options(headers: {'X-Platform': platformSource}),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _openReorderScreen() async {
    if (_plans.isEmpty) return;
    final int? mId = _masterPlanId ?? await _getOrCreateMasterPlanId();
    if (mId == null || !mounted) return;

    final updatedPlans = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(
        builder:
            (context) => MultiDayPlanReorderScreen(
              planTitle: widget.groupTitle,
              plans: _plans,
              masterPlanId: mId,
              source: widget.source ?? 'trainer',
            ),
      ),
    );

    if (updatedPlans != null && mounted) {
      setState(() {
        _plans = updatedPlans;
      });
      _fetchPlans(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const PopButton().center,
        title: Text(
          'Workout Plans',
          style: AppStyles.text16Px.poppins.w600.copyWith(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderGrey),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      _searchQuery = val;
                      EasyDebounce.debounce(
                        'plans-search',
                        const Duration(milliseconds: 400),
                        () => _fetchPlans(),
                      );
                    },
                    decoration: InputDecoration(
                      icon: const Icon(Icons.search, color: AppColors.textGrey),
                      hintText: 'Search for plan',
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FB),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        child: Text(
                          widget.groupTitle.replaceAll('\n', ' '),
                          style: AppStyles.text18Px.poppins.w600.copyWith(
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_plans.length} plans',
                              style: AppStyles.text14Px.poppins.w400.copyWith(
                                color: AppColors.textGrey,
                              ),
                            ),
                            if (widget.groupType == 'multi_day' &&
                                _plans.length > 1)
                              InkWell(
                                onTap: _openReorderScreen,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEAEA),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.swap_vert,
                                        size: 16,
                                        color: Color(0xFFFF3434),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Reorder',
                                        style: AppStyles.text12Px.poppins.w500
                                            .copyWith(
                                              color: const Color(0xFFFF3434),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child:
                            _isLoading
                                ? _buildShimmerList()
                                : _plans.isEmpty
                                ? const Center(
                                  child: Text('No workout plans found.'),
                                )
                                : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    100,
                                  ),
                                  itemCount: _plans.length,
                                  separatorBuilder:
                                      (context, index) =>
                                          const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final plan = _plans[index];
                                    final int planId = plan['id'] as int;
                                    final String planName =
                                        plan['plan_name'] as String? ?? 'Plan';
                                    final int exerciseCount =
                                        plan['exercise_count'] as int? ?? 0;
                                    final String createdOn =
                                        plan['created_at'] != null
                                            ? DateFormat('dd MMM yyyy').format(
                                              DateTime.parse(
                                                plan['created_at'] as String,
                                              ),
                                            )
                                            : 'N/A';

                                    final planSource =
                                        plan['source'] as String? ??
                                        widget.source;
                                    final isOrgPlan =
                                        (planSource == 'organization' ||
                                            planSource == 'gym' ||
                                            plan['is_preset'] == true) &&
                                        widget.source != 'trainer';
                                    final user =
                                        context
                                            .read<AppCubit>()
                                            .state
                                            .currentUser;
                                    final isTrainer = user?.userRole == 35;
                                    final isTrainerOwned =
                                        widget.source == 'trainer' ||
                                        planSource == 'trainer';
                                    final canEditOrDelete =
                                        widget.assignToCustomerId != null ||
                                        isTrainerOwned ||
                                        !isTrainer ||
                                        !isOrgPlan;

                                    final int? dayNum =
                                        widget.groupType == 'multi_day'
                                            ? (index + 1)
                                            : null;

                                    return _PlanCard(
                                      title: planName,
                                      exerciseCount: exerciseCount,
                                      createdOn: createdOn,
                                      canEditOrDelete: canEditOrDelete,
                                      dayNumber: dayNum,
                                      onTap: () async {
                                        final int childPlanId =
                                            (plan['id'] as int?) ?? 0;
                                        final bool isChild =
                                            widget.groupType == 'multi_day' &&
                                            childPlanId != 0 &&
                                            childPlanId != _masterPlanId;
                                        final int targetPlanId =
                                            isChild
                                                ? childPlanId
                                                : (widget.groupType ==
                                                        'multi_day'
                                                    ? (_masterPlanId ?? planId)
                                                    : planId);
                                        final int? targetPlanDayId =
                                            isChild
                                                ? null
                                                : (widget.groupType ==
                                                        'multi_day'
                                                    ? (plan['plan_day_id']
                                                        as int?)
                                                    : null);

                                        final dynamic result = await Navigator.push(
                                          context,
                                          MaterialPageRoute<dynamic>(
                                            builder:
                                                (context) =>
                                                    WorkoutPlanDetailsScreen(
                                                      planTitle: planName,
                                                      planId: targetPlanId,
                                                      planDayId:
                                                          targetPlanDayId,
                                                      isOrganizationWorkout:
                                                          widget.assignToCustomerId !=
                                                                  null
                                                              ? false
                                                              : isOrgPlan,
                                                    ),
                                          ),
                                        );
                                        if (result == true && mounted) {
                                          _fetchPlans(silent: true);
                                        }
                                      },
                                      onAssignTap: () {
                                        showModalBottomSheet<void>(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder:
                                              (context) =>
                                                  AssignToClientBottomSheet(
                                                    planId: planId,
                                                    planTitle: planName,
                                                  ),
                                        );
                                      },
                                      onRename:
                                          () => _renamePlan(
                                            planId,
                                            planName,
                                            planDayId:
                                                plan['plan_day_id'] as int?,
                                          ),
                                      onDelete:
                                          () => _deletePlan(
                                            planId,
                                            planDayId:
                                                plan['plan_day_id'] as int?,
                                          ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child:
                widget.assignToCustomerId != null
                    ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _onAddWorkoutTap,
                            icon: const Icon(
                              Icons.add,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            label: Text(
                              'Add Day',
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  _isAssigning
                                      ? null
                                      : () => _assignCustomizedMultiDay(
                                        widget.assignToCustomerId!,
                                      ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 3,
                              ),
                              child:
                                  _isAssigning
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Text(
                                        'Assign to Client',
                                        style: AppStyles.text14Px.poppins.w600
                                            .copyWith(color: Colors.white),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : Center(
                      child: CreateGroupButton(
                        onTap: _onAddWorkoutTap,
                        label:
                            widget.groupType == 'multi_day'
                                ? 'Add Workout'
                                : 'Create new plan',
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Future<void> _assignCustomizedMultiDay(int customerId) async {
    final titleController = TextEditingController(text: widget.groupTitle);
    final notesController = TextEditingController();
    DateTime? selectedDate = DateTime.now();
    String? holidayWarning = await GymHolidayService.getHolidayName(selectedDate);

    final bool? confirmed = await showDialog<bool>(
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
                'Assign Workout Title',
                style: AppStyles.text16Px.poppins.w600,
              ),
              content: SingleChildScrollView(
                child: Column(
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
                      'Start Date',
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
                          final hol = await GymHolidayService.getHolidayName(picked);
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
                      onPressed: () => Navigator.pop(dialogContext, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
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
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
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

    if (confirmed != true) return;

    final targetDate = selectedDate ?? DateTime.now();
    final isHol = await GymHolidayService.isHoliday(targetDate);
    if (isHol) {
      Dialogs.showSnack(
        msg: 'Cannot assign workout: The selected date is a gym holiday.',
      );
      return;
    }

    final enteredTitle = titleController.text.trim();
    final String finalTitle =
        enteredTitle.isNotEmpty ? enteredTitle : widget.groupTitle;

    if (!mounted) return;
    setState(() {
      _isAssigning = true;
    });

    try {
      final dio = DioClient().dio;
      final targetPlanId = _masterPlanId ?? widget.groupId;

      final String startDateStr =
          "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";
      final int totalDays = _plans.isNotEmpty ? _plans.length : 7;
      final DateTime calculatedEndDate =
          targetDate.add(Duration(days: totalDays - 1));
      final String endDateStr =
          "${calculatedEndDate.year}-${calculatedEndDate.month.toString().padLeft(2, '0')}-${calculatedEndDate.day.toString().padLeft(2, '0')}";

      List<Map<String, dynamic>> assignDays = [];
      for (int i = 0; i < _plans.length; i++) {
        final dayMap = _plans[i];
        final dayDate = targetDate.add(Duration(days: i));
        final String dayDateStr =
            "${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}";
        final int pId = (dayMap['child_plan_id'] as int?) ??
            ((dayMap['child_plan'] is Map)
                ? (dayMap['child_plan']['id'] as int?)
                : null) ??
            (dayMap['plan'] as int?) ??
            (dayMap['plan_id'] as int?) ??
            (dayMap['id'] as int? ?? 0);

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
      }

      dynamic response;
      try {
        response = await dio.post<dynamic>(
          ApiUris.assignMultiDayWorkout(targetPlanId),
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
            'group_id': targetPlanId,
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

      if (!mounted) return;
      setState(() {
        _isAssigning = false;
      });

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        Dialogs.showSnack(msg: 'Multi-day workout assigned successfully!');
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
      } else {
        Dialogs.showSnack(msg: 'Failed to assign multi-day workout');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _isAssigning = false;
      });
      String errorMsg = 'Error assigning plan';
      if (e.response?.data is Map) {
        errorMsg =
            (e.response!.data as Map)['error']?.toString() ??
            (e.response!.data as Map)['message']?.toString() ??
            (e.response!.data as Map)['detail']?.toString() ??
            errorMsg;
      }
      Dialogs.showSnack(msg: errorMsg);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAssigning = false;
      });
      Dialogs.showSnack(msg: 'Error assigning plan: ${e.toString()}');
    }
  }

  Future<int?> _getOrCreateMasterPlanId() async {
    if (_masterPlanId != null) {
      return _masterPlanId;
    }
    if (widget.groupType == 'multi_day' && widget.assignToCustomerId != null) {
      _masterPlanId = widget.groupId;
      return _masterPlanId;
    }

    final user = context.read<AppCubit>().state.currentUser;
    final isTrainer = user?.userRole == 35;
    final source = isTrainer ? 'trainer' : 'organization';

    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.workoutPlans,
        data: {
          'plan_name': widget.groupTitle,
          'plan_name_internal': widget.groupTitle,
          'group': widget.groupId,
          'total_weeks': 1,
          'total_days': 0,
          'source': source,
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map &&
          response.data['id'] != null) {
        final planId = response.data['id'] as int;
        _masterPlanId = planId;
        await _fetchPlans();
        return planId;
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error initializing master plan: ${e.toString()}');
    }
    return null;
  }

  void _onAddWorkoutTap() async {
    if (widget.groupType == 'multi_day') {
      final masterPlanId = await _getOrCreateMasterPlanId();
      if (masterPlanId != null && mounted) {
        final bool isFirstDummyDay =
            _plans.length == 1 &&
            ((_plans[0]['exercise_count'] as int? ?? 0) == 0) &&
            (_plans[0]['plan_name'] == 'Day 1' ||
                _plans[0]['plan_name'] == widget.groupTitle);

        final nextDayNumber = isFirstDummyDay ? 1 : _plans.length + 1;
        final firstDayId =
            isFirstDummyDay ? (_plans[0]['plan_day_id'] as int?) : null;

        _showSelectWorkoutGroupSheet(
          context,
          nextDayNumber: nextDayNumber,
          masterPlanId: masterPlanId,
          firstDayIdToReplace: firstDayId,
        );
      }
    } else {
      _showCreatePlanSheet(context);
    }
  }

  void _showSelectWorkoutGroupSheet(
    BuildContext context, {
    required int nextDayNumber,
    required int masterPlanId,
    int? firstDayIdToReplace,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SelectGroupForWorkoutSheet(
          onGroupSelected: (groupId, groupName) {
            Navigator.pop(context);
            _showSelectPlanForDaySheet(
              context,
              groupId: groupId,
              groupName: groupName,
              nextDayNumber: nextDayNumber,
              masterPlanId: masterPlanId,
              firstDayIdToReplace: firstDayIdToReplace,
            );
          },
        );
      },
    );
  }

  void _showSelectPlanForDaySheet(
    BuildContext context, {
    required int groupId,
    required String groupName,
    required int nextDayNumber,
    required int masterPlanId,
    int? firstDayIdToReplace,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SelectPlanForDaySheet(
          groupId: groupId,
          groupName: groupName,
          nextDayNumber: nextDayNumber,
          masterPlanId: masterPlanId,
          firstDayIdToReplace: firstDayIdToReplace,
          onBackToGroupSelect: (updatedNextDay, updatedReplaceId) {
            _showSelectWorkoutGroupSheet(
              context,
              nextDayNumber: updatedNextDay,
              masterPlanId: masterPlanId,
              firstDayIdToReplace: updatedReplaceId,
            );
          },
          onPlanAdded: () {
            _fetchPlans();
          },
        );
      },
    );
  }

  Future<void> _renamePlan(
    int planId,
    String currentName, {
    int? planDayId,
  }) async {
    final nameController = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Rename Workout Plan',
            style: AppStyles.text16Px.poppins.w600,
          ),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter new plan name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: Text(
                'Cancel',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed:
                  () =>
                      Navigator.pop(dialogContext, nameController.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Save',
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty && newName != currentName) {
      try {
        final dio = DioClient().dio;
        dynamic response;

        final int? masterPlanId =
            _masterPlanId ?? await _getOrCreateMasterPlanId();

        if (widget.groupType == 'multi_day' &&
            planDayId != null &&
            masterPlanId != null) {
          try {
            response = await dio.patch<dynamic>(
              '${ApiUris.workoutPlanDays(masterPlanId)}$planDayId/',
              data: {'title': newName, 'name': newName},
              options: Options(headers: {'X-Platform': platformSource}),
            );
          } catch (_) {
            try {
              response = await dio.patch<dynamic>(
                '${ApiUris.multiDayWorkoutDays(masterPlanId)}$planDayId/',
                data: {'title': newName, 'name': newName},
                options: Options(headers: {'X-Platform': platformSource}),
              );
            } catch (_) {
              response = await dio.patch<dynamic>(
                '${ApiUris.workoutPlans}$masterPlanId/days/$planDayId/',
                data: {'title': newName},
                options: Options(headers: {'X-Platform': platformSource}),
              );
            }
          }
        } else {
          try {
            response = await dio.patch<dynamic>(
              ApiUris.singleDayWorkoutDetail(planId),
              data: {'name': newName, 'plan_name': newName},
              options: Options(headers: {'X-Platform': platformSource}),
            );
          } catch (_) {
            response = await dio.patch<dynamic>(
              ApiUris.workoutPlanDetail(planId),
              data: {'name': newName, 'plan_name': newName},
              options: Options(headers: {'X-Platform': platformSource}),
            );
          }
        }

        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 204)) {
          Dialogs.showSnack(msg: 'Workout plan renamed successfully');
          _fetchPlans();
        } else {
          Dialogs.showSnack(msg: 'Failed to rename workout plan');
        }
      } catch (e) {
        Dialogs.showSnack(msg: 'Error renaming plan: ${e.toString()}');
      }
    }
  }

  Future<void> _deletePlan(int planId, {int? planDayId}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            widget.groupType == 'multi_day'
                ? 'Delete Workout Day'
                : 'Delete Workout Plan',
            style: AppStyles.text16Px.poppins.w600,
          ),
          content: Text(
            widget.groupType == 'multi_day'
                ? 'Are you sure you want to delete this workout day?'
                : 'Are you sure you want to delete this workout plan?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete',
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final previousPlans = List<Map<String, dynamic>>.from(_plans);
      setState(() {
        _plans.removeWhere((p) {
          if (planDayId != null) {
            return p['plan_day_id'] == planDayId;
          }
          return p['id'] == planId;
        });
        if (widget.groupType == 'multi_day') {
          for (int i = 0; i < _plans.length; i++) {
            _plans[i]['day_number'] = i + 1;
          }
        }
      });

      try {
        final dio = DioClient().dio;
        dynamic response;

        final int? masterPlanId =
            _masterPlanId ?? await _getOrCreateMasterPlanId();

        if (widget.groupType == 'multi_day' &&
            planDayId != null &&
            masterPlanId != null) {
          try {
            response = await dio.delete<dynamic>(
              '${ApiUris.workoutPlanDays(masterPlanId)}$planDayId/',
              options: Options(headers: {'X-Platform': platformSource}),
            );
          } catch (_) {
            try {
              response = await dio.delete<dynamic>(
                '${ApiUris.multiDayWorkoutDays(masterPlanId)}$planDayId/',
                options: Options(headers: {'X-Platform': platformSource}),
              );
            } catch (_) {
              try {
                response = await dio.delete<dynamic>(
                  '${ApiUris.workoutPlans}$masterPlanId/days/$planDayId/',
                  options: Options(headers: {'X-Platform': platformSource}),
                );
              } catch (_) {
                response = await dio.delete<dynamic>(
                  'api/v1/trainer/plan-days/$planDayId/',
                  options: Options(headers: {'X-Platform': platformSource}),
                );
              }
            }
          }
        } else {
          try {
            response = await dio.delete<dynamic>(
              ApiUris.singleDayWorkoutDetail(planId),
              options: Options(headers: {'X-Platform': platformSource}),
            );
          } catch (_) {
            response = await dio.delete<dynamic>(
              ApiUris.workoutPlanDetail(planId),
              options: Options(headers: {'X-Platform': platformSource}),
            );
          }
        }

        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 204)) {
          final msg =
              (response.data is Map && response.data['message'] != null)
                  ? response.data['message'].toString()
                  : (widget.groupType == 'multi_day'
                      ? 'Workout day deleted successfully.'
                      : 'Workout plan deleted successfully.');
          Dialogs.showSnack(msg: msg);
          if (widget.groupType == 'multi_day') {
            await _saveReorderedDays();
          }
          if (mounted) {
            await _fetchPlans(silent: true);
          }
        } else {
          if (mounted) {
            setState(() {
              _plans = previousPlans;
            });
          }
          Dialogs.showSnack(
            msg: widget.groupType == 'multi_day'
                ? 'Failed to delete workout day'
                : 'Failed to delete workout plan',
          );
        }
      } on DioException catch (e) {
        if (mounted) {
          setState(() {
            _plans = previousPlans;
          });
        }
        String errorMsg = 'Error deleting plan';
        if (e.response?.data is Map) {
          final map = e.response!.data as Map;
          errorMsg =
              map['detail']?.toString() ??
              map['message']?.toString() ??
              errorMsg;
        }
        Dialogs.showSnack(msg: errorMsg);
      } catch (e) {
        if (mounted) {
          setState(() {
            _plans = previousPlans;
          });
        }
        Dialogs.showSnack(msg: 'Error deleting plan: ${e.toString()}');
      }
    }
  }

  Future<void> _createPlan(
    String planName, {
    int totalWeeks = 1,
    int totalDays = 1,
    String? description,
  }) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final user = context.read<AppCubit>().state.currentUser;
    final isTrainer = user?.userRole == 35;
    final source = isTrainer ? 'trainer' : 'organization';

    try {
      final dio = DioClient().dio;
      dynamic response;

      // Primary: Create via workoutPlans with group link
      try {
        response = await dio.post<dynamic>(
          ApiUris.workoutPlans,
          data: {
            'plan_name': planName,
            'plan_name_internal': planName,
            'name': planName,
            if (description != null && description.isNotEmpty)
              'description': description,
            'group': widget.groupId,
            'total_weeks': totalWeeks,
            'total_days': totalDays,
            'source': source,
          },
          options: Options(headers: {'X-Platform': platformSource}),
        );
      } catch (_) {
        if (widget.groupType == 'multi_day') {
          response = await dio.post<dynamic>(
            ApiUris.multiDayWorkouts,
            data: {
              'name': planName,
              'title': planName,
              'plan_name': planName,
              'group': widget.groupId,
              'total_weeks': totalWeeks,
              'total_days': totalDays,
              if (description != null && description.isNotEmpty)
                'description': description,
              'source': source,
            },
            options: Options(headers: {'X-Platform': platformSource}),
          );
        } else {
          response = await dio.post<dynamic>(
            ApiUris.singleDayWorkouts,
            data: {
              'name': planName,
              'title': planName,
              'plan_name': planName,
              'group': widget.groupId,
              if (description != null && description.isNotEmpty)
                'description': description,
              'source': source,
            },
            options: Options(headers: {'X-Platform': platformSource}),
          );
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(msg: 'Workout plan created successfully');
        _planName.controller?.clear();

        if (response.data is Map && response.data['id'] != null) {
          final int planId = response.data['id'] as int;
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder:
                  (context) => WorkoutPlanDetailsScreen(
                    planId: planId,
                    planTitle: planName,
                  ),
            ),
          ).then((_) {
            if (mounted) {
              _fetchPlans(silent: true);
            }
          });
        } else {
          _fetchPlans(silent: true);
        }
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to create plan');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error creating plan: ${e.toString()}');
    }
  }

  void _showCreatePlanSheet(BuildContext context) {
    final isMultiDay = widget.groupType == 'multi_day';
    final weeksController = TextEditingController(text: '4');
    final daysController = TextEditingController(text: '3');
    final descController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMultiDay
                        ? 'Create Multi-Day Plan'
                        : 'Create Single-Day Plan',
                    style: AppStyles.text18Px.poppins.w600.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      text: 'Plan Name ',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: context.colors.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: '*',
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Field(data: _planName.copyWith(label: '')),
                  if (isMultiDay) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Weeks',
                                style: AppStyles.text14Px.poppins.w500.copyWith(
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: weeksController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '4',
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.borderGrey,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Days/Routines',
                                style: AppStyles.text14Px.poppins.w500.copyWith(
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: daysController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '3',
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.borderGrey,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        hintText: 'e.g. 3-day weekly workout plan',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.borderGrey,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final name = _planName.controller?.text.trim() ?? '';
                          final weeks =
                              int.tryParse(weeksController.text.trim()) ?? 4;
                          final days =
                              int.tryParse(daysController.text.trim()) ?? 3;
                          final desc = descController.text.trim();
                          Navigator.pop(context);
                          if (name.isNotEmpty) {
                            _createPlan(
                              name,
                              totalWeeks: isMultiDay ? weeks : 1,
                              totalDays: isMultiDay ? days : 1,
                              description: desc,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD30000),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Create Plan',
                        style: AppStyles.text16Px.poppins.w600.copyWith(
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
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KShimmer(width: 180, height: 16, radius: 4),
              const SizedBox(height: 8),
              const KShimmer(width: 110, height: 12, radius: 4),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KShimmer(width: 60, height: 10, radius: 4),
                      SizedBox(height: 4),
                      KShimmer(width: 80, height: 12, radius: 4),
                    ],
                  ),
                  KShimmer(width: 90, height: 34, radius: 20),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.exerciseCount,
    required this.createdOn,
    required this.onTap,
    required this.onAssignTap,
    required this.onRename,
    required this.onDelete,
    this.canEditOrDelete = true,
    this.dayNumber,
  });

  final String title;
  final int exerciseCount;
  final String createdOn;
  final VoidCallback onTap;
  final VoidCallback onAssignTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final bool canEditOrDelete;
  final int? dayNumber;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (dayNumber != null) ...[
              Container(
                width: 56,
                height: 56,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'DAY',
                      style: AppStyles.text10Px.poppins.w600.copyWith(
                        color: AppColors.textDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '$dayNumber',
                      style: AppStyles.text18Px.poppins.w700.copyWith(
                        color: AppColors.textDark,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                          style: AppStyles.text16Px.poppins.w600.copyWith(
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (canEditOrDelete)
                        PopupMenuButton<String>(
                          color: Colors.white,
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            if (value == 'rename') {
                              onRename();
                            } else if (value == 'delete') {
                              onDelete();
                            }
                          },
                          itemBuilder:
                              (context) => [
                                PopupMenuItem<String>(
                                  height: 36,
                                  value: 'rename',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.edit_outlined,
                                        color: AppColors.textDark,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Rename',
                                        style: AppStyles.text14Px.poppins
                                            .copyWith(
                                              color: AppColors.textDark,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  height: 36,
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Delete',
                                        style: AppStyles.text14Px.poppins
                                            .copyWith(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                          child: const CircleAvatar(
                            backgroundColor: AppColors.grey,
                            radius: 15,
                            child: Icon(
                              Icons.more_vert,
                              size: 18,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No of Exercises: $exerciseCount',
                    style: AppStyles.text14Px.poppins.w400.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Created on\n$createdOn',
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                      if (dayNumber == null)
                        InkWell(
                          onTap: onAssignTap,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF2E7D32),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              'Assign to',
                              style: AppStyles.text12Px.poppins.w600.copyWith(
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ),
                    ],
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

class _SelectGroupForWorkoutSheet extends StatefulWidget {
  const _SelectGroupForWorkoutSheet({required this.onGroupSelected});
  final Function(int groupId, String groupName) onGroupSelected;

  @override
  State<_SelectGroupForWorkoutSheet> createState() =>
      __SelectGroupForWorkoutSheetState();
}

class __SelectGroupForWorkoutSheetState
    extends State<_SelectGroupForWorkoutSheet> {
  List<Map<String, dynamic>> _groups = [];
  bool _isLoading = true;
  String _search = '';
  String _filter = 'all'; // 'all', 'trainer', 'org'

  @override
  void initState() {
    super.initState();
    _fetchSingleDayGroups();
  }

  Future<void> _fetchSingleDayGroups() async {
    try {
      final dio = DioClient().dio;
      final queryParams = {
        if (_search.trim().isNotEmpty) 'search': _search.trim(),
      };

      final List<Map<String, dynamic>> combined = [];
      final Set<int> seenIds = {};

      void addGroups(dynamic rawData) {
        if (rawData == null) return;
        final List<dynamic> list =
            (rawData is Map)
                ? (rawData['results'] as List<dynamic>? ?? [])
                : (rawData is List ? rawData : []);
        for (final item in list) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            final id = map['id'] as int?;
            if (id != null && !seenIds.contains(id)) {
              seenIds.add(id);
              combined.add(map);
            }
          }
        }
      }

      // 1. Fetch from trainer workout groups endpoint
      try {
        final response = await dio.get<dynamic>(
          ApiUris.workoutGroups,
          queryParameters: queryParams,
          options: Options(headers: {'X-Platform': platformSource}),
        );
        if (response.statusCode == 200) {
          addGroups(response.data);
        }
      } catch (_) {}

      // 2. Fetch from gym/organization workout groups endpoint to ensure all org groups are loaded
      try {
        final gymResponse = await dio.get<dynamic>(
          ApiUris.gymWorkoutGroups,
          queryParameters: queryParams,
          options: Options(headers: {'X-Platform': platformSource}),
        );
        if (gymResponse.statusCode == 200) {
          addGroups(gymResponse.data);
        }
      } catch (_) {}

      // 3. Filter for single-day groups (exclude multi_day groups)
      final singleDayGroups =
          combined.where((g) {
            final type = g['type']?.toString();
            return type != 'multi_day';
          }).toList();

      singleDayGroups.sort((a, b) {
        final aId = a['id'] as int? ?? 0;
        final bId = b['id'] as int? ?? 0;
        return bId.compareTo(aId);
      });

      if (mounted) {
        setState(() {
          _groups = singleDayGroups;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredGroups {
    if (_filter == 'trainer') {
      return _groups.where((g) => g['source'] == 'trainer').toList();
    } else if (_filter == 'org') {
      return _groups
          .where(
            (g) =>
                g['source'] == 'organization' ||
                g['source'] == 'gym' ||
                g['is_preset'] == true,
          )
          .toList();
    }
    return _groups;
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _filter == value;
    return InkWell(
      onTap: () => setState(() => _filter = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD30000) : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppStyles.text12Px.poppins.w500.copyWith(
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: AppStyles.text10Px.poppins.w600.copyWith(
                  color: isSelected ? Colors.white : AppColors.textGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedGroups = _filteredGroups;
    final trainerCount = _groups.where((g) => g['source'] == 'trainer').length;
    final orgCount =
        _groups
            .where(
              (g) =>
                  g['source'] == 'organization' ||
                  g['source'] == 'gym' ||
                  g['is_preset'] == true,
            )
            .length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Select the group of the workout',
                  style: AppStyles.text18Px.poppins.w600.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textDark),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: (val) {
              _search = val;
              _fetchSingleDayGroups();
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              hintText: 'Search for workout group',
              filled: true,
              fillColor: AppColors.fieldFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all', _groups.length),
                const SizedBox(width: 8),
                _buildFilterChip('My Groups', 'trainer', trainerCount),
                const SizedBox(width: 8),
                _buildFilterChip('Organization', 'org', orgCount),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : displayedGroups.isEmpty
                    ? const Center(child: Text('No workout groups found.'))
                    : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.25,
                          ),
                      itemCount: displayedGroups.length,
                      itemBuilder: (context, index) {
                        final g = displayedGroups[index];
                        final int gId = g['id'] as int;
                        final String gName = g['name'] as String? ?? '';
                        final int planCount =
                            g['plan_count'] as int? ??
                            g['plans_count'] as int? ??
                            0;
                        final isTrainerCreated = g['source'] == 'trainer';

                        return InkWell(
                          onTap: () => widget.onGroupSelected(gId, gName),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      gName,
                                      style: AppStyles.text14Px.poppins.w600
                                          .copyWith(color: AppColors.textDark),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isTrainerCreated
                                                ? const Color(0xFFFFF0F0)
                                                : const Color(0xFFF2F4F7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isTrainerCreated
                                            ? 'My Group'
                                            : 'Organization',
                                        style: AppStyles.text10Px.poppins.w500
                                            .copyWith(
                                              color:
                                                  isTrainerCreated
                                                      ? const Color(0xFFD30000)
                                                      : const Color(0xFF475467),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Workout plans: $planCount',
                                      style: AppStyles.text12Px.poppins.w400
                                          .copyWith(color: AppColors.textGrey),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                      color: AppColors.textGrey,
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

class _SelectPlanForDaySheet extends StatefulWidget {
  const _SelectPlanForDaySheet({
    required this.groupId,
    required this.groupName,
    required this.nextDayNumber,
    required this.masterPlanId,
    required this.onPlanAdded,
    required this.onBackToGroupSelect,
    this.firstDayIdToReplace,
  });

  final int groupId;
  final String groupName;
  final int nextDayNumber;
  final int masterPlanId;
  final int? firstDayIdToReplace;
  final VoidCallback onPlanAdded;
  final void Function(int nextDayNumber, int? firstDayIdToReplace)
  onBackToGroupSelect;

  @override
  State<_SelectPlanForDaySheet> createState() => __SelectPlanForDaySheetState();
}

class __SelectPlanForDaySheetState extends State<_SelectPlanForDaySheet> {
  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = true;
  String _search = '';
  final Set<int> _addingPlanIds = {};
  final Set<int> _addedPlanIds = {};
  late int _currentNextDayNumber;
  int? _currentFirstDayIdToReplace;

  @override
  void initState() {
    super.initState();
    _currentNextDayNumber = widget.nextDayNumber;
    _currentFirstDayIdToReplace = widget.firstDayIdToReplace;
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.workoutPlans,
        queryParameters: {
          'group': widget.groupId,
          if (_search.trim().isNotEmpty) 'search': _search.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data =
            (response.data is Map)
                ? (response.data['results'] as List<dynamic>? ?? [])
                : (response.data is List ? response.data as List<dynamic> : []);
        if (mounted) {
          setState(() {
            _plans =
                data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addDay(int planId, String planName) async {
    setState(() => _addingPlanIds.add(planId));
    try {
      if (_currentFirstDayIdToReplace != null) {
        try {
          await DioClient().dio.delete<dynamic>(
            '${ApiUris.workoutPlanDays(widget.masterPlanId)}$_currentFirstDayIdToReplace/',
            options: Options(headers: {'X-Platform': platformSource}),
          );
        } catch (_) {}
        _currentFirstDayIdToReplace = null;
      }

      final dayToAssign = _currentNextDayNumber;

      dynamic response;
      try {
        response = await DioClient().dio.post<dynamic>(
          ApiUris.multiDayWorkoutDays(widget.masterPlanId),
          data: {
            'day_number': dayToAssign,
            'title': planName,
            'plan_id': planId,
            'child_plan_id': planId,
            'child_plan': planId,
            'is_rest_day': false,
          },
          options: Options(headers: {'X-Platform': platformSource}),
        );
      } catch (_) {
        response = await DioClient().dio.post<dynamic>(
          ApiUris.workoutPlanDays(widget.masterPlanId),
          data: {
            'day_number': dayToAssign,
            'title': planName,
            'plan_id': planId,
            'child_plan_id': planId,
            'child_plan': planId,
            'is_rest_day': false,
          },
          options: Options(headers: {'X-Platform': platformSource}),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          setState(() {
            _addingPlanIds.remove(planId);
            _addedPlanIds.add(planId);
            _currentNextDayNumber++;
          });
        }
        Dialogs.showSnack(msg: 'Added $planName to Day $dayToAssign');
        widget.onPlanAdded();
      } else {
        if (mounted) setState(() => _addingPlanIds.remove(planId));
        Dialogs.showSnack(msg: 'Failed to add workout plan');
      }
    } catch (e) {
      if (mounted) setState(() => _addingPlanIds.remove(planId));
      Dialogs.showSnack(msg: 'Error adding workout plan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onBackToGroupSelect?.call(
                    _currentNextDayNumber,
                    _currentFirstDayIdToReplace,
                  );
                },
                icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Add Workout Plan for Day $_currentNextDayNumber',
                  style: AppStyles.text18Px.poppins.w600.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (val) {
              _search = val;
              _fetchPlans();
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              hintText: 'Search for plan',
              filled: true,
              fillColor: AppColors.fieldFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _plans.isEmpty
                    ? const Center(child: Text('No workout plans found.'))
                    : ListView.separated(
                      itemCount: _plans.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final plan = _plans[index];
                        final int pId = plan['id'] as int;
                        final String pName = plan['plan_name'] as String? ?? '';
                        final int exCount = plan['exercise_count'] as int? ?? 0;
                        final isAdding = _addingPlanIds.contains(pId);
                        final isAdded = _addedPlanIds.contains(pId);

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pName,
                                      style: AppStyles.text14Px.poppins.w600
                                          .copyWith(color: AppColors.textDark),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'No of Exercises: $exCount',
                                      style: AppStyles.text12Px.poppins.w400
                                          .copyWith(color: AppColors.textGrey),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed:
                                    (isAdding || isAdded)
                                        ? null
                                        : () => _addDay(pId, pName),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isAdded
                                          ? Colors.grey
                                          : const Color(0xFFD30000),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  isAdding
                                      ? 'Adding...'
                                      : isAdded
                                      ? 'Added'
                                      : 'Add',
                                  style: AppStyles.text12Px.poppins.w600
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                            ],
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
