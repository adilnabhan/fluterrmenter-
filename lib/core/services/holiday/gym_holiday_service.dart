import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

class GymHolidayService {
  static final Map<String, String> _cache = {};

  /// Clears the in-memory holiday cache.
  /// If [orgId] is specified, only that organization's cached holidays are removed.
  static void clearCache([int? orgId]) {
    if (orgId != null) {
      final prefix = '${orgId}_';
      _cache.removeWhere((k, _) => k.startsWith(prefix));
    } else {
      _cache.clear();
    }
  }

  /// Checks if the given date is a gym holiday.
  /// Returns the holiday name if it is a holiday, otherwise returns null.
  static Future<String?> getHolidayName(
    DateTime date, {
    int? orgId,
    bool forceRefresh = false,
  }) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final cacheKey = '${orgId ?? 0}_$dateStr';

    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    // 1. Fetch holidays list for the month from gym holidays endpoint
    bool primaryEndpointSucceeded = false;
    try {
      final monthStr = DateFormat('yyyy-MM').format(date);
      final orgParam =
          (orgId != null && orgId != 0) ? '&organization_id=$orgId' : '';
      final response = await DioClient().dio.get<dynamic>(
        '${ApiUris.gymHolidays}?month=$monthStr$orgParam',
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        primaryEndpointSucceeded = true;
        // Purge any stale cached dates for this org & month so removed holidays are cleared
        final monthPrefix = '${orgId ?? 0}_$monthStr';
        _cache.removeWhere((k, _) => k.startsWith(monthPrefix));

        final list =
            response.data is List
                ? (response.data as List<dynamic>)
                : (response.data is Map && response.data['results'] is List
                    ? (response.data['results'] as List<dynamic>)
                    : <dynamic>[]);

        for (final item in list) {
          if (item is Map && item['date'] != null) {
            final d = item['date'].toString();
            final name =
                (item['title'] ??
                        item['name'] ??
                        item['description'] ??
                        'Gym Holiday')
                    .toString();
            _cache['${orgId ?? 0}_$d'] = name;
          }
        }

        return _cache[cacheKey];
      }
    } catch (_) {}

    // 2. Fallback check via trainer client attendance endpoint only if primary endpoint failed
    if (!primaryEndpointSucceeded) {
      try {
        final response = await DioClient().dio.get<dynamic>(
          '${ApiUris.trainerClientAttendance}?date=$dateStr&include_expired=true&page=1',
          options: Options(headers: {'X-Platform': platformSource}),
        );

        if (response.statusCode == 200 && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          final isHoliday =
              data['is_holiday'] == true ||
              data['is_holiday'] == 1 ||
              data['is_holiday'] == 'true' ||
              data['holiday'] == true ||
              data['status']?.toString().toLowerCase() == 'holiday';

          if (isHoliday) {
            final name =
                (data['holiday_title'] ??
                        data['holiday_name'] ??
                        data['title'] ??
                        'Gym Holiday')
                    .toString();
            _cache[cacheKey] = name;
            return name;
          }
        }
      } catch (_) {}
    }

    return null;
  }

  /// Convenience boolean check
  static Future<bool> isHoliday(
    DateTime date, {
    int? orgId,
    bool forceRefresh = false,
  }) async {
    final holidayName = await getHolidayName(
      date,
      orgId: orgId,
      forceRefresh: forceRefresh,
    );
    return holidayName != null && holidayName.isNotEmpty;
  }

  /// Fetches all gym holidays for a specific month (yyyy-MM).
  /// Returns a map of 'yyyy-MM-dd' -> holiday title.
  static Future<Map<String, String>> getMonthHolidays(
    DateTime month, {
    int? orgId,
    bool forceRefresh = false,
  }) async {
    final monthStr = DateFormat('yyyy-MM').format(month);
    final monthPrefix = '${orgId ?? 0}_$monthStr';

    if (!forceRefresh) {
      final cachedForMonth = <String, String>{};
      for (final entry in _cache.entries) {
        if (entry.key.startsWith(monthPrefix)) {
          final dateStr = entry.key.substring('${orgId ?? 0}_'.length);
          cachedForMonth[dateStr] = entry.value;
        }
      }
      if (cachedForMonth.isNotEmpty) {
        return cachedForMonth;
      }
    }

    try {
      final orgParam =
          (orgId != null && orgId != 0) ? '&organization_id=$orgId' : '';
      final response = await DioClient().dio.get<dynamic>(
        '${ApiUris.gymHolidays}?month=$monthStr$orgParam',
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
        _cache.removeWhere((k, _) => k.startsWith(monthPrefix));

        final list = response.data is List
            ? (response.data as List<dynamic>)
            : (response.data is Map && response.data['results'] is List
                ? (response.data['results'] as List<dynamic>)
                : <dynamic>[]);

        final holidays = <String, String>{};
        for (final item in list) {
          if (item is Map && item['date'] != null) {
            final d = item['date'].toString();
            final name = (item['title'] ??
                    item['name'] ??
                    item['description'] ??
                    'Gym Holiday')
                .toString();
            _cache['${orgId ?? 0}_$d'] = name;
            holidays[d] = name;
          }
        }
        return holidays;
      }
    } catch (_) {}

    return {};
  }
}
