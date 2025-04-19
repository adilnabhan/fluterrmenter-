// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LoginEntity _$LoginEntityFromJson(Map<String, dynamic> json) {
  return _LoginEntity.fromJson(json);
}

/// @nodoc
mixin _$LoginEntity {
  @JsonKey(name: 'last_login')
  DateTime? get lastLogin => throw _privateConstructorUsedError;
  @JsonKey(name: 'username')
  String? get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'message')
  String? get message => throw _privateConstructorUsedError;
  @JsonKey(name: 'user')
  int? get user => throw _privateConstructorUsedError;
  @JsonKey(name: 'vendor')
  Vendor? get vendor => throw _privateConstructorUsedError;
  @JsonKey(name: 'vendor_id')
  num? get vendorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String? get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String? get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'get_full_name')
  String? get getFullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'email')
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_staff')
  bool? get isStaff => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool? get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'mobile_no')
  String? get mobileNo => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_image')
  dynamic get profileImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'modules')
  List<dynamic>? get modules => throw _privateConstructorUsedError;
  @JsonKey(name: 'get_role_display')
  String? get getRoleDisplay => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_vendor')
  bool? get isVendor => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_customer')
  bool? get isCustomer => throw _privateConstructorUsedError;
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'role')
  int? get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'access')
  String? get accessToken => throw _privateConstructorUsedError;
  @JsonKey(name: 'refresh')
  String? get refresh => throw _privateConstructorUsedError;

  /// Serializes this LoginEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginEntityCopyWith<LoginEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginEntityCopyWith<$Res> {
  factory $LoginEntityCopyWith(
          LoginEntity value, $Res Function(LoginEntity) then) =
      _$LoginEntityCopyWithImpl<$Res, LoginEntity>;
  @useResult
  $Res call(
      {@JsonKey(name: 'last_login') DateTime? lastLogin,
      @JsonKey(name: 'username') String? username,
      @JsonKey(name: 'message') String? message,
      @JsonKey(name: 'user') int? user,
      @JsonKey(name: 'vendor') Vendor? vendor,
      @JsonKey(name: 'vendor_id') num? vendorId,
      @JsonKey(name: 'first_name') String? firstName,
      @JsonKey(name: 'last_name') String? lastName,
      @JsonKey(name: 'get_full_name') String? getFullName,
      @JsonKey(name: 'email') String? email,
      @JsonKey(name: 'is_staff') bool? isStaff,
      @JsonKey(name: 'is_active') bool? isActive,
      @JsonKey(name: 'mobile_no') String? mobileNo,
      @JsonKey(name: 'profile_image') dynamic profileImage,
      @JsonKey(name: 'modules') List<dynamic>? modules,
      @JsonKey(name: 'get_role_display') String? getRoleDisplay,
      @JsonKey(name: 'is_vendor') bool? isVendor,
      @JsonKey(name: 'is_customer') bool? isCustomer,
      @JsonKey(name: 'id') int? id,
      @JsonKey(name: 'role') int? role,
      @JsonKey(name: 'access') String? accessToken,
      @JsonKey(name: 'refresh') String? refresh});

  $VendorCopyWith<$Res>? get vendor;
}

