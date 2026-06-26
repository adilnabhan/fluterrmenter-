// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_details_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrganizationDetailsModel _$OrganizationDetailsModelFromJson(
  Map<String, dynamic> json,
) {
  return _OrganizationDetailsModel.fromJson(json);
}

/// @nodoc
mixin _$OrganizationDetailsModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'description')
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'email')
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo')
  String? get logo => throw _privateConstructorUsedError;
  @JsonKey(name: 'phone_number')
  String? get phoneNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_public')
  bool? get isPublic => throw _privateConstructorUsedError;
  @JsonKey(name: 'active')
  bool? get active => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_subscribed')
  bool? get isSubscribed => throw _privateConstructorUsedError;
  @JsonKey(name: 'take_free_trial')
  bool? get takeFreeTrial => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_on_free_trial')
  bool? get isOnFreeTrial => throw _privateConstructorUsedError;
  @JsonKey(name: 'location')
  LocationModel? get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'working_days')
  List<WorkingDayModel>? get workingDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'social_media')
  List<SocialMediaModel>? get socialMedia => throw _privateConstructorUsedError;
  @JsonKey(name: 'services')
  List<AmenityModel>? get services => throw _privateConstructorUsedError;
  @JsonKey(name: 'amenities')
  List<AmenityModel>? get amenities => throw _privateConstructorUsedError;
  @JsonKey(name: 'categories')
  List<AmenityModel>? get categories => throw _privateConstructorUsedError;
  @JsonKey(name: 'photos')
  List<PhotoModel>? get photos => throw _privateConstructorUsedError;
  @JsonKey(name: 'packages')
  List<dynamic>? get packages => throw _privateConstructorUsedError;
  @JsonKey(name: 'subscription_details')
  dynamic get subscriptionDetails => throw _privateConstructorUsedError;

  /// Serializes this OrganizationDetailsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrganizationDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizationDetailsModelCopyWith<OrganizationDetailsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationDetailsModelCopyWith<$Res> {
  factory $OrganizationDetailsModelCopyWith(
    OrganizationDetailsModel value,
    $Res Function(OrganizationDetailsModel) then,
  ) = _$OrganizationDetailsModelCopyWithImpl<$Res, OrganizationDetailsModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'is_public') bool? isPublic,
    @JsonKey(name: 'active') bool? active,
    @JsonKey(name: 'is_subscribed') bool? isSubscribed,
    @JsonKey(name: 'take_free_trial') bool? takeFreeTrial,
    @JsonKey(name: 'is_on_free_trial') bool? isOnFreeTrial,
    @JsonKey(name: 'location') LocationModel? location,
    @JsonKey(name: 'working_days') List<WorkingDayModel>? workingDays,
    @JsonKey(name: 'social_media') List<SocialMediaModel>? socialMedia,
    @JsonKey(name: 'services') List<AmenityModel>? services,
    @JsonKey(name: 'amenities') List<AmenityModel>? amenities,
    @JsonKey(name: 'categories') List<AmenityModel>? categories,
    @JsonKey(name: 'photos') List<PhotoModel>? photos,
    @JsonKey(name: 'packages') List<dynamic>? packages,
    @JsonKey(name: 'subscription_details') dynamic subscriptionDetails,
  });

  $LocationModelCopyWith<$Res>? get location;
}

/// @nodoc
class _$OrganizationDetailsModelCopyWithImpl<
  $Res,
  $Val extends OrganizationDetailsModel
>
    implements $OrganizationDetailsModelCopyWith<$Res> {
  _$OrganizationDetailsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrganizationDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? email = freezed,
    Object? logo = freezed,
    Object? phoneNumber = freezed,
    Object? isPublic = freezed,
    Object? active = freezed,
    Object? isSubscribed = freezed,
    Object? takeFreeTrial = freezed,
    Object? isOnFreeTrial = freezed,
    Object? location = freezed,
    Object? workingDays = freezed,
    Object? socialMedia = freezed,
    Object? services = freezed,
    Object? amenities = freezed,
    Object? categories = freezed,
    Object? photos = freezed,
    Object? packages = freezed,
    Object? subscriptionDetails = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            logo:
                freezed == logo
                    ? _value.logo
                    : logo // ignore: cast_nullable_to_non_nullable
                        as String?,
            phoneNumber:
                freezed == phoneNumber
                    ? _value.phoneNumber
                    : phoneNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            isPublic:
                freezed == isPublic
                    ? _value.isPublic
                    : isPublic // ignore: cast_nullable_to_non_nullable
                        as bool?,
            active:
                freezed == active
                    ? _value.active
                    : active // ignore: cast_nullable_to_non_nullable
                        as bool?,
            isSubscribed:
                freezed == isSubscribed
                    ? _value.isSubscribed
                    : isSubscribed // ignore: cast_nullable_to_non_nullable
                        as bool?,
            takeFreeTrial:
                freezed == takeFreeTrial
                    ? _value.takeFreeTrial
                    : takeFreeTrial // ignore: cast_nullable_to_non_nullable
                        as bool?,
            isOnFreeTrial:
                freezed == isOnFreeTrial
                    ? _value.isOnFreeTrial
                    : isOnFreeTrial // ignore: cast_nullable_to_non_nullable
                        as bool?,
            location:
                freezed == location
                    ? _value.location
                    : location // ignore: cast_nullable_to_non_nullable
                        as LocationModel?,
            workingDays:
                freezed == workingDays
                    ? _value.workingDays
                    : workingDays // ignore: cast_nullable_to_non_nullable
                        as List<WorkingDayModel>?,
            socialMedia:
                freezed == socialMedia
                    ? _value.socialMedia
                    : socialMedia // ignore: cast_nullable_to_non_nullable
                        as List<SocialMediaModel>?,
            services:
                freezed == services
                    ? _value.services
                    : services // ignore: cast_nullable_to_non_nullable
                        as List<AmenityModel>?,
            amenities:
                freezed == amenities
                    ? _value.amenities
                    : amenities // ignore: cast_nullable_to_non_nullable
                        as List<AmenityModel>?,
            categories:
                freezed == categories
                    ? _value.categories
                    : categories // ignore: cast_nullable_to_non_nullable
                        as List<AmenityModel>?,
            photos:
                freezed == photos
                    ? _value.photos
                    : photos // ignore: cast_nullable_to_non_nullable
                        as List<PhotoModel>?,
            packages:
                freezed == packages
                    ? _value.packages
                    : packages // ignore: cast_nullable_to_non_nullable
                        as List<dynamic>?,
            subscriptionDetails:
                freezed == subscriptionDetails
                    ? _value.subscriptionDetails
                    : subscriptionDetails // ignore: cast_nullable_to_non_nullable
                        as dynamic,
          )
          as $Val,
    );
  }

  /// Create a copy of OrganizationDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationModelCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $LocationModelCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrganizationDetailsModelImplCopyWith<$Res>
    implements $OrganizationDetailsModelCopyWith<$Res> {
  factory _$$OrganizationDetailsModelImplCopyWith(
    _$OrganizationDetailsModelImpl value,
    $Res Function(_$OrganizationDetailsModelImpl) then,
  ) = __$$OrganizationDetailsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'is_public') bool? isPublic,
    @JsonKey(name: 'active') bool? active,
    @JsonKey(name: 'is_subscribed') bool? isSubscribed,
    @JsonKey(name: 'take_free_trial') bool? takeFreeTrial,
    @JsonKey(name: 'is_on_free_trial') bool? isOnFreeTrial,
    @JsonKey(name: 'location') LocationModel? location,
    @JsonKey(name: 'working_days') List<WorkingDayModel>? workingDays,
    @JsonKey(name: 'social_media') List<SocialMediaModel>? socialMedia,
    @JsonKey(name: 'services') List<AmenityModel>? services,
    @JsonKey(name: 'amenities') List<AmenityModel>? amenities,
    @JsonKey(name: 'categories') List<AmenityModel>? categories,
    @JsonKey(name: 'photos') List<PhotoModel>? photos,
    @JsonKey(name: 'packages') List<dynamic>? packages,
    @JsonKey(name: 'subscription_details') dynamic subscriptionDetails,
  });

  @override
  $LocationModelCopyWith<$Res>? get location;
}

