import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class MultiDayPlanReorderScreen extends StatefulWidget {
  const MultiDayPlanReorderScreen({
    super.key,
    required this.planTitle,
    required this.plans,
    required this.masterPlanId,
    this.source = 'trainer',
  });

  final String planTitle;
  final List<Map<String, dynamic>> plans;
  final int masterPlanId;
  final String source;

  @override
  State<MultiDayPlanReorderScreen> createState() =>
      _MultiDayPlanReorderScreenState();
}

class _MultiDayPlanReorderScreenState extends State<MultiDayPlanReorderScreen> {
  late List<Map<String, dynamic>> _plans;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _plans = widget.plans
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    // Ensure initial 1-indexed day numbers
    for (int i = 0; i < _plans.length; i++) {
      _plans[i]['day_number'] = i + 1;
    }
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final dio = DioClient().dio;
      final int containerId = widget.masterPlanId;

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
      bool saved = false;
      try {
        final response = await dio.post<dynamic>(
          ApiUris.multiDayWorkoutReorder(containerId),
          data: {
            'day_ids': dayIds,
            'days': daysPayload,
            'order': dayIds,
          },
          options: Options(headers: {'X-Platform': platformSource}),
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          saved = true;
        }
      } catch (_) {}

      // 2. Legacy fallback if atomic endpoint fails
      if (!saved) {
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
      }

      Dialogs.showSnack(msg: 'Workout plan order saved successfully');
      if (mounted) {
        Navigator.pop(context, _plans);
      }
    } catch (e) {
      Dialogs.showSnack(msg: 'Error saving changes: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
                '${_plans.length} Days',
                style: AppStyles.text14Px.poppins.w400.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        onPressed: _isSaving ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD30000),
          disabledBackgroundColor: const Color(0xFFD30000).withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Save Changes',
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: Colors.white,
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
                itemCount: _plans.length,
                onReorder: (oldIndex, newIndex) {
                  if (!mounted) return;
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
                },
                itemBuilder: (context, index) {
                  final plan = _plans[index];
                  final String planName =
                      plan['plan_name'] as String? ?? plan['title'] as String? ?? 'Day Routine';
                  final int exCount = plan['exercise_count'] as int? ?? 0;
                  final planDayId = plan['plan_day_id'] ?? plan['id'] ?? 'day_$index';

                  return _ReorderableDayCard(
                    key: ValueKey(planDayId),
                    index: index + 1,
                    title: planName,
                    exerciseCount: exCount,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReorderableDayCard extends StatelessWidget {
  const _ReorderableDayCard({
    required super.key,
    required this.index,
    required this.title,
    required this.exerciseCount,
  });

  final int index;
  final String title;
  final int exerciseCount;

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
            color: Colors.black.withValues(alpha: 0.05),
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
              width: 58,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                border: Border(right: BorderSide(color: AppColors.borderGrey)),
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
                    index.toString(),
                    style: AppStyles.text22Px.poppins.w700.copyWith(
                      color: Colors.black,
                      height: 1.1,
                    ),
                  ),
                ],
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
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppStyles.text16Px.poppins.w600.copyWith(
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No of Exercises: $exerciseCount',
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: AppColors.textGrey,
                      ),
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
