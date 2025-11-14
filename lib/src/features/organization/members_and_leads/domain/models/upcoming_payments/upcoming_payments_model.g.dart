// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upcoming_payments_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpComingPaymentsImpl _$$UpComingPaymentsImplFromJson(
  Map<String, dynamic> json,
) => _$UpComingPaymentsImpl(
  count: (json['count'] as num).toInt(),
  next: json['next'],
  previous: json['previous'],
  results:
      (json['results'] as List<dynamic>)
          .map((e) => UpComingPaymentsList.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$$UpComingPaymentsImplToJson(
  _$UpComingPaymentsImpl instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};

_$UpComingPaymentsListImpl _$$UpComingPaymentsListImplFromJson(
  Map<String, dynamic> json,
) => _$UpComingPaymentsListImpl(
  id: (json['id'] as num).toInt(),
  customerDetails: CustomerDetails.fromJson(
    json['customer_details'] as Map<String, dynamic>,
  ),
  endDate: DateTime.parse(json['end_date'] as String),
  daysUntilExpire: (json['days_until_expire'] as num).toInt(),
);

Map<String, dynamic> _$$UpComingPaymentsListImplToJson(
  _$UpComingPaymentsListImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'customer_details': instance.customerDetails,
  'end_date': instance.endDate.toIso8601String(),
  'days_until_expire': instance.daysUntilExpire,
};

_$CustomerDetailsImpl _$$CustomerDetailsImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerDetailsImpl(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  mobileNumber: json['mobile_number'] as String,
  profilePicture: json['profile_picture'] as String?,
  joinedDate: json['joined_date'] as String,
  activePlans: ActivePlans.fromJson(
    json['active_plan'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$$CustomerDetailsImplToJson(
  _$CustomerDetailsImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'mobile_number': instance.mobileNumber,
  'profile_picture': instance.profilePicture,
  'joined_date': instance.joinedDate,
  'active_plan': instance.activePlans,
};

_$ActivePlansImpl _$$ActivePlansImplFromJson(Map<String, dynamic> json) =>
    _$ActivePlansImpl(
      id: (json['id'] as num).toInt(),
      planName: json['plan_name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String,
    );

Map<String, dynamic> _$$ActivePlansImplToJson(_$ActivePlansImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plan_name': instance.planName,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'status': instance.status,
    };
