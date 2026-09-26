import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum AssignedWorkoutsStatus {
  initial,
  loading,
  success,
  failure,
}

/// Holds cached data for a specific plan type tab.
@immutable
class TabCache {
  const TabCache({
    this.workouts = const [],
    this.hasMore = true,
    this.currentPage = 1,
  });

  final List<Map<String, dynamic>> workouts;
  final bool hasMore;
  final int currentPage;
}

@immutable
class AssignedWorkoutsState {
  const AssignedWorkoutsState({
    this.status = AssignedWorkoutsStatus.initial,
    this.workouts = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.currentPage = 1,
    this.selectedDate,
    this.selectedPlanType = 'single_day',
    this.searchQuery = '',
    this.sortNewestFirst = true,
    this.errorMessage,
    this.isDeleting = false,
    this.actionMessage,
    this.tabCaches = const {},
  });

  final AssignedWorkoutsStatus status;
  final List<Map<String, dynamic>> workouts;
  final bool hasMore;
  final bool isLoadingMore;
  final int currentPage;
  final DateTime? selectedDate;
  final String selectedPlanType;
  final String searchQuery;
  final bool sortNewestFirst;
  final String? errorMessage;
  final bool isDeleting;
  final String? actionMessage;

  /// Cached data per plan type tab (e.g. 'single_day', 'multi_day').
  final Map<String, TabCache> tabCaches;

  AssignedWorkoutsState copyWith({
    AssignedWorkoutsStatus? status,
    List<Map<String, dynamic>>? workouts,
    bool? hasMore,
    bool? isLoadingMore,
    int? currentPage,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    String? selectedPlanType,
    String? searchQuery,
    bool? sortNewestFirst,
    String? errorMessage,
    bool? isDeleting,
    String? actionMessage,
    Map<String, TabCache>? tabCaches,
  }) {
    return AssignedWorkoutsState(
      status: status ?? this.status,
      workouts: workouts ?? this.workouts,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      selectedPlanType: selectedPlanType ?? this.selectedPlanType,
      searchQuery: searchQuery ?? this.searchQuery,
      sortNewestFirst: sortNewestFirst ?? this.sortNewestFirst,
      errorMessage: errorMessage,
      isDeleting: isDeleting ?? this.isDeleting,
      actionMessage: actionMessage,
      // ignore: unnecessary_null_comparison
      tabCaches: tabCaches ?? (this.tabCaches ?? const {}),
    );
  }

  List<Map<String, dynamic>> get filteredWorkouts {
    var list = List<Map<String, dynamic>>.from(workouts);

    // Filter strictly by exact selected date (Option A)
    if (selectedDate != null) {
      final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);
      list = list.where((item) {
        final itemDate = _extractDate(item);
        if (itemDate.isEmpty) return false;
        final normalized =
            itemDate.length >= 10 ? itemDate.substring(0, 10) : itemDate;
        return normalized == selectedDateStr;
      }).toList();
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((item) {
        final title = (item['plan_name'] ??
                item['title'] ??
                item['name'] ??
                item['workout_plan_name'] ??
                '')
            .toString()
            .toLowerCase();
        final client = (item['client_name'] ?? '').toString().toLowerCase();
        final status = (item['status'] ?? '').toString().toLowerCase();
        return title.contains(q) || client.contains(q) || status.contains(q);
      }).toList();
    }

    list.sort((a, b) {
      final dateA = _extractDate(a);
      final dateB = _extractDate(b);
      final cmp = dateA.compareTo(dateB);
      return sortNewestFirst ? -cmp : cmp;
    });

    return list;
  }

  static String _extractDate(Map<String, dynamic> item) {
    return (item['start_date'] ??
            item['scheduled_date'] ??
            item['session_date'] ??
            item['assigned_date'] ??
            item['date'] ??
            item['created_at'] ??
            '')
        .toString();
  }
}
