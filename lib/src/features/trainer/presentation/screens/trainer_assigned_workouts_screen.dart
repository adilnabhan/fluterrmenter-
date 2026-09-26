import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/trainer/cubit/assigned_workouts/assigned_workouts_cubit.dart';
import 'package:mentor_mobile_app/src/features/trainer/cubit/assigned_workouts/assigned_workouts_state.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_groups_screen.dart';
import 'package:mentor_mobile_app/src/features/workouts/presentation/screens/workout_plan_details_screen.dart';

class TrainerAssignedWorkoutsScreen extends StatelessWidget {
  const TrainerAssignedWorkoutsScreen({
    this.customerId,
    this.customerName,
    super.key,
  });

  final int? customerId;
  final String? customerName;

  static void clearCache() {}

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AssignedWorkoutsCubit(
        customerId: customerId,
        customerName: customerName,
      )..loadAssignedWorkouts(reset: true),
      child: _TrainerAssignedWorkoutsView(
        customerId: customerId,
        customerName: customerName,
      ),
    );
  }
}

class _TrainerAssignedWorkoutsView extends StatefulWidget {
  final int? customerId;
  final String? customerName;

  const _TrainerAssignedWorkoutsView({
    this.customerId,
    this.customerName,
  });

  @override
  State<_TrainerAssignedWorkoutsView> createState() =>
      _TrainerAssignedWorkoutsViewState();
}

