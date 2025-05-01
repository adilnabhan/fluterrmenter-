// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sent_otp_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SentOtpEntityImpl _$$SentOtpEntityImplFromJson(Map<String, dynamic> json) =>
    _$SentOtpEntityImpl(
      id: json['id'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      process: json['process'] as String?,
      source: json['source'] as String?,
      otp: json['otp'] as String?,
    );

Map<String, dynamic> _$$SentOtpEntityImplToJson(_$SentOtpEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mobile_number': instance.mobileNumber,
      'process': instance.process,
      'source': instance.source,
      'otp': instance.otp,
    };
