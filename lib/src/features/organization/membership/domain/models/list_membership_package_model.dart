// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'list_membership_package_model.freezed.dart';
part 'list_membership_package_model.g.dart';

@freezed
class ListMembershipPackagesModel with _$ListMembershipPackagesModel {
  const factory ListMembershipPackagesModel({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') dynamic next,
    @JsonKey(name: 'previous') dynamic previous,
    @JsonKey(name: 'results') List<MembershipPackageModel>? results,
  }) = _ListMembershipPackagesModel;

  factory ListMembershipPackagesModel.fromJson(Map<String, dynamic> json) => _$ListMembershipPackagesModelFromJson(json);
}

@freezed
class MembershipPackageModel with _$MembershipPackageModel {
  const factory MembershipPackageModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'organization') int? organization,
    @JsonKey(name: 'package_type') String? packageType,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'actual_price') String? actualPrice,
    @JsonKey(name: 'offer_price') String? offerPrice,
    @JsonKey(name: 'duration_days') int? durationDays,
    @JsonKey(name: 'features') List<String>? features,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'is_emi_available') bool? isEmiAvailable,
  }) = _MembershipPackageModel;

  factory MembershipPackageModel.fromJson(Map<String, dynamic> json) => _$MembershipPackageModelFromJson(json);
}
