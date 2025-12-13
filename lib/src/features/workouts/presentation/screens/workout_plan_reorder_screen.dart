import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_details_screen.dart';

class WorkoutPlanReorderScreen extends StatefulWidget {
  const WorkoutPlanReorderScreen({
    super.key,
    required this.planTitle,
    required this.exercises,
  });

  final String planTitle;
  final List<WorkoutExercise> exercises;

  @override
  State<WorkoutPlanReorderScreen> createState() =>
      _WorkoutPlanReorderScreenState();
}

class _WorkoutPlanReorderScreenState extends State<WorkoutPlanReorderScreen> {
  late List<WorkoutExercise> _exercises;

  @override
  void initState() {
    super.initState();
    _exercises = List.from(widget.exercises);
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
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                itemCount: _exercises.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = _exercises.removeAt(oldIndex);
                    _exercises.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  return _ReorderableExerciseCard(
                    key: ValueKey(exercise.id),
                    index: index + 1,
                    exercise: exercise,
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _exercises);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD30000),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Save Changes',
                  style: AppStyles.text16Px.poppins.w600.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReorderableExerciseCard extends StatelessWidget {
  const _ReorderableExerciseCard({
    required this.key,
    required this.index,
    required this.exercise,
  }) : super(key: key);

  final Key key;
  final int index;
  final WorkoutExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            ReorderableDragStartListener(
              index: index - 1,
              child: Container(
                width: 40,
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.keyboard_arrow_up,
                      size: 16,
                      color: Color(0xFFD30000),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(),
                        const SizedBox(width: 2),
                        _buildDot(),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(),
                        const SizedBox(width: 2),
                        _buildDot(),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(),
                        const SizedBox(width: 2),
                        _buildDot(),
                      ],
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Color(0xFFD30000),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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

  Widget _buildDot() {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Color(0xFFD30000),
        shape: BoxShape.circle,
      ),
    );
  }
}
