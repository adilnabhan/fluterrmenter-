// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'multi_select_data_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MultiSelectDataEntity _$MultiSelectDataEntityFromJson(
  Map<String, dynamic> json,
) {
  return _MultiSelectDataEntity.fromJson(json);
}

/// @nodoc
mixin _$MultiSelectDataEntity {
  @JsonKey(name: 'results')
  List<MultiSelectSingleDataEntity>? get results =>
      throw _privateConstructorUsedError;

  /// Serializes this MultiSelectDataEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MultiSelectDataEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MultiSelectDataEntityCopyWith<MultiSelectDataEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MultiSelectDataEntityCopyWith<$Res> {
  factory $MultiSelectDataEntityCopyWith(
    MultiSelectDataEntity value,
    $Res Function(MultiSelectDataEntity) then,
  ) = _$MultiSelectDataEntityCopyWithImpl<$Res, MultiSelectDataEntity>;
  @useResult
  $Res call({
    @JsonKey(name: 'results') List<MultiSelectSingleDataEntity>? results,
  });
}

/// @nodoc
class _$MultiSelectDataEntityCopyWithImpl<
  $Res,
  $Val extends MultiSelectDataEntity
>
    implements $MultiSelectDataEntityCopyWith<$Res> {
  _$MultiSelectDataEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MultiSelectDataEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? results = freezed}) {
    return _then(
      _value.copyWith(
            results:
                freezed == results
                    ? _value.results
                    : results // ignore: cast_nullable_to_non_nullable
                        as List<MultiSelectSingleDataEntity>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MultiSelectDataEntityImplCopyWith<$Res>
    implements $MultiSelectDataEntityCopyWith<$Res> {
  factory _$$MultiSelectDataEntityImplCopyWith(
    _$MultiSelectDataEntityImpl value,
    $Res Function(_$MultiSelectDataEntityImpl) then,
  ) = __$$MultiSelectDataEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'results') List<MultiSelectSingleDataEntity>? results,
  });
}

/// @nodoc
class __$$MultiSelectDataEntityImplCopyWithImpl<$Res>
    extends
        _$MultiSelectDataEntityCopyWithImpl<$Res, _$MultiSelectDataEntityImpl>
    implements _$$MultiSelectDataEntityImplCopyWith<$Res> {
  __$$MultiSelectDataEntityImplCopyWithImpl(
    _$MultiSelectDataEntityImpl _value,
    $Res Function(_$MultiSelectDataEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MultiSelectDataEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? results = freezed}) {
    return _then(
      _$MultiSelectDataEntityImpl(
        results:
            freezed == results
                ? _value._results
                : results // ignore: cast_nullable_to_non_nullable
                    as List<MultiSelectSingleDataEntity>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MultiSelectDataEntityImpl implements _MultiSelectDataEntity {
  const _$MultiSelectDataEntityImpl({
    @JsonKey(name: 'results') final List<MultiSelectSingleDataEntity>? results,
  }) : _results = results;

  factory _$MultiSelectDataEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$MultiSelectDataEntityImplFromJson(json);

  final List<MultiSelectSingleDataEntity>? _results;
  @override
  @JsonKey(name: 'results')
  List<MultiSelectSingleDataEntity>? get results {
    final value = _results;
    if (value == null) return null;
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'MultiSelectDataEntity(results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MultiSelectDataEntityImpl &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_results));

  /// Create a copy of MultiSelectDataEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MultiSelectDataEntityImplCopyWith<_$MultiSelectDataEntityImpl>
  get copyWith =>
      __$$MultiSelectDataEntityImplCopyWithImpl<_$MultiSelectDataEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MultiSelectDataEntityImplToJson(this);
  }
}

abstract class _MultiSelectDataEntity implements MultiSelectDataEntity {
  const factory _MultiSelectDataEntity({
    @JsonKey(name: 'results') final List<MultiSelectSingleDataEntity>? results,
  }) = _$MultiSelectDataEntityImpl;

  factory _MultiSelectDataEntity.fromJson(Map<String, dynamic> json) =
      _$MultiSelectDataEntityImpl.fromJson;

  @override
  @JsonKey(name: 'results')
  List<MultiSelectSingleDataEntity>? get results;

  /// Create a copy of MultiSelectDataEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MultiSelectDataEntityImplCopyWith<_$MultiSelectDataEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MultiSelectSingleDataEntity _$MultiSelectSingleDataEntityFromJson(
  Map<String, dynamic> json,
) {
  return _MultiSelectSingleDataEntity.fromJson(json);
}

/// @nodoc
mixin _$MultiSelectSingleDataEntity {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo')
  String? get logo => throw _privateConstructorUsedError;
  @JsonKey(name: 'status_string')
  String? get statusString => throw _privateConstructorUsedError;

  /// Serializes this MultiSelectSingleDataEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MultiSelectSingleDataEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MultiSelectSingleDataEntityCopyWith<MultiSelectSingleDataEntity>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MultiSelectSingleDataEntityCopyWith<$Res> {
  factory $MultiSelectSingleDataEntityCopyWith(
    MultiSelectSingleDataEntity value,
    $Res Function(MultiSelectSingleDataEntity) then,
  ) =
      _$MultiSelectSingleDataEntityCopyWithImpl<
        $Res,
        MultiSelectSingleDataEntity
      >;
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'status_string') String? statusString,
  });
}

/// @nodoc
class _$MultiSelectSingleDataEntityCopyWithImpl<
  $Res,
  $Val extends MultiSelectSingleDataEntity
>
    implements $MultiSelectSingleDataEntityCopyWith<$Res> {
  _$MultiSelectSingleDataEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MultiSelectSingleDataEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? logo = freezed,
    Object? statusString = freezed,
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
            logo:
                freezed == logo
                    ? _value.logo
                    : logo // ignore: cast_nullable_to_non_nullable
                        as String?,
            statusString:
                freezed == statusString
                    ? _value.statusString
                    : statusString // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MultiSelectSingleDataEntityImplCopyWith<$Res>
    implements $MultiSelectSingleDataEntityCopyWith<$Res> {
  factory _$$MultiSelectSingleDataEntityImplCopyWith(
    _$MultiSelectSingleDataEntityImpl value,
    $Res Function(_$MultiSelectSingleDataEntityImpl) then,
  ) = __$$MultiSelectSingleDataEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'status_string') String? statusString,
  });
}

