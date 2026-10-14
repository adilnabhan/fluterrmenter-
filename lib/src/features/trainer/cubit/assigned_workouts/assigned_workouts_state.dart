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
      tabCaches: tabCaches ?? this.tabCaches,
    );
  }

  List<Map<String, dynamic>> get filteredWorkouts {
    var list = List<Map<String, dynamic>>.from(workouts);

    // Filter by plan type tab: 'single_day' vs 'multi_day'
    final isMultiDayTab = selectedPlanType == 'multi_day';
    list = list.where((item) {
      final isMulti = _isMultiDay(item);
      return isMultiDayTab ? isMulti : !isMulti;
    }).toList();

    // Filter by date: exact match for single-day, active range match for multi-day
    if (selectedDate != null) {
      final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);
      final checkDate =
          DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);

      list = list.where((item) {
        final isMulti = _isMultiDay(item);
        if (!isMulti) {
          final itemDate = _extractDate(item);
          if (itemDate.isEmpty) return false;
          final normalized =
              itemDate.length >= 10 ? itemDate.substring(0, 10) : itemDate;
          return normalized == selectedDateStr;
        }

        // For multi-day plans, check if selectedDate falls within [startDate, effectiveEnd]
        final startStr = _extractDate(item);
        if (startStr.isEmpty) return false;
        final normStart =
            startStr.length >= 10 ? startStr.substring(0, 10) : startStr;
        final startDate = DateTime.tryParse(normStart);
        if (startDate == null) return false;

        final endRaw = (item['end_date'] ?? item['expiry_date'])?.toString();
        final normEnd = (endRaw != null && endRaw.length >= 10)
            ? endRaw.substring(0, 10)
            : null;
        final endDate = normEnd != null ? DateTime.tryParse(normEnd) : null;

        final totalDays = (item['total_days'] as num?)?.toInt() ??
            (item['days_count'] as num?)?.toInt() ??
            (item['days'] as List?)?.length ??
            (item['workout_days'] as List?)?.length ??
            (item['routines'] as List?)?.length ??
            1;

        final effectiveEnd = endDate ??
            startDate.add(
              Duration(days: (totalDays > 0 ? totalDays : 1) - 1),
            );
        final checkStart =
            DateTime(startDate.year, startDate.month, startDate.day);
        final checkEnd = DateTime(
          effectiveEnd.year,
          effectiveEnd.month,
          effectiveEnd.day,
        );

        return !checkDate.isBefore(checkStart) && !checkDate.isAfter(checkEnd);
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

    // Deduplicate by Client + Title + Date so the exact same workout never shows twice
    final uniqueList = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final item in list) {
      final title = (item['plan_name'] ??
              item['title'] ??
              item['name'] ??
              item['workout_plan_name'] ??
              '')
          .toString()
          .trim()
          .toLowerCase();
      final date = _extractDate(item);
      final normDate = date.length >= 10 ? date.substring(0, 10) : date;
      final client = (item['client_name'] ??
              item['customer_name'] ??
              item['customer']?['name'] ??
              item['client']?['name'] ??
              item['customer_id'] ??
              '')
          .toString()
          .trim()
          .toLowerCase();

      final rawId = item['id'] ??
          item['customer_workout_plan_id'] ??
          item['assignment_id'] ??
          item['session_id'];

      // Primary key: client + title + date. (If same client has same workout on same day, it's a duplicate!)
      final key = title.isNotEmpty && normDate.isNotEmpty
          ? '${client}_${title}_$normDate'
          : (title.isNotEmpty
              ? '${client}_$title'
              : (rawId != null && rawId != 0 ? 'id_$rawId' : '${item.hashCode}'));

      if (!seen.contains(key)) {
        seen.add(key);
        uniqueList.add(item);
      }
    }

    return uniqueList;
  }

  static bool _isMultiDay(Map<String, dynamic> item) {
    // 1. Explicit boolean indicators
    if (item['is_multi_day'] == true ||
        item['is_multiday'] == true ||
        item['is_multiday_workout'] == true) {
      return true;
    }
    if (item['is_single_day'] == true ||
        item['is_singleday'] == true ||
        item['is_single_day_workout'] == true) {
      return false;
    }

    // 2. Explicit plan_type / group_type strings
    final planType = (item['plan_type'] ?? item['group_type'] ?? '')
        .toString()
        .toLowerCase();
    if (planType == 'multi_day' || planType == 'custom_range') {
      return true;
    }
    if (planType == 'single_day' || planType == 'single') {
      return false;
    }

    // 3. Nested group object type
    final groupObj = item['group'];
    if (groupObj is Map) {
      final gType = (groupObj['type'] ?? groupObj['group_type'] ?? '')
          .toString()
          .toLowerCase();
      if (gType == 'multi_day') return true;
      if (gType == 'single_day') return false;
    }

    // 4. Nested workout_plan or plan object type
    final planObj = item['workout_plan'] ?? item['plan'];
    if (planObj is Map) {
      final pType = (planObj['group_type'] ??
              planObj['type'] ??
              planObj['plan_type'] ??
              '')
          .toString()
          .toLowerCase();
      if (pType == 'multi_day' || pType == 'custom_range') return true;
      if (pType == 'single_day' || pType == 'single') return false;
      if (planObj['is_multi_day'] == true || planObj['is_multiday'] == true) {
        return true;
      }
    }

    // 5. Explicit multi-day container ID
    if (item['multi_day_container_id'] != null ||
        item['container_id'] != null) {
      return true;
    }

    // 6. Days / Routines count > 1
    final totalDays = (item['total_days'] as num?)?.toInt() ??
        (item['days_count'] as num?)?.toInt() ??
        (item['days'] as List?)?.length ??
        (item['routines'] as List?)?.length ??
        (item['workout_days'] as List?)?.length ??
        0;
    if (totalDays > 1) {
      return true;
    }

    // 7. Nested customer_workout_plan check
    final cwp = item['customer_workout_plan'];
    if (cwp is Map) {
      final cwpType = (cwp['plan_type'] ?? cwp['type'] ?? cwp['group_type'] ?? '')
          .toString()
          .toLowerCase();
      if (cwpType == 'multi_day' || cwpType == 'custom_range') return true;
      if (cwpType == 'single_day' || cwpType == 'single') return false;
      if (cwp['is_multi_day'] == true || cwp['is_multiday'] == true) return true;
      if (cwp['total_days'] is num && (cwp['total_days'] as num) > 1) return true;
    }

    return false;
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
