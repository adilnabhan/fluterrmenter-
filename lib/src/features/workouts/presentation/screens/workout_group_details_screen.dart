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
    super.key,
  });

  final int groupId;
  final String groupTitle;
  final String? source;

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
          if (widget.source != null) 'source': widget.source,
          if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        if (!mounted) return;
        setState(() {
          _plans =
              data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
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
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
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

                                    final planSource = plan['source'] as String? ?? widget.source;
                                    final isOrgPlan = planSource == 'organization' || planSource == 'gym' || plan['is_preset'] == true;
                                    final user = context.read<AppCubit>().state.currentUser;
                                    final isTrainer = user?.userRole == 35;
                                    final canEditOrDelete = !isTrainer || !isOrgPlan;

                                    return _PlanCard(
                                      title: planName,
                                      exerciseCount: exerciseCount,
                                      createdOn: createdOn,
                                      canEditOrDelete: canEditOrDelete,
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder:
                                                (context) =>
                                                    WorkoutPlanDetailsScreen(
                                                      planTitle: planName,
                                                      planId: planId,
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
                                      onRename: () => _renamePlan(planId, planName),
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
                onTap: () {
                  _showCreatePlanSheet(context);
                },
                label: 'Create new plan',
              ),
            ),
          ),
        ],
      ),
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
                style: AppStyles.text14Px.poppins.w500.copyWith(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                nameController.text.trim(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Save',
                style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.white),
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
                style: AppStyles.text14Px.poppins.w500.copyWith(color: Colors.grey),
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
                style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.white),
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
          final msg = (response.data is Map && response.data['message'] != null)
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
          errorMsg = map['detail']?.toString() ??
              map['message']?.toString() ??
              errorMsg;
        }
        Dialogs.showSnack(msg: errorMsg);
      } catch (e) {
        Dialogs.showSnack(msg: 'Error deleting plan: ${e.toString()}');
      }
    }
  }

  Future<void> _createPlan(String planName) async {
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
          'group': widget.groupId,
          'total_weeks': 1,
          'total_days': 1,
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    'Create a Single-Day group',
                    style: AppStyles.text18Px.poppins.w600.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final name = _planName.controller?.text.trim() ?? '';
                          Navigator.pop(context);
                          if (name.isNotEmpty) {
                            _createPlan(name);
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
  });

  final String title;
  final int exerciseCount;
  final String createdOn;
  final VoidCallback onTap;
  final VoidCallback onAssignTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final bool canEditOrDelete;

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
                                style: AppStyles.text14Px.poppins.copyWith(
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
                                style: AppStyles.text14Px.poppins.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                  child: CircleAvatar(
                    backgroundColor: AppColors.grey,
                    radius: 15,
                    child: const Icon(
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
    );
  }
}