/// @nodoc
class __$$OrganizationDetailsModelImplCopyWithImpl<$Res>
    extends
        _$OrganizationDetailsModelCopyWithImpl<
          $Res,
          _$OrganizationDetailsModelImpl
        >
    implements _$$OrganizationDetailsModelImplCopyWith<$Res> {
  __$$OrganizationDetailsModelImplCopyWithImpl(
    _$OrganizationDetailsModelImpl _value,
    $Res Function(_$OrganizationDetailsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrganizationDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? email = freezed,
    Object? logo = freezed,
    Object? phoneNumber = freezed,
    Object? isPublic = freezed,
    Object? active = freezed,
    Object? isSubscribed = freezed,
    Object? takeFreeTrial = freezed,
    Object? isOnFreeTrial = freezed,
    Object? location = freezed,
    Object? workingDays = freezed,
    Object? socialMedia = freezed,
    Object? services = freezed,
    Object? amenities = freezed,
    Object? categories = freezed,
    Object? photos = freezed,
    Object? packages = freezed,
    Object? subscriptionDetails = freezed,
  }) {
    return _then(
      _$OrganizationDetailsModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        logo:
            freezed == logo
                ? _value.logo
                : logo // ignore: cast_nullable_to_non_nullable
                    as String?,
        phoneNumber:
            freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        isPublic:
            freezed == isPublic
                ? _value.isPublic
                : isPublic // ignore: cast_nullable_to_non_nullable
                    as bool?,
        active:
            freezed == active
                ? _value.active
                : active // ignore: cast_nullable_to_non_nullable
                    as bool?,
        isSubscribed:
            freezed == isSubscribed
                ? _value.isSubscribed
                : isSubscribed // ignore: cast_nullable_to_non_nullable
                    as bool?,
        takeFreeTrial:
            freezed == takeFreeTrial
                ? _value.takeFreeTrial
                : takeFreeTrial // ignore: cast_nullable_to_non_nullable
                    as bool?,
        isOnFreeTrial:
            freezed == isOnFreeTrial
                ? _value.isOnFreeTrial
                : isOnFreeTrial // ignore: cast_nullable_to_non_nullable
                    as bool?,
        location:
            freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                    as LocationModel?,
        workingDays:
            freezed == workingDays
                ? _value._workingDays
                : workingDays // ignore: cast_nullable_to_non_nullable
                    as List<WorkingDayModel>?,
        socialMedia:
            freezed == socialMedia
                ? _value._socialMedia
                : socialMedia // ignore: cast_nullable_to_non_nullable
                    as List<SocialMediaModel>?,
        services:
            freezed == services
                ? _value._services
                : services // ignore: cast_nullable_to_non_nullable
                    as List<AmenityModel>?,
        amenities:
            freezed == amenities
                ? _value._amenities
                : amenities // ignore: cast_nullable_to_non_nullable
                    as List<AmenityModel>?,
        categories:
            freezed == categories
                ? _value._categories
                : categories // ignore: cast_nullable_to_non_nullable
                    as List<AmenityModel>?,
        photos:
            freezed == photos
                ? _value._photos
                : photos // ignore: cast_nullable_to_non_nullable
                    as List<PhotoModel>?,
        packages:
            freezed == packages
                ? _value._packages
                : packages // ignore: cast_nullable_to_non_nullable
                    as List<dynamic>?,
        subscriptionDetails:
            freezed == subscriptionDetails
                ? _value.subscriptionDetails
                : subscriptionDetails // ignore: cast_nullable_to_non_nullable
                    as dynamic,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrganizationDetailsModelImpl implements _OrganizationDetailsModel {
  const _$OrganizationDetailsModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'description') this.description,
    @JsonKey(name: 'email') this.email,
    @JsonKey(name: 'logo') this.logo,
    @JsonKey(name: 'phone_number') this.phoneNumber,
    @JsonKey(name: 'is_public') this.isPublic,
    @JsonKey(name: 'active') this.active,
    @JsonKey(name: 'is_subscribed') this.isSubscribed,
    @JsonKey(name: 'take_free_trial') this.takeFreeTrial,
    @JsonKey(name: 'is_on_free_trial') this.isOnFreeTrial,
    @JsonKey(name: 'location') this.location,
    @JsonKey(name: 'working_days') final List<WorkingDayModel>? workingDays,
    @JsonKey(name: 'social_media') final List<SocialMediaModel>? socialMedia,
    @JsonKey(name: 'services') final List<AmenityModel>? services,
    @JsonKey(name: 'amenities') final List<AmenityModel>? amenities,
    @JsonKey(name: 'categories') final List<AmenityModel>? categories,
    @JsonKey(name: 'photos') final List<PhotoModel>? photos,
    @JsonKey(name: 'packages') final List<dynamic>? packages,
    @JsonKey(name: 'subscription_details') this.subscriptionDetails,
  }) : _workingDays = workingDays,
       _socialMedia = socialMedia,
       _services = services,
       _amenities = amenities,
       _categories = categories,
       _photos = photos,
       _packages = packages;

  factory _$OrganizationDetailsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrganizationDetailsModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'description')
  final String? description;
  @override
  @JsonKey(name: 'email')
  final String? email;
  @override
  @JsonKey(name: 'logo')
  final String? logo;
  @override
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @override
  @JsonKey(name: 'is_public')
  final bool? isPublic;
  @override
  @JsonKey(name: 'active')
  final bool? active;
  @override
  @JsonKey(name: 'is_subscribed')
  final bool? isSubscribed;
  @override
  @JsonKey(name: 'take_free_trial')
  final bool? takeFreeTrial;
  @override
  @JsonKey(name: 'is_on_free_trial')
  final bool? isOnFreeTrial;
  @override
  @JsonKey(name: 'location')
  final LocationModel? location;
  final List<WorkingDayModel>? _workingDays;
  @override
  @JsonKey(name: 'working_days')
  List<WorkingDayModel>? get workingDays {
    final value = _workingDays;
    if (value == null) return null;
    if (_workingDays is EqualUnmodifiableListView) return _workingDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<SocialMediaModel>? _socialMedia;
  @override
  @JsonKey(name: 'social_media')
  List<SocialMediaModel>? get socialMedia {
    final value = _socialMedia;
    if (value == null) return null;
    if (_socialMedia is EqualUnmodifiableListView) return _socialMedia;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<AmenityModel>? _services;
  @override
  @JsonKey(name: 'services')
  List<AmenityModel>? get services {
    final value = _services;
    if (value == null) return null;
    if (_services is EqualUnmodifiableListView) return _services;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<AmenityModel>? _amenities;
  @override
  @JsonKey(name: 'amenities')
  List<AmenityModel>? get amenities {
    final value = _amenities;
    if (value == null) return null;
    if (_amenities is EqualUnmodifiableListView) return _amenities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<AmenityModel>? _categories;
  @override
  @JsonKey(name: 'categories')
  List<AmenityModel>? get categories {
    final value = _categories;
    if (value == null) return null;
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<PhotoModel>? _photos;
  @override
  @JsonKey(name: 'photos')
  List<PhotoModel>? get photos {
    final value = _photos;
    if (value == null) return null;
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<dynamic>? _packages;
  @override
  @JsonKey(name: 'packages')
  List<dynamic>? get packages {
    final value = _packages;
    if (value == null) return null;
    if (_packages is EqualUnmodifiableListView) return _packages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'subscription_details')
  final dynamic subscriptionDetails;

  @override
  String toString() {
    return 'OrganizationDetailsModel(id: $id, name: $name, description: $description, email: $email, logo: $logo, phoneNumber: $phoneNumber, isPublic: $isPublic, active: $active, isSubscribed: $isSubscribed, takeFreeTrial: $takeFreeTrial, isOnFreeTrial: $isOnFreeTrial, location: $location, workingDays: $workingDays, socialMedia: $socialMedia, services: $services, amenities: $amenities, categories: $categories, photos: $photos, packages: $packages, subscriptionDetails: $subscriptionDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizationDetailsModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.logo, logo) || other.logo == logo) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.isSubscribed, isSubscribed) ||
                other.isSubscribed == isSubscribed) &&
            (identical(other.takeFreeTrial, takeFreeTrial) ||
                other.takeFreeTrial == takeFreeTrial) &&
            (identical(other.isOnFreeTrial, isOnFreeTrial) ||
                other.isOnFreeTrial == isOnFreeTrial) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(
              other._workingDays,
              _workingDays,
            ) &&
            const DeepCollectionEquality().equals(
              other._socialMedia,
              _socialMedia,
            ) &&
            const DeepCollectionEquality().equals(other._services, _services) &&
            const DeepCollectionEquality().equals(
              other._amenities,
              _amenities,
            ) &&
            const DeepCollectionEquality().equals(
              other._categories,
              _categories,
            ) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            const DeepCollectionEquality().equals(other._packages, _packages) &&
            const DeepCollectionEquality().equals(
              other.subscriptionDetails,
              subscriptionDetails,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    description,
    email,
    logo,
    phoneNumber,
    isPublic,
    active,
    isSubscribed,
    takeFreeTrial,
    isOnFreeTrial,
    location,
    const DeepCollectionEquality().hash(_workingDays),
    const DeepCollectionEquality().hash(_socialMedia),
    const DeepCollectionEquality().hash(_services),
    const DeepCollectionEquality().hash(_amenities),
    const DeepCollectionEquality().hash(_categories),
    const DeepCollectionEquality().hash(_photos),
    const DeepCollectionEquality().hash(_packages),
    const DeepCollectionEquality().hash(subscriptionDetails),
  ]);

  /// Create a copy of OrganizationDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationDetailsModelImplCopyWith<_$OrganizationDetailsModelImpl>
  get copyWith => __$$OrganizationDetailsModelImplCopyWithImpl<
    _$OrganizationDetailsModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrganizationDetailsModelImplToJson(this);
  }
}

abstract class _OrganizationDetailsModel implements OrganizationDetailsModel {
  const factory _OrganizationDetailsModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'description') final String? description,
    @JsonKey(name: 'email') final String? email,
    @JsonKey(name: 'logo') final String? logo,
    @JsonKey(name: 'phone_number') final String? phoneNumber,
    @JsonKey(name: 'is_public') final bool? isPublic,
    @JsonKey(name: 'active') final bool? active,
    @JsonKey(name: 'is_subscribed') final bool? isSubscribed,
    @JsonKey(name: 'take_free_trial') final bool? takeFreeTrial,
    @JsonKey(name: 'is_on_free_trial') final bool? isOnFreeTrial,
    @JsonKey(name: 'location') final LocationModel? location,
    @JsonKey(name: 'working_days') final List<WorkingDayModel>? workingDays,
    @JsonKey(name: 'social_media') final List<SocialMediaModel>? socialMedia,
    @JsonKey(name: 'services') final List<AmenityModel>? services,
    @JsonKey(name: 'amenities') final List<AmenityModel>? amenities,
    @JsonKey(name: 'categories') final List<AmenityModel>? categories,
    @JsonKey(name: 'photos') final List<PhotoModel>? photos,
    @JsonKey(name: 'packages') final List<dynamic>? packages,
    @JsonKey(name: 'subscription_details') final dynamic subscriptionDetails,
  }) = _$OrganizationDetailsModelImpl;

  factory _OrganizationDetailsModel.fromJson(Map<String, dynamic> json) =
      _$OrganizationDetailsModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'description')
  String? get description;
  @override
  @JsonKey(name: 'email')
  String? get email;
  @override
  @JsonKey(name: 'logo')
  String? get logo;
  @override
  @JsonKey(name: 'phone_number')
  String? get phoneNumber;
  @override
  @JsonKey(name: 'is_public')
  bool? get isPublic;
  @override
  @JsonKey(name: 'active')
  bool? get active;
  @override
  @JsonKey(name: 'is_subscribed')
  bool? get isSubscribed;
  @override
  @JsonKey(name: 'take_free_trial')
  bool? get takeFreeTrial;
  @override
  @JsonKey(name: 'is_on_free_trial')
  bool? get isOnFreeTrial;
  @override
  @JsonKey(name: 'location')
  LocationModel? get location;
  @override
  @JsonKey(name: 'working_days')
  List<WorkingDayModel>? get workingDays;
  @override
  @JsonKey(name: 'social_media')
  List<SocialMediaModel>? get socialMedia;
  @override
  @JsonKey(name: 'services')
  List<AmenityModel>? get services;
  @override
  @JsonKey(name: 'amenities')
  List<AmenityModel>? get amenities;
  @override
  @JsonKey(name: 'categories')
  List<AmenityModel>? get categories;
  @override
  @JsonKey(name: 'photos')
  List<PhotoModel>? get photos;
  @override
  @JsonKey(name: 'packages')
  List<dynamic>? get packages;
  @override
  @JsonKey(name: 'subscription_details')
  dynamic get subscriptionDetails;

  /// Create a copy of OrganizationDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationDetailsModelImplCopyWith<_$OrganizationDetailsModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

