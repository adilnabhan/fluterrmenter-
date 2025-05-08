import 'package:mentor_mobile_app/imports_bindings.dart';

part 'organization_location_details_state.dart';
part 'organization_location_details_cubit.freezed.dart';

class OrganizationLocationDetailsCubit extends Cubit<OrganizationLocationDetailsState> {
  OrganizationLocationDetailsCubit() : super(const OrganizationLocationDetailsState());

  Future<void> searchPlaces({required String q}) async {
    if (q.trim().isEmpty) {
      emit(state.copyWith(placeAutoCompletes: null));
      return;
    }
    try {
      emit(state.copyWith(placeAutoCompletes: none()));
      final res = await GooglePlaceRepo().autocomplete(q);
      emit(state.copyWith(placeAutoCompletes: some(right(res))));
    } on ApiException catch (e) {
      emit(state.copyWith(placeAutoCompletes: some(left(e))));
    } catch (e) {
      emit(state.copyWith(placeAutoCompletes: some(left(const ApiException.unknown()))));
    }
  }

  Future<void> getPlaceDetails({required String placeId}) async {
    try {
      emit(state.copyWith(selectedPlaceDetails: (data: none(), placeID: placeId)));
      final res = await GooglePlaceRepo().placeDetails(placeId);
      emit(state.copyWith(selectedPlaceDetails: (data: some(res), placeID: placeId)));
    } on ApiException catch (e) {
      emit(state.copyWith(selectedPlaceDetails: (data: some(left(e)), placeID: placeId)));
    } catch (e) {
      emit(state.copyWith(selectedPlaceDetails: (data: some(left(const ApiException.unknown())), placeID: placeId)));
    }
  }

  Future<void> getPlaceDetailsFromCurrentLocation() async {
    try {
      emit(state.copyWith(currentPlaceDetails: none()));
      final currentPosition = await LocationService().getPostion();
      final res = await GoogleGeoCodeRepo().fromLatLong(currentPosition.latitude, currentPosition.longitude);
      emit(state.copyWith(currentPlaceDetails: some(res)));
    } on ApiException catch (e) {
      emit(state.copyWith(currentPlaceDetails: some(left(e))));
    } catch (e) {
      emit(state.copyWith(currentPlaceDetails: some(left(const ApiException.unknown()))));
    }
  }
}
