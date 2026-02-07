import 'dart:developer' as log;

import 'package:dio/dio.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

@immutable
final class AuthRepository {
  ///* This constructor body for creating singleton widget
  factory AuthRepository() {
    _instance ??= AuthRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  AuthRepository._internal();

  //* This variable for store this class object globally
  static AuthRepository? _instance;

  final Dio _dio = DioClient().dio;

  /*
   @api {POST https://discipl-backend.onrender.com/api/v1/user/send-otp} https://discipl-backend.onrender.com/api/v1/user/send-otp
   @apiName sent_otp
   @apiGroup Auth
   */
  Future<Either<ApiException, SentOtpEntity>> sentOtp({
    required Map<String, dynamic> body,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.sentOtp,
          data: body,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          log.log(res.toString(), name: 'AuthRepository.sentOtp');
          if ([200, 201].contains(res.statusCode) &&
              res.data != null &&
              res.data is Map) {
            return right(
              SentOtpEntity.fromJson(res.data as Map<String, dynamic>),
            );
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      log.log(e.toString(), name: 'AuthRepository.sentOtp');
      return left(e);
    } catch (e) {
      log.log(e.toString(), name: 'AuthRepository.sentOtp');
      return left(const ApiException.unknown());
    }
  }

  /*
   @api {POST https://discipl-backend.onrender.com/api/v1/user/otp/verify} https://discipl-backend.onrender.com/api/v1/user/otp/verify
   @apiName login_with_otp
   @apiGroup Auth
   */
  Future<Either<ApiException, LoginSuccessModel>> loginWithOtp({
    required Map<String, dynamic> body,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.loginWithOtp,
          data: body,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        customHandler: (error) => null,
        onSuccess: (res) {
          if (res.statusCode == 200 && res.data != null && res.data is Map) {
            return right(
              LoginSuccessModel.fromJson(res.data as Map<String, dynamic>),
            );
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

  /*
   @api {POST https://discipl-backend.onrender.com/api/v1/user/otp/verification/registration} https://discipl-backend.onrender.com/api/v1/user/otp/verification/registration
   @apiName verify_otp
   @apiGroup Auth
   */
  Future<Either<ApiException, void>> verifyOtp({
    required Map<String, dynamic> body,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.verifyOtp,
          data: body,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200 && res.data != null && res.data is Map) {
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

  /*
   @api {POST https://discipl-backend.onrender.com/api/v1/user/onboarding} https://discipl-backend.onrender.com/api/v1/user/onboarding
   @apiName onboarding
   @apiGroup Auth
   */
  // Future<Either<ApiException, LoginSuccessModel>> onboarding({
  //   required Map<String, dynamic> body,
  // }) async {
  //   try {
  //     return await Feggy.async(
  //       call: _dio.post<dynamic>(
  //         ApiUris.onboarding,
  //         data: body,
  //         options: Options(headers: {'X-Platform': platformSource}),
  //       ),
  //       onSuccess: (res) {
  //         if ([200, 201].contains(res.statusCode) &&
  //             res.data != null &&
  //             res.data is Map) {
  //           return right(
  //             LoginSuccessModel.fromJson(res.data as Map<String, dynamic>),
  //           );
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

  Future<Either<ApiException, LoginSuccessModel>> onboarding({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiUris.onboarding,
        data: body,
        options: Options(headers: {'X-Platform': platformSource}),
      );

      // ✅ Safely check status code
      final statusCode = response.statusCode ?? 0;

      if ((statusCode == 200 || statusCode == 201) &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        return right(
          LoginSuccessModel.fromJson(response.data as Map<String, dynamic>),
        );
      }

      // ❌ Handle unexpected non-success response
      return left(
        ApiException.unknown(msg: 'Unexpected response from server.'),
      );
    } on DioError catch (e) {
      // ✅ Extract message from backend error
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          // Example: {"email": ["This email is already in used for default."]}
          final firstKey = data.keys.first;
          // final message = (data[firstKey] is List && data[firstKey].isNotEmpty)
          //     ? data[firstKey][0].toString()
          //     : data[firstKey].toString();
          return left(ApiException.unknown(msg: data.toString()));
        }
      }

      return left(
        ApiException.unknown(msg: e.message ?? 'Something went wrong.'),
      );
    } catch (e) {
      return left(const ApiException.unknown());
    }
  }

  /*
   @api {POST https://discipl-backend.onrender.com/api/v1/user/logout} https://discipl-backend.onrender.com/api/v1/user/logout
   @apiName logout
   @apiGroup Auth
   */
  Future<Either<ApiException, void>> logout() async {
    try {
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.logout,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200 && res.data != null && res.data is Map) {
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

  Future<Either<ApiException, LoginSuccessModel>> onboardingUpdate({
    required Map<String, dynamic> body,
    required int? id,
  }) async {
    return await Feggy.async(
      call: _dio.patch<dynamic>(
        ApiUris.onboardingUpdate(id!),
        data: body,

        options:
            Options(
              validateStatus: (_) => true,
              headers: {'X-Platform': platformSource},
            ).token,
      ),
      onSuccess: (res) {
        if (res.statusCode != null &&
            res.statusCode! >= 200 &&
            res.statusCode! < 300) {
          return right(
            LoginSuccessModel.fromJson(res.data as Map<String, dynamic>),
          );
        }

        final data = res.data;
        String message = "Something went wrong";
        if (data is Map<String, dynamic> && data.values.isNotEmpty) {
          message = data.values.first.toString();
          print('errro---${data.values.first.toString()}');
        } else if (data is String) {
          message = data;
        }
        return left(ApiException.unknown(msg: message));
      },
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> refreshToken(
    String refreshToken,
  ) async {
    try {
      print('refesh tojken is--$refreshToken');
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.tokenRefresh,
          data: {"refresh_token": refreshToken},
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200 && res.data is Map) {
            return right(res.data as Map<String, dynamic>);
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }
}
