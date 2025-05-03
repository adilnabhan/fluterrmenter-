// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gym_creation_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GymCreationState {
  ///* Brand Details
  ({
    String brandCategory,
    String brandDescription,
    String brandLogo,
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

  /// Create a copy of GymCreationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GymCreationStateCopyWith<GymCreationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GymCreationStateCopyWith<$Res> {
  factory $GymCreationStateCopyWith(
          GymCreationState value, $Res Function(GymCreationState) then) =
      _$GymCreationStateCopyWithImpl<$Res, GymCreationState>;
  @useResult
  $Res call(
      {({
        String brandCategory,
        String brandDescription,
        String brandLogo,
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
class _$GymCreationStateCopyWithImpl<$Res, $Val extends GymCreationState>
    implements $GymCreationStateCopyWith<$Res> {
  _$GymCreationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GymCreationState
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
              String brandCategory,
              String brandDescription,
              String brandLogo,
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
abstract class _$$GymCreationStateImplCopyWith<$Res>
    implements $GymCreationStateCopyWith<$Res> {
  factory _$$GymCreationStateImplCopyWith(_$GymCreationStateImpl value,
          $Res Function(_$GymCreationStateImpl) then) =
      __$$GymCreationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {({
        String brandCategory,
        String brandDescription,
        String brandLogo,
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
class __$$GymCreationStateImplCopyWithImpl<$Res>
    extends _$GymCreationStateCopyWithImpl<$Res, _$GymCreationStateImpl>
    implements _$$GymCreationStateImplCopyWith<$Res> {
  __$$GymCreationStateImplCopyWithImpl(_$GymCreationStateImpl _value,
      $Res Function(_$GymCreationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of GymCreationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? brandDetails = freezed,
    Object? gymLocationDetails = freezed,
    Object? gymPhotos = null,
    Object? createOrg = freezed,
  }) {
    return _then(_$GymCreationStateImpl(
      brandDetails: freezed == brandDetails
          ? _value.brandDetails
          : brandDetails // ignore: cast_nullable_to_non_nullable
              as ({
              String brandCategory,
              String brandDescription,
              String brandLogo,
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

class _$GymCreationStateImpl implements _GymCreationState {
  const _$GymCreationStateImpl(
      {this.brandDetails,
      this.gymLocationDetails,
      final List<String> gymPhotos = const [],
      this.createOrg})
      : _gymPhotos = gymPhotos;

  ///* Brand Details
  @override
  final ({
    String brandCategory,
    String brandDescription,
    String brandLogo,
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
    return 'GymCreationState(brandDetails: $brandDetails, gymLocationDetails: $gymLocationDetails, gymPhotos: $gymPhotos, createOrg: $createOrg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GymCreationStateImpl &&
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

  /// Create a copy of GymCreationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GymCreationStateImplCopyWith<_$GymCreationStateImpl> get copyWith =>
      __$$GymCreationStateImplCopyWithImpl<_$GymCreationStateImpl>(
          this, _$identity);
}

abstract class _GymCreationState implements GymCreationState {
  const factory _GymCreationState(
          {final ({
            String brandCategory,
            String brandDescription,
            String brandLogo,
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
      _$GymCreationStateImpl;

  ///* Brand Details
  @override
  ({
    String brandCategory,
    String brandDescription,
    String brandLogo,
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

  /// Create a copy of GymCreationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GymCreationStateImplCopyWith<_$GymCreationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
