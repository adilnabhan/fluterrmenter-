// ignore_for_file: public_member_api_docs

import 'package:mentor_mobile_app/imports_bindings.dart';

@immutable
class GooglePlaceResponseEntity {
  const GooglePlaceResponseEntity({
    required this.lat,
    required this.lng,
    this.placeName,
    this.state,
    this.country,
    this.district,
    this.pincode,
    this.formatedAddress,
    this.streetName,
    this.labelName,
    this.vicinity,
  });
  final String? placeName;
  final String? pincode;
  final String? formatedAddress;
  final num lat;
  final num lng;
  final String? state;
  final String? country;
  final String? district;
  final String? labelName;
  final String? vicinity;
  final String? streetName;
}
