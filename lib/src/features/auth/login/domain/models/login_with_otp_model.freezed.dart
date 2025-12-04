// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_with_otp_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LoginSuccessModel _$LoginSuccessModelFromJson(Map<String, dynamic> json) {
  return _LoginWithOtpEntity.fromJson(json);
}

/// @nodoc
mixin _$LoginSuccessModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'access')
  String? get access => throw _privateConstructorUsedError;
  @JsonKey(name: 'refresh')
  String? get refresh => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String? get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String? get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'mobile_number')
  String? get mobileNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'email')
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'blood_group')
  String? get bloodGroup => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_login')
  DateTime? get lastLogin => throw _privateConstructorUsedError;
  @JsonKey(name: 'mentor')
  Mentor? get mentor => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer')
  dynamic get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_picture')
  dynamic get profilePicture => throw _privateConstructorUsedError;
  @JsonKey(name: 'warnings')
  List<dynamic>? get warnings => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_profile_complete')
  bool? get isProfileCompleted => throw _privateConstructorUsedError;

  /// Serializes this LoginSuccessModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginSuccessModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginSuccessModelCopyWith<LoginSuccessModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginSuccessModelCopyWith<$Res> {
  factory $LoginSuccessModelCopyWith(
    LoginSuccessModel value,
    $Res Function(LoginSuccessModel) then,
  ) = _$LoginSuccessModelCopyWithImpl<$Res, LoginSuccessModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'access') String? access,
    @JsonKey(name: 'refresh') String? refresh,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'blood_group') String? bloodGroup,
    @JsonKey(name: 'last_login') DateTime? lastLogin,
    @JsonKey(name: 'mentor') Mentor? mentor,
    @JsonKey(name: 'customer') dynamic customer,
    @JsonKey(name: 'profile_picture') dynamic profilePicture,
    @JsonKey(name: 'warnings') List<dynamic>? warnings,
    @JsonKey(name: 'is_profile_complete') bool? isProfileCompleted,
  });

  $MentorCopyWith<$Res>? get mentor;
}

/// @nodoc
class _$LoginSuccessModelCopyWithImpl<$Res, $Val extends LoginSuccessModel>
    implements $LoginSuccessModelCopyWith<$Res> {
  _$LoginSuccessModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginSuccessModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? access = freezed,
    Object? refresh = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? mobileNumber = freezed,
    Object? email = freezed,
    Object? bloodGroup = freezed,
    Object? lastLogin = freezed,
    Object? mentor = freezed,
    Object? customer = freezed,
    Object? profilePicture = freezed,
    Object? warnings = freezed,
    Object? isProfileCompleted = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            access:
                freezed == access
                    ? _value.access
                    : access // ignore: cast_nullable_to_non_nullable
                        as String?,
            refresh:
                freezed == refresh
                    ? _value.refresh
                    : refresh // ignore: cast_nullable_to_non_nullable
                        as String?,
            firstName:
                freezed == firstName
                    ? _value.firstName
                    : firstName // ignore: cast_nullable_to_non_nullable
                        as String?,
            lastName:
                freezed == lastName
                    ? _value.lastName
                    : lastName // ignore: cast_nullable_to_non_nullable
                        as String?,
            mobileNumber:
                freezed == mobileNumber
                    ? _value.mobileNumber
                    : mobileNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            bloodGroup:
                freezed == bloodGroup
                    ? _value.bloodGroup
                    : bloodGroup // ignore: cast_nullable_to_non_nullable
                        as String?,
            lastLogin:
                freezed == lastLogin
                    ? _value.lastLogin
                    : lastLogin // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            mentor:
                freezed == mentor
                    ? _value.mentor
                    : mentor // ignore: cast_nullable_to_non_nullable
                        as Mentor?,
            customer:
                freezed == customer
                    ? _value.customer
                    : customer // ignore: cast_nullable_to_non_nullable
                        as dynamic,
            profilePicture:
                freezed == profilePicture
                    ? _value.profilePicture
                    : profilePicture // ignore: cast_nullable_to_non_nullable
                        as dynamic,
            warnings:
                freezed == warnings
                    ? _value.warnings
                    : warnings // ignore: cast_nullable_to_non_nullable
                        as List<dynamic>?,
            isProfileCompleted:
                freezed == isProfileCompleted
                    ? _value.isProfileCompleted
                    : isProfileCompleted // ignore: cast_nullable_to_non_nullable
                        as bool?,
          )
          as $Val,
    );
  }

  /// Create a copy of LoginSuccessModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MentorCopyWith<$Res>? get mentor {
    if (_value.mentor == null) {
      return null;
    }

    return $MentorCopyWith<$Res>(_value.mentor!, (value) {
      return _then(_value.copyWith(mentor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LoginWithOtpEntityImplCopyWith<$Res>
    implements $LoginSuccessModelCopyWith<$Res> {
  factory _$$LoginWithOtpEntityImplCopyWith(
    _$LoginWithOtpEntityImpl value,
    $Res Function(_$LoginWithOtpEntityImpl) then,
  ) = __$$LoginWithOtpEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'access') String? access,
    @JsonKey(name: 'refresh') String? refresh,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'blood_group') String? bloodGroup,
    @JsonKey(name: 'last_login') DateTime? lastLogin,
    @JsonKey(name: 'mentor') Mentor? mentor,
    @JsonKey(name: 'customer') dynamic customer,
    @JsonKey(name: 'profile_picture') dynamic profilePicture,
    @JsonKey(name: 'warnings') List<dynamic>? warnings,
    @JsonKey(name: 'is_profile_complete') bool? isProfileCompleted,
  });

  @override
  $MentorCopyWith<$Res>? get mentor;
}

