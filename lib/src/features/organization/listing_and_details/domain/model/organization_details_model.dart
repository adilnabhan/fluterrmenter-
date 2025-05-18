// To parse this JSON data, do
//
//     final organizationDetailsModel = organizationDetailsModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization_details_model.freezed.dart';
part 'organization_details_model.g.dart';

@freezed
class OrganizationDetailsModel with _$OrganizationDetailsModel {
  const factory OrganizationDetailsModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'is_public') bool? isPublic,
    @JsonKey(name: 'active') bool? active,
    @JsonKey(name: 'is_subscribed') bool? isSubscribed,
    @JsonKey(name: 'take_free_trial') bool? takeFreeTrial,
    @JsonKey(name: 'is_on_free_trial') bool? isOnFreeTrial,
    @JsonKey(name: 'location') LocationModel? location,
    @JsonKey(name: 'working_days') List<WorkingDayModel>? workingDays,
    @JsonKey(name: 'social_media') List<dynamic>? socialMedia,
    @JsonKey(name: 'services') List<AmenityModel>? services,
    @JsonKey(name: 'amenities') List<AmenityModel>? amenities,
    @JsonKey(name: 'categories') List<AmenityModel>? categories,
    @JsonKey(name: 'photos') List<PhotoModel>? photos,
    @JsonKey(name: 'packages') List<dynamic>? packages,
    @JsonKey(name: 'subscription_details') dynamic subscriptionDetails,
  }) = _OrganizationDetailsModel;

  factory OrganizationDetailsModel.fromJson(Map<String, dynamic> json) => _$OrganizationDetailsModelFromJson(json);
}

@freezed
class AmenityModel with _$AmenityModel {
  const factory AmenityModel({@JsonKey(name: 'id') int? id, @JsonKey(name: 'name') String? name}) = _AmenityModel;

  factory AmenityModel.fromJson(Map<String, dynamic> json) => _$AmenityModelFromJson(json);
}

@freezed
class LocationModel with _$LocationModel {
  const factory LocationModel({
    @JsonKey(name: 'building_name') String? buildingName,
    @JsonKey(name: 'street') String? street,
    @JsonKey(name: 'city') String? city,
    @JsonKey(name: 'state') String? state,
    @JsonKey(name: 'pin_code') String? pinCode,
    @JsonKey(name: 'latitude') dynamic latitude,
    @JsonKey(name: 'longitude') dynamic longitude,
  }) = _LocationModel;

  factory LocationModel.fromJson(Map<String, dynamic> json) => _$LocationModelFromJson(json);
}

@freezed
class PhotoModel with _$PhotoModel {
  const factory PhotoModel({@JsonKey(name: 'id') int? id, @JsonKey(name: 'image') String? image, @JsonKey(name: 'caption') String? caption, @JsonKey(name: 'is_primary') bool? isPrimary}) =
      _PhotoModel;

  factory PhotoModel.fromJson(Map<String, dynamic> json) => _$PhotoModelFromJson(json);
}

@freezed
class WorkingDayModel with _$WorkingDayModel {
  const factory WorkingDayModel({
    @JsonKey(name: 'day') String? day,
    @JsonKey(name: 'is_open') bool? isOpen,
    @JsonKey(name: 'morning_opening_time') String? morningOpeningTime,
    @JsonKey(name: 'morning_closing_time') String? morningClosingTime,
    @JsonKey(name: 'evening_opening_time') String? eveningOpeningTime,
    @JsonKey(name: 'evening_closing_time') String? eveningClosingTime,
  }) = _WorkingDayModel;

  factory WorkingDayModel.fromJson(Map<String, dynamic> json) => _$WorkingDayModelFromJson(json);
}
