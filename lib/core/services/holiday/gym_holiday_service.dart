import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

class GymHolidayService {
  static final Map<String, String> _cache = {};

  /// Checks if the given date is a gym holiday.
  /// Returns the holiday name if it is a holiday, otherwise returns null.
  static Future<String?> getHolidayName(DateTime date, {int? orgId}) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    if (_cache.containsKey(dateStr)) {
      return _cache[dateStr];
    }

    // 1. Fetch holidays list for the month from gym holidays endpoint
    try {
      final monthStr = DateFormat('yyyy-MM').format(date);
      final orgParam =
          (orgId != null && orgId != 0) ? '&organization_id=$orgId' : '';
      final response = await DioClient().dio.get<dynamic>(
        '${ApiUris.gymHolidays}?month=$monthStr$orgParam',
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200) {
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
            _cache[d] = name;
          }
        }

        if (_cache.containsKey(dateStr)) {
          return _cache[dateStr];
        }
      }
    } catch (_) {}

    // 2. Fallback check via trainer client attendance endpoint
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
          _cache[dateStr] = name;
          return name;
        }
      }
    } catch (_) {}

    return null;
  }

  /// Convenience boolean check
  static Future<bool> isHoliday(DateTime date, {int? orgId}) async {
    final holidayName = await getHolidayName(date, orgId: orgId);
    return holidayName != null && holidayName.isNotEmpty;
  }
}
