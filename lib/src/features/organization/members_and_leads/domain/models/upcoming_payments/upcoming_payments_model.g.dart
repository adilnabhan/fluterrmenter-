// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upcoming_payments_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpComingPaymentsImpl _$$UpComingPaymentsImplFromJson(
  Map<String, dynamic> json,
) => _$UpComingPaymentsImpl(
  id: (json['id'] as num).toInt(),
  customerDetails: CustomerDetails.fromJson(
    json['customer_details'] as Map<String, dynamic>,
  ),
  planDetails: PlanDetails.fromJson(
    json['plan_details'] as Map<String, dynamic>,
  ),
  endDate: DateTime.parse(json['end_date'] as String),
  daysUntilExpire: (json['days_until_expire'] as num).toInt(),
);

Map<String, dynamic> _$$UpComingPaymentsImplToJson(
  _$UpComingPaymentsImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'customer_details': instance.customerDetails,
  'plan_details': instance.planDetails,
  'end_date': instance.endDate.toIso8601String(),
  'days_until_expire': instance.daysUntilExpire,
};

_$CustomerDetailsImpl _$$CustomerDetailsImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerDetailsImpl(
  fullName: json['full_name'] as String,
  email: json['email'] as String,
  mobileNumber: json['mobile_number'] as String,
  image: json['image'] as String?,
);

Map<String, dynamic> _$$CustomerDetailsImplToJson(
  _$CustomerDetailsImpl instance,
) => <String, dynamic>{
  'full_name': instance.fullName,
  'email': instance.email,
  'mobile_number': instance.mobileNumber,
  'image': instance.image,
};

_$PlanDetailsImpl _$$PlanDetailsImplFromJson(Map<String, dynamic> json) =>
    _$PlanDetailsImpl(
      name: json['name'] as String,
      packageType: json['package_type'] as String,
    );

Map<String, dynamic> _$$PlanDetailsImplToJson(_$PlanDetailsImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'package_type': instance.packageType,
    };
