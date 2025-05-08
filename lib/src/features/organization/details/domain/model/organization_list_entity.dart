import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization_list_entity.freezed.dart';
part 'organization_list_entity.g.dart';

@freezed
class OrganizationsListEntity with _$OrganizationsListEntity {
  const factory OrganizationsListEntity({bool? success, List<SingleOrganizationEntity>? result}) = _OrganizationsListEntity;

  factory OrganizationsListEntity.fromJson(Map<String, dynamic> json) => _$OrganizationsListEntityFromJson(json);
}

@freezed
class SingleOrganizationEntity with _$SingleOrganizationEntity {
  const factory SingleOrganizationEntity({int? id, String? name, List<int>? category, String? email, String? phoneNumber, String? logo}) = _SingleOrganizationEntity;

  factory SingleOrganizationEntity.fromJson(Map<String, dynamic> json) => _$SingleOrganizationEntityFromJson(json);
}
