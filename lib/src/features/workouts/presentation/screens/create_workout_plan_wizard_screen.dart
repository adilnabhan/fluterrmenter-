import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_details_screen.dart';

class CreateWorkoutPlanWizardScreen extends StatefulWidget {
  const CreateWorkoutPlanWizardScreen({
    this.preselectedGroupId,
    this.preselectedGroupTitle,
    super.key,
  });

  final int? preselectedGroupId;
  final String? preselectedGroupTitle;

  @override
  State<CreateWorkoutPlanWizardScreen> createState() =>
      _CreateWorkoutPlanWizardScreenState();
}

class _CreateWorkoutPlanWizardScreenState
    extends State<CreateWorkoutPlanWizardScreen> {
  int _currentStep = 0;

  // Step 1 Controllers & State
  final _planNameController = TextEditingController();

  // Step 2 State
  final List<WorkoutExercise> _exercises = [];

  // Step 3 State
  List<Map<String, dynamic>> _groups = [];
  bool _isLoadingGroups = false;
  int? _selectedGroupId;
  String? _selectedGroupName;
  String _groupSearchQuery = '';

  // Submission State
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.preselectedGroupId;
    _selectedGroupName = widget.preselectedGroupTitle;
    _fetchWorkoutGroups();
  }

  @override
  void dispose() {
    _planNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchWorkoutGroups() async {
    setState(() => _isLoadingGroups = true);
    final user = context.read<AppCubit>().state.currentUser;
    final isTrainer = user?.userRole == 35;
    final url = isTrainer ? ApiUris.workoutGroups : ApiUris.gymWorkoutGroups;

    try {
      final response = await DioClient().dio.get<dynamic>(
        url,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && mounted) {
        final List<dynamic> raw =
            (response.data is Map)
                ? (response.data['results'] as List<dynamic>? ?? [])
                : (response.data as List<dynamic>);
        final list = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        list.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));

        setState(() {
          _groups = list;
          _isLoadingGroups = false;
        });
      } else if (mounted) {
        setState(() => _isLoadingGroups = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingGroups = false);
    }
  }

  void _onAddExercise(WorkoutExercise newEx) {
    if (!mounted) return;
    // Ensure default sets if empty
    final finalSets =
        newEx.sets.isNotEmpty
            ? newEx.sets
            : [
              {'set_number': 1, 'reps': 10, 'weight': 0.0, 'rest_time': 60},
              {'set_number': 2, 'reps': 10, 'weight': 0.0, 'rest_time': 60},
              {'set_number': 3, 'reps': 10, 'weight': 0.0, 'rest_time': 60},
            ];

    setState(() {
      _exercises.add(newEx.copyWith(sets: finalSets));
    });
  }

  void _onRemoveExercise(String workoutId) {
    if (!mounted) return;
    setState(() {
      _exercises.removeWhere((item) => item.workoutId == workoutId);
    });
  }

  void _openExerciseSelector() {
    final user = context.read<AppCubit>().state.currentUser;
    final isTrainer = user?.userRole == 35;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (sheetContext) => SelectExerciseSheetContent(
            existingExercises: _exercises,
            hideYouCreated: !isTrainer,
            onAddExercise: _onAddExercise,
            onRemoveExercise: _onRemoveExercise,
          ),
    );
  }

  void _showCreateNewGroupDialog() {
    final groupNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              24,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Create New Workout Group',
                        style: AppStyles.text18Px.poppins.w600.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: context.colors.icon),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a group folder to categorize this workout plan.',
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: groupNameController,
                    autofocus: true,
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: context.colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Group Name *',
                      hintText: 'e.g. Hypertrophy, Upper Body, Core',
                      hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                        color: Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: context.colors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.colors.border),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Group name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          final name = groupNameController.text.trim();
                          Navigator.pop(ctx);
                          await _submitCreateGroup(name);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD30000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Create & Select Group',
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

  Future<void> _submitCreateGroup(String name) async {
    final user = context.read<AppCubit>().state.currentUser;
    final isTrainer = user?.userRole == 35;
    final source = isTrainer ? 'trainer' : 'organization';

    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.workoutGroups,
        data: {
          'name': name,
          'type': 'single_day',
          'source': source,
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map &&
          response.data['id'] != null) {
        final newGroup = Map<String, dynamic>.from(response.data as Map);
        newGroup['plans_count'] = 0;
        newGroup['type'] = 'single_day';

        final newId = newGroup['id'] as int;
        if (mounted) {
          setState(() {
            _groups.insert(0, newGroup);
            _selectedGroupId = newId;
            _selectedGroupName = name;
          });
          Dialogs.showSnack(msg: 'Group "$name" created & selected');
        }
      } else {
        Dialogs.showSnack(msg: 'Failed to create group');
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error creating group: ${e.toString()}');
    }
  }

  Future<void> _submitCompletePlan() async {
    final planName = _planNameController.text.trim();
    if (planName.isEmpty) {
      Dialogs.showSnack(msg: 'Please enter a plan name');
      setState(() => _currentStep = 0);
      return;
    }

    if (_exercises.isEmpty) {
      Dialogs.showSnack(msg: 'Please add at least one exercise to the plan');
      setState(() => _currentStep = 1);
      return;
    }

    if (_selectedGroupId == null) {
      Dialogs.showSnack(msg: 'Please select or create a workout group');
      return;
    }

    setState(() => _isSubmitting = true);

    final user = context.read<AppCubit>().state.currentUser;
    final isTrainer = user?.userRole == 35;
    final source = isTrainer ? 'trainer' : 'organization';
    final dio = DioClient().dio;

    try {
      final payload = {
        'name': planName,
        'title': planName,
        'plan_name': planName,
        'group': _selectedGroupId,
        'source': source,
      };

      final response = await dio.post<dynamic>(
        ApiUris.singleDayWorkouts,
        data: payload,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final int? planId =
            (response.data is Map) ? (response.data['id'] as int?) : null;

        if (planId != null) {
          // Find day ID to attach exercises
          int? dayId;
          if (response.data is Map &&
              response.data['days'] is List &&
              (response.data['days'] as List).isNotEmpty) {
            final firstDay = (response.data['days'] as List).first as Map;
            dayId = int.tryParse(firstDay['id']?.toString() ?? '');
          }

          if (dayId == null) {
            try {
              final detailRes = await dio.get<dynamic>(
                ApiUris.workoutPlanDetail(planId),
                options: Options(headers: {'X-Platform': platformSource}),
              );
              if (detailRes.statusCode == 200 && detailRes.data is Map) {
                final daysList = detailRes.data['days'] as List<dynamic>?;
                if (daysList != null && daysList.isNotEmpty) {
                  dayId = int.tryParse((daysList[0] as Map)['id']?.toString() ?? '');
                }
              }
            } catch (_) {}
          }

          // Attach all selected exercises
          if (dayId != null && _exercises.isNotEmpty) {
            for (int i = 0; i < _exercises.length; i++) {
              final ex = _exercises[i];
              final workoutId = int.tryParse(ex.workoutId);
              if (workoutId != null) {
                try {
                  await dio.post<dynamic>(
                    ApiUris.planDayExercises(dayId),
                    data: {
                      'workout': workoutId,
                      'video_url': ex.videoLink,
                      'order_index': i,
                      'sets': ex.sets,
                    },
                    options: Options(headers: {'X-Platform': platformSource}),
                  );
                } catch (_) {}
              }
            }
          }

          Dialogs.showSnack(msg: 'Workout plan "$planName" created successfully!');

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder:
                    (context) => WorkoutPlanDetailsScreen(
                      planId: planId,
                      planTitle: planName,
                    ),
              ),
            );
          }
          return;
        }
      }

      if (mounted) {
        setState(() => _isSubmitting = false);
        Dialogs.showSnack(msg: 'Failed to create plan');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Dialogs.showSnack(msg: 'Error creating plan: ${e.toString()}');
      }
    }
  }

  void _editExerciseSets(WorkoutExercise ex, int index) {
    int setsCount = ex.sets.length;
    final repsControllers =
        ex.sets
            .map((s) => TextEditingController(text: '${s['reps'] ?? 10}'))
            .toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setSheetState) {
              return Container(
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  MediaQuery.of(ctx).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            ex.name,
                            style: AppStyles.text18Px.poppins.w600.copyWith(
                              color: context.colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: context.colors.icon),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Number of Sets:',
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppColors.primary,
                              onPressed:
                                  setsCount > 1
                                      ? () {
                                        setSheetState(() {
                                          setsCount--;
                                          repsControllers.removeLast();
                                        });
                                      }
                                      : null,
                            ),
                            Text(
                              '$setsCount',
                              style: AppStyles.text16Px.poppins.w700.copyWith(
                                color: context.colors.textPrimary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              color: AppColors.primary,
                              onPressed: () {
                                setSheetState(() {
                                  setsCount++;
                                  repsControllers.add(
                                    TextEditingController(text: '10'),
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: setsCount,
                        itemBuilder: (ctx, sIdx) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text(
                                  'Set ${sIdx + 1}',
                                  style: AppStyles.text14Px.poppins.w600.copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 90,
                                  height: 38,
                                  child: TextField(
                                    controller: repsControllers[sIdx],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      suffixText: 'reps',
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final updatedSets = <Map<String, dynamic>>[];
                          for (int s = 0; s < setsCount; s++) {
                            final reps =
                                int.tryParse(repsControllers[s].text.trim()) ??
                                10;
                            updatedSets.add({
                              'set_number': s + 1,
                              'reps': reps,
                              'weight': 0.0,
                              'rest_time': 60,
                            });
                          }
                          setState(() {
                            _exercises[index] = ex.copyWith(sets: updatedSets);
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD30000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Save Sets',
                          style: AppStyles.text14Px.poppins.w600.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.icon),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Create Workout Plan',
          style: AppStyles.text18Px.poppins.w600.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
      body:
          _isSubmitting
              ? _buildSubmittingState()
              : Column(
                children: [
                  _buildStepperHeader(),
                  Expanded(
                    child: IndexedStack(
                      index: _currentStep,
                      children: [
                        _buildStep1PlanInfo(),
                        _buildStep2AddExercises(),
                        _buildStep3SelectGroup(),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildSubmittingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFFD30000)),
            const SizedBox(height: 24),
            Text(
              'Creating your workout plan...',
              style: AppStyles.text18Px.poppins.w600.copyWith(
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Setting up exercise days and organizing under "${_selectedGroupName ?? 'Selected Group'}"',
              style: AppStyles.text13Px.poppins.w400.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border(bottom: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        children: [
          _buildStepPill(
            stepIndex: 0,
            number: '1',
            title: 'Plan Info',
          ),
          _buildStepDivider(stepIndex: 0),
          _buildStepPill(
            stepIndex: 1,
            number: '2',
            title: 'Exercises',
          ),
          _buildStepDivider(stepIndex: 1),
          _buildStepPill(
            stepIndex: 2,
            number: '3',
            title: 'Group',
          ),
        ],
      ),
    );
  }

  Widget _buildStepPill({
    required int stepIndex,
    required String number,
    required String title,
  }) {
    final isCurrent = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    return InkWell(
      onTap: () {
        if (isDone) {
          setState(() => _currentStep = stepIndex);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isDone
                      ? const Color(0xFF10B981)
                      : isCurrent
                      ? const Color(0xFFD30000)
                      : context.colors.border,
            ),
            child: Center(
              child:
                  isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text(
                        number,
                        style: AppStyles.text12Px.poppins.w600.copyWith(
                          color: isCurrent ? Colors.white : context.colors.textSecondary,
                        ),
                      ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: AppStyles.text12Px.poppins.copyWith(
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
              color:
                  isCurrent
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider({required int stepIndex}) {
    final isDone = _currentStep > stepIndex;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isDone ? const Color(0xFF10B981) : context.colors.border,
      ),
    );
  }

  // ===========================================================================
  // Step 1: Plan Details
  // ===========================================================================
  Widget _buildStep1PlanInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan Setup',
            style: AppStyles.text18Px.poppins.w600.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Give your single-day workout plan a title.',
            style: AppStyles.text12Px.poppins.w400.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          // Plan Name
          Text(
            'Plan Name *',
            style: AppStyles.text14Px.poppins.w500.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _planNameController,
            style: AppStyles.text14Px.poppins.w500.copyWith(
              color: context.colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. Chest & Triceps Hypertrophy',
              hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                color: Colors.grey.shade400,
              ),
              filled: true,
              fillColor: context.colors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD30000), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (_planNameController.text.trim().isEmpty) {
                  Dialogs.showSnack(msg: 'Please enter a plan name to proceed');
                  return;
                }
                setState(() => _currentStep = 1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD30000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue to Add Exercises',
                    style: AppStyles.text16Px.poppins.w600.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Step 2: Add Exercises
  // ===========================================================================
  Widget _buildStep2AddExercises() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_exercises.length} ${_exercises.length == 1 ? 'Exercise' : 'Exercises'}',
                    style: AppStyles.text18Px.poppins.w600.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Add & order exercises for this workout',
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _openExerciseSelector,
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: Text(
                  'Add Exercise',
                  style: AppStyles.text13Px.poppins.w600.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD30000),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child:
              _exercises.isEmpty
                  ? _buildEmptyExercisesView()
                  : ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    itemCount: _exercises.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        var targetIndex = newIndex;
                        if (targetIndex > oldIndex) targetIndex--;
                        final item = _exercises.removeAt(oldIndex);
                        _exercises.insert(targetIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final ex = _exercises[index];
                      return _buildExerciseListItem(
                        key: ValueKey(ex.workoutId),
                        exercise: ex,
                        index: index,
                      );
                    },
                  ),
        ),
        _buildStep2BottomBar(),
      ],
    );
  }

  Widget _buildEmptyExercisesView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFD30000).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 36,
                color: Color(0xFFD30000),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Exercises Added Yet',
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "+ Add Exercise" to choose movements from your library, gym created, or custom exercises.',
              style: AppStyles.text13Px.poppins.w400.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _openExerciseSelector,
              icon: const Icon(Icons.add, color: Color(0xFFD30000)),
              label: Text(
                'Browse Exercises',
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: const Color(0xFFD30000),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD30000)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseListItem({
    required Key key,
    required WorkoutExercise exercise,
    required int index,
  }) {
    final setsSummary =
        exercise.sets.isNotEmpty
            ? '${exercise.sets.length} sets • ${exercise.sets.first['reps'] ?? 10} reps'
            : '3 sets';

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          // Drag handle on left
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.drag_indicator,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ),
          ),
          // Order Pill (without #)
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFD30000).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppStyles.text12Px.poppins.w600.copyWith(
                  color: const Color(0xFFD30000),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Exercise Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: AppStyles.text14Px.poppins.w600.copyWith(
                    color: context.colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (exercise.muscle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    exercise.muscle,
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                // Sets & reps on next row
                InkWell(
                  onTap: () => _editExerciseSets(exercise, index),
                  borderRadius: BorderRadius.circular(6),
                  child: Text(
                    setsSummary,
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                      color: const Color(0xFFD30000),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // More vert popup menu for edit and delete
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: context.colors.textSecondary,
              size: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (action) {
              if (action == 'edit') {
                _editExerciseSets(exercise, index);
              } else if (action == 'delete') {
                _onRemoveExercise(exercise.workoutId);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: context.colors.textPrimary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Edit Sets',
                      style: AppStyles.text13Px.poppins.w500.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Delete',
                      style: AppStyles.text13Px.poppins.w500.copyWith(
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2BottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _currentStep = 0),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Back',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed:
                  _exercises.isNotEmpty
                      ? () => setState(() => _currentStep = 2)
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD30000),
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Next: Choose Group (${_exercises.length})',
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Step 3: Choose Workout Group or Create New Group
  // ===========================================================================
  Widget _buildStep3SelectGroup() {
    final filteredGroups =
        _groups.where((g) {
          final matchesType = (g['type'] ?? 'single_day') == 'single_day';
          if (!matchesType) return false;
          if (_groupSearchQuery.trim().isEmpty) return true;
          final name = (g['name'] ?? '').toString().toLowerCase();
          return name.contains(_groupSearchQuery.toLowerCase());
        }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign to Workout Group',
                style: AppStyles.text18Px.poppins.w600.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select a group folder to categorize this plan, or create a new group.',
                style: AppStyles.text12Px.poppins.w400.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              // Search input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.border),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _groupSearchQuery = val),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, size: 20, color: context.colors.icon),
                    hintText: 'Search workout groups...',
                    hintStyle: AppStyles.text13Px.poppins.w400.copyWith(
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Create New Group Action Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: InkWell(
            onTap: _showCreateNewGroupDialog,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFD30000).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFD30000).withValues(alpha: 0.4),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD30000),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '+ Create New Group',
                          style: AppStyles.text14Px.poppins.w600.copyWith(
                            color: const Color(0xFFD30000),
                          ),
                        ),
                        Text(
                          'Add a brand new folder for this plan',
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFFD30000),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        // Existing Groups List
        Expanded(
          child:
              _isLoadingGroups
                  ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD30000)),
                  )
                  : filteredGroups.isEmpty
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 48,
                            color: context.colors.textSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _groupSearchQuery.isEmpty
                                ? 'No single-day groups found'
                                : 'No matching groups found',
                            style: AppStyles.text14Px.poppins.w500.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap "+ Create New Group" above to create one.',
                            style: AppStyles.text12Px.poppins.w400.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: filteredGroups.length,
                    itemBuilder: (context, index) {
                      final group = filteredGroups[index];
                      final id = group['id'] as int;
                      final name = group['name'] as String? ?? 'Group';
                      final count =
                          group['plans_count'] ?? group['workout_count'] ?? 0;
                      final isSelected = _selectedGroupId == id;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedGroupId = id;
                            _selectedGroupName = name;
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: context.colors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? const Color(0xFFD30000)
                                      : context.colors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.folder_outlined,
                                color:
                                    isSelected
                                        ? const Color(0xFFD30000)
                                        : context.colors.icon,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: AppStyles.text14Px.poppins.w600
                                          .copyWith(
                                            color: context.colors.textPrimary,
                                          ),
                                    ),
                                    Text(
                                      '$count ${count == 1 ? 'plan' : 'plans'}',
                                      style: AppStyles.text12Px.poppins.w400
                                          .copyWith(
                                            color: context.colors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFD30000),
                                  size: 20,
                                )
                              else
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: context.colors.border,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
        // Step 3 Bottom Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.card,
            border: Border(top: BorderSide(color: context.colors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep = 1),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed:
                      _selectedGroupId != null ? _submitCompletePlan : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD30000),
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Create Workout Plan',
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