/// @nodoc
class __$$LoginWithOtpEntityImplCopyWithImpl<$Res>
    extends _$LoginSuccessModelCopyWithImpl<$Res, _$LoginWithOtpEntityImpl>
    implements _$$LoginWithOtpEntityImplCopyWith<$Res> {
  __$$LoginWithOtpEntityImplCopyWithImpl(
    _$LoginWithOtpEntityImpl _value,
    $Res Function(_$LoginWithOtpEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginSuccessModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? access = freezed,
    Object? refresh = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? mobileNumber = freezed,
    Object? email = freezed,
    Object? bloodGroup = freezed,
    Object? lastLogin = freezed,
    Object? mentor = freezed,
    Object? customer = freezed,
    Object? profilePicture = freezed,
    Object? warnings = freezed,
    Object? isProfileCompleted = freezed,
  }) {
    return _then(
      _$LoginWithOtpEntityImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        access:
            freezed == access
                ? _value.access
                : access // ignore: cast_nullable_to_non_nullable
                    as String?,
        refresh:
            freezed == refresh
                ? _value.refresh
                : refresh // ignore: cast_nullable_to_non_nullable
                    as String?,
        firstName:
            freezed == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                    as String?,
        lastName:
            freezed == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                    as String?,
        mobileNumber:
            freezed == mobileNumber
                ? _value.mobileNumber
                : mobileNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        bloodGroup:
            freezed == bloodGroup
                ? _value.bloodGroup
                : bloodGroup // ignore: cast_nullable_to_non_nullable
                    as String?,
        lastLogin:
            freezed == lastLogin
                ? _value.lastLogin
                : lastLogin // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        mentor:
            freezed == mentor
                ? _value.mentor
                : mentor // ignore: cast_nullable_to_non_nullable
                    as Mentor?,
        customer:
            freezed == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                    as dynamic,
        profilePicture:
            freezed == profilePicture
                ? _value.profilePicture
                : profilePicture // ignore: cast_nullable_to_non_nullable
                    as dynamic,
        warnings:
            freezed == warnings
                ? _value._warnings
                : warnings // ignore: cast_nullable_to_non_nullable
                    as List<dynamic>?,
        isProfileCompleted:
            freezed == isProfileCompleted
                ? _value.isProfileCompleted
                : isProfileCompleted // ignore: cast_nullable_to_non_nullable
                    as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginWithOtpEntityImpl implements _LoginWithOtpEntity {
  const _$LoginWithOtpEntityImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'access') this.access,
    @JsonKey(name: 'refresh') this.refresh,
    @JsonKey(name: 'first_name') this.firstName,
    @JsonKey(name: 'last_name') this.lastName,
    @JsonKey(name: 'mobile_number') this.mobileNumber,
    @JsonKey(name: 'email') this.email,
    @JsonKey(name: 'blood_group') this.bloodGroup,
    @JsonKey(name: 'last_login') this.lastLogin,
    @JsonKey(name: 'mentor') this.mentor,
    @JsonKey(name: 'customer') this.customer,
    @JsonKey(name: 'profile_picture') this.profilePicture,
    @JsonKey(name: 'warnings') final List<dynamic>? warnings,
    @JsonKey(name: 'is_profile_complete') this.isProfileCompleted,
  }) : _warnings = warnings;

  factory _$LoginWithOtpEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginWithOtpEntityImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'access')
  final String? access;
  @override
  @JsonKey(name: 'refresh')
  final String? refresh;
  @override
  @JsonKey(name: 'first_name')
  final String? firstName;
  @override
  @JsonKey(name: 'last_name')
  final String? lastName;
  @override
  @JsonKey(name: 'mobile_number')
  final String? mobileNumber;
  @override
  @JsonKey(name: 'email')
  final String? email;
  @override
  @JsonKey(name: 'blood_group')
  final String? bloodGroup;
  @override
  @JsonKey(name: 'last_login')
  final DateTime? lastLogin;
  @override
  @JsonKey(name: 'mentor')
  final Mentor? mentor;
  @override
  @JsonKey(name: 'customer')
  final dynamic customer;
  @override
  @JsonKey(name: 'profile_picture')
  final dynamic profilePicture;
  final List<dynamic>? _warnings;
  @override
  @JsonKey(name: 'warnings')
  List<dynamic>? get warnings {
    final value = _warnings;
    if (value == null) return null;
    if (_warnings is EqualUnmodifiableListView) return _warnings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'is_profile_complete')
  final bool? isProfileCompleted;

  @override
  String toString() {
    return 'LoginSuccessModel(id: $id, access: $access, refresh: $refresh, firstName: $firstName, lastName: $lastName, mobileNumber: $mobileNumber, email: $email, bloodGroup: $bloodGroup, lastLogin: $lastLogin, mentor: $mentor, customer: $customer, profilePicture: $profilePicture, warnings: $warnings, isProfileCompleted: $isProfileCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginWithOtpEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.access, access) || other.access == access) &&
            (identical(other.refresh, refresh) || other.refresh == refresh) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.mobileNumber, mobileNumber) ||
                other.mobileNumber == mobileNumber) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.bloodGroup, bloodGroup) ||
                other.bloodGroup == bloodGroup) &&
            (identical(other.lastLogin, lastLogin) ||
                other.lastLogin == lastLogin) &&
            (identical(other.mentor, mentor) || other.mentor == mentor) &&
            const DeepCollectionEquality().equals(other.customer, customer) &&
            const DeepCollectionEquality().equals(
              other.profilePicture,
              profilePicture,
            ) &&
            const DeepCollectionEquality().equals(other._warnings, _warnings) &&
            (identical(other.isProfileCompleted, isProfileCompleted) ||
                other.isProfileCompleted == isProfileCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    access,
    refresh,
    firstName,
    lastName,
    mobileNumber,
    email,
    bloodGroup,
    lastLogin,
    mentor,
    const DeepCollectionEquality().hash(customer),
    const DeepCollectionEquality().hash(profilePicture),
    const DeepCollectionEquality().hash(_warnings),
    isProfileCompleted,
  );

  /// Create a copy of LoginSuccessModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginWithOtpEntityImplCopyWith<_$LoginWithOtpEntityImpl> get copyWith =>
      __$$LoginWithOtpEntityImplCopyWithImpl<_$LoginWithOtpEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginWithOtpEntityImplToJson(this);
  }
}

