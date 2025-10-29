// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_details_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MemberDetailsModel _$MemberDetailsModelFromJson(Map<String, dynamic> json) {
  return _MemberDetailsModel.fromJson(json);
}

/// @nodoc
mixin _$MemberDetailsModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_picture')
  String? get profilePicture => throw _privateConstructorUsedError;
  @JsonKey(name: 'emergency_contact_name')
  String? get emergencyContactName => throw _privateConstructorUsedError;
  @JsonKey(name: 'emergency_contact_number')
  String? get emergencyContactNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'height')
  String? get height => throw _privateConstructorUsedError;
  @JsonKey(name: 'weight')
  String? get weight => throw _privateConstructorUsedError;
  @JsonKey(name: 'profession')
  String? get profession => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active_member')
  bool? get isActiveMember => throw _privateConstructorUsedError;
  @JsonKey(name: 'memberships')
  List<MembershipDataModel>? get memberships =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String? get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'created')
  DateTime? get created => throw _privateConstructorUsedError;
  @JsonKey(name: 'modified')
  DateTime? get modified => throw _privateConstructorUsedError;
  @JsonKey(name: 'mobile_number')
  String? get mobileNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String? get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String? get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'email')
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_of_birth')
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  @JsonKey(name: 'gender')
  String? get gender => throw _privateConstructorUsedError;
  @JsonKey(name: 'blood_group')
  String? get bloodGroup => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_role')
  String? get userRole => throw _privateConstructorUsedError;
  @JsonKey(name: 'hash_of_user_phone_number')
  String? get hashOfUserPhoneNumber => throw _privateConstructorUsedError;

  /// Serializes this MemberDetailsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemberDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberDetailsModelCopyWith<MemberDetailsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberDetailsModelCopyWith<$Res> {
  factory $MemberDetailsModelCopyWith(
    MemberDetailsModel value,
    $Res Function(MemberDetailsModel) then,
  ) = _$MemberDetailsModelCopyWithImpl<$Res, MemberDetailsModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'profile_picture') String? profilePicture,
    @JsonKey(name: 'emergency_contact_name') String? emergencyContactName,
    @JsonKey(name: 'emergency_contact_number') String? emergencyContactNumber,
    @JsonKey(name: 'height') String? height,
    @JsonKey(name: 'weight') String? weight,
    @JsonKey(name: 'profession') String? profession,
    @JsonKey(name: 'is_active_member') bool? isActiveMember,
    @JsonKey(name: 'memberships') List<MembershipDataModel>? memberships,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'created') DateTime? created,
    @JsonKey(name: 'modified') DateTime? modified,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
    @JsonKey(name: 'gender') String? gender,
    @JsonKey(name: 'blood_group') String? bloodGroup,
    @JsonKey(name: 'user_role') String? userRole,
    @JsonKey(name: 'hash_of_user_phone_number') String? hashOfUserPhoneNumber,
  });
}

