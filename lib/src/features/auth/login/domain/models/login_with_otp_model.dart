// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_with_otp_model.g.dart';
part 'login_with_otp_model.freezed.dart';

@freezed
class LoginSuccessModel with _$LoginSuccessModel {
  const factory LoginSuccessModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'access') String? access,
    @JsonKey(name: 'refresh') String? refresh,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'blood_group') String? bloodGroup,
    @JsonKey(name: 'last_login') DateTime? lastLogin,
    @JsonKey(name: 'mentor') Mentor? mentor,
    @JsonKey(name: 'customer') dynamic customer,
    @JsonKey(name: 'profile_picture') dynamic profilePicture,
    @JsonKey(name: 'warnings') List<dynamic>? warnings,
    @JsonKey(name: 'is_profile_complete') bool? isProfileCompleted,
    @JsonKey(name: 'user_role') int? userRole,
  }) = _LoginWithOtpEntity;

  factory LoginSuccessModel.fromJson(Map<String, dynamic> json) =>
      _$LoginSuccessModelFromJson(json);
}

@freezed
class Mentor with _$Mentor {
  const factory Mentor({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'organization') Org? org,
  }) = _Mentor;

  factory Mentor.fromJson(Map<String, dynamic> json) => _$MentorFromJson(json);
}

@freezed
class Org with _$Org {
  const factory Org({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'profile_completeness') int? profileCompleteness,
  }) = _Org;

  factory Org.fromJson(Map<String, dynamic> json) =>
      _$OrgFromJson(json);
}
