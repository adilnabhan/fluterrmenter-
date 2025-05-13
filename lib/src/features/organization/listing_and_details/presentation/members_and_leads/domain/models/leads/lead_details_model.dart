// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:mentor_mobile_app/imports_bindings.dart';

part 'lead_details_model.freezed.dart';
part 'lead_details_model.g.dart';

@freezed
class LeadDetailsModel with _$LeadDetailsModel {
  const factory LeadDetailsModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'gender') String? gender,
    @JsonKey(name: 'blood_group') String? bloodGroup,
    @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
    @JsonKey(name: 'mentor_profile') MentorProfileData? mentorProfile,
    @JsonKey(name: 'certificates') List<dynamic>? certificates,
    @JsonKey(name: 'profile_picture') dynamic profilePicture,
  }) = _LeadDetailsModel;

  factory LeadDetailsModel.fromJson(Map<String, dynamic> json) => _$LeadDetailsModelFromJson(json);
}

@freezed
class MentorProfileData with _$MentorProfileData {
  const factory MentorProfileData({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'organization') Organization? organization,
    @JsonKey(name: 'experience') String? experience,
    @JsonKey(name: 'designation') String? designation,
    @JsonKey(name: 'emergency_contact') String? emergencyContact,
    @JsonKey(name: 'address_proof') dynamic addressProof,
    @JsonKey(name: 'categories') List<MultiSelectSingleDataEntity>? categories,
  }) = _MentorProfileData;

  factory MentorProfileData.fromJson(Map<String, dynamic> json) => _$MentorProfileDataFromJson(json);
}

@freezed
class Organization with _$Organization {
  const factory Organization({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'category') List<int>? category,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'logo') dynamic logo,
  }) = _Organization;

  factory Organization.fromJson(Map<String, dynamic> json) => _$OrganizationFromJson(json);
}