/// @nodoc
class _$MemberDetailsModelCopyWithImpl<$Res, $Val extends MemberDetailsModel>
    implements $MemberDetailsModelCopyWith<$Res> {
  _$MemberDetailsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemberDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? profilePicture = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactNumber = freezed,
    Object? height = freezed,
    Object? weight = freezed,
    Object? profession = freezed,
    Object? isActiveMember = freezed,
    Object? memberships = freezed,
    Object? fullName = freezed,
    Object? created = freezed,
    Object? modified = freezed,
    Object? mobileNumber = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? email = freezed,
    Object? dateOfBirth = freezed,
    Object? gender = freezed,
    Object? bloodGroup = freezed,
    Object? userRole = freezed,
    Object? hashOfUserPhoneNumber = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            profilePicture:
                freezed == profilePicture
                    ? _value.profilePicture
                    : profilePicture // ignore: cast_nullable_to_non_nullable
                        as String?,
            emergencyContactName:
                freezed == emergencyContactName
                    ? _value.emergencyContactName
                    : emergencyContactName // ignore: cast_nullable_to_non_nullable
                        as String?,
            emergencyContactNumber:
                freezed == emergencyContactNumber
                    ? _value.emergencyContactNumber
                    : emergencyContactNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            height:
                freezed == height
                    ? _value.height
                    : height // ignore: cast_nullable_to_non_nullable
                        as String?,
            weight:
                freezed == weight
                    ? _value.weight
                    : weight // ignore: cast_nullable_to_non_nullable
                        as String?,
            profession:
                freezed == profession
                    ? _value.profession
                    : profession // ignore: cast_nullable_to_non_nullable
                        as String?,
            isActiveMember:
                freezed == isActiveMember
                    ? _value.isActiveMember
                    : isActiveMember // ignore: cast_nullable_to_non_nullable
                        as bool?,
            memberships:
                freezed == memberships
                    ? _value.memberships
                    : memberships // ignore: cast_nullable_to_non_nullable
                        as List<MembershipDataModel>?,
            fullName:
                freezed == fullName
                    ? _value.fullName
                    : fullName // ignore: cast_nullable_to_non_nullable
                        as String?,
            created:
                freezed == created
                    ? _value.created
                    : created // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            modified:
                freezed == modified
                    ? _value.modified
                    : modified // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            mobileNumber:
                freezed == mobileNumber
                    ? _value.mobileNumber
                    : mobileNumber // ignore: cast_nullable_to_non_nullable
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
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            dateOfBirth:
                freezed == dateOfBirth
                    ? _value.dateOfBirth
                    : dateOfBirth // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            gender:
                freezed == gender
                    ? _value.gender
                    : gender // ignore: cast_nullable_to_non_nullable
                        as String?,
            bloodGroup:
                freezed == bloodGroup
                    ? _value.bloodGroup
                    : bloodGroup // ignore: cast_nullable_to_non_nullable
                        as String?,
            userRole:
                freezed == userRole
                    ? _value.userRole
                    : userRole // ignore: cast_nullable_to_non_nullable
                        as String?,
            hashOfUserPhoneNumber:
                freezed == hashOfUserPhoneNumber
                    ? _value.hashOfUserPhoneNumber
                    : hashOfUserPhoneNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MemberDetailsModelImplCopyWith<$Res>
    implements $MemberDetailsModelCopyWith<$Res> {
  factory _$$MemberDetailsModelImplCopyWith(
    _$MemberDetailsModelImpl value,
    $Res Function(_$MemberDetailsModelImpl) then,
  ) = __$$MemberDetailsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'profile_picture') String? profilePicture,
    @JsonKey(name: 'emergency_contact_name') String? emergencyContactName,
    @JsonKey(name: 'emergency_contact_number') String? emergencyContactNumber,
    @JsonKey(name: 'height') String? height,
    @JsonKey(name: 'weight') String? weight,
    @JsonKey(name: 'profession') String? profession,
    @JsonKey(name: 'is_active_member') bool? isActiveMember,
    @JsonKey(name: 'memberships') List<MembershipDataModel>? memberships,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'created') DateTime? created,
    @JsonKey(name: 'modified') DateTime? modified,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
    @JsonKey(name: 'gender') String? gender,
    @JsonKey(name: 'blood_group') String? bloodGroup,
    @JsonKey(name: 'user_role') String? userRole,
    @JsonKey(name: 'hash_of_user_phone_number') String? hashOfUserPhoneNumber,
  });
}

