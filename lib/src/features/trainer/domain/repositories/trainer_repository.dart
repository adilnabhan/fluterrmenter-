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
    int customerId, [
    String? planType,
  ]) {
    List<Map<String, dynamic>> list = [];
    if (data is List) {
      list = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } else if (data is Map) {
      if (data['results'] is List && (data['results'] as List).isNotEmpty) {
        list = (data['results'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } else {
        // Check for specific non-empty list instead of blindly combining all lists,
        // which caused duplicate cards when the backend returned data under multiple keys
        final candidates = [
          data['assigned_workouts'],
          data['assigned_plans'],
          data['data'],
          data['plans'],
          data['assigned_sessions'],
        ];
        List<dynamic>? matchedList;
        for (final c in candidates) {
          if (c is List && c.isNotEmpty) {
            matchedList = c;
            break;
          }
        }
        if (matchedList != null) {
          list = matchedList
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      }
    }

    final uniqueList = <Map<String, dynamic>>[];
    final seenKeys = <String>{};

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
      if (planType != null && planType.isNotEmpty) {
        item['plan_type'] ??= planType;
      }

      final rawId = item['id'] ??
          item['customer_workout_plan_id'] ??
          item['assignment_id'] ??
          item['session_id'];

      final title = (item['plan_name'] ??
              item['title'] ??
              item['name'] ??
              item['workout_plan_name'] ??
              '')
          .toString()
          .trim()
          .toLowerCase();

      final date = (item['start_date'] ??
              item['scheduled_date'] ??
              item['session_date'] ??
              item['assigned_date'] ??
              item['date'] ??
              item['created_at'] ??
              '')
          .toString();
      final normalizedDate = date.length >= 10 ? date.substring(0, 10) : date;

      final client = (item['client_name'] ??
              item['customer_name'] ??
              item['customer_id'] ??
              (customerId > 0 ? customerId : ''))
          .toString()
          .trim()
          .toLowerCase();

      final key = title.isNotEmpty && normalizedDate.isNotEmpty
          ? '${client}_${title}_$normalizedDate'
          : (title.isNotEmpty
              ? '${client}_$title'
              : (rawId != null && rawId != 0 && rawId != '0'
                  ? 'id_$rawId'
                  : '${item.hashCode}'));

      if (!seenKeys.contains(key)) {
        seenKeys.add(key);
        uniqueList.add(item);
      }
    }

    return uniqueList;
  }

  WorkoutsFetchResult _parseWorkoutsResponseData(
    dynamic data,
    String clientName,
    int customerId,
    int requestedPage,
    int pageSize, [
    String? planType,
  ]) {
    bool hasMore = false;
    final list =
        _parseWorkoutsResponse(data, clientName, customerId, planType);

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
      final url = ApiUris.trainerClientAssignedWorkouts(customerId);
      debugPrint('🔍 [AssignedWorkouts] Calling Primary Endpoint: $url with params: $queryParams');
      final response = await _dio.get<dynamic>(
        url,
        queryParameters: queryParams,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      debugPrint('🔍 [AssignedWorkouts] Primary status: ${response.statusCode}');
      if (response.statusCode == 200) {
        result = _parseWorkoutsResponseData(
          response.data,
          clientName,
          customerId,
          page,
          pageSize,
          planType,
        );
        debugPrint('🔍 [AssignedWorkouts] Primary parsed workouts: ${result.workouts.length}');
        fetched = true;
      }
    } catch (e) {
      debugPrint('🔍 [AssignedWorkouts] Primary Endpoint failed: $e');
    }

    // 2. Fallback Endpoint
    if (!fetched) {
      try {
        final url = ApiUris.customerAssignedWorkouts(customerId);
        debugPrint('🔍 [AssignedWorkouts] Calling Fallback 1: $url with params: $queryParams');
        final response = await _dio.get<dynamic>(
          url,
          queryParameters: queryParams,
          options: Options(headers: {'X-Platform': platformSource}),
        );
        debugPrint('🔍 [AssignedWorkouts] Fallback 1 status: ${response.statusCode}');
        if (response.statusCode == 200) {
          result = _parseWorkoutsResponseData(
            response.data,
            clientName,
            customerId,
            page,
            pageSize,
            planType,
          );
          debugPrint('🔍 [AssignedWorkouts] Fallback 1 parsed workouts: ${result.workouts.length}');
          fetched = true;
        }
      } catch (e) {
        debugPrint('🔍 [AssignedWorkouts] Fallback 1 failed: $e');
      }
    }

    // 3. Fallback Endpoint All
    if (!fetched) {
      try {
        final url = ApiUris.customerAssignedWorkoutsAll(customerId);
        debugPrint('🔍 [AssignedWorkouts] Calling Fallback 2: $url with params: $queryParams');
        final response = await _dio.get<dynamic>(
          url,
          queryParameters: queryParams,
          options: Options(headers: {'X-Platform': platformSource}),
        );
        debugPrint('🔍 [AssignedWorkouts] Fallback 2 status: ${response.statusCode}');
        if (response.statusCode == 200) {
          result = _parseWorkoutsResponseData(
            response.data,
            clientName,
            customerId,
            page,
            pageSize,
            planType,
          );
          debugPrint('🔍 [AssignedWorkouts] Fallback 2 parsed workouts: ${result.workouts.length}');
        }
      } catch (e) {
        debugPrint('🔍 [AssignedWorkouts] Fallback 2 failed: $e');
      }
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
      final url = ApiUris.trainerAssignedWorkouts;
      debugPrint('🔍 [AssignedWorkouts] Calling TrainerAssignedWorkouts: $url with params: $queryParams');
      final response = await _dio.get<dynamic>(
        url,
        queryParameters: queryParams,
        options: Options(headers: {'X-Platform': platformSource}),
      );
      debugPrint('🔍 [AssignedWorkouts] TrainerAssignedWorkouts status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final parsed = _parseWorkoutsResponseData(
          response.data,
          'Client',
          0,
          page,
          pageSize,
          planType,
        );
        debugPrint('🔍 [AssignedWorkouts] TrainerAssignedWorkouts parsed workouts: ${parsed.workouts.length}');
        return parsed;
      }
    } catch (e) {
      debugPrint('🔍 [AssignedWorkouts] TrainerAssignedWorkouts failed or not supported: $e');
    }

    // Fallback: Fetch clients and query per client
    try {
      debugPrint('🔍 [AssignedWorkouts] Running fallback: fetch customers and query per customer');
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

        final seenCids = <int>{};
        final List<Future<WorkoutsFetchResult>> futures = [];
        for (final client in clients) {
          final profile = client['profile'] as Map? ?? client;
          final cid = client['id'] as int? ?? client['customer_id'] as int?;
          final cname =
              profile['name']?.toString() ??
              profile['first_name']?.toString() ??
              'Client';
          if (cid != null && !seenCids.contains(cid)) {
            seenCids.add(cid);
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
        final seenCombinedKeys = <String>{};
        for (final res in results) {
          for (final w in res.workouts) {
            final title = (w['plan_name'] ?? w['title'] ?? w['name'] ?? '').toString().trim().toLowerCase();
            final date = (w['start_date'] ?? w['scheduled_date'] ?? w['session_date'] ?? w['assigned_date'] ?? w['date'] ?? '').toString().trim();
            final normDate = date.length >= 10 ? date.substring(0, 10) : date;
            final client = (w['client_name'] ?? w['customer_name'] ?? w['customer_id'] ?? '').toString().trim().toLowerCase();
            final rawId = w['id'] ?? w['customer_workout_plan_id'] ?? w['session_id'];
            final key = title.isNotEmpty && normDate.isNotEmpty
                ? '${client}_${title}_$normDate'
                : (title.isNotEmpty ? '${client}_$title' : 'id_$rawId');
            if (!seenCombinedKeys.contains(key)) {
              seenCombinedKeys.add(key);
              combinedWorkouts.add(w);
            }
          }
        }

        debugPrint('🔍 [AssignedWorkouts] Fallback completed with ${combinedWorkouts.length} unique workouts across ${seenCids.length} clients');
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
      'remarks': remarks?.trim() ?? '',
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
