// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OnboardingEntityImpl _$$OnboardingEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$OnboardingEntityImpl(
      access: json['access'] as String?,
      refresh: json['refresh'] as String?,
      id: (json['id'] as num?)?.toInt(),
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
    );

Map<String, dynamic> _$$OnboardingEntityImplToJson(
        _$OnboardingEntityImpl instance) =>
    <String, dynamic>{
      'access': instance.access,
      'refresh': instance.refresh,
      'id': instance.id,
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