/// @nodoc
class __$$MemberDetailsModelImplCopyWithImpl<$Res>
    extends _$MemberDetailsModelCopyWithImpl<$Res, _$MemberDetailsModelImpl>
    implements _$$MemberDetailsModelImplCopyWith<$Res> {
  __$$MemberDetailsModelImplCopyWithImpl(
    _$MemberDetailsModelImpl _value,
    $Res Function(_$MemberDetailsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MemberDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? profilePicture = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactNumber = freezed,
    Object? height = freezed,
    Object? weight = freezed,
    Object? profession = freezed,
    Object? isActiveMember = freezed,
    Object? memberships = freezed,
    Object? fullName = freezed,
    Object? created = freezed,
    Object? modified = freezed,
    Object? mobileNumber = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? email = freezed,
    Object? dateOfBirth = freezed,
    Object? gender = freezed,
    Object? bloodGroup = freezed,
    Object? userRole = freezed,
    Object? hashOfUserPhoneNumber = freezed,
  }) {
    return _then(
      _$MemberDetailsModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        profilePicture:
            freezed == profilePicture
                ? _value.profilePicture
                : profilePicture // ignore: cast_nullable_to_non_nullable
                    as String?,
        emergencyContactName:
            freezed == emergencyContactName
                ? _value.emergencyContactName
                : emergencyContactName // ignore: cast_nullable_to_non_nullable
                    as String?,
        emergencyContactNumber:
            freezed == emergencyContactNumber
                ? _value.emergencyContactNumber
                : emergencyContactNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        height:
            freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                    as String?,
        weight:
            freezed == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                    as String?,
        profession:
            freezed == profession
                ? _value.profession
                : profession // ignore: cast_nullable_to_non_nullable
                    as String?,
        isActiveMember:
            freezed == isActiveMember
                ? _value.isActiveMember
                : isActiveMember // ignore: cast_nullable_to_non_nullable
                    as bool?,
        memberships:
            freezed == memberships
                ? _value._memberships
                : memberships // ignore: cast_nullable_to_non_nullable
                    as List<MembershipDataModel>?,
        fullName:
            freezed == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                    as String?,
        created:
            freezed == created
                ? _value.created
                : created // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        modified:
            freezed == modified
                ? _value.modified
                : modified // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        mobileNumber:
            freezed == mobileNumber
                ? _value.mobileNumber
                : mobileNumber // ignore: cast_nullable_to_non_nullable
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
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        dateOfBirth:
            freezed == dateOfBirth
                ? _value.dateOfBirth
                : dateOfBirth // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        gender:
            freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                    as String?,
        bloodGroup:
            freezed == bloodGroup
                ? _value.bloodGroup
                : bloodGroup // ignore: cast_nullable_to_non_nullable
                    as String?,
        userRole:
            freezed == userRole
                ? _value.userRole
                : userRole // ignore: cast_nullable_to_non_nullable
                    as String?,
        hashOfUserPhoneNumber:
            freezed == hashOfUserPhoneNumber
                ? _value.hashOfUserPhoneNumber
                : hashOfUserPhoneNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MemberDetailsModelImpl implements _MemberDetailsModel {
  const _$MemberDetailsModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'profile_picture') this.profilePicture,
    @JsonKey(name: 'emergency_contact_name') this.emergencyContactName,
    @JsonKey(name: 'emergency_contact_number') this.emergencyContactNumber,
    @JsonKey(name: 'height') this.height,
    @JsonKey(name: 'weight') this.weight,
    @JsonKey(name: 'profession') this.profession,
    @JsonKey(name: 'is_active_member') this.isActiveMember,
    @JsonKey(name: 'memberships') final List<MembershipDataModel>? memberships,
    @JsonKey(name: 'full_name') this.fullName,
    @JsonKey(name: 'created') this.created,
    @JsonKey(name: 'modified') this.modified,
    @JsonKey(name: 'mobile_number') this.mobileNumber,
    @JsonKey(name: 'first_name') this.firstName,
    @JsonKey(name: 'last_name') this.lastName,
    @JsonKey(name: 'email') this.email,
    @JsonKey(name: 'date_of_birth') this.dateOfBirth,
    @JsonKey(name: 'gender') this.gender,
    @JsonKey(name: 'blood_group') this.bloodGroup,
    @JsonKey(name: 'user_role') this.userRole,
    @JsonKey(name: 'hash_of_user_phone_number') this.hashOfUserPhoneNumber,
  }) : _memberships = memberships;

  factory _$MemberDetailsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemberDetailsModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  @override
  @JsonKey(name: 'emergency_contact_name')
  final String? emergencyContactName;
  @override
  @JsonKey(name: 'emergency_contact_number')
  final String? emergencyContactNumber;
  @override
  @JsonKey(name: 'height')
  final String? height;
  @override
  @JsonKey(name: 'weight')
  final String? weight;
  @override
  @JsonKey(name: 'profession')
  final String? profession;
  @override
  @JsonKey(name: 'is_active_member')
  final bool? isActiveMember;
  final List<MembershipDataModel>? _memberships;
  @override
  @JsonKey(name: 'memberships')
  List<MembershipDataModel>? get memberships {
    final value = _memberships;
    if (value == null) return null;
    if (_memberships is EqualUnmodifiableListView) return _memberships;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'full_name')
  final String? fullName;
  @override
  @JsonKey(name: 'created')
  final DateTime? created;
  @override
  @JsonKey(name: 'modified')
  final DateTime? modified;
  @override
  @JsonKey(name: 'mobile_number')
  final String? mobileNumber;
  @override
  @JsonKey(name: 'first_name')
  final String? firstName;
  @override
  @JsonKey(name: 'last_name')
  final String? lastName;
  @override
  @JsonKey(name: 'email')
  final String? email;
  @override
  @JsonKey(name: 'date_of_birth')
  final DateTime? dateOfBirth;
  @override
  @JsonKey(name: 'gender')
  final String? gender;
  @override
  @JsonKey(name: 'blood_group')
  final String? bloodGroup;
  @override
  @JsonKey(name: 'user_role')
  final String? userRole;
  @override
  @JsonKey(name: 'hash_of_user_phone_number')
  final String? hashOfUserPhoneNumber;

  @override
  String toString() {
    return 'MemberDetailsModel(id: $id, profilePicture: $profilePicture, emergencyContactName: $emergencyContactName, emergencyContactNumber: $emergencyContactNumber, height: $height, weight: $weight, profession: $profession, isActiveMember: $isActiveMember, memberships: $memberships, fullName: $fullName, created: $created, modified: $modified, mobileNumber: $mobileNumber, firstName: $firstName, lastName: $lastName, email: $email, dateOfBirth: $dateOfBirth, gender: $gender, bloodGroup: $bloodGroup, userRole: $userRole, hashOfUserPhoneNumber: $hashOfUserPhoneNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberDetailsModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture) &&
            (identical(other.emergencyContactName, emergencyContactName) ||
                other.emergencyContactName == emergencyContactName) &&
            (identical(other.emergencyContactNumber, emergencyContactNumber) ||
                other.emergencyContactNumber == emergencyContactNumber) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.profession, profession) ||
                other.profession == profession) &&
            (identical(other.isActiveMember, isActiveMember) ||
                other.isActiveMember == isActiveMember) &&
            const DeepCollectionEquality().equals(
              other._memberships,
              _memberships,
            ) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.created, created) || other.created == created) &&
            (identical(other.modified, modified) ||
                other.modified == modified) &&
            (identical(other.mobileNumber, mobileNumber) ||
                other.mobileNumber == mobileNumber) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.bloodGroup, bloodGroup) ||
                other.bloodGroup == bloodGroup) &&
            (identical(other.userRole, userRole) ||
                other.userRole == userRole) &&
            (identical(other.hashOfUserPhoneNumber, hashOfUserPhoneNumber) ||
                other.hashOfUserPhoneNumber == hashOfUserPhoneNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    profilePicture,
    emergencyContactName,
    emergencyContactNumber,
    height,
    weight,
    profession,
    isActiveMember,
    const DeepCollectionEquality().hash(_memberships),
    fullName,
    created,
    modified,
    mobileNumber,
    firstName,
    lastName,
    email,
    dateOfBirth,
    gender,
    bloodGroup,
    userRole,
    hashOfUserPhoneNumber,
  ]);

  /// Create a copy of MemberDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberDetailsModelImplCopyWith<_$MemberDetailsModelImpl> get copyWith =>
      __$$MemberDetailsModelImplCopyWithImpl<_$MemberDetailsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MemberDetailsModelImplToJson(this);
  }
}