/// @nodoc
class _$LoginEntityCopyWithImpl<$Res, $Val extends LoginEntity>
    implements $LoginEntityCopyWith<$Res> {
  _$LoginEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastLogin = freezed,
    Object? username = freezed,
    Object? message = freezed,
    Object? user = freezed,
    Object? vendor = freezed,
    Object? vendorId = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? getFullName = freezed,
    Object? email = freezed,
    Object? isStaff = freezed,
    Object? isActive = freezed,
    Object? mobileNo = freezed,
    Object? profileImage = freezed,
    Object? modules = freezed,
    Object? getRoleDisplay = freezed,
    Object? isVendor = freezed,
    Object? isCustomer = freezed,
    Object? id = freezed,
    Object? role = freezed,
    Object? accessToken = freezed,
    Object? refresh = freezed,
  }) {
    return _then(_value.copyWith(
      lastLogin: freezed == lastLogin
          ? _value.lastLogin
          : lastLogin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as int?,
      vendor: freezed == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as Vendor?,
      vendorId: freezed == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as num?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      getFullName: freezed == getFullName
          ? _value.getFullName
          : getFullName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      isStaff: freezed == isStaff
          ? _value.isStaff
          : isStaff // ignore: cast_nullable_to_non_nullable
              as bool?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      mobileNo: freezed == mobileNo
          ? _value.mobileNo
          : mobileNo // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImage: freezed == profileImage
          ? _value.profileImage
          : profileImage // ignore: cast_nullable_to_non_nullable
              as dynamic,
      modules: freezed == modules
          ? _value.modules
          : modules // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      getRoleDisplay: freezed == getRoleDisplay
          ? _value.getRoleDisplay
          : getRoleDisplay // ignore: cast_nullable_to_non_nullable
              as String?,
      isVendor: freezed == isVendor
          ? _value.isVendor
          : isVendor // ignore: cast_nullable_to_non_nullable
              as bool?,
      isCustomer: freezed == isCustomer
          ? _value.isCustomer
          : isCustomer // ignore: cast_nullable_to_non_nullable
              as bool?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as int?,
      accessToken: freezed == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      refresh: freezed == refresh
          ? _value.refresh
          : refresh // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of LoginEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VendorCopyWith<$Res>? get vendor {
    if (_value.vendor == null) {
      return null;
    }

    return $VendorCopyWith<$Res>(_value.vendor!, (value) {
      return _then(_value.copyWith(vendor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LoginEntityImplCopyWith<$Res>
    implements $LoginEntityCopyWith<$Res> {
  factory _$$LoginEntityImplCopyWith(
          _$LoginEntityImpl value, $Res Function(_$LoginEntityImpl) then) =
      __$$LoginEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'last_login') DateTime? lastLogin,
      @JsonKey(name: 'username') String? username,
      @JsonKey(name: 'message') String? message,
      @JsonKey(name: 'user') int? user,
      @JsonKey(name: 'vendor') Vendor? vendor,
      @JsonKey(name: 'vendor_id') num? vendorId,
      @JsonKey(name: 'first_name') String? firstName,
      @JsonKey(name: 'last_name') String? lastName,
      @JsonKey(name: 'get_full_name') String? getFullName,
      @JsonKey(name: 'email') String? email,
      @JsonKey(name: 'is_staff') bool? isStaff,
      @JsonKey(name: 'is_active') bool? isActive,
      @JsonKey(name: 'mobile_no') String? mobileNo,
      @JsonKey(name: 'profile_image') dynamic profileImage,
      @JsonKey(name: 'modules') List<dynamic>? modules,
      @JsonKey(name: 'get_role_display') String? getRoleDisplay,
      @JsonKey(name: 'is_vendor') bool? isVendor,
      @JsonKey(name: 'is_customer') bool? isCustomer,
      @JsonKey(name: 'id') int? id,
      @JsonKey(name: 'role') int? role,
      @JsonKey(name: 'access') String? accessToken,
      @JsonKey(name: 'refresh') String? refresh});

  @override
  $VendorCopyWith<$Res>? get vendor;
}

/// @nodoc
class __$$LoginEntityImplCopyWithImpl<$Res>
    extends _$LoginEntityCopyWithImpl<$Res, _$LoginEntityImpl>
    implements _$$LoginEntityImplCopyWith<$Res> {
  __$$LoginEntityImplCopyWithImpl(
      _$LoginEntityImpl _value, $Res Function(_$LoginEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoginEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastLogin = freezed,
    Object? username = freezed,
    Object? message = freezed,
    Object? user = freezed,
    Object? vendor = freezed,
    Object? vendorId = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? getFullName = freezed,
    Object? email = freezed,
    Object? isStaff = freezed,
    Object? isActive = freezed,
    Object? mobileNo = freezed,
    Object? profileImage = freezed,
    Object? modules = freezed,
    Object? getRoleDisplay = freezed,
    Object? isVendor = freezed,
    Object? isCustomer = freezed,
    Object? id = freezed,
    Object? role = freezed,
    Object? accessToken = freezed,
    Object? refresh = freezed,
  }) {
    return _then(_$LoginEntityImpl(
      lastLogin: freezed == lastLogin
          ? _value.lastLogin
          : lastLogin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as int?,
      vendor: freezed == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as Vendor?,
      vendorId: freezed == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as num?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      getFullName: freezed == getFullName
          ? _value.getFullName
          : getFullName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      isStaff: freezed == isStaff
          ? _value.isStaff
          : isStaff // ignore: cast_nullable_to_non_nullable
              as bool?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      mobileNo: freezed == mobileNo
          ? _value.mobileNo
          : mobileNo // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImage: freezed == profileImage
          ? _value.profileImage
          : profileImage // ignore: cast_nullable_to_non_nullable
              as dynamic,
      modules: freezed == modules
          ? _value._modules
          : modules // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      getRoleDisplay: freezed == getRoleDisplay
          ? _value.getRoleDisplay
          : getRoleDisplay // ignore: cast_nullable_to_non_nullable
              as String?,
      isVendor: freezed == isVendor
          ? _value.isVendor
          : isVendor // ignore: cast_nullable_to_non_nullable
              as bool?,
      isCustomer: freezed == isCustomer
          ? _value.isCustomer
          : isCustomer // ignore: cast_nullable_to_non_nullable
              as bool?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as int?,
      accessToken: freezed == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      refresh: freezed == refresh
          ? _value.refresh
          : refresh // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginEntityImpl implements _LoginEntity {
  const _$LoginEntityImpl(
      {@JsonKey(name: 'last_login') this.lastLogin,
      @JsonKey(name: 'username') this.username,
      @JsonKey(name: 'message') this.message,
      @JsonKey(name: 'user') this.user,
      @JsonKey(name: 'vendor') this.vendor,
      @JsonKey(name: 'vendor_id') this.vendorId,
      @JsonKey(name: 'first_name') this.firstName,
      @JsonKey(name: 'last_name') this.lastName,
      @JsonKey(name: 'get_full_name') this.getFullName,
      @JsonKey(name: 'email') this.email,
      @JsonKey(name: 'is_staff') this.isStaff,
      @JsonKey(name: 'is_active') this.isActive,
      @JsonKey(name: 'mobile_no') this.mobileNo,
      @JsonKey(name: 'profile_image') this.profileImage,
      @JsonKey(name: 'modules') final List<dynamic>? modules,
      @JsonKey(name: 'get_role_display') this.getRoleDisplay,
      @JsonKey(name: 'is_vendor') this.isVendor,
      @JsonKey(name: 'is_customer') this.isCustomer,
      @JsonKey(name: 'id') this.id,
      @JsonKey(name: 'role') this.role,
      @JsonKey(name: 'access') this.accessToken,
      @JsonKey(name: 'refresh') this.refresh})
      : _modules = modules;

  factory _$LoginEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginEntityImplFromJson(json);

  @override
  @JsonKey(name: 'last_login')
  final DateTime? lastLogin;
  @override
  @JsonKey(name: 'username')
  final String? username;
  @override
  @JsonKey(name: 'message')
  final String? message;
  @override
  @JsonKey(name: 'user')
  final int? user;
  @override
  @JsonKey(name: 'vendor')
  final Vendor? vendor;
  @override
  @JsonKey(name: 'vendor_id')
  final num? vendorId;
  @override
  @JsonKey(name: 'first_name')
  final String? firstName;
  @override
  @JsonKey(name: 'last_name')
  final String? lastName;
  @override
  @JsonKey(name: 'get_full_name')
  final String? getFullName;
  @override
  @JsonKey(name: 'email')
  final String? email;
  @override
  @JsonKey(name: 'is_staff')
  final bool? isStaff;
  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @override
  @JsonKey(name: 'mobile_no')
  final String? mobileNo;
  @override
  @JsonKey(name: 'profile_image')
  final dynamic profileImage;
  final List<dynamic>? _modules;
  @override
  @JsonKey(name: 'modules')
  List<dynamic>? get modules {
    final value = _modules;
    if (value == null) return null;
    if (_modules is EqualUnmodifiableListView) return _modules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'get_role_display')
  final String? getRoleDisplay;
  @override
  @JsonKey(name: 'is_vendor')
  final bool? isVendor;
  @override
  @JsonKey(name: 'is_customer')
  final bool? isCustomer;
  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'role')
  final int? role;
  @override
  @JsonKey(name: 'access')
  final String? accessToken;
  @override
  @JsonKey(name: 'refresh')
  final String? refresh;

  @override
  String toString() {
    return 'LoginEntity(lastLogin: $lastLogin, username: $username, message: $message, user: $user, vendor: $vendor, vendorId: $vendorId, firstName: $firstName, lastName: $lastName, getFullName: $getFullName, email: $email, isStaff: $isStaff, isActive: $isActive, mobileNo: $mobileNo, profileImage: $profileImage, modules: $modules, getRoleDisplay: $getRoleDisplay, isVendor: $isVendor, isCustomer: $isCustomer, id: $id, role: $role, accessToken: $accessToken, refresh: $refresh)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginEntityImpl &&
            (identical(other.lastLogin, lastLogin) ||
                other.lastLogin == lastLogin) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.vendor, vendor) || other.vendor == vendor) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.getFullName, getFullName) ||
                other.getFullName == getFullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.isStaff, isStaff) || other.isStaff == isStaff) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.mobileNo, mobileNo) ||
                other.mobileNo == mobileNo) &&
            const DeepCollectionEquality()
                .equals(other.profileImage, profileImage) &&
            const DeepCollectionEquality().equals(other._modules, _modules) &&
            (identical(other.getRoleDisplay, getRoleDisplay) ||
                other.getRoleDisplay == getRoleDisplay) &&
            (identical(other.isVendor, isVendor) ||
                other.isVendor == isVendor) &&
            (identical(other.isCustomer, isCustomer) ||
                other.isCustomer == isCustomer) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refresh, refresh) || other.refresh == refresh));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        lastLogin,
        username,
        message,
        user,
        vendor,
        vendorId,
        firstName,
        lastName,
        getFullName,
        email,
        isStaff,
        isActive,
        mobileNo,
        const DeepCollectionEquality().hash(profileImage),
        const DeepCollectionEquality().hash(_modules),
        getRoleDisplay,
        isVendor,
        isCustomer,
        id,
        role,
        accessToken,
        refresh
      ]);

  /// Create a copy of LoginEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginEntityImplCopyWith<_$LoginEntityImpl> get copyWith =>
      __$$LoginEntityImplCopyWithImpl<_$LoginEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginEntityImplToJson(
      this,
    );
  }
}

