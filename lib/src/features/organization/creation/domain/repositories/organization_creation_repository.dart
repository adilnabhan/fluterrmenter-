import 'package:dio/dio.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

@immutable
final class OrganizationCreationRepository {
  ///* This constructor body for creating singleton widget
  factory OrganizationCreationRepository() {
    _instance ??= const OrganizationCreationRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  const OrganizationCreationRepository._internal();

  //* This variable for store this class object globally
  static OrganizationCreationRepository? _instance;

  // Future<Either<ApiException, void>> create({required FormData body}) async {
  //   try {
  //     return await Feggy.async(
  //       call: Dio().post<dynamic>(ApiUris.createOrg, data: body, options: Options(headers: {'X-Platform': platformSource}).token),
  //       onSuccess: (res) {
  //         if ([200, 201].contains(res.statusCode)) {
  //           // if (res.data != null && res.data is Map) {
  //           //   return right(LoginSuccessModel.fromJson(res.data as Map<String, dynamic>));
  //           // }
  //           return right(null);
  //         }
  //         return left(const ApiException.unknown());
  //       },
  //     );
  //   } on ApiException catch (e) {
  //     return left(e);
  //   } catch (e) {
  //     return left(const ApiException.unknown());
  //   }
  // }

  Future<Either<ApiException, dynamic>> create({required FormData body}) async {
    try {
      final dio = Dio();
      final response = await dio.post<dynamic>(
        ApiUris.createOrg,
        data: body,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      final statusCode = response.statusCode ?? 0;

      if ((statusCode == 200 || statusCode == 201) &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        // If backend returns a message or object
        return right(response.data);
      }
      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioError catch (e) {
      // ✅ Handle API errors (bad request, validation, etc.)
      print('error is dio');
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          return left(ApiException.unknown(msg: data.toString()));
        }
      }

      return left(
        ApiException.unknown(
          msg: e.message ?? 'Something went wrong during request.',
        ),
      );
    } catch (e) {
      return left(
        ApiException.unknown(msg: 'Unexpected error: ${e.toString()}'),
      );
    }
  }
}
