// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrganizationsListModelImpl _$$OrganizationsListModelImplFromJson(
        Map<String, dynamic> json) =>
    _$OrganizationsListModelImpl(
      success: json['success'] as bool?,
      result: (json['result'] as List<dynamic>?)
          ?.map((e) =>
              SingleOrganizationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$OrganizationsListModelImplToJson(
        _$OrganizationsListModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'result': instance.result,
    };

_$SingleOrganizationModelImpl _$$SingleOrganizationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SingleOrganizationModelImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      category: (json['category'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      logo: json['logo'] as String?,
    );

Map<String, dynamic> _$$SingleOrganizationModelImplToJson(
        _$SingleOrganizationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'logo': instance.logo,
    };
