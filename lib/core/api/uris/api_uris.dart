import 'package:mentor_mobile_app/imports_bindings.dart';

///* This class contains Api uris
@immutable
final class ApiUris {
  ///* Base Url
  static const _baseUrlEnv = String.fromEnvironment('baseUrl');
  static final _baseUrl =
      _baseUrlEnv == ''
          ? 'https://discipl-backend.onrender.com'
          : (_baseUrlEnv.endsWith('/')
              ? _baseUrlEnv.substring(0, _baseUrlEnv.length - 1)
              : _baseUrlEnv);
  static String get baseUrl => _baseUrl;
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
  static String fitnessCenterReviews(int orgId) =>
      '${_v1}fitnesscenter/organization/$orgId/reviews/';

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
      '${_v1}fitnesscenter/organization/photos/$photoId/delete/';
  static final fcOrganizationReviews =
      '${_v1}fitnesscenter/organization/reviews/';

  ///============================= Subscription =============================\\\
  static final plans = '${_v1}subscription/discipl-subscription-plans/';
  static final initiateRazorpayPayment = '${_v1}subscription/create-order/';
  static final webhook = '${_v1}subscription/webhook/';

  ///============================= Members =============================\\\
  static final membersListing = '${_v1}fitnesscenter/customers/';
  static final createMember = '${_v1}customer/manage/create/';
  static String updateMember(int id) => '${_v1}customer/manage/$id/update/';
  static String memberDetails(int id) => '${_v1}customer/manage/$id/';
  static final searchCustomer = '${_v1}customer/search/';
  static String customerBodyMatrix(dynamic customerId) =>
      '${_v1}customer/body-matrix/?customer_id=$customerId';

  ///============================= Trainers =============================\\\
  static final leadsListing = '${_v1}fitnesscenter/trainers/';
  static String removeTrainerFromGym(dynamic linkId) =>
      '${_v1}fitnesscenter/trainers/$linkId/remove/';
  static final createLead = '${_v1}mentor/trainers/';
  static String updateLead(int id) => '${_v1}mentor/trainers/$id/';
  static String leadDetails(String id) => '${_v1}mentor/trainers/$id/';
  static final searchTrainer = '${_v1}fitnesscenter/trainers/search/';
  static final addExistingTrainer = '${_v1}fitnesscenter/trainers/add-existing/';
  static String assignWorkoutPlan(int planId) =>
      '${_v1}trainer/workout-plans/$planId/assign/';
  static String saveWorkoutPlanAsTemplate(int planId) =>
      '${_v1}trainer/workout-plans/$planId/save-as-template/';

  ///============================= Membership =============================\\\
  static final createMembershipPackage =
      '${_v1}fitnesscenter/membership-plans/';
  static final listMembershipPackages = '${_v1}fitnesscenter/membership-plans/';
  static final manualMembershipEntry =
      '${_v1}fitnesscenter/memberships/manual-entry/';
  static final customerRenewals = '${_v1}fitnesscenter/customer_renewals/';
  static String updateMembershipPackage(int id) =>
      '${_v1}fitnesscenter/membership-plans/$id/';
  static String deleteMembershipPackage(int id) =>
      '${_v1}fitnesscenter/membership-plans/$id/';
  // New endpoints for editing and canceling a client membership
  static String updateCustomerMembership(int id) =>
      '${_v1}fitnesscenter/customer-memberships/$id/';
  static String cancelCustomerMembership(int id) =>
      '${_v1}fitnesscenter/customer-memberships/$id/cancel/';
  static final paymentHistory = '${_v1}fitnesscenter/customer-payments/';
  static final reports = '${_v1}fitnesscenter/reports/';
  static final reportsCustomers = '${_v1}fitnesscenter/reports/customers/';
  static final clientWorkoutCalendar = '${_v1}fitnesscenter/reports/client-workout-calendar/';
  static String clientWorkoutCalendarDetail(String date) => '${_v1}fitnesscenter/reports/client-workout-calendar/$date/';
  static final expenses = '${_v1}fitnesscenter/expenses/';
  static String expenseDetail(int id) => '${_v1}fitnesscenter/expenses/$id/';
  static final revenueCategories = '${_v1}fitnesscenter/revenue-categories/';
  static String revenueCategoryDetail(int id) => '${_v1}fitnesscenter/revenue-categories/$id/';
  static final revenues = '${_v1}fitnesscenter/revenues/';
  static String revenueDetail(int id) => '${_v1}fitnesscenter/revenues/$id/';
  static final revenueReports = '${_v1}fitnesscenter/revenue-reports/';
  static final revenueTargets = '${_v1}fitnesscenter/revenue-targets/';
  static final budget = '${_v1}fitnesscenter/budget/';
  static final trainerAttendance = '${_v1}fitnesscenter/trainer-attendance/';
  static String trainerAttendanceDetail(int id) => '${_v1}fitnesscenter/trainer-attendance/$id/';
  static String trainerAttendanceSessionDelete(int id) => '${_v1}fitnesscenter/trainer-attendance/session/$id/';
  static final trainerAttendanceReports = '${_v1}fitnesscenter/trainer-attendance/reports/';
  static final clientAttendance = '${_v1}fitnesscenter/client-attendance/';
  static String clientAttendanceDetail(int id) => '${_v1}fitnesscenter/client-attendance/$id/';
  static final clientAttendanceReport = '${_v1}fitnesscenter/client-attendance/report/';
  static final clientAttendanceDashboard = '${_v1}fitnesscenter/client-attendance/dashboard/';
  static final gymHolidays = '${_v1}fitnesscenter/holidays/';
  static String gymHolidayDetail(int id) => '${_v1}fitnesscenter/holidays/$id/';
  // static String paymentHistory(String orgId) =>
  //     '${_v1}fitnesscenter/customer-payments/$orgId';

