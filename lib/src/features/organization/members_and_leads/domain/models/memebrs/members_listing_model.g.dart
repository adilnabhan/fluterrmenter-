// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'members_listing_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MembersListingModelImpl _$$MembersListingModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MembersListingModelImpl(
      count: (json['count'] as num?)?.toInt(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => MemberDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MembersListingModelImplToJson(
        _$MembersListingModelImpl instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results,
    };

_$MemberDataModelImpl _$$MemberDataModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MemberDataModelImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      profilePicture: json['profile_picture'],
      joinedDate: json['joined_date'] == null
          ? null
          : DateTime.parse(json['joined_date'] as String),
      activePlan: json['active_plan'] == null
          ? null
          : ActivePlan.fromJson(json['active_plan'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MemberDataModelImplToJson(
        _$MemberDataModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'mobile_number': instance.mobileNumber,
      'profile_picture': instance.profilePicture,
      'joined_date': instance.joinedDate?.toIso8601String(),
      'active_plan': instance.activePlan,
    };

_$ActivePlanImpl _$$ActivePlanImplFromJson(Map<String, dynamic> json) =>
    _$ActivePlanImpl(
      id: (json['id'] as num?)?.toInt(),
      planName: json['plan_name'] as String?,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$$ActivePlanImplToJson(_$ActivePlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plan_name': instance.planName,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'status': instance.status,
    };
