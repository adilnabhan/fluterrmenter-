// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_list_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OrganizationsListEntity _$OrganizationsListEntityFromJson(
    Map<String, dynamic> json) {
  return _OrganizationsListEntity.fromJson(json);
}

/// @nodoc
mixin _$OrganizationsListEntity {
  bool? get success => throw _privateConstructorUsedError;
  List<SingleOrganizationEntity>? get result =>
      throw _privateConstructorUsedError;

  /// Serializes this OrganizationsListEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrganizationsListEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizationsListEntityCopyWith<OrganizationsListEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationsListEntityCopyWith<$Res> {
  factory $OrganizationsListEntityCopyWith(OrganizationsListEntity value,
          $Res Function(OrganizationsListEntity) then) =
      _$OrganizationsListEntityCopyWithImpl<$Res, OrganizationsListEntity>;
  @useResult
  $Res call({bool? success, List<SingleOrganizationEntity>? result});
}

/// @nodoc
class _$OrganizationsListEntityCopyWithImpl<$Res,
        $Val extends OrganizationsListEntity>
    implements $OrganizationsListEntityCopyWith<$Res> {
  _$OrganizationsListEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrganizationsListEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? result = freezed,
  }) {
    return _then(_value.copyWith(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as List<SingleOrganizationEntity>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrganizationsListEntityImplCopyWith<$Res>
    implements $OrganizationsListEntityCopyWith<$Res> {
  factory _$$OrganizationsListEntityImplCopyWith(
          _$OrganizationsListEntityImpl value,
          $Res Function(_$OrganizationsListEntityImpl) then) =
      __$$OrganizationsListEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? success, List<SingleOrganizationEntity>? result});
}

/// @nodoc
class __$$OrganizationsListEntityImplCopyWithImpl<$Res>
    extends _$OrganizationsListEntityCopyWithImpl<$Res,
        _$OrganizationsListEntityImpl>
    implements _$$OrganizationsListEntityImplCopyWith<$Res> {
  __$$OrganizationsListEntityImplCopyWithImpl(
      _$OrganizationsListEntityImpl _value,
      $Res Function(_$OrganizationsListEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrganizationsListEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? result = freezed,
  }) {
    return _then(_$OrganizationsListEntityImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      result: freezed == result
          ? _value._result
          : result // ignore: cast_nullable_to_non_nullable
              as List<SingleOrganizationEntity>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrganizationsListEntityImpl implements _OrganizationsListEntity {
  const _$OrganizationsListEntityImpl(
      {this.success, final List<SingleOrganizationEntity>? result})
      : _result = result;

  factory _$OrganizationsListEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrganizationsListEntityImplFromJson(json);

  @override
  final bool? success;
  final List<SingleOrganizationEntity>? _result;
  @override
  List<SingleOrganizationEntity>? get result {
    final value = _result;
    if (value == null) return null;
    if (_result is EqualUnmodifiableListView) return _result;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'OrganizationsListEntity(success: $success, result: $result)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizationsListEntityImpl &&
            (identical(other.success, success) || other.success == success) &&
            const DeepCollectionEquality().equals(other._result, _result));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, success, const DeepCollectionEquality().hash(_result));

  /// Create a copy of OrganizationsListEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationsListEntityImplCopyWith<_$OrganizationsListEntityImpl>
      get copyWith => __$$OrganizationsListEntityImplCopyWithImpl<
          _$OrganizationsListEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrganizationsListEntityImplToJson(
      this,
    );
  }
}

abstract class _OrganizationsListEntity implements OrganizationsListEntity {
  const factory _OrganizationsListEntity(
          {final bool? success, final List<SingleOrganizationEntity>? result}) =
      _$OrganizationsListEntityImpl;

  factory _OrganizationsListEntity.fromJson(Map<String, dynamic> json) =
      _$OrganizationsListEntityImpl.fromJson;

  @override
  bool? get success;
  @override
  List<SingleOrganizationEntity>? get result;

  /// Create a copy of OrganizationsListEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationsListEntityImplCopyWith<_$OrganizationsListEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SingleOrganizationEntity _$SingleOrganizationEntityFromJson(
    Map<String, dynamic> json) {
  return _SingleOrganizationEntity.fromJson(json);
}

/// @nodoc
mixin _$SingleOrganizationEntity {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  List<int>? get category => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get logo => throw _privateConstructorUsedError;

  /// Serializes this SingleOrganizationEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SingleOrganizationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SingleOrganizationEntityCopyWith<SingleOrganizationEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SingleOrganizationEntityCopyWith<$Res> {
  factory $SingleOrganizationEntityCopyWith(SingleOrganizationEntity value,
          $Res Function(SingleOrganizationEntity) then) =
      _$SingleOrganizationEntityCopyWithImpl<$Res, SingleOrganizationEntity>;
  @useResult
  $Res call(
      {int? id,
      String? name,
      List<int>? category,
      String? email,
      String? phoneNumber,
      String? logo});
}

/// @nodoc
class _$SingleOrganizationEntityCopyWithImpl<$Res,
        $Val extends SingleOrganizationEntity>
    implements $SingleOrganizationEntityCopyWith<$Res> {
  _$SingleOrganizationEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SingleOrganizationEntity
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
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SingleOrganizationEntityImplCopyWith<$Res>
    implements $SingleOrganizationEntityCopyWith<$Res> {
  factory _$$SingleOrganizationEntityImplCopyWith(
          _$SingleOrganizationEntityImpl value,
          $Res Function(_$SingleOrganizationEntityImpl) then) =
      __$$SingleOrganizationEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? name,
      List<int>? category,
      String? email,
      String? phoneNumber,
      String? logo});
}

/// @nodoc
class __$$SingleOrganizationEntityImplCopyWithImpl<$Res>
    extends _$SingleOrganizationEntityCopyWithImpl<$Res,
        _$SingleOrganizationEntityImpl>
    implements _$$SingleOrganizationEntityImplCopyWith<$Res> {
  __$$SingleOrganizationEntityImplCopyWithImpl(
      _$SingleOrganizationEntityImpl _value,
      $Res Function(_$SingleOrganizationEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of SingleOrganizationEntity
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
    return _then(_$SingleOrganizationEntityImpl(
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
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SingleOrganizationEntityImpl implements _SingleOrganizationEntity {
  const _$SingleOrganizationEntityImpl(
      {this.id,
      this.name,
      final List<int>? category,
      this.email,
      this.phoneNumber,
      this.logo})
      : _category = category;

  factory _$SingleOrganizationEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$SingleOrganizationEntityImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;
  final List<int>? _category;
  @override
  List<int>? get category {
    final value = _category;
    if (value == null) return null;
    if (_category is EqualUnmodifiableListView) return _category;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? email;
  @override
  final String? phoneNumber;
  @override
  final String? logo;

  @override
  String toString() {
    return 'SingleOrganizationEntity(id: $id, name: $name, category: $category, email: $email, phoneNumber: $phoneNumber, logo: $logo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SingleOrganizationEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._category, _category) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.logo, logo) || other.logo == logo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name,
      const DeepCollectionEquality().hash(_category), email, phoneNumber, logo);

  /// Create a copy of SingleOrganizationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SingleOrganizationEntityImplCopyWith<_$SingleOrganizationEntityImpl>
      get copyWith => __$$SingleOrganizationEntityImplCopyWithImpl<
          _$SingleOrganizationEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SingleOrganizationEntityImplToJson(
      this,
    );
  }
}

abstract class _SingleOrganizationEntity implements SingleOrganizationEntity {
  const factory _SingleOrganizationEntity(
      {final int? id,
      final String? name,
      final List<int>? category,
      final String? email,
      final String? phoneNumber,
      final String? logo}) = _$SingleOrganizationEntityImpl;

  factory _SingleOrganizationEntity.fromJson(Map<String, dynamic> json) =
      _$SingleOrganizationEntityImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;
  @override
  List<int>? get category;
  @override
  String? get email;
  @override
  String? get phoneNumber;
  @override
  String? get logo;

  /// Create a copy of SingleOrganizationEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SingleOrganizationEntityImplCopyWith<_$SingleOrganizationEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
