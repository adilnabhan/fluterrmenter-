import 'package:mentor_mobile_app/imports_bindings.dart';

@immutable
final class GymCreationRepository {
  ///* This constructor body for creating singleton widget
  factory GymCreationRepository() {
    _instance ??= const GymCreationRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  const GymCreationRepository._internal();

  //* This variable for store this class object globally
  static GymCreationRepository? _instance;

  Future<Either<ApiException, void>> create({required FormData body}) async {
    try {
      return await Feggy.async(
        call: Dio().post<dynamic>(ApiUris.createOrg, data: body, options: Options(headers: {'X-Platform': platformSource}).token),
        onSuccess: (res) {
          if ([200, 201].contains(res.statusCode)) {
            // if (res.data != null && res.data is Map) {
            //   return right(LoginSuccessEntity.fromJson(res.data as Map<String, dynamic>));
            // }
            return right(null);
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (e) {
      return left(const ApiException.unknown());
    }
  }
}
