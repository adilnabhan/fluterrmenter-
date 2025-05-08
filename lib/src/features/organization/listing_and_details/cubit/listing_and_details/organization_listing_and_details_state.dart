part of 'organization_listing_and_details_cubit.dart';

@freezed
class OrganizationListingAndDetailsState with _$OrganizationListingAndDetailsState {
  const factory OrganizationListingAndDetailsState({@Default(None()) Option<Either<ApiException, OrganizationsListEntity>> details}) = _OrganizationListingAndDetailsState;
}
