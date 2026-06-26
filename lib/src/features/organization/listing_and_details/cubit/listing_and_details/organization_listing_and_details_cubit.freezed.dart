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
  SingleOrganizationModel? get selectedOrganization =>
      throw _privateConstructorUsedError;
  Option<Either<ApiException, OrganizationsListModel>> get list =>
      throw _privateConstructorUsedError;
  Option<Either<ApiException, OrganizationDetailsModel>> get details =>
      throw _privateConstructorUsedError;
  Option<Either<ApiException, OrganizationHomeDataModel>> get homeData =>
      throw _privateConstructorUsedError;
  Option<Either<ApiException, OrganizationDetailsModel>>?
  get updateOrgDetails => throw _privateConstructorUsedError;

  /// Create a copy of OrganizationListingAndDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizationListingAndDetailsStateCopyWith<
    OrganizationListingAndDetailsState
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationListingAndDetailsStateCopyWith<$Res> {
  factory $OrganizationListingAndDetailsStateCopyWith(
    OrganizationListingAndDetailsState value,
    $Res Function(OrganizationListingAndDetailsState) then,
  ) =
      _$OrganizationListingAndDetailsStateCopyWithImpl<
        $Res,
        OrganizationListingAndDetailsState
      >;
  @useResult
  $Res call({
    SingleOrganizationModel? selectedOrganization,
    Option<Either<ApiException, OrganizationsListModel>> list,
    Option<Either<ApiException, OrganizationDetailsModel>> details,
    Option<Either<ApiException, OrganizationHomeDataModel>> homeData,
    Option<Either<ApiException, OrganizationDetailsModel>>? updateOrgDetails,
  });

  $SingleOrganizationModelCopyWith<$Res>? get selectedOrganization;
}

/// @nodoc
class _$OrganizationListingAndDetailsStateCopyWithImpl<
  $Res,
  $Val extends OrganizationListingAndDetailsState
>
    implements $OrganizationListingAndDetailsStateCopyWith<$Res> {
  _$OrganizationListingAndDetailsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrganizationListingAndDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedOrganization = freezed,
    Object? list = null,
    Object? details = null,
    Object? homeData = null,
    Object? updateOrgDetails = freezed,
  }) {
    return _then(
      _value.copyWith(
            selectedOrganization:
                freezed == selectedOrganization
                    ? _value.selectedOrganization
                    : selectedOrganization // ignore: cast_nullable_to_non_nullable
                        as SingleOrganizationModel?,
            list:
                null == list
                    ? _value.list
                    : list // ignore: cast_nullable_to_non_nullable
                        as Option<Either<ApiException, OrganizationsListModel>>,
            details:
                null == details
                    ? _value.details
                    : details // ignore: cast_nullable_to_non_nullable
                        as Option<
                          Either<ApiException, OrganizationDetailsModel>
                        >,
            homeData:
                null == homeData
                    ? _value.homeData
                    : homeData // ignore: cast_nullable_to_non_nullable
                        as Option<
                          Either<ApiException, OrganizationHomeDataModel>
                        >,
            updateOrgDetails:
                freezed == updateOrgDetails
                    ? _value.updateOrgDetails
                    : updateOrgDetails // ignore: cast_nullable_to_non_nullable
                        as Option<
                          Either<ApiException, OrganizationDetailsModel>
                        >?,
          )
          as $Val,
    );
  }

  /// Create a copy of OrganizationListingAndDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SingleOrganizationModelCopyWith<$Res>? get selectedOrganization {
    if (_value.selectedOrganization == null) {
      return null;
    }

    return $SingleOrganizationModelCopyWith<$Res>(
      _value.selectedOrganization!,
      (value) {
        return _then(_value.copyWith(selectedOrganization: value) as $Val);
      },
    );
  }
}

/// @nodoc
abstract class _$$OrganizationListingAndDetailsStateImplCopyWith<$Res>
    implements $OrganizationListingAndDetailsStateCopyWith<$Res> {
  factory _$$OrganizationListingAndDetailsStateImplCopyWith(
    _$OrganizationListingAndDetailsStateImpl value,
    $Res Function(_$OrganizationListingAndDetailsStateImpl) then,
  ) = __$$OrganizationListingAndDetailsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    SingleOrganizationModel? selectedOrganization,
    Option<Either<ApiException, OrganizationsListModel>> list,
    Option<Either<ApiException, OrganizationDetailsModel>> details,
    Option<Either<ApiException, OrganizationHomeDataModel>> homeData,
    Option<Either<ApiException, OrganizationDetailsModel>>? updateOrgDetails,
  });

  @override
  $SingleOrganizationModelCopyWith<$Res>? get selectedOrganization;
}

