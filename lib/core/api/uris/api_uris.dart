import 'package:mentor_mobile_app/imports_bindings.dart';

///* This class contains Api uris
@immutable
final class ApiUris {
  ///* BASE URL
  static const _baseUrl = String.fromEnvironment('baseUrl');
  static const _v1 = '$_baseUrl/api/v1/';

  ///============================= AUTH =============================\\\
  static const sentOtp = '${_v1}user/send-otp/';
  static const loginWithOtp = '${_v1}user/otp/verify/';
  static const verifyOtp = '${_v1}user/otp/verification/registration/';
  static const onboarding = '${_v1}user/onboarding/';
  static const logout = '${_v1}user/logout/';

  ///============================= Common =============================\\\
  static const categories = '${_v1}fitnesscenter/categories/';
  static const amenities = '${_v1}fitnesscenter/amenities/';

  ///============================= Organization =============================\\\
  static const createOrg = '${_v1}fitnesscenter/organization/create/';
  static const listOrganizations = '${_v1}fitnesscenter/organization/list/';
  static String orgDetails(int orgId) => '${_v1}fitnesscenter/organization/$orgId/';
  static String fetchHomeData(int orgId) => '${_v1}fitnesscenter/home/?organization_id=$orgId';

  ///============================= Subscription =============================\\\
  static const plans = '${_v1}subscription/discipl-subscription-plans/';
  static const initiateRazorpayPayment = '${_v1}subscription/create-order/';
  static const webhook = '${_v1}subscription/webhook/';
}
