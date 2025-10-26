// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_location_details_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OrganizationLocationDetailsState {
  Option<Either<ApiException, GooglePlaceResponseEntity>>?
  get currentPlaceDetails => throw _privateConstructorUsedError;
  Option<Either<ApiException, GoogleAutoCompleteEntity>>?
  get placeAutoCompletes => throw _privateConstructorUsedError;
  ({
    Option<Either<ApiException, GooglePlaceResponseEntity>> data,
    String placeID,
  })?
  get selectedPlaceDetails => throw _privateConstructorUsedError;

  /// Create a copy of OrganizationLocationDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizationLocationDetailsStateCopyWith<OrganizationLocationDetailsState>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationLocationDetailsStateCopyWith<$Res> {
  factory $OrganizationLocationDetailsStateCopyWith(
    OrganizationLocationDetailsState value,
    $Res Function(OrganizationLocationDetailsState) then,
  ) =
      _$OrganizationLocationDetailsStateCopyWithImpl<
        $Res,
        OrganizationLocationDetailsState
      >;
  @useResult
  $Res call({
    Option<Either<ApiException, GooglePlaceResponseEntity>>?
    currentPlaceDetails,
    Option<Either<ApiException, GoogleAutoCompleteEntity>>? placeAutoCompletes,
    ({
      Option<Either<ApiException, GooglePlaceResponseEntity>> data,
      String placeID,
    })?
    selectedPlaceDetails,
  });
}

/// @nodoc
class _$OrganizationLocationDetailsStateCopyWithImpl<
  $Res,
  $Val extends OrganizationLocationDetailsState
