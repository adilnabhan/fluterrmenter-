import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/widgets/create_group_button.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_reorder_screen.dart';

class WorkoutPlanDetailsScreen extends StatefulWidget {
  const WorkoutPlanDetailsScreen({
    super.key,
    required this.planTitle,
    this.exercises = _defaultExercises,
    this.libraryExercises = _defaultLibraryExercises,
  });

  final String planTitle;
  final List<WorkoutExercise> exercises;
  final List<WorkoutExercise> libraryExercises;

  @override
  State<WorkoutPlanDetailsScreen> createState() =>
      _WorkoutPlanDetailsScreenState();
}

class _WorkoutPlanDetailsScreenState extends State<WorkoutPlanDetailsScreen> {
  late List<WorkoutExercise> exercises;

  @override
  void initState() {
    super.initState();
    exercises = widget.exercises;
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
                '${exercises.length} Exercises',
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
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              itemCount: exercises.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _ExerciseCard(
                  index: index + 1,
                  exercise: exercises[index],
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
                mainAxisAlignment: MainAxisAlignment.center,
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
                                    exercises: exercises,
                                  ),
                            ),
                          );
                      if (updatedExercises != null) {
                        setState(() {
                          exercises = updatedExercises;
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
            ),
          ),
        ],
      ),
    );
  }

  void _showSelectExerciseSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
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
                      Text(
                        'Select Exercise',
                        style: AppStyles.text18Px.poppins.w600.copyWith(
                          color: AppColors.textDark,
                        ),
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
                          decoration: InputDecoration(
                            icon: const Icon(
                              Icons.search,
                              color: AppColors.textGrey,
                            ),
                            hintText: 'Search for added exercise',
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(20),
                                ),
                                border: Border.all(color: AppColors.borderGrey),
                              ),
                              child: Center(
                                child: Text(
                                  'Library',
                                  style: AppStyles.text14Px.poppins.w600
                                      .copyWith(color: AppColors.textDark),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FB),
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(20),
                                ),
                                border: const Border(
                                  top: BorderSide(color: AppColors.borderGrey),
                                  right: BorderSide(
                                    color: AppColors.borderGrey,
                                  ),
                                  bottom: BorderSide(
                                    color: AppColors.borderGrey,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'You created',
                                  style: AppStyles.text14Px.poppins.w500
                                      .copyWith(color: AppColors.textGrey),
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
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: widget.libraryExercises.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final exercise = widget.libraryExercises[index];
                      // Check if exercise is already in the plan
                      final isAdded = exercises.any((e) => e.id == exercise.id);
                      return _SelectExerciseItem(
                        exercise: exercise,
                        isAdded: isAdded,
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
          ),
    );
  }

  void _showCreateExerciseSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateExerciseBottomSheet(),
    );
  }
}

class _CreateExerciseBottomSheet extends StatefulWidget {
  const _CreateExerciseBottomSheet();

  @override
  State<_CreateExerciseBottomSheet> createState() => _CreateExerciseBottomSheetState();
}