abstract class _LoginWithOtpEntity implements LoginSuccessModel {
  const factory _LoginWithOtpEntity({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'access') final String? access,
    @JsonKey(name: 'refresh') final String? refresh,
    @JsonKey(name: 'first_name') final String? firstName,
    @JsonKey(name: 'last_name') final String? lastName,
    @JsonKey(name: 'mobile_number') final String? mobileNumber,
    @JsonKey(name: 'email') final String? email,
    @JsonKey(name: 'blood_group') final String? bloodGroup,
    @JsonKey(name: 'last_login') final DateTime? lastLogin,
    @JsonKey(name: 'mentor') final Mentor? mentor,
    @JsonKey(name: 'customer') final dynamic customer,
    @JsonKey(name: 'profile_picture') final dynamic profilePicture,
    @JsonKey(name: 'warnings') final List<dynamic>? warnings,
    @JsonKey(name: 'is_profile_complete') final bool? isProfileCompleted,
  }) = _$LoginWithOtpEntityImpl;

  factory _LoginWithOtpEntity.fromJson(Map<String, dynamic> json) =
      _$LoginWithOtpEntityImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'access')
  String? get access;
  @override
  @JsonKey(name: 'refresh')
  String? get refresh;
  @override
  @JsonKey(name: 'first_name')
  String? get firstName;
  @override
  @JsonKey(name: 'last_name')
  String? get lastName;
  @override
  @JsonKey(name: 'mobile_number')
  String? get mobileNumber;
  @override
  @JsonKey(name: 'email')
  String? get email;
  @override
  @JsonKey(name: 'blood_group')
  String? get bloodGroup;
  @override
  @JsonKey(name: 'last_login')
  DateTime? get lastLogin;
  @override
  @JsonKey(name: 'mentor')
  Mentor? get mentor;
  @override
  @JsonKey(name: 'customer')
  dynamic get customer;
  @override
  @JsonKey(name: 'profile_picture')
  dynamic get profilePicture;
  @override
  @JsonKey(name: 'warnings')
  List<dynamic>? get warnings;
  @override
  @JsonKey(name: 'is_profile_complete')
  bool? get isProfileCompleted;

  /// Create a copy of LoginSuccessModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginWithOtpEntityImplCopyWith<_$LoginWithOtpEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Mentor _$MentorFromJson(Map<String, dynamic> json) {
  return _Mentor.fromJson(json);
}

