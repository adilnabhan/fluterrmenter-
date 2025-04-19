// import 'package:mentor_mobile_app/imports_bindings.dart';

// @immutable
// final class LoginRepo {
//   ///* This constructor body for creating singleton widget
//   factory LoginRepo() => _authRepo ??= const LoginRepo._internel();

//   //* This named constructor for create object for this class
//   const LoginRepo._internel();

//   //* This variable for store this class object globally
//   static LoginRepo? _authRepo;

//   ///* A simple methord for send otp
//   Future<String?> sendOtp({
//     required String phone,
//   }) async {
//     try {
//       // String? signature;
//       // if (Platform.isAndroid || Platform.isIOS) {
//       //   signature = await SmartAuth().getAppSignature();
//       // }
//       return await Feggy.async(
//         call: Dio().post<dynamic>(
//           ApiUris.loginSendOtp,
//           data: {
//             'username': '+91$phone',
//             'otp_type': 'login',
//           },
//           //options: Options(headers: {'Content-Type': 'application/json'}),
//         ),
//         onSuccess: (res) {
//           if (res.statusCode != 201) {
//             throw const ApiException.notFound(msg: "Couldn't generate otp");
//           }
//           if (res.data is Map) {
//             if ((res.data as Map).containsKey('otp')) {
//               if ((res.data as Map)['otp'] is String) {
//                 if (((res.data as Map)['otp'] as String).isNotEmpty) {
//                   return (res.data as Map)['otp'] as String;
//                 }
//               }
//             }
//           }
//           return null;
//         },
//         customHandler: (error) {
//           final res = error.response;
//           if (res?.data is Map) {
//             if ((res?.data as Map).containsKey('username')) {
//               if (((res?.data as Map)['username'][0] as String).isNotEmpty) {
//                 return ApiException.notFound(msg: (res?.data as Map)['username'][0] as String);
//               }
//             }
//           }
//           return null;
//         },
//       );
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       throw const ApiException.notFound();
//     }
//   }

//   ///* A simple methord for verify otp
//   Future<LoginEntity> verifyOtp({
//     required String phone,
//     required String otp,
//   }) async {
//     try {
//       final formData = FormData.fromMap({
//         'username': phone,
//         'otp': otp,
//         'otp_type': 'login',
//       });
//       return await Feggy.async(
//         call: Dio().post<dynamic>(
//           ApiUris.verifyOTP,
//           data: formData,
//           options: Options(headers: {'Content-Type': 'application/json'}),
//         ),
//         customHandler: (error) {
//           final res = error.response;
//           if (res?.data is Map) {
//             if ((res?.data as Map).containsKey('error')) {
//               if (((res?.data as Map)['error'][0] as String).isNotEmpty) {
//                 return ApiException.notFound(msg: (res?.data as Map)['error'][0] as String);
//               }
//             } else if ((res?.data as Map).containsKey('is_user_exists')) {
//               return const ApiException.notFound(msg: 'User not found');
//             }
//           }
//           return null;
//         },
//         onSuccess: (res) {
//           write('res verify otp : ${res.data}');
//           if (res.data is Map) {
//             final model = LoginEntity.fromJson((res.data as Map).cast());
//             if ((model.accessToken ?? '').isNotEmpty) {
//               return model;
//             }
//           }
//           throw const ApiException.notFound();
//         },
//       );
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       write('eeeee print tttt : $e');
//       throw const ApiException.notFound();
//     }
//   }

//   ///* A simple methord for send otp
//   Future<bool> logout({
//     required String refreshToken,
//   }) async {
//     try {
//       // String? signature;
//       // if (Platform.isAndroid || Platform.isIOS) {
//       //   signature = await SmartAuth().getAppSignature();
//       // }
//       final formData = FormData.fromMap({
//         'refresh': refreshToken,
//       });
//       return await Feggy.async(
//         call: Dio().post<dynamic>(
//           ApiUris.logout,
//           data: formData,
//           //options: Options(headers: {'Content-Type': 'application/json'}),
//         ),
//         onSuccess: (res) => res.statusCode == 200,
//         customHandler: (error) {
//           final res = error.response;
//           write('res ::: $res');
//           return null;
//         },
//       );
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       throw const ApiException.notFound();
//     }
//   }
// }
