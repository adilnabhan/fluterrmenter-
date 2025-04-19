import 'package:geolocator/geolocator.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

///
class LocationService {
  //* This constructor body for creating singleton widget
  /// For handling location services eg: [Fetch Current Location]
  factory LocationService() {
    _instance ??= LocationService._internel();
    return _instance!;
  }

  //* This named constructor for create object for this class
  LocationService._internel();

  //* This variable for store this class object globally
  static LocationService? _instance;

  final String _errorMsg = 'Location permissions are denied';

  ///*For fetch current location
  Future<Position> getPostion() async {
    //*Handling hasn't connection
    try {
      final permission = await handlePermission();
      if (permission) {
        return Geolocator.getCurrentPosition();
      } else {
        throw ApiException.unknown(msg: _errorMsg);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.unknown(msg: _errorMsg);
    }
  }

  //* Handling location permisiion
  Future<bool> handlePermission() async {
    //*For store location state
    LocationPermission? permission;

    //* Checking connection enabled or not
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      return true;
    } else if (permission == LocationPermission.deniedForever) {
      await openAppSettings();
    } else {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      return true;
    } else {
      await openAppSettings();
    }
    throw ApiException.unknown(msg: _errorMsg);
  }

  //*Handling
  // Future<List<Placemark>> currentLocation() async {
  //   try {
  //     final position = await _getPostion();
  //     return await placemarkFromCoordinates(position.latitude, position.longitude);
  //   } catch (e) {
  //     write('location error is : $e');
  //     if (_errorMsg == '$e') {
  //       rethrow;
  //     }
  //     throw 'Something went wrong ! please try again later .';
  //   }
  // }
}
