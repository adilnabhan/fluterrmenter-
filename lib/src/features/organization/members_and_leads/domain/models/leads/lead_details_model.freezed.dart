// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lead_details_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LeadDetailsModel _$LeadDetailsModelFromJson(Map<String, dynamic> json) {
  return _LeadDetailsModel.fromJson(json);
}

/// @nodoc
mixin _$LeadDetailsModel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String? get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String? get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'mobile_number')
  String? get mobileNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'email')
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'gender')
  String? get gender => throw _privateConstructorUsedError;
  @JsonKey(name: 'blood_group')
  String? get bloodGroup => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_of_birth')
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  @JsonKey(name: 'mentor_profile')
  MentorProfileData? get mentorProfile => throw _privateConstructorUsedError;
  @JsonKey(name: 'certificates')
  List<dynamic>? get certificates => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_picture')
  dynamic get profilePicture => throw _privateConstructorUsedError;

  /// Serializes this LeadDetailsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeadDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadDetailsModelCopyWith<LeadDetailsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadDetailsModelCopyWith<$Res> {
  factory $LeadDetailsModelCopyWith(
          LeadDetailsModel value, $Res Function(LeadDetailsModel) then) =
      _$LeadDetailsModelCopyWithImpl<$Res, LeadDetailsModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'first_name') String? firstName,
      @JsonKey(name: 'last_name') String? lastName,
      @JsonKey(name: 'mobile_number') String? mobileNumber,
      @JsonKey(name: 'email') String? email,
      @JsonKey(name: 'gender') String? gender,
      @JsonKey(name: 'blood_group') String? bloodGroup,
      @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
      @JsonKey(name: 'mentor_profile') MentorProfileData? mentorProfile,
      @JsonKey(name: 'certificates') List<dynamic>? certificates,
      @JsonKey(name: 'profile_picture') dynamic profilePicture});

  $MentorProfileDataCopyWith<$Res>? get mentorProfile;
}

