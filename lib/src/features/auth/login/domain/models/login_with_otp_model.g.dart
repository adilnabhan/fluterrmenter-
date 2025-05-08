// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_with_otp_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginWithOtpEntityImpl _$$LoginWithOtpEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$LoginWithOtpEntityImpl(
      id: (json['id'] as num?)?.toInt(),
      access: json['access'] as String?,
      refresh: json['refresh'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      email: json['email'] as String?,
      bloodGroup: json['blood_group'] as String?,
      lastLogin: json['last_login'] == null
          ? null
          : DateTime.parse(json['last_login'] as String),
      mentor: json['mentor'] == null
          ? null
          : Mentor.fromJson(json['mentor'] as Map<String, dynamic>),
      customer: json['customer'],
      profilePicture: json['profile_picture'],
      warnings: json['warnings'] as List<dynamic>?,
      isProfileCompleted: json['is_profile_complete'] as bool?,
    );

Map<String, dynamic> _$$LoginWithOtpEntityImplToJson(
        _$LoginWithOtpEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'access': instance.access,
      'refresh': instance.refresh,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'mobile_number': instance.mobileNumber,
      'email': instance.email,
      'blood_group': instance.bloodGroup,
      'last_login': instance.lastLogin?.toIso8601String(),
      'mentor': instance.mentor,
      'customer': instance.customer,
      'profile_picture': instance.profilePicture,
      'warnings': instance.warnings,
      'is_profile_complete': instance.isProfileCompleted,
    };

_$MentorImpl _$$MentorImplFromJson(Map<String, dynamic> json) => _$MentorImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$MentorImplToJson(_$MentorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