AmenityModel _$AmenityModelFromJson(Map<String, dynamic> json) {
  return _AmenityModel.fromJson(json);
}

/// @nodoc
mixin _$AmenityModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;

  /// Serializes this AmenityModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AmenityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AmenityModelCopyWith<AmenityModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AmenityModelCopyWith<$Res> {
  factory $AmenityModelCopyWith(
    AmenityModel value,
    $Res Function(AmenityModel) then,
  ) = _$AmenityModelCopyWithImpl<$Res, AmenityModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
  });
}

/// @nodoc
class _$AmenityModelCopyWithImpl<$Res, $Val extends AmenityModel>
    implements $AmenityModelCopyWith<$Res> {
  _$AmenityModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AmenityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = freezed, Object? name = freezed}) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AmenityModelImplCopyWith<$Res>
    implements $AmenityModelCopyWith<$Res> {
  factory _$$AmenityModelImplCopyWith(
    _$AmenityModelImpl value,
    $Res Function(_$AmenityModelImpl) then,
  ) = __$$AmenityModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
  });
}

/// @nodoc
class __$$AmenityModelImplCopyWithImpl<$Res>
    extends _$AmenityModelCopyWithImpl<$Res, _$AmenityModelImpl>
    implements _$$AmenityModelImplCopyWith<$Res> {
  __$$AmenityModelImplCopyWithImpl(
    _$AmenityModelImpl _value,
    $Res Function(_$AmenityModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AmenityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = freezed, Object? name = freezed}) {
    return _then(
      _$AmenityModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AmenityModelImpl implements _AmenityModel {
  const _$AmenityModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'name') this.name,
  });

  factory _$AmenityModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AmenityModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'name')
  final String? name;

  @override
  String toString() {
    return 'AmenityModel(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AmenityModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of AmenityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AmenityModelImplCopyWith<_$AmenityModelImpl> get copyWith =>
      __$$AmenityModelImplCopyWithImpl<_$AmenityModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AmenityModelImplToJson(this);
  }
}

