// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upcoming_renewal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpcomingRenewalResponseModelImpl _$$UpcomingRenewalResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$UpcomingRenewalResponseModelImpl(
  count: (json['count'] as num?)?.toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => UpcomingRenewalModel.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$$UpcomingRenewalResponseModelImplToJson(
  _$UpcomingRenewalResponseModelImpl instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};

_$UpcomingRenewalModelImpl _$$UpcomingRenewalModelImplFromJson(
  Map<String, dynamic> json,
) => _$UpcomingRenewalModelImpl(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  whatsappLink: json['whatsapp_link'] as String?,
  profileImage: json['profile_image'] as String?,
  membershipName: json['membership_name'] as String?,
  renewalDate: json['renewal_date'] as String?,
  daysRemaining: (json['days_remaining'] as num?)?.toInt(),
  expiryLabel: json['expiry_label'] as String?,
);

Map<String, dynamic> _$$UpcomingRenewalModelImplToJson(
  _$UpcomingRenewalModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'phone': instance.phone,
  'whatsapp_link': instance.whatsappLink,
  'profile_image': instance.profileImage,
  'membership_name': instance.membershipName,
  'renewal_date': instance.renewalDate,
  'days_remaining': instance.daysRemaining,
  'expiry_label': instance.expiryLabel,
};