/// @nodoc
mixin _$Mentor {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization')
  Org? get org => throw _privateConstructorUsedError;

  /// Serializes this Mentor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Mentor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MentorCopyWith<Mentor> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MentorCopyWith<$Res> {
  factory $MentorCopyWith(Mentor value, $Res Function(Mentor) then) =
      _$MentorCopyWithImpl<$Res, Mentor>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'organization') Org? org,
  });

  $OrgCopyWith<$Res>? get org;
}

/// @nodoc
class _$MentorCopyWithImpl<$Res, $Val extends Mentor>
    implements $MentorCopyWith<$Res> {
  _$MentorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Mentor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? org = freezed,
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
            org:
                freezed == org
                    ? _value.org
                    : org // ignore: cast_nullable_to_non_nullable
                        as Org?,
          )
          as $Val,
    );
  }

  /// Create a copy of Mentor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrgCopyWith<$Res>? get org {
    if (_value.org == null) {
      return null;
    }

    return $OrgCopyWith<$Res>(_value.org!, (value) {
      return _then(_value.copyWith(org: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MentorImplCopyWith<$Res> implements $MentorCopyWith<$Res> {
  factory _$$MentorImplCopyWith(
    _$MentorImpl value,
    $Res Function(_$MentorImpl) then,
  ) = __$$MentorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'organization') Org? org,
  });

  @override
  $OrgCopyWith<$Res>? get org;
}

/// @nodoc
class __$$MentorImplCopyWithImpl<$Res>
    extends _$MentorCopyWithImpl<$Res, _$MentorImpl>
    implements _$$MentorImplCopyWith<$Res> {
  __$$MentorImplCopyWithImpl(
    _$MentorImpl _value,
    $Res Function(_$MentorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Mentor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? org = freezed,
  }) {
    return _then(
      _$MentorImpl(
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
        org:
            freezed == org
                ? _value.org
                : org // ignore: cast_nullable_to_non_nullable
                    as Org?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MentorImpl implements _Mentor {
  const _$MentorImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'organization') this.org,
  });

  factory _$MentorImpl.fromJson(Map<String, dynamic> json) =>
      _$$MentorImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'organization')
  final Org? org;

  @override
  String toString() {
    return 'Mentor(id: $id, name: $name, org: $org)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MentorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.org, org) || other.org == org));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, org);

  /// Create a copy of Mentor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MentorImplCopyWith<_$MentorImpl> get copyWith =>
      __$$MentorImplCopyWithImpl<_$MentorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MentorImplToJson(this);
  }
}

abstract class _Mentor implements Mentor {
  const factory _Mentor({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'organization') final Org? org,
  }) = _$MentorImpl;

  factory _Mentor.fromJson(Map<String, dynamic> json) = _$MentorImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'organization')
  Org? get org;

  /// Create a copy of Mentor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MentorImplCopyWith<_$MentorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Org _$OrgFromJson(Map<String, dynamic> json) {
  return _Org.fromJson(json);
}