class _TrainerAssignedWorkoutsViewState
    extends State<_TrainerAssignedWorkoutsView> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final cubit = context.read<AssignedWorkoutsCubit>();
      if (!cubit.state.isLoadingMore && cubit.state.hasMore) {
        cubit.loadAssignedWorkouts(reset: false);
      }
    }
  }

  Future<void> _confirmDeleteWorkout(
    BuildContext context,
    Map<String, dynamic> workout,
  ) async {
    final title = (workout['plan_name'] ??
            workout['title'] ??
            workout['name'] ??
            workout['workout_plan_name'] ??
            'Workout Plan')
        .toString();

    final clientName = (workout['client_name'] ?? 'Client').toString();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Assigned Workout'),
        content: Text(
          'Are you sure you want to delete "$title" for $clientName?\n\nThis will remove the assignment and uncompleted future workout sessions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffE53E3E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<AssignedWorkoutsCubit>().deleteWorkout(workout);
    }
  }

  String _extractDateString(Map<String, dynamic> item) {
    final raw = (item['start_date'] ??
            item['scheduled_date'] ??
            item['session_date'] ??
            item['assigned_date'] ??
            item['date'] ??
            item['created_at'] ??
            '')
        .toString();
    if (raw.length >= 10) {
      final datePart = raw.substring(0, 10);
      try {
        final parsed = DateTime.tryParse(datePart);
        if (parsed != null) {
          return DateFormat('dd MMM, yyyy').format(parsed);
        }
      } catch (_) {}
      return datePart;
    }
    return raw;
  }

  Widget _buildSegmentButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: AppStyles.text14Px.poppins.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : const Color(0xff718096),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssignedWorkoutsCubit, AssignedWorkoutsState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          Dialogs.showSnack(msg: state.errorMessage!);
        } else if (state.actionMessage != null &&
            state.actionMessage!.isNotEmpty) {
          Dialogs.showSnack(msg: state.actionMessage!);
        }
      },
      builder: (context, state) {
        final filteredWorkouts = state.filteredWorkouts;
        final selectedDate = state.selectedDate;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF7F9FC),
            elevation: 0,
            leading: const PopButton().center,
            title: Text(
              'Assigned Workouts',
              style: AppStyles.text16Px.poppins.w600.dark,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded, color: AppColors.dark),
                tooltip: 'Assign Workout',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const WorkoutGroupsScreen(),
                    ),
                  ).then((_) {
                    context
                        .read<AssignedWorkoutsCubit>()
                        .loadAssignedWorkouts(reset: true);
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.dark),
                onPressed: () {
                  final cubit = context.read<AssignedWorkoutsCubit>();
                  cubit.invalidateCaches();
                  cubit.loadAssignedWorkouts(reset: true);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Segmented Control: Single Day vs Multi Day
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xffEDF2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSegmentButton(
                          title: 'Single Day',
                          isSelected: state.selectedPlanType == 'single_day',
                          onTap: () => context
                              .read<AssignedWorkoutsCubit>()
                              .selectPlanType('single_day'),
                        ),
                      ),
                      Expanded(
                        child: _buildSegmentButton(
                          title: 'Multi Day',
                          isSelected: state.selectedPlanType == 'multi_day',
                          onTap: () => context
                              .read<AssignedWorkoutsCubit>()
                              .selectPlanType('multi_day'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar with Calendar Filter Icon
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xffE2E8F0)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => context
                              .read<AssignedWorkoutsCubit>()
                              .setSearchQuery(val),
                          style: AppStyles.text14Px.poppins.w500.dark,
                          decoration: InputDecoration(
                            hintText: 'Search by workout name or client...',
                            hintStyle: AppStyles.text13Px.poppins.w400.copyWith(
                              color: const Color(0xffA0AEC0),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 20,
                              color: Color(0xff718096),
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null && context.mounted) {
                          context
                              .read<AssignedWorkoutsCubit>()
                              .selectDate(picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: selectedDate != null
                              ? const Color(0xFFFFEAEA)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selectedDate != null
                                ? AppColors.primary
                                : const Color(0xffE2E8F0),
                            width: selectedDate != null ? 1.5 : 1.0,
                          ),
                        ),
                        child: Icon(
                          Icons.calendar_month_outlined,
                          size: 22,
                          color: selectedDate != null
                              ? AppColors.primary
                              : const Color(0xff718096),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Active Date Filter Chip
              if (selectedDate != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEAEA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('dd MMM, yyyy').format(selectedDate),
                              style: AppStyles.text12Px.poppins.w500.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => context
                                  .read<AssignedWorkoutsCubit>()
                                  .selectDate(null),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Main Workouts List
              Expanded(
                child: state.status == AssignedWorkoutsStatus.loading
                    ? _buildShimmerList()
                    : state.status == AssignedWorkoutsStatus.failure &&
                            filteredWorkouts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  state.errorMessage ??
                                      'Failed to load assigned workouts',
                                  style:
                                      AppStyles.text14Px.poppins.w500.copyWith(
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => context
                                      .read<AssignedWorkoutsCubit>()
                                      .loadAssignedWorkouts(reset: true),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : filteredWorkouts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.fitness_center_outlined,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      selectedDate != null
                                          ? "No assigned workouts for ${DateFormat('dd MMM, yyyy').format(selectedDate)}"
                                          : "No assigned workouts found",
                                      style: AppStyles.text14Px.poppins.w500
                                          .copyWith(
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () => context
                                    .read<AssignedWorkoutsCubit>()
                                    .loadAssignedWorkouts(reset: true),
                                child: ListView.separated(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: filteredWorkouts.length +
                                      (state.isLoadingMore ? 1 : 0),
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    if (index == filteredWorkouts.length) {
                                      return const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16),
                                        child: Center(
                                          child: CircularProgressIndicator
                                              .adaptive(),
                                        ),
                                      );
                                    }
                                    final workout = filteredWorkouts[index];
                                    final planId = workout['plan_id']
                                            as int? ??
                                        workout['customer_workout_plan_id']
                                            as int? ??
                                        workout['workout_plan_id'] as int? ??
                                        workout['id'] as int? ??
                                        0;
                                    final title = (workout['plan_name'] ??
                                            workout['title'] ??
                                            workout['name'] ??
                                            workout['workout_plan_name'] ??
                                            'Workout Plan')
                                        .toString();
                                    final clientName =
                                        (workout['client_name'] ?? 'Client')
                                            .toString();
                                    final status = (workout['status'] ??
                                            workout['assignment_status'] ??
                                            'Active')
                                        .toString();
                                    final rawStatus = status.toLowerCase();
                                    final bool isCompleted =
                                        workout['is_completed'] == true ||
                                            workout['completed'] == true ||
                                            rawStatus == 'completed' ||
                                            rawStatus == 'done' ||
                                            rawStatus == 'verified';
                                    final assignedDate =
                                        _extractDateString(workout);
                                    final routinesCount = workout[
                                                'total_days'] as int? ??
                                        workout['days_count'] as int? ??
                                        (workout['days'] as List?)?.length ??
                                        (workout['routines'] as List?)
                                            ?.length ??
                                        (workout['workout_days'] as List?)
                                            ?.length ??
                                        0;
                                    // Status-specific color configurations
                                    Color statusBgColor;
                                    Color statusTextColor;
                                    Color iconBgColor;
                                    Color iconColor;
                                    Color? cardBorderColor;

                                    switch (rawStatus) {
                                      case 'completed':
                                      case 'done':
                                      case 'verified':
                                        statusBgColor = const Color(0xffC6F6D5); // Soft Green
                                        statusTextColor = const Color(0xff22543D); // Dark Green
                                        iconBgColor = const Color(0xffE6FFFA);
                                        iconColor = const Color(0xff234E52);
                                        cardBorderColor = const Color(0xff38A169);
                                        break;
                                      case 'pending':
                                        statusBgColor = const Color(0xffFEEBC8); // Soft Amber/Orange
                                        statusTextColor = const Color(0xff7B341E); // Dark Amber
                                        iconBgColor = const Color(0xffFFFAF0);
                                        iconColor = const Color(0xffDD6B20);
                                        cardBorderColor = const Color(0xffED8936);
                                        break;
                                      case 'scheduled':
                                        statusBgColor = const Color(0xffEBF8FF); // Soft Blue
                                        statusTextColor = const Color(0xff2B6CB0); // Dark Blue
                                        iconBgColor = const Color(0xffF7FAFC);
                                        iconColor = const Color(0xff3182CE);
                                        cardBorderColor = const Color(0xff4299E1);
                                        break;
                                      case 'skipped':
                                        statusBgColor = const Color(0xffFED7D7); // Soft Red
                                        statusTextColor = const Color(0xff9B2C2C); // Dark Red
                                        iconBgColor = const Color(0xffFFF5F5);
                                        iconColor = const Color(0xffE53E3E);
                                        cardBorderColor = const Color(0xffE53E3E);
                                        break;
                                      case 'rest_day':
                                      case 'rest':
                                        statusBgColor = const Color(0xffE9D8FD); // Soft Purple
                                        statusTextColor = const Color(0xff553C9A); // Dark Purple
                                        iconBgColor = const Color(0xffFAF5FF);
                                        iconColor = const Color(0xff805AD5);
                                        cardBorderColor = const Color(0xff9F7AEA);
                                        break;
                                      default:
                                        // Active / Default
                                        statusBgColor = const Color(0xffE2E8F0);
                                        statusTextColor = const Color(0xff4A5568);
                                        iconBgColor = const Color(0xffEDF2F7);
                                        iconColor = const Color(0xff4A5568);
                                        cardBorderColor = null;
                                    }

                                    return InkWell(
                                      onTap: planId > 0
                                          ? () {
                                              Navigator.push<void>(
                                                context,
                                                MaterialPageRoute<void>(
                                                  builder: (context) =>
                                                      WorkoutPlanDetailsScreen(
                                                    planId: planId,
                                                    planTitle: title,
                                                  ),
                                                ),
                                              );
                                            }
                                          : null,
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: const Color(0xffE2E8F0),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.02),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: cardBorderColor != null
                                                  ? Border(
                                                      left: BorderSide(
                                                        color: cardBorderColor,
                                                        width: 4,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                            padding: const EdgeInsets.all(14),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Top Row: Icon + Title & Client + Status + Delete Menu
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 44,
                                                      height: 44,
                                                      decoration: BoxDecoration(
                                                        color: iconBgColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        rawStatus == 'rest_day' || rawStatus == 'rest'
                                                            ? Icons.hotel_rounded
                                                            : Icons.fitness_center_rounded,
                                                        color: iconColor,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            title,
                                                            style: AppStyles
                                                                .text15Px
                                                                .poppins
                                                                .w600
                                                                .dark,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          const SizedBox(
                                                              height: 2),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .person_outline,
                                                                size: 13,
                                                                color: Color(
                                                                    0xff718096),
                                                              ),
                                                              const SizedBox(
                                                                  width: 4),
                                                              Expanded(
                                                                child: Text(
                                                                  clientName,
                                                                  style:
                                                                      AppStyles
                                                                          .text12Px
                                                                          .poppins
                                                                          .w400
                                                                          .copyWith(
                                                                    color: const Color(
                                                                        0xff4A5568),
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: statusBgColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Text(
                                                            status
                                                                .toUpperCase(),
                                                            style: AppStyles
                                                                .text10Px
                                                                .poppins
                                                                .w700
                                                                .copyWith(
                                                              color: statusTextColor,
                                                            ),
                                                          ),
                                                        ),
                                                        if (!isCompleted)
                                                          PopupMenuButton<
                                                              String>(
                                                            icon: const Icon(
                                                              Icons
                                                                  .more_vert_rounded,
                                                              size: 20,
                                                              color: Color(
                                                                  0xff718096),
                                                            ),
                                                            padding:
                                                                EdgeInsets.zero,
                                                            constraints:
                                                                const BoxConstraints(),
                                                            onSelected: (val) {
                                                              if (val ==
                                                                  'delete') {
                                                                _confirmDeleteWorkout(
                                                                  context,
                                                                  workout,
                                                                );
                                                              }
                                                            },
                                                            itemBuilder:
                                                                (context) => [
                                                              const PopupMenuItem<
                                                                  String>(
                                                                value: 'delete',
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .delete_outline_rounded,
                                                                      color: Color(
                                                                          0xffE53E3E),
                                                                      size: 18,
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            8),
                                                                    Text(
                                                                      'Delete Assignment',
                                                                      style: TextStyle(
                                                                        color: Color(
                                                                            0xffE53E3E),
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 10),
                                                const Divider(
                                                  height: 1,
                                                  color: Color(0xffEDF2F7),
                                                ),
                                                const SizedBox(height: 10),

                                                // Bottom Row: Routines/Days + Date + Chevron
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          routinesCount > 0
                                                              ? '$routinesCount Workout Routines / Days'
                                                              : 'Workout Plan Details',
                                                          style: AppStyles
                                                              .text12Px
                                                              .poppins
                                                              .w500
                                                              .copyWith(
                                                            color: const Color(
                                                                0xff4A5568),
                                                          ),
                                                        ),
                                                        if (assignedDate
                                                            .isNotEmpty) ...[
                                                          const SizedBox(
                                                              height: 2),
                                                          Text(
                                                            'Assigned: $assignedDate',
                                                            style: AppStyles
                                                                .text10Px
                                                                .poppins
                                                                .w500
                                                                .copyWith(
                                                              color:
                                                                  const Color(
                                                                      0xff718096),
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                    const Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                      color: Color(0xff718096),
                                                      size: 20,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xffE2E8F0),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  KShimmer(width: 44, height: 44, radius: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        KShimmer(width: 160, height: 15, radius: 4),
                        SizedBox(height: 6),
                        KShimmer(width: 80, height: 11, radius: 4),
                      ],
                    ),
                  ),
                  KShimmer(width: 70, height: 22, radius: 8),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xffEDF2F7)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KShimmer(width: 140, height: 12, radius: 4),
                      SizedBox(height: 4),
                      KShimmer(width: 90, height: 10, radius: 4),
                    ],
                  ),
                  KShimmer(width: 16, height: 16, radius: 4),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