abstract class _AmenityModel implements AmenityModel {
  const factory _AmenityModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'name') final String? name,
  }) = _$AmenityModelImpl;

  factory _AmenityModel.fromJson(Map<String, dynamic> json) =
      _$AmenityModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'name')
  String? get name;

  /// Create a copy of AmenityModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AmenityModelImplCopyWith<_$AmenityModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) {
  return _LocationModel.fromJson(json);
}

/// @nodoc
mixin _$LocationModel {
  @JsonKey(name: 'building_name')
  String? get buildingName => throw _privateConstructorUsedError;
  @JsonKey(name: 'street')
  String? get street => throw _privateConstructorUsedError;
  @JsonKey(name: 'city')
  String? get city => throw _privateConstructorUsedError;
  @JsonKey(name: 'state')
  String? get state => throw _privateConstructorUsedError;
  @JsonKey(name: 'pin_code')
  String? get pinCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'latitude')
  dynamic get latitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'longitude')
  dynamic get longitude => throw _privateConstructorUsedError;

  /// Serializes this LocationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationModelCopyWith<LocationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationModelCopyWith<$Res> {
  factory $LocationModelCopyWith(
    LocationModel value,
    $Res Function(LocationModel) then,
  ) = _$LocationModelCopyWithImpl<$Res, LocationModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'building_name') String? buildingName,
    @JsonKey(name: 'street') String? street,
    @JsonKey(name: 'city') String? city,
    @JsonKey(name: 'state') String? state,
    @JsonKey(name: 'pin_code') String? pinCode,
    @JsonKey(name: 'latitude') dynamic latitude,
    @JsonKey(name: 'longitude') dynamic longitude,
  });
}

