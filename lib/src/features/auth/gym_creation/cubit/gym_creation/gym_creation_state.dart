part of 'gym_creation_cubit.dart';

@freezed
class GymCreationState with _$GymCreationState {
  const factory GymCreationState({
    ///* Brand Details
    ({String brandName, String brandCategory, String brandDescription, String brandLogo})? brandDetails,

    ///* Gym Location Details
    ({String flatName, String street, String city, String state, String picode})? gymLocationDetails,

    ///* Gym Photos
    @Default([]) List<String> gymPhotos,

    ///*
    Option<Either<ApiException, void>>? createOrg,
  }) = _GymCreationState;
}
