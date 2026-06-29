import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/widgets/create_group_button.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_reorder_screen.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class WorkoutPlanDetailsScreen extends StatefulWidget {
  const WorkoutPlanDetailsScreen({
    super.key,
    required this.planTitle,
    required this.planId,
  });

  final String planTitle;
  final int planId;

  @override
  State<WorkoutPlanDetailsScreen> createState() => _WorkoutPlanDetailsScreenState();
}

class _WorkoutPlanDetailsScreenState extends State<WorkoutPlanDetailsScreen> {
  List<WorkoutExercise> _exercises = [];
  List<WorkoutExercise> _originalExercises = [];
  bool _isLoading = true;
  bool _isSaving = false;
  int? _dayId;

  @override
  void initState() {
    super.initState();
    _fetchPlanDetails();
  }

  Future<void> _fetchPlanDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.workoutPlanDetail(widget.planId),
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(response.data as Map);
        final List<dynamic> days = data['days'] as List<dynamic>? ?? [];
        if (days.isNotEmpty) {
          final firstDay = Map<String, dynamic>.from(days[0] as Map);
          _dayId = firstDay['id'] as int?;
          final List<dynamic> exerciseList = firstDay['exercises'] as List<dynamic>? ?? [];

          final parsedExercises = exerciseList.map((e) {
            final Map<String, dynamic> item = Map<String, dynamic>.from(e as Map);
            final workout = Map<String, dynamic>.from(item['workout_detail'] as Map? ?? {});
            final List<dynamic> rawSets = item['sets'] as List<dynamic>? ?? [];
            final setsList = rawSets.map((s) => Map<String, dynamic>.from(s as Map)).toList();
            return WorkoutExercise(
              id: item['id'].toString(),
              workoutId: item['workout'].toString(),
              name: workout['name'] as String? ?? 'Exercise',
              muscle: workout['primary_muscle_group_name'] as String? ?? 'General',
              equipment: workout['equipment_name'] as String? ?? 'None',
              type: workout['type'] as String? ?? 'Other',
              videoLink: item['video_url'] as String? ?? workout['video_url'] as String? ?? '',
              sets: setsList,
            );
          }).toList();

          setState(() {
            _exercises = List.from(parsedExercises);
            _originalExercises = List.from(parsedExercises);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load plan details');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading plan details: ${e.toString()}');
    }
  }

