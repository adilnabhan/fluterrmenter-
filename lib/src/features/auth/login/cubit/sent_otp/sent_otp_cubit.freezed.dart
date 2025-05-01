// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sent_otp_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SentOtpState {
  Option<Either<ApiException, SentOtpEntity>>? get sentOtp =>
      throw _privateConstructorUsedError;
  Option<Either<ApiException, void>>? get googleSignIn =>
      throw _privateConstructorUsedError;

  /// Create a copy of SentOtpState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SentOtpStateCopyWith<SentOtpState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SentOtpStateCopyWith<$Res> {
  factory $SentOtpStateCopyWith(
          SentOtpState value, $Res Function(SentOtpState) then) =
      _$SentOtpStateCopyWithImpl<$Res, SentOtpState>;
  @useResult
  $Res call(
      {Option<Either<ApiException, SentOtpEntity>>? sentOtp,
      Option<Either<ApiException, void>>? googleSignIn});
}

/// @nodoc
class _$SentOtpStateCopyWithImpl<$Res, $Val extends SentOtpState>
    implements $SentOtpStateCopyWith<$Res> {
  _$SentOtpStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SentOtpState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sentOtp = freezed,
    Object? googleSignIn = freezed,
  }) {
    return _then(_value.copyWith(
      sentOtp: freezed == sentOtp
          ? _value.sentOtp
          : sentOtp // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, SentOtpEntity>>?,
      googleSignIn: freezed == googleSignIn
          ? _value.googleSignIn
          : googleSignIn // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, void>>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SentOtpStateImplCopyWith<$Res>
    implements $SentOtpStateCopyWith<$Res> {
  factory _$$SentOtpStateImplCopyWith(
          _$SentOtpStateImpl value, $Res Function(_$SentOtpStateImpl) then) =
      __$$SentOtpStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Option<Either<ApiException, SentOtpEntity>>? sentOtp,
      Option<Either<ApiException, void>>? googleSignIn});
}

/// @nodoc
class __$$SentOtpStateImplCopyWithImpl<$Res>
    extends _$SentOtpStateCopyWithImpl<$Res, _$SentOtpStateImpl>
    implements _$$SentOtpStateImplCopyWith<$Res> {
  __$$SentOtpStateImplCopyWithImpl(
      _$SentOtpStateImpl _value, $Res Function(_$SentOtpStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SentOtpState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sentOtp = freezed,
    Object? googleSignIn = freezed,
  }) {
    return _then(_$SentOtpStateImpl(
      sentOtp: freezed == sentOtp
          ? _value.sentOtp
          : sentOtp // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, SentOtpEntity>>?,
      googleSignIn: freezed == googleSignIn
          ? _value.googleSignIn
          : googleSignIn // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, void>>?,
    ));
  }
}

/// @nodoc

class _$SentOtpStateImpl implements _SentOtpState {
  const _$SentOtpStateImpl({this.sentOtp, this.googleSignIn});

  @override
  final Option<Either<ApiException, SentOtpEntity>>? sentOtp;
  @override
  final Option<Either<ApiException, void>>? googleSignIn;

  @override
  String toString() {
    return 'SentOtpState(sentOtp: $sentOtp, googleSignIn: $googleSignIn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SentOtpStateImpl &&
            (identical(other.sentOtp, sentOtp) || other.sentOtp == sentOtp) &&
            (identical(other.googleSignIn, googleSignIn) ||
                other.googleSignIn == googleSignIn));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sentOtp, googleSignIn);

  /// Create a copy of SentOtpState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SentOtpStateImplCopyWith<_$SentOtpStateImpl> get copyWith =>
      __$$SentOtpStateImplCopyWithImpl<_$SentOtpStateImpl>(this, _$identity);
}

abstract class _SentOtpState implements SentOtpState {
  const factory _SentOtpState(
          {final Option<Either<ApiException, SentOtpEntity>>? sentOtp,
          final Option<Either<ApiException, void>>? googleSignIn}) =
      _$SentOtpStateImpl;

  @override
  Option<Either<ApiException, SentOtpEntity>>? get sentOtp;
  @override
  Option<Either<ApiException, void>>? get googleSignIn;

  /// Create a copy of SentOtpState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SentOtpStateImplCopyWith<_$SentOtpStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
