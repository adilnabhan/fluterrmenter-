// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BannerModelImpl _$$BannerModelImplFromJson(Map<String, dynamic> json) =>
    _$BannerModelImpl(
      id: (json['id'] as num?)?.toInt(),
      bannerImage: json['banner_image'] as String?,
      title: json['title'] as String?,
      contactNumber: json['contact_number'] as String?,
      redirectType: json['redirect_type'] as String?,
    );

Map<String, dynamic> _$$BannerModelImplToJson(_$BannerModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'banner_image': instance.bannerImage,
      'title': instance.title,
      'contact_number': instance.contactNumber,
      'redirect_type': instance.redirectType,
    };
