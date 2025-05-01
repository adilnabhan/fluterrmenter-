// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'logout_entity.freezed.dart';
part 'logout_entity.g.dart';

@freezed
class LogoutEntity with _$LogoutEntity {
  const factory LogoutEntity({@JsonKey(name: 'message') String? message}) = _LogoutEntity;

  factory LogoutEntity.fromJson(Map<String, dynamic> json) => _$LogoutEntityFromJson(json);
}
