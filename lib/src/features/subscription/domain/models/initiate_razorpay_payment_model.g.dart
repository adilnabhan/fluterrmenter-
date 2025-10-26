// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initiate_razorpay_payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InitiateRazorpayPaymentModelImpl _$$InitiateRazorpayPaymentModelImplFromJson(
  Map<String, dynamic> json,
) => _$InitiateRazorpayPaymentModelImpl(
  id: json['id'] as String?,
  orderId: json['order_id'] as String?,
  user:
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
  organization: json['organization'] as String?,
  disciplPlan:
      json['discipl_plan'] == null
          ? null
          : DisciplPlan.fromJson(json['discipl_plan'] as Map<String, dynamic>),
  amount: json['amount'] as String?,
);

Map<String, dynamic> _$$InitiateRazorpayPaymentModelImplToJson(
  _$InitiateRazorpayPaymentModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'order_id': instance.orderId,
  'user': instance.user,
  'organization': instance.organization,
  'discipl_plan': instance.disciplPlan,
  'amount': instance.amount,
};

_$DisciplPlanImpl _$$DisciplPlanImplFromJson(Map<String, dynamic> json) =>
    _$DisciplPlanImpl(
      id: json['id'] as String?,
      name: json['name'] as String?,
      planType: json['plan_type'] as String?,
      regularPrice: json['regular_price'] as String?,
      discountedPrice: json['discounted_price'] as String?,
      period: (json['period'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$DisciplPlanImplToJson(_$DisciplPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'plan_type': instance.planType,
      'regular_price': instance.regularPrice,
      'discounted_price': instance.discountedPrice,
      'period': instance.period,
    };

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: (json['id'] as num?)?.toInt(),
  email: json['email'] as String?,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  mobileNumber: json['mobile_number'] as String?,
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'mobile_number': instance.mobileNumber,
    };
