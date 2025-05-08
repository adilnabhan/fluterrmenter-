// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_list_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrganizationsListEntityImpl _$$OrganizationsListEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$OrganizationsListEntityImpl(
      success: json['success'] as bool?,
      result: (json['result'] as List<dynamic>?)
          ?.map((e) =>
              SingleOrganizationEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$OrganizationsListEntityImplToJson(
        _$OrganizationsListEntityImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'result': instance.result,
    };

_$SingleOrganizationEntityImpl _$$SingleOrganizationEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$SingleOrganizationEntityImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      category: (json['category'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      logo: json['logo'] as String?,
    );

Map<String, dynamic> _$$SingleOrganizationEntityImplToJson(
        _$SingleOrganizationEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'logo': instance.logo,
    };
