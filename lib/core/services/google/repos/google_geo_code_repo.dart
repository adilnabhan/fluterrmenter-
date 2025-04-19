import 'package:fpdart/fpdart.dart';
import 'package:mentor_mobile_app/core/api/uris/google_uri.dart';
import 'package:mentor_mobile_app/core/services/google/entities/google_geo_code_entity.dart';
import 'package:mentor_mobile_app/core/services/google/entities/google_place_response_entity.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

@immutable
class GoogleGeoCodeRepo {
  //* This constructor body for creating singleton widget
  /// For handling goodle services eg: [Google ]
  factory GoogleGeoCodeRepo() {
    _instance == null ? {_instance = GoogleGeoCodeRepo._internel()} : null;
    return _instance!;
  }

  //* This named constructor for create object for this class
  GoogleGeoCodeRepo._internel();

  //* This variable for store this class object globally
  static GoogleGeoCodeRepo? _instance;

  ///*Get place details from latitude and logitude
  Future<Either<ApiException, GooglePlaceResponseEntity>> fromLatLong(num latitude, num longitude) {
    final params = {'latlng': '$latitude,$longitude', 'key': AppData.googleKey};
    return Feggy.async(
      call: Dio().get<dynamic>(GoogleUris.geoCode, queryParameters: params),
      onSuccess: (res) {
        final model = GeoCodeEntity.fromJson(res.data as Map<String, dynamic>);
        final location = model.results?.first.geometry?.location;
        final formattedAddress = model.results?.first.formattedAddress;
        String? placeName;
        String? pincode;
        String? country;
        String? state;
        String? district;
        String? streetName;
        model.results?.first.addressComponents?.forEach((e) {
          /// check country
          if (listEquals(e.types, ['country', 'political']) && country == null) {
            country = e.longName ?? e.shortName;
          }

          /// check state
          if (listEquals(e.types, ['administrative_area_level_1', 'political']) && state == null) {
            state = e.longName ?? e.shortName;
          }

          /// check District
          if (listEquals(e.types, ['administrative_area_level_3', 'political']) && district == null) {
            district = e.longName ?? e.shortName;
          }

          /// check address component is pincode
          if (listEquals(e.types, ['postal_code']) && pincode == null) {
            pincode = e.longName ?? e.shortName;
          }

          /// check street
          if (listEquals(e.types, ['political', 'sublocality', 'sublocality_level_1']) && streetName == null) {
            streetName = e.longName ?? e.shortName;
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
        if (location?.lat != null && location?.lng != null) {
          return right(
            GooglePlaceResponseEntity(
              placeName: placeName,
              pincode: pincode,
              formatedAddress: formattedAddress,
              lat: location!.lat!,
              lng: location.lng!,
              country: country,
              state: state,
              district: district,
              streetName: streetName,
            ),
          );
        }
        return left(const ApiException.unknown(msg: 'Currently selected location not acceptable!'));
      },
    );
  }

  // //*Get place details from latitude and logitude
  // Future<GeoCodeEntity> fromLatLong(num latitude, num longitude) async {
  //   try {
  //     final params = {
  //       'latlng': '$latitude,$longitude',
  //       'key': AppData.googleKey,
  //     };
  //     return await BaseRepository().apiCall(
  //       call: Dio().get(
  //         GoogleUris.geoCode,
  //         queryParameters: params,
  //       ),
  //       onSuccess: (res) {
  //         write('auto complete res : ${res.data}');
  //         return GeoCodeEntity.fromJson(res.data);
  //       },
  //     );
  //   } catch (e) {
  //     throw '$e';
  //   }
  // }
}
