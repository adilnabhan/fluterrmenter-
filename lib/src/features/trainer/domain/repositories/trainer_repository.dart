import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/trainer/domain/models/bulk_workout_verification_model.dart';

class WorkoutsFetchResult {
  const WorkoutsFetchResult({
    required this.workouts,
    required this.hasMore,
  });

  final List<Map<String, dynamic>> workouts;
  final bool hasMore;
}

class TrainerRepository {
  factory TrainerRepository() {
    _instance ??= TrainerRepository._internal();
    return _instance!;
  }

  TrainerRepository._internal();

  static TrainerRepository? _instance;

  final Dio _dio = DioClient().dio;

  List<Map<String, dynamic>> _parseWorkoutsResponse(
    dynamic data,
    String clientName,
    int customerId,
  ) {
    List<Map<String, dynamic>> list = [];
    if (data is List) {
      list = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } else if (data is Map) {
      if (data['results'] is List && (data['results'] as List).isNotEmpty) {
        list = (data['results'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } else {
        final plans = data['assigned_plans'] is List
            ? (data['assigned_plans'] as List)
            : <dynamic>[];
        final sessions = data['assigned_sessions'] is List
            ? (data['assigned_sessions'] as List)
            : <dynamic>[];
        final workouts = data['assigned_workouts'] is List
            ? (data['assigned_workouts'] as List)
            : <dynamic>[];
        final genericPlans =
            data['plans'] is List ? (data['plans'] as List) : <dynamic>[];
        final dataItems =
            data['data'] is List ? (data['data'] as List) : <dynamic>[];

        final combined = [
          ...plans,
          ...sessions,
          ...workouts,
          ...genericPlans,
          ...dataItems,
        ];
        if (combined.isNotEmpty) {
          list = combined
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      }
    }

    for (final item in list) {
      item['client_name'] =
          item['client_name'] ??
          item['customer_name'] ??
          item['customer']?['name'] ??
          item['client']?['name'] ??
          (clientName != 'Client' ? clientName : null) ??
          'Client';
      item['customer_id'] =
          item['customer_id'] ??
          item['client_id'] ??
          (customerId > 0 ? customerId : null);
    }

    return list;
  }

  WorkoutsFetchResult _parseWorkoutsResponseData(
    dynamic data,
    String clientName,
    int customerId,
    int requestedPage,
    int pageSize,
  ) {
    bool hasMore = false;
    final list = _parseWorkoutsResponse(data, clientName, customerId);

    if (data is Map) {
      if (data['results'] is List) {
        if (data['next'] != null &&
            data['next'].toString().isNotEmpty &&
            data['next'].toString() != 'null') {
          hasMore = true;
        } else if (data['total_pages'] is int) {
          final totalPages = data['total_pages'] as int;
          final currentPage = data['current_page'] as int? ?? requestedPage;
          hasMore = currentPage < totalPages;
        } else {
          hasMore = list.length >= pageSize;
        }
      }
    }

    return WorkoutsFetchResult(workouts: list, hasMore: hasMore);
  }

  Future<WorkoutsFetchResult> fetchAssignedWorkoutsForClient({
    required int customerId,
    required String clientName,
    String? dateStr,
    String? planType,
    int page = 1,
    int pageSize = 20,
  }) async {
    WorkoutsFetchResult result = const WorkoutsFetchResult(workouts: [], hasMore: false);
    bool fetched = false;

    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      'status': 'all',
      if (dateStr != null && dateStr.isNotEmpty) 'date': dateStr,
      if (planType != null && planType.isNotEmpty) 'plan_type': planType,
    };

    // 1. Primary Endpoint
    try {
      final response = await _dio.get<dynamic>(
        ApiUris.trainerClientAssignedWorkouts(customerId),
        queryParameters: queryParams,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200) {
        result = _parseWorkoutsResponseData(
          response.data,
          clientName,
          customerId,
          page,
          pageSize,
        );
        if (result.workouts.isNotEmpty ||
            (response.data is Map &&
                (response.data['results'] as List? ?? []).isEmpty)) {
          fetched = true;
        }
      }
    } catch (_) {}

    // 2. Fallback Endpoint
    if (!fetched) {
      try {
        final response = await _dio.get<dynamic>(
          ApiUris.customerAssignedWorkouts(customerId),
          queryParameters: queryParams,
          options: Options(headers: {'X-Platform': platformSource}),
        );
        if (response.statusCode == 200) {
          result = _parseWorkoutsResponseData(
            response.data,
            clientName,
            customerId,
            page,
            pageSize,
          );
          if (result.workouts.isNotEmpty ||
              (response.data is Map &&
                  (response.data['results'] as List? ?? []).isEmpty)) {
            fetched = true;
          }
        }
      } catch (_) {}
    }

    // 3. Fallback Endpoint All
    if (!fetched) {
      try {
        final response = await _dio.get<dynamic>(
          ApiUris.customerAssignedWorkoutsAll(customerId),
          queryParameters: queryParams,
          options: Options(headers: {'X-Platform': platformSource}),
        );
        if (response.statusCode == 200) {
          result = _parseWorkoutsResponseData(
            response.data,
            clientName,
            customerId,
            page,
            pageSize,
          );
        }
      } catch (_) {}
    }

    return result;
  }

  Future<WorkoutsFetchResult> fetchAllTrainerAssignedWorkouts({
    String? dateStr,
    String? planType,
    int page = 1,
    int pageSize = 20,
  }) async {
    final Map<String, dynamic> queryParams = {
      if (dateStr != null && dateStr.isNotEmpty) 'date': dateStr,
      if (planType != null && planType.isNotEmpty) 'plan_type': planType,
      'status': 'all',
      'page': page,
      'page_size': pageSize,
    };

    try {
      final response = await _dio.get<dynamic>(
        ApiUris.trainerAssignedWorkouts,
        queryParameters: queryParams,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        return _parseWorkoutsResponseData(
          response.data,
          'Client',
          0,
          page,
          pageSize,
        );
      }
    } catch (_) {}

    // Fallback: Fetch clients and query per client
    try {
      final clientsRes = await _dio.get<dynamic>(
        ApiUris.trainerCustomers,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (clientsRes.statusCode == 200) {
        List<dynamic> dataList = [];
        if (clientsRes.data is List) {
          dataList = clientsRes.data as List;
        } else if (clientsRes.data is Map &&
            clientsRes.data['results'] is List) {
          dataList = clientsRes.data['results'] as List;
        }

        final clients =
            dataList.map((e) => Map<String, dynamic>.from(e as Map)).toList();

        final List<Future<WorkoutsFetchResult>> futures = [];
        for (final client in clients) {
          final profile = client['profile'] as Map? ?? client;
          final cid = client['id'] as int? ?? client['customer_id'] as int?;
          final cname =
              profile['name']?.toString() ??
              profile['first_name']?.toString() ??
              'Client';
          if (cid != null) {
            futures.add(fetchAssignedWorkoutsForClient(
              customerId: cid,
              clientName: cname,
              dateStr: dateStr,
              planType: planType,
            ));
          }
        }

        final results = await Future.wait(futures);
        final List<Map<String, dynamic>> combinedWorkouts = [];
        for (final res in results) {
          combinedWorkouts.addAll(res.workouts);
        }

        return WorkoutsFetchResult(workouts: combinedWorkouts, hasMore: false);
      }
    } catch (_) {}

    return const WorkoutsFetchResult(workouts: [], hasMore: false);
  }

  Future<bool> deleteAssignedWorkout(int assignmentId) async {
    try {
      final response = await _dio.delete<dynamic>(
        ApiUris.trainerDeleteAssignedWorkout(assignmentId),
        options: Options(headers: {'X-Platform': platformSource}),
      );
      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 202) {
        return true;
      }
    } catch (_) {}

    return false;
  }

  Future<BulkWorkoutVerificationResponse> bulkVerifyWorkoutSessions({
    required List<int> sessionIds,
    String verificationStatus = 'verified',
    String? remarks,
  }) async {
    final payload = <String, dynamic>{
      'session_ids': sessionIds,
      'verification_status': verificationStatus,
      if (remarks != null && remarks.trim().isNotEmpty)
        'remarks': remarks.trim()
      else
        'remarks': 'Batch verified by trainer',
    };

    final response = await _dio.post<dynamic>(
      ApiUris.bulkVerifyWorkoutSessions,
      data: payload,
      options: Options(headers: {'X-Platform': platformSource}),
    );

    if (response.data is Map) {
      return BulkWorkoutVerificationResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    return BulkWorkoutVerificationResponse(
      message: 'Verified ${sessionIds.length} workout session(s)',
      successCount: sessionIds.length,
      failureCount: 0,
      totalCount: sessionIds.length,
    );
  }
}
