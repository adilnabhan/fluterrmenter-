// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_with_otp_entity.freezed.dart';
part 'login_with_otp_entity.g.dart';

@freezed
class LoginSuccessEntity with _$LoginSuccessEntity {
  const factory LoginSuccessEntity({
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
    @JsonKey(name: 'is_profile_completed') bool? isProfileCompleted,
  }) = _LoginWithOtpEntity;

  factory LoginSuccessEntity.fromJson(Map<String, dynamic> json) => _$LoginSuccessEntityFromJson(json);
}

@freezed
class Mentor with _$Mentor {
  const factory Mentor({@JsonKey(name: 'id') int? id, @JsonKey(name: 'name') String? name}) = _Mentor;

  factory Mentor.fromJson(Map<String, dynamic> json) => _$MentorFromJson(json);
}
