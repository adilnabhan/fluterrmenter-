
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner_model.freezed.dart';
part 'banner_model.g.dart';

@freezed
class BannerModel with _$BannerModel {
  const factory BannerModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'banner_image') String? bannerImage,
    @JsonKey(name: 'title') String? title,
    @JsonKey(name: 'contact_number') String? contactNumber,
    @JsonKey(name: 'redirect_type') String? redirectType,
  }) = _BannerModel;

  factory BannerModel.fromJson(Map<String, dynamic> json) => _$BannerModelFromJson(json);
}