class _CreateExerciseBottomSheetState extends State<_CreateExerciseBottomSheet> {
  late final GlobalKey<FormState> _formKey;
  late final FieldData<dynamic> _exerciseName;
  late final FieldData<String> _muscle;
  late final FieldData<String> _type;
  late final FieldData<String> _equipment;
  late final FieldData<dynamic> _youtubeLink;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _exerciseName = FieldData(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Exercise Name',
      requiredLabel: true,
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'Exercise name is required';
        }
        return null;
      },
      onSubmitted: (value) {
        if (mounted) {
          _muscle.focusNode?.requestFocus();
        }
      },
      controller: TextEditingController(),
      focusNode: FocusNode(),
      decoration: InputDecoration(
        hintText: 'Enter exercise name',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );
    _muscle = FieldData<String>(
      type: FieldType.checkbox,
      items: [],
      textInputAction: TextInputAction.next,
      label: 'Muscle',
      selectedValues: ValueNotifier([]),
      controller: TextEditingController(),
      focusNode: FocusNode(),
      decoration: InputDecoration(
        hintText: 'Select the muscle',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );
    _type = FieldData<String>(
      type: FieldType.checkbox,
      items: [],
      textInputAction: TextInputAction.next,
      label: 'Type',
      selectedValues: ValueNotifier([]),
      controller: TextEditingController(),
      focusNode: FocusNode(),
      decoration: InputDecoration(
        hintText: 'Select the type of exercise',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );
    _equipment = FieldData<String>(
      type: FieldType.checkbox,
      items: [],
      textInputAction: TextInputAction.next,
      label: 'Equipment',
      selectedValues: ValueNotifier([]),
      controller: TextEditingController(),
      focusNode: FocusNode(),
      decoration: InputDecoration(
        hintText: 'Select the equipment used',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );
    _youtubeLink = FieldData(
      type: FieldType.word,
      textInputAction: TextInputAction.done,
      label: 'Youtube Link',
      controller: TextEditingController(),
      focusNode: FocusNode(),
      decoration: InputDecoration(
        hintText: 'Paste the youtube link of exercis..',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
        suffixIcon: const Icon(Icons.content_paste, color: AppColors.textGrey),
      ),
    );
  }

  @override
  void dispose() {
    _exerciseName.controller?.dispose();
    _exerciseName.focusNode?.dispose();
    _muscle.controller?.dispose();
    _muscle.focusNode?.dispose();
    _type.controller?.dispose();
    _type.focusNode?.dispose();
    _equipment.controller?.dispose();
    _equipment.focusNode?.dispose();
    _youtubeLink.controller?.dispose();
    _youtubeLink.focusNode?.dispose();
    super.dispose();
    // Dispose selectedValues after super.dispose() to ensure CheckboxField finishes disposing first
    _muscle.selectedValues?.dispose();
    _type.selectedValues?.dispose();
    _equipment.selectedValues?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: UniqueKey(),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create new Exercise',
              style: AppStyles.text18Px.poppins.w600.copyWith(
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Field(data: _exerciseName),
                    const SizedBox(height: 16),
                    Field<String>(data: _muscle),
                    const SizedBox(height: 16),
                    Field<String>(data: _type),
                    const SizedBox(height: 16),
                    Field<String>(data: _equipment),
                    const SizedBox(height: 16),
                    Field(data: _youtubeLink),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Unfocus before closing to prevent context access errors
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context); // Close create sheet
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context); // Close select sheet
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
  const _ExerciseCard({required this.index, required this.exercise});

  final int index;
  final WorkoutExercise exercise;

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
                        Row(
                          children: [
                            Container(
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
                          ],
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
  final String name;
  final String muscle;
  final String equipment;
  final String type;
  final String videoLink;

  const WorkoutExercise({
    required this.id,
    required this.name,
    required this.muscle,
    required this.equipment,
    required this.type,
    required this.videoLink,
  });

  String get subtitle => '$muscle / $equipment / $type';
}

const List<WorkoutExercise> _defaultExercises = [
  WorkoutExercise(
    id: '1',
    name: 'Incline Bench Press',
    muscle: 'Chest',
    equipment: 'Barbell',
    type: 'Volume×Rep',
    videoLink: 'https://www.youtube.com/videoN...',
  ),
  WorkoutExercise(
    id: '2',
    name: 'Incline Bench Press',
    muscle: 'Chest',
    equipment: 'Barbell',
    type: 'Volume×Rep',
    videoLink: 'https://www.youtube.com/videoN...',
  ),
  WorkoutExercise(
    id: '3',
    name: 'Incline Bench Press',
    muscle: 'Chest',
    equipment: 'Barbell',
    type: 'Volume×Rep',
    videoLink: 'https://www.youtube.com/videoN...',
  ),
  WorkoutExercise(
    id: '4',
    name: 'Incline Bench Press',
    muscle: 'Chest',
    equipment: 'Barbell',
    type: 'Volume×Rep',
    videoLink: 'https://www.youtube.com/videoN...',
  ),
];

const List<WorkoutExercise> _defaultLibraryExercises = [
  WorkoutExercise(
    id: '1',
    name: 'Flat Bench Dumbbell Press',
    muscle: 'Chest',
    equipment: 'Dumbbell',
    type: 'Volume×Rep',
    videoLink: '',
  ),
  WorkoutExercise(
    id: '102',
    name: 'Incline Dumbbell Press',
    muscle: 'Chest',
    equipment: 'Dumbbell',
    type: 'Volume×Rep',
    videoLink: '',
  ),
  WorkoutExercise(
    id: '103',
    name: 'Incline Dumbbell Press',
    muscle: 'Chest',
    equipment: 'Dumbbell',
    type: 'Volume×Rep',
    videoLink: '',
  ),
  WorkoutExercise(
    id: '104',
    name: 'Incline Dumbbell Press',
    muscle: 'Chest',
    equipment: 'Dumbbell',
    type: 'Volume×Rep',
    videoLink: '',
  ),
];

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