/// @nodoc
class _$LeadDetailsModelCopyWithImpl<$Res, $Val extends LeadDetailsModel>
    implements $LeadDetailsModelCopyWith<$Res> {
  _$LeadDetailsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeadDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? mobileNumber = freezed,
    Object? email = freezed,
    Object? gender = freezed,
    Object? bloodGroup = freezed,
    Object? dateOfBirth = freezed,
    Object? mentorProfile = freezed,
    Object? certificates = freezed,
    Object? profilePicture = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      mobileNumber: freezed == mobileNumber
          ? _value.mobileNumber
          : mobileNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      bloodGroup: freezed == bloodGroup
          ? _value.bloodGroup
          : bloodGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mentorProfile: freezed == mentorProfile
          ? _value.mentorProfile
          : mentorProfile // ignore: cast_nullable_to_non_nullable
              as MentorProfileData?,
      certificates: freezed == certificates
          ? _value.certificates
          : certificates // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      profilePicture: freezed == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }

  /// Create a copy of LeadDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MentorProfileDataCopyWith<$Res>? get mentorProfile {
    if (_value.mentorProfile == null) {
      return null;
    }

    return $MentorProfileDataCopyWith<$Res>(_value.mentorProfile!, (value) {
      return _then(_value.copyWith(mentorProfile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LeadDetailsModelImplCopyWith<$Res>
    implements $LeadDetailsModelCopyWith<$Res> {
  factory _$$LeadDetailsModelImplCopyWith(_$LeadDetailsModelImpl value,
          $Res Function(_$LeadDetailsModelImpl) then) =
      __$$LeadDetailsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'first_name') String? firstName,
      @JsonKey(name: 'last_name') String? lastName,
      @JsonKey(name: 'mobile_number') String? mobileNumber,
      @JsonKey(name: 'email') String? email,
      @JsonKey(name: 'gender') String? gender,
      @JsonKey(name: 'blood_group') String? bloodGroup,
      @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
      @JsonKey(name: 'mentor_profile') MentorProfileData? mentorProfile,
      @JsonKey(name: 'certificates') List<dynamic>? certificates,
      @JsonKey(name: 'profile_picture') dynamic profilePicture});

  @override
  $MentorProfileDataCopyWith<$Res>? get mentorProfile;
}

/// @nodoc
class __$$LeadDetailsModelImplCopyWithImpl<$Res>
    extends _$LeadDetailsModelCopyWithImpl<$Res, _$LeadDetailsModelImpl>
    implements _$$LeadDetailsModelImplCopyWith<$Res> {
  __$$LeadDetailsModelImplCopyWithImpl(_$LeadDetailsModelImpl _value,
      $Res Function(_$LeadDetailsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LeadDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? mobileNumber = freezed,
    Object? email = freezed,
    Object? gender = freezed,
    Object? bloodGroup = freezed,
    Object? dateOfBirth = freezed,
    Object? mentorProfile = freezed,
    Object? certificates = freezed,
    Object? profilePicture = freezed,
  }) {
    return _then(_$LeadDetailsModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      mobileNumber: freezed == mobileNumber
          ? _value.mobileNumber
          : mobileNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      bloodGroup: freezed == bloodGroup
          ? _value.bloodGroup
          : bloodGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mentorProfile: freezed == mentorProfile
          ? _value.mentorProfile
          : mentorProfile // ignore: cast_nullable_to_non_nullable
              as MentorProfileData?,
      certificates: freezed == certificates
          ? _value._certificates
          : certificates // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      profilePicture: freezed == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeadDetailsModelImpl implements _LeadDetailsModel {
  const _$LeadDetailsModelImpl(
      {@JsonKey(name: 'id') this.id,
      @JsonKey(name: 'first_name') this.firstName,
      @JsonKey(name: 'last_name') this.lastName,
      @JsonKey(name: 'mobile_number') this.mobileNumber,
      @JsonKey(name: 'email') this.email,
      @JsonKey(name: 'gender') this.gender,
      @JsonKey(name: 'blood_group') this.bloodGroup,
      @JsonKey(name: 'date_of_birth') this.dateOfBirth,
      @JsonKey(name: 'mentor_profile') this.mentorProfile,
      @JsonKey(name: 'certificates') final List<dynamic>? certificates,
      @JsonKey(name: 'profile_picture') this.profilePicture})
      : _certificates = certificates;

  factory _$LeadDetailsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeadDetailsModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
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
  @JsonKey(name: 'gender')
  final String? gender;
  @override
  @JsonKey(name: 'blood_group')
  final String? bloodGroup;
  @override
  @JsonKey(name: 'date_of_birth')
  final DateTime? dateOfBirth;
  @override
  @JsonKey(name: 'mentor_profile')
  final MentorProfileData? mentorProfile;
  final List<dynamic>? _certificates;
  @override
  @JsonKey(name: 'certificates')
  List<dynamic>? get certificates {
    final value = _certificates;
    if (value == null) return null;
    if (_certificates is EqualUnmodifiableListView) return _certificates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'profile_picture')
  final dynamic profilePicture;

  @override
  String toString() {
    return 'LeadDetailsModel(id: $id, firstName: $firstName, lastName: $lastName, mobileNumber: $mobileNumber, email: $email, gender: $gender, bloodGroup: $bloodGroup, dateOfBirth: $dateOfBirth, mentorProfile: $mentorProfile, certificates: $certificates, profilePicture: $profilePicture)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadDetailsModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.mobileNumber, mobileNumber) ||
                other.mobileNumber == mobileNumber) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.bloodGroup, bloodGroup) ||
                other.bloodGroup == bloodGroup) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.mentorProfile, mentorProfile) ||
                other.mentorProfile == mentorProfile) &&
            const DeepCollectionEquality()
                .equals(other._certificates, _certificates) &&
            const DeepCollectionEquality()
                .equals(other.profilePicture, profilePicture));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      firstName,
      lastName,
      mobileNumber,
      email,
      gender,
      bloodGroup,
      dateOfBirth,
      mentorProfile,
      const DeepCollectionEquality().hash(_certificates),
      const DeepCollectionEquality().hash(profilePicture));

  /// Create a copy of LeadDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadDetailsModelImplCopyWith<_$LeadDetailsModelImpl> get copyWith =>
      __$$LeadDetailsModelImplCopyWithImpl<_$LeadDetailsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeadDetailsModelImplToJson(
      this,
    );
  }
}

abstract class _LeadDetailsModel implements LeadDetailsModel {
  const factory _LeadDetailsModel(
      {@JsonKey(name: 'id') final int? id,
      @JsonKey(name: 'first_name') final String? firstName,
      @JsonKey(name: 'last_name') final String? lastName,
      @JsonKey(name: 'mobile_number') final String? mobileNumber,
      @JsonKey(name: 'email') final String? email,
      @JsonKey(name: 'gender') final String? gender,
      @JsonKey(name: 'blood_group') final String? bloodGroup,
      @JsonKey(name: 'date_of_birth') final DateTime? dateOfBirth,
      @JsonKey(name: 'mentor_profile') final MentorProfileData? mentorProfile,
      @JsonKey(name: 'certificates') final List<dynamic>? certificates,
      @JsonKey(name: 'profile_picture')
      final dynamic profilePicture}) = _$LeadDetailsModelImpl;

