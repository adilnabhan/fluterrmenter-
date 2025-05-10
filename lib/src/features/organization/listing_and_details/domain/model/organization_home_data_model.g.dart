// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_home_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrganizationHomeDataModelImpl _$$OrganizationHomeDataModelImplFromJson(
        Map<String, dynamic> json) =>
    _$OrganizationHomeDataModelImpl(
      organizationId: (json['organization_id'] as num?)?.toInt(),
      trainerCount: (json['trainer_count'] as num?)?.toInt(),
      activeCustomersCount: (json['active_customers_count'] as num?)?.toInt(),
      upcomingRenewalsCount: (json['upcoming_renewals_count'] as num?)?.toInt(),
      expiredCustomersCount: (json['expired_customers_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$OrganizationHomeDataModelImplToJson(
        _$OrganizationHomeDataModelImpl instance) =>
    <String, dynamic>{
      'organization_id': instance.organizationId,
      'trainer_count': instance.trainerCount,
      'active_customers_count': instance.activeCustomersCount,
      'upcoming_renewals_count': instance.upcomingRenewalsCount,
      'expired_customers_count': instance.expiredCustomersCount,
    };