abstract class _LoginEntity implements LoginEntity {
  const factory _LoginEntity(
      {@JsonKey(name: 'last_login') final DateTime? lastLogin,
      @JsonKey(name: 'username') final String? username,
      @JsonKey(name: 'message') final String? message,
      @JsonKey(name: 'user') final int? user,
      @JsonKey(name: 'vendor') final Vendor? vendor,
      @JsonKey(name: 'vendor_id') final num? vendorId,
      @JsonKey(name: 'first_name') final String? firstName,
      @JsonKey(name: 'last_name') final String? lastName,
      @JsonKey(name: 'get_full_name') final String? getFullName,
      @JsonKey(name: 'email') final String? email,
      @JsonKey(name: 'is_staff') final bool? isStaff,
      @JsonKey(name: 'is_active') final bool? isActive,
      @JsonKey(name: 'mobile_no') final String? mobileNo,
      @JsonKey(name: 'profile_image') final dynamic profileImage,
      @JsonKey(name: 'modules') final List<dynamic>? modules,
      @JsonKey(name: 'get_role_display') final String? getRoleDisplay,
      @JsonKey(name: 'is_vendor') final bool? isVendor,
      @JsonKey(name: 'is_customer') final bool? isCustomer,
      @JsonKey(name: 'id') final int? id,
      @JsonKey(name: 'role') final int? role,
      @JsonKey(name: 'access') final String? accessToken,
      @JsonKey(name: 'refresh') final String? refresh}) = _$LoginEntityImpl;

  factory _LoginEntity.fromJson(Map<String, dynamic> json) =
      _$LoginEntityImpl.fromJson;

