// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_membership_package_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ListMembershipPackagesModelImpl _$$ListMembershipPackagesModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ListMembershipPackagesModelImpl(
      count: (json['count'] as num?)?.toInt(),
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>?)
          ?.map(
              (e) => MembershipPackageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ListMembershipPackagesModelImplToJson(
        _$ListMembershipPackagesModelImpl instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results,
    };

_$MembershipPackageModelImpl _$$MembershipPackageModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MembershipPackageModelImpl(
      id: (json['id'] as num?)?.toInt(),
      organization: (json['organization'] as num?)?.toInt(),
      packageType: json['package_type'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      actualPrice: json['actual_price'] as String?,
      offerPrice: json['offer_price'] as String?,
      durationDays: (json['duration_days'] as num?)?.toInt(),
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isActive: json['is_active'] as bool?,
      isEmiAvailable: json['is_emi_available'] as bool?,
    );

Map<String, dynamic> _$$MembershipPackageModelImplToJson(
        _$MembershipPackageModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization': instance.organization,
      'package_type': instance.packageType,
      'name': instance.name,
      'description': instance.description,
      'actual_price': instance.actualPrice,
      'offer_price': instance.offerPrice,
      'duration_days': instance.durationDays,
      'features': instance.features,
      'is_active': instance.isActive,
      'is_emi_available': instance.isEmiAvailable,
    };
