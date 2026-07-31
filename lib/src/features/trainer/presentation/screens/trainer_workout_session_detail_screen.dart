import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class TrainerWorkoutSessionDetailScreen extends StatefulWidget {
  const TrainerWorkoutSessionDetailScreen({
    super.key,
    required this.sessionId,
  });

  final int sessionId;

  @override
  State<TrainerWorkoutSessionDetailScreen> createState() =>
      _TrainerWorkoutSessionDetailScreenState();
}

class _TrainerWorkoutSessionDetailScreenState
    extends State<TrainerWorkoutSessionDetailScreen> {
  Map<String, dynamic> _sessionData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSessionDetails();
  }

  Future<void> _fetchSessionDetails() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.workoutSessionDetails(widget.sessionId),
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200 && response.data is Map) {
        if (!mounted) return;
        setState(() {
          _sessionData = Map<String, dynamic>.from(response.data as Map);
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Dialogs.showSnack(msg: 'Failed to load session details');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Dialogs.showSnack(msg: 'Error loading session details');
    }
  }

  bool _isAssignedWorkout(Map<String, dynamic> item) {
    final type = (item['workout_type'] ??
            item['session_type'] ??
            item['type'] ??
            item['workout_category'] ??
            '')
        .toString()
        .toLowerCase();
    if (type.contains('assigned')) return true;
    if (type.contains('self') || type.contains('custom') || type.contains('own')) return false;

    final isAssigned = item['is_assigned'] as bool? ??
        item['is_assigned_workout'] as bool?;
    if (isAssigned != null) return isAssigned;

    final isSelf = item['is_self_workout'] as bool? ??
        item['is_custom'] as bool? ??
        item['is_self'] as bool?;
    if (isSelf != null) return !isSelf;

    final planId = item['customer_workout_plan_id'] ??
        item['plan_id'] ??
        item['workout_plan_id'] ??
        item['plan'];
    return planId != null && planId != 0;
  }

  Widget _buildWorkoutTypeBadge(Map<String, dynamic> item) {
    final isAssigned = _isAssignedWorkout(item);
    final label = isAssigned ? 'Assigned Workout' : 'Self Workout';
    final bg = isAssigned
        ? const Color(0xFFEBF3FF)
        : const Color(0xFFF3E8FF);
    final textColor = isAssigned
        ? const Color(0xFF1E56A0)
        : const Color(0xFF7E22CE);
    final icon = isAssigned ? Icons.assignment_outlined : Icons.person_outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppStyles.text10Px.poppins.w600.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutTitle = _sessionData['workout_title'] as String? ?? 'Workout Session';
    final exercises = _sessionData['exercises'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const PopButton().center,
        centerTitle: false,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workoutTitle,
                    style: AppStyles.text18Px.poppins.w600.dark,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (exercises.isNotEmpty)
                    Text(
                      '${exercises.length} Exercises',
                      style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.textGrey),
                    ),
                ],
              ),
            ),
            if (_sessionData.isNotEmpty) ...[
              const SizedBox(width: 8),
              _buildWorkoutTypeBadge(_sessionData),
            ],
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : exercises.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return _buildExerciseCard(
                      index: index + 1,
                      exerciseData: exercise,
                    );
                  },
                ),
    );
  }

  Widget _buildExerciseCard({required int index, required dynamic exerciseData}) {
    final name = exerciseData['exercise_name'] as String? ?? '';
    final category = exerciseData['category'] as String? ?? '';
    final sets = exerciseData['sets'] as List<dynamic>? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$index. $name',
                      style: AppStyles.text16Px.poppins.w600.dark,
                    ),
                    if (category.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        category,
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSetsTable(sets),
        ],
      ),
    );
  }

  Widget _buildSetsTable(List<dynamic> sets) {
    return Column(
      children: [
        // Table Header
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text('Set', style: AppStyles.text12Px.poppins.w600.dark),
            ),
            Expanded(
              flex: 3,
              child: Text('Previous', style: AppStyles.text12Px.poppins.w600.dark),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text('kg', style: AppStyles.text12Px.poppins.w600.dark),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text('Rep', style: AppStyles.text12Px.poppins.w600.dark),
              ),
            ),
            const SizedBox(width: 32), // Space for checkbox
          ],
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, color: Color(0xffEEEEEE)),
        const SizedBox(height: 8),
        
        // Table Rows
        ...sets.map((set) {
          final setNum = set['set_number']?.toString() ?? '-';
          final previous = set['previous_data'] as String? ?? 'no data';
          final kg = set['logged_kg']?.toString() ?? '0';
          final rep = set['logged_reps']?.toString() ?? '0';
          final isCompleted = set['is_completed'] as bool? ?? false;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    setNum,
                    style: AppStyles.text14Px.poppins.w500.dark,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    previous,
                    style: AppStyles.text14Px.poppins.w400.copyWith(
                      color: previous == 'no data' ? Colors.grey.shade400 : AppColors.textDark,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      kg,
                      style: AppStyles.text14Px.poppins.w500.dark,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      rep,
                      style: AppStyles.text14Px.poppins.w500.dark,
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Center(
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.primary : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isCompleted ? AppColors.primary : Colors.grey.shade300,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : const Icon(Icons.check, size: 16, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Exercises Found',
            style: AppStyles.text16Px.poppins.w600.dark,
          ),
        ],
      ),
    );
  }
}
