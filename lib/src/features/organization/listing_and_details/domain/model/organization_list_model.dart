import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization_list_model.freezed.dart';
part 'organization_list_model.g.dart';

@freezed
class OrganizationsListModel with _$OrganizationsListModel {
  const factory OrganizationsListModel({bool? success, List<SingleOrganizationModel>? result}) = _OrganizationsListModel;

  factory OrganizationsListModel.fromJson(Map<String, dynamic> json) => _$OrganizationsListModelFromJson(json);
}

@freezed
class SingleOrganizationModel with _$SingleOrganizationModel {
  const factory SingleOrganizationModel({int? id, String? name, List<int>? category, String? email, String? phoneNumber, String? logo}) = _SingleOrganizationModel;

  factory SingleOrganizationModel.fromJson(Map<String, dynamic> json) => _$SingleOrganizationModelFromJson(json);
}
