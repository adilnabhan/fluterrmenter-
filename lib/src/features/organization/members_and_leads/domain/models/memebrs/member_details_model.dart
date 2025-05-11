// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_details_model.freezed.dart';
part 'member_details_model.g.dart';

@freezed
class MemberDetailsModel with _$MemberDetailsModel {
  const factory MemberDetailsModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'emergency_contact_name') String? emergencyContactName,
    @JsonKey(name: 'emergency_contact_number') String? emergencyContactNumber,
    @JsonKey(name: 'height') String? height,
    @JsonKey(name: 'weight') String? weight,
    @JsonKey(name: 'profession') String? profession,
    @JsonKey(name: 'is_active_member') bool? isActiveMember,
    @JsonKey(name: 'memberships') List<MembershipDataModel>? memberships,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'created') DateTime? created,
    @JsonKey(name: 'modified') DateTime? modified,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
    @JsonKey(name: 'gender') String? gender,
    @JsonKey(name: 'blood_group') String? bloodGroup,
    @JsonKey(name: 'user_role') String? userRole,
    @JsonKey(name: 'hash_of_user_phone_number') String? hashOfUserPhoneNumber,
  }) = _MemberDetailsModel;

  factory MemberDetailsModel.fromJson(Map<String, dynamic> json) => _$MemberDetailsModelFromJson(json);
}

@freezed
class MembershipDataModel with _$MembershipDataModel {
  const factory MembershipDataModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'membership') int? membership,
    @JsonKey(name: 'membership_name') String? membershipName,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'assign_free') bool? assignFree,
    @JsonKey(name: 'is_trial') bool? isTrial,
    @JsonKey(name: 'payment_status') String? paymentStatus,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'trial_start_at') DateTime? trialStartAt,
    @JsonKey(name: 'trial_end_at') DateTime? trialEndAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _MembershipDataModel;

  factory MembershipDataModel.fromJson(Map<String, dynamic> json) => _$MembershipDataModelFromJson(json);
}