  @override
  @JsonKey(name: 'last_login')
  DateTime? get lastLogin;
  @override
  @JsonKey(name: 'username')
  String? get username;
  @override
  @JsonKey(name: 'message')
  String? get message;
  @override
  @JsonKey(name: 'user')
  int? get user;
  @override
  @JsonKey(name: 'vendor')
  Vendor? get vendor;
  @override
  @JsonKey(name: 'vendor_id')
  num? get vendorId;
  @override
  @JsonKey(name: 'first_name')
  String? get firstName;
  @override
  @JsonKey(name: 'last_name')
  String? get lastName;
  @override
  @JsonKey(name: 'get_full_name')
  String? get getFullName;
  @override
  @JsonKey(name: 'email')
  String? get email;
  @override
  @JsonKey(name: 'is_staff')
  bool? get isStaff;
  @override
  @JsonKey(name: 'is_active')
  bool? get isActive;
  @override
  @JsonKey(name: 'mobile_no')
  String? get mobileNo;
  @override
  @JsonKey(name: 'profile_image')
  dynamic get profileImage;
  @override
  @JsonKey(name: 'modules')
  List<dynamic>? get modules;
  @override
  @JsonKey(name: 'get_role_display')
  String? get getRoleDisplay;
  @override
  @JsonKey(name: 'is_vendor')
  bool? get isVendor;
  @override
  @JsonKey(name: 'is_customer')
  bool? get isCustomer;
  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'role')
  int? get role;
  @override
  @JsonKey(name: 'access')
  String? get accessToken;
  @override
  @JsonKey(name: 'refresh')
  String? get refresh;

  /// Create a copy of LoginEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginEntityImplCopyWith<_$LoginEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Vendor _$VendorFromJson(Map<String, dynamic> json) {
  return _Vendor.fromJson(json);
}

/// @nodoc
mixin _$Vendor {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'shop_name')
  String? get shopName => throw _privateConstructorUsedError;
  @JsonKey(name: 'vendor_role')
  int? get vendorRole => throw _privateConstructorUsedError;
  @JsonKey(name: 'gstn_number')
  String? get gstnNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_of_establishment')
  dynamic get dateOfEstablishment => throw _privateConstructorUsedError;
  @JsonKey(name: 'business_logo')
  dynamic get businessLogo => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_care_number')
  dynamic get customerCareNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'landline_number')
  dynamic get landlineNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'manufacturing_items')
  dynamic get manufacturingItems => throw _privateConstructorUsedError;
  @JsonKey(name: 'proprietor_first_name')
  dynamic get proprietorFirstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'proprietor_last_name')
  dynamic get proprietorLastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'bank_details')
  dynamic get bankDetails => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_step')
  int? get lastStep => throw _privateConstructorUsedError;
  @JsonKey(name: 'addresses')
  List<dynamic>? get addresses => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_manufacture')
  bool? get isManufacture => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_retailer')
  bool? get isRetailer => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_wholesaler')
  bool? get isWholesaler => throw _privateConstructorUsedError;
  @JsonKey(name: 'documents')
  List<dynamic>? get documents => throw _privateConstructorUsedError;
  @JsonKey(name: 'partner_request')
  dynamic get partnerRequest => throw _privateConstructorUsedError;
  @JsonKey(name: 'latitude')
  dynamic get latitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'longitude')
  dynamic get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_delivery_distance')
  dynamic get totalDeliveryDistance => throw _privateConstructorUsedError;
  @JsonKey(name: 'free_delivery_distance')
  dynamic get freeDeliveryDistance => throw _privateConstructorUsedError;

  /// Serializes this Vendor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Vendor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VendorCopyWith<Vendor> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VendorCopyWith<$Res> {
  factory $VendorCopyWith(Vendor value, $Res Function(Vendor) then) =
      _$VendorCopyWithImpl<$Res, Vendor>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'shop_name') String? shopName,
      @JsonKey(name: 'vendor_role') int? vendorRole,
      @JsonKey(name: 'gstn_number') String? gstnNumber,
      @JsonKey(name: 'date_of_establishment') dynamic dateOfEstablishment,
      @JsonKey(name: 'business_logo') dynamic businessLogo,
      @JsonKey(name: 'customer_care_number') dynamic customerCareNumber,
      @JsonKey(name: 'landline_number') dynamic landlineNumber,
      @JsonKey(name: 'manufacturing_items') dynamic manufacturingItems,
      @JsonKey(name: 'proprietor_first_name') dynamic proprietorFirstName,
      @JsonKey(name: 'proprietor_last_name') dynamic proprietorLastName,
      @JsonKey(name: 'bank_details') dynamic bankDetails,
      @JsonKey(name: 'last_step') int? lastStep,
      @JsonKey(name: 'addresses') List<dynamic>? addresses,
      @JsonKey(name: 'is_manufacture') bool? isManufacture,
      @JsonKey(name: 'is_retailer') bool? isRetailer,
      @JsonKey(name: 'is_wholesaler') bool? isWholesaler,
      @JsonKey(name: 'documents') List<dynamic>? documents,
      @JsonKey(name: 'partner_request') dynamic partnerRequest,
      @JsonKey(name: 'latitude') dynamic latitude,
      @JsonKey(name: 'longitude') dynamic longitude,
      @JsonKey(name: 'total_delivery_distance') dynamic totalDeliveryDistance,
      @JsonKey(name: 'free_delivery_distance') dynamic freeDeliveryDistance});
}

