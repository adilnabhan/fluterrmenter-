import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/widgets/create_group_button.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_details_screen.dart';

class WorkoutGroupDetailsScreen extends StatefulWidget {
  const WorkoutGroupDetailsScreen({super.key, required this.groupTitle});
  final String groupTitle;

  @override
  State<WorkoutGroupDetailsScreen> createState() => _WorkoutGroupDetailsScreenState();
}

class _WorkoutGroupDetailsScreenState extends State<WorkoutGroupDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final FieldData<dynamic> _planNamePrivate;
  late final FieldData<dynamic> _planNamePublic;

  final List<Map<String, dynamic>> _plans = const [
    {
      'title': 'Chest Exercise Plan 1',
      'exerciseCount': 4,
      'createdOn': '21 Monday',
    },
    {
      'title': 'Chest Exercise Plan 2',
      'exerciseCount': 6,
      'createdOn': '22 Tuesday',
    },
    {
      'title': 'Chest Exercise Plan 3',
      'exerciseCount': 6,
      'createdOn': '22 Tuesday',
    },
    {
      'title': 'Chest Exercise Plan 4',
      'exerciseCount': 6,
      'createdOn': '22 Tuesday',
    },
  ];

  @override
  void initState() {
    super.initState();
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
    super.dispose();
    _planNamePrivate.controller?.dispose();
    _planNamePrivate.focusNode?.dispose();
    _planNamePublic.controller?.dispose();
    _planNamePublic.focusNode?.dispose();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
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
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.borderGrey),
                  ),
                  child: TextField(
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
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: _plans.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final plan = _plans[index];
                            return _PlanCard(
                              title: plan['title'] as String,
                              exerciseCount: plan['exerciseCount'] as int,
                              createdOn: plan['createdOn'] as String,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder:
                                        (context) => WorkoutPlanDetailsScreen(
                                          planTitle: plan['title'] as String,
                                        ),
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
                          Navigator.pop(context);
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
  });

  final String title;
  final int exerciseCount;
  final String createdOn;
  final VoidCallback onTap;

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
                Container(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
