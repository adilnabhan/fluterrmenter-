import 'package:fpdart/fpdart.dart';
import 'package:mentor_mobile_app/core/api/uris/google_uri.dart';
import 'package:mentor_mobile_app/core/constants/app_data.dart';
import 'package:mentor_mobile_app/core/services/google/entities/google_auto_complete_entity.dart';
import 'package:mentor_mobile_app/core/services/google/entities/google_place_details_entity.dart';
import 'package:mentor_mobile_app/core/services/google/entities/google_place_response_entity.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

final class GooglePlaceRepo {
  //* This constructor body for creating singleton widget
  /// For handling goodle palce services eg: [Google AutoComplete Api,Google Place Api,Google Image Url Creator]
  factory GooglePlaceRepo() {
    _instance == null ? {_instance = GooglePlaceRepo._internel()} : null;
    return _instance!;
  }

  //* This named constructor for create object for this class
  GooglePlaceRepo._internel();

  //* This variable for store this class object globally
  static GooglePlaceRepo? _instance;

  ///* Auto complete api
  Future<GoogleAutoCompleteEntity> autocomplete(String input) async {
    try {
      final params = {'input': input, 'key': AppData.googleKey};
      return await Feggy.async(
        // ignore: inference_failure_on_function_invocation
        call: Dio().get(GoogleUris.autoComplete, queryParameters: params),
        onSuccess: (res) {
          write('auto complete res : ${res.data}');
          return GoogleAutoCompleteEntity.fromJson(res.data as Map<String, dynamic>);
        },
      );
    } catch (e) {
      throw '$e';
    }
  }

  //*Get place details from google place id
  Future<Either<ApiException, GooglePlaceResponseEntity>> placeDetails(String placeId) async {
    return Feggy.async(
      call: Dio().get<dynamic>(GoogleUris.placeDetails, queryParameters: {'placeid': placeId, 'key': AppData.googleKey}),
      onSuccess: (res) {
        write('res data map : ${res.data}');
        final model = GooglePlaceDetailsEntity.fromJson(res.data as Map<String, dynamic>);
        final location = model.result?.geometry?.location;
        final formattedAddress = model.result?.formattedAddress;

        ///check label name
        final labelName = model.result?.name;

        ///check vicinity
        final vicinity = model.result?.vicinity;
        write('label name: $labelName');
        write('vicinity: $vicinity');
        String? placeName;
        String? pincode;
        String? country;
        String? state;
        String? district;
        String? streetName;
        model.result?.addressComponents?.forEach((e) {
          /// check country
          if (listEquals(e.types, ['country', 'political']) && country == null) {
            country = e.longName ?? e.shortName;
          }

          /// check state
          if (listEquals(e.types, ['administrative_area_level_1', 'political']) && state == null) {
            state = e.longName ?? e.shortName;
          }

          /// check street
          if (listEquals(e.types, ['political', 'sublocality', 'sublocality_level_2']) && streetName == null) {
            streetName = e.longName ?? e.shortName;
          }

          /// check District
          if (listEquals(e.types, ['administrative_area_level_3', 'political']) && district == null) {
            district = e.longName ?? e.shortName;
          }

          /// check address component is pincode
          if (listEquals(e.types, ['postal_code']) && pincode == null) {
            pincode = e.longName ?? e.shortName;
          }

          /// check address component is place name
          if (listEquals(e.types, ['political', 'sublocality', 'sublocality_level_2'])) {
            placeName = e.longName ?? e.shortName;
          } else if (listEquals(e.types, ['neighborhood', 'political']) && placeName == null) {
            placeName = e.longName ?? e.shortName;
          } else if (listEquals(e.types, ['locality', 'political']) && placeName == null) {
            placeName = e.longName ?? e.shortName;
          }
        });
        write('placeName: $placeName');
        write('pincode: $pincode');
        write('country: $country');
        write('state: $state');
        write('district: $district');
        write('streetName: $streetName');
        write('location?.lat: ${location?.lat}');
        write('location?.lng: ${location?.lng}');
        if (location?.lat != null && location?.lng != null) {
          return right(
            GooglePlaceResponseEntity(
              lat: location!.lat!,
              lng: location.lng!,
              placeName: placeName,
              pincode: pincode,
              formatedAddress: formattedAddress,
              country: country,
              state: state,
              district: district,
              labelName: labelName,
              vicinity: vicinity,
              streetName: streetName,
            ),
          );
        }
        return left(const ApiException.unknown(msg: 'Currently selected location not acceptable!'));
      },
    );
  }

  //*
  // Future<GooglePlaceDetailsEntity> placeDetails(String placeId) async {
  //   try {
  //     final params = {
  //       'placeid': placeId,
  //       'key': AppData.googleKey,
  //     };
  //     return await BaseRepository().apiCall(
  //       call: Dio().get(
  //         GoogleUris.placeDetails,
  //         queryParameters: params,
  //       ),
  //       onSuccess: (res) {
  //         write('auto complete res : ${res.data}');
  //         return GooglePlaceDetailsEntity.fromJson(res.data);
  //       },
  //     );
  //   } catch (e) {
  //     throw '$e';
  //   }
  // }
}
