class GoogleAutoCompleteEntity {
  GoogleAutoCompleteEntity({
    this.predictions,
    this.status,
  });

  factory GoogleAutoCompleteEntity.fromJson(Map<String, dynamic> json) => GoogleAutoCompleteEntity(
        predictions: json['predictions'] == null ? [] : List<GooglePredictionEntity>.from((json['predictions'] as List<dynamic>).map((dynamic x) => GooglePredictionEntity.fromJson(x as Map<String, dynamic>))),
        status: json['status'] as String?,
      );
  final List<GooglePredictionEntity>? predictions;
  final String? status;
}

class GooglePredictionEntity {
  GooglePredictionEntity({
    this.description,
    this.matchedSubstrings,
    this.placeId,
    this.reference,
    this.structuredFormatting,
    this.terms,
    this.types,
  });

  factory GooglePredictionEntity.fromJson(Map<String, dynamic> json) => GooglePredictionEntity(
        description: json['description'] as String?,
        matchedSubstrings: json['matched_substrings'] == null ? [] : List<GoogleMatchedSubstringEntity>.from((json['matched_substrings'] as List<dynamic>).map((dynamic x) => GoogleMatchedSubstringEntity.fromJson(x as Map<String, dynamic>))),
        placeId: json['place_id'] as String?,
        reference: json['reference'] as String?,
        structuredFormatting: json['structured_formatting'] == null ? null : GoogleStructuredFormattingEntity.fromJson(json['structured_formatting'] as Map<String, dynamic>),
        terms: json['terms'] == null ? [] : List<GoogleTermEntity>.from((json['terms'] as List<dynamic>).map((dynamic x) => GoogleTermEntity.fromJson(x as Map<String, dynamic>))),
        types: json['types'] == null ? [] : List<String>.from((json['types'] as List<dynamic>).map((dynamic x) => x as String)),
      );
  final String? description;
  final List<GoogleMatchedSubstringEntity>? matchedSubstrings;
  final String? placeId;
  final String? reference;
  final GoogleStructuredFormattingEntity? structuredFormatting;
  final List<GoogleTermEntity>? terms;
  final List<String>? types;
}

class GoogleMatchedSubstringEntity {
  GoogleMatchedSubstringEntity({
    this.length,
    this.offset,
  });

  factory GoogleMatchedSubstringEntity.fromJson(Map<String, dynamic> json) => GoogleMatchedSubstringEntity(
        length: json['length'] as int?,
        offset: json['offset'] as int?,
      );
  final int? length;
  final int? offset;
}

class GoogleStructuredFormattingEntity {
  GoogleStructuredFormattingEntity({
    this.mainText,
    this.mainTextMatchedSubstrings,
    this.secondaryText,
  });

  factory GoogleStructuredFormattingEntity.fromJson(Map<String, dynamic> json) => GoogleStructuredFormattingEntity(
        mainText: json['main_text'] as String?,
        mainTextMatchedSubstrings:
            json['main_text_matched_substrings'] == null ? [] : List<GoogleMatchedSubstringEntity>.from((json['main_text_matched_substrings'] as List<dynamic>).map((dynamic x) => GoogleMatchedSubstringEntity.fromJson(x as Map<String, dynamic>))),
        secondaryText: json['secondary_text'] as String?,
      );
  final String? mainText;
  final List<GoogleMatchedSubstringEntity>? mainTextMatchedSubstrings;
  final String? secondaryText;
}

class GoogleTermEntity {
  GoogleTermEntity({
    this.offset,
    this.value,
  });

  factory GoogleTermEntity.fromJson(Map<String, dynamic> json) => GoogleTermEntity(
        offset: json['offset'] as int?,
        value: json['value'] as String?,
      );
  final int? offset;
  final String? value;
}
