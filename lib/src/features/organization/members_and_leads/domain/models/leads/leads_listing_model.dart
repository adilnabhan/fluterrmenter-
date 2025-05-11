// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'leads_listing_model.freezed.dart';
part 'leads_listing_model.g.dart';

@freezed
class LeadsListingModel with _$LeadsListingModel {
  const factory LeadsListingModel({
    @JsonKey(name: 'count') int? count,
    @JsonKey(name: 'next') String? next,
    @JsonKey(name: 'previous') String? previous,
    @JsonKey(name: 'results') List<Result>? results,
  }) = _LeadsListingModel;

  factory LeadsListingModel.fromJson(Map<String, dynamic> json) => _$LeadsListingModelFromJson(json);
}

@freezed
class Result with _$Result {
  const factory Result({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'designation') String? designation,
    @JsonKey(name: 'created') DateTime? created,
    @JsonKey(name: 'profile_picture') dynamic profilePicture,
    @JsonKey(name: 'categories') List<String>? categories,
  }) = _Result;

  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);
}
