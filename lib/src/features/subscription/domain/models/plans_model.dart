// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'plans_model.freezed.dart';
part 'plans_model.g.dart';

@freezed
class PlansModel with _$PlansModel {
  const factory PlansModel({@JsonKey(name: 'results') List<Result>? results}) = _PlansModel;

  factory PlansModel.fromJson(Map<String, dynamic> json) => _$PlansModelFromJson(json);
}

@freezed
class Result with _$Result {
  const factory Result({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'plan_type') String? planType,
    @JsonKey(name: 'regular_price') String? regularPrice,
    @JsonKey(name: 'discounted_price') String? discountedPrice,
    @JsonKey(name: 'period') int? period,
  }) = _Result;

  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);
}
