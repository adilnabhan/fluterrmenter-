class GooglePlaceDetailsEntity {
  GooglePlaceDetailsEntity({this.htmlAttributions, this.result, this.status});

  factory GooglePlaceDetailsEntity.fromJson(Map<String, dynamic> json) =>
      GooglePlaceDetailsEntity(
        htmlAttributions:
            json['html_attributions'] == null
                ? []
                : List<dynamic>.from(
                  json['html_attributions'] as Iterable<dynamic>,
                ),
        result:
            json['result'] == null
                ? null
                : GoogleResultEntity.fromJson(
                  json['result'] as Map<String, dynamic>,
                ),
        status: json['status'] as String?,
      );
  final List<dynamic>? htmlAttributions;
  final GoogleResultEntity? result;
  final String? status;
}

class GoogleResultEntity {
  GoogleResultEntity({
    this.addressComponents,
    this.adrAddress,
    this.businessStatus,
    this.formattedAddress,
    this.formattedPhoneNumber,
    this.geometry,
    this.icon,
    this.iconBackgroundColor,
    this.iconMaskBaseUri,
    this.internationalPhoneNumber,
    this.name,
    this.photos,
    this.placeId,
    this.rating,
    this.reference,
    this.reviews,
    this.types,
    this.url,
    this.userRatingsTotal,
    this.utcOffset,
    this.vicinity,
    this.website,
    this.wheelchairAccessibleEntrance,
  });

  factory GoogleResultEntity.fromJson(Map<String, dynamic> json) =>
      GoogleResultEntity(
        addressComponents:
            json['address_components'] == null
                ? []
                : List<GoogleAddressComponentEntity>.from(
                  (json['address_components'] as Iterable<dynamic>).map(
                    (dynamic x) => GoogleAddressComponentEntity.fromJson(
                      x as Map<String, dynamic>,
                    ),
                  ),
                ),
        adrAddress: json['adr_address'] as String?,
        businessStatus: json['business_status'] as String?,
        formattedAddress: json['formatted_address'] as String?,
        formattedPhoneNumber: json['formatted_phone_number'] as String?,
        geometry:
            json['geometry'] == null
                ? null
                : GoogleGeometryEntity.fromJson(
                  json['geometry'] as Map<String, dynamic>,
                ),
        icon: json['icon'] as String?,
        iconBackgroundColor: json['icon_background_color'] as String?,
        iconMaskBaseUri: json['icon_mask_base_uri'] as String?,
        internationalPhoneNumber: json['international_phone_number'] as String?,
        name: json['name'] as String?,
        photos:
            json['photos'] == null
                ? []
                : List<Photo>.from(
                  (json['photos'] as List).map(
                    (x) => Photo.fromJson(x as Map<String, dynamic>),
                  ),
                ),
        placeId: json['place_id'] as String?,
        rating: (json['rating'] as num?)?.toDouble(),
        reference: json['reference'] as String?,
        reviews:
            json['reviews'] == null
                ? []
                : List<GoogleReviewEntity>.from(
                  (json['reviews'] as List).map(
                    (x) =>
                        GoogleReviewEntity.fromJson(x as Map<String, dynamic>),
                  ),
                ),
        types:
            json['types'] == null
                ? []
                : List<String>.from(
                  (json['types'] as List).map((x) => x as String),
                ),
        url: json['url'] as String?,
        userRatingsTotal: json['user_ratings_total'] as int?,
        utcOffset: json['utc_offset'] as int?,
        vicinity: json['vicinity'] as String?,
        website: json['website'] as String?,
        wheelchairAccessibleEntrance:
            json['wheelchair_accessible_entrance'] as bool?,
      );
  final List<GoogleAddressComponentEntity>? addressComponents;
  final String? adrAddress;
  final String? businessStatus;
  final String? formattedAddress;
  final String? formattedPhoneNumber;
  final GoogleGeometryEntity? geometry;
  final String? icon;
  final String? iconBackgroundColor;
  final String? iconMaskBaseUri;
  final String? internationalPhoneNumber;
  final String? name;
  final List<Photo>? photos;
  final String? placeId;
  final double? rating;
  final String? reference;
  final List<GoogleReviewEntity>? reviews;
  final List<String>? types;
  final String? url;
  final int? userRatingsTotal;
  final int? utcOffset;
  final String? vicinity;
  final String? website;
  final bool? wheelchairAccessibleEntrance;
}