/// @nodoc
class _$LocationModelCopyWithImpl<$Res, $Val extends LocationModel>
    implements $LocationModelCopyWith<$Res> {
  _$LocationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? buildingName = freezed,
    Object? street = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? pinCode = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(
      _value.copyWith(
            buildingName:
                freezed == buildingName
                    ? _value.buildingName
                    : buildingName // ignore: cast_nullable_to_non_nullable
                        as String?,
            street:
                freezed == street
                    ? _value.street
                    : street // ignore: cast_nullable_to_non_nullable
                        as String?,
            city:
                freezed == city
                    ? _value.city
                    : city // ignore: cast_nullable_to_non_nullable
                        as String?,
            state:
                freezed == state
                    ? _value.state
                    : state // ignore: cast_nullable_to_non_nullable
                        as String?,
            pinCode:
                freezed == pinCode
                    ? _value.pinCode
                    : pinCode // ignore: cast_nullable_to_non_nullable
                        as String?,
            latitude:
                freezed == latitude
                    ? _value.latitude
                    : latitude // ignore: cast_nullable_to_non_nullable
                        as dynamic,
            longitude:
                freezed == longitude
                    ? _value.longitude
                    : longitude // ignore: cast_nullable_to_non_nullable
                        as dynamic,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LocationModelImplCopyWith<$Res>
    implements $LocationModelCopyWith<$Res> {
  factory _$$LocationModelImplCopyWith(
    _$LocationModelImpl value,
    $Res Function(_$LocationModelImpl) then,
  ) = __$$LocationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'building_name') String? buildingName,
    @JsonKey(name: 'street') String? street,
    @JsonKey(name: 'city') String? city,
    @JsonKey(name: 'state') String? state,
    @JsonKey(name: 'pin_code') String? pinCode,
    @JsonKey(name: 'latitude') dynamic latitude,
    @JsonKey(name: 'longitude') dynamic longitude,
  });
}

/// @nodoc
class __$$LocationModelImplCopyWithImpl<$Res>
    extends _$LocationModelCopyWithImpl<$Res, _$LocationModelImpl>
    implements _$$LocationModelImplCopyWith<$Res> {
  __$$LocationModelImplCopyWithImpl(
    _$LocationModelImpl _value,
    $Res Function(_$LocationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? buildingName = freezed,
    Object? street = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? pinCode = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(
      _$LocationModelImpl(
        buildingName:
            freezed == buildingName
                ? _value.buildingName
                : buildingName // ignore: cast_nullable_to_non_nullable
                    as String?,
        street:
            freezed == street
                ? _value.street
                : street // ignore: cast_nullable_to_non_nullable
                    as String?,
        city:
            freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                    as String?,
        state:
            freezed == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                    as String?,
        pinCode:
            freezed == pinCode
                ? _value.pinCode
                : pinCode // ignore: cast_nullable_to_non_nullable
                    as String?,
        latitude:
            freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                    as dynamic,
        longitude:
            freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                    as dynamic,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationModelImpl implements _LocationModel {
  const _$LocationModelImpl({
    @JsonKey(name: 'building_name') this.buildingName,
    @JsonKey(name: 'street') this.street,
    @JsonKey(name: 'city') this.city,
    @JsonKey(name: 'state') this.state,
    @JsonKey(name: 'pin_code') this.pinCode,
    @JsonKey(name: 'latitude') this.latitude,
    @JsonKey(name: 'longitude') this.longitude,
  });

  factory _$LocationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationModelImplFromJson(json);

  @override
  @JsonKey(name: 'building_name')
  final String? buildingName;
  @override
  @JsonKey(name: 'street')
  final String? street;
  @override
  @JsonKey(name: 'city')
  final String? city;
  @override
  @JsonKey(name: 'state')
  final String? state;
  @override
  @JsonKey(name: 'pin_code')
  final String? pinCode;
  @override
  @JsonKey(name: 'latitude')
  final dynamic latitude;
  @override
  @JsonKey(name: 'longitude')
  final dynamic longitude;

  @override
  String toString() {
    return 'LocationModel(buildingName: $buildingName, street: $street, city: $city, state: $state, pinCode: $pinCode, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationModelImpl &&
            (identical(other.buildingName, buildingName) ||
                other.buildingName == buildingName) &&
            (identical(other.street, street) || other.street == street) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.pinCode, pinCode) || other.pinCode == pinCode) &&
            const DeepCollectionEquality().equals(other.latitude, latitude) &&
            const DeepCollectionEquality().equals(other.longitude, longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    buildingName,
    street,
    city,
    state,
    pinCode,
    const DeepCollectionEquality().hash(latitude),
    const DeepCollectionEquality().hash(longitude),
  );

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationModelImplCopyWith<_$LocationModelImpl> get copyWith =>
      __$$LocationModelImplCopyWithImpl<_$LocationModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationModelImplToJson(this);
  }
}

abstract class _LocationModel implements LocationModel {
  const factory _LocationModel({
    @JsonKey(name: 'building_name') final String? buildingName,
    @JsonKey(name: 'street') final String? street,
    @JsonKey(name: 'city') final String? city,
    @JsonKey(name: 'state') final String? state,
    @JsonKey(name: 'pin_code') final String? pinCode,
    @JsonKey(name: 'latitude') final dynamic latitude,
    @JsonKey(name: 'longitude') final dynamic longitude,
  }) = _$LocationModelImpl;

  factory _LocationModel.fromJson(Map<String, dynamic> json) =
      _$LocationModelImpl.fromJson;

  @override
  @JsonKey(name: 'building_name')
  String? get buildingName;
  @override
  @JsonKey(name: 'street')
  String? get street;
  @override
  @JsonKey(name: 'city')
  String? get city;
  @override
  @JsonKey(name: 'state')
  String? get state;
  @override
  @JsonKey(name: 'pin_code')
  String? get pinCode;
  @override
  @JsonKey(name: 'latitude')
  dynamic get latitude;
  @override
  @JsonKey(name: 'longitude')
  dynamic get longitude;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationModelImplCopyWith<_$LocationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PhotoModel _$PhotoModelFromJson(Map<String, dynamic> json) {
  return _PhotoModel.fromJson(json);
}

/// @nodoc
mixin _$PhotoModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'image')
  String? get image => throw _privateConstructorUsedError;
  @JsonKey(name: 'caption')
  String? get caption => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_primary')
  bool? get isPrimary => throw _privateConstructorUsedError;

  /// Serializes this PhotoModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoModelCopyWith<PhotoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoModelCopyWith<$Res> {
  factory $PhotoModelCopyWith(
    PhotoModel value,
    $Res Function(PhotoModel) then,
  ) = _$PhotoModelCopyWithImpl<$Res, PhotoModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'image') String? image,
    @JsonKey(name: 'caption') String? caption,
    @JsonKey(name: 'is_primary') bool? isPrimary,
  });
}

