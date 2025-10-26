// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emi_options_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmiOptionsModelImpl _$$EmiOptionsModelImplFromJson(
  Map<String, dynamic> json,
) => _$EmiOptionsModelImpl(
  month: (json['number_of_installments'] as num).toInt(),
  price: (json['emi_amount_per_cycle'] as num).toDouble(),
);

Map<String, dynamic> _$$EmiOptionsModelImplToJson(
  _$EmiOptionsModelImpl instance,
) => <String, dynamic>{
  'number_of_installments': instance.month,
  'emi_amount_per_cycle': instance.price,
};
