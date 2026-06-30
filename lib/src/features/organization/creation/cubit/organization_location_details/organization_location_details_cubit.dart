import 'package:mentor_mobile_app/imports_bindings.dart';

part 'organization_location_details_state.dart';
part 'organization_location_details_cubit.freezed.dart';

class OrganizationLocationDetailsCubit
    extends Cubit<OrganizationLocationDetailsState> {
  OrganizationLocationDetailsCubit()
    : super(const OrganizationLocationDetailsState());

  Future<void> searchPlaces({required String q}) async {
    if (q.trim().isEmpty) {
      if (isClosed) return;
      emit(state.copyWith(placeAutoCompletes: null));
      return;
    }
    try {
      if (isClosed) return;
      emit(state.copyWith(placeAutoCompletes: none()));
      final res = await GooglePlaceRepo().autocomplete(q);
      if (isClosed) return;
      emit(state.copyWith(placeAutoCompletes: some(right(res))));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(placeAutoCompletes: some(left(e))));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          placeAutoCompletes: some(left(const ApiException.unknown())),
        ),
      );
    }
  }

  Future<void> getPlaceDetails({required String placeId}) async {
    try {
      if (isClosed) return;
      emit(
        state.copyWith(selectedPlaceDetails: (data: none(), placeID: placeId)),
      );
      final res = await GooglePlaceRepo().placeDetails(placeId);
      res.fold(
            (l) {
              print('badhnf=$l');
            },
            (r) {
              // print('rrr=${r.formatedAddress}');
              print('rr=${r.placeName}');
              print('ttt=${r.vicinity}');
              print('ttt=${r.country}');
              print('ttt=${r.pincode}');
            },
          ) ??
          false;

      if (isClosed) return;
      emit(
        state.copyWith(
          selectedPlaceDetails: (data: some(res), placeID: placeId),
        ),
      );
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          selectedPlaceDetails: (data: some(left(e)), placeID: placeId),
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          selectedPlaceDetails: (
            data: some(left(const ApiException.unknown())),
            placeID: placeId,
          ),
        ),
      );
    }
  }

  Future<void> getPlaceDetailsFromCurrentLocation() async {
    try {
      if (isClosed) return;
      emit(state.copyWith(currentPlaceDetails: none()));
      final currentPosition = await LocationService().getPostion();
      final res = await GoogleGeoCodeRepo().fromLatLong(
        currentPosition.latitude,
        currentPosition.longitude,
      );
      GooglePlaceResponseEntity? data;
      res.fold(
            (l) {
              print('badhnf=$l');
            },
            (r) {
              print('FromCurrentLocation=${r.formatedAddress}');
              print('FromCurrentLocation=${r.placeName}');
              print('FromCurrentLocation=${r.vicinity}');
              print('FromCurrentLocation=${r.country}');
              print('FromCurrentLocation=${r.pincode}');
              data = GooglePlaceResponseEntity(
                lat: r.lat,
                lng: r.lng,
                country: r.country,
                district: r.district,
                formatedAddress: r.formatedAddress,
                labelName: r.labelName,
                pincode: r.pincode,
                placeName: r.placeName,
                state: r.state,
                streetName: r.streetName,
                vicinity: r.vicinity,
              );
            },
          ) ??
          false;

      if (isClosed) return;
      emit(
        state.copyWith(
          currentPlaceDetails: some(res),
          selectedPlaceDetails: (
            data: some(right(data!)),
            placeID: '${currentPosition.latitude},${currentPosition.longitude}',
          ),
        ),
      );
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(currentPlaceDetails: some(left(e))));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          currentPlaceDetails: some(left(const ApiException.unknown())),
        ),
      );
    }
  }
}

//
// import 'package:mentor_mobile_app/imports_bindings.dart';
//
// part 'organization_location_details_state.dart';
// part 'organization_location_details_cubit.freezed.dart';
//
// class OrganizationLocationDetailsCubit extends Cubit<OrganizationLocationDetailsState> {
//   OrganizationLocationDetailsCubit() : super(const OrganizationLocationDetailsState());
//
//   Future<void> searchPlaces({required String q}) async {
//     if (q.trim().isEmpty) {
//       if (isClosed) return;
//       emit(state.copyWith(placeAutoCompletes: null));
//       return;
//     }
//     try {
//       if (isClosed) return;
//       emit(state.copyWith(placeAutoCompletes: none()));
//       final res = await GooglePlaceRepo().autocomplete(q);
//       if (isClosed) return;
//       emit(state.copyWith(placeAutoCompletes: some(right(res))));
//     } on ApiException catch (e) {
//       if (isClosed) return;
//       emit(state.copyWith(placeAutoCompletes: some(left(e))));
//     } catch (e) {
//       if (isClosed) return;
//       emit(state.copyWith(placeAutoCompletes: some(left(const ApiException.unknown()))));
//     }
//   }
//
//   Future<void> getPlaceDetails({required String placeId}) async {
//     try {
//       if (isClosed) return;
//       emit(state.copyWith(selectedPlaceDetails: (data: none(), placeID: placeId)));
//       final res = await GooglePlaceRepo().placeDetails(placeId);
//       if (isClosed) return;
//       emit(state.copyWith(selectedPlaceDetails: (data: some(res), placeID: placeId)));
//     } on ApiException catch (e) {
//       if (isClosed) return;
//       emit(state.copyWith(selectedPlaceDetails: (data: some(left(e)), placeID: placeId)));
//     } catch (e) {
//       if (isClosed) return;
//       emit(state.copyWith(selectedPlaceDetails: (data: some(left(const ApiException.unknown())), placeID: placeId)));
//     }
//   }
//
//   Future<void> getPlaceDetailsFromCurrentLocation() async {
//     try {
//       if (isClosed) return;
//       emit(state.copyWith(currentPlaceDetails: none()));
//       final currentPosition = await LocationService().getPostion();
//       final res = await GoogleGeoCodeRepo().fromLatLong(currentPosition.latitude, currentPosition.longitude);
//       if (isClosed) return;
//       emit(state.copyWith(currentPlaceDetails: some(res)));
//     } on ApiException catch (e) {
//       if (isClosed) return;
//       emit(state.copyWith(currentPlaceDetails: some(left(e))));
//     } catch (e) {
//       if (isClosed) return;
//       emit(state.copyWith(currentPlaceDetails: some(left(const ApiException.unknown()))));
//     }
//   }
// }
