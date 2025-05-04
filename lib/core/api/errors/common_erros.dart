import 'package:mentor_mobile_app/imports_bindings.dart';

class ApiCommonErrors {
  static String? handleNonFieldError({required DioException error}) {
    if (error.response?.data != null && error.response?.data is Map) {
      final data = error.response!.data as Map;
      if (data.containsKey('non_field_errors')) {
        final nonFieldErrors = data['non_field_errors'];
        if (nonFieldErrors is List && nonFieldErrors.isNotEmpty) {
          return nonFieldErrors[0].toString();
        } else if (nonFieldErrors is String) {
          return nonFieldErrors;
        }
      }
    }
    return null;
  }
}