/// @nodoc
class _$VendorCopyWithImpl<$Res, $Val extends Vendor>
    implements $VendorCopyWith<$Res> {
  _$VendorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Vendor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? shopName = freezed,
    Object? vendorRole = freezed,
    Object? gstnNumber = freezed,
    Object? dateOfEstablishment = freezed,
    Object? businessLogo = freezed,
    Object? customerCareNumber = freezed,
    Object? landlineNumber = freezed,
    Object? manufacturingItems = freezed,
    Object? proprietorFirstName = freezed,
    Object? proprietorLastName = freezed,
    Object? bankDetails = freezed,
    Object? lastStep = freezed,
    Object? addresses = freezed,
    Object? isManufacture = freezed,
    Object? isRetailer = freezed,
    Object? isWholesaler = freezed,
    Object? documents = freezed,
    Object? partnerRequest = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? totalDeliveryDistance = freezed,
    Object? freeDeliveryDistance = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      shopName: freezed == shopName
          ? _value.shopName
          : shopName // ignore: cast_nullable_to_non_nullable
              as String?,
      vendorRole: freezed == vendorRole
          ? _value.vendorRole
          : vendorRole // ignore: cast_nullable_to_non_nullable
              as int?,
      gstnNumber: freezed == gstnNumber
          ? _value.gstnNumber
          : gstnNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfEstablishment: freezed == dateOfEstablishment
          ? _value.dateOfEstablishment
          : dateOfEstablishment // ignore: cast_nullable_to_non_nullable
              as dynamic,
      businessLogo: freezed == businessLogo
          ? _value.businessLogo
          : businessLogo // ignore: cast_nullable_to_non_nullable
              as dynamic,
      customerCareNumber: freezed == customerCareNumber
          ? _value.customerCareNumber
          : customerCareNumber // ignore: cast_nullable_to_non_nullable
              as dynamic,
      landlineNumber: freezed == landlineNumber
          ? _value.landlineNumber
          : landlineNumber // ignore: cast_nullable_to_non_nullable
              as dynamic,
      manufacturingItems: freezed == manufacturingItems
          ? _value.manufacturingItems
          : manufacturingItems // ignore: cast_nullable_to_non_nullable
              as dynamic,
      proprietorFirstName: freezed == proprietorFirstName
          ? _value.proprietorFirstName
          : proprietorFirstName // ignore: cast_nullable_to_non_nullable
              as dynamic,
      proprietorLastName: freezed == proprietorLastName
          ? _value.proprietorLastName
          : proprietorLastName // ignore: cast_nullable_to_non_nullable
              as dynamic,
      bankDetails: freezed == bankDetails
          ? _value.bankDetails
          : bankDetails // ignore: cast_nullable_to_non_nullable
              as dynamic,
      lastStep: freezed == lastStep
          ? _value.lastStep
          : lastStep // ignore: cast_nullable_to_non_nullable
              as int?,
      addresses: freezed == addresses
          ? _value.addresses
          : addresses // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      isManufacture: freezed == isManufacture
          ? _value.isManufacture
          : isManufacture // ignore: cast_nullable_to_non_nullable
              as bool?,
      isRetailer: freezed == isRetailer
          ? _value.isRetailer
          : isRetailer // ignore: cast_nullable_to_non_nullable
              as bool?,
      isWholesaler: freezed == isWholesaler
          ? _value.isWholesaler
          : isWholesaler // ignore: cast_nullable_to_non_nullable
              as bool?,
      documents: freezed == documents
          ? _value.documents
          : documents // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      partnerRequest: freezed == partnerRequest
          ? _value.partnerRequest
          : partnerRequest // ignore: cast_nullable_to_non_nullable
              as dynamic,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as dynamic,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as dynamic,
      totalDeliveryDistance: freezed == totalDeliveryDistance
          ? _value.totalDeliveryDistance
          : totalDeliveryDistance // ignore: cast_nullable_to_non_nullable
              as dynamic,
      freeDeliveryDistance: freezed == freeDeliveryDistance
          ? _value.freeDeliveryDistance
          : freeDeliveryDistance // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VendorImplCopyWith<$Res> implements $VendorCopyWith<$Res> {
  factory _$$VendorImplCopyWith(
          _$VendorImpl value, $Res Function(_$VendorImpl) then) =
      __$$VendorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'shop_name') String? shopName,
      @JsonKey(name: 'vendor_role') int? vendorRole,
      @JsonKey(name: 'gstn_number') String? gstnNumber,
      @JsonKey(name: 'date_of_establishment') dynamic dateOfEstablishment,
      @JsonKey(name: 'business_logo') dynamic businessLogo,
      @JsonKey(name: 'customer_care_number') dynamic customerCareNumber,
      @JsonKey(name: 'landline_number') dynamic landlineNumber,
      @JsonKey(name: 'manufacturing_items') dynamic manufacturingItems,
      @JsonKey(name: 'proprietor_first_name') dynamic proprietorFirstName,
      @JsonKey(name: 'proprietor_last_name') dynamic proprietorLastName,
      @JsonKey(name: 'bank_details') dynamic bankDetails,
      @JsonKey(name: 'last_step') int? lastStep,
      @JsonKey(name: 'addresses') List<dynamic>? addresses,
      @JsonKey(name: 'is_manufacture') bool? isManufacture,
      @JsonKey(name: 'is_retailer') bool? isRetailer,
      @JsonKey(name: 'is_wholesaler') bool? isWholesaler,
      @JsonKey(name: 'documents') List<dynamic>? documents,
      @JsonKey(name: 'partner_request') dynamic partnerRequest,
      @JsonKey(name: 'latitude') dynamic latitude,
      @JsonKey(name: 'longitude') dynamic longitude,
      @JsonKey(name: 'total_delivery_distance') dynamic totalDeliveryDistance,
      @JsonKey(name: 'free_delivery_distance') dynamic freeDeliveryDistance});
}

