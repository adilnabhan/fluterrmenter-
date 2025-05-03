import 'package:freezed_annotation/freezed_annotation.dart';

part 'multi_select_data_entity.freezed.dart';
part 'multi_select_data_entity.g.dart';

@freezed
class MultiSelectDataEntity with _$MultiSelectDataEntity {
  const factory MultiSelectDataEntity({@JsonKey(name: 'results') List<MultiSelectSingleDataEntity>? results}) = _MultiSelectDataEntity;

  factory MultiSelectDataEntity.fromJson(Map<String, dynamic> json) => _$MultiSelectDataEntityFromJson(json);
}

@freezed
class MultiSelectSingleDataEntity with _$MultiSelectSingleDataEntity {
  const factory MultiSelectSingleDataEntity({@JsonKey(name: 'id') int? id, @JsonKey(name: 'name') String? name, @JsonKey(name: 'logo') String? logo}) = _MultiSelectSingleDataEntity;

  factory MultiSelectSingleDataEntity.fromJson(Map<String, dynamic> json) => _$MultiSelectSingleDataEntityFromJson(json);
}