abstract class _MemberDetailsModel implements MemberDetailsModel {
  const factory _MemberDetailsModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'profile_picture') final String? profilePicture,
    @JsonKey(name: 'emergency_contact_name') final String? emergencyContactName,
    @JsonKey(name: 'emergency_contact_number')
    final String? emergencyContactNumber,
    @JsonKey(name: 'height') final String? height,
    @JsonKey(name: 'weight') final String? weight,
    @JsonKey(name: 'profession') final String? profession,
    @JsonKey(name: 'is_active_member') final bool? isActiveMember,
    @JsonKey(name: 'memberships') final List<MembershipDataModel>? memberships,
    @JsonKey(name: 'full_name') final String? fullName,
    @JsonKey(name: 'created') final DateTime? created,
    @JsonKey(name: 'modified') final DateTime? modified,
    @JsonKey(name: 'mobile_number') final String? mobileNumber,
    @JsonKey(name: 'first_name') final String? firstName,
    @JsonKey(name: 'last_name') final String? lastName,
    @JsonKey(name: 'email') final String? email,
    @JsonKey(name: 'date_of_birth') final DateTime? dateOfBirth,
    @JsonKey(name: 'gender') final String? gender,
    @JsonKey(name: 'blood_group') final String? bloodGroup,
    @JsonKey(name: 'user_role') final String? userRole,
    @JsonKey(name: 'hash_of_user_phone_number')
    final String? hashOfUserPhoneNumber,
  }) = _$MemberDetailsModelImpl;

  factory _MemberDetailsModel.fromJson(Map<String, dynamic> json) =
      _$MemberDetailsModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'profile_picture')
  String? get profilePicture;
  @override
  @JsonKey(name: 'emergency_contact_name')
  String? get emergencyContactName;
  @override
  @JsonKey(name: 'emergency_contact_number')
  String? get emergencyContactNumber;
  @override
  @JsonKey(name: 'height')
  String? get height;
  @override
  @JsonKey(name: 'weight')
  String? get weight;
  @override
  @JsonKey(name: 'profession')
  String? get profession;
  @override
  @JsonKey(name: 'is_active_member')
  bool? get isActiveMember;
  @override
  @JsonKey(name: 'memberships')
  List<MembershipDataModel>? get memberships;
  @override
  @JsonKey(name: 'full_name')
  String? get fullName;
  @override
  @JsonKey(name: 'created')
  DateTime? get created;
  @override
  @JsonKey(name: 'modified')
  DateTime? get modified;
  @override
  @JsonKey(name: 'mobile_number')
  String? get mobileNumber;
  @override
  @JsonKey(name: 'first_name')
  String? get firstName;
  @override
  @JsonKey(name: 'last_name')
  String? get lastName;
  @override
  @JsonKey(name: 'email')
  String? get email;
  @override
  @JsonKey(name: 'date_of_birth')
  DateTime? get dateOfBirth;
  @override
  @JsonKey(name: 'gender')
  String? get gender;
  @override
  @JsonKey(name: 'blood_group')
  String? get bloodGroup;
  @override
  @JsonKey(name: 'user_role')
  String? get userRole;
  @override
  @JsonKey(name: 'hash_of_user_phone_number')
  String? get hashOfUserPhoneNumber;

  /// Create a copy of MemberDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberDetailsModelImplCopyWith<_$MemberDetailsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MembershipDataModel _$MembershipDataModelFromJson(Map<String, dynamic> json) {
  return _MembershipDataModel.fromJson(json);
}