>
    implements $OrganizationLocationDetailsStateCopyWith<$Res> {
  _$OrganizationLocationDetailsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrganizationLocationDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPlaceDetails = freezed,
    Object? placeAutoCompletes = freezed,
    Object? selectedPlaceDetails = freezed,
  }) {
    return _then(
      _value.copyWith(
            currentPlaceDetails:
                freezed == currentPlaceDetails
                    ? _value.currentPlaceDetails
                    : currentPlaceDetails // ignore: cast_nullable_to_non_nullable
                        as Option<
                          Either<ApiException, GooglePlaceResponseEntity>
                        >?,
            placeAutoCompletes:
                freezed == placeAutoCompletes
                    ? _value.placeAutoCompletes
                    : placeAutoCompletes // ignore: cast_nullable_to_non_nullable
                        as Option<
                          Either<ApiException, GoogleAutoCompleteEntity>
                        >?,
            selectedPlaceDetails:
                freezed == selectedPlaceDetails
                    ? _value.selectedPlaceDetails
                    : selectedPlaceDetails // ignore: cast_nullable_to_non_nullable
                        as ({
                          Option<
                            Either<ApiException, GooglePlaceResponseEntity>
                          >
                          data,
                          String placeID,
                        })?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrganizationLocationDetailsStateImplCopyWith<$Res>
    implements $OrganizationLocationDetailsStateCopyWith<$Res> {
  factory _$$OrganizationLocationDetailsStateImplCopyWith(
    _$OrganizationLocationDetailsStateImpl value,
    $Res Function(_$OrganizationLocationDetailsStateImpl) then,
  ) = __$$OrganizationLocationDetailsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Option<Either<ApiException, GooglePlaceResponseEntity>>?
    currentPlaceDetails,
    Option<Either<ApiException, GoogleAutoCompleteEntity>>? placeAutoCompletes,
    ({
      Option<Either<ApiException, GooglePlaceResponseEntity>> data,
      String placeID,
    })?
    selectedPlaceDetails,
  });
}

/// @nodoc
class __$$OrganizationLocationDetailsStateImplCopyWithImpl<$Res>
    extends
        _$OrganizationLocationDetailsStateCopyWithImpl<
          $Res,
          _$OrganizationLocationDetailsStateImpl
        >
    implements _$$OrganizationLocationDetailsStateImplCopyWith<$Res> {
  __$$OrganizationLocationDetailsStateImplCopyWithImpl(
    _$OrganizationLocationDetailsStateImpl _value,
    $Res Function(_$OrganizationLocationDetailsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrganizationLocationDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPlaceDetails = freezed,
    Object? placeAutoCompletes = freezed,
    Object? selectedPlaceDetails = freezed,
  }) {
    return _then(
      _$OrganizationLocationDetailsStateImpl(
        currentPlaceDetails:
            freezed == currentPlaceDetails
                ? _value.currentPlaceDetails
                : currentPlaceDetails // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, GooglePlaceResponseEntity>>?,
        placeAutoCompletes:
            freezed == placeAutoCompletes
                ? _value.placeAutoCompletes
                : placeAutoCompletes // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, GoogleAutoCompleteEntity>>?,
        selectedPlaceDetails:
            freezed == selectedPlaceDetails
                ? _value.selectedPlaceDetails
                : selectedPlaceDetails // ignore: cast_nullable_to_non_nullable
                    as ({
                      Option<Either<ApiException, GooglePlaceResponseEntity>>
                      data,
                      String placeID,
                    })?,
      ),
    );
  }
}

/// @nodoc

class _$OrganizationLocationDetailsStateImpl
    implements _OrganizationLocationDetailsState {
  const _$OrganizationLocationDetailsStateImpl({
    this.currentPlaceDetails,
    this.placeAutoCompletes,
    this.selectedPlaceDetails,
  });

  @override
  final Option<Either<ApiException, GooglePlaceResponseEntity>>?
  currentPlaceDetails;
  @override
  final Option<Either<ApiException, GoogleAutoCompleteEntity>>?
  placeAutoCompletes;
  @override
  final ({
    Option<Either<ApiException, GooglePlaceResponseEntity>> data,
    String placeID,
  })?
  selectedPlaceDetails;

  @override
  String toString() {
    return 'OrganizationLocationDetailsState(currentPlaceDetails: $currentPlaceDetails, placeAutoCompletes: $placeAutoCompletes, selectedPlaceDetails: $selectedPlaceDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizationLocationDetailsStateImpl &&
            (identical(other.currentPlaceDetails, currentPlaceDetails) ||
                other.currentPlaceDetails == currentPlaceDetails) &&
            (identical(other.placeAutoCompletes, placeAutoCompletes) ||
                other.placeAutoCompletes == placeAutoCompletes) &&
            (identical(other.selectedPlaceDetails, selectedPlaceDetails) ||
                other.selectedPlaceDetails == selectedPlaceDetails));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentPlaceDetails,
    placeAutoCompletes,
    selectedPlaceDetails,
  );

  /// Create a copy of OrganizationLocationDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationLocationDetailsStateImplCopyWith<
    _$OrganizationLocationDetailsStateImpl
  >
  get copyWith => __$$OrganizationLocationDetailsStateImplCopyWithImpl<
    _$OrganizationLocationDetailsStateImpl
  >(this, _$identity);
}

abstract class _OrganizationLocationDetailsState
    implements OrganizationLocationDetailsState {
  const factory _OrganizationLocationDetailsState({
    final Option<Either<ApiException, GooglePlaceResponseEntity>>?
    currentPlaceDetails,
    final Option<Either<ApiException, GoogleAutoCompleteEntity>>?
    placeAutoCompletes,
    final ({
      Option<Either<ApiException, GooglePlaceResponseEntity>> data,
      String placeID,
    })?
    selectedPlaceDetails,
  }) = _$OrganizationLocationDetailsStateImpl;

  @override
  Option<Either<ApiException, GooglePlaceResponseEntity>>?
  get currentPlaceDetails;
  @override
  Option<Either<ApiException, GoogleAutoCompleteEntity>>?
  get placeAutoCompletes;
  @override
  ({
    Option<Either<ApiException, GooglePlaceResponseEntity>> data,
    String placeID,
  })?
  get selectedPlaceDetails;

  /// Create a copy of OrganizationLocationDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationLocationDetailsStateImplCopyWith<
    _$OrganizationLocationDetailsStateImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