/// @nodoc
class _$PhotoModelCopyWithImpl<$Res, $Val extends PhotoModel>
    implements $PhotoModelCopyWith<$Res> {
  _$PhotoModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? image = freezed,
    Object? caption = freezed,
    Object? isPrimary = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            image:
                freezed == image
                    ? _value.image
                    : image // ignore: cast_nullable_to_non_nullable
                        as String?,
            caption:
                freezed == caption
                    ? _value.caption
                    : caption // ignore: cast_nullable_to_non_nullable
                        as String?,
            isPrimary:
                freezed == isPrimary
                    ? _value.isPrimary
                    : isPrimary // ignore: cast_nullable_to_non_nullable
                        as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PhotoModelImplCopyWith<$Res>
    implements $PhotoModelCopyWith<$Res> {
  factory _$$PhotoModelImplCopyWith(
    _$PhotoModelImpl value,
    $Res Function(_$PhotoModelImpl) then,
  ) = __$$PhotoModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'image') String? image,
    @JsonKey(name: 'caption') String? caption,
    @JsonKey(name: 'is_primary') bool? isPrimary,
  });
}

/// @nodoc
class __$$PhotoModelImplCopyWithImpl<$Res>
    extends _$PhotoModelCopyWithImpl<$Res, _$PhotoModelImpl>
    implements _$$PhotoModelImplCopyWith<$Res> {
  __$$PhotoModelImplCopyWithImpl(
    _$PhotoModelImpl _value,
    $Res Function(_$PhotoModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? image = freezed,
    Object? caption = freezed,
    Object? isPrimary = freezed,
  }) {
    return _then(
      _$PhotoModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        image:
            freezed == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                    as String?,
        caption:
            freezed == caption
                ? _value.caption
                : caption // ignore: cast_nullable_to_non_nullable
                    as String?,
        isPrimary:
            freezed == isPrimary
                ? _value.isPrimary
                : isPrimary // ignore: cast_nullable_to_non_nullable
                    as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PhotoModelImpl implements _PhotoModel {
  const _$PhotoModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'image') this.image,
    @JsonKey(name: 'caption') this.caption,
    @JsonKey(name: 'is_primary') this.isPrimary,
  });

  factory _$PhotoModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhotoModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'image')
  final String? image;
  @override
  @JsonKey(name: 'caption')
  final String? caption;
  @override
  @JsonKey(name: 'is_primary')
  final bool? isPrimary;

  @override
  String toString() {
    return 'PhotoModel(id: $id, image: $image, caption: $caption, isPrimary: $isPrimary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, image, caption, isPrimary);

  /// Create a copy of PhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoModelImplCopyWith<_$PhotoModelImpl> get copyWith =>
      __$$PhotoModelImplCopyWithImpl<_$PhotoModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhotoModelImplToJson(this);
  }
}

abstract class _PhotoModel implements PhotoModel {
  const factory _PhotoModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'image') final String? image,
    @JsonKey(name: 'caption') final String? caption,
    @JsonKey(name: 'is_primary') final bool? isPrimary,
  }) = _$PhotoModelImpl;

  factory _PhotoModel.fromJson(Map<String, dynamic> json) =
      _$PhotoModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'image')
  String? get image;
  @override
  @JsonKey(name: 'caption')
  String? get caption;
  @override
  @JsonKey(name: 'is_primary')
  bool? get isPrimary;

  /// Create a copy of PhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoModelImplCopyWith<_$PhotoModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SocialMediaModel _$SocialMediaModelFromJson(Map<String, dynamic> json) {
  return _SocialMediaModel.fromJson(json);
}

/// @nodoc
mixin _$SocialMediaModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'platform')
  String? get platform => throw _privateConstructorUsedError;
  @JsonKey(name: 'url')
  String? get url => throw _privateConstructorUsedError;

  /// Serializes this SocialMediaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SocialMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SocialMediaModelCopyWith<SocialMediaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SocialMediaModelCopyWith<$Res> {
  factory $SocialMediaModelCopyWith(
    SocialMediaModel value,
    $Res Function(SocialMediaModel) then,
  ) = _$SocialMediaModelCopyWithImpl<$Res, SocialMediaModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'platform') String? platform,
    @JsonKey(name: 'url') String? url,
  });
}

