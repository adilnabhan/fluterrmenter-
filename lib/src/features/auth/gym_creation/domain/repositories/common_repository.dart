import 'package:mentor_mobile_app/imports_bindings.dart';

@immutable
final class CommonRepository {
  ///* This constructor body for creating singleton widget
  factory CommonRepository() {
    _instance ??= const CommonRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  const CommonRepository._internal();

  //* This variable for store this class object globally
  static CommonRepository? _instance;

  Future<Either<ApiException, MultiSelectDataEntity>> getCategories({required Map<String, dynamic> params}) async {
    try {
      return await Feggy.async(
        call: Dio().get<dynamic>(ApiUris.categories, queryParameters: params, options: Options(headers: {'X-Platform': platformSource})),
        onSuccess: (res) {
          if ([200, 201].contains(res.statusCode)) {
            if (res.data != null && res.data is Map) {
              return right(MultiSelectDataEntity.fromJson(res.data as Map<String, dynamic>));
            }
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException {
      return left(const ApiException.unknown());
    } catch (e) {
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, MultiSelectDataEntity>> getAmenities({required Map<String, dynamic> params}) async {
    try {
      return await Feggy.async(
        call: Dio().get<dynamic>(ApiUris.amenities, queryParameters: params, options: Options(headers: {'X-Platform': platformSource})),
        onSuccess: (res) {
          if ([200, 201].contains(res.statusCode)) {
            if (res.data != null && res.data is Map) {
              return right(MultiSelectDataEntity.fromJson(res.data as Map<String, dynamic>));
            }
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException {
      return left(const ApiException.unknown());
    } catch (e) {
      return left(const ApiException.unknown());
    }
  }
}
