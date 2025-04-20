part of 'gym_location_details_cubit.dart';

@freezed
class GymLocationDetailsState with _$GymLocationDetailsState {
  const factory GymLocationDetailsState({
    Option<Either<ApiException, GooglePlaceResponseEntity>>?
    currentPlaceDetails,
    Option<Either<ApiException, GoogleAutoCompleteEntity>>? placeAutoCompletes,
    ({
      Option<Either<ApiException, GooglePlaceResponseEntity>> data,
      String placeID,
    })?
    selectedPlaceDetails,
  }) = _GymLocationDetailsState;
}
