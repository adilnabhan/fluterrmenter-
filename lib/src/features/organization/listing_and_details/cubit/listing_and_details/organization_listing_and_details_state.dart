part of 'organization_listing_and_details_cubit.dart';

@freezed
class OrganizationListingAndDetailsState
    with _$OrganizationListingAndDetailsState {
  const factory OrganizationListingAndDetailsState({
    SingleOrganizationModel? selectedOrganization,
    @Default(None()) Option<Either<ApiException, OrganizationsListModel>> list,
    @Default(None())
    Option<Either<ApiException, OrganizationDetailsModel>> details,
    @Default(None())
    Option<Either<ApiException, OrganizationHomeDataModel>> homeData,
    Option<Either<ApiException, OrganizationDetailsModel>>? updateOrgDetails,
    @Default(None()) Option<Either<ApiException, List<BannerModel>>> gymBanners,
    @Default(None()) Option<Either<ApiException, List<BannerModel>>> globalBanners,
  }) = _OrganizationListingAndDetailsState;
}
