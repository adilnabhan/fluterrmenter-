// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verify_otp_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$VerifyOtpState {
  SentOtpEntity get sentOtpEntity => throw _privateConstructorUsedError;
  Option<Either<ApiException, LoginSuccessModel?>>? get verifyOtp =>
      throw _privateConstructorUsedError;
  Option<Either<ApiException, SentOtpEntity>>? get resentOtp =>
      throw _privateConstructorUsedError;
  int get resentOtpReminigTime => throw _privateConstructorUsedError;

  /// Create a copy of VerifyOtpState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerifyOtpStateCopyWith<VerifyOtpState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerifyOtpStateCopyWith<$Res> {
  factory $VerifyOtpStateCopyWith(
    VerifyOtpState value,
    $Res Function(VerifyOtpState) then,
  ) = _$VerifyOtpStateCopyWithImpl<$Res, VerifyOtpState>;
  @useResult
  $Res call({
    SentOtpEntity sentOtpEntity,
    Option<Either<ApiException, LoginSuccessModel?>>? verifyOtp,
    Option<Either<ApiException, SentOtpEntity>>? resentOtp,
    int resentOtpReminigTime,
  });

  $SentOtpEntityCopyWith<$Res> get sentOtpEntity;
}

/// @nodoc
class _$VerifyOtpStateCopyWithImpl<$Res, $Val extends VerifyOtpState>
    implements $VerifyOtpStateCopyWith<$Res> {
  _$VerifyOtpStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VerifyOtpState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sentOtpEntity = null,
    Object? verifyOtp = freezed,
    Object? resentOtp = freezed,
    Object? resentOtpReminigTime = null,
  }) {
    return _then(
      _value.copyWith(
            sentOtpEntity:
                null == sentOtpEntity
                    ? _value.sentOtpEntity
                    : sentOtpEntity // ignore: cast_nullable_to_non_nullable
                        as SentOtpEntity,
            verifyOtp:
                freezed == verifyOtp
                    ? _value.verifyOtp
                    : verifyOtp // ignore: cast_nullable_to_non_nullable
                        as Option<Either<ApiException, LoginSuccessModel?>>?,
            resentOtp:
                freezed == resentOtp
                    ? _value.resentOtp
                    : resentOtp // ignore: cast_nullable_to_non_nullable
                        as Option<Either<ApiException, SentOtpEntity>>?,
            resentOtpReminigTime:
                null == resentOtpReminigTime
                    ? _value.resentOtpReminigTime
                    : resentOtpReminigTime // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }

  /// Create a copy of VerifyOtpState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SentOtpEntityCopyWith<$Res> get sentOtpEntity {
    return $SentOtpEntityCopyWith<$Res>(_value.sentOtpEntity, (value) {
      return _then(_value.copyWith(sentOtpEntity: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VerifyOtpStateImplCopyWith<$Res>
    implements $VerifyOtpStateCopyWith<$Res> {
  factory _$$VerifyOtpStateImplCopyWith(
    _$VerifyOtpStateImpl value,
    $Res Function(_$VerifyOtpStateImpl) then,
  ) = __$$VerifyOtpStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    SentOtpEntity sentOtpEntity,
    Option<Either<ApiException, LoginSuccessModel?>>? verifyOtp,
    Option<Either<ApiException, SentOtpEntity>>? resentOtp,
    int resentOtpReminigTime,
  });

  @override
  $SentOtpEntityCopyWith<$Res> get sentOtpEntity;
}

/// @nodoc
class __$$VerifyOtpStateImplCopyWithImpl<$Res>
    extends _$VerifyOtpStateCopyWithImpl<$Res, _$VerifyOtpStateImpl>
    implements _$$VerifyOtpStateImplCopyWith<$Res> {
  __$$VerifyOtpStateImplCopyWithImpl(
    _$VerifyOtpStateImpl _value,
    $Res Function(_$VerifyOtpStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VerifyOtpState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sentOtpEntity = null,
    Object? verifyOtp = freezed,
    Object? resentOtp = freezed,
    Object? resentOtpReminigTime = null,
  }) {
    return _then(
      _$VerifyOtpStateImpl(
        sentOtpEntity:
            null == sentOtpEntity
                ? _value.sentOtpEntity
                : sentOtpEntity // ignore: cast_nullable_to_non_nullable
                    as SentOtpEntity,
        verifyOtp:
            freezed == verifyOtp
                ? _value.verifyOtp
                : verifyOtp // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, LoginSuccessModel?>>?,
        resentOtp:
            freezed == resentOtp
                ? _value.resentOtp
                : resentOtp // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, SentOtpEntity>>?,
        resentOtpReminigTime:
            null == resentOtpReminigTime
                ? _value.resentOtpReminigTime
                : resentOtpReminigTime // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc

class _$VerifyOtpStateImpl implements _VerifyOtpState {
  const _$VerifyOtpStateImpl({
    required this.sentOtpEntity,
    this.verifyOtp,
    this.resentOtp,
    this.resentOtpReminigTime = 0,
  });

  @override
  final SentOtpEntity sentOtpEntity;
  @override
  final Option<Either<ApiException, LoginSuccessModel?>>? verifyOtp;
  @override
  final Option<Either<ApiException, SentOtpEntity>>? resentOtp;
  @override
  @JsonKey()
  final int resentOtpReminigTime;

  @override
  String toString() {
    return 'VerifyOtpState(sentOtpEntity: $sentOtpEntity, verifyOtp: $verifyOtp, resentOtp: $resentOtp, resentOtpReminigTime: $resentOtpReminigTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerifyOtpStateImpl &&
            (identical(other.sentOtpEntity, sentOtpEntity) ||
                other.sentOtpEntity == sentOtpEntity) &&
            (identical(other.verifyOtp, verifyOtp) ||
                other.verifyOtp == verifyOtp) &&
            (identical(other.resentOtp, resentOtp) ||
                other.resentOtp == resentOtp) &&
            (identical(other.resentOtpReminigTime, resentOtpReminigTime) ||
                other.resentOtpReminigTime == resentOtpReminigTime));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    sentOtpEntity,
    verifyOtp,
    resentOtp,
    resentOtpReminigTime,
  );

  /// Create a copy of VerifyOtpState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerifyOtpStateImplCopyWith<_$VerifyOtpStateImpl> get copyWith =>
      __$$VerifyOtpStateImplCopyWithImpl<_$VerifyOtpStateImpl>(
        this,
        _$identity,
      );
}

abstract class _VerifyOtpState implements VerifyOtpState {
  const factory _VerifyOtpState({
    required final SentOtpEntity sentOtpEntity,
    final Option<Either<ApiException, LoginSuccessModel?>>? verifyOtp,
    final Option<Either<ApiException, SentOtpEntity>>? resentOtp,
    final int resentOtpReminigTime,
  }) = _$VerifyOtpStateImpl;

  @override
  SentOtpEntity get sentOtpEntity;
  @override
  Option<Either<ApiException, LoginSuccessModel?>>? get verifyOtp;
  @override
  Option<Either<ApiException, SentOtpEntity>>? get resentOtp;
  @override
  int get resentOtpReminigTime;

  /// Create a copy of VerifyOtpState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerifyOtpStateImplCopyWith<_$VerifyOtpStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
