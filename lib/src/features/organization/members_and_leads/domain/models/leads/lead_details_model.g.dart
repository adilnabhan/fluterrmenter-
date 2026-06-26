// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeadDetailsModelImpl _$$LeadDetailsModelImplFromJson(
  Map<String, dynamic> json,
) => _$LeadDetailsModelImpl(
  id: (json['id'] as num?)?.toInt(),
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  mobileNumber: json['mobile_number'] as String?,
  email: json['email'] as String?,
  gender: json['gender'] as String?,
  bloodGroup: json['blood_group'] as String?,
  dateOfBirth:
      json['date_of_birth'] == null
          ? null
          : DateTime.parse(json['date_of_birth'] as String),
  mentorProfile:
      json['mentor_profile'] == null
          ? null
          : MentorProfileData.fromJson(
            json['mentor_profile'] as Map<String, dynamic>,
          ),
  certificates: json['certificates'] as List<dynamic>?,
  profilePicture: json['profile_picture'],
);

Map<String, dynamic> _$$LeadDetailsModelImplToJson(
  _$LeadDetailsModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'mobile_number': instance.mobileNumber,
  'email': instance.email,
  'gender': instance.gender,
  'blood_group': instance.bloodGroup,
  'date_of_birth': instance.dateOfBirth?.toIso8601String(),
  'mentor_profile': instance.mentorProfile,
  'certificates': instance.certificates,
  'profile_picture': instance.profilePicture,
};

_$MentorProfileDataImpl _$$MentorProfileDataImplFromJson(
  Map<String, dynamic> json,
) => _$MentorProfileDataImpl(
  id: (json['id'] as num?)?.toInt(),
  organization:
      json['organization'] == null
          ? null
          : Organization.fromJson(json['organization'] as Map<String, dynamic>),
  experience: json['experience'] as String?,
  designation: json['designation'] as String?,
  emergencyContact: json['emergency_contact'] as String?,
  addressProof: json['address_proof'],
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map(
            (e) =>
                MultiSelectSingleDataEntity.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$$MentorProfileDataImplToJson(
  _$MentorProfileDataImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization': instance.organization,
  'experience': instance.experience,
  'designation': instance.designation,
  'emergency_contact': instance.emergencyContact,
  'address_proof': instance.addressProof,
  'categories': instance.categories,
};

_$OrganizationImpl _$$OrganizationImplFromJson(Map<String, dynamic> json) =>
    _$OrganizationImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      category:
          (json['category'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList(),
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      logo: json['logo'],
    );

Map<String, dynamic> _$$OrganizationImplToJson(_$OrganizationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'logo': instance.logo,
    };
