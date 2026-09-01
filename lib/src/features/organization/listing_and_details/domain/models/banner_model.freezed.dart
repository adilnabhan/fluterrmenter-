// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'banner_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BannerModel _$BannerModelFromJson(Map<String, dynamic> json) {
  return _BannerModel.fromJson(json);
}

/// @nodoc
mixin _$BannerModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'banner_image')
  String? get bannerImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'title')
  String? get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_number')
  String? get contactNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'redirect_type')
  String? get redirectType => throw _privateConstructorUsedError;

  /// Serializes this BannerModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BannerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BannerModelCopyWith<BannerModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BannerModelCopyWith<$Res> {
  factory $BannerModelCopyWith(
    BannerModel value,
    $Res Function(BannerModel) then,
  ) = _$BannerModelCopyWithImpl<$Res, BannerModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'banner_image') String? bannerImage,
    @JsonKey(name: 'title') String? title,
    @JsonKey(name: 'contact_number') String? contactNumber,
    @JsonKey(name: 'redirect_type') String? redirectType,
  });
}

/// @nodoc
class _$BannerModelCopyWithImpl<$Res, $Val extends BannerModel>
    implements $BannerModelCopyWith<$Res> {
  _$BannerModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BannerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? bannerImage = freezed,
    Object? title = freezed,
    Object? contactNumber = freezed,
    Object? redirectType = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            bannerImage:
                freezed == bannerImage
                    ? _value.bannerImage
                    : bannerImage // ignore: cast_nullable_to_non_nullable
                        as String?,
            title:
                freezed == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String?,
            contactNumber:
                freezed == contactNumber
                    ? _value.contactNumber
                    : contactNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            redirectType:
                freezed == redirectType
                    ? _value.redirectType
                    : redirectType // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BannerModelImplCopyWith<$Res>
    implements $BannerModelCopyWith<$Res> {
  factory _$$BannerModelImplCopyWith(
    _$BannerModelImpl value,
    $Res Function(_$BannerModelImpl) then,
  ) = __$$BannerModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'banner_image') String? bannerImage,
    @JsonKey(name: 'title') String? title,
    @JsonKey(name: 'contact_number') String? contactNumber,
    @JsonKey(name: 'redirect_type') String? redirectType,
  });
}

/// @nodoc
class __$$BannerModelImplCopyWithImpl<$Res>
    extends _$BannerModelCopyWithImpl<$Res, _$BannerModelImpl>
    implements _$$BannerModelImplCopyWith<$Res> {
  __$$BannerModelImplCopyWithImpl(
    _$BannerModelImpl _value,
    $Res Function(_$BannerModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BannerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? bannerImage = freezed,
    Object? title = freezed,
    Object? contactNumber = freezed,
    Object? redirectType = freezed,
  }) {
    return _then(
      _$BannerModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        bannerImage:
            freezed == bannerImage
                ? _value.bannerImage
                : bannerImage // ignore: cast_nullable_to_non_nullable
                    as String?,
        title:
            freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String?,
        contactNumber:
            freezed == contactNumber
                ? _value.contactNumber
                : contactNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        redirectType:
            freezed == redirectType
                ? _value.redirectType
                : redirectType // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BannerModelImpl implements _BannerModel {
  const _$BannerModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'banner_image') this.bannerImage,
    @JsonKey(name: 'title') this.title,
    @JsonKey(name: 'contact_number') this.contactNumber,
    @JsonKey(name: 'redirect_type') this.redirectType,
  });

  factory _$BannerModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BannerModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'banner_image')
  final String? bannerImage;
  @override
  @JsonKey(name: 'title')
  final String? title;
  @override
  @JsonKey(name: 'contact_number')
  final String? contactNumber;
  @override
  @JsonKey(name: 'redirect_type')
  final String? redirectType;

  @override
  String toString() {
    return 'BannerModel(id: $id, bannerImage: $bannerImage, title: $title, contactNumber: $contactNumber, redirectType: $redirectType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BannerModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bannerImage, bannerImage) ||
                other.bannerImage == bannerImage) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.contactNumber, contactNumber) ||
                other.contactNumber == contactNumber) &&
            (identical(other.redirectType, redirectType) ||
                other.redirectType == redirectType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    bannerImage,
    title,
    contactNumber,
    redirectType,
  );

  /// Create a copy of BannerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BannerModelImplCopyWith<_$BannerModelImpl> get copyWith =>
      __$$BannerModelImplCopyWithImpl<_$BannerModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BannerModelImplToJson(this);
  }
}

abstract class _BannerModel implements BannerModel {
  const factory _BannerModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'banner_image') final String? bannerImage,
    @JsonKey(name: 'title') final String? title,
    @JsonKey(name: 'contact_number') final String? contactNumber,
    @JsonKey(name: 'redirect_type') final String? redirectType,
  }) = _$BannerModelImpl;

  factory _BannerModel.fromJson(Map<String, dynamic> json) =
      _$BannerModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'banner_image')
  String? get bannerImage;
  @override
  @JsonKey(name: 'title')
  String? get title;
  @override
  @JsonKey(name: 'contact_number')
  String? get contactNumber;
  @override
  @JsonKey(name: 'redirect_type')
  String? get redirectType;

  /// Create a copy of BannerModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BannerModelImplCopyWith<_$BannerModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