  ///============================= bank =============================\\\

  static String bankDetails(String id) =>
      '${_v1}fitnesscenter/bank-details/$id/';
  static final addBankDetails = '${_v1}fitnesscenter/bank-details/';

  ///============================= Trainer =============================\\\
  static final editTrainerBasicDetails =
      '${_v1}trainer/trainers/basic-details/';
  static final trainerDashboard = '${_v1}trainer/dashboard/';
  static final trainerCustomers = '${_v1}trainer/customers/';
  static String trainerCustomerDetails(int customerId) =>
      '${_v1}trainer/customers/$customerId/';
  static final trainerAssignedWorkouts = '${_v1}trainer/assigned-workouts/';
  static String trainerDeleteAssignedWorkout(int customerWorkoutPlanId) =>
      '${_v1}trainer/assigned-workouts/$customerWorkoutPlanId/';
  static String trainerClientAssignedWorkouts(int customerId) =>
      '${_v1}trainer/clients/$customerId/assigned-workouts/';
  static String customerAssignedWorkouts(int customerId) =>
      '${_v1}customers/assigned-workouts/?customer_id=$customerId&status=all';
  static String customerAssignedWorkoutsAll(int customerId) =>
      '${_v1}customers/assigned-workouts-all/?customer_id=$customerId';
  static final trainerReports = '${_v1}trainer/reports/';
  static final trainerClientsTrained = '${_v1}trainer/reports/clients-trained/';
  static final trainerReviews = '${_v1}trainer/reviews/';
  static final trainerClientAttendance = '${_v1}trainer/client-attendance/';
  static final trainerClientAttendanceMark =
      '${_v1}trainer/client-attendance/mark/';

  ///============================= Certificates & Portfolio =============================\\\
  static final certificates = '${_v1}trainer/certificates/';
  static String deleteCertificate(int id) => '${_v1}trainer/certificates/$id/';
  static final portfolioImages = '${_v1}trainer/portfolio-images/';
  static String deletePortfolioImage(int id) =>
      '${_v1}trainer/portfolio-images/$id/';
  
  ///============================= Transformations =============================\\\
  static final transformations = '${_v1}fitnesscenter/transformations/';
  static String deleteTransformation(int id) => '${_v1}fitnesscenter/transformations/$id/';
  static String trainerTransformationImages(String trainerId) =>
      '${_v1}mentor/trainers/$trainerId/transformation-images/';
  static String deleteTrainerTransformationImage(String trainerId, dynamic imageId) =>
      '${_v1}mentor/trainers/$trainerId/transformation-images/$imageId/';

