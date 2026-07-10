// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_with_otp_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginWithOtpEntityImpl _$$LoginWithOtpEntityImplFromJson(
  Map<String, dynamic> json,
) => _$LoginWithOtpEntityImpl(
  id: (json['id'] as num?)?.toInt(),
  access: json['access'] as String?,
  refresh: json['refresh'] as String?,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  mobileNumber: json['mobile_number'] as String?,
  email: json['email'] as String?,
  bloodGroup: json['blood_group'] as String?,
  lastLogin:
      json['last_login'] == null
          ? null
          : DateTime.parse(json['last_login'] as String),
  mentor:
      json['mentor'] == null
          ? null
          : Mentor.fromJson(json['mentor'] as Map<String, dynamic>),
  customer: json['customer'],
  profilePicture: json['profile_picture'],
  warnings: json['warnings'] as List<dynamic>?,
  isProfileCompleted: json['is_profile_complete'] as bool?,
  userRole: (json['user_role'] as num?)?.toInt(),
  gender: json['gender'] as String?,
  dateOfBirth: json['date_of_birth'] as String?,
  experienceYears: (json['experience_years'] as num?)?.toInt(),
  bio: json['bio'] as String?,
  location: json['location'] as String?,
  instagram: json['instagram'] as String?,
  facebook: json['facebook'] as String?,
  youtube: json['youtube'] as String?,
  trainer:
      json['trainer'] == null
          ? null
          : TrainerModel.fromJson(json['trainer'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$LoginWithOtpEntityImplToJson(
  _$LoginWithOtpEntityImpl instance,
) => <String, dynamic>{
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
  'user_role': instance.userRole,
  'gender': instance.gender,
  'date_of_birth': instance.dateOfBirth,
  'experience_years': instance.experienceYears,
  'bio': instance.bio,
  'location': instance.location,
  'instagram': instance.instagram,
  'facebook': instance.facebook,
  'youtube': instance.youtube,
  'trainer': instance.trainer,
};

_$MentorImpl _$$MentorImplFromJson(Map<String, dynamic> json) => _$MentorImpl(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  org:
      json['organization'] == null
          ? null
          : Org.fromJson(json['organization'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$MentorImplToJson(_$MentorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'organization': instance.org,
    };

_$TrainerModelImpl _$$TrainerModelImplFromJson(Map<String, dynamic> json) =>
    _$TrainerModelImpl(
      id: (json['id'] as num?)?.toInt(),
      userType: json['user_type'] as String?,
      profileStep: (json['profile_step'] as num?)?.toInt(),
      certificates:
          (json['certificates'] as List<dynamic>?)
              ?.map((e) => CertificateModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      portfolioImages:
          (json['portfolio_images'] as List<dynamic>?)
              ?.map(
                (e) => PortfolioImageModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );

Map<String, dynamic> _$$TrainerModelImplToJson(_$TrainerModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_type': instance.userType,
      'profile_step': instance.profileStep,
      'certificates': instance.certificates,
      'portfolio_images': instance.portfolioImages,
    };

_$CertificateModelImpl _$$CertificateModelImplFromJson(
  Map<String, dynamic> json,
) => _$CertificateModelImpl(
  id: (json['id'] as num?)?.toInt(),
  name: json['certificate_name'] as String?,
  certificate: json['certificate_file'] as String?,
  issuedDate: json['issued_date'] as String?,
  issuingAuthority: json['issued_by'] as String?,
);

Map<String, dynamic> _$$CertificateModelImplToJson(
  _$CertificateModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'certificate_name': instance.name,
  'certificate_file': instance.certificate,
  'issued_date': instance.issuedDate,
  'issued_by': instance.issuingAuthority,
};

_$PortfolioImageModelImpl _$$PortfolioImageModelImplFromJson(
  Map<String, dynamic> json,
) => _$PortfolioImageModelImpl(
  id: (json['id'] as num?)?.toInt(),
  image: json['image'] as String?,
  type: json['type'] as String?,
);

Map<String, dynamic> _$$PortfolioImageModelImplToJson(
  _$PortfolioImageModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'image': instance.image,
  'type': instance.type,
};

_$OrgImpl _$$OrgImplFromJson(Map<String, dynamic> json) => _$OrgImpl(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  profileCompleteness: (json['profile_completeness'] as num?)?.toInt(),
);

Map<String, dynamic> _$$OrgImplToJson(_$OrgImpl instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'profile_completeness': instance.profileCompleteness,
};
