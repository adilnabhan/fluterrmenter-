// ignore_for_file: invalid_annotation_target, constant_identifier_names, join_return_with_assignment
import 'package:mentor_mobile_app/imports_bindings.dart';

part 'create_lead_model.freezed.dart';
part 'create_lead_model.g.dart';

@freezed
class CreateOrUpdateLeadModel with _$CreateOrUpdateLeadModel {
  const factory CreateOrUpdateLeadModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'experience') String? experience,
    @JsonKey(name: 'emergency_contact') String? emergencyContact,
    @JsonKey(name: 'gender') String? gender,
    @JsonKey(name: 'blood_group') String? bloodGroup,
    @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
    @JsonKey(name: 'address_proof') dynamic addressProof,
    @JsonKey(name: 'certificates') List<dynamic>? certificates,
    @JsonKey(name: 'designation') String? designation,
    @JsonKey(name: 'profile_picture') dynamic profilePicture,
    @JsonKey(name: 'user_role') int? userRole,
    @JsonKey(name: 'category_data') List<MultiSelectSingleDataEntity>? categoryData,
  }) = _CreateOrUpdateLeadModel;

  factory CreateOrUpdateLeadModel.fromJson(Map<String, dynamic> json) => _$CreateOrUpdateLeadModelFromJson(json);
}