class GoogleAddressComponentEntity {
  GoogleAddressComponentEntity({this.longName, this.shortName, this.types});

  factory GoogleAddressComponentEntity.fromJson(Map<String, dynamic> json) =>
      GoogleAddressComponentEntity(
        longName: json['long_name'] as String?,
        shortName: json['short_name'] as String?,
        types:
            json['types'] == null
                ? []
                : List<String>.from(
                  (json['types'] as List<dynamic>).map(
                    (dynamic x) => x as String,
                  ),
                ),
      );
  final String? longName;
  final String? shortName;
  final List<String>? types;
}

class GoogleGeometryEntity {
  GoogleGeometryEntity({this.location, this.viewport});

  factory GoogleGeometryEntity.fromJson(Map<String, dynamic> json) =>
      GoogleGeometryEntity(
        location:
            json['location'] == null
                ? null
                : GoogleLocationEntity.fromJson(
                  json['location'] as Map<String, dynamic>,
                ),
        viewport:
            json['viewport'] == null
                ? null
                : GoogleViewportEntity.fromJson(
                  json['viewport'] as Map<String, dynamic>,
                ),
      );
  final GoogleLocationEntity? location;
  final GoogleViewportEntity? viewport;
}

class GoogleLocationEntity {
  GoogleLocationEntity({this.lat, this.lng});

  factory GoogleLocationEntity.fromJson(Map<String, dynamic> json) =>
      GoogleLocationEntity(
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
  final double? lat;
  final double? lng;
}

class GoogleViewportEntity {
  GoogleViewportEntity({this.northeast, this.southwest});

  factory GoogleViewportEntity.fromJson(Map<String, dynamic> json) =>
      GoogleViewportEntity(
        northeast:
            json['northeast'] == null
                ? null
                : GoogleLocationEntity.fromJson(
                  json['northeast'] as Map<String, dynamic>,
                ),
        southwest:
            json['southwest'] == null
                ? null
                : GoogleLocationEntity.fromJson(
                  json['southwest'] as Map<String, dynamic>,
                ),
      );
  final GoogleLocationEntity? northeast;
  final GoogleLocationEntity? southwest;
}

class Photo {
  Photo({this.height, this.htmlAttributions, this.photoReference, this.width});

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
    height: json['height'] as int?,
    htmlAttributions:
        json['html_attributions'] == null
            ? []
            : List<String>.from(
              (json['html_attributions'] as List<dynamic>).map(
                (dynamic x) => x as String,
              ),
            ),
    photoReference: json['photo_reference'] as String?,
    width: json['width'] as int?,
  );
  final int? height;
  final List<String>? htmlAttributions;
  final String? photoReference;

  final int? width;
}

class GoogleReviewEntity {
  GoogleReviewEntity({
    this.authorName,
    this.authorUrl,
    this.language,
    this.originalLanguage,
    this.profilePhotoUrl,
    this.rating,
    this.relativeTimeDescription,
    this.text,
    this.time,
    this.translated,
  });

  factory GoogleReviewEntity.fromJson(Map<String, dynamic> json) =>
      GoogleReviewEntity(
        authorName: json['author_name'] as String?,
        authorUrl: json['author_url'] as String?,
        language: json['language'] as String?,
        originalLanguage: json['original_language'] as String?,
        profilePhotoUrl: json['profile_photo_url'] as String?,
        rating: json['rating'] as int?,
        relativeTimeDescription: json['relative_time_description'] as String?,
        text: json['text'] as String?,
        time: json['time'] as int?,
        translated: json['translated'] as bool?,
      );
  final String? authorName;
  final String? authorUrl;
  final String? language;
  final String? originalLanguage;
  final String? profilePhotoUrl;
  final int? rating;
  final String? relativeTimeDescription;
  final String? text;
  final int? time;
  final bool? translated;
}