/// @nodoc
class _$SocialMediaModelCopyWithImpl<$Res, $Val extends SocialMediaModel>
    implements $SocialMediaModelCopyWith<$Res> {
  _$SocialMediaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SocialMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? platform = freezed,
    Object? url = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            platform:
                freezed == platform
                    ? _value.platform
                    : platform // ignore: cast_nullable_to_non_nullable
                        as String?,
            url:
                freezed == url
                    ? _value.url
                    : url // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SocialMediaModelImplCopyWith<$Res>
    implements $SocialMediaModelCopyWith<$Res> {
  factory _$$SocialMediaModelImplCopyWith(
    _$SocialMediaModelImpl value,
    $Res Function(_$SocialMediaModelImpl) then,
  ) = __$$SocialMediaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'platform') String? platform,
    @JsonKey(name: 'url') String? url,
  });
}

/// @nodoc
class __$$SocialMediaModelImplCopyWithImpl<$Res>
    extends _$SocialMediaModelCopyWithImpl<$Res, _$SocialMediaModelImpl>
    implements _$$SocialMediaModelImplCopyWith<$Res> {
  __$$SocialMediaModelImplCopyWithImpl(
    _$SocialMediaModelImpl _value,
    $Res Function(_$SocialMediaModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SocialMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? platform = freezed,
    Object? url = freezed,
  }) {
    return _then(
      _$SocialMediaModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        platform:
            freezed == platform
                ? _value.platform
                : platform // ignore: cast_nullable_to_non_nullable
                    as String?,
        url:
            freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SocialMediaModelImpl implements _SocialMediaModel {
  const _$SocialMediaModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'platform') this.platform,
    @JsonKey(name: 'url') this.url,
  });

  factory _$SocialMediaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SocialMediaModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'platform')
  final String? platform;
  @override
  @JsonKey(name: 'url')
  final String? url;

  @override
  String toString() {
    return 'SocialMediaModel(id: $id, platform: $platform, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocialMediaModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, platform, url);

  /// Create a copy of SocialMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SocialMediaModelImplCopyWith<_$SocialMediaModelImpl> get copyWith =>
      __$$SocialMediaModelImplCopyWithImpl<_$SocialMediaModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SocialMediaModelImplToJson(this);
  }
}

abstract class _SocialMediaModel implements SocialMediaModel {
  const factory _SocialMediaModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'platform') final String? platform,
    @JsonKey(name: 'url') final String? url,
  }) = _$SocialMediaModelImpl;

  factory _SocialMediaModel.fromJson(Map<String, dynamic> json) =
      _$SocialMediaModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'platform')
  String? get platform;
  @override
  @JsonKey(name: 'url')
  String? get url;

  /// Create a copy of SocialMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SocialMediaModelImplCopyWith<_$SocialMediaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkingDayModel _$WorkingDayModelFromJson(Map<String, dynamic> json) {
  return _WorkingDayModel.fromJson(json);
}

/// @nodoc
mixin _$WorkingDayModel {
  @JsonKey(name: 'day')
  String? get day => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_open')
  bool? get isOpen => throw _privateConstructorUsedError;
  @JsonKey(name: 'morning_opening_time')
  String? get morningOpeningTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'morning_closing_time')
  String? get morningClosingTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'evening_opening_time')
  String? get eveningOpeningTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'evening_closing_time')
  String? get eveningClosingTime => throw _privateConstructorUsedError;

  /// Serializes this WorkingDayModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkingDayModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkingDayModelCopyWith<WorkingDayModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkingDayModelCopyWith<$Res> {
  factory $WorkingDayModelCopyWith(
    WorkingDayModel value,
    $Res Function(WorkingDayModel) then,
  ) = _$WorkingDayModelCopyWithImpl<$Res, WorkingDayModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'day') String? day,
    @JsonKey(name: 'is_open') bool? isOpen,
    @JsonKey(name: 'morning_opening_time') String? morningOpeningTime,
    @JsonKey(name: 'morning_closing_time') String? morningClosingTime,
    @JsonKey(name: 'evening_opening_time') String? eveningOpeningTime,
    @JsonKey(name: 'evening_closing_time') String? eveningClosingTime,
  });
}

/// @nodoc
class _$WorkingDayModelCopyWithImpl<$Res, $Val extends WorkingDayModel>
    implements $WorkingDayModelCopyWith<$Res> {
  _$WorkingDayModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkingDayModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = freezed,
    Object? isOpen = freezed,
    Object? morningOpeningTime = freezed,
    Object? morningClosingTime = freezed,
    Object? eveningOpeningTime = freezed,
    Object? eveningClosingTime = freezed,
  }) {
    return _then(
      _value.copyWith(
            day:
                freezed == day
                    ? _value.day
                    : day // ignore: cast_nullable_to_non_nullable
                        as String?,
            isOpen:
                freezed == isOpen
                    ? _value.isOpen
                    : isOpen // ignore: cast_nullable_to_non_nullable
                        as bool?,
            morningOpeningTime:
                freezed == morningOpeningTime
                    ? _value.morningOpeningTime
                    : morningOpeningTime // ignore: cast_nullable_to_non_nullable
                        as String?,
            morningClosingTime:
                freezed == morningClosingTime
                    ? _value.morningClosingTime
                    : morningClosingTime // ignore: cast_nullable_to_non_nullable
                        as String?,
            eveningOpeningTime:
                freezed == eveningOpeningTime
                    ? _value.eveningOpeningTime
                    : eveningOpeningTime // ignore: cast_nullable_to_non_nullable
                        as String?,
            eveningClosingTime:
                freezed == eveningClosingTime
                    ? _value.eveningClosingTime
                    : eveningClosingTime // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkingDayModelImplCopyWith<$Res>
    implements $WorkingDayModelCopyWith<$Res> {
  factory _$$WorkingDayModelImplCopyWith(
    _$WorkingDayModelImpl value,
    $Res Function(_$WorkingDayModelImpl) then,
  ) = __$$WorkingDayModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'day') String? day,
    @JsonKey(name: 'is_open') bool? isOpen,
    @JsonKey(name: 'morning_opening_time') String? morningOpeningTime,
    @JsonKey(name: 'morning_closing_time') String? morningClosingTime,
    @JsonKey(name: 'evening_opening_time') String? eveningOpeningTime,
    @JsonKey(name: 'evening_closing_time') String? eveningClosingTime,
  });
}

