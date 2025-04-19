class GeoCodeEntity {
  factory GeoCodeEntity.fromJson(Map<String, dynamic> json) => GeoCodeEntity(
        plusCode: json['plus_code'] == null ? null : GeoPlusCodeEntity.fromJson(json['plus_code'] as Map<String, dynamic>),
        results: json['results'] == null ? [] : List<GoeResultEntity>.from((json['results'] as List).map((x) => GoeResultEntity.fromJson(x as Map<String, dynamic>))),
        status: json['status'] as String?,
      );

  GeoCodeEntity({
    this.plusCode,
    this.results,
    this.status,
  });
  final GeoPlusCodeEntity? plusCode;
  final List<GoeResultEntity>? results;
  final String? status;
}

class GeoPlusCodeEntity {
  GeoPlusCodeEntity({
    this.compoundCode,
    this.globalCode,
  });

  factory GeoPlusCodeEntity.fromJson(Map<String, dynamic> json) => GeoPlusCodeEntity(
        compoundCode: json['compound_code'] as String?,
        globalCode: json['global_code'] as String?,
      );
  final String? compoundCode;
  final String? globalCode;
}

class GoeResultEntity {
  GoeResultEntity({
    this.addressComponents,
    this.formattedAddress,
    this.geometry,
    this.placeId,
    this.plusCode,
    this.types,
  });

  factory GoeResultEntity.fromJson(Map<String, dynamic> json) => GoeResultEntity(
        addressComponents: json['address_components'] == null ? [] : List<GeoAddressComponentEntity>.from((json['address_components'] as List<dynamic>).map((dynamic x) => GeoAddressComponentEntity.fromJson(x as Map<String, dynamic>))),
        formattedAddress: json['formatted_address'] as String?,
        geometry: json['geometry'] == null ? null : GeometryEntity.fromJson(json['geometry'] as Map<String, dynamic>),
        placeId: json['place_id'] as String?,
        plusCode: json['plus_code'] == null ? null : GeoPlusCodeEntity.fromJson(json['plus_code'] as Map<String, dynamic>),
        types: json['types'] == null ? [] : List<String>.from((json['types'] as List<dynamic>).map((dynamic x) => x as String)),
      );
  final List<GeoAddressComponentEntity>? addressComponents;
  final String? formattedAddress;
  final GeometryEntity? geometry;
  final String? placeId;
  final GeoPlusCodeEntity? plusCode;
  final List<String>? types;
}

class GeoAddressComponentEntity {
  GeoAddressComponentEntity({
    this.longName,
    this.shortName,
    this.types,
  });

  factory GeoAddressComponentEntity.fromJson(Map<String, dynamic> json) => GeoAddressComponentEntity(
        longName: json['long_name'] as String?,
        shortName: json['short_name'] as String?,
        types: json['types'] == null ? [] : List<String>.from((json['types'] as List<dynamic>).map((dynamic x) => x as String)),
      );
  final String? longName;
  final String? shortName;
  final List<String>? types;
}

class GeometryEntity {
  GeometryEntity({
    this.location,
    this.locationType,
    this.viewport,
    this.bounds,
  });

  factory GeometryEntity.fromJson(Map<String, dynamic> json) => GeometryEntity(
        location: json['location'] == null ? null : GeoLocationEntity.fromJson(json['location'] as Map<String, dynamic>),
        locationType: locationTypeValues.map[json['location_type']],
        viewport: json['viewport'] == null ? null : GeoBoundsEntity.fromJson(json['viewport'] as Map<String, dynamic>),
        bounds: json['bounds'] == null ? null : GeoBoundsEntity.fromJson(json['bounds'] as Map<String, dynamic>),
      );
  final GeoLocationEntity? location;
  final GeoLocationType? locationType;
  final GeoBoundsEntity? viewport;
  final GeoBoundsEntity? bounds;
}

class GeoBoundsEntity {
  GeoBoundsEntity({
    this.northeast,
    this.southwest,
  });

  factory GeoBoundsEntity.fromJson(Map<String, dynamic> json) => GeoBoundsEntity(
        northeast: json['northeast'] == null ? null : GeoLocationEntity.fromJson(json['northeast'] as Map<String, dynamic>),
        southwest: json['southwest'] == null ? null : GeoLocationEntity.fromJson(json['southwest'] as Map<String, dynamic>),
      );
  final GeoLocationEntity? northeast;
  final GeoLocationEntity? southwest;
}

class GeoLocationEntity {
  GeoLocationEntity({
    this.lat,
    this.lng,
  });

  factory GeoLocationEntity.fromJson(Map<String, dynamic> json) => GeoLocationEntity(
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
  final num? lat;
  final num? lng;
}

enum GeoLocationType { APPROXIMATE, GEOMETRIC_CENTER, ROOFTOP }

final locationTypeValues = GeoEnumValues({'APPROXIMATE': GeoLocationType.APPROXIMATE, 'GEOMETRIC_CENTER': GeoLocationType.GEOMETRIC_CENTER, 'ROOFTOP': GeoLocationType.ROOFTOP});

class GeoEnumValues<T> {
  GeoEnumValues(this.map);
  Map<String, T> map;
  late Map<T, String> reverseMap;

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
