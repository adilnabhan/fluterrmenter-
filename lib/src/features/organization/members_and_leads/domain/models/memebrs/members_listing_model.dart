// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'members_listing_model.freezed.dart';
part 'members_listing_model.g.dart';

@freezed
class MembersListingModel with _$MembersListingModel {
  const factory MembersListingModel({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: 'results') List<MemberDataModel>? results,
  }) = _MembersListingModel;

  factory MembersListingModel.fromJson(Map<String, dynamic> json) => _$MembersListingModelFromJson(json);
}

@freezed
class MemberDataModel with _$MemberDataModel {
  const factory MemberDataModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'profile_picture') dynamic profilePicture,
    @JsonKey(name: 'joined_date') DateTime? joinedDate,
    @JsonKey(name: 'active_plan') ActivePlan? activePlan,
  }) = _MemberDataModel;

  factory MemberDataModel.fromJson(Map<String, dynamic> json) => _$MemberDataModelFromJson(json);
}

@freezed
class ActivePlan with _$ActivePlan {
  const factory ActivePlan({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'plan_name') String? planName,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'status') String? status,
  }) = _ActivePlan;

  factory ActivePlan.fromJson(Map<String, dynamic> json) => _$ActivePlanFromJson(json);
}
