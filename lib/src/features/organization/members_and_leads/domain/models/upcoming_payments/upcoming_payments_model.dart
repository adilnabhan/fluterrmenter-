import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'upcoming_payments_model.freezed.dart';
part 'upcoming_payments_model.g.dart';

@freezed
class UpComingPayments with _$UpComingPayments {
  const factory UpComingPayments({
    @JsonKey(name: "count") required int count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: "results") required List<UpComingPaymentsList> results,
  }) = _UpComingPayments;

  factory UpComingPayments.fromJson(Map<String, dynamic> json) =>
      _$UpComingPaymentsFromJson(json);
}

@freezed
class UpComingPaymentsList with _$UpComingPaymentsList {
  const factory UpComingPaymentsList({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "customer_details")
    required CustomerDetails customerDetails,
    @JsonKey(name: "end_date") required DateTime endDate,
    @JsonKey(name: "days_until_expire") required int daysUntilExpire,
  }) = _UpComingPaymentsList;

  factory UpComingPaymentsList.fromJson(Map<String, dynamic> json) =>
      _$UpComingPaymentsListFromJson(json);
}

@freezed
class CustomerDetails with _$CustomerDetails {
  const factory CustomerDetails({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "name") required String name,
    @JsonKey(name: "mobile_number") required String mobileNumber,
    @JsonKey(name: "profile_picture") String? profilePicture,
    @JsonKey(name: "joined_date") required String joinedDate,
    @JsonKey(name: "active_plan") required ActivePlans activePlans,
  }) = _CustomerDetails;

  factory CustomerDetails.fromJson(Map<String, dynamic> json) =>
      _$CustomerDetailsFromJson(json);
}

@freezed
class ActivePlans with _$ActivePlans {
  const factory ActivePlans({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "plan_name") required String planName,
    @JsonKey(name: "start_date") required DateTime startDate,
    @JsonKey(name: "end_date") required DateTime endDate,
    @JsonKey(name: "status") required String status,
  }) = _ActivePlans;

  factory ActivePlans.fromJson(Map<String, dynamic> json) =>
      _$ActivePlansFromJson(json);
}
