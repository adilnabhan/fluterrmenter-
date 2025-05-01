import 'package:mentor_mobile_app/imports_bindings.dart';

@immutable
final class AuthRepository {
  ///* This constructor body for creating singleton widget
  factory AuthRepository() {
    _instance ??= const AuthRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  const AuthRepository._internal();

  //* This variable for store this class object globally
  static AuthRepository? _instance;

  /*
   @api {POST https://discipl-backend.onrender.com/api/v1/user/send-otp} https://discipl-backend.onrender.com/api/v1/user/send-otp
   @apiName sent_otp
   @apiGroup Auth

   @apiBody {json} body Request payload
   ```json
   {
    "mobile_number": "+917510661748",
    "process": "login",
    "source": "mentor-app-android"
}
   ```

   @apiSuccess {SentOtpEntity} response Success response
   */
  Future<Either<ApiException, SentOtpEntity>> sentOtp({required Map<String, dynamic> body}) async {
    try {
      return await Feggy.async(
        call: Dio().post<dynamic>(ApiUris.sentOtp, data: body),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(SentOtpEntity.fromJson(res.data as Map<String, dynamic>));
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

  /*
   @api {POST https://discipl-backend.onrender.com/api/v1/user/otp/verify} https://discipl-backend.onrender.com/api/v1/user/otp/verify
   @apiName login_with_otp
   @apiGroup Auth

   @apiBody {json} body Request payload
   ```json
   {
    "process": "login",
    "source": "mentor-app-ios",
    "otp_id": "{{AUTHORIZATION_OTP_ID}}",
    "otp": "{{AUTHORIZATION_OTP_CODE}}",
    "mobile_number": "+917510661748"
}
   ```

   @apiSuccess {LoginWithOtpEntity} response Success response
   */
  Future<Either<ApiException, LoginSuccessEntity>> loginWithOtp({required Map<String, dynamic> body}) async {
    try {
      return await Feggy.async(
        call: Dio().post<dynamic>(ApiUris.loginWithOtp, data: body),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(LoginSuccessEntity.fromJson(res.data as Map<String, dynamic>));
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

  /*
   @api {POST https://discipl-backend.onrender.com/api/v1/user/otp/verification/registration} https://discipl-backend.onrender.com/api/v1/user/otp/verification/registration
   @apiName verify_otp
   @apiGroup Auth

   @apiBody {json} body Request payload
   ```json
   {
    "process": "registration",
    "source": "mentor-app-android",
    "otp_id": "{{AUTHORIZATION_OTP_ID}}",
    "otp": "{{AUTHORIZATION_OTP_CODE}}",
    "mobile_number": "+917510661748"
}
   ```

   @apiSuccess {VerifyOtpEntity} response Success response
   */
  Future<Either<ApiException, VerifyOtpEntity>> verifyOtp({required Map<String, dynamic> body}) async {
    try {
      return await Feggy.async(
        call: Dio().post<dynamic>(ApiUris.verifyOtp, data: body),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(VerifyOtpEntity.fromJson(res.data as Map<String, dynamic>));
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

  /*
   @api {POST https://discipl-backend.onrender.com/api/v1/user/onboarding} https://discipl-backend.onrender.com/api/v1/user/onboarding
   @apiName onboarding
   @apiGroup Auth

   @apiBody {json} body Request payload
   ```json
   {
    "email": "kasyap@gamail.com",
    "first_name": "kumari",
    "last_name": "k",
    "otp_id": "{{AUTHORIZATION_OTP_ID}}",
    "mobile_number": "+917510661748",
    "process": "registration",
    "source": "mentor-app-android",
    "user_role": "20",
    "meta":{
        
    }
}
   ```

   @apiSuccess {OnboardingEntity} response Success response
   */
  Future<Either<ApiException, LoginSuccessEntity>> onboarding({required Map<String, dynamic> body}) async {
    try {
      return await Feggy.async(
        call: Dio().post<dynamic>(ApiUris.onboarding, data: body),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(LoginSuccessEntity.fromJson(res.data as Map<String, dynamic>));
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

  /*
   @api {POST https://discipl-backend.onrender.com/api/v1/user/logout} https://discipl-backend.onrender.com/api/v1/user/logout
   @apiName logout
   @apiGroup Auth

   @apiSuccess {LogoutEntity} response Success response
   */
  Future<Either<ApiException, LogoutEntity>> logout() async {
    try {
      return await Feggy.async(
        call: Dio().post<dynamic>(ApiUris.logout, options: Options().token),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(LogoutEntity.fromJson(res.data as Map<String, dynamic>));
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
