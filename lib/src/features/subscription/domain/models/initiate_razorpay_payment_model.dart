// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'initiate_razorpay_payment_model.freezed.dart';
part 'initiate_razorpay_payment_model.g.dart';

@freezed
class InitiateRazorpayPaymentModel with _$InitiateRazorpayPaymentModel {
  const factory InitiateRazorpayPaymentModel({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'user') User? user,
    @JsonKey(name: 'organization') String? organization,
    @JsonKey(name: 'discipl_plan') DisciplPlan? disciplPlan,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'is_free_plan') bool? isFreePlan,
  }) = _InitiateRazorpayPaymentModel;

  factory InitiateRazorpayPaymentModel.fromJson(Map<String, dynamic> json) => _$InitiateRazorpayPaymentModelFromJson(json);
}

@freezed
class DisciplPlan with _$DisciplPlan {
  const factory DisciplPlan({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'plan_type') String? planType,
    @JsonKey(name: 'regular_price') String? regularPrice,
    @JsonKey(name: 'discounted_price') String? discountedPrice,
    @JsonKey(name: 'period') int? period,
  }) = _DisciplPlan;

  factory DisciplPlan.fromJson(Map<String, dynamic> json) => _$DisciplPlanFromJson(json);
}

@freezed
class User with _$User {
  const factory User({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
