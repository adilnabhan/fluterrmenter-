part of 'organization_creation_cubit.dart';

@freezed
class OrganizationCreationState with _$OrganizationCreationState {
  const factory OrganizationCreationState({
    ///* Brand Details
    ({String brandName, List<String> brandCategory, String brandDescription, String brandLogo})? brandDetails,

    ///* Gym Location Details
    ({String flatName, String street, String city, String state, String picode})? gymLocationDetails,

    ///* Gym Photos
    @Default([]) List<String> gymPhotos,

    ///*
    Option<Either<ApiException, void>>? createOrg,
  }) = _OrganizationCreationState;
}
