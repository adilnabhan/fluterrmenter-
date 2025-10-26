import 'package:freezed_annotation/freezed_annotation.dart';


part 'upcoming_payments_model.freezed.dart';
part 'upcoming_payments_model.g.dart';

@freezed
class UpComingPayments with _$UpComingPayments {
  const factory UpComingPayments({
    @JsonKey(name: "id")
    required int id,
    @JsonKey(name: "customer_details")
    required CustomerDetails customerDetails,
    @JsonKey(name: "plan_details")
    required PlanDetails planDetails,
    @JsonKey(name: "end_date")
    required DateTime endDate,
    @JsonKey(name: "days_until_expire")
    required int daysUntilExpire,
  }) = _UpComingPayments;

  factory UpComingPayments.fromJson(Map<String, dynamic> json) => _$UpComingPaymentsFromJson(json);
}

@freezed
class CustomerDetails with _$CustomerDetails {
  const factory CustomerDetails({
    @JsonKey(name: "full_name")
    required String fullName,
    @JsonKey(name: "email")
    required String email,
    @JsonKey(name: "mobile_number")
    required String mobileNumber,
    @JsonKey(name: "image")
    String? image,
  }) = _CustomerDetails;

  factory CustomerDetails.fromJson(Map<String, dynamic> json) => _$CustomerDetailsFromJson(json);
}

@freezed
class PlanDetails with _$PlanDetails {
  const factory PlanDetails({
    @JsonKey(name: "name")
    required String name,
    @JsonKey(name: "package_type")
    required String packageType,
  }) = _PlanDetails;

  factory PlanDetails.fromJson(Map<String, dynamic> json) => _$PlanDetailsFromJson(json);
}