/// @nodoc
class __$$VendorImplCopyWithImpl<$Res>
    extends _$VendorCopyWithImpl<$Res, _$VendorImpl>
    implements _$$VendorImplCopyWith<$Res> {
  __$$VendorImplCopyWithImpl(
      _$VendorImpl _value, $Res Function(_$VendorImpl) _then)
      : super(_value, _then);

  /// Create a copy of Vendor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? shopName = freezed,
    Object? vendorRole = freezed,
    Object? gstnNumber = freezed,
    Object? dateOfEstablishment = freezed,
    Object? businessLogo = freezed,
    Object? customerCareNumber = freezed,
    Object? landlineNumber = freezed,
    Object? manufacturingItems = freezed,
    Object? proprietorFirstName = freezed,
    Object? proprietorLastName = freezed,
    Object? bankDetails = freezed,
    Object? lastStep = freezed,
    Object? addresses = freezed,
    Object? isManufacture = freezed,
    Object? isRetailer = freezed,
    Object? isWholesaler = freezed,
    Object? documents = freezed,
    Object? partnerRequest = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? totalDeliveryDistance = freezed,
    Object? freeDeliveryDistance = freezed,
  }) {
    return _then(_$VendorImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      shopName: freezed == shopName
          ? _value.shopName
          : shopName // ignore: cast_nullable_to_non_nullable
              as String?,
      vendorRole: freezed == vendorRole
          ? _value.vendorRole
          : vendorRole // ignore: cast_nullable_to_non_nullable
              as int?,
      gstnNumber: freezed == gstnNumber
          ? _value.gstnNumber
          : gstnNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfEstablishment: freezed == dateOfEstablishment
          ? _value.dateOfEstablishment
          : dateOfEstablishment // ignore: cast_nullable_to_non_nullable
              as dynamic,
      businessLogo: freezed == businessLogo
          ? _value.businessLogo
          : businessLogo // ignore: cast_nullable_to_non_nullable
              as dynamic,
      customerCareNumber: freezed == customerCareNumber
          ? _value.customerCareNumber
          : customerCareNumber // ignore: cast_nullable_to_non_nullable
              as dynamic,
      landlineNumber: freezed == landlineNumber
          ? _value.landlineNumber
          : landlineNumber // ignore: cast_nullable_to_non_nullable
              as dynamic,
      manufacturingItems: freezed == manufacturingItems
          ? _value.manufacturingItems
          : manufacturingItems // ignore: cast_nullable_to_non_nullable
              as dynamic,
      proprietorFirstName: freezed == proprietorFirstName
          ? _value.proprietorFirstName
          : proprietorFirstName // ignore: cast_nullable_to_non_nullable
              as dynamic,
      proprietorLastName: freezed == proprietorLastName
          ? _value.proprietorLastName
          : proprietorLastName // ignore: cast_nullable_to_non_nullable
              as dynamic,
      bankDetails: freezed == bankDetails
          ? _value.bankDetails
          : bankDetails // ignore: cast_nullable_to_non_nullable
              as dynamic,
      lastStep: freezed == lastStep
          ? _value.lastStep
          : lastStep // ignore: cast_nullable_to_non_nullable
              as int?,
      addresses: freezed == addresses
          ? _value._addresses
          : addresses // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      isManufacture: freezed == isManufacture
          ? _value.isManufacture
          : isManufacture // ignore: cast_nullable_to_non_nullable
              as bool?,
      isRetailer: freezed == isRetailer
          ? _value.isRetailer
          : isRetailer // ignore: cast_nullable_to_non_nullable
              as bool?,
      isWholesaler: freezed == isWholesaler
          ? _value.isWholesaler
          : isWholesaler // ignore: cast_nullable_to_non_nullable
              as bool?,
      documents: freezed == documents
          ? _value._documents
          : documents // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      partnerRequest: freezed == partnerRequest
          ? _value.partnerRequest
          : partnerRequest // ignore: cast_nullable_to_non_nullable
              as dynamic,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as dynamic,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as dynamic,
      totalDeliveryDistance: freezed == totalDeliveryDistance
          ? _value.totalDeliveryDistance
          : totalDeliveryDistance // ignore: cast_nullable_to_non_nullable
              as dynamic,
      freeDeliveryDistance: freezed == freeDeliveryDistance
          ? _value.freeDeliveryDistance
          : freeDeliveryDistance // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VendorImpl implements _Vendor {
  const _$VendorImpl(
      {@JsonKey(name: 'id') this.id,
      @JsonKey(name: 'shop_name') this.shopName,
      @JsonKey(name: 'vendor_role') this.vendorRole,
      @JsonKey(name: 'gstn_number') this.gstnNumber,
      @JsonKey(name: 'date_of_establishment') this.dateOfEstablishment,
      @JsonKey(name: 'business_logo') this.businessLogo,
      @JsonKey(name: 'customer_care_number') this.customerCareNumber,
      @JsonKey(name: 'landline_number') this.landlineNumber,
      @JsonKey(name: 'manufacturing_items') this.manufacturingItems,
      @JsonKey(name: 'proprietor_first_name') this.proprietorFirstName,
      @JsonKey(name: 'proprietor_last_name') this.proprietorLastName,
      @JsonKey(name: 'bank_details') this.bankDetails,
      @JsonKey(name: 'last_step') this.lastStep,
      @JsonKey(name: 'addresses') final List<dynamic>? addresses,
      @JsonKey(name: 'is_manufacture') this.isManufacture,
      @JsonKey(name: 'is_retailer') this.isRetailer,
      @JsonKey(name: 'is_wholesaler') this.isWholesaler,
      @JsonKey(name: 'documents') final List<dynamic>? documents,
      @JsonKey(name: 'partner_request') this.partnerRequest,
      @JsonKey(name: 'latitude') this.latitude,
      @JsonKey(name: 'longitude') this.longitude,
      @JsonKey(name: 'total_delivery_distance') this.totalDeliveryDistance,
      @JsonKey(name: 'free_delivery_distance') this.freeDeliveryDistance})
      : _addresses = addresses,
        _documents = documents;

  factory _$VendorImpl.fromJson(Map<String, dynamic> json) =>
      _$$VendorImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'shop_name')
  final String? shopName;
  @override
  @JsonKey(name: 'vendor_role')
  final int? vendorRole;
  @override
  @JsonKey(name: 'gstn_number')
  final String? gstnNumber;
  @override
  @JsonKey(name: 'date_of_establishment')
  final dynamic dateOfEstablishment;
  @override
  @JsonKey(name: 'business_logo')
  final dynamic businessLogo;
  @override
  @JsonKey(name: 'customer_care_number')
  final dynamic customerCareNumber;
  @override
  @JsonKey(name: 'landline_number')
  final dynamic landlineNumber;
  @override
  @JsonKey(name: 'manufacturing_items')
  final dynamic manufacturingItems;
  @override
  @JsonKey(name: 'proprietor_first_name')
  final dynamic proprietorFirstName;
  @override
  @JsonKey(name: 'proprietor_last_name')
  final dynamic proprietorLastName;
  @override
  @JsonKey(name: 'bank_details')
  final dynamic bankDetails;
  @override
  @JsonKey(name: 'last_step')
  final int? lastStep;
  final List<dynamic>? _addresses;
  @override
  @JsonKey(name: 'addresses')
  List<dynamic>? get addresses {
    final value = _addresses;
    if (value == null) return null;
    if (_addresses is EqualUnmodifiableListView) return _addresses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'is_manufacture')
  final bool? isManufacture;
  @override
  @JsonKey(name: 'is_retailer')
  final bool? isRetailer;
  @override
  @JsonKey(name: 'is_wholesaler')
  final bool? isWholesaler;
  final List<dynamic>? _documents;
  @override
  @JsonKey(name: 'documents')
  List<dynamic>? get documents {
    final value = _documents;
    if (value == null) return null;
    if (_documents is EqualUnmodifiableListView) return _documents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'partner_request')
  final dynamic partnerRequest;
  @override
  @JsonKey(name: 'latitude')
  final dynamic latitude;
  @override
  @JsonKey(name: 'longitude')
  final dynamic longitude;
  @override
  @JsonKey(name: 'total_delivery_distance')
  final dynamic totalDeliveryDistance;
  @override
  @JsonKey(name: 'free_delivery_distance')
  final dynamic freeDeliveryDistance;

  @override
  String toString() {
    return 'Vendor(id: $id, shopName: $shopName, vendorRole: $vendorRole, gstnNumber: $gstnNumber, dateOfEstablishment: $dateOfEstablishment, businessLogo: $businessLogo, customerCareNumber: $customerCareNumber, landlineNumber: $landlineNumber, manufacturingItems: $manufacturingItems, proprietorFirstName: $proprietorFirstName, proprietorLastName: $proprietorLastName, bankDetails: $bankDetails, lastStep: $lastStep, addresses: $addresses, isManufacture: $isManufacture, isRetailer: $isRetailer, isWholesaler: $isWholesaler, documents: $documents, partnerRequest: $partnerRequest, latitude: $latitude, longitude: $longitude, totalDeliveryDistance: $totalDeliveryDistance, freeDeliveryDistance: $freeDeliveryDistance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shopName, shopName) ||
                other.shopName == shopName) &&
            (identical(other.vendorRole, vendorRole) ||
                other.vendorRole == vendorRole) &&
            (identical(other.gstnNumber, gstnNumber) ||
                other.gstnNumber == gstnNumber) &&
            const DeepCollectionEquality()
                .equals(other.dateOfEstablishment, dateOfEstablishment) &&
            const DeepCollectionEquality()
                .equals(other.businessLogo, businessLogo) &&
            const DeepCollectionEquality()
                .equals(other.customerCareNumber, customerCareNumber) &&
            const DeepCollectionEquality()
                .equals(other.landlineNumber, landlineNumber) &&
            const DeepCollectionEquality()
                .equals(other.manufacturingItems, manufacturingItems) &&
            const DeepCollectionEquality()
                .equals(other.proprietorFirstName, proprietorFirstName) &&
            const DeepCollectionEquality()
                .equals(other.proprietorLastName, proprietorLastName) &&
            const DeepCollectionEquality()
                .equals(other.bankDetails, bankDetails) &&
            (identical(other.lastStep, lastStep) ||
                other.lastStep == lastStep) &&
            const DeepCollectionEquality()
                .equals(other._addresses, _addresses) &&
            (identical(other.isManufacture, isManufacture) ||
                other.isManufacture == isManufacture) &&
            (identical(other.isRetailer, isRetailer) ||
                other.isRetailer == isRetailer) &&
            (identical(other.isWholesaler, isWholesaler) ||
                other.isWholesaler == isWholesaler) &&
            const DeepCollectionEquality()
                .equals(other._documents, _documents) &&
            const DeepCollectionEquality()
                .equals(other.partnerRequest, partnerRequest) &&
            const DeepCollectionEquality().equals(other.latitude, latitude) &&
            const DeepCollectionEquality().equals(other.longitude, longitude) &&
            const DeepCollectionEquality()
                .equals(other.totalDeliveryDistance, totalDeliveryDistance) &&
            const DeepCollectionEquality()
                .equals(other.freeDeliveryDistance, freeDeliveryDistance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        shopName,
        vendorRole,
        gstnNumber,
        const DeepCollectionEquality().hash(dateOfEstablishment),
        const DeepCollectionEquality().hash(businessLogo),
        const DeepCollectionEquality().hash(customerCareNumber),
        const DeepCollectionEquality().hash(landlineNumber),
        const DeepCollectionEquality().hash(manufacturingItems),
        const DeepCollectionEquality().hash(proprietorFirstName),
        const DeepCollectionEquality().hash(proprietorLastName),
        const DeepCollectionEquality().hash(bankDetails),
        lastStep,
        const DeepCollectionEquality().hash(_addresses),
        isManufacture,
        isRetailer,
        isWholesaler,
        const DeepCollectionEquality().hash(_documents),
        const DeepCollectionEquality().hash(partnerRequest),
        const DeepCollectionEquality().hash(latitude),
        const DeepCollectionEquality().hash(longitude),
        const DeepCollectionEquality().hash(totalDeliveryDistance),
        const DeepCollectionEquality().hash(freeDeliveryDistance)
      ]);

  /// Create a copy of Vendor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VendorImplCopyWith<_$VendorImpl> get copyWith =>
      __$$VendorImplCopyWithImpl<_$VendorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VendorImplToJson(
      this,
    );
  }
}

