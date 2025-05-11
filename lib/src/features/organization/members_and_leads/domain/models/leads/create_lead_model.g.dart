// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_lead_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateOrUpdateLeadModelImpl _$$CreateOrUpdateLeadModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateOrUpdateLeadModelImpl(
      id: (json['id'] as num?)?.toInt(),
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      email: json['email'] as String?,
      experience: json['experience'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      gender: json['gender'] as String?,
      bloodGroup: json['blood_group'] as String?,
      dateOfBirth: json['date_of_birth'] == null
          ? null
          : DateTime.parse(json['date_of_birth'] as String),
      addressProof: json['address_proof'],
      certificates: json['certificates'] as List<dynamic>?,
      designation: json['designation'] as String?,
      profilePicture: json['profile_picture'],
      userRole: (json['user_role'] as num?)?.toInt(),
      categoryData: (json['category_data'] as List<dynamic>?)
          ?.map((e) =>
              MultiSelectSingleDataEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$CreateOrUpdateLeadModelImplToJson(
        _$CreateOrUpdateLeadModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'mobile_number': instance.mobileNumber,
      'email': instance.email,
      'experience': instance.experience,
      'emergency_contact': instance.emergencyContact,
      'gender': instance.gender,
      'blood_group': instance.bloodGroup,
      'date_of_birth': instance.dateOfBirth?.toIso8601String(),
      'address_proof': instance.addressProof,
      'certificates': instance.certificates,
      'designation': instance.designation,
      'profile_picture': instance.profilePicture,
      'user_role': instance.userRole,
      'category_data': instance.categoryData,
    };
