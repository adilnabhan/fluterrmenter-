import 'package:fpdart/fpdart.dart';
import 'package:mentor_mobile_app/core/api/uris/google_uri.dart';
import 'package:mentor_mobile_app/core/services/google/entities/google_auto_complete_entity.dart';
import 'package:mentor_mobile_app/core/services/google/entities/google_place_response_entity.dart';
import 'package:mentor_mobile_app/core/services/google/repos/google_place_repo.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

final class GooglePlaceServices {
  //* This constructor body for creating singleton widget
  /// For handling goodle palce services eg: [Google AutoComplete Api,Google Place Api,Google Image Url Creator]
  factory GooglePlaceServices() {
    _instance == null ? {_instance = GooglePlaceServices._internel()} : null;
    return _instance!;
  }

  //* This named constructor for create object for this class
  GooglePlaceServices._internel();

  //* This variable for store this class object globally
  static GooglePlaceServices? _instance;

  ///* Auto complete api
  Future<GoogleAutoCompleteEntity> autocomplete(String input) async {
    return await GooglePlaceRepo().autocomplete(input);
  }

  //*
  Future<Either<ApiException, GooglePlaceResponseEntity>> placeDetails(String placeId) async {
    return GooglePlaceRepo().placeDetails(placeId);
  }

  //*
  String createPlaceImageUrl({required String ref, int maxWidth = 400}) {
    return '${GoogleUris.placeImage}maxwidth=$maxWidth&photo_reference=$ref&key=${AppData.googleKey}';
  }
}
