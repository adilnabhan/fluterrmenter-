import 'package:mentor_mobile_app/imports_bindings.dart';

///* This class contains Api uris
@immutable
final class ApiUris {
  ///* Base Url
  static const _baseUrlEnv = String.fromEnvironment('baseUrl');
  static final _baseUrl = _baseUrlEnv == ''
      ? 'https://discipl-backend.onrender.com'
      : (_baseUrlEnv.endsWith('/')
          ? _baseUrlEnv.substring(0, _baseUrlEnv.length - 1)
          : _baseUrlEnv);
  static final _v1 = '$_baseUrl/api/v1/';

  ///============================= Authentication =============================\\\
  static final sentOtp = '${_v1}user/send-otp/';
  static final loginWithOtp = '${_v1}user/otp/verify/';
  static final verifyOtp = '${_v1}user/otp/verification/registration/';
  static final tokenRefresh = '${_v1}user/token/refresh/';
  static final onboarding = '${_v1}user/onboarding/';

  static final logout = '${_v1}user/logout/';

  ///============================= Common =============================\\\
  static final categories = '${_v1}fitnesscenter/categories/';
  static final amenities = '${_v1}fitnesscenter/amenities/';

  ///============================= Organization =============================\\\
  ///
  /// 31/update/
  static final createOrg = '${_v1}fitnesscenter/organization/create/';
  static String onboardingUpdate(int id) =>
      '${_v1}fitnesscenter/organization/$id/update/';
  static final listOrganizations = '${_v1}fitnesscenter/organization/list/';
  static String orgDetails(int orgId) =>
      '${_v1}fitnesscenter/organization/$orgId/';
  static String fetchHomeData(int orgId) =>
      '${_v1}fitnesscenter/home/?organization_id=$orgId';
  static String updateOrg(int orgId) =>
      '${_v1}fitnesscenter/organization/$orgId/update/';
  static String deletePhoto(int orgId, int photoId) =>
      '${_v1}fitnesscenter/organization/$orgId/photos/$photoId/delete';

  ///============================= Subscription =============================\\\
  static final plans = '${_v1}subscription/discipl-subscription-plans/';
  static final initiateRazorpayPayment = '${_v1}subscription/create-order/';
  static final webhook = '${_v1}subscription/webhook/';

  ///============================= Members =============================\\\
  static final membersListing = '${_v1}fitnesscenter/customers/';
  static final createMember = '${_v1}customer/manage/create/';
  static String updateMember(int id) => '${_v1}customer/manage/$id/update/';
  static String memberDetails(int id) => '${_v1}customer/manage/$id/';

  ///============================= Trainers =============================\\\
  static final leadsListing = '${_v1}fitnesscenter/trainers/';
  static final createLead = '${_v1}mentor/trainers/';
  static String updateLead(int id) => '${_v1}mentor/trainers/$id/';
  static String leadDetails(String id) => '${_v1}mentor/trainers/$id/';
  static String assignWorkoutPlan(int planId) => '${_v1}trainer/workout-plans/$planId/assign/';

  ///============================= Membership =============================\\\
  static final createMembershipPackage =
      '${_v1}fitnesscenter/membership-plans/';
  static final listMembershipPackages = '${_v1}fitnesscenter/membership-plans/';
  static final expiringMembershipPackages =
      '${_v1}fitnesscenter/expiring-memberships/';
  static String updateMembershipPackage(int id) =>
      '${_v1}fitnesscenter/membership-plans/$id/';
  static String deleteMembershipPackage(int id) =>
      '${_v1}fitnesscenter/membership-plans/$id/';
  static final paymentHistory = '${_v1}fitnesscenter/customer-payments';
  // static String paymentHistory(String orgId) =>
  //     '${_v1}fitnesscenter/customer-payments/$orgId';

  ///============================= bank =============================\\\

  static String bankDetails(String id) =>
      '${_v1}fitnesscenter/bank-details/$id/';
  static final addBankDetails = '${_v1}fitnesscenter/bank-details/';

  ///============================= Trainer =============================\\\
  static final trainerDashboard = '${_v1}trainer/dashboard/';
  static final trainerCustomers = '${_v1}trainer/customers/';
  static String trainerCustomerDetails(int customerId) => '${_v1}trainer/customers/$customerId/';

  ///============================= Workouts =============================\\\
  static final workoutGroups = '${_v1}trainer/workout-groups/';
  static String workoutGroupDetail(int id) => '${_v1}trainer/workout-groups/$id/';
  static final workoutPlans = '${_v1}trainer/workout-plans/';
  static String workoutPlanDetail(int id) => '${_v1}trainer/workout-plans/$id/';
}
