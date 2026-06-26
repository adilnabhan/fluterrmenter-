import 'package:fpdart/fpdart.dart';
import 'package:mentor_mobile_app/core/services/google/entities/google_place_response_entity.dart';
import 'package:mentor_mobile_app/core/services/google/repos/google_geo_code_repo.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

@immutable
class GoogleGeoCodeServices {
  //* This constructor body for creating singleton widget
  /// For handling goodle services eg: [Google ]
  factory GoogleGeoCodeServices() {
    _instance == null ? {_instance = GoogleGeoCodeServices._internel()} : null;
    return _instance!;
  }

  //* This named constructor for create object for this class
  GoogleGeoCodeServices._internel();

  //* This variable for store this class object globally
  static GoogleGeoCodeServices? _instance;

  //*Get place details from latitude and logitude
  Future<Either<ApiException, GooglePlaceResponseEntity>> fromLatLong(double latitude, double longitude) async {
    //*Fetching current location details
    return GoogleGeoCodeRepo().fromLatLong(latitude, longitude);

    //*Getting Locality Name from response
    //   GeoAddressComponentEntity? locality;
    //   for (var types in [
    //     ["political", "sublocality", "sublocality_level_2"],
    //     ['locality', 'political'],
    //   ]) {
    //     locality = res.results?.first.addressComponents?.singleWhere(
    //       (e) => '${e.types}' == '$types',
    //       orElse: () => GeoAddressComponentEntity(
    //         longName: '',
    //         shortName: '',
    //         types: [],
    //       ),
    //     );
    //     if ((locality?.shortName?.isNotEmpty ?? false)) {
    //       break;
    //     }
    //   }
    //   if (locality != null &&
    //       (res.results?.first.addressComponents?.isNotEmpty ?? false)) {
    //     res.results!.first.addressComponents!
    //       ..clear()
    //       ..add(locality);
    //   }

    //   if (res.results?.first == null) {
    //     //* Handling Error Cases [ No location available in local and api side ]
    //     throw 'Couldn\'t pick current location now ! Please try again later';
    //   }

    //   //* Checking Given locality not null and empty
    //   return res.results!.first;
    // }
  }
}
