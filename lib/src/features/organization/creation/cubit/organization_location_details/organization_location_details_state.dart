part of 'organization_location_details_cubit.dart';

@freezed
class OrganizationLocationDetailsState with _$OrganizationLocationDetailsState {
  const factory OrganizationLocationDetailsState({
    Option<Either<ApiException, GooglePlaceResponseEntity>>? currentPlaceDetails,
    Option<Either<ApiException, GoogleAutoCompleteEntity>>? placeAutoCompletes,
    ({Option<Either<ApiException, GooglePlaceResponseEntity>> data, String placeID})? selectedPlaceDetails,
  }) = _OrganizationLocationDetailsState;
}
