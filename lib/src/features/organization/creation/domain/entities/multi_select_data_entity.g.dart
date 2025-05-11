// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_select_data_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MultiSelectDataEntityImpl _$$MultiSelectDataEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$MultiSelectDataEntityImpl(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) =>
              MultiSelectSingleDataEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MultiSelectDataEntityImplToJson(
        _$MultiSelectDataEntityImpl instance) =>
    <String, dynamic>{
      'results': instance.results,
    };

_$MultiSelectSingleDataEntityImpl _$$MultiSelectSingleDataEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$MultiSelectSingleDataEntityImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      logo: json['logo'] as String?,
      statusString: json['status_string'] as String?,
    );

Map<String, dynamic> _$$MultiSelectSingleDataEntityImplToJson(
        _$MultiSelectSingleDataEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'status_string': instance.statusString,
    };
