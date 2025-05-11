// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leads_listing_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeadsListingModelImpl _$$LeadsListingModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LeadsListingModelImpl(
      count: (json['count'] as num?)?.toInt(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => Result.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$LeadsListingModelImplToJson(
        _$LeadsListingModelImpl instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results,
    };

_$ResultImpl _$$ResultImplFromJson(Map<String, dynamic> json) => _$ResultImpl(
      id: (json['id'] as num?)?.toInt(),
      userId: json['user_id'] as String?,
      name: json['name'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      email: json['email'] as String?,
      designation: json['designation'] as String?,
      created: json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
      profilePicture: json['profile_picture'],
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$ResultImplToJson(_$ResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'mobile_number': instance.mobileNumber,
      'email': instance.email,
      'designation': instance.designation,
      'created': instance.created?.toIso8601String(),
      'profile_picture': instance.profilePicture,
      'categories': instance.categories,
    };
