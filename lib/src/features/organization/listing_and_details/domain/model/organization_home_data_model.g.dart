// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_home_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrganizationHomeDataModelImpl _$$OrganizationHomeDataModelImplFromJson(
  Map<String, dynamic> json,
) => _$OrganizationHomeDataModelImpl(
  organizationId: (json['organization_id'] as num?)?.toInt(),
  trainerCount: (json['trainer_count'] as num?)?.toInt(),
  activeCustomersCount: (json['active_customers_count'] as num?)?.toInt(),
  upcomingRenewalsCount: (json['upcoming_renewals_count'] as num?)?.toInt(),
  expiredCustomersCount: (json['expired_customers_count'] as num?)?.toInt(),
  upcomingPaymentCount: (json['upcoming_payment_count'] as num?)?.toInt(),
  allPaymentCount: (json['allPayment_count'] as num?)?.toInt(),
  totalCustomersCount: (json['total_customers_count'] as num?)?.toInt(),
  totalCustomers: (json['total_customers'] as num?)?.toInt(),
  freezedCustomersCount: (json['freezed_customers_count'] as num?)?.toInt(),
  memberInsights: json['member_insights'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$OrganizationHomeDataModelImplToJson(
  _$OrganizationHomeDataModelImpl instance,
) => <String, dynamic>{
  'organization_id': instance.organizationId,
  'trainer_count': instance.trainerCount,
  'active_customers_count': instance.activeCustomersCount,
  'upcoming_renewals_count': instance.upcomingRenewalsCount,
  'expired_customers_count': instance.expiredCustomersCount,
  'upcoming_payment_count': instance.upcomingPaymentCount,
  'allPayment_count': instance.allPaymentCount,
  'total_customers_count': instance.totalCustomersCount,
  'total_customers': instance.totalCustomers,
  'freezed_customers_count': instance.freezedCustomersCount,
  'member_insights': instance.memberInsights,
};