/// @nodoc
mixin _$MembershipDataModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'membership')
  int? get membership => throw _privateConstructorUsedError;
  @JsonKey(name: 'membership_name')
  String? get membershipName => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime? get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount')
  String? get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'assign_free')
  bool? get assignFree => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_trial')
  bool? get isTrial => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_status')
  String? get paymentStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool? get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'trial_start_at')
  DateTime? get trialStartAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'trial_end_at')
  DateTime? get trialEndAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this MembershipDataModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MembershipDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MembershipDataModelCopyWith<MembershipDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembershipDataModelCopyWith<$Res> {
  factory $MembershipDataModelCopyWith(
    MembershipDataModel value,
    $Res Function(MembershipDataModel) then,
  ) = _$MembershipDataModelCopyWithImpl<$Res, MembershipDataModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'membership') int? membership,
    @JsonKey(name: 'membership_name') String? membershipName,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'assign_free') bool? assignFree,
    @JsonKey(name: 'is_trial') bool? isTrial,
    @JsonKey(name: 'payment_status') String? paymentStatus,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'trial_start_at') DateTime? trialStartAt,
    @JsonKey(name: 'trial_end_at') DateTime? trialEndAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$MembershipDataModelCopyWithImpl<$Res, $Val extends MembershipDataModel>
    implements $MembershipDataModelCopyWith<$Res> {
  _$MembershipDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MembershipDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? membership = freezed,
    Object? membershipName = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? status = freezed,
    Object? amount = freezed,
    Object? assignFree = freezed,
    Object? isTrial = freezed,
    Object? paymentStatus = freezed,
    Object? isActive = freezed,
    Object? trialStartAt = freezed,
    Object? trialEndAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            membership:
                freezed == membership
                    ? _value.membership
                    : membership // ignore: cast_nullable_to_non_nullable
                        as int?,
            membershipName:
                freezed == membershipName
                    ? _value.membershipName
                    : membershipName // ignore: cast_nullable_to_non_nullable
                        as String?,
            startDate:
                freezed == startDate
                    ? _value.startDate
                    : startDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            endDate:
                freezed == endDate
                    ? _value.endDate
                    : endDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            status:
                freezed == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String?,
            amount:
                freezed == amount
                    ? _value.amount
                    : amount // ignore: cast_nullable_to_non_nullable
                        as String?,
            assignFree:
                freezed == assignFree
                    ? _value.assignFree
                    : assignFree // ignore: cast_nullable_to_non_nullable
                        as bool?,
            isTrial:
                freezed == isTrial
                    ? _value.isTrial
                    : isTrial // ignore: cast_nullable_to_non_nullable
                        as bool?,
            paymentStatus:
                freezed == paymentStatus
                    ? _value.paymentStatus
                    : paymentStatus // ignore: cast_nullable_to_non_nullable
                        as String?,
            isActive:
                freezed == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool?,
            trialStartAt:
                freezed == trialStartAt
                    ? _value.trialStartAt
                    : trialStartAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            trialEndAt:
                freezed == trialEndAt
                    ? _value.trialEndAt
                    : trialEndAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            updatedAt:
                freezed == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MembershipDataModelImplCopyWith<$Res>
    implements $MembershipDataModelCopyWith<$Res> {
  factory _$$MembershipDataModelImplCopyWith(
    _$MembershipDataModelImpl value,
    $Res Function(_$MembershipDataModelImpl) then,
  ) = __$$MembershipDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'membership') int? membership,
    @JsonKey(name: 'membership_name') String? membershipName,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'amount') String? amount,
    @JsonKey(name: 'assign_free') bool? assignFree,
    @JsonKey(name: 'is_trial') bool? isTrial,
    @JsonKey(name: 'payment_status') String? paymentStatus,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'trial_start_at') DateTime? trialStartAt,
    @JsonKey(name: 'trial_end_at') DateTime? trialEndAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$$MembershipDataModelImplCopyWithImpl<$Res>
    extends _$MembershipDataModelCopyWithImpl<$Res, _$MembershipDataModelImpl>
    implements _$$MembershipDataModelImplCopyWith<$Res> {
  __$$MembershipDataModelImplCopyWithImpl(
    _$MembershipDataModelImpl _value,
    $Res Function(_$MembershipDataModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MembershipDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? membership = freezed,
    Object? membershipName = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? status = freezed,
    Object? amount = freezed,
    Object? assignFree = freezed,
    Object? isTrial = freezed,
    Object? paymentStatus = freezed,
    Object? isActive = freezed,
    Object? trialStartAt = freezed,
    Object? trialEndAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$MembershipDataModelImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        membership:
            freezed == membership
                ? _value.membership
                : membership // ignore: cast_nullable_to_non_nullable
                    as int?,
        membershipName:
            freezed == membershipName
                ? _value.membershipName
                : membershipName // ignore: cast_nullable_to_non_nullable
                    as String?,
        startDate:
            freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        endDate:
            freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        status:
            freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String?,
        amount:
            freezed == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                    as String?,
        assignFree:
            freezed == assignFree
                ? _value.assignFree
                : assignFree // ignore: cast_nullable_to_non_nullable
                    as bool?,
        isTrial:
            freezed == isTrial
                ? _value.isTrial
                : isTrial // ignore: cast_nullable_to_non_nullable
                    as bool?,
        paymentStatus:
            freezed == paymentStatus
                ? _value.paymentStatus
                : paymentStatus // ignore: cast_nullable_to_non_nullable
                    as String?,
        isActive:
            freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool?,
        trialStartAt:
            freezed == trialStartAt
                ? _value.trialStartAt
                : trialStartAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        trialEndAt:
            freezed == trialEndAt
                ? _value.trialEndAt
                : trialEndAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        updatedAt:
            freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MembershipDataModelImpl implements _MembershipDataModel {
  const _$MembershipDataModelImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'membership') this.membership,
    @JsonKey(name: 'membership_name') this.membershipName,
    @JsonKey(name: 'start_date') this.startDate,
    @JsonKey(name: 'end_date') this.endDate,
    @JsonKey(name: 'status') this.status,
    @JsonKey(name: 'amount') this.amount,
    @JsonKey(name: 'assign_free') this.assignFree,
    @JsonKey(name: 'is_trial') this.isTrial,
    @JsonKey(name: 'payment_status') this.paymentStatus,
    @JsonKey(name: 'is_active') this.isActive,
    @JsonKey(name: 'trial_start_at') this.trialStartAt,
    @JsonKey(name: 'trial_end_at') this.trialEndAt,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  });

  factory _$MembershipDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MembershipDataModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'membership')
  final int? membership;
  @override
  @JsonKey(name: 'membership_name')
  final String? membershipName;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @override
  @JsonKey(name: 'status')
  final String? status;
  @override
  @JsonKey(name: 'amount')
  final String? amount;
  @override
  @JsonKey(name: 'assign_free')
  final bool? assignFree;
  @override
  @JsonKey(name: 'is_trial')
  final bool? isTrial;
  @override
  @JsonKey(name: 'payment_status')
  final String? paymentStatus;
  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @override
  @JsonKey(name: 'trial_start_at')
  final DateTime? trialStartAt;
  @override
  @JsonKey(name: 'trial_end_at')
  final DateTime? trialEndAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'MembershipDataModel(id: $id, membership: $membership, membershipName: $membershipName, startDate: $startDate, endDate: $endDate, status: $status, amount: $amount, assignFree: $assignFree, isTrial: $isTrial, paymentStatus: $paymentStatus, isActive: $isActive, trialStartAt: $trialStartAt, trialEndAt: $trialEndAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MembershipDataModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.membership, membership) ||
                other.membership == membership) &&
            (identical(other.membershipName, membershipName) ||
                other.membershipName == membershipName) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.assignFree, assignFree) ||
                other.assignFree == assignFree) &&
            (identical(other.isTrial, isTrial) || other.isTrial == isTrial) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.trialStartAt, trialStartAt) ||
                other.trialStartAt == trialStartAt) &&
            (identical(other.trialEndAt, trialEndAt) ||
                other.trialEndAt == trialEndAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    membership,
    membershipName,
    startDate,
    endDate,
    status,
    amount,
    assignFree,
    isTrial,
    paymentStatus,
    isActive,
    trialStartAt,
    trialEndAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of MembershipDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MembershipDataModelImplCopyWith<_$MembershipDataModelImpl> get copyWith =>
      __$$MembershipDataModelImplCopyWithImpl<_$MembershipDataModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MembershipDataModelImplToJson(this);
  }
}