  Future<void> _saveChanges() async {
    if (_dayId == null) {
      Dialogs.showSnack(msg: 'No plan day linked.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final dio = DioClient().dio;

      // 1. Find deleted exercises
      final List<WorkoutExercise> toDelete = [];
      for (var orig in _originalExercises) {
        if (!_exercises.any((curr) => curr.id == orig.id)) {
          toDelete.add(orig);
        }
      }

      // 2. Perform deletions
      for (var item in toDelete) {
        final exerciseId = int.tryParse(item.id);
        if (exerciseId != null) {
          await dio.delete<dynamic>(
            ApiUris.planDayExerciseDetail(_dayId!, exerciseId),
            options: Options(headers: {'X-Platform': platformSource}),
          );
        }
      }

      // 3. Perform additions and updates
      for (var i = 0; i < _exercises.length; i++) {
        final curr = _exercises[i];
        final isNew = curr.id.startsWith('temp_');
        if (isNew) {
          final workoutId = int.parse(curr.workoutId);
          await dio.post<dynamic>(
            ApiUris.planDayExercises(_dayId!),
            data: {
              'workout': workoutId,
              'video_url': curr.videoLink,
              'order_index': i,
              'sets': curr.sets,
            },
            options: Options(headers: {'X-Platform': platformSource}),
          );
        } else {
          final exerciseId = int.tryParse(curr.id);
          if (exerciseId != null) {
            await dio.put<dynamic>(
              ApiUris.planDayExerciseDetail(_dayId!, exerciseId),
              data: {
                'video_url': curr.videoLink,
                'sets': curr.sets,
              },
              options: Options(headers: {'X-Platform': platformSource}),
            );
          }
        }
      }

      // 4. Perform reorder update
      // Re-fetch or build order index payload for non-new items
      await _fetchPlanDetails();

      final List<Map<String, dynamic>> reorderPayload = [];
      for (var i = 0; i < _exercises.length; i++) {
        reorderPayload.add({
          'id': int.parse(_exercises[i].id),
          'order_index': i,
        });
      }

      if (reorderPayload.isNotEmpty) {
        await dio.post<dynamic>(
          ApiUris.planDayExercisesReorder(_dayId!),
          data: reorderPayload,
          options: Options(headers: {'X-Platform': platformSource}),
        );
      }

      Dialogs.showSnack(msg: 'Changes saved successfully');
      _fetchPlanDetails();
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      Dialogs.showSnack(msg: 'Error saving changes: ${e.toString()}');
    }
  }

  void _showSelectExerciseSheet(BuildContext context) {
    if (_dayId == null) {
      Dialogs.showSnack(msg: 'Cannot add exercise: no plan day found.');
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _SelectExerciseSheetContent(
        existingExercises: _exercises,
        onAddExercise: (WorkoutExercise newEx) {
          setState(() {
            _exercises.add(newEx);
          });
        },
      ),
    );
  }

  void _editExerciseBottomSheet(WorkoutExercise ex) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _EditExerciseBottomSheet(
        exercise: ex,
        onSave: (updatedEx) {
          setState(() {
            final index = _exercises.indexWhere((item) => item.id == ex.id);
            if (index != -1) {
              _exercises[index] = updatedEx;
            }
          });
        },
        onDelete: () {
          setState(() {
            _exercises.removeWhere((item) => item.id == ex.id);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.planTitle,
          style: AppStyles.text20Px.poppins.w600.copyWith(color: Colors.black),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_exercises.length} Exercises',
                style: AppStyles.text14Px.poppins.w400.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _exercises.isEmpty
                    ? Center(
                        child: Text(
                          'No exercises in this plan.\nTap "+" below to add.',
                          textAlign: TextAlign.center,
                          style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                        itemCount: _exercises.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = _exercises[index];
                          return _ExerciseCard(
                            index: index + 1,
                            exercise: item,
                            onEditTap: () => _editExerciseBottomSheet(item),
                          );
                        },
                      ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => _showSelectExerciseSheet(context),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD30000),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () async {
                          final updatedExercises = await Navigator.push<List<WorkoutExercise>>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutPlanReorderScreen(
                                planTitle: widget.planTitle,
                                exercises: _exercises,
                              ),
                            ),
                          );
                          if (updatedExercises != null) {
                            setState(() {
                              _exercises = updatedExercises;
                            });
                          }
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD30000),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.swap_vert, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  _isSaving
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD30000),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(
                            'Save Changes',
                            style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.white),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectExerciseSheetContent extends StatefulWidget {
  final List<WorkoutExercise> existingExercises;
  final Function(WorkoutExercise) onAddExercise;

  const _SelectExerciseSheetContent({
    required this.existingExercises,
    required this.onAddExercise,
  });

  @override
  State<_SelectExerciseSheetContent> createState() => _SelectExerciseSheetContentState();
}

class _SelectExerciseSheetContentState extends State<_SelectExerciseSheetContent> {
  int _selectedTab = 0; // 0 for Library, 1 for You Created
  List<Map<String, dynamic>> _allExercises = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.workoutExercises,
        queryParameters: {
          if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> list = response.data as List<dynamic>;
        setState(() {
          _allExercises = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading exercises: ${e.toString()}');
    }
  }

  List<Map<String, dynamic>> get _filteredExercises {
    return _allExercises.where((item) {
      final isGlobal = item['is_global'] as bool? ?? true;
      if (_selectedTab == 0 && !isGlobal) return false;
      if (_selectedTab == 1 && isGlobal) return false;
      return true;
    }).toList();
  }

  void _showCreateExerciseSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _CreateExerciseBottomSheet(
        onCreated: () {
          _fetchExercises();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredExercises;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Exercise',
                      style: AppStyles.text18Px.poppins.w600.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.borderGrey),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      _searchQuery = val;
                      EasyDebounce.debounce(
                        'exercise-search',
                        const Duration(milliseconds: 300),
                        () => _fetchExercises(),
                      );
                    },
                    decoration: InputDecoration(
                      icon: const Icon(
                        Icons.search,
                        color: AppColors.textGrey,
                      ),
                      hintText: 'Search for exercise',
                      border: InputBorder.none,
                      fillColor: Colors.white,
                      hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? const Color(0xFFF1F1F1) : Colors.white,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(20),
                            ),
                            border: Border.all(color: AppColors.borderGrey),
                          ),
                          child: Center(
                            child: Text(
                              'Library',
                              style: AppStyles.text14Px.poppins.w600.copyWith(color: AppColors.textDark),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? const Color(0xFFF1F1F1) : Colors.white,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(20),
                            ),
                            border: const Border(
                              top: BorderSide(color: AppColors.borderGrey),
                              right: BorderSide(color: AppColors.borderGrey),
                              bottom: BorderSide(color: AppColors.borderGrey),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'You created',
                              style: AppStyles.text14Px.poppins.w600.copyWith(color: AppColors.textDark),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayList.isEmpty
                    ? Center(
                        child: Text(
                          'No exercises found.',
                          style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: displayList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = displayList[index];
                          final idStr = item['id'].toString();
                          final isAdded = widget.existingExercises.any((e) => e.workoutId == idStr);

                          return InkWell(
                            onTap: isAdded
                                ? null
                                : () {
                                    final WorkoutExercise newEx = WorkoutExercise(
                                      id: 'temp_${DateTime.now().millisecondsSinceEpoch}_$index',
                                      workoutId: idStr,
                                      name: item['name'] as String? ?? '',
                                      muscle: item['primary_muscle_group_name'] as String? ?? 'General',
                                      equipment: item['equipment_name'] as String? ?? 'None',
                                      type: item['type'] as String? ?? 'Other',
                                      videoLink: item['video_url'] as String? ?? '',
                                      sets: const [
                                        {'set_number': 1, 'target_reps': 10, 'target_weight': 15.0}
                                      ],
                                    );
                                    widget.onAddExercise(newEx);
                                    Dialogs.showSnack(msg: '${newEx.name} added to plan list');
                                    setState(() {}); // Refresh local added check
                                  },
                            child: _SelectExerciseItem(
                              exercise: WorkoutExercise(
                                id: '',
                                workoutId: idStr,
                                name: item['name'] as String? ?? '',
                                muscle: item['primary_muscle_group_name'] as String? ?? 'General',
                                equipment: item['equipment_name'] as String? ?? 'None',
                                type: item['type'] as String? ?? 'Other',
                                videoLink: item['video_url'] as String? ?? '',
                                sets: const [],
                              ),
                              isAdded: isAdded,
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: CreateGroupButton(
              label: 'Create new Exercise',
              onTap: () => _showCreateExerciseSheet(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateExerciseBottomSheet extends StatefulWidget {
  final VoidCallback onCreated;

  const _CreateExerciseBottomSheet({required this.onCreated});

  @override
  State<_CreateExerciseBottomSheet> createState() => _CreateExerciseBottomSheetState();
}

class _CreateExerciseBottomSheetState extends State<_CreateExerciseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _youtubeController = TextEditingController();

  List<Map<String, dynamic>> _muscles = [];
  List<Map<String, dynamic>> _equipments = [];
  List<Map<String, dynamic>> _types = [];

  int? _selectedMuscleId;
  int? _selectedEquipmentId;
  String? _selectedType;

  bool _isLoadingDropdowns = true;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final dio = DioClient().dio;
      final mRes = await dio.get<dynamic>(ApiUris.muscleGroups);
      final eRes = await dio.get<dynamic>(ApiUris.equipment);
      final tRes = await dio.get<dynamic>(ApiUris.exerciseTypes);

      setState(() {
        _muscles = (mRes.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _equipments = (eRes.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _types = (tRes.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _isLoadingDropdowns = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDropdowns = false;
      });
      Dialogs.showSnack(msg: 'Error loading form options: ${e.toString()}');
    }
  }

  Future<void> _createExercise() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMuscleId == null || _selectedEquipmentId == null || _selectedType == null) {
      Dialogs.showSnack(msg: 'Please fill all dropdown selections');
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.workoutExercises,
        data: {
          'name': _nameController.text.trim(),
          'primary_muscle_group': _selectedMuscleId,
          'equipment': _selectedEquipmentId,
          'type': _selectedType,
          'video_url': _youtubeController.text.trim(),
          'instructions': '',
          'status': true,
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(msg: 'Exercise created successfully');
        widget.onCreated();
        Navigator.pop(context); // Close create form
      } else {
        setState(() {
          _isCreating = false;
        });
        Dialogs.showSnack(msg: 'Failed to create exercise');
      }
    } catch (e) {
      setState(() {
        _isCreating = false;
      });
      Dialogs.showSnack(msg: 'Error creating exercise: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
      child: _isLoadingDropdowns
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Create new Exercise',
                        style: AppStyles.text18Px.poppins.w600.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Workout Name *', style: AppStyles.text12Px.poppins.w600.dark),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Workout name is required' : null,
                            decoration: InputDecoration(
                              hintText: 'Enter workout name',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Muscle *', style: AppStyles.text12Px.poppins.w600.dark),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _selectedMuscleId,
                            hint: const Text('Select the muscle'),
                            items: _muscles.map((m) {
                              return DropdownMenuItem<int>(
                                value: m['id'] as int,
                                child: Text(m['name'] as String),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedMuscleId = val),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Type *', style: AppStyles.text12Px.poppins.w600.dark),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            hint: const Text('Select the type of exercise'),
                            items: _types.map((t) {
                              return DropdownMenuItem<String>(
                                value: t['value'] as String,
                                child: Text(t['label'] as String),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedType = val),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Equipment *', style: AppStyles.text12Px.poppins.w600.dark),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _selectedEquipmentId,
                            hint: const Text('Select the equipment used'),
                            items: _equipments.map((eq) {
                              return DropdownMenuItem<int>(
                                value: eq['id'] as int,
                                child: Text(eq['name'] as String),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedEquipmentId = val),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('YouTube Link', style: AppStyles.text12Px.poppins.w600.dark),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _youtubeController,
                            decoration: InputDecoration(
                              hintText: 'Paste the YouTube link of exercise',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              suffixIcon: const Icon(Icons.link),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: _isCreating
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _createExercise,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD30000),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Create Exercise',
                              style: AppStyles.text16Px.poppins.w600.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.index,
    required this.exercise,
    required this.onEditTap,
  });

  final int index;
  final WorkoutExercise exercise;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                border: Border(right: BorderSide(color: AppColors.borderGrey)),
              ),
              child: Center(
                child: Text(
                  index.toString(),
                  style: AppStyles.text24Px.poppins.w500.copyWith(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: AppStyles.text16Px.poppins.w600.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: onEditTap,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.subtitle,
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                    if (exercise.sets.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: exercise.sets.map((s) {
                          final reps = s['target_reps'] ?? 0;
                          final weight = s['target_weight'] ?? 0.0;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9FA),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.borderGrey.withOpacity(0.6)),
                            ),
                            child: Text(
                              'Set ${s['set_number']}: ${reps}r × ${weight}kg',
                              style: AppStyles.text11Px.poppins.w500.copyWith(color: AppColors.textDark),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 4),
                    if (exercise.videoLink.isNotEmpty)
                      Text(
                        'link: ${exercise.videoLink}',
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: AppColors.textDark,
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutExercise {
  final String id;
  final String workoutId;
  final String name;
  final String muscle;
  final String equipment;
  final String type;
  final String videoLink;
  final List<Map<String, dynamic>> sets;

  const WorkoutExercise({
    required this.id,
    required this.workoutId,
    required this.name,
    required this.muscle,
    required this.equipment,
    required this.type,
    required this.videoLink,
    required this.sets,
  });

  String get subtitle => '$muscle / $equipment / $type';
}

class _SelectExerciseItem extends StatelessWidget {
  const _SelectExerciseItem({required this.exercise, required this.isAdded});

  final WorkoutExercise exercise;
  final bool isAdded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: AppStyles.text16Px.poppins.w600.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.subtitle,
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (isAdded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAEA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Added',
                style: AppStyles.text12Px.poppins.w600.copyWith(
                  color: const Color(0xFFFF3434),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD30000),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Add',
                style: AppStyles.text12Px.poppins.w600.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EditExerciseBottomSheet extends StatefulWidget {
  final WorkoutExercise exercise;
  final Function(WorkoutExercise) onSave;
  final VoidCallback onDelete;

  const _EditExerciseBottomSheet({
    required this.exercise,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_EditExerciseBottomSheet> createState() => _EditExerciseBottomSheetState();
}

class _EditExerciseBottomSheetState extends State<_EditExerciseBottomSheet> {
  late TextEditingController _linkController;
  late List<Map<String, dynamic>> _sets;

  @override
  void initState() {
    super.initState();
    _linkController = TextEditingController(text: widget.exercise.videoLink);
    _sets = List.from(widget.exercise.sets.map((s) => Map<String, dynamic>.from(s)));
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  void _addSet() {
    setState(() {
      int nextSetNum = _sets.isEmpty ? 1 : (_sets.map((s) => (s['set_number'] as int)).reduce((a, b) => a > b ? a : b) + 1);
      double prevWeight = _sets.isEmpty ? 10.0 : double.tryParse(_sets.last['target_weight'].toString()) ?? 10.0;
      int prevReps = _sets.isEmpty ? 10 : int.tryParse(_sets.last['target_reps'].toString()) ?? 10;
      _sets.add({
        'set_number': nextSetNum,
        'target_reps': prevReps,
        'target_weight': prevWeight,
      });
    });
  }

  void _removeSet(int index) {
    setState(() {
      _sets.removeAt(index);
      for (int i = 0; i < _sets.length; i++) {
        _sets[i]['set_number'] = i + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Edit ${widget.exercise.name}',
                  style: AppStyles.text18Px.poppins.w600.copyWith(color: AppColors.textDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Override YouTube Link', style: AppStyles.text14Px.poppins.w600.dark),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _linkController,
                    decoration: InputDecoration(
                      hintText: 'Paste YouTube URL',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      suffixIcon: const Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sets Configuration', style: AppStyles.text16Px.poppins.w600.dark),
                      TextButton.icon(
                        onPressed: _addSet,
                        icon: const Icon(Icons.add, size: 18, color: Color(0xFFD30000)),
                        label: Text('Add Set', style: AppStyles.text14Px.poppins.w600.copyWith(color: const Color(0xFFD30000))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_sets.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No sets added. Click "+ Add Set" above.',
                          style: AppStyles.text14Px.poppins.w400.copyWith(color: AppColors.textGrey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _sets.length,
                      itemBuilder: (context, index) {
                        final s = _sets[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFFF5F5F5),
                                child: Text('${s['set_number']}', style: AppStyles.text12Px.poppins.w600.dark),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue: s['target_reps']?.toString() ?? '',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                  decoration: InputDecoration(
                                    labelText: 'Reps',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onChanged: (val) {
                                    s['target_reps'] = int.tryParse(val) ?? 0;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue: s['target_weight']?.toString() ?? '',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Weight (kg)',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onChanged: (val) {
                                    s['target_weight'] = double.tryParse(val) ?? 0.0;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Color(0xFFD30000)),
                                onPressed: () => _removeSet(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.onDelete();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                  label: const Text('Delete Exercise'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave(WorkoutExercise(
                      id: widget.exercise.id,
                      workoutId: widget.exercise.workoutId,
                      name: widget.exercise.name,
                      muscle: widget.exercise.muscle,
                      equipment: widget.exercise.equipment,
                      type: widget.exercise.type,
                      videoLink: _linkController.text.trim(),
                      sets: _sets,
                    ));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Save', style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
