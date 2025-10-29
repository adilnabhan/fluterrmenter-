// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_list_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrganizationsListModel _$OrganizationsListModelFromJson(
  Map<String, dynamic> json,
) {
  return _OrganizationsListModel.fromJson(json);
}

/// @nodoc
mixin _$OrganizationsListModel {
  bool? get success => throw _privateConstructorUsedError;
  List<SingleOrganizationModel>? get result =>
      throw _privateConstructorUsedError;

  /// Serializes this OrganizationsListModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrganizationsListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizationsListModelCopyWith<OrganizationsListModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationsListModelCopyWith<$Res> {
  factory $OrganizationsListModelCopyWith(
    OrganizationsListModel value,
    $Res Function(OrganizationsListModel) then,
  ) = _$OrganizationsListModelCopyWithImpl<$Res, OrganizationsListModel>;
  @useResult
  $Res call({bool? success, List<SingleOrganizationModel>? result});
}

/// @nodoc
class _$OrganizationsListModelCopyWithImpl<
  $Res,
  $Val extends OrganizationsListModel
>
    implements $OrganizationsListModelCopyWith<$Res> {
  _$OrganizationsListModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrganizationsListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? success = freezed, Object? result = freezed}) {
    return _then(
      _value.copyWith(
            success:
                freezed == success
                    ? _value.success
                    : success // ignore: cast_nullable_to_non_nullable
                        as bool?,
            result:
                freezed == result
                    ? _value.result
                    : result // ignore: cast_nullable_to_non_nullable
                        as List<SingleOrganizationModel>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrganizationsListModelImplCopyWith<$Res>
    implements $OrganizationsListModelCopyWith<$Res> {
  factory _$$OrganizationsListModelImplCopyWith(
    _$OrganizationsListModelImpl value,
    $Res Function(_$OrganizationsListModelImpl) then,
  ) = __$$OrganizationsListModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? success, List<SingleOrganizationModel>? result});
}

/// @nodoc
class __$$OrganizationsListModelImplCopyWithImpl<$Res>
    extends
        _$OrganizationsListModelCopyWithImpl<$Res, _$OrganizationsListModelImpl>
    implements _$$OrganizationsListModelImplCopyWith<$Res> {
  __$$OrganizationsListModelImplCopyWithImpl(
    _$OrganizationsListModelImpl _value,
    $Res Function(_$OrganizationsListModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrganizationsListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? success = freezed, Object? result = freezed}) {
    return _then(
      _$OrganizationsListModelImpl(
        success:
            freezed == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                    as bool?,
        result:
            freezed == result
                ? _value._result
                : result // ignore: cast_nullable_to_non_nullable
                    as List<SingleOrganizationModel>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrganizationsListModelImpl implements _OrganizationsListModel {
  const _$OrganizationsListModelImpl({
    this.success,
    final List<SingleOrganizationModel>? result,
  }) : _result = result;

  factory _$OrganizationsListModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrganizationsListModelImplFromJson(json);

  @override
  final bool? success;
  final List<SingleOrganizationModel>? _result;
  @override
  List<SingleOrganizationModel>? get result {
    final value = _result;
    if (value == null) return null;
    if (_result is EqualUnmodifiableListView) return _result;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'OrganizationsListModel(success: $success, result: $result)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizationsListModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            const DeepCollectionEquality().equals(other._result, _result));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    const DeepCollectionEquality().hash(_result),
  );

  /// Create a copy of OrganizationsListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationsListModelImplCopyWith<_$OrganizationsListModelImpl>
  get copyWith =>
      __$$OrganizationsListModelImplCopyWithImpl<_$OrganizationsListModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrganizationsListModelImplToJson(this);
  }
}

abstract class _OrganizationsListModel implements OrganizationsListModel {
  const factory _OrganizationsListModel({
    final bool? success,
    final List<SingleOrganizationModel>? result,
  }) = _$OrganizationsListModelImpl;

  factory _OrganizationsListModel.fromJson(Map<String, dynamic> json) =
      _$OrganizationsListModelImpl.fromJson;

  @override
  bool? get success;
  @override
  List<SingleOrganizationModel>? get result;

  /// Create a copy of OrganizationsListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationsListModelImplCopyWith<_$OrganizationsListModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SingleOrganizationModel _$SingleOrganizationModelFromJson(
  Map<String, dynamic> json,
) {
  return _SingleOrganizationModel.fromJson(json);
}

/// @nodoc
mixin _$SingleOrganizationModel {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  List<int>? get category => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get logo => throw _privateConstructorUsedError;

  /// Serializes this SingleOrganizationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SingleOrganizationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SingleOrganizationModelCopyWith<SingleOrganizationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SingleOrganizationModelCopyWith<$Res> {
  factory $SingleOrganizationModelCopyWith(
    SingleOrganizationModel value,
    $Res Function(SingleOrganizationModel) then,
  ) = _$SingleOrganizationModelCopyWithImpl<$Res, SingleOrganizationModel>;
  @useResult
  $Res call({
    int? id,
    String? name,
    List<int>? category,
    String? email,
    String? phoneNumber,
    String? logo,
  });
}

/// @nodoc
class _$SingleOrganizationModelCopyWithImpl<
  $Res,
  $Val extends SingleOrganizationModel
>
    implements $SingleOrganizationModelCopyWith<$Res> {
  _$SingleOrganizationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SingleOrganizationModel
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
            category:
                freezed == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as List<int>?,
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            phoneNumber:
                freezed == phoneNumber
                    ? _value.phoneNumber
                    : phoneNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            logo:
                freezed == logo
                    ? _value.logo
                    : logo // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SingleOrganizationModelImplCopyWith<$Res>
    implements $SingleOrganizationModelCopyWith<$Res> {
  factory _$$SingleOrganizationModelImplCopyWith(
    _$SingleOrganizationModelImpl value,
    $Res Function(_$SingleOrganizationModelImpl) then,
  ) = __$$SingleOrganizationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String? name,
    List<int>? category,
    String? email,
    String? phoneNumber,
    String? logo,
  });
}

/// @nodoc
class __$$SingleOrganizationModelImplCopyWithImpl<$Res>
    extends
        _$SingleOrganizationModelCopyWithImpl<
          $Res,
          _$SingleOrganizationModelImpl
        >
    implements _$$SingleOrganizationModelImplCopyWith<$Res> {
  __$$SingleOrganizationModelImplCopyWithImpl(
    _$SingleOrganizationModelImpl _value,
    $Res Function(_$SingleOrganizationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SingleOrganizationModel
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
    return _then(
      _$SingleOrganizationModelImpl(
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
        category:
            freezed == category
                ? _value._category
                : category // ignore: cast_nullable_to_non_nullable
                    as List<int>?,
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        phoneNumber:
            freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        logo:
            freezed == logo
                ? _value.logo
                : logo // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SingleOrganizationModelImpl implements _SingleOrganizationModel {
  const _$SingleOrganizationModelImpl({
    this.id,
    this.name,
    final List<int>? category,
    this.email,
    this.phoneNumber,
    this.logo,
  }) : _category = category;

  factory _$SingleOrganizationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SingleOrganizationModelImplFromJson(json);

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
    return 'SingleOrganizationModel(id: $id, name: $name, category: $category, email: $email, phoneNumber: $phoneNumber, logo: $logo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SingleOrganizationModelImpl &&
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
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_category),
    email,
    phoneNumber,
    logo,
  );

  /// Create a copy of SingleOrganizationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SingleOrganizationModelImplCopyWith<_$SingleOrganizationModelImpl>
  get copyWith => __$$SingleOrganizationModelImplCopyWithImpl<
    _$SingleOrganizationModelImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SingleOrganizationModelImplToJson(this);
  }
}

abstract class _SingleOrganizationModel implements SingleOrganizationModel {
  const factory _SingleOrganizationModel({
    final int? id,
    final String? name,
    final List<int>? category,
    final String? email,
    final String? phoneNumber,
    final String? logo,
  }) = _$SingleOrganizationModelImpl;

  factory _SingleOrganizationModel.fromJson(Map<String, dynamic> json) =
      _$SingleOrganizationModelImpl.fromJson;

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

  /// Create a copy of SingleOrganizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SingleOrganizationModelImplCopyWith<_$SingleOrganizationModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
