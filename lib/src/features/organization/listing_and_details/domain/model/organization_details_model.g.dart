// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrganizationDetailsModelImpl _$$OrganizationDetailsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$OrganizationDetailsModelImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      email: json['email'] as String?,
      logo: json['logo'] as String?,
      phoneNumber: json['phone_number'] as String?,
      isPublic: json['is_public'] as bool?,
      active: json['active'] as bool?,
      isSubscribed: json['is_subscribed'] as bool?,
      takeFreeTrial: json['take_free_trial'] as bool?,
      isOnFreeTrial: json['is_on_free_trial'] as bool?,
      location: json['location'] == null
          ? null
          : LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      workingDays: (json['working_days'] as List<dynamic>?)
          ?.map((e) => WorkingDayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      socialMedia: (json['social_media'] as List<dynamic>?)
          ?.map((e) => SocialMediaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => AmenityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => AmenityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => AmenityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => PhotoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      packages: json['packages'] as List<dynamic>?,
      subscriptionDetails: json['subscription_details'],
    );

Map<String, dynamic> _$$OrganizationDetailsModelImplToJson(
        _$OrganizationDetailsModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'email': instance.email,
      'logo': instance.logo,
      'phone_number': instance.phoneNumber,
      'is_public': instance.isPublic,
      'active': instance.active,
      'is_subscribed': instance.isSubscribed,
      'take_free_trial': instance.takeFreeTrial,
      'is_on_free_trial': instance.isOnFreeTrial,
      'location': instance.location,
      'working_days': instance.workingDays,
      'social_media': instance.socialMedia,
      'services': instance.services,
      'amenities': instance.amenities,
      'categories': instance.categories,
      'photos': instance.photos,
      'packages': instance.packages,
      'subscription_details': instance.subscriptionDetails,
    };

_$AmenityModelImpl _$$AmenityModelImplFromJson(Map<String, dynamic> json) =>
    _$AmenityModelImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$AmenityModelImplToJson(_$AmenityModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

_$LocationModelImpl _$$LocationModelImplFromJson(Map<String, dynamic> json) =>
    _$LocationModelImpl(
      buildingName: json['building_name'] as String?,
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pinCode: json['pin_code'] as String?,
      latitude: json['latitude'],
      longitude: json['longitude'],
    );

Map<String, dynamic> _$$LocationModelImplToJson(_$LocationModelImpl instance) =>
    <String, dynamic>{
      'building_name': instance.buildingName,
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'pin_code': instance.pinCode,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

_$PhotoModelImpl _$$PhotoModelImplFromJson(Map<String, dynamic> json) =>
    _$PhotoModelImpl(
      id: (json['id'] as num?)?.toInt(),
      image: json['image'] as String?,
      caption: json['caption'] as String?,
      isPrimary: json['is_primary'] as bool?,
    );

Map<String, dynamic> _$$PhotoModelImplToJson(_$PhotoModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image': instance.image,
      'caption': instance.caption,
      'is_primary': instance.isPrimary,
    };

_$SocialMediaModelImpl _$$SocialMediaModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SocialMediaModelImpl(
      id: (json['id'] as num?)?.toInt(),
      platform: json['platform'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$$SocialMediaModelImplToJson(
        _$SocialMediaModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'platform': instance.platform,
      'url': instance.url,
    };

_$WorkingDayModelImpl _$$WorkingDayModelImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkingDayModelImpl(
      day: json['day'] as String?,
      isOpen: json['is_open'] as bool?,
      morningOpeningTime: json['morning_opening_time'] as String?,
      morningClosingTime: json['morning_closing_time'] as String?,
      eveningOpeningTime: json['evening_opening_time'] as String?,
      eveningClosingTime: json['evening_closing_time'] as String?,
    );

Map<String, dynamic> _$$WorkingDayModelImplToJson(
        _$WorkingDayModelImpl instance) =>
    <String, dynamic>{
      'day': instance.day,
      'is_open': instance.isOpen,
      'morning_opening_time': instance.morningOpeningTime,
      'morning_closing_time': instance.morningClosingTime,
      'evening_opening_time': instance.eveningOpeningTime,
      'evening_closing_time': instance.eveningClosingTime,
    };
