import 'package:mentor_mobile_app/imports_bindings.dart';

///* This class contains Api uris
@immutable
final class ApiUris {
  ///* BASE URL
  static const _baseUrl = String.fromEnvironment('baseUrl');
  static const _v1 = '$_baseUrl/api/v1/';

  ///============================= AUTH MODULE =============================\\\
  static const sentOtp = '${_v1}user/send-otp/';
  static const loginWithOtp = '${_v1}user/otp/verify/';
  static const verifyOtp = '${_v1}user/otp/verification/registration/';
  static const onboarding = '${_v1}user/onboarding/';
  static const logout = '${_v1}user/logout/';
}
