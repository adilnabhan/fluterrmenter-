// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MembershipState {
  Option<Either<ApiException, ListMembershipPackagesModel>>
  get membershipPackages => throw _privateConstructorUsedError;
  Option<Either<ApiException, BankDetailsModel>> get bankDetails =>
      throw _privateConstructorUsedError;
  Option<Either<ApiException, void>>? get createOrUpdatePackage =>
      throw _privateConstructorUsedError;
  Option<Either<ApiException, void>>? get createOrUpdateBank =>
      throw _privateConstructorUsedError;
  bool get isDeleting => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;

  /// Create a copy of MembershipState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MembershipStateCopyWith<MembershipState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembershipStateCopyWith<$Res> {
  factory $MembershipStateCopyWith(
    MembershipState value,
    $Res Function(MembershipState) then,
  ) = _$MembershipStateCopyWithImpl<$Res, MembershipState>;
  @useResult
  $Res call({
    Option<Either<ApiException, ListMembershipPackagesModel>>
    membershipPackages,
    Option<Either<ApiException, BankDetailsModel>> bankDetails,
    Option<Either<ApiException, void>>? createOrUpdatePackage,
    Option<Either<ApiException, void>>? createOrUpdateBank,
    bool isDeleting,
    bool isLoading,
  });
}

