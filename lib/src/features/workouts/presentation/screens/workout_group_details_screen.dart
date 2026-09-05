import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/widgets/create_group_button.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_details_screen.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/assign_workout_plan_screen.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/widgets/assign_to_client_bottom_sheet.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:intl/intl.dart';

class WorkoutGroupDetailsScreen extends StatefulWidget {
  const WorkoutGroupDetailsScreen({
    required this.groupId,
    required this.groupTitle,
    this.source,
    this.groupType,
    super.key,
  });

  final int groupId;
  final String groupTitle;
  final String? source;
  final String? groupType;

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

  Future<void> _fetchPlans() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.workoutPlans,
        queryParameters: {
          'group': widget.groupId,
          if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        final fetchedPlans =
            data.map((e) => Map<String, dynamic>.from(e as Map)).toList();

        if (widget.groupType == 'multi_day' && fetchedPlans.isNotEmpty) {
          final int masterPlanId = fetchedPlans[0]['id'] as int;
          _masterPlanId = masterPlanId;
          try {
            final detailResponse = await DioClient().dio.get<dynamic>(
              ApiUris.workoutPlanDetail(masterPlanId),
              options: Options(headers: {'X-Platform': platformSource}),
            );

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
                    final int exCount =
                        (dayMap['exercise_count'] as int?) ??
                        (dayMap['total_exercises'] as int?) ??
                        exercises.length;

                    final int targetPlanId =
                        (dayMap['plan'] as int?) ??
                        (dayMap['plan_id'] as int?) ??
                        (dayMap['id'] as int);

                    return <String, dynamic>{
                      'id': targetPlanId,
                      'plan_day_id': dayMap['id'],
                      'plan_name': dayMap['title'] as String? ?? 'Day Routine',
                      'day_number': dayMap['day_number'] as int? ?? 1,
                      'exercise_count': exCount,
                      'created_at':
                          dayMap['created_at'] ?? planDetail['created_at'],
                      'source': planDetail['source'],
                      'is_preset': planDetail['is_preset'],
                    };
                  }).toList();

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
      for (int i = 0; i < _plans.length; i++) {
        final plan = _plans[i];
        final int? dayId =
            (plan['plan_day_id'] as int?) ?? (plan['id'] as int?);
        if (dayId != null) {
          await dio.put<dynamic>(
            '${ApiUris.workoutPlans}$_masterPlanId/days/$dayId/',
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
                            // Container(
                            //   padding: const EdgeInsets.symmetric(
                            //     horizontal: 12,
                            //     vertical: 6,
                            //   ),
                            //   decoration: BoxDecoration(
                            //     color: const Color(0xFFFFEAEA),
                            //     borderRadius: BorderRadius.circular(20),
                            //   ),
                            //   child: Row(
                            //     children: [
                            //       const Icon(
                            //         Icons.filter_alt_outlined,
                            //         size: 16,
                            //         color: Color(0xFFFF3434),
                            //       ),
                            //       const SizedBox(width: 4),
                            //       Text(
                            //         'Sort',
                            //         style: AppStyles.text12Px.poppins.w500
                            //             .copyWith(
                            //               color: const Color(0xFFFF3434),
                            //             ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
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
                                : widget.groupType == 'multi_day'
                                ? ReorderableListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    100,
                                  ),
                                  itemCount: _plans.length,
                                  onReorder: (int oldIndex, int newIndex) {
                                    setState(() {
                                      if (oldIndex < newIndex) {
                                        newIndex -= 1;
                                      }
                                      final item = _plans.removeAt(oldIndex);
                                      _plans.insert(newIndex, item);
                                      for (int i = 0; i < _plans.length; i++) {
                                        _plans[i]['day_number'] = i + 1;
                                      }
                                    });
                                    _saveReorderedDays();
                                  },
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
                                        planSource == 'organization' ||
                                        planSource == 'gym' ||
                                        plan['is_preset'] == true;
                                    final user =
                                        context
                                            .read<AppCubit>()
                                            .state
                                            .currentUser;
                                    final isTrainer = user?.userRole == 35;
                                    final canEditOrDelete =
                                        !isTrainer || !isOrgPlan;

                                    final int? dayNum =
                                        (plan['day_number'] as int?) ??
                                        (index + 1);

                                    return Padding(
                                      key: ValueKey(
                                        plan['plan_day_id'] ??
                                            plan['id'] ??
                                            'day_$index',
                                      ),
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: _PlanCard(
                                        title: planName,
                                        exerciseCount: exerciseCount,
                                        createdOn: createdOn,
                                        canEditOrDelete: canEditOrDelete,
                                        dayNumber: dayNum,
                                        onTap: () async {
                                          final int targetPlanId =
                                              _masterPlanId ?? planId;
                                          final int? targetPlanDayId =
                                              plan['plan_day_id'] as int?;

                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute<void>(
                                              builder:
                                                  (context) =>
                                                      WorkoutPlanDetailsScreen(
                                                        planTitle: planName,
                                                        planId: targetPlanId,
                                                        planDayId:
                                                            targetPlanDayId,
                                                      ),
                                            ),
                                          );
                                          if (mounted) {
                                            _fetchPlans();
                                          }
                                        },
                                        onAssignTap: () {},
                                        onRename:
                                            () => _renamePlan(planId, planName),
                                        onDelete: () => _deletePlan(planId),
                                      ),
                                    );
                                  },
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
                                        planSource == 'organization' ||
                                        planSource == 'gym' ||
                                        plan['is_preset'] == true;
                                    final user =
                                        context
                                            .read<AppCubit>()
                                            .state
                                            .currentUser;
                                    final isTrainer = user?.userRole == 35;
                                    final canEditOrDelete =
                                        !isTrainer || !isOrgPlan;

                                    final int? dayNum =
                                        widget.groupType == 'multi_day'
                                            ? ((plan['day_number'] as int?) ??
                                                (index + 1))
                                            : null;

                                    return _PlanCard(
                                      title: planName,
                                      exerciseCount: exerciseCount,
                                      createdOn: createdOn,
                                      canEditOrDelete: canEditOrDelete,
                                      dayNumber: dayNum,
                                      onTap: () async {
                                        final int targetPlanId =
                                            widget.groupType == 'multi_day'
                                                ? (_masterPlanId ?? planId)
                                                : planId;
                                        final int? targetPlanDayId =
                                            widget.groupType == 'multi_day'
                                                ? (plan['plan_day_id'] as int?)
                                                : null;

                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder:
                                                (context) =>
                                                    WorkoutPlanDetailsScreen(
                                                      planTitle: planName,
                                                      planId: targetPlanId,
                                                      planDayId:
                                                          targetPlanDayId,
                                                    ),
                                          ),
                                        );
                                        if (mounted) {
                                          _fetchPlans();
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
                                          () => _renamePlan(planId, planName),
                                      onDelete: () => _deletePlan(planId),
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
            child: Center(
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

  Future<int?> _getOrCreateMasterPlanId() async {
    if (_masterPlanId != null) {
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

  Future<void> _renamePlan(int planId, String currentName) async {
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
        final response = await DioClient().dio.patch<dynamic>(
          ApiUris.workoutPlanDetail(planId),
          data: {'name': newName, 'plan_name': newName},
          options: Options(headers: {'X-Platform': platformSource}),
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
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

  Future<void> _deletePlan(int planId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Workout Plan',
            style: AppStyles.text16Px.poppins.w600,
          ),
          content: const Text(
            'Are you sure you want to delete this workout plan?',
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
      try {
        final response = await DioClient().dio.delete<dynamic>(
          ApiUris.workoutPlanDetail(planId),
          options: Options(headers: {'X-Platform': platformSource}),
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          final msg =
              (response.data is Map && response.data['message'] != null)
                  ? response.data['message'].toString()
                  : 'Workout plan deleted successfully.';
          Dialogs.showSnack(msg: msg);
          _fetchPlans();
        } else {
          Dialogs.showSnack(msg: 'Failed to delete workout plan');
        }
      } on DioException catch (e) {
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
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.workoutPlans,
        data: {
          'plan_name': planName,
          'plan_name_internal': planName,
          if (description != null && description.isNotEmpty)
            'description': description,
          'group': widget.groupId,
          'total_weeks': totalWeeks,
          'total_days': totalDays,
          'source': source,
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

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
            _fetchPlans();
          });
        } else {
          _fetchPlans();
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
              const Icon(
                Icons.drag_handle_rounded,
                color: AppColors.textGrey,
                size: 22,
              ),
              const SizedBox(width: 8),
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

  @override
  void initState() {
    super.initState();
    _fetchSingleDayGroups();
  }

  Future<void> _fetchSingleDayGroups() async {
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.workoutGroups,
        queryParameters: {
          'type': 'single_day',
          if (_search.trim().isNotEmpty) 'search': _search.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data =
            (response.data is Map)
                ? (response.data['results'] as List<dynamic>? ?? [])
                : (response.data as List<dynamic>);
        if (mounted) {
          setState(() {
            _groups =
                data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _groups.isEmpty
                    ? const Center(child: Text('No workout groups found.'))
                    : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.5,
                          ),
                      itemCount: _groups.length,
                      itemBuilder: (context, index) {
                        final g = _groups[index];
                        final int gId = g['id'] as int;
                        final String gName = g['name'] as String? ?? '';
                        final int planCount =
                            g['plan_count'] as int? ??
                            g['plans_count'] as int? ??
                            0;

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
                                Text(
                                  gName,
                                  style: AppStyles.text14Px.poppins.w600
                                      .copyWith(color: AppColors.textDark),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
    this.firstDayIdToReplace,
    this.onBackToGroupSelect,
  });

  final int groupId;
  final String groupName;
  final int nextDayNumber;
  final int masterPlanId;
  final int? firstDayIdToReplace;
  final VoidCallback onPlanAdded;
  final void Function(int updatedNextDay, int? updatedReplaceId)? onBackToGroupSelect;

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
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
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

      final response = await DioClient().dio.post<dynamic>(
        ApiUris.workoutPlanDays(widget.masterPlanId),
        data: {
          'day_number': dayToAssign,
          'title': planName,
          'plan_id': planId,
          'is_rest_day': false,
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          setState(() {
            _addingPlanIds.remove(planId);
            _addedPlanIds.add(planId);
            _currentNextDayNumber++;
          });
        }
        Dialogs.showSnack(
          msg: 'Added $planName to Day $dayToAssign',
        );
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