abstract class _Vendor implements Vendor {
  const factory _Vendor(
      {@JsonKey(name: 'id') final int? id,
      @JsonKey(name: 'shop_name') final String? shopName,
      @JsonKey(name: 'vendor_role') final int? vendorRole,
      @JsonKey(name: 'gstn_number') final String? gstnNumber,
      @JsonKey(name: 'date_of_establishment') final dynamic dateOfEstablishment,
      @JsonKey(name: 'business_logo') final dynamic businessLogo,
      @JsonKey(name: 'customer_care_number') final dynamic customerCareNumber,
      @JsonKey(name: 'landline_number') final dynamic landlineNumber,
      @JsonKey(name: 'manufacturing_items') final dynamic manufacturingItems,
      @JsonKey(name: 'proprietor_first_name') final dynamic proprietorFirstName,
      @JsonKey(name: 'proprietor_last_name') final dynamic proprietorLastName,
      @JsonKey(name: 'bank_details') final dynamic bankDetails,
      @JsonKey(name: 'last_step') final int? lastStep,
      @JsonKey(name: 'addresses') final List<dynamic>? addresses,
      @JsonKey(name: 'is_manufacture') final bool? isManufacture,
      @JsonKey(name: 'is_retailer') final bool? isRetailer,
      @JsonKey(name: 'is_wholesaler') final bool? isWholesaler,
      @JsonKey(name: 'documents') final List<dynamic>? documents,
      @JsonKey(name: 'partner_request') final dynamic partnerRequest,
      @JsonKey(name: 'latitude') final dynamic latitude,
      @JsonKey(name: 'longitude') final dynamic longitude,
      @JsonKey(name: 'total_delivery_distance')
      final dynamic totalDeliveryDistance,
      @JsonKey(name: 'free_delivery_distance')
      final dynamic freeDeliveryDistance}) = _$VendorImpl;

