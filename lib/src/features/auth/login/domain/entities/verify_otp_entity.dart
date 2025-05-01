// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_otp_entity.freezed.dart';
part 'verify_otp_entity.g.dart';

@freezed
class VerifyOtpEntity with _$VerifyOtpEntity {
  const factory VerifyOtpEntity({@JsonKey(name: 'message') String? message}) = _VerifyOtpEntity;

  factory VerifyOtpEntity.fromJson(Map<String, dynamic> json) => _$VerifyOtpEntityFromJson(json);
}