/// @nodoc
class _$MembershipStateCopyWithImpl<$Res, $Val extends MembershipState>
    implements $MembershipStateCopyWith<$Res> {
  _$MembershipStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MembershipState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? membershipPackages = null,
    Object? bankDetails = null,
    Object? createOrUpdatePackage = freezed,
    Object? createOrUpdateBank = freezed,
    Object? isDeleting = null,
    Object? isLoading = null,
  }) {
    return _then(
      _value.copyWith(
            membershipPackages:
                null == membershipPackages
                    ? _value.membershipPackages
                    : membershipPackages // ignore: cast_nullable_to_non_nullable
                        as Option<
                          Either<ApiException, ListMembershipPackagesModel>
                        >,
            bankDetails:
                null == bankDetails
                    ? _value.bankDetails
                    : bankDetails // ignore: cast_nullable_to_non_nullable
                        as Option<Either<ApiException, BankDetailsModel>>,
            createOrUpdatePackage:
                freezed == createOrUpdatePackage
                    ? _value.createOrUpdatePackage
                    : createOrUpdatePackage // ignore: cast_nullable_to_non_nullable
                        as Option<Either<ApiException, void>>?,
            createOrUpdateBank:
                freezed == createOrUpdateBank
                    ? _value.createOrUpdateBank
                    : createOrUpdateBank // ignore: cast_nullable_to_non_nullable
                        as Option<Either<ApiException, void>>?,
            isDeleting:
                null == isDeleting
                    ? _value.isDeleting
                    : isDeleting // ignore: cast_nullable_to_non_nullable
                        as bool,
            isLoading:
                null == isLoading
                    ? _value.isLoading
                    : isLoading // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MembershipStateImplCopyWith<$Res>
    implements $MembershipStateCopyWith<$Res> {
  factory _$$MembershipStateImplCopyWith(
    _$MembershipStateImpl value,
    $Res Function(_$MembershipStateImpl) then,
  ) = __$$MembershipStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Option<Either<ApiException, ListMembershipPackagesModel>>
    membershipPackages,
    Option<Either<ApiException, BankDetailsModel>> bankDetails,
    Option<Either<ApiException, void>>? createOrUpdatePackage,
    Option<Either<ApiException, void>>? createOrUpdateBank,
    bool isDeleting,
    bool isLoading,
  });
}

/// @nodoc
class __$$MembershipStateImplCopyWithImpl<$Res>
    extends _$MembershipStateCopyWithImpl<$Res, _$MembershipStateImpl>
    implements _$$MembershipStateImplCopyWith<$Res> {
  __$$MembershipStateImplCopyWithImpl(
    _$MembershipStateImpl _value,
    $Res Function(_$MembershipStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MembershipState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? membershipPackages = null,
    Object? bankDetails = null,
    Object? createOrUpdatePackage = freezed,
    Object? createOrUpdateBank = freezed,
    Object? isDeleting = null,
    Object? isLoading = null,
  }) {
    return _then(
      _$MembershipStateImpl(
        membershipPackages:
            null == membershipPackages
                ? _value.membershipPackages
                : membershipPackages // ignore: cast_nullable_to_non_nullable
                    as Option<
                      Either<ApiException, ListMembershipPackagesModel>
                    >,
        bankDetails:
            null == bankDetails
                ? _value.bankDetails
                : bankDetails // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, BankDetailsModel>>,
        createOrUpdatePackage:
            freezed == createOrUpdatePackage
                ? _value.createOrUpdatePackage
                : createOrUpdatePackage // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, void>>?,
        createOrUpdateBank:
            freezed == createOrUpdateBank
                ? _value.createOrUpdateBank
                : createOrUpdateBank // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, void>>?,
        isDeleting:
            null == isDeleting
                ? _value.isDeleting
                : isDeleting // ignore: cast_nullable_to_non_nullable
                    as bool,
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

class _$MembershipStateImpl implements _MembershipState {
  const _$MembershipStateImpl({
    this.membershipPackages = const None(),
    this.bankDetails = const None(),
    this.createOrUpdatePackage,
    this.createOrUpdateBank,
    this.isDeleting = false,
    this.isLoading = false,
  });

  @override
  @JsonKey()
  final Option<Either<ApiException, ListMembershipPackagesModel>>
  membershipPackages;
  @override
  @JsonKey()
  final Option<Either<ApiException, BankDetailsModel>> bankDetails;
  @override
  final Option<Either<ApiException, void>>? createOrUpdatePackage;
  @override
  final Option<Either<ApiException, void>>? createOrUpdateBank;
  @override
  @JsonKey()
  final bool isDeleting;
  @override
  @JsonKey()
  final bool isLoading;

  @override
  String toString() {
    return 'MembershipState(membershipPackages: $membershipPackages, bankDetails: $bankDetails, createOrUpdatePackage: $createOrUpdatePackage, createOrUpdateBank: $createOrUpdateBank, isDeleting: $isDeleting, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MembershipStateImpl &&
            (identical(other.membershipPackages, membershipPackages) ||
                other.membershipPackages == membershipPackages) &&
            (identical(other.bankDetails, bankDetails) ||
                other.bankDetails == bankDetails) &&
            (identical(other.createOrUpdatePackage, createOrUpdatePackage) ||
                other.createOrUpdatePackage == createOrUpdatePackage) &&
            (identical(other.createOrUpdateBank, createOrUpdateBank) ||
                other.createOrUpdateBank == createOrUpdateBank) &&
            (identical(other.isDeleting, isDeleting) ||
                other.isDeleting == isDeleting) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    membershipPackages,
    bankDetails,
    createOrUpdatePackage,
    createOrUpdateBank,
    isDeleting,
    isLoading,
  );

  /// Create a copy of MembershipState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MembershipStateImplCopyWith<_$MembershipStateImpl> get copyWith =>
      __$$MembershipStateImplCopyWithImpl<_$MembershipStateImpl>(
        this,
        _$identity,
      );
}

abstract class _MembershipState implements MembershipState {
  const factory _MembershipState({
    final Option<Either<ApiException, ListMembershipPackagesModel>>
    membershipPackages,
    final Option<Either<ApiException, BankDetailsModel>> bankDetails,
    final Option<Either<ApiException, void>>? createOrUpdatePackage,
    final Option<Either<ApiException, void>>? createOrUpdateBank,
    final bool isDeleting,
    final bool isLoading,
  }) = _$MembershipStateImpl;

  @override
  Option<Either<ApiException, ListMembershipPackagesModel>>
  get membershipPackages;
  @override
  Option<Either<ApiException, BankDetailsModel>> get bankDetails;
  @override
  Option<Either<ApiException, void>>? get createOrUpdatePackage;
  @override
  Option<Either<ApiException, void>>? get createOrUpdateBank;
  @override
  bool get isDeleting;
  @override
  bool get isLoading;

  /// Create a copy of MembershipState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MembershipStateImplCopyWith<_$MembershipStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
