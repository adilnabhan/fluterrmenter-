import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/domain/models/banner_model.dart';

part 'organization_listing_and_details_state.dart';
part 'organization_listing_and_details_cubit.freezed.dart';

class OrganizationListingAndDetailsCubit
    extends Cubit<OrganizationListingAndDetailsState> {
  OrganizationListingAndDetailsCubit()
    : super(const OrganizationListingAndDetailsState());

  void selectOrganization(SingleOrganizationModel? organization) {
    emit(state.copyWith(selectedOrganization: organization));
  }

  Future<void> fetchList({bool isRefresh = false}) async {
    emit(
      state.copyWith(
        list: none(),
        details: none(),
        homeData: none(),
        selectedOrganization: isRefresh ? null : state.selectedOrganization,
      ),
    );
    final res = await OrganizationListAndDetailsRepository().fetch();
    res.fold(
      (l) {
        emit(state.copyWith(details: some(left(l)), homeData: some(left(l))));
      },
      (r) {
        final orgs = r.result ?? [];

        /// Check if the organization list is empty
        if (orgs.isEmpty) {
          emit(state.copyWith(selectedOrganization: null));
          return;
        }

        /// Check if the selected organization is null
        if (orgs.isNotEmpty && state.selectedOrganization == null) {
          emit(state.copyWith(selectedOrganization: orgs.first));
          return;
        }

        /// Check if the selected organization is not null
        if (orgs.isNotEmpty && state.selectedOrganization != null) {
          final orgIndex = orgs.indexWhere(
            (e) => e.id == state.selectedOrganization?.id,
          );
          if (orgIndex != -1) {
            emit(state.copyWith(selectedOrganization: orgs[orgIndex]));
          } else {
            emit(state.copyWith(selectedOrganization: orgs.first));
          }
          return;
        }

        /// If the organization list is empty and the selected organization is not null
        emit(
          state.copyWith(
            details: some(left(const ApiException.notFound())),
            homeData: some(left(const ApiException.notFound())),
          ),
        );
      },
    );
    emit(state.copyWith(list: some(res)));
  }

  Future<void> fetchOrg({required int orgId}) async {
    emit(state.copyWith(homeData: none(), details: none(), gymBanners: none(), globalBanners: none()));
    final organizationListAndDetailsRepository =
        OrganizationListAndDetailsRepository();
    final responses = await Future.wait([
      organizationListAndDetailsRepository.fetchDetails(orgId: orgId),
      organizationListAndDetailsRepository.fetchHomeData(orgId: orgId),
      organizationListAndDetailsRepository.getGymBanners(orgId),
      organizationListAndDetailsRepository.getGlobalBanners(),
    ]);
    final detailsResponse =
        responses[0] as Either<ApiException, OrganizationDetailsModel>;
    final homeDataResponse =
        responses[1] as Either<ApiException, OrganizationHomeDataModel>;
    final gymResponse = 
        responses[2] as Either<ApiException, List<BannerModel>>;
    final globalResponse = 
        responses[3] as Either<ApiException, List<BannerModel>>;
        
    detailsResponse.fold(
      (l) {
        emit(state.copyWith(details: some(left(l)), homeData: some(left(l))));
      },
      (details) {
        homeDataResponse.fold(
          (l) {
            emit(
              state.copyWith(homeData: some(left(l)), details: some(left(l))),
            );
          },
          (homeData) {
            emit(
              state.copyWith(
                homeData: some(right(homeData)),
                details: some(right(details)),
                gymBanners: some(gymResponse),
                globalBanners: some(globalResponse),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> fetchDetails({required int orgId}) async {
    emit(state.copyWith(details: none()));
    final res = await OrganizationListAndDetailsRepository().fetchDetails(
      orgId: orgId,
    );
    emit(state.copyWith(details: some(res)));
  }

  Future<void> fetchHomeData({required int orgId}) async {
    emit(state.copyWith(homeData: none()));
    final res = await OrganizationListAndDetailsRepository().fetchHomeData(
      orgId: orgId,
    );
    emit(state.copyWith(homeData: some(res)));
  }

  Future<void> updateOrgDetails({
    required int orgId,
    required dynamic body,
  }) async {
    emit(state.copyWith(updateOrgDetails: none()));
    final res = await OrganizationListAndDetailsRepository().updateOrgDetails(
      orgId: orgId,
      body: body,
    );
    emit(state.copyWith(updateOrgDetails: some(res)));
  }

  Future<void> deletePhoto({required int orgId, required int photoId}) async {
    emit(state.copyWith(updateOrgDetails: none()));
    final res = await OrganizationListAndDetailsRepository().deletePhoto(
      orgId: orgId,
      photoId: photoId,
    );
    emit(state.copyWith(updateOrgDetails: some(res)));
  }


  void skipSubscriptionCheck() {
    state.details.fold(() {}, (either) {
      either.fold((error) {}, (orgDetails) {
        final updatedOrgDetails = orgDetails.copyWith(
          isOnFreeTrial: true,
          isSubscribed: true,
        );
        emit(state.copyWith(details: Option.of(right(updatedOrgDetails))));
      });
    });
  }
}
