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
    super.key,
  });

  final int groupId;
  final String groupTitle;

  @override
  State<WorkoutGroupDetailsScreen> createState() => _WorkoutGroupDetailsScreenState();
}

class _WorkoutGroupDetailsScreenState extends State<WorkoutGroupDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final FieldData<dynamic> _planNamePrivate;
  late final FieldData<dynamic> _planNamePublic;

  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPlans();
    _planNamePrivate = FieldData(
      type: FieldType.word,
      textInputAction: TextInputAction.next,
      label: 'Plan Name',
      requiredLabel: true,
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'Plan name is required';
        }
        return null;
      },
      onSubmitted: (value) {
        _planNamePublic.focusNode?.requestFocus();
      },
      controller: TextEditingController(),
      focusNode: FocusNode(),
      decoration: InputDecoration(
        hintText: 'Enter plan name',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );
    _planNamePublic = FieldData(
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
      decoration: InputDecoration(
        hintText: 'Enter plan name',
        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _planNamePrivate.controller?.dispose();
    _planNamePrivate.focusNode?.dispose();
    _planNamePublic.controller?.dispose();
    _planNamePublic.focusNode?.dispose();
    super.dispose();
  }

  Future<void> _fetchPlans() async {
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
        setState(() {
          _plans = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to load workout plans');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error loading plans: ${e.toString()}');
    }
  }

  Future<void> _createPlan(String privateName, String publicName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.workoutPlans,
        data: {
          'plan_name': publicName,
          'plan_name_internal': privateName,
          'group': widget.groupId,
          'total_weeks': 1,
          'total_days': 1,
        },
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Dialogs.showSnack(msg: 'Workout plan created successfully');
        _planNamePrivate.controller?.clear();
        _planNamePublic.controller?.clear();
        _fetchPlans();
      } else {
        setState(() {
          _isLoading = false;
        });
        Dialogs.showSnack(msg: 'Failed to create workout plan');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Dialogs.showSnack(msg: 'Error creating workout plan: ${e.toString()}');
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
          'Workout Plans',
          style: AppStyles.text20Px.poppins.w600.copyWith(color: Colors.black),
        ),
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
                    borderRadius: BorderRadius.circular(30),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.groupTitle.replaceAll('\n', ' '),
                    style: AppStyles.text18Px.poppins.w600.copyWith(
                      color: AppColors.textDark,
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
                    children: [
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
                            Container(
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
                                    Icons.filter_list,
                                    size: 16,
                                    color: Color(0xFFFF3434),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Sort',
                                    style: AppStyles.text12Px.poppins.w500
                                        .copyWith(
                                          color: const Color(0xFFFF3434),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _plans.isEmpty
                                ? const Center(child: Text('No workout plans found.'))
                                : ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                    itemCount: _plans.length,
                                    separatorBuilder:
                                        (context, index) => const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      final plan = _plans[index];
                                      final int planId = plan['id'] as int;
                                      final String planName = plan['plan_name'] as String? ?? 'Plan';
                                      final int exerciseCount = plan['exercise_count'] as int? ?? 0;
                                      final String createdOn = plan['created_at'] != null
                                          ? DateFormat('dd MMM yyyy').format(DateTime.parse(plan['created_at'] as String))
                                          : 'N/A';

                                      return _PlanCard(
                                        title: planName,
                                        exerciseCount: exerciseCount,
                                        createdOn: createdOn,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<void>(
                                              builder:
                                                  (context) => WorkoutPlanDetailsScreen(
                                                    planTitle: planName,
                                                    planId: planId,
                                                  ),
                                            ),
                                          );
                                        },
                                        onAssignTap: () {
                                          showModalBottomSheet<void>(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) => AssignToClientBottomSheet(
                                              planId: planId,
                                              planTitle: planName,
                                            ),
                                          );
                                        },
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
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: CreateGroupButton(
                label: 'Create new plan',
                onTap: () => _showCreatePlanSheet(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePlanSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create a Single-Day group',
                    style: AppStyles.text18Px.poppins.w600.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Field(
                    data: _planNamePrivate.copyWith(
                      label: 'Plan Name (only visible to you)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Field(
                    data: _planNamePublic.copyWith(
                      label: 'Plan Name (visible to clients)',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final privateName = _planNamePrivate.controller?.text.trim() ?? '';
                          final publicName = _planNamePublic.controller?.text.trim() ?? '';
                          Navigator.pop(context);
                          if (privateName.isNotEmpty && publicName.isNotEmpty) {
                            _createPlan(privateName, publicName);
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
  });

  final String title;
  final int exerciseCount;
  final String createdOn;
  final VoidCallback onTap;
  final VoidCallback onAssignTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                Text(
                  title,
                  style: AppStyles.text16Px.poppins.w600.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const Icon(Icons.edit, size: 18, color: AppColors.textGrey),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'No of Exercises: $exerciseCount',
              style: AppStyles.text14Px.poppins.w400.copyWith(
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created on\n$createdOn',
                  style: AppStyles.text12Px.poppins.w400.copyWith(
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2E7D32)),
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