/// @nodoc
class __$$OrganizationListingAndDetailsStateImplCopyWithImpl<$Res>
    extends
        _$OrganizationListingAndDetailsStateCopyWithImpl<
          $Res,
          _$OrganizationListingAndDetailsStateImpl
        >
    implements _$$OrganizationListingAndDetailsStateImplCopyWith<$Res> {
  __$$OrganizationListingAndDetailsStateImplCopyWithImpl(
    _$OrganizationListingAndDetailsStateImpl _value,
    $Res Function(_$OrganizationListingAndDetailsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrganizationListingAndDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedOrganization = freezed,
    Object? list = null,
    Object? details = null,
    Object? homeData = null,
    Object? updateOrgDetails = freezed,
  }) {
    return _then(
      _$OrganizationListingAndDetailsStateImpl(
        selectedOrganization:
            freezed == selectedOrganization
                ? _value.selectedOrganization
                : selectedOrganization // ignore: cast_nullable_to_non_nullable
                    as SingleOrganizationModel?,
        list:
            null == list
                ? _value.list
                : list // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, OrganizationsListModel>>,
        details:
            null == details
                ? _value.details
                : details // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, OrganizationDetailsModel>>,
        homeData:
            null == homeData
                ? _value.homeData
                : homeData // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, OrganizationHomeDataModel>>,
        updateOrgDetails:
            freezed == updateOrgDetails
                ? _value.updateOrgDetails
                : updateOrgDetails // ignore: cast_nullable_to_non_nullable
                    as Option<Either<ApiException, OrganizationDetailsModel>>?,
      ),
    );
  }
}

/// @nodoc

class _$OrganizationListingAndDetailsStateImpl
    implements _OrganizationListingAndDetailsState {
  const _$OrganizationListingAndDetailsStateImpl({
    this.selectedOrganization,
    this.list = const None(),
    this.details = const None(),
    this.homeData = const None(),
    this.updateOrgDetails,
  });

  @override
  final SingleOrganizationModel? selectedOrganization;
  @override
  @JsonKey()
  final Option<Either<ApiException, OrganizationsListModel>> list;
  @override
  @JsonKey()
  final Option<Either<ApiException, OrganizationDetailsModel>> details;
  @override
  @JsonKey()
  final Option<Either<ApiException, OrganizationHomeDataModel>> homeData;
  @override
  final Option<Either<ApiException, OrganizationDetailsModel>>?
  updateOrgDetails;

  @override
  String toString() {
    return 'OrganizationListingAndDetailsState(selectedOrganization: $selectedOrganization, list: $list, details: $details, homeData: $homeData, updateOrgDetails: $updateOrgDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizationListingAndDetailsStateImpl &&
            (identical(other.selectedOrganization, selectedOrganization) ||
                other.selectedOrganization == selectedOrganization) &&
            (identical(other.list, list) || other.list == list) &&
            (identical(other.details, details) || other.details == details) &&
            (identical(other.homeData, homeData) ||
                other.homeData == homeData) &&
            (identical(other.updateOrgDetails, updateOrgDetails) ||
                other.updateOrgDetails == updateOrgDetails));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    selectedOrganization,
    list,
    details,
    homeData,
    updateOrgDetails,
  );

  /// Create a copy of OrganizationListingAndDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationListingAndDetailsStateImplCopyWith<
    _$OrganizationListingAndDetailsStateImpl
  >
  get copyWith => __$$OrganizationListingAndDetailsStateImplCopyWithImpl<
    _$OrganizationListingAndDetailsStateImpl
  >(this, _$identity);
}

abstract class _OrganizationListingAndDetailsState
    implements OrganizationListingAndDetailsState {
  const factory _OrganizationListingAndDetailsState({
    final SingleOrganizationModel? selectedOrganization,
    final Option<Either<ApiException, OrganizationsListModel>> list,
    final Option<Either<ApiException, OrganizationDetailsModel>> details,
    final Option<Either<ApiException, OrganizationHomeDataModel>> homeData,
    final Option<Either<ApiException, OrganizationDetailsModel>>?
    updateOrgDetails,
  }) = _$OrganizationListingAndDetailsStateImpl;

  @override
  SingleOrganizationModel? get selectedOrganization;
  @override
  Option<Either<ApiException, OrganizationsListModel>> get list;
  @override
  Option<Either<ApiException, OrganizationDetailsModel>> get details;
  @override
  Option<Either<ApiException, OrganizationHomeDataModel>> get homeData;
  @override
  Option<Either<ApiException, OrganizationDetailsModel>>? get updateOrgDetails;

  /// Create a copy of OrganizationListingAndDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationListingAndDetailsStateImplCopyWith<
    _$OrganizationListingAndDetailsStateImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