  factory _LeadDetailsModel.fromJson(Map<String, dynamic> json) =
      _$LeadDetailsModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
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
  @JsonKey(name: 'gender')
  String? get gender;
  @override
  @JsonKey(name: 'blood_group')
  String? get bloodGroup;
  @override
  @JsonKey(name: 'date_of_birth')
  DateTime? get dateOfBirth;
  @override
  @JsonKey(name: 'mentor_profile')
  MentorProfileData? get mentorProfile;
  @override
  @JsonKey(name: 'certificates')
  List<dynamic>? get certificates;
  @override
  @JsonKey(name: 'profile_picture')
  dynamic get profilePicture;

  /// Create a copy of LeadDetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadDetailsModelImplCopyWith<_$LeadDetailsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MentorProfileData _$MentorProfileDataFromJson(Map<String, dynamic> json) {
  return _MentorProfileData.fromJson(json);
}

/// @nodoc
mixin _$MentorProfileData {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization')
  Organization? get organization => throw _privateConstructorUsedError;
  @JsonKey(name: 'experience')
  String? get experience => throw _privateConstructorUsedError;
  @JsonKey(name: 'designation')
  String? get designation => throw _privateConstructorUsedError;
  @JsonKey(name: 'emergency_contact')
  String? get emergencyContact => throw _privateConstructorUsedError;
  @JsonKey(name: 'address_proof')
  dynamic get addressProof => throw _privateConstructorUsedError;
  @JsonKey(name: 'categories')
  List<MultiSelectSingleDataEntity>? get categories =>
      throw _privateConstructorUsedError;

  /// Serializes this MentorProfileData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MentorProfileData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MentorProfileDataCopyWith<MentorProfileData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MentorProfileDataCopyWith<$Res> {
  factory $MentorProfileDataCopyWith(
          MentorProfileData value, $Res Function(MentorProfileData) then) =
      _$MentorProfileDataCopyWithImpl<$Res, MentorProfileData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'organization') Organization? organization,
      @JsonKey(name: 'experience') String? experience,
      @JsonKey(name: 'designation') String? designation,
      @JsonKey(name: 'emergency_contact') String? emergencyContact,
      @JsonKey(name: 'address_proof') dynamic addressProof,
      @JsonKey(name: 'categories')
      List<MultiSelectSingleDataEntity>? categories});

  $OrganizationCopyWith<$Res>? get organization;
}

