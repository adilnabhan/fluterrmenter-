// ignore_for_file: invalid_annotation_target, constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'upcoming_renewal_model.freezed.dart';
part 'upcoming_renewal_model.g.dart';

@freezed
class UpcomingRenewalResponseModel with _$UpcomingRenewalResponseModel {
  const factory UpcomingRenewalResponseModel({
    @JsonKey(name: "count") int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: "results") List<UpcomingRenewalModel>? results,
  }) = _UpcomingRenewalResponseModel;

  factory UpcomingRenewalResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UpcomingRenewalResponseModelFromJson(json);
}

@freezed
class UpcomingRenewalModel with _$UpcomingRenewalModel {
  const factory UpcomingRenewalModel({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "phone") String? phone,
    @JsonKey(name: "whatsapp_link") String? whatsappLink,
    @JsonKey(name: "profile_image") String? profileImage,
    @JsonKey(name: "membership_name") String? membershipName,
    @JsonKey(name: "renewal_date") String? renewalDate,
    @JsonKey(name: "days_remaining") int? daysRemaining,
    @JsonKey(name: "expiry_label") String? expiryLabel,
  }) = _UpcomingRenewalModel;

  factory UpcomingRenewalModel.fromJson(Map<String, dynamic> json) =>
      _$UpcomingRenewalModelFromJson(json);
}