/// @nodoc
class __$$MultiSelectSingleDataEntityImplCopyWithImpl<$Res>
    extends
        _$MultiSelectSingleDataEntityCopyWithImpl<
          $Res,
          _$MultiSelectSingleDataEntityImpl
        >
    implements _$$MultiSelectSingleDataEntityImplCopyWith<$Res> {
  __$$MultiSelectSingleDataEntityImplCopyWithImpl(
    _$MultiSelectSingleDataEntityImpl _value,
    $Res Function(_$MultiSelectSingleDataEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MultiSelectSingleDataEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? logo = freezed,
    Object? statusString = freezed,
  }) {
    return _then(
      _$MultiSelectSingleDataEntityImpl(
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
        logo:
            freezed == logo
                ? _value.logo
                : logo // ignore: cast_nullable_to_non_nullable
                    as String?,
        statusString:
            freezed == statusString
                ? _value.statusString
                : statusString // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MultiSelectSingleDataEntityImpl
    implements _MultiSelectSingleDataEntity {
  const _$MultiSelectSingleDataEntityImpl({
    @JsonKey(name: 'id') this.id,
    @JsonKey(name: 'name') this.name,
    @JsonKey(name: 'logo') this.logo,
    @JsonKey(name: 'status_string') this.statusString,
  });

  factory _$MultiSelectSingleDataEntityImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$MultiSelectSingleDataEntityImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'logo')
  final String? logo;
  @override
  @JsonKey(name: 'status_string')
  final String? statusString;

  @override
  String toString() {
    return 'MultiSelectSingleDataEntity(id: $id, name: $name, logo: $logo, statusString: $statusString)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MultiSelectSingleDataEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.logo, logo) || other.logo == logo) &&
            (identical(other.statusString, statusString) ||
                other.statusString == statusString));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, logo, statusString);

  /// Create a copy of MultiSelectSingleDataEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MultiSelectSingleDataEntityImplCopyWith<_$MultiSelectSingleDataEntityImpl>
  get copyWith => __$$MultiSelectSingleDataEntityImplCopyWithImpl<
    _$MultiSelectSingleDataEntityImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MultiSelectSingleDataEntityImplToJson(this);
  }
}

abstract class _MultiSelectSingleDataEntity
    implements MultiSelectSingleDataEntity {
  const factory _MultiSelectSingleDataEntity({
    @JsonKey(name: 'id') final int? id,
    @JsonKey(name: 'name') final String? name,
    @JsonKey(name: 'logo') final String? logo,
    @JsonKey(name: 'status_string') final String? statusString,
  }) = _$MultiSelectSingleDataEntityImpl;

  factory _MultiSelectSingleDataEntity.fromJson(Map<String, dynamic> json) =
      _$MultiSelectSingleDataEntityImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'logo')
  String? get logo;
  @override
  @JsonKey(name: 'status_string')
  String? get statusString;

  /// Create a copy of MultiSelectSingleDataEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MultiSelectSingleDataEntityImplCopyWith<_$MultiSelectSingleDataEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
