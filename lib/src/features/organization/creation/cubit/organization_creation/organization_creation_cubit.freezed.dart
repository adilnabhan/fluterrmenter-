// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_creation_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OrganizationCreationState {
  ///* Brand Details
  ({
    List<String> brandCategory,
    String brandDescription,
    String? brandLogo,
    String brandName
  })? get brandDetails => throw _privateConstructorUsedError;

  ///* Gym Location Details
  ({String city, String flatName, String picode, String state, String street})?
      get gymLocationDetails => throw _privateConstructorUsedError;

  ///* Gym Photos
  List<String> get gymPhotos => throw _privateConstructorUsedError;

  ///*
  Option<Either<ApiException, void>>? get createOrg =>
      throw _privateConstructorUsedError;

  /// Create a copy of OrganizationCreationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizationCreationStateCopyWith<OrganizationCreationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationCreationStateCopyWith<$Res> {
  factory $OrganizationCreationStateCopyWith(OrganizationCreationState value,
          $Res Function(OrganizationCreationState) then) =
      _$OrganizationCreationStateCopyWithImpl<$Res, OrganizationCreationState>;
  @useResult
  $Res call(
      {({
        List<String> brandCategory,
        String brandDescription,
        String? brandLogo,
        String brandName
      })? brandDetails,
      ({
        String city,
        String flatName,
        String picode,
        String state,
        String street
      })? gymLocationDetails,
      List<String> gymPhotos,
      Option<Either<ApiException, void>>? createOrg});
}

