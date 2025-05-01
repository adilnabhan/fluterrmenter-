// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'logout_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LogoutEntity _$LogoutEntityFromJson(Map<String, dynamic> json) {
  return _LogoutEntity.fromJson(json);
}

/// @nodoc
mixin _$LogoutEntity {
  @JsonKey(name: 'message')
  String? get message => throw _privateConstructorUsedError;

  /// Serializes this LogoutEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LogoutEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LogoutEntityCopyWith<LogoutEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogoutEntityCopyWith<$Res> {
  factory $LogoutEntityCopyWith(
          LogoutEntity value, $Res Function(LogoutEntity) then) =
      _$LogoutEntityCopyWithImpl<$Res, LogoutEntity>;
  @useResult
  $Res call({@JsonKey(name: 'message') String? message});
}

/// @nodoc
class _$LogoutEntityCopyWithImpl<$Res, $Val extends LogoutEntity>
    implements $LogoutEntityCopyWith<$Res> {
  _$LogoutEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LogoutEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LogoutEntityImplCopyWith<$Res>
    implements $LogoutEntityCopyWith<$Res> {
  factory _$$LogoutEntityImplCopyWith(
          _$LogoutEntityImpl value, $Res Function(_$LogoutEntityImpl) then) =
      __$$LogoutEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'message') String? message});
}

/// @nodoc
class __$$LogoutEntityImplCopyWithImpl<$Res>
    extends _$LogoutEntityCopyWithImpl<$Res, _$LogoutEntityImpl>
    implements _$$LogoutEntityImplCopyWith<$Res> {
  __$$LogoutEntityImplCopyWithImpl(
      _$LogoutEntityImpl _value, $Res Function(_$LogoutEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of LogoutEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_$LogoutEntityImpl(
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LogoutEntityImpl implements _LogoutEntity {
  const _$LogoutEntityImpl({@JsonKey(name: 'message') this.message});

  factory _$LogoutEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$LogoutEntityImplFromJson(json);

  @override
  @JsonKey(name: 'message')
  final String? message;

  @override
  String toString() {
    return 'LogoutEntity(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogoutEntityImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of LogoutEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LogoutEntityImplCopyWith<_$LogoutEntityImpl> get copyWith =>
      __$$LogoutEntityImplCopyWithImpl<_$LogoutEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LogoutEntityImplToJson(
      this,
    );
  }
}

abstract class _LogoutEntity implements LogoutEntity {
  const factory _LogoutEntity(
      {@JsonKey(name: 'message') final String? message}) = _$LogoutEntityImpl;

  factory _LogoutEntity.fromJson(Map<String, dynamic> json) =
      _$LogoutEntityImpl.fromJson;

  @override
  @JsonKey(name: 'message')
  String? get message;

  /// Create a copy of LogoutEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LogoutEntityImplCopyWith<_$LogoutEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
