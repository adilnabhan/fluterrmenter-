// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sent_otp_entity.freezed.dart';
part 'sent_otp_entity.g.dart';

@freezed
class SentOtpEntity with _$SentOtpEntity {
    const factory SentOtpEntity({
        @JsonKey(name: 'id')
        String? id,
        @JsonKey(name: 'mobile_number')
        String? mobileNumber,
        @JsonKey(name: 'process')
        String? process,
        @JsonKey(name: 'source')
        String? source,
        @JsonKey(name: 'otp')
        String? otp,
    }) = _SentOtpEntity;

    factory SentOtpEntity.fromJson(Map<String, dynamic> json) => _$SentOtpEntityFromJson(json);
}
