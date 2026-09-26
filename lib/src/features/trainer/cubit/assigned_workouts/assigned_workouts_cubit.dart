import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/trainer/cubit/assigned_workouts/assigned_workouts_state.dart';
import 'package:mentor_mobile_app/src/features/trainer/domain/repositories/trainer_repository.dart';

class AssignedWorkoutsCubit extends Cubit<AssignedWorkoutsState> {
  AssignedWorkoutsCubit({
    TrainerRepository? repository,
    this.customerId,
    this.customerName,
  })  : repository = repository ?? TrainerRepository(),
        super(const AssignedWorkoutsState());

  final TrainerRepository repository;
  final int? customerId;
  final String? customerName;

  static const int pageSize = 20;

  Future<void> loadAssignedWorkouts({
    bool reset = true,
    DateTime? dateOverride,
    String? planTypeOverride,
  }) async {
    if (isClosed) return;

    final date = dateOverride ?? state.selectedDate;
    final dateStr =
        date != null ? DateFormat('yyyy-MM-dd').format(date) : null;
    final planType = planTypeOverride ?? state.selectedPlanType;

    if (reset) {
      emit(state.copyWith(
        status: AssignedWorkoutsStatus.loading,
        currentPage: 1,
        hasMore: true,
        workouts: [],
        selectedDate: date,
        clearSelectedDate: date == null,
        selectedPlanType: planType,
      ));
    } else {
      if (!state.hasMore || state.isLoadingMore) return;
      emit(state.copyWith(isLoadingMore: true));
    }

    final pageToFetch = reset ? 1 : state.currentPage + 1;

    try {
      WorkoutsFetchResult result;
      if (customerId != null) {
        result = await repository.fetchAssignedWorkoutsForClient(
          customerId: customerId!,
          clientName: customerName ?? 'Client',
          dateStr: dateStr,
          planType: planType,
          page: pageToFetch,
        );
      } else {
        result = await repository.fetchAllTrainerAssignedWorkouts(
          dateStr: dateStr,
          planType: planType,
          page: pageToFetch,
        );
      }

      if (isClosed) return;

      if (reset) {
        emit(state.copyWith(
          status: AssignedWorkoutsStatus.success,
          workouts: result.workouts,
          hasMore: result.hasMore,
          currentPage: pageToFetch,
          isLoadingMore: false,
        ));
      } else {
        final existingIds = state.workouts
            .map((e) => e['id'] ?? e['customer_workout_plan_id'])
            .toSet();

        final merged = List<Map<String, dynamic>>.from(state.workouts);
        for (final w in result.workouts) {
          final id = w['id'] ?? w['customer_workout_plan_id'];
          if (id == null || !existingIds.contains(id)) {
            merged.add(w);
          }
        }

        emit(state.copyWith(
          status: AssignedWorkoutsStatus.success,
          workouts: merged,
          hasMore: result.hasMore,
          currentPage: pageToFetch,
          isLoadingMore: false,
        ));
      }

      // Save to tab cache after successful load
      _saveCurrentTabCache();
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: reset && state.workouts.isEmpty
            ? AssignedWorkoutsStatus.failure
            : AssignedWorkoutsStatus.success,
        isLoadingMore: false,
        errorMessage: 'Failed to load assigned workouts',
      ));
    }
  }

  void selectDate(DateTime? date) {
    if (isClosed) return;
    // Invalidate tab caches when date changes
    emit(state.copyWith(
      selectedDate: date,
      clearSelectedDate: date == null,
      tabCaches: const {},
    ));
    loadAssignedWorkouts(dateOverride: date);
  }

  void selectPlanType(String planType) {
    if (isClosed || state.selectedPlanType == planType) return;

    // Save current tab data to cache before switching
    _saveCurrentTabCache();

    // Check if the target tab has cached data
    final cached = state.tabCaches[planType];
    if (cached != null) {
      // Restore from cache — no API call needed
      emit(state.copyWith(
        selectedPlanType: planType,
        status: AssignedWorkoutsStatus.success,
        workouts: cached.workouts,
        hasMore: cached.hasMore,
        currentPage: cached.currentPage,
        isLoadingMore: false,
      ));
    } else {
      // No cache — fetch from API
      emit(state.copyWith(selectedPlanType: planType));
      loadAssignedWorkouts(reset: true, planTypeOverride: planType);
    }
  }

  void setSearchQuery(String query) {
    if (isClosed) return;
    emit(state.copyWith(searchQuery: query));
  }

  void toggleSortOrder() {
    if (isClosed) return;
    emit(state.copyWith(sortNewestFirst: !state.sortNewestFirst));
  }

  Future<bool> deleteWorkout(Map<String, dynamic> workout) async {
    final dynamic rawPlanId = workout['customer_workout_plan_id'];
    final dynamic rawPlan = workout['customer_workout_plan'];
    final dynamic rawAssignmentId = workout['assignment_id'];
    final dynamic rawId = workout['id'];

    int assignmentId = 0;
    if (rawPlanId is int) {
      assignmentId = rawPlanId;
    } else if (rawPlan is int) {
      assignmentId = rawPlan;
    } else if (rawPlan is Map && rawPlan['id'] is int) {
      assignmentId = rawPlan['id'] as int;
    } else if (rawAssignmentId is int) {
      assignmentId = rawAssignmentId;
    } else if (rawId is int) {
      assignmentId = rawId;
    }

    if (assignmentId <= 0) {
      emit(state.copyWith(errorMessage: 'Unable to identify assigned workout ID.'));
      return false;
    }

    emit(state.copyWith(isDeleting: true));

    final success = await repository.deleteAssignedWorkout(assignmentId);

    if (isClosed) return false;

    if (success) {
      final updatedList = state.workouts.where((item) {
        final id = item['customer_workout_plan_id'] ??
            item['assignment_id'] ??
            item['id'];
        return id != assignmentId;
      }).toList();

      emit(state.copyWith(
        isDeleting: false,
        workouts: updatedList,
        actionMessage: 'Assigned workout deleted successfully',
      ));

      // Update cache after deletion
      _saveCurrentTabCache();
      return true;
    } else {
      emit(state.copyWith(
        isDeleting: false,
        errorMessage: 'Failed to delete assigned workout. Please try again.',
      ));
      return false;
    }
  }

  /// Saves the current tab's workouts/hasMore/currentPage into the tabCaches map.
  void _saveCurrentTabCache() {
    if (isClosed || state.status != AssignedWorkoutsStatus.success) return;

    final updatedCaches = Map<String, TabCache>.from(state.tabCaches);
    updatedCaches[state.selectedPlanType] = TabCache(
      workouts: state.workouts,
      hasMore: state.hasMore,
      currentPage: state.currentPage,
    );
    emit(state.copyWith(tabCaches: updatedCaches));
  }

  /// Invalidates all tab caches (e.g. on manual refresh).
  void invalidateCaches() {
    if (isClosed) return;
    emit(state.copyWith(tabCaches: const {}));
  }
}
