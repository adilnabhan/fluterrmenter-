// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_account_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CreateAccountState {
  SentOtpEntity get sentOtpEntity => throw _privateConstructorUsedError;
  Option<Either<ApiException, LoginSuccessModel>>? get onboardingUser =>
      throw _privateConstructorUsedError;
  Option<Either<ApiException, void>>? get createOrUpdateOnboarding =>
      throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;

  /// Create a copy of CreateAccountState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateAccountStateCopyWith<CreateAccountState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateAccountStateCopyWith<$Res> {
  factory $CreateAccountStateCopyWith(
    CreateAccountState value,
    $Res Function(CreateAccountState) then,
  ) = _$CreateAccountStateCopyWithImpl<$Res, CreateAccountState>;
  @useResult
  $Res call({
    SentOtpEntity sentOtpEntity,
    Option<Either<ApiException, LoginSuccessModel>>? onboardingUser,
    Option<Either<ApiException, void>>? createOrUpdateOnboarding,
    bool isLoading,
  });

  $SentOtpEntityCopyWith<$Res> get sentOtpEntity;
}

/// @nodoc
class _$CreateAccountStateCopyWithImpl<$Res, $Val extends CreateAccountState>
    implements $CreateAccountStateCopyWith<$Res> {
  _$CreateAccountStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateAccountState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sentOtpEntity = null,
    Object? onboardingUser = freezed,
    Object? createOrUpdateOnboarding = freezed,
    Object? isLoading = null,
  }) {
    return _then(
      _value.copyWith(
            sentOtpEntity:
                null == sentOtpEntity
                    ? _value.sentOtpEntity
                    : sentOtpEntity // ignore: cast_nullable_to_non_nullable
                        as SentOtpEntity,
            onboardingUser:
                freezed == onboardingUser
                    ? _value.onboardingUser
                    : onboardingUser // ignore: cast_nullable_to_non_nullable
                        as Option<Either<ApiException, LoginSuccessModel>>?,
            createOrUpdateOnboarding:
                freezed == createOrUpdateOnboarding
                    ? _value.createOrUpdateOnboarding
                    : createOrUpdateOnboarding // ignore: cast_nullable_to_non_nullable
                        as Option<Either<ApiException, void>>?,
            isLoading:
                null == isLoading
                    ? _value.isLoading
                    : isLoading // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of CreateAccountState
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
abstract class _$$CreateAccountStateImplCopyWith<$Res>
    implements $CreateAccountStateCopyWith<$Res> {
  factory _$$CreateAccountStateImplCopyWith(
    _$CreateAccountStateImpl value,
    $Res Function(_$CreateAccountStateImpl) then,
  ) = __$$CreateAccountStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    SentOtpEntity sentOtpEntity,
    Option<Either<ApiException, LoginSuccessModel>>? onboardingUser,
    Option<Either<ApiException, void>>? createOrUpdateOnboarding,
    bool isLoading,
  });

  @override
  $SentOtpEntityCopyWith<$Res> get sentOtpEntity;
}

/// @nodoc
class __$$CreateAccountStateImplCopyWithImpl<$Res>
    extends _$CreateAccountStateCopyWithImpl<$Res, _$CreateAccountStateImpl>
    implements _$$CreateAccountStateImplCopyWith<$Res> {
  __$$CreateAccountStateImplCopyWithImpl(
    _$CreateAccountStateImpl _value,
    $Res Function(_$CreateAccountStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateAccountState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sentOtpEntity = null,
    Object? onboardingUser = freezed,
    Object? createOrUpdateOnboarding = freezed,
    Object? isLoading = null,
  }) {
    return _then(
      _$CreateAccountStateImpl(
        sentOtpEntity:
            null == sentOtpEntity
                ? _value.sentOtpEntity
                : sentOtpEntity // ignore: cast_nullable_to_non_nullable
                    as SentOtpEntity,
        onboardingUser:
            freezed == onboardingUser
                ? _value.onboardingUser
                : onboardingUser // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, LoginSuccessModel>>?,
        createOrUpdateOnboarding:
            freezed == createOrUpdateOnboarding
                ? _value.createOrUpdateOnboarding
                : createOrUpdateOnboarding // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, void>>?,
        isLoading:
            null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc

class _$CreateAccountStateImpl implements _CreateAccountState {
  const _$CreateAccountStateImpl({
    required this.sentOtpEntity,
    this.onboardingUser,
    this.createOrUpdateOnboarding,
    this.isLoading = false,
  });

  @override
  final SentOtpEntity sentOtpEntity;
  @override
  final Option<Either<ApiException, LoginSuccessModel>>? onboardingUser;
  @override
  final Option<Either<ApiException, void>>? createOrUpdateOnboarding;
  @override
  @JsonKey()
  final bool isLoading;

  @override
  String toString() {
    return 'CreateAccountState(sentOtpEntity: $sentOtpEntity, onboardingUser: $onboardingUser, createOrUpdateOnboarding: $createOrUpdateOnboarding, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateAccountStateImpl &&
            (identical(other.sentOtpEntity, sentOtpEntity) ||
                other.sentOtpEntity == sentOtpEntity) &&
            (identical(other.onboardingUser, onboardingUser) ||
                other.onboardingUser == onboardingUser) &&
            (identical(
                  other.createOrUpdateOnboarding,
                  createOrUpdateOnboarding,
                ) ||
                other.createOrUpdateOnboarding == createOrUpdateOnboarding) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    sentOtpEntity,
    onboardingUser,
    createOrUpdateOnboarding,
    isLoading,
  );

  /// Create a copy of CreateAccountState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateAccountStateImplCopyWith<_$CreateAccountStateImpl> get copyWith =>
      __$$CreateAccountStateImplCopyWithImpl<_$CreateAccountStateImpl>(
        this,
        _$identity,
      );
}

abstract class _CreateAccountState implements CreateAccountState {
  const factory _CreateAccountState({
    required final SentOtpEntity sentOtpEntity,
    final Option<Either<ApiException, LoginSuccessModel>>? onboardingUser,
    final Option<Either<ApiException, void>>? createOrUpdateOnboarding,
    final bool isLoading,
  }) = _$CreateAccountStateImpl;

  @override
  SentOtpEntity get sentOtpEntity;
  @override
  Option<Either<ApiException, LoginSuccessModel>>? get onboardingUser;
  @override
  Option<Either<ApiException, void>>? get createOrUpdateOnboarding;
  @override
  bool get isLoading;

  /// Create a copy of CreateAccountState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateAccountStateImplCopyWith<_$CreateAccountStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