/// @nodoc
class _$MentorProfileDataCopyWithImpl<$Res, $Val extends MentorProfileData>
    implements $MentorProfileDataCopyWith<$Res> {
  _$MentorProfileDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MentorProfileData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? organization = freezed,
    Object? experience = freezed,
    Object? designation = freezed,
    Object? emergencyContact = freezed,
    Object? addressProof = freezed,
    Object? categories = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      organization: freezed == organization
          ? _value.organization
          : organization // ignore: cast_nullable_to_non_nullable
              as Organization?,
      experience: freezed == experience
          ? _value.experience
          : experience // ignore: cast_nullable_to_non_nullable
              as String?,
      designation: freezed == designation
          ? _value.designation
          : designation // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyContact: freezed == emergencyContact
          ? _value.emergencyContact
          : emergencyContact // ignore: cast_nullable_to_non_nullable
              as String?,
      addressProof: freezed == addressProof
          ? _value.addressProof
          : addressProof // ignore: cast_nullable_to_non_nullable
              as dynamic,
      categories: freezed == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<MultiSelectSingleDataEntity>?,
    ) as $Val);
  }

  /// Create a copy of MentorProfileData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrganizationCopyWith<$Res>? get organization {
    if (_value.organization == null) {
      return null;
    }

    return $OrganizationCopyWith<$Res>(_value.organization!, (value) {
      return _then(_value.copyWith(organization: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MentorProfileDataImplCopyWith<$Res>
    implements $MentorProfileDataCopyWith<$Res> {
  factory _$$MentorProfileDataImplCopyWith(_$MentorProfileDataImpl value,
          $Res Function(_$MentorProfileDataImpl) then) =
      __$$MentorProfileDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'organization') Organization? organization,
      @JsonKey(name: 'experience') String? experience,
      @JsonKey(name: 'designation') String? designation,
      @JsonKey(name: 'emergency_contact') String? emergencyContact,
      @JsonKey(name: 'address_proof') dynamic addressProof,
      @JsonKey(name: 'categories')
      List<MultiSelectSingleDataEntity>? categories});

  @override
  $OrganizationCopyWith<$Res>? get organization;
}

/// @nodoc
class __$$MentorProfileDataImplCopyWithImpl<$Res>
    extends _$MentorProfileDataCopyWithImpl<$Res, _$MentorProfileDataImpl>
    implements _$$MentorProfileDataImplCopyWith<$Res> {
  __$$MentorProfileDataImplCopyWithImpl(_$MentorProfileDataImpl _value,
      $Res Function(_$MentorProfileDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of MentorProfileData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? organization = freezed,
    Object? experience = freezed,
    Object? designation = freezed,
    Object? emergencyContact = freezed,
    Object? addressProof = freezed,
    Object? categories = freezed,
  }) {
    return _then(_$MentorProfileDataImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      organization: freezed == organization
          ? _value.organization
          : organization // ignore: cast_nullable_to_non_nullable
              as Organization?,
      experience: freezed == experience
          ? _value.experience
          : experience // ignore: cast_nullable_to_non_nullable
              as String?,
      designation: freezed == designation
          ? _value.designation
          : designation // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyContact: freezed == emergencyContact
          ? _value.emergencyContact
          : emergencyContact // ignore: cast_nullable_to_non_nullable
              as String?,
      addressProof: freezed == addressProof
          ? _value.addressProof
          : addressProof // ignore: cast_nullable_to_non_nullable
              as dynamic,
      categories: freezed == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<MultiSelectSingleDataEntity>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MentorProfileDataImpl implements _MentorProfileData {
  const _$MentorProfileDataImpl(
      {@JsonKey(name: 'id') this.id,
      @JsonKey(name: 'organization') this.organization,
      @JsonKey(name: 'experience') this.experience,
      @JsonKey(name: 'designation') this.designation,
      @JsonKey(name: 'emergency_contact') this.emergencyContact,
      @JsonKey(name: 'address_proof') this.addressProof,
      @JsonKey(name: 'categories')
      final List<MultiSelectSingleDataEntity>? categories})
      : _categories = categories;

  factory _$MentorProfileDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MentorProfileDataImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'organization')
  final Organization? organization;
  @override
  @JsonKey(name: 'experience')
  final String? experience;
  @override
  @JsonKey(name: 'designation')
  final String? designation;
  @override
  @JsonKey(name: 'emergency_contact')
  final String? emergencyContact;
  @override
  @JsonKey(name: 'address_proof')
  final dynamic addressProof;
  final List<MultiSelectSingleDataEntity>? _categories;
  @override
  @JsonKey(name: 'categories')
  List<MultiSelectSingleDataEntity>? get categories {
    final value = _categories;
    if (value == null) return null;
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'MentorProfileData(id: $id, organization: $organization, experience: $experience, designation: $designation, emergencyContact: $emergencyContact, addressProof: $addressProof, categories: $categories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MentorProfileDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.organization, organization) ||
                other.organization == organization) &&
            (identical(other.experience, experience) ||
                other.experience == experience) &&
            (identical(other.designation, designation) ||
                other.designation == designation) &&
            (identical(other.emergencyContact, emergencyContact) ||
                other.emergencyContact == emergencyContact) &&
            const DeepCollectionEquality()
                .equals(other.addressProof, addressProof) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      organization,
      experience,
      designation,
      emergencyContact,
      const DeepCollectionEquality().hash(addressProof),
      const DeepCollectionEquality().hash(_categories));

  /// Create a copy of MentorProfileData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MentorProfileDataImplCopyWith<_$MentorProfileDataImpl> get copyWith =>
      __$$MentorProfileDataImplCopyWithImpl<_$MentorProfileDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MentorProfileDataImplToJson(
      this,
    );
  }
}

abstract class _MentorProfileData implements MentorProfileData {
  const factory _MentorProfileData(
          {@JsonKey(name: 'id') final int? id,
          @JsonKey(name: 'organization') final Organization? organization,
          @JsonKey(name: 'experience') final String? experience,
          @JsonKey(name: 'designation') final String? designation,
          @JsonKey(name: 'emergency_contact') final String? emergencyContact,
          @JsonKey(name: 'address_proof') final dynamic addressProof,
          @JsonKey(name: 'categories')
          final List<MultiSelectSingleDataEntity>? categories}) =
      _$MentorProfileDataImpl;

  factory _MentorProfileData.fromJson(Map<String, dynamic> json) =
      _$MentorProfileDataImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'organization')
  Organization? get organization;
  @override
  @JsonKey(name: 'experience')
  String? get experience;
  @override
  @JsonKey(name: 'designation')
  String? get designation;
  @override
  @JsonKey(name: 'emergency_contact')
  String? get emergencyContact;
  @override
  @JsonKey(name: 'address_proof')
  dynamic get addressProof;
  @override
  @JsonKey(name: 'categories')
  List<MultiSelectSingleDataEntity>? get categories;

  /// Create a copy of MentorProfileData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MentorProfileDataImplCopyWith<_$MentorProfileDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Organization _$OrganizationFromJson(Map<String, dynamic> json) {
  return _Organization.fromJson(json);
}

