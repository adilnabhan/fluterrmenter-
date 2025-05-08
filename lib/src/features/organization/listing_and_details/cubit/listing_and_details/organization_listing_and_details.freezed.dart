// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_listing_and_details_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OrganizationListingAndDetailsState {
  Option<Either<ApiException, OrganizationsListEntity>> get details => throw _privateConstructorUsedError;

  /// Create a copy of OrganizationListingAndDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizationListingAndDetailsStateCopyWith<OrganizationListingAndDetailsState> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationListingAndDetailsStateCopyWith<$Res> {
  factory $OrganizationListingAndDetailsStateCopyWith(OrganizationListingAndDetailsState value, $Res Function(OrganizationListingAndDetailsState) then) =
      _$OrganizationListingAndDetailsStateCopyWithImpl<$Res, OrganizationListingAndDetailsState>;
  @useResult
  $Res call({Option<Either<ApiException, OrganizationsListEntity>> details});
}

/// @nodoc
class _$OrganizationListingAndDetailsStateCopyWithImpl<$Res, $Val extends OrganizationListingAndDetailsState> implements $OrganizationListingAndDetailsStateCopyWith<$Res> {
  _$OrganizationListingAndDetailsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrganizationListingAndDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? details = null}) {
    return _then(
      _value.copyWith(
            details:
                null == details
                    ? _value.details
                    : details // ignore: cast_nullable_to_non_nullable
                        as Option<Either<ApiException, OrganizationsListEntity>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrganizationListingAndDetailsStateImplCopyWith<$Res> implements $OrganizationListingAndDetailsStateCopyWith<$Res> {
  factory _$$OrganizationListingAndDetailsStateImplCopyWith(_$OrganizationListingAndDetailsStateImpl value, $Res Function(_$OrganizationListingAndDetailsStateImpl) then) =
      __$$OrganizationListingAndDetailsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Option<Either<ApiException, OrganizationsListEntity>> details});
}

/// @nodoc
class __$$OrganizationListingAndDetailsStateImplCopyWithImpl<$Res> extends _$OrganizationListingAndDetailsStateCopyWithImpl<$Res, _$OrganizationListingAndDetailsStateImpl>
    implements _$$OrganizationListingAndDetailsStateImplCopyWith<$Res> {
  __$$OrganizationListingAndDetailsStateImplCopyWithImpl(_$OrganizationListingAndDetailsStateImpl _value, $Res Function(_$OrganizationListingAndDetailsStateImpl) _then) : super(_value, _then);

  /// Create a copy of OrganizationListingAndDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? details = null}) {
    return _then(
      _$OrganizationListingAndDetailsStateImpl(
        details:
            null == details
                ? _value.details
                : details // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, OrganizationsListEntity>>,
      ),
    );
  }
}

/// @nodoc

class _$OrganizationListingAndDetailsStateImpl implements _OrganizationListingAndDetailsState {
  const _$OrganizationListingAndDetailsStateImpl({this.details = const None()});

  @override
  @JsonKey()
  final Option<Either<ApiException, OrganizationsListEntity>> details;

  @override
  String toString() {
    return 'OrganizationListingAndDetailsState(details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$OrganizationListingAndDetailsStateImpl && (identical(other.details, details) || other.details == details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, details);

  /// Create a copy of OrganizationListingAndDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationListingAndDetailsStateImplCopyWith<_$OrganizationListingAndDetailsStateImpl> get copyWith =>
      __$$OrganizationListingAndDetailsStateImplCopyWithImpl<_$OrganizationListingAndDetailsStateImpl>(this, _$identity);
}

abstract class _OrganizationListingAndDetailsState implements OrganizationListingAndDetailsState {
  const factory _OrganizationListingAndDetailsState({final Option<Either<ApiException, OrganizationsListEntity>> details}) = _$OrganizationListingAndDetailsStateImpl;

  @override
  Option<Either<ApiException, OrganizationsListEntity>> get details;

  /// Create a copy of OrganizationListingAndDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationListingAndDetailsStateImplCopyWith<_$OrganizationListingAndDetailsStateImpl> get copyWith => throw _privateConstructorUsedError;
}
