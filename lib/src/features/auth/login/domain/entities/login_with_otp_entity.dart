// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_with_otp_entity.freezed.dart';
part 'login_with_otp_entity.g.dart';

@freezed
class LoginWithOtpEntity with _$LoginWithOtpEntity {
  const factory LoginWithOtpEntity({@JsonKey(name: 'non_field_errors') List<String>? nonFieldErrors}) = _LoginWithOtpEntity;

  factory LoginWithOtpEntity.fromJson(Map<String, dynamic> json) => _$LoginWithOtpEntityFromJson(json);
}