/// @nodoc
mixin _$Org {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_completeness')
  int? get profileCompleteness => throw _privateConstructorUsedError;

  /// Serializes this Org to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Org
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrgCopyWith<Org> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrgCopyWith<$Res> {
  factory $OrgCopyWith(Org value, $Res Function(Org) then) =
      _$OrgCopyWithImpl<$Res, Org>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'profile_completeness') int? profileCompleteness,
  });
}

/// @nodoc
class _$OrgCopyWithImpl<$Res, $Val extends Org> implements $OrgCopyWith<$Res> {
  _$OrgCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Org
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? profileCompleteness = freezed,
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
            profileCompleteness:
                freezed == profileCompleteness
                    ? _value.profileCompleteness
                    : profileCompleteness // ignore: cast_nullable_to_non_nullable
                        as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrgImplCopyWith<$Res> implements $OrgCopyWith<$Res> {
  factory _$$OrgImplCopyWith(_$OrgImpl value, $Res Function(_$OrgImpl) then) =
      __$$OrgImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'profile_completeness') int? profileCompleteness,
  });
}

/// @nodoc
class __$$OrgImplCopyWithImpl<$Res> extends _$OrgCopyWithImpl<$Res, _$OrgImpl>
    implements _$$OrgImplCopyWith<$Res> {
  __$$OrgImplCopyWithImpl(_$OrgImpl _value, $Res Function(_$OrgImpl) _then)
    : super(_value, _then);

  /// Create a copy of Org
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? profileCompleteness = freezed,
  }) {
    return _then(
      _$OrgImpl(
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
        profileCompleteness:
            freezed == profileCompleteness
                ? _value.profileCompleteness
                : profileCompleteness // ignore: cast_nullable_to_non_nullable
                    as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrgImpl implements _Org {
  const _$OrgImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'profile_completeness') this.profileCompleteness,
  });

  factory _$OrgImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrgImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'profile_completeness')
  final int? profileCompleteness;

  @override
  String toString() {
    return 'Org(id: $id, name: $name, profileCompleteness: $profileCompleteness)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrgImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.profileCompleteness, profileCompleteness) ||
                other.profileCompleteness == profileCompleteness));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, profileCompleteness);

  /// Create a copy of Org
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrgImplCopyWith<_$OrgImpl> get copyWith =>
      __$$OrgImplCopyWithImpl<_$OrgImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrgImplToJson(this);
  }
}

abstract class _Org implements Org {
  const factory _Org({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'profile_completeness') final int? profileCompleteness,
  }) = _$OrgImpl;

  factory _Org.fromJson(Map<String, dynamic> json) = _$OrgImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'profile_completeness')
  int? get profileCompleteness;

  /// Create a copy of Org
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrgImplCopyWith<_$OrgImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
