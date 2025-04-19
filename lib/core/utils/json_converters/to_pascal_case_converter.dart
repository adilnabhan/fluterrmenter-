import 'package:mentor_mobile_app/imports_bindings.dart';

class ToPascalCaseConverter implements JsonConverter<String?, String?> {
  const ToPascalCaseConverter();

  @override
  String? fromJson(String? json) {
    if (json == null) return null;
    return json.pascalCase;
  }

  @override
  String? toJson(String? object) => object;
}