/// @nodoc
class __$$WorkingDayModelImplCopyWithImpl<$Res>
    extends _$WorkingDayModelCopyWithImpl<$Res, _$WorkingDayModelImpl>
    implements _$$WorkingDayModelImplCopyWith<$Res> {
  __$$WorkingDayModelImplCopyWithImpl(
    _$WorkingDayModelImpl _value,
    $Res Function(_$WorkingDayModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkingDayModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = freezed,
    Object? isOpen = freezed,
    Object? morningOpeningTime = freezed,
    Object? morningClosingTime = freezed,
    Object? eveningOpeningTime = freezed,
    Object? eveningClosingTime = freezed,
  }) {
    return _then(
      _$WorkingDayModelImpl(
        day:
            freezed == day
                ? _value.day
                : day // ignore: cast_nullable_to_non_nullable
                    as String?,
        isOpen:
            freezed == isOpen
                ? _value.isOpen
                : isOpen // ignore: cast_nullable_to_non_nullable
                    as bool?,
        morningOpeningTime:
            freezed == morningOpeningTime
                ? _value.morningOpeningTime
                : morningOpeningTime // ignore: cast_nullable_to_non_nullable
                    as String?,
        morningClosingTime:
            freezed == morningClosingTime
                ? _value.morningClosingTime
                : morningClosingTime // ignore: cast_nullable_to_non_nullable
                    as String?,
        eveningOpeningTime:
            freezed == eveningOpeningTime
                ? _value.eveningOpeningTime
                : eveningOpeningTime // ignore: cast_nullable_to_non_nullable
                    as String?,
        eveningClosingTime:
            freezed == eveningClosingTime
                ? _value.eveningClosingTime
                : eveningClosingTime // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkingDayModelImpl implements _WorkingDayModel {
  const _$WorkingDayModelImpl({
    @JsonKey(name: 'day') this.day,
    @JsonKey(name: 'is_open') this.isOpen,
    @JsonKey(name: 'morning_opening_time') this.morningOpeningTime,
    @JsonKey(name: 'morning_closing_time') this.morningClosingTime,
    @JsonKey(name: 'evening_opening_time') this.eveningOpeningTime,
    @JsonKey(name: 'evening_closing_time') this.eveningClosingTime,
  });

  factory _$WorkingDayModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkingDayModelImplFromJson(json);

  @override
  @JsonKey(name: 'day')
  final String? day;
  @override
  @JsonKey(name: 'is_open')
  final bool? isOpen;
  @override
  @JsonKey(name: 'morning_opening_time')
  final String? morningOpeningTime;
  @override
  @JsonKey(name: 'morning_closing_time')
  final String? morningClosingTime;
  @override
  @JsonKey(name: 'evening_opening_time')
  final String? eveningOpeningTime;
  @override
  @JsonKey(name: 'evening_closing_time')
  final String? eveningClosingTime;

  @override
  String toString() {
    return 'WorkingDayModel(day: $day, isOpen: $isOpen, morningOpeningTime: $morningOpeningTime, morningClosingTime: $morningClosingTime, eveningOpeningTime: $eveningOpeningTime, eveningClosingTime: $eveningClosingTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkingDayModelImpl &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.isOpen, isOpen) || other.isOpen == isOpen) &&
            (identical(other.morningOpeningTime, morningOpeningTime) ||
                other.morningOpeningTime == morningOpeningTime) &&
            (identical(other.morningClosingTime, morningClosingTime) ||
                other.morningClosingTime == morningClosingTime) &&
            (identical(other.eveningOpeningTime, eveningOpeningTime) ||
                other.eveningOpeningTime == eveningOpeningTime) &&
            (identical(other.eveningClosingTime, eveningClosingTime) ||
                other.eveningClosingTime == eveningClosingTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    day,
    isOpen,
    morningOpeningTime,
    morningClosingTime,
    eveningOpeningTime,
    eveningClosingTime,
  );

  /// Create a copy of WorkingDayModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkingDayModelImplCopyWith<_$WorkingDayModelImpl> get copyWith =>
      __$$WorkingDayModelImplCopyWithImpl<_$WorkingDayModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkingDayModelImplToJson(this);
  }
}

abstract class _WorkingDayModel implements WorkingDayModel {
  const factory _WorkingDayModel({
    @JsonKey(name: 'day') final String? day,
    @JsonKey(name: 'is_open') final bool? isOpen,
    @JsonKey(name: 'morning_opening_time') final String? morningOpeningTime,
    @JsonKey(name: 'morning_closing_time') final String? morningClosingTime,
    @JsonKey(name: 'evening_opening_time') final String? eveningOpeningTime,
    @JsonKey(name: 'evening_closing_time') final String? eveningClosingTime,
  }) = _$WorkingDayModelImpl;

  factory _WorkingDayModel.fromJson(Map<String, dynamic> json) =
      _$WorkingDayModelImpl.fromJson;

  @override
  @JsonKey(name: 'day')
  String? get day;
  @override
  @JsonKey(name: 'is_open')
  bool? get isOpen;
  @override
  @JsonKey(name: 'morning_opening_time')
  String? get morningOpeningTime;
  @override
  @JsonKey(name: 'morning_closing_time')
  String? get morningClosingTime;
  @override
  @JsonKey(name: 'evening_opening_time')
  String? get eveningOpeningTime;
  @override
  @JsonKey(name: 'evening_closing_time')
  String? get eveningClosingTime;

  /// Create a copy of WorkingDayModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkingDayModelImplCopyWith<_$WorkingDayModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
