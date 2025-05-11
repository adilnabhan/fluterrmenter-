// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemberDetailsModelImpl _$$MemberDetailsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MemberDetailsModelImpl(
      id: (json['id'] as num?)?.toInt(),
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactNumber: json['emergency_contact_number'] as String?,
      height: json['height'] as String?,
      weight: json['weight'] as String?,
      profession: json['profession'] as String?,
      isActiveMember: json['is_active_member'] as bool?,
      memberships: (json['memberships'] as List<dynamic>?)
          ?.map((e) => MembershipDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      fullName: json['full_name'] as String?,
      created: json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
      modified: json['modified'] == null
          ? null
          : DateTime.parse(json['modified'] as String),
      mobileNumber: json['mobile_number'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      dateOfBirth: json['date_of_birth'] == null
          ? null
          : DateTime.parse(json['date_of_birth'] as String),
      gender: json['gender'] as String?,
      bloodGroup: json['blood_group'] as String?,
      userRole: json['user_role'] as String?,
      hashOfUserPhoneNumber: json['hash_of_user_phone_number'] as String?,
    );

Map<String, dynamic> _$$MemberDetailsModelImplToJson(
        _$MemberDetailsModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'emergency_contact_name': instance.emergencyContactName,
      'emergency_contact_number': instance.emergencyContactNumber,
      'height': instance.height,
      'weight': instance.weight,
      'profession': instance.profession,
      'is_active_member': instance.isActiveMember,
      'memberships': instance.memberships,
      'full_name': instance.fullName,
      'created': instance.created?.toIso8601String(),
      'modified': instance.modified?.toIso8601String(),
      'mobile_number': instance.mobileNumber,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'date_of_birth': instance.dateOfBirth?.toIso8601String(),
      'gender': instance.gender,
      'blood_group': instance.bloodGroup,
      'user_role': instance.userRole,
      'hash_of_user_phone_number': instance.hashOfUserPhoneNumber,
    };

_$MembershipDataModelImpl _$$MembershipDataModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MembershipDataModelImpl(
      id: (json['id'] as num?)?.toInt(),
      membership: (json['membership'] as num?)?.toInt(),
      membershipName: json['membership_name'] as String?,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      status: json['status'] as String?,
      amount: json['amount'] as String?,
      assignFree: json['assign_free'] as bool?,
      isTrial: json['is_trial'] as bool?,
      paymentStatus: json['payment_status'] as String?,
      isActive: json['is_active'] as bool?,
      trialStartAt: json['trial_start_at'] == null
          ? null
          : DateTime.parse(json['trial_start_at'] as String),
      trialEndAt: json['trial_end_at'] == null
          ? null
          : DateTime.parse(json['trial_end_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$MembershipDataModelImplToJson(
        _$MembershipDataModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'membership': instance.membership,
      'membership_name': instance.membershipName,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'status': instance.status,
      'amount': instance.amount,
      'assign_free': instance.assignFree,
      'is_trial': instance.isTrial,
      'payment_status': instance.paymentStatus,
      'is_active': instance.isActive,
      'trial_start_at': instance.trialStartAt?.toIso8601String(),
      'trial_end_at': instance.trialEndAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
