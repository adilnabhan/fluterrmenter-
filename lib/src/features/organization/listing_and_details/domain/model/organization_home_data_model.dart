// To parse this JSON data, do
//
//     final organizationHomeDataModel = organizationHomeDataModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization_home_data_model.freezed.dart';
part 'organization_home_data_model.g.dart';

@freezed
class OrganizationHomeDataModel with _$OrganizationHomeDataModel {
  const factory OrganizationHomeDataModel({
    @JsonKey(name: 'organization_id') int? organizationId,
    @JsonKey(name: 'trainer_count') int? trainerCount,
    @JsonKey(name: 'active_customers_count') int? activeCustomersCount,
    @JsonKey(name: 'upcoming_renewals_count') int? upcomingRenewalsCount,
    @JsonKey(name: 'expired_customers_count') int? expiredCustomersCount,
    @JsonKey(name: 'upcoming_payment_count') int? upcomingPaymentCount,
  }) = _OrganizationHomeDataModel;

  factory OrganizationHomeDataModel.fromJson(Map<String, dynamic> json) => _$OrganizationHomeDataModelFromJson(json);
}
