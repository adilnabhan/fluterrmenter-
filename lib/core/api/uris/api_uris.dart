import 'package:mentor_mobile_app/imports_bindings.dart';

///* This class contains Api uris
@immutable
final class ApiUris {
  ///* Base Url
  static const _baseUrl = String.fromEnvironment('baseUrl');
  static const _v1 = '$_baseUrl/api/v1/';

  ///============================= Authentication =============================\\\
  static const sentOtp = '${_v1}user/send-otp/';
  static const loginWithOtp = '${_v1}user/otp/verify/';
  static const verifyOtp = '${_v1}user/otp/verification/registration/';
  static const onboarding = '${_v1}user/onboarding/';

  static const logout = '${_v1}user/logout/';

  ///============================= Common =============================\\\
  static const categories = '${_v1}fitnesscenter/categories/';
  static const amenities = '${_v1}fitnesscenter/amenities/';

  ///============================= Organization =============================\\\
  ///
  /// 31/update/
  static const createOrg = '${_v1}fitnesscenter/organization/create/';
  static String onboardingUpdate(int id) =>
      '${_v1}fitnesscenter/organization/$id/update/';
  static const listOrganizations = '${_v1}fitnesscenter/organization/list/';
  static String orgDetails(int orgId) =>
      '${_v1}fitnesscenter/organization/$orgId/';
  static String fetchHomeData(int orgId) =>
      '${_v1}fitnesscenter/home/?organization_id=$orgId';
  static String updateOrg(int orgId) =>
      '${_v1}fitnesscenter/organization/$orgId/update/';
  static String deletePhoto(int orgId, int photoId) =>
      '${_v1}fitnesscenter/organization/$orgId/photos/$photoId/delete';

  ///============================= Subscription =============================\\\
  static const plans = '${_v1}subscription/discipl-subscription-plans/';
  static const initiateRazorpayPayment = '${_v1}subscription/create-order/';
  static const webhook = '${_v1}subscription/webhook/';

  ///============================= Members =============================\\\
  static const membersListing = '${_v1}fitnesscenter/customers/';
  static const createMember = '${_v1}customer/manage/create/';
  static String updateMember(int id) => '${_v1}customer/manage/$id/update/';
  static String memberDetails(int id) => '${_v1}customer/manage/$id/';

  ///============================= Trainers =============================\\\
  static const leadsListing = '${_v1}fitnesscenter/trainers/';
  static const createLead = '${_v1}mentor/trainers/';
  static String updateLead(int id) => '${_v1}mentor/trainers/$id/';
  static String leadDetails(String id) => '${_v1}mentor/trainers/$id/';

  ///============================= Membership =============================\\\
  static const createMembershipPackage =
      '${_v1}fitnesscenter/membership-plans/';
  static const listMembershipPackages = '${_v1}fitnesscenter/membership-plans/';
  static const expiringMembershipPackages =
      '${_v1}fitnesscenter/expiring-memberships/';
  static String updateMembershipPackage(int id) =>
      '${_v1}fitnesscenter/membership-plans/$id/';
  static String deleteMembershipPackage(int id) =>
      '${_v1}fitnesscenter/membership-plans/$id/';

  ///============================= bank =============================\\\
  static String bankDetails(String id) =>
      '${_v1}fitnesscenter/bank-details/$id/';
  static const addBankDetails = '${_v1}fitnesscenter/bank-details/';
}