  ///============================= Workouts =============================\\\
  static final gymExercises = '${_v1}fitnesscenter/exercises/';
  static final createGymExercise = '${_v1}fitnesscenter/exercises/create/';
  static String editGymExercise(int id) => '${_v1}fitnesscenter/exercises/$id/';
  static String deleteGymExercise(int id) => '${_v1}fitnesscenter/exercises/$id/';
  static final gymWorkoutLibrary = '${_v1}fitnesscenter/workout-library/';
  static String gymWorkoutLibraryDetail(int id) => '${_v1}fitnesscenter/workout-library/$id/';
  static final gymWorkoutGroups = '${_v1}fitnesscenter/workout-groups/';
  static final workoutGroups = '${_v1}trainer/workout-groups/';
  static String workoutGroupDetail(int id) =>
      '${_v1}trainer/workout-groups/$id/';
  static final workoutPlans = '${_v1}trainer/workout-plans/';
  static String workoutPlanDetail(int id) => '${_v1}trainer/workout-plans/$id/';
  static String copyWorkoutPlan(int id) => '${_v1}trainer/workout-plans/$id/copy/';
  static final muscleGroups = '${_v1}trainer/muscle-groups/';
  static final equipment = '${_v1}trainer/equipment/';
  static final exerciseTypes = '${_v1}trainer/exercise-types/';
  static final workoutExercises = '${_v1}trainer/exercises/';
  static final customerExercises = '${_v1}customers/exercises/';
  static final trainerMuscleClassification = '${_v1}trainer/muscle-classification/';
  static final customerMuscleClassification = '${_v1}customers/muscle-classification/';
  static final gymMuscleClassification = '${_v1}fitnesscenter/muscle-classification/';

  // Plan-day exercise endpoints
  static String planDayExercises(int dayId) =>
      '${_v1}trainer/plan-days/$dayId/exercises/';
  static String planDayExerciseDetail(int dayId, int exerciseId) =>
      '${_v1}trainer/plan-days/$dayId/exercises/$exerciseId/';
  static String planDayExercisesReorder(int dayId) =>
      '${_v1}trainer/plan-days/$dayId/exercises/reorder/';

  // Multi-Day Workout endpoints
  static final multiDayAssign = '${_v1}trainer/multi-day-assign/';
  static String multiDayAssignPreview({
    required int customerId,
    required String startDate,
    required String endDate,
    required String planType,
  }) =>
      '${_v1}trainer/multi-day-assign/preview/?customer_id=$customerId&start_date=$startDate&end_date=$endDate&plan_type=$planType';
  static String assignWorkoutPlanTemplate(int planId) =>
      '${_v1}trainer/workout-plans/$planId/assign/';
  static String workoutPlanDays(int planId) =>
      '${_v1}trainer/workout-plans/$planId/days/';
  static String updateMultiDayAssignmentDay(int cwpId, int planDayId) =>
      '${_v1}trainer/multi-day-assign/$cwpId/days/$planDayId/';

  // Customer workout history
  static String customerWorkoutHistory(int customerId) =>
      '${_v1}trainer/customers/$customerId/workout-history/';

  // Client Calendar & History
  static String clientCalendar(int customerId) =>
      '${_v1}mentor/clients/$customerId/calendar/';

  ///============================= Verification =============================\\\
  static final pendingVerifications = '${_v1}mentor/verification/pending/';
  static String verifyWorkoutSession(int sessionId) =>
      '${_v1}mentor/verification/verify/$sessionId/';
  static String workoutSessionDetails(int sessionId) =>
      '${_v1}mentor/verification/session/$sessionId/';
  static final verificationHistory = '${_v1}mentor/verification/history/';

  ///============================= Gym Banners =============================\\\
  static final gymBanners = '${_v1}fitnesscenter/gym-banners/';
  static String gymBannerDetail(int id) =>
      '${_v1}fitnesscenter/gym-banners/$id/';

  ///============================= Upcoming Payments =============================\\\
  static final upcomingPayments = '${_v1}fitnesscenter/upcoming-payments/';
  static String markUpcomingPaymentPaid(int id) =>
      '${_v1}fitnesscenter/upcoming-payments/$id/mark-paid/';
  static String upcomingPaymentDetail(int id) =>
      '${_v1}fitnesscenter/upcoming-payments/$id/';

  ///============================= Communication & Notifications =============================\\\
  static final registerDeviceToken = '${_v1}communication/device-token/register/';
}