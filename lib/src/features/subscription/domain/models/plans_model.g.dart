// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plans_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlansModelImpl _$$PlansModelImplFromJson(Map<String, dynamic> json) =>
    _$PlansModelImpl(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => Result.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PlansModelImplToJson(_$PlansModelImpl instance) =>
    <String, dynamic>{
      'results': instance.results,
    };

_$ResultImpl _$$ResultImplFromJson(Map<String, dynamic> json) => _$ResultImpl(
      id: json['id'] as String?,
      name: json['name'] as String?,
      planType: json['plan_type'] as String?,
      regularPrice: json['regular_price'] as String?,
      discountedPrice: json['discounted_price'] as String?,
      period: (json['period'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ResultImplToJson(_$ResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'plan_type': instance.planType,
      'regular_price': instance.regularPrice,
      'discounted_price': instance.discountedPrice,
      'period': instance.period,
    };
