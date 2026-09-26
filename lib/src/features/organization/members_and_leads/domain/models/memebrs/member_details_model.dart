// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_details_model.freezed.dart';
part 'member_details_model.g.dart';

@freezed
class MemberDetailsModel with _$MemberDetailsModel {
  const factory MemberDetailsModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'profile_picture') String? profilePicture,
    @JsonKey(name: 'emergency_contact_name') String? emergencyContactName,
    @JsonKey(name: 'emergency_contact_number') String? emergencyContactNumber,
    @JsonKey(name: 'height') String? height,
    @JsonKey(name: 'weight') String? weight,
    @JsonKey(name: 'address') String? address,
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
    @JsonKey(name: 'whatsapp_link') String? whatsappLink,
  }) = _MemberDetailsModel;

  factory MemberDetailsModel.fromJson(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    if (sanitized['user_role'] != null) {
      sanitized['user_role'] = sanitized['user_role'].toString();
    }
    if (sanitized['height'] != null) {
      sanitized['height'] = sanitized['height'].toString();
    }
    if (sanitized['weight'] != null) {
      sanitized['weight'] = sanitized['weight'].toString();
    }
    if (sanitized['emergency_contact_number'] != null) {
      sanitized['emergency_contact_number'] =
          sanitized['emergency_contact_number'].toString();
    }
    if (sanitized['mobile_number'] != null) {
      sanitized['mobile_number'] = sanitized['mobile_number'].toString();
    }
    return _$MemberDetailsModelFromJson(sanitized);
  }
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

  factory MembershipDataModel.fromJson(Map<String, dynamic> json) =>
      _$MembershipDataModelFromJson(json);
}

extension MembershipDataModelX on MembershipDataModel {
  /// The inclusive end date of the membership (the last active day for the member).
  ///
  /// Since the system/backend stores [endDate] as an exclusive expiry boundary
  /// (e.g. startDate + 30 days = 17 Oct 00:00:00), the actual last day the member
  /// can use the gym is [endDate] - 1 day (e.g. 16 Oct).
  DateTime? get inclusiveEndDate {
    if (endDate == null) return null;
    if (startDate != null && endDate!.isAfter(startDate!)) {
      return endDate!.subtract(const Duration(days: 1));
    }
    return endDate;
  }
}
