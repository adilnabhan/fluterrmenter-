import 'package:mentor_mobile_app/imports_bindings.dart';

part 'organization_listing_and_details_state.dart';
part 'organization_listing_and_details.freezed.dart';

class OrganizationListingAndDetailsCubit extends Cubit<OrganizationListingAndDetailsState> {
  OrganizationListingAndDetailsCubit() : super(const OrganizationListingAndDetailsState());

  Future<void> fetch() async {
    emit(state.copyWith(details: none()));
    final res = await OrganizationListRepository().fetch();
    emit(state.copyWith(details: some(res)));
  }
}
