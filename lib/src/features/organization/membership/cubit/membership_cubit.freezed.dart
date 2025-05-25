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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MembershipState {
  Option<Either<ApiException, ListMembershipPackagesModel>>
      get membershipPackages => throw _privateConstructorUsedError;
  Option<Either<ApiException, void>>? get createOrUpdatePackage =>
      throw _privateConstructorUsedError;

  /// Create a copy of MembershipState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MembershipStateCopyWith<MembershipState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembershipStateCopyWith<$Res> {
  factory $MembershipStateCopyWith(
          MembershipState value, $Res Function(MembershipState) then) =
      _$MembershipStateCopyWithImpl<$Res, MembershipState>;
  @useResult
  $Res call(
      {Option<Either<ApiException, ListMembershipPackagesModel>>
          membershipPackages,
      Option<Either<ApiException, void>>? createOrUpdatePackage});
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
    Object? createOrUpdatePackage = freezed,
  }) {
    return _then(_value.copyWith(
      membershipPackages: null == membershipPackages
          ? _value.membershipPackages
          : membershipPackages // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, ListMembershipPackagesModel>>,
      createOrUpdatePackage: freezed == createOrUpdatePackage
          ? _value.createOrUpdatePackage
          : createOrUpdatePackage // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, void>>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MembershipStateImplCopyWith<$Res>
    implements $MembershipStateCopyWith<$Res> {
  factory _$$MembershipStateImplCopyWith(_$MembershipStateImpl value,
          $Res Function(_$MembershipStateImpl) then) =
      __$$MembershipStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Option<Either<ApiException, ListMembershipPackagesModel>>
          membershipPackages,
      Option<Either<ApiException, void>>? createOrUpdatePackage});
}

/// @nodoc
class __$$MembershipStateImplCopyWithImpl<$Res>
    extends _$MembershipStateCopyWithImpl<$Res, _$MembershipStateImpl>
    implements _$$MembershipStateImplCopyWith<$Res> {
  __$$MembershipStateImplCopyWithImpl(
      _$MembershipStateImpl _value, $Res Function(_$MembershipStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MembershipState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? membershipPackages = null,
    Object? createOrUpdatePackage = freezed,
  }) {
    return _then(_$MembershipStateImpl(
      membershipPackages: null == membershipPackages
          ? _value.membershipPackages
          : membershipPackages // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, ListMembershipPackagesModel>>,
      createOrUpdatePackage: freezed == createOrUpdatePackage
          ? _value.createOrUpdatePackage
          : createOrUpdatePackage // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, void>>?,
    ));
  }
}

/// @nodoc

class _$MembershipStateImpl implements _MembershipState {
  const _$MembershipStateImpl(
      {this.membershipPackages = const None(), this.createOrUpdatePackage});

  @override
  @JsonKey()
  final Option<Either<ApiException, ListMembershipPackagesModel>>
      membershipPackages;
  @override
  final Option<Either<ApiException, void>>? createOrUpdatePackage;

  @override
  String toString() {
    return 'MembershipState(membershipPackages: $membershipPackages, createOrUpdatePackage: $createOrUpdatePackage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MembershipStateImpl &&
            (identical(other.membershipPackages, membershipPackages) ||
                other.membershipPackages == membershipPackages) &&
            (identical(other.createOrUpdatePackage, createOrUpdatePackage) ||
                other.createOrUpdatePackage == createOrUpdatePackage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, membershipPackages, createOrUpdatePackage);

  /// Create a copy of MembershipState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MembershipStateImplCopyWith<_$MembershipStateImpl> get copyWith =>
      __$$MembershipStateImplCopyWithImpl<_$MembershipStateImpl>(
          this, _$identity);
}

abstract class _MembershipState implements MembershipState {
  const factory _MembershipState(
          {final Option<Either<ApiException, ListMembershipPackagesModel>>
              membershipPackages,
          final Option<Either<ApiException, void>>? createOrUpdatePackage}) =
      _$MembershipStateImpl;

  @override
  Option<Either<ApiException, ListMembershipPackagesModel>>
      get membershipPackages;
  @override
  Option<Either<ApiException, void>>? get createOrUpdatePackage;

  /// Create a copy of MembershipState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MembershipStateImplCopyWith<_$MembershipStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