  factory _Vendor.fromJson(Map<String, dynamic> json) = _$VendorImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'shop_name')
  String? get shopName;
  @override
  @JsonKey(name: 'vendor_role')
  int? get vendorRole;
  @override
  @JsonKey(name: 'gstn_number')
  String? get gstnNumber;
  @override
  @JsonKey(name: 'date_of_establishment')
  dynamic get dateOfEstablishment;
  @override
  @JsonKey(name: 'business_logo')
  dynamic get businessLogo;
  @override
  @JsonKey(name: 'customer_care_number')
  dynamic get customerCareNumber;
  @override
  @JsonKey(name: 'landline_number')
  dynamic get landlineNumber;
  @override
  @JsonKey(name: 'manufacturing_items')
  dynamic get manufacturingItems;
  @override
  @JsonKey(name: 'proprietor_first_name')
  dynamic get proprietorFirstName;
  @override
  @JsonKey(name: 'proprietor_last_name')
  dynamic get proprietorLastName;
  @override
  @JsonKey(name: 'bank_details')
  dynamic get bankDetails;
  @override
  @JsonKey(name: 'last_step')
  int? get lastStep;
  @override
  @JsonKey(name: 'addresses')
  List<dynamic>? get addresses;
  @override
  @JsonKey(name: 'is_manufacture')
  bool? get isManufacture;
  @override
  @JsonKey(name: 'is_retailer')
  bool? get isRetailer;
  @override
  @JsonKey(name: 'is_wholesaler')
  bool? get isWholesaler;
  @override
  @JsonKey(name: 'documents')
  List<dynamic>? get documents;
  @override
  @JsonKey(name: 'partner_request')
  dynamic get partnerRequest;
  @override
  @JsonKey(name: 'latitude')
  dynamic get latitude;
  @override
  @JsonKey(name: 'longitude')
  dynamic get longitude;
  @override
  @JsonKey(name: 'total_delivery_distance')
  dynamic get totalDeliveryDistance;
  @override
  @JsonKey(name: 'free_delivery_distance')
  dynamic get freeDeliveryDistance;

  /// Create a copy of Vendor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VendorImplCopyWith<_$VendorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