/// @nodoc
mixin _$Organization {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'category')
  List<int>? get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'email')
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'phone_number')
  String? get phoneNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo')
  dynamic get logo => throw _privateConstructorUsedError;

  /// Serializes this Organization to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Organization
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizationCopyWith<Organization> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationCopyWith<$Res> {
  factory $OrganizationCopyWith(
          Organization value, $Res Function(Organization) then) =
      _$OrganizationCopyWithImpl<$Res, Organization>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'name') String? name,
      @JsonKey(name: 'category') List<int>? category,
      @JsonKey(name: 'email') String? email,
      @JsonKey(name: 'phone_number') String? phoneNumber,
      @JsonKey(name: 'logo') dynamic logo});
}

/// @nodoc
class _$OrganizationCopyWithImpl<$Res, $Val extends Organization>
    implements $OrganizationCopyWith<$Res> {
  _$OrganizationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Organization
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? category = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? logo = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      logo: freezed == logo
          ? _value.logo
          : logo // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrganizationImplCopyWith<$Res>
    implements $OrganizationCopyWith<$Res> {
  factory _$$OrganizationImplCopyWith(
          _$OrganizationImpl value, $Res Function(_$OrganizationImpl) then) =
      __$$OrganizationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'name') String? name,
      @JsonKey(name: 'category') List<int>? category,
      @JsonKey(name: 'email') String? email,
      @JsonKey(name: 'phone_number') String? phoneNumber,
      @JsonKey(name: 'logo') dynamic logo});
}

/// @nodoc
class __$$OrganizationImplCopyWithImpl<$Res>
    extends _$OrganizationCopyWithImpl<$Res, _$OrganizationImpl>
    implements _$$OrganizationImplCopyWith<$Res> {
  __$$OrganizationImplCopyWithImpl(
      _$OrganizationImpl _value, $Res Function(_$OrganizationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Organization
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? category = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? logo = freezed,
  }) {
    return _then(_$OrganizationImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value._category
          : category // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      logo: freezed == logo
          ? _value.logo
          : logo // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrganizationImpl implements _Organization {
  const _$OrganizationImpl(
      {@JsonKey(name: 'id') this.id,
      @JsonKey(name: 'name') this.name,
      @JsonKey(name: 'category') final List<int>? category,
      @JsonKey(name: 'email') this.email,
      @JsonKey(name: 'phone_number') this.phoneNumber,
      @JsonKey(name: 'logo') this.logo})
      : _category = category;

  factory _$OrganizationImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrganizationImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'name')
  final String? name;
  final List<int>? _category;
  @override
  @JsonKey(name: 'category')
  List<int>? get category {
    final value = _category;
    if (value == null) return null;
    if (_category is EqualUnmodifiableListView) return _category;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'email')
  final String? email;
  @override
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @override
  @JsonKey(name: 'logo')
  final dynamic logo;

  @override
  String toString() {
    return 'Organization(id: $id, name: $name, category: $category, email: $email, phoneNumber: $phoneNumber, logo: $logo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._category, _category) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            const DeepCollectionEquality().equals(other.logo, logo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      const DeepCollectionEquality().hash(_category),
      email,
      phoneNumber,
      const DeepCollectionEquality().hash(logo));

  /// Create a copy of Organization
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationImplCopyWith<_$OrganizationImpl> get copyWith =>
      __$$OrganizationImplCopyWithImpl<_$OrganizationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrganizationImplToJson(
      this,
    );
  }
}

abstract class _Organization implements Organization {
  const factory _Organization(
      {@JsonKey(name: 'id') final int? id,
      @JsonKey(name: 'name') final String? name,
      @JsonKey(name: 'category') final List<int>? category,
      @JsonKey(name: 'email') final String? email,
      @JsonKey(name: 'phone_number') final String? phoneNumber,
      @JsonKey(name: 'logo') final dynamic logo}) = _$OrganizationImpl;

  factory _Organization.fromJson(Map<String, dynamic> json) =
      _$OrganizationImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'category')
  List<int>? get category;
  @override
  @JsonKey(name: 'email')
  String? get email;
  @override
  @JsonKey(name: 'phone_number')
  String? get phoneNumber;
  @override
  @JsonKey(name: 'logo')
  dynamic get logo;

  /// Create a copy of Organization
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationImplCopyWith<_$OrganizationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