abstract class _MembershipDataModel implements MembershipDataModel {
  const factory _MembershipDataModel({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'membership') final int? membership,
    @JsonKey(name: 'membership_name') final String? membershipName,
    @JsonKey(name: 'start_date') final DateTime? startDate,
    @JsonKey(name: 'end_date') final DateTime? endDate,
    @JsonKey(name: 'status') final String? status,
    @JsonKey(name: 'amount') final String? amount,
    @JsonKey(name: 'assign_free') final bool? assignFree,
    @JsonKey(name: 'is_trial') final bool? isTrial,
    @JsonKey(name: 'payment_status') final String? paymentStatus,
    @JsonKey(name: 'is_active') final bool? isActive,
    @JsonKey(name: 'trial_start_at') final DateTime? trialStartAt,
    @JsonKey(name: 'trial_end_at') final DateTime? trialEndAt,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
  }) = _$MembershipDataModelImpl;

  factory _MembershipDataModel.fromJson(Map<String, dynamic> json) =
      _$MembershipDataModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'membership')
  int? get membership;
  @override
  @JsonKey(name: 'membership_name')
  String? get membershipName;
  @override
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime? get endDate;
  @override
  @JsonKey(name: 'status')
  String? get status;
  @override
  @JsonKey(name: 'amount')
  String? get amount;
  @override
  @JsonKey(name: 'assign_free')
  bool? get assignFree;
  @override
  @JsonKey(name: 'is_trial')
  bool? get isTrial;
  @override
  @JsonKey(name: 'payment_status')
  String? get paymentStatus;
  @override
  @JsonKey(name: 'is_active')
  bool? get isActive;
  @override
  @JsonKey(name: 'trial_start_at')
  DateTime? get trialStartAt;
  @override
  @JsonKey(name: 'trial_end_at')
  DateTime? get trialEndAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of MembershipDataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MembershipDataModelImplCopyWith<_$MembershipDataModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