/// @nodoc
class _$OrganizationCreationStateCopyWithImpl<$Res,
        $Val extends OrganizationCreationState>
    implements $OrganizationCreationStateCopyWith<$Res> {
  _$OrganizationCreationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrganizationCreationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? brandDetails = freezed,
    Object? gymLocationDetails = freezed,
    Object? gymPhotos = null,
    Object? createOrg = freezed,
  }) {
    return _then(_value.copyWith(
      brandDetails: freezed == brandDetails
          ? _value.brandDetails
          : brandDetails // ignore: cast_nullable_to_non_nullable
              as ({
              List<String> brandCategory,
              String brandDescription,
              String? brandLogo,
              String brandName
            })?,
      gymLocationDetails: freezed == gymLocationDetails
          ? _value.gymLocationDetails
          : gymLocationDetails // ignore: cast_nullable_to_non_nullable
              as ({
              String city,
              String flatName,
              String picode,
              String state,
              String street
            })?,
      gymPhotos: null == gymPhotos
          ? _value.gymPhotos
          : gymPhotos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createOrg: freezed == createOrg
          ? _value.createOrg
          : createOrg // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, void>>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrganizationCreationStateImplCopyWith<$Res>
    implements $OrganizationCreationStateCopyWith<$Res> {
  factory _$$OrganizationCreationStateImplCopyWith(
          _$OrganizationCreationStateImpl value,
          $Res Function(_$OrganizationCreationStateImpl) then) =
      __$$OrganizationCreationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {({
        List<String> brandCategory,
        String brandDescription,
        String? brandLogo,
        String brandName
      })? brandDetails,
      ({
        String city,
        String flatName,
        String picode,
        String state,
        String street
      })? gymLocationDetails,
      List<String> gymPhotos,
      Option<Either<ApiException, void>>? createOrg});
}

/// @nodoc
class __$$OrganizationCreationStateImplCopyWithImpl<$Res>
    extends _$OrganizationCreationStateCopyWithImpl<$Res,
        _$OrganizationCreationStateImpl>
    implements _$$OrganizationCreationStateImplCopyWith<$Res> {
  __$$OrganizationCreationStateImplCopyWithImpl(
      _$OrganizationCreationStateImpl _value,
      $Res Function(_$OrganizationCreationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrganizationCreationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? brandDetails = freezed,
    Object? gymLocationDetails = freezed,
    Object? gymPhotos = null,
    Object? createOrg = freezed,
  }) {
    return _then(_$OrganizationCreationStateImpl(
      brandDetails: freezed == brandDetails
          ? _value.brandDetails
          : brandDetails // ignore: cast_nullable_to_non_nullable
              as ({
              List<String> brandCategory,
              String brandDescription,
              String? brandLogo,
              String brandName
            })?,
      gymLocationDetails: freezed == gymLocationDetails
          ? _value.gymLocationDetails
          : gymLocationDetails // ignore: cast_nullable_to_non_nullable
              as ({
              String city,
              String flatName,
              String picode,
              String state,
              String street
            })?,
      gymPhotos: null == gymPhotos
          ? _value._gymPhotos
          : gymPhotos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createOrg: freezed == createOrg
          ? _value.createOrg
          : createOrg // ignore: cast_nullable_to_non_nullable
              as Option<Either<ApiException, void>>?,
    ));
  }
}

/// @nodoc

class _$OrganizationCreationStateImpl implements _OrganizationCreationState {
  const _$OrganizationCreationStateImpl(
      {this.brandDetails,
      this.gymLocationDetails,
      final List<String> gymPhotos = const [],
      this.createOrg})
      : _gymPhotos = gymPhotos;

  ///* Brand Details
  @override
  final ({
    List<String> brandCategory,
    String brandDescription,
    String? brandLogo,
    String brandName
  })? brandDetails;

  ///* Gym Location Details
  @override
  final ({
    String city,
    String flatName,
    String picode,
    String state,
    String street
  })? gymLocationDetails;

  ///* Gym Photos
  final List<String> _gymPhotos;

  ///* Gym Photos
  @override
  @JsonKey()
  List<String> get gymPhotos {
    if (_gymPhotos is EqualUnmodifiableListView) return _gymPhotos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gymPhotos);
  }

  ///*
  @override
  final Option<Either<ApiException, void>>? createOrg;

  @override
  String toString() {
    return 'OrganizationCreationState(brandDetails: $brandDetails, gymLocationDetails: $gymLocationDetails, gymPhotos: $gymPhotos, createOrg: $createOrg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizationCreationStateImpl &&
            (identical(other.brandDetails, brandDetails) ||
                other.brandDetails == brandDetails) &&
            (identical(other.gymLocationDetails, gymLocationDetails) ||
                other.gymLocationDetails == gymLocationDetails) &&
            const DeepCollectionEquality()
                .equals(other._gymPhotos, _gymPhotos) &&
            (identical(other.createOrg, createOrg) ||
                other.createOrg == createOrg));
  }

  @override
  int get hashCode => Object.hash(runtimeType, brandDetails, gymLocationDetails,
      const DeepCollectionEquality().hash(_gymPhotos), createOrg);

  /// Create a copy of OrganizationCreationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationCreationStateImplCopyWith<_$OrganizationCreationStateImpl>
      get copyWith => __$$OrganizationCreationStateImplCopyWithImpl<
          _$OrganizationCreationStateImpl>(this, _$identity);
}

abstract class _OrganizationCreationState implements OrganizationCreationState {
  const factory _OrganizationCreationState(
          {final ({
            List<String> brandCategory,
            String brandDescription,
            String? brandLogo,
            String brandName
          })? brandDetails,
          final ({
            String city,
            String flatName,
            String picode,
            String state,
            String street
          })? gymLocationDetails,
          final List<String> gymPhotos,
          final Option<Either<ApiException, void>>? createOrg}) =
      _$OrganizationCreationStateImpl;

  ///* Brand Details
  @override
  ({
    List<String> brandCategory,
    String brandDescription,
    String? brandLogo,
    String brandName
  })? get brandDetails;

  ///* Gym Location Details
  @override
  ({String city, String flatName, String picode, String state, String street})?
      get gymLocationDetails;

  ///* Gym Photos
  @override
  List<String> get gymPhotos;

  ///*
  @override
  Option<Either<ApiException, void>>? get createOrg;

  /// Create a copy of OrganizationCreationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationCreationStateImplCopyWith<_$OrganizationCreationStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
