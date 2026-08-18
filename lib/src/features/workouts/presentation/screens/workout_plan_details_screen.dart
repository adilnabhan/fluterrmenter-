import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/widgets/create_group_button.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_reorder_screen.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class WorkoutPlanDetailsScreen extends StatefulWidget {
  const WorkoutPlanDetailsScreen({
    super.key,
    required this.planTitle,
    required this.planId,
    this.assignToCustomerId,
    this.isInstantWorkout = false,
  });

  final String planTitle;
  final int planId;
  final int? assignToCustomerId;
  final bool? isInstantWorkout;

  @override
  State<WorkoutPlanDetailsScreen> createState() =>
      _WorkoutPlanDetailsScreenState();
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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.workoutPlanDetail(widget.planId),
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          response.data as Map,
        );
        final List<dynamic> days = data['days'] as List<dynamic>? ?? [];
        if (days.isNotEmpty) {
          final firstDay = Map<String, dynamic>.from(days[0] as Map);
          _dayId = firstDay['id'] as int?;
          final List<dynamic> exerciseList =
              firstDay['exercises'] as List<dynamic>? ?? [];

          final parsedExercises =
              exerciseList.map((e) {
                final Map<String, dynamic> item = Map<String, dynamic>.from(
                  e as Map,
                );
                final workout = Map<String, dynamic>.from(
                  item['workout_detail'] as Map? ?? {},
                );
                final List<dynamic> rawSets =
                    item['sets'] as List<dynamic>? ?? [];
                final setsList =
                    rawSets
                        .map((s) => Map<String, dynamic>.from(s as Map))
                        .toList();
                final int orderIdx =
                    (item['order_index'] as int?) ??
                    (item['order'] as int?) ??
                    0;
                return WorkoutExercise(
                  id: item['id'].toString(),
                  workoutId: item['workout'].toString(),
                  name: workout['name'] as String? ?? 'Exercise',
                  muscle:
                      workout['primary_muscle_group_name'] as String? ??
                      'General',
                  equipment: workout['equipment_name'] as String? ?? 'None',
                  type: workout['type'] as String? ?? 'Other',
                  videoLink:
                      item['video_url'] as String? ??
                      workout['video_url'] as String? ??
                      '',
                  trackBy: workout['track_by'] as String? ?? 'reps',
                  sets: setsList,
                  orderIndex: orderIdx,
                );
              }).toList();

          parsedExercises.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

          if (!mounted) return;
          setState(() {
            _exercises = List.from(parsedExercises);
            _originalExercises = List.from(parsedExercises);
            _isLoading = false;
          });
        } else {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load plan details');
      }
    } catch (e) {
      if (!mounted) return;
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

    if (!mounted) return;
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
          final res = await dio.post<dynamic>(
            ApiUris.planDayExercises(_dayId!),
            data: {
              'workout': workoutId,
              'video_url': curr.videoLink,
              'order_index': i,
              'sets': curr.sets,
            },
            options: Options(headers: {'X-Platform': platformSource}),
          );
          if ((res.statusCode == 200 || res.statusCode == 201) &&
              res.data is Map) {
            final newId = res.data['id'];
            if (newId != null) {
              _exercises[i] = _exercises[i].copyWith(id: newId.toString());
            }
          }
        } else {
          final exerciseId = int.tryParse(curr.id);
          if (exerciseId != null) {
            await dio.put<dynamic>(
              ApiUris.planDayExerciseDetail(_dayId!, exerciseId),
              data: {
                'video_url': curr.videoLink,
                'sets': curr.sets,
                'order_index': i,
                'order': i,
              },
              options: Options(headers: {'X-Platform': platformSource}),
            );
          }
        }
      }

      // 4. Perform reorder update
      final List<Map<String, dynamic>> reorderPayload = [];
      for (var i = 0; i < _exercises.length; i++) {
        final exerciseId = int.tryParse(_exercises[i].id);
        if (exerciseId != null) {
          reorderPayload.add({
            'id': exerciseId,
            'order_index': i,
            'order': i,
          });
        }
      }

      if (reorderPayload.isNotEmpty) {
        await dio.post<dynamic>(
          ApiUris.planDayExercisesReorder(_dayId!),
          data: reorderPayload,
          options: Options(headers: {'X-Platform': platformSource}),
        );
      }

      Dialogs.showSnack(msg: 'Changes saved successfully');
      await _fetchPlanDetails();
    } catch (e) {
      Dialogs.showSnack(msg: 'Error saving changes: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _saveAndAssignWorkout(int customerId) async {
    if (_exercises.isEmpty) {
      Dialogs.showSnack(
        msg: 'Please add at least one exercise before assigning.',
      );
      return;
    }

    if (_dayId == null) {
      Dialogs.showSnack(msg: 'No plan day linked.');
      return;
    }

    if (!mounted) return;
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
          final res = await dio.post<dynamic>(
            ApiUris.planDayExercises(_dayId!),
            data: {
              'workout': workoutId,
              'video_url': curr.videoLink,
              'order_index': i,
              'sets': curr.sets,
            },
            options: Options(headers: {'X-Platform': platformSource}),
          );
          if ((res.statusCode == 200 || res.statusCode == 201) &&
              res.data is Map) {
            final newId = res.data['id'];
            if (newId != null) {
              _exercises[i] = _exercises[i].copyWith(id: newId.toString());
            }
          }
        } else {
          final exerciseId = int.tryParse(curr.id);
          if (exerciseId != null) {
            await dio.put<dynamic>(
              ApiUris.planDayExerciseDetail(_dayId!, exerciseId),
              data: {
                'video_url': curr.videoLink,
                'sets': curr.sets,
                'order_index': i,
                'order': i,
              },
              options: Options(headers: {'X-Platform': platformSource}),
            );
          }
        }
      }

      // 4. Perform reorder update
      final List<Map<String, dynamic>> reorderPayload = [];
      for (var i = 0; i < _exercises.length; i++) {
        final exerciseId = int.tryParse(_exercises[i].id);
        if (exerciseId != null) {
          reorderPayload.add({
            'id': exerciseId,
            'order_index': i,
            'order': i,
          });
        }
      }

      if (reorderPayload.isNotEmpty) {
        await dio.post<dynamic>(
          ApiUris.planDayExercisesReorder(_dayId!),
          data: reorderPayload,
          options: Options(headers: {'X-Platform': platformSource}),
        );
      }

      // 5. Save completed. Refresh state and assign!
      await _fetchPlanDetails();
      setState(() {
        _isSaving = false;
      });

      // trigger assignment prompt
      await _assignWorkout(customerId);

    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
      Dialogs.showSnack(msg: 'Error saving and assigning: ${e.toString()}');
    }
  }

  Future<void> _assignWorkout(int customerId) async {
    final titleController = TextEditingController(text: widget.planTitle);
    final notesController = TextEditingController();
    DateTime? selectedDate;
    final confirmed = await showDialog<bool>(
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

    if (confirmed != true) return;

    final enteredTitle = titleController.text.trim();
    final String finalTitle =
        enteredTitle.isNotEmpty ? enteredTitle : widget.planTitle;

    if (!mounted) return;
    setState(() {
      _isSaving = true;
    });

    try {
      final dio = DioClient().dio;
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
        _isSaving = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(msg: 'Plan assigned successfully!');
        if (widget.isInstantWorkout == true) {
          await _askToSaveAsTemplate();
        }
        // ignore: use_build_context_synchronously
        Navigator.pop(context); // Go back after assign
      } else {
        Dialogs.showSnack(msg: 'Failed to assign plan');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      Dialogs.showSnack(msg: 'Error assigning plan: ${e.toString()}');
    }
  }

  Future<void> _askToSaveAsTemplate() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Save as Template?',
          style: AppStyles.text16Px.poppins.w600,
        ),
        content: const Text(
          'Would you like to save this instant workout as a template for future use?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'No, thanks',
              style: AppStyles.text14Px.poppins.w500.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Yes, Save',
              style: AppStyles.text14Px.poppins.w600.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => _SaveTemplateBottomSheet(
          planId: widget.planId,
          defaultTemplateName: widget.planTitle,
        ),
      );
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
      builder:
          (sheetContext) => SelectExerciseSheetContent(
            existingExercises: _exercises,
            onAddExercise: (WorkoutExercise newEx) {
              if (!mounted) return;
              setState(() {
                _exercises.add(newEx);
              });
            },
            onRemoveExercise: (String workoutId) {
              if (!mounted) return;
              setState(() {
                _exercises.removeWhere((item) => item.workoutId == workoutId);
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
      builder:
          (sheetContext) => _EditExerciseBottomSheet(
            exercise: ex,
            onSave: (updatedEx) {
              if (!mounted) return;
              setState(() {
                final index = _exercises.indexWhere((item) => item.id == ex.id);
                if (index != -1) {
                  _exercises[index] = updatedEx;
                }
              });
            },
            onDelete: () {
              if (!mounted) return;
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
        centerTitle: true,
        leading: const PopButton().center,
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
                  child: Text(
                    widget.planTitle,
                    style: AppStyles.text20Px.poppins.w600.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    '${_exercises.length} Exercises',
                    style: AppStyles.text14Px.poppins.w400.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
                Expanded(
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _exercises.isEmpty
                          ? Center(
                            child: Text(
                              'No exercises in this plan.\nTap "+" below to add.',
                              textAlign: TextAlign.center,
                              style: AppStyles.text14Px.poppins.w400.copyWith(
                                color: AppColors.textGrey,
                              ),
                            ),
                          )
                          : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                            itemCount: _exercises.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 12),
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
              ],
            ),
          ),
          Positioned(
            bottom: 40,
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
                          final updatedExercises =
                              await Navigator.push<List<WorkoutExercise>>(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => WorkoutPlanReorderScreen(
                                        planTitle: widget.planTitle,
                                        exercises: _exercises,
                                      ),
                                ),
                              );
                          if (updatedExercises != null) {
                            if (!mounted) return;
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
                          child: const Icon(
                            Icons.swap_vert,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _isSaving
                      ? const CircularProgressIndicator()
                      : widget.assignToCustomerId != null
                          ? ElevatedButton(
                              onPressed: () => _saveAndAssignWorkout(
                                widget.assignToCustomerId!,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Save & Assign',
                                style: AppStyles.text14Px.poppins.w600.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD30000),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Save Changes',
                                style: AppStyles.text14Px.poppins.w600.copyWith(
                                  color: Colors.white,
                                ),
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

class SelectExerciseSheetContent extends StatefulWidget {
  final List<WorkoutExercise> existingExercises;
  final Function(WorkoutExercise)? onAddExercise;
  final Function(String)? onRemoveExercise;
  final String title;
  final bool isPage;

  const SelectExerciseSheetContent({
    super.key,
    this.existingExercises = const [],
    this.onAddExercise,
    this.onRemoveExercise,
    this.title = 'Select Workout',
    this.isPage = false,
  });

  @override
  State<SelectExerciseSheetContent> createState() =>
      _SelectExerciseSheetContentState();
}

class _TabCache {
  final List<Map<String, dynamic>> exercises;
  final int currentPage;
  final bool hasMore;

  _TabCache({
    required this.exercises,
    required this.currentPage,
    required this.hasMore,
  });
}

class _SelectExerciseSheetContentState
    extends State<SelectExerciseSheetContent> {
  int _selectedTab = 0; // 0 for Gym Created, 1 for You Created, 2 for Library
  List<Map<String, dynamic>> _allExercises = [];
  bool _isLoading = true;
  String _searchQuery = '';

  // Major & Sub Muscle Classification Filter State
  String _selectedMajorMuscle = 'All';
  String _selectedSubMuscle = 'All';

  List<String> _majorMuscles = [
    'All',
    'Abs',
    'Back',
    'Biceps',
    'Chest',
    'Forearms',
    'Legs',
    'Neck',
    'Shoulders',
    'Triceps',
    'Others',
  ];
  Map<String, List<Map<String, dynamic>>> _subMusclesMap = {};

  // Cache for each tab: 0 -> Gym Created, 1 -> You Created, 2 -> Library
  final Map<int, _TabCache> _tabCaches = {};

  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchMuscleClassification();
    _fetchExercises();
  }

  Future<void> _fetchMuscleClassification() async {
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.trainerMuscleClassification,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic>? allMajors = data['all_major_muscles'] as List?;
        final List<dynamic>? majorList = data['major_muscles'] as List?;

        final Map<String, List<Map<String, dynamic>>> subMap = {};
        if (majorList != null) {
          for (var item in majorList) {
            if (item is Map) {
              final name = item['name']?.toString() ?? '';
              final subs = (item['sub_muscles'] as List? ?? [])
                  .map((s) => Map<String, dynamic>.from(s as Map))
                  .toList();
              if (name.isNotEmpty) {
                subMap[name] = subs;
              }
            }
          }
        }

        if (mounted) {
          setState(() {
            if (allMajors != null && allMajors.isNotEmpty) {
              _majorMuscles = allMajors.map((e) => e.toString()).toList();
            }
            _subMusclesMap = subMap;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isFetchingMore && _hasMore) {
        _fetchExercises(isRefresh: false);
      }
    }
  }

  Future<void> _fetchExercises({bool isRefresh = true}) async {
    if (!mounted) return;

    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _allExercises = [];
        _currentPage = 1;
        _hasMore = true;
      });
    } else {
      if (_isFetchingMore || !_hasMore) return;
      setState(() {
        _isFetchingMore = true;
      });
    }

    if (isRefresh &&
        _searchQuery.trim().isEmpty &&
        _selectedMajorMuscle == 'All' &&
        _selectedSubMuscle == 'All' &&
        _tabCaches.containsKey(_selectedTab)) {
      final cache = _tabCaches[_selectedTab]!;
      setState(() {
        _allExercises = List<Map<String, dynamic>>.from(cache.exercises);
        _currentPage = cache.currentPage;
        _hasMore = cache.hasMore;
        _isLoading = false;
      });
      return;
    }

    try {
      final String sourceValue =
          _selectedTab == 0 ? 'gym' : (_selectedTab == 1 ? 'you_created' : 'library');

      final Map<String, dynamic> queryParams = {
        'source': sourceValue,
        'page': _currentPage,
        'page_size': 20,
        if (_selectedMajorMuscle != 'All') 'major_muscle': _selectedMajorMuscle,
        if (_selectedSubMuscle != 'All' && _selectedSubMuscle.isNotEmpty)
          'sub_muscle': _selectedSubMuscle,
        if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
      };

      dynamic data;
      try {
        final response = await DioClient().dio.get<dynamic>(
          ApiUris.workoutExercises,
          queryParameters: queryParams,
          options: Options(headers: {'X-Platform': platformSource}),
        );
        if (response.statusCode == 200) {
          data = response.data;
        }
      } catch (_) {}

      // If Gym Created tab is selected and trainer source=gym returned empty/null, try ApiUris.gymExercises
      final bool isGymTabEmpty = data == null ||
          (data is Map && (data['results'] as List? ?? []).isEmpty) ||
          (data is List && data.isEmpty);

      if (_selectedTab == 0 && isGymTabEmpty) {
        try {
          final gymRes = await DioClient().dio.get<dynamic>(
            ApiUris.gymExercises,
            queryParameters: {
              if (_selectedMajorMuscle != 'All') 'major_muscle': _selectedMajorMuscle,
              if (_selectedSubMuscle != 'All' && _selectedSubMuscle.isNotEmpty)
                'sub_muscle': _selectedSubMuscle,
              if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
            },
            options: Options(headers: {'X-Platform': platformSource}),
          );
          if (gymRes.statusCode == 200 && gymRes.data != null) {
            data = gymRes.data;
          }
        } catch (_) {}
      }

      if (data != null) {
        List<dynamic> resultsList = [];
        bool hasMore = false;

        if (data is Map) {
          resultsList = List<dynamic>.from(data['results'] as List? ?? []);
          final int currentPageVal = data['current_page'] as int? ?? _currentPage;
          final int totalPages = data['total_pages'] as int? ?? 1;
          hasMore = currentPageVal < totalPages;
        } else if (data is List) {
          resultsList = data;
          hasMore = false;
        }

        if (!mounted) return;
        setState(() {
          final newItems = resultsList
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

          if (isRefresh) {
            _allExercises = newItems;
          } else {
            _allExercises.addAll(newItems);
          }

          _hasMore = hasMore;
          _currentPage++;
          _isLoading = false;
          _isFetchingMore = false;

          // Save to cache if query and filters are default
          if (_searchQuery.trim().isEmpty &&
              _selectedMajorMuscle == 'All' &&
              _selectedSubMuscle == 'All') {
            _tabCaches[_selectedTab] = _TabCache(
              exercises: List<Map<String, dynamic>>.from(_allExercises),
              currentPage: _currentPage,
              hasMore: _hasMore,
            );
          }
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
      Dialogs.showSnack(msg: 'Error loading exercises: ${e.toString()}');
    }
  }

  List<Map<String, dynamic>> get _filteredExercises {
    return _allExercises;
  }

  Future<void> _deleteGymExercise(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Exercise'),
            content: const Text(
              'Are you sure you want to delete this custom exercise?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await DioClient().dio.delete<dynamic>(ApiUris.deleteGymExercise(id));
      Dialogs.showSnack(msg: 'Exercise deleted successfully');
      _tabCaches.clear();
      _fetchExercises();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Dialogs.showSnack(msg: 'Failed to delete exercise');
    }
  }

  void _showCreateExerciseSheet(
    BuildContext context, [
    Map<String, dynamic>? exercise,
  ]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (sheetContext) => _CreateExerciseBottomSheet(
            editExercise: exercise,
            isGymExercise: _selectedTab == 0,
            onCreated: () {
              _tabCaches.clear();
              _fetchExercises();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredExercises;

    return Container(
      height: widget.isPage ? double.infinity : MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: widget.isPage
            ? BorderRadius.zero
            : const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.isPage)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: AppStyles.text16Px.poppins.w600.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: context.colors.icon),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                if (!widget.isPage) const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                      icon: const Icon(Icons.search, color: AppColors.textGrey),
                      hintText: 'Search for workout',
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
                        onTap: () {
                          if (!mounted) return;
                          if (_selectedTab != 0) {
                            setState(() => _selectedTab = 0);
                            _fetchExercises();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _selectedTab == 0
                                    ? const Color(0xFFF1F1F1)
                                    : Colors.white,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(20),
                            ),
                            border: Border.all(color: AppColors.borderGrey),
                          ),
                          child: Center(
                            child: Text(
                              'Gym created',
                              style: AppStyles.text14Px.poppins.w500.copyWith(
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!mounted) return;
                          if (_selectedTab != 1) {
                            setState(() => _selectedTab = 1);
                            _fetchExercises();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _selectedTab == 1
                                    ? const Color(0xFFF1F1F1)
                                    : Colors.white,
                            border: const Border(
                              top: BorderSide(color: AppColors.borderGrey),
                              bottom: BorderSide(color: AppColors.borderGrey),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'You created',
                              style: AppStyles.text14Px.poppins.w500.copyWith(
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!mounted) return;
                          if (_selectedTab != 2) {
                            setState(() => _selectedTab = 2);
                            _fetchExercises();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _selectedTab == 2
                                    ? const Color(0xFFF1F1F1)
                                    : Colors.white,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(20),
                            ),
                            border: Border.all(color: AppColors.borderGrey),
                          ),
                          child: Center(
                            child: Text(
                              'Library',
                              style: AppStyles.text14Px.poppins.w500.copyWith(
                                color: AppColors.textDark,
                              ),
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
          // Major Muscle Horizontal Scroll Pills
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _majorMuscles.length,
                itemBuilder: (context, index) {
                  final majorName = _majorMuscles[index];
                  final isSelected =
                      _selectedMajorMuscle.toLowerCase() == majorName.toLowerCase();

                  return GestureDetector(
                    onTap: () {
                      if (_selectedMajorMuscle.toLowerCase() != majorName.toLowerCase()) {
                        setState(() {
                          _selectedMajorMuscle = majorName;
                          _selectedSubMuscle = 'All';
                        });
                        _tabCaches.clear();
                        _fetchExercises();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          majorName,
                          style: AppStyles.text13Px.poppins.w600.copyWith(
                            color: isSelected ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Sub Muscle Horizontal Scroll Pills (if Major Muscle is selected and not 'All')
          if (_selectedMajorMuscle != 'All') ...[
            Builder(
              builder: (context) {
                final subList = _subMusclesMap[_selectedMajorMuscle] ??
                    _subMusclesMap[_majorMuscles.firstWhere(
                      (m) => m.toLowerCase() == _selectedMajorMuscle.toLowerCase(),
                      orElse: () => _selectedMajorMuscle,
                    )] ?? [];
                final List<Map<String, dynamic>> subPills = [
                  {
                    'name': 'All ${_selectedMajorMuscle}',
                    'slug': 'All',
                    'count': null,
                  },
                  ...subList,
                ];

                return Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: SizedBox(
                    height: 34,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: subPills.length,
                      itemBuilder: (context, index) {
                        final subItem = subPills[index];
                        final subName = subItem['name']?.toString() ?? '';
                        final count = subItem['count'] as int?;
                        final bool showCount = _selectedTab == 2;
                        final String displayName =
                            showCount && count != null && count > 0
                                ? '$subName ($count)'
                                : subName;

                        final isSelected =
                            (index == 0 &&
                                (_selectedSubMuscle == 'All' ||
                                    _selectedSubMuscle.isEmpty)) ||
                            (_selectedSubMuscle.toLowerCase() ==
                                subName.toLowerCase());

                        return GestureDetector(
                          onTap: () {
                            final targetSub = index == 0 ? 'All' : subName;
                            if (_selectedSubMuscle.toLowerCase() != targetSub.toLowerCase()) {
                              setState(() {
                                _selectedSubMuscle = targetSub;
                              });
                              _tabCaches.clear();
                              _fetchExercises();
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color(0xFFFFEAEA)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : const Color(0xFFE2E8F0),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                displayName,
                                style: AppStyles.text12Px.poppins.w500.copyWith(
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : AppColors.textDark,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : displayList.isEmpty
                    ? Center(
                      child: Text(
                        'No exercises found.',
                        style: AppStyles.text14Px.poppins.w400.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    )
                    : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: displayList.length + (_isFetchingMore ? 1 : 0),
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        if (index == displayList.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final item = displayList[index];
                        final idStr = item['id'].toString();
                        final isAdded = widget.existingExercises.any(
                          (e) => e.workoutId == idStr,
                        );

                        return InkWell(
                          onTap: () {
                            final exName = item['name'] as String? ?? 'Exercise';
                            if (isAdded) {
                              if (widget.onRemoveExercise != null) {
                                widget.onRemoveExercise!(idStr);
                              } else {
                                widget.existingExercises.removeWhere((e) => e.workoutId == idStr);
                              }
                              Dialogs.showSnack(
                                msg: '$exName removed from plan',
                              );
                            } else {
                              final WorkoutExercise newEx = WorkoutExercise(
                                id: 'temp_${DateTime.now().millisecondsSinceEpoch}_$index',
                                workoutId: idStr,
                                name: exName,
                                muscle: item['primary_muscle_group_name'] as String? ?? 'General',
                                equipment: item['equipment_name'] as String? ?? 'None',
                                type: item['type'] as String? ?? 'Other',
                                videoLink: item['video_url'] as String? ?? '',
                                trackBy: item['track_by']?.toString().toLowerCase() ?? 'reps',
                                sets: const [
                                  {'set_number': 1},
                                ],
                              );
                              widget.onAddExercise?.call(newEx);
                              Dialogs.showSnack(
                                msg: '$exName added to plan list',
                              );
                            }
                            if (!mounted) return;
                            setState(() {});
                          },
                          child: _SelectExerciseItem(
                            exercise: WorkoutExercise(
                              id: '',
                              workoutId: idStr,
                              name: item['name'] as String? ?? '',
                              muscle:
                                  item['primary_muscle_group_name']
                                      as String? ??
                                  'General',
                              equipment:
                                  item['equipment_name'] as String? ?? 'None',
                              type: item['type'] as String? ?? 'Other',
                              videoLink: item['video_url'] as String? ?? '',
                              trackBy:
                                  item['track_by']?.toString().toLowerCase() ??
                                  'reps',
                              sets: const [],
                            ),
                            isAdded: isAdded,
                            onEdit: null,
                            onDelete: null,
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
  final Map<String, dynamic>? editExercise;
  final bool isGymExercise;

  const _CreateExerciseBottomSheet({
    required this.onCreated,
    this.editExercise,
    this.isGymExercise = false,
  });

  @override
  State<_CreateExerciseBottomSheet> createState() =>
      _CreateExerciseBottomSheetState();
}

class _CreateExerciseBottomSheetState
    extends State<_CreateExerciseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _youtubeController = TextEditingController();

  List<Map<String, dynamic>> _muscles = [];
  List<Map<String, dynamic>> _equipments = [];
  List<Map<String, dynamic>> _types = [];

  int? _selectedMuscleId;
  List<int> _selectedSecondaryMuscleIds = [];
  int? _selectedEquipmentId;
  String? _selectedType;
  String? _selectedTrackBy;

  bool _isLoadingDropdowns = true;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    if (widget.editExercise != null) {
      _nameController.text = widget.editExercise!['name']?.toString() ?? '';
      _youtubeController.text =
          widget.editExercise!['video_url']?.toString() ??
          widget.editExercise!['youtube_link']?.toString() ??
          '';

      final muscle =
          widget.editExercise!['primary_muscle_group_id'] ??
          widget.editExercise!['primary_muscle_group'] ??
          widget.editExercise!['muscle_group_id'];
      if (muscle != null) _selectedMuscleId = int.tryParse(muscle.toString());

      final equipment =
          widget.editExercise!['equipment_id'] ??
          widget.editExercise!['equipment'];
      if (equipment != null)
        _selectedEquipmentId = int.tryParse(equipment.toString());

      _selectedType =
          widget.editExercise!['exercise_type_id']?.toString() ??
          widget.editExercise!['type']?.toString();
      _selectedTrackBy = widget.editExercise!['track_by']?.toString();
    }
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final dio = DioClient().dio;
      final mRes = await dio.get<dynamic>(ApiUris.muscleGroups);
      final eRes = await dio.get<dynamic>(ApiUris.equipment);
      final tRes = await dio.get<dynamic>(ApiUris.exerciseTypes);

      if (!mounted) return;
      setState(() {
        _muscles =
            (mRes.data as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
        _equipments =
            (eRes.data as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
        _types =
            (tRes.data as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
        _isLoadingDropdowns = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingDropdowns = false;
      });
      Dialogs.showSnack(msg: 'Error loading form options: ${e.toString()}');
    }
  }

  Future<void> _createExercise() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMuscleId == null ||
        _selectedEquipmentId == null ||
        _selectedType == null) {
      Dialogs.showSnack(msg: 'Please fill all dropdown selections');
      return;
    }

    if (!mounted) return;
    setState(() {
      _isCreating = true;
    });

    try {
      final isEditingGym = widget.editExercise != null && widget.isGymExercise;
      final data = {
        'name': _nameController.text.trim(),
        'primary_muscle_group': _selectedMuscleId,
        'secondary_muscle_group': _selectedSecondaryMuscleIds,
        'equipment': _selectedEquipmentId,
        'type': _selectedType,
        'track_by': _selectedTrackBy,
        'video_url': _youtubeController.text.trim(),
        'instructions': '',
        'status': true,
      };

      final response =
          isEditingGym
              ? await DioClient().dio.put<dynamic>(
                ApiUris.editGymExercise(widget.editExercise!['id'] as int),
                data: data,
                options: Options(headers: {'X-Platform': platformSource}),
              )
              : await DioClient().dio.post<dynamic>(
                ApiUris.workoutExercises,
                data: data,
                options: Options(headers: {'X-Platform': platformSource}),
              );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(
          msg:
              isEditingGym
                  ? 'Exercise updated successfully'
                  : 'Exercise created successfully',
        );
        widget.onCreated();
        Navigator.pop(context); // Close create form
      } else {
        if (!mounted) return;
        setState(() {
          _isCreating = false;
        });
        Dialogs.showSnack(
          msg:
              isEditingGym
                  ? 'Failed to update exercise'
                  : 'Failed to create exercise',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCreating = false;
      });
      Dialogs.showSnack(msg: 'Error creating exercise: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> _showAddNewDialog(
    String title,
    String endpoint,
  ) async {
    final controller = TextEditingController();
    bool isSaving = false;
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add New $title'),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter name',
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSaving ? null : () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                      isSaving
                          ? null
                          : () async {
                            final name = controller.text.trim();
                            if (name.isEmpty) return;
                            setDialogState(() => isSaving = true);
                            try {
                              final res = await DioClient().dio.post<dynamic>(
                                endpoint,
                                data: {'name': name},
                              );
                              if (res.statusCode == 200 ||
                                  res.statusCode == 201) {
                                Navigator.pop(context, res.data);
                              } else {
                                Dialogs.showSnack(msg: 'Failed to create');
                                setDialogState(() => isSaving = false);
                              }
                            } catch (e) {
                              Dialogs.showSnack(msg: 'Error: ${e.toString()}');
                              setDialogState(() => isSaving = false);
                            }
                          },
                  child:
                      isSaving
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
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
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      child:
          _isLoadingDropdowns
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
                          style: AppStyles.text16Px.poppins.w600.copyWith(
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
                            Text(
                              'Workout Name *',
                              style: AppStyles.text14Px.poppins.w500.dark,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              validator:
                                  (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Workout name is required'
                                          : null,
                              decoration: InputDecoration(
                                hintText: 'Enter workout name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Muscle *',
                              style: AppStyles.text14Px.poppins.w500.dark,
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              menuMaxHeight: 300,
                              value: _selectedMuscleId,
                              hint: const Text('Select the muscle'),
                              items: [
                                ..._muscles.map((m) {
                                  return DropdownMenuItem<int>(
                                    value: m['id'] as int,
                                    child: Text(m['name'] as String),
                                  );
                                }),
                                const DropdownMenuItem<int>(
                                  value: -1,
                                  child: Text(
                                    '+ Add New Muscle...',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (val) async {
                                if (val == -1) {
                                  final newMuscle = await _showAddNewDialog(
                                    'Muscle Group',
                                    ApiUris.muscleGroups,
                                  );
                                  if (newMuscle != null && mounted) {
                                    setState(() {
                                      _muscles.add(newMuscle);
                                      _selectedMuscleId =
                                          newMuscle['id'] as int;
                                    });
                                  } else {
                                    setState(() {}); // Reset if cancelled
                                  }
                                } else {
                                  if (!mounted) return;
                                  setState(() => _selectedMuscleId = val);
                                }
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Secondary Muscle',
                              style: AppStyles.text14Px.poppins.w500.dark,
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (ctx) {
                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        return Container(
                                          height:
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                              0.5,
                                          padding: const EdgeInsets.all(20),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(24),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Select Secondary Muscles',
                                                style:
                                                    AppStyles
                                                        .text16Px
                                                        .poppins
                                                        .w600
                                                        .dark,
                                              ),
                                              const SizedBox(height: 16),
                                              Expanded(
                                                child: ListView.builder(
                                                  itemCount: _muscles.length,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    final m = _muscles[index];
                                                    final mId = m['id'] as int;
                                                    final isSelected =
                                                        _selectedSecondaryMuscleIds
                                                            .contains(mId);
                                                    return CheckboxListTile(
                                                      title: Text(
                                                        m['name'] as String,
                                                        style:
                                                            AppStyles
                                                                .text14Px
                                                                .poppins
                                                                .w500
                                                                .dark,
                                                      ),
                                                      value: isSelected,
                                                      activeColor:
                                                          AppColors.primary,
                                                      onChanged: (val) {
                                                        setModalState(() {
                                                          if (val == true) {
                                                            _selectedSecondaryMuscleIds
                                                                .add(mId);
                                                          } else {
                                                            _selectedSecondaryMuscleIds
                                                                .remove(mId);
                                                          }
                                                        });
                                                        setState(
                                                          () {},
                                                        ); // Update parent UI
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.primary,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 16,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Done',
                                                    style: AppStyles
                                                        .text14Px
                                                        .poppins
                                                        .w600
                                                        .copyWith(
                                                          color: Colors.white,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ), // Match the standard Dropdown border
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedSecondaryMuscleIds.isEmpty
                                            ? 'Select the secondary muscles'
                                            : _selectedSecondaryMuscleIds
                                                .map(
                                                  (id) =>
                                                      _muscles.firstWhere(
                                                        (m) => m['id'] == id,
                                                        orElse:
                                                            () => {'name': ''},
                                                      )['name'],
                                                )
                                                .join(', '),
                                        style: AppStyles.text14Px.poppins.w400
                                            .copyWith(
                                              color:
                                                  _selectedSecondaryMuscleIds
                                                          .isEmpty
                                                      ? Colors.grey.shade600
                                                      : AppColors.textDark,
                                            ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Type *',
                              style: AppStyles.text14Px.poppins.w500.dark,
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              menuMaxHeight: 300,
                              value: _selectedType,
                              hint: const Text('Select the type of exercise'),
                              items:
                                  _types.map((t) {
                                    return DropdownMenuItem<String>(
                                      value: t['value'] as String,
                                      child: Text(t['label'] as String),
                                    );
                                  }).toList(),
                              onChanged: (val) {
                                if (!mounted) return;
                                setState(() => _selectedType = val);
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Track By *',
                              style: AppStyles.text14Px.poppins.w500.dark,
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              menuMaxHeight: 300,
                              value: _selectedTrackBy,
                              hint: const Text('Select track by'),
                              items:
                                  ['Reps', 'Time', 'Distance'].map((t) {
                                    return DropdownMenuItem<String>(
                                      value: t.toLowerCase(),
                                      child: Text(t),
                                    );
                                  }).toList(),
                              onChanged: (val) {
                                if (!mounted) return;
                                setState(() => _selectedTrackBy = val);
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Equipment *',
                              style: AppStyles.text14Px.poppins.w500.dark,
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              menuMaxHeight: 300,
                              value: _selectedEquipmentId,
                              hint: const Text('Select the equipment used'),
                              items: [
                                ..._equipments.map((eq) {
                                  return DropdownMenuItem<int>(
                                    value: eq['id'] as int,
                                    child: Text(eq['name'] as String),
                                  );
                                }),
                                const DropdownMenuItem<int>(
                                  value: -1,
                                  child: Text(
                                    '+ Add New Equipment...',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (val) async {
                                if (val == -1) {
                                  final newEquipment = await _showAddNewDialog(
                                    'Equipment',
                                    ApiUris.equipment,
                                  );
                                  if (newEquipment != null && mounted) {
                                    setState(() {
                                      _equipments.add(newEquipment);
                                      _selectedEquipmentId =
                                          newEquipment['id'] as int;
                                    });
                                  } else {
                                    setState(() {}); // Reset if cancelled
                                  }
                                } else {
                                  if (!mounted) return;
                                  setState(() => _selectedEquipmentId = val);
                                }
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'YouTube Link',
                              style: AppStyles.text14Px.poppins.w500.dark,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _youtubeController,
                              decoration: InputDecoration(
                                hintText: 'Paste the YouTube link of exercise',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
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
                      child:
                          _isCreating
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                onPressed: _createExercise,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD30000),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Create Exercise',
                                  style: AppStyles.text16Px.poppins.w600
                                      .copyWith(color: Colors.white),
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
        border: Border.all(color: AppColors.borderGrey, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
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
                border: Border(
                  right: BorderSide(color: AppColors.borderGrey, width: 1.5),
                ),
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
                        children:
                            exercise.sets.map((s) {
                              final reps = s['target_reps']?.toString() ?? '-';
                              final weight =
                                  s['target_weight']?.toString() ?? '-';
                              String unit = 'r';
                              if (exercise.trackBy == 'time') {
                                unit = 's';
                              } else if (exercise.trackBy == 'distance') {
                                unit = 'm';
                              }
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F9FA),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.borderGrey.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Set ${s['set_number']}: $reps$unit × ${weight}kg',
                                  style: AppStyles.text12Px.poppins.w500
                                      .copyWith(color: AppColors.textDark),
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
  final String trackBy;
  final List<Map<String, dynamic>> sets;
  final int orderIndex;

  const WorkoutExercise({
    required this.id,
    required this.workoutId,
    required this.name,
    required this.muscle,
    required this.equipment,
    required this.type,
    required this.videoLink,
    this.trackBy = 'reps',
    required this.sets,
    this.orderIndex = 0,
  });

  WorkoutExercise copyWith({
    String? id,
    String? workoutId,
    String? name,
    String? muscle,
    String? equipment,
    String? type,
    String? videoLink,
    String? trackBy,
    List<Map<String, dynamic>>? sets,
    int? orderIndex,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      name: name ?? this.name,
      muscle: muscle ?? this.muscle,
      equipment: equipment ?? this.equipment,
      type: type ?? this.type,
      videoLink: videoLink ?? this.videoLink,
      trackBy: trackBy ?? this.trackBy,
      sets: sets ?? this.sets,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  String get subtitle => '$muscle / $equipment / $type';
}

class _SelectExerciseItem extends StatelessWidget {
  const _SelectExerciseItem({
    required this.exercise,
    required this.isAdded,
    this.onEdit,
    this.onDelete,
  });

  final WorkoutExercise exercise;
  final bool isAdded;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAdded ? const Color(0xFFFF3434) : AppColors.borderGrey,
        ),
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
                border: Border.all(color: const Color(0xFFFF3434)),
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
          if (onEdit != null || onDelete != null) ...[
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              onSelected: (value) {
                if (value == 'edit') onEdit?.call();
                if (value == 'delete') onDelete?.call();
              },
              itemBuilder:
                  (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EditExerciseBottomSheet extends StatefulWidget {
  final WorkoutExercise exercise;
  final void Function(WorkoutExercise) onSave;
  final VoidCallback onDelete;

  const _EditExerciseBottomSheet({
    required this.exercise,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_EditExerciseBottomSheet> createState() =>
      _EditExerciseBottomSheetState();
}

class _EditExerciseBottomSheetState extends State<_EditExerciseBottomSheet> {
  late TextEditingController _linkController;
  late List<Map<String, dynamic>> _sets;

  @override
  void initState() {
    super.initState();
    _linkController = TextEditingController(text: widget.exercise.videoLink);
    _sets = List.from(
      widget.exercise.sets.map((s) => Map<String, dynamic>.from(s)),
    );
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  void _addSet() {
    if (!mounted) return;
    setState(() {
      int nextSetNum =
          _sets.isEmpty
              ? 1
              : (_sets
                      .map((s) => (s['set_number'] as int))
                      .reduce((a, b) => a > b ? a : b) +
                  1);
      double? prevWeight =
          _sets.isEmpty
              ? null
              : double.tryParse(_sets.last['target_weight'].toString());
      int? prevReps =
          _sets.isEmpty
              ? null
              : int.tryParse(_sets.last['target_reps'].toString());
      _sets.add({
        'set_number': nextSetNum,
        if (prevReps != null) 'target_reps': prevReps,
        if (prevWeight != null) 'target_weight': prevWeight,
      });
    });
  }

  void _removeSet(int index) {
    if (!mounted) return;
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
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Edit ${widget.exercise.name}',
                  style: AppStyles.text18Px.poppins.w600.copyWith(
                    color: AppColors.textDark,
                  ),
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
                  Text(
                    'Override YouTube Link',
                    style: AppStyles.text14Px.poppins.w600.dark,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _linkController,
                    decoration: InputDecoration(
                      hintText: 'Paste YouTube URL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: const Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sets Configuration',
                        style: AppStyles.text16Px.poppins.w600.dark,
                      ),
                      TextButton.icon(
                        onPressed: _addSet,
                        icon: const Icon(
                          Icons.add,
                          size: 18,
                          color: Color(0xFFD30000),
                        ),
                        label: Text(
                          'Add Set',
                          style: AppStyles.text14Px.poppins.w600.copyWith(
                            color: const Color(0xFFD30000),
                          ),
                        ),
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
                          style: AppStyles.text14Px.poppins.w400.copyWith(
                            color: AppColors.textGrey,
                          ),
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
                                child: Text(
                                  '${s['set_number']}',
                                  style: AppStyles.text12Px.poppins.w600.dark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue:
                                      s['target_reps']?.toString() ?? '',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: false,
                                      ),
                                  decoration: InputDecoration(
                                    labelText:
                                        widget.exercise.trackBy == 'time'
                                            ? 'Time (sec)'
                                            : (widget.exercise.trackBy ==
                                                    'distance'
                                                ? 'Distance'
                                                : 'Reps'),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    s['target_reps'] = int.tryParse(val);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue:
                                      s['target_weight']?.toString() ?? '',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  onChanged:
                                      (val) =>
                                          s['target_weight'] = double.tryParse(
                                            val,
                                          ),
                                  decoration: InputDecoration(
                                    labelText: 'Weight (kg)',
                                    filled: true,
                                    fillColor: const Color(0xFFF5F5F5),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFD30000),
                                ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave(
                      WorkoutExercise(
                        id: widget.exercise.id,
                        workoutId: widget.exercise.workoutId,
                        name: widget.exercise.name,
                        muscle: widget.exercise.muscle,
                        equipment: widget.exercise.equipment,
                        type: widget.exercise.type,
                        videoLink: _linkController.text.trim(),
                        trackBy: widget.exercise.trackBy,
                        sets: _sets,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SaveTemplateBottomSheet extends StatefulWidget {
  final int planId;
  final String defaultTemplateName;

  const _SaveTemplateBottomSheet({
    required this.planId,
    required this.defaultTemplateName,
  });

  @override
  State<_SaveTemplateBottomSheet> createState() => _SaveTemplateBottomSheetState();
}

class _SaveTemplateBottomSheetState extends State<_SaveTemplateBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _templateNameController;
  late final TextEditingController _newGroupNameController;

  bool _isNewGroup = false;
  String _groupType = 'single_day'; // 'single_day' or 'multi_day'

  List<Map<String, dynamic>> _groups = [];
  int? _selectedGroupId;
  bool _isLoadingGroups = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _templateNameController = TextEditingController(text: widget.defaultTemplateName);
    _newGroupNameController = TextEditingController();
    _fetchGroups();
  }

  @override
  void dispose() {
    _templateNameController.dispose();
    _newGroupNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchGroups() async {
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.workoutGroups,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data =
            (response.data is Map)
                ? (response.data['results'] as List<dynamic>? ?? [])
                : (response.data as List<dynamic>);
        setState(() {
          _groups = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          if (_groups.isNotEmpty) {
            _selectedGroupId = _groups.first['id'] as int;
          } else {
            _isNewGroup = true;
          }
          _isLoadingGroups = false;
        });
      } else {
        setState(() {
          _isLoadingGroups = false;
          _isNewGroup = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingGroups = false;
        _isNewGroup = true;
      });
    }
  }

  Future<void> _saveAsTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isNewGroup && _selectedGroupId == null) {
      Dialogs.showSnack(msg: 'Please select a workout group');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final Map<String, dynamic> payload = {
        'template_name': _templateNameController.text.trim(),
      };

      if (_isNewGroup) {
        payload['group_name'] = _newGroupNameController.text.trim();
        payload['group_type'] = _groupType;
      } else {
        payload['group_id'] = _selectedGroupId;
      }

      final response = await DioClient().dio.post<dynamic>(
        ApiUris.saveWorkoutPlanAsTemplate(widget.planId),
        data: payload,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(msg: 'Saved as template successfully!');
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        Dialogs.showSnack(msg: 'Failed to save as template');
        setState(() => _isSaving = false);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      Dialogs.showSnack(msg: 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Save as Template',
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
              Text(
                'Template Name',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _templateNameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Chest & Triceps Blast',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              Text(
                'Workout Group',
                style: AppStyles.text14Px.poppins.w500.copyWith(
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Existing Group'),
                      selected: !_isNewGroup,
                      onSelected: _groups.isEmpty
                          ? null
                          : (selected) {
                              setState(() {
                                _isNewGroup = false;
                              });
                            },
                      selectedColor: AppColors.primary.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: !_isNewGroup
                            ? AppColors.primary
                            : AppColors.textGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Create New Group'),
                      selected: _isNewGroup,
                      onSelected: (selected) {
                        setState(() {
                          _isNewGroup = true;
                        });
                      },
                      selectedColor: AppColors.primary.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: _isNewGroup
                            ? AppColors.primary
                            : AppColors.textGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!_isNewGroup) ...[
                if (_isLoadingGroups)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  DropdownButtonFormField<int>(
                    value: _selectedGroupId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    items: _groups.map((group) {
                      return DropdownMenuItem<int>(
                        value: group['id'] as int,
                        child: Text(group['name'] as String? ?? 'Unnamed Group'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedGroupId = val;
                      });
                    },
                  ),
              ] else ...[
                Text(
                  'Group Name',
                  style: AppStyles.text12Px.poppins.w500.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newGroupNameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Hypertrophy Push Days',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Text(
                  'Group Type',
                  style: AppStyles.text12Px.poppins.w500.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Radio<String>(
                      value: 'single_day',
                      groupValue: _groupType,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _groupType = val!;
                        });
                      },
                    ),
                    Text(
                      'Single Day',
                      style: AppStyles.text14Px.poppins.w500.dark,
                    ),
                    const SizedBox(width: 24),
                    Radio<String>(
                      value: 'multi_day',
                      groupValue: _groupType,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _groupType = val!;
                        });
                      },
                    ),
                    Text(
                      'Multi Day',
                      style: AppStyles.text14Px.poppins.w500.dark,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: _isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _saveAsTemplate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Save Template',
                          style: AppStyles.text14Px.poppins.w600.copyWith(
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
