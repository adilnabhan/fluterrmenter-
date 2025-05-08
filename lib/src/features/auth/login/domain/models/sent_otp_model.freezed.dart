// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sent_otp_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SentOtpEntity _$SentOtpEntityFromJson(Map<String, dynamic> json) {
  return _SentOtpEntity.fromJson(json);
}

/// @nodoc
mixin _$SentOtpEntity {
  @JsonKey(name: 'id')
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'mobile_number')
  String? get mobileNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'process')
  String? get process => throw _privateConstructorUsedError;
  @JsonKey(name: 'source')
  String? get source => throw _privateConstructorUsedError;
  @JsonKey(name: 'otp')
  String? get otp => throw _privateConstructorUsedError;

  /// Serializes this SentOtpEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SentOtpEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SentOtpEntityCopyWith<SentOtpEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SentOtpEntityCopyWith<$Res> {
  factory $SentOtpEntityCopyWith(
          SentOtpEntity value, $Res Function(SentOtpEntity) then) =
      _$SentOtpEntityCopyWithImpl<$Res, SentOtpEntity>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String? id,
      @JsonKey(name: 'mobile_number') String? mobileNumber,
      @JsonKey(name: 'process') String? process,
      @JsonKey(name: 'source') String? source,
      @JsonKey(name: 'otp') String? otp});
}

/// @nodoc
class _$SentOtpEntityCopyWithImpl<$Res, $Val extends SentOtpEntity>
    implements $SentOtpEntityCopyWith<$Res> {
  _$SentOtpEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SentOtpEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? mobileNumber = freezed,
    Object? process = freezed,
    Object? source = freezed,
    Object? otp = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      mobileNumber: freezed == mobileNumber
          ? _value.mobileNumber
          : mobileNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      process: freezed == process
          ? _value.process
          : process // ignore: cast_nullable_to_non_nullable
              as String?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      otp: freezed == otp
          ? _value.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SentOtpEntityImplCopyWith<$Res>
    implements $SentOtpEntityCopyWith<$Res> {
  factory _$$SentOtpEntityImplCopyWith(
          _$SentOtpEntityImpl value, $Res Function(_$SentOtpEntityImpl) then) =
      __$$SentOtpEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String? id,
      @JsonKey(name: 'mobile_number') String? mobileNumber,
      @JsonKey(name: 'process') String? process,
      @JsonKey(name: 'source') String? source,
      @JsonKey(name: 'otp') String? otp});
}

/// @nodoc
class __$$SentOtpEntityImplCopyWithImpl<$Res>
    extends _$SentOtpEntityCopyWithImpl<$Res, _$SentOtpEntityImpl>
    implements _$$SentOtpEntityImplCopyWith<$Res> {
  __$$SentOtpEntityImplCopyWithImpl(
      _$SentOtpEntityImpl _value, $Res Function(_$SentOtpEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of SentOtpEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? mobileNumber = freezed,
    Object? process = freezed,
    Object? source = freezed,
    Object? otp = freezed,
  }) {
    return _then(_$SentOtpEntityImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      mobileNumber: freezed == mobileNumber
          ? _value.mobileNumber
          : mobileNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      process: freezed == process
          ? _value.process
          : process // ignore: cast_nullable_to_non_nullable
              as String?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      otp: freezed == otp
          ? _value.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SentOtpEntityImpl implements _SentOtpEntity {
  const _$SentOtpEntityImpl(
      {@JsonKey(name: 'id') this.id,
      @JsonKey(name: 'mobile_number') this.mobileNumber,
      @JsonKey(name: 'process') this.process,
      @JsonKey(name: 'source') this.source,
      @JsonKey(name: 'otp') this.otp});

  factory _$SentOtpEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$SentOtpEntityImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String? id;
  @override
  @JsonKey(name: 'mobile_number')
  final String? mobileNumber;
  @override
  @JsonKey(name: 'process')
  final String? process;
  @override
  @JsonKey(name: 'source')
  final String? source;
  @override
  @JsonKey(name: 'otp')
  final String? otp;

  @override
  String toString() {
    return 'SentOtpEntity(id: $id, mobileNumber: $mobileNumber, process: $process, source: $source, otp: $otp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SentOtpEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mobileNumber, mobileNumber) ||
                other.mobileNumber == mobileNumber) &&
            (identical(other.process, process) || other.process == process) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.otp, otp) || other.otp == otp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, mobileNumber, process, source, otp);

  /// Create a copy of SentOtpEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SentOtpEntityImplCopyWith<_$SentOtpEntityImpl> get copyWith =>
      __$$SentOtpEntityImplCopyWithImpl<_$SentOtpEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SentOtpEntityImplToJson(
      this,
    );
  }
}

abstract class _SentOtpEntity implements SentOtpEntity {
  const factory _SentOtpEntity(
      {@JsonKey(name: 'id') final String? id,
      @JsonKey(name: 'mobile_number') final String? mobileNumber,
      @JsonKey(name: 'process') final String? process,
      @JsonKey(name: 'source') final String? source,
      @JsonKey(name: 'otp') final String? otp}) = _$SentOtpEntityImpl;

  factory _SentOtpEntity.fromJson(Map<String, dynamic> json) =
      _$SentOtpEntityImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String? get id;
  @override
  @JsonKey(name: 'mobile_number')
  String? get mobileNumber;
  @override
  @JsonKey(name: 'process')
  String? get process;
  @override
  @JsonKey(name: 'source')
  String? get source;
  @override
  @JsonKey(name: 'otp')
  String? get otp;

  /// Create a copy of SentOtpEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SentOtpEntityImplCopyWith<_$SentOtpEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
