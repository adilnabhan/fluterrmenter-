import 'package:mentor_mobile_app/imports_bindings.dart';

part 'organization_listing_and_details_state.dart';
part 'organization_listing_and_details_cubit.freezed.dart';

class OrganizationListingAndDetailsCubit extends Cubit<OrganizationListingAndDetailsState> {
  OrganizationListingAndDetailsCubit() : super(const OrganizationListingAndDetailsState());

  void selectOrganization(SingleOrganizationModel? organization) {
    // emit(state.copyWith(sele: organization));
  }

  Future<void> fetchList() async {
    emit(state.copyWith(list: none()));
    final res = await OrganizationListAndDetailsRepository().fetch();
    res.fold((l) {}, (r) {
      final orgs = r.result ?? [];
      if (orgs.isEmpty) {
        emit(state.copyWith(selectedOrganization: null));
      } else if (orgs.isNotEmpty && state.selectedOrganization == null) {
        emit(state.copyWith(selectedOrganization: orgs.first));
      } else if (orgs.isNotEmpty && state.selectedOrganization != null) {
        final orgIndex = orgs.indexWhere((e) => e.id == state.selectedOrganization?.id);
        if (orgIndex != -1) {
          emit(state.copyWith(selectedOrganization: orgs[orgIndex]));
        } else {
          emit(state.copyWith(selectedOrganization: orgs.first));
        }
      }
    });
    emit(state.copyWith(list: some(res)));
  }

  Future<void> fetchDetails({required int orgId}) async {
    emit(state.copyWith(details: none()));
    final res = await OrganizationListAndDetailsRepository().fetchDetails(orgId: orgId);
    emit(state.copyWith(details: some(res)));
  }
}
