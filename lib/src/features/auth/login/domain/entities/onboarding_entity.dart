// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_entity.freezed.dart';
part 'onboarding_entity.g.dart';

@freezed
class OnboardingEntity with _$OnboardingEntity {
    const factory OnboardingEntity({
        @JsonKey(name: 'access')
        String? access,
        @JsonKey(name: 'refresh')
        String? refresh,
        @JsonKey(name: 'id')
        int? id,
        @JsonKey(name: 'first_name')
        String? firstName,
        @JsonKey(name: 'last_name')
        String? lastName,
        @JsonKey(name: 'mobile_number')
        String? mobileNumber,
        @JsonKey(name: 'email')
        String? email,
        @JsonKey(name: 'blood_group')
        String? bloodGroup,
        @JsonKey(name: 'last_login')
        DateTime? lastLogin,
        @JsonKey(name: 'mentor')
        Mentor? mentor,
        @JsonKey(name: 'customer')
        dynamic customer,
        @JsonKey(name: 'profile_picture')
        dynamic profilePicture,
        @JsonKey(name: 'warnings')
        List<dynamic>? warnings,
    }) = _OnboardingEntity;

    factory OnboardingEntity.fromJson(Map<String, dynamic> json) => _$OnboardingEntityFromJson(json);
}

@freezed
class Mentor with _$Mentor {
    const factory Mentor({
        @JsonKey(name: 'id')
        int? id,
        @JsonKey(name: 'name')
        String? name,
    }) = _Mentor;

    factory Mentor.fromJson(Map<String, dynamic> json) => _$MentorFromJson(json);
}
