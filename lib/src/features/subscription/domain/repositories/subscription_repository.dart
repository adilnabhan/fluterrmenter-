import 'package:dio/dio.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

@immutable
final class SubscriptionRepository {
  ///* This constructor body for creating singleton widget
  factory SubscriptionRepository() {
    _instance ??= const SubscriptionRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  const SubscriptionRepository._internal();

  //* This variable for store this class object globally
  static SubscriptionRepository? _instance;

  /// @api {GET https://discipl-backend.onrender.com/api/v1/subscription/discipl-subscription-plans} https://discipl-backend.onrender.com/api/v1/subscription/discipl-subscription-plans
  /// @apiName plans
  /// @apiGroup Subscription

  /// @apiSuccess {PlansModel} response Success response

  Future<Either<ApiException, PlansModel>> plans() async {
    try {
      return await Feggy.async(
        call: Dio().get<dynamic>(
          ApiUris.plans,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(
                PlansModel.fromJson(res.data as Map<String, dynamic>),
              );
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

  /// @api {POST https://discipl-backend.onrender.com/api/v1/subscription/create-order} https://discipl-backend.onrender.com/api/v1/subscription/create-order
  /// @apiName initiate_razorpay_payment
  /// @apiGroup Subscription

  /// @apiBody {json} body Request payload
  /// ```json
  /// {
  ///   "plan_id": "9914fb82-03c8-4fde-af98-329115098cd3",
  ///   "organization_id": 4
  /// }
  ///
  /// ```

  /// @apiSuccess {InitiateRazorpayPaymentModel} response Success response

  // Future<Either<ApiException, InitiateRazorpayPaymentModel>>
  // initiateRazorpayPayment({required Map<String, dynamic> body}) async {
  //   try {
  //     return await Feggy.async(
  //       call: Dio().post<dynamic>(
  //         ApiUris.initiateRazorpayPayment,
  //         data: body,
  //         options: Options(headers: {'X-Platform': platformSource}).token,
  //       ),
  //       onSuccess: (res) {
  //         if ([200, 201].contains(res.statusCode)) {
  //           if (res.data != null && res.data is Map) {
  //             return right(
  //               InitiateRazorpayPaymentModel.fromJson(
  //                 res.data as Map<String, dynamic>,
  //               ),
  //             );
  //           }
  //         }
  //         return left(const ApiException.unknown());
  //       },
  //     );
  //   } on ApiException {
  //     return left(const ApiException.unknown());
  //   } catch (e) {
  //     return left(const ApiException.unknown());
  //   }
  // }

  Future<Either<ApiException, InitiateRazorpayPaymentModel>>
  initiateRazorpayPayment({required Map<String, dynamic> body}) async {
    try {
      final dio = Dio();
      final response = await dio.post<dynamic>(
        ApiUris.initiateRazorpayPayment,
        data: body,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      final statusCode = response.statusCode ?? 0;

      if ((statusCode == 200 || statusCode == 201) &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        return right(
          InitiateRazorpayPaymentModel.fromJson(
            response.data as Map<String, dynamic>,
          ),
        );
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioError catch (e) {
      // API errors (400/404/500 etc.)
      if (e.response?.data != null) {
        final data = e.response!.data;
        print('the error is--${e.response?.statusCode}---${data.toString()}');
        if (data is Map && data.isNotEmpty) {
          return left(ApiException.unknown(msg: data.toString()));
        }
      }

      return left(
        ApiException.unknown(
          msg: e.message ?? 'Something went wrong during payment request.',
        ),
      );
    } catch (e) {
      return left(
        ApiException.unknown(msg: 'Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// @api {POST https://8f93-2405-201-f017-f0f4-f8a1-6b2-b385-a098.ngrok-free.app/api/v1/subscription/webhook} https://8f93-2405-201-f017-f0f4-f8a1-6b2-b385-a098.ngrok-free.app/api/v1/subscription/webhook
  /// @apiName webhook
  /// @apiGroup Subscription

  /// @apiBody {json} body Request payload
  /// ```json
  /// {
  ///   "event": "payment.captured",
  ///   "payload": {
  ///     "payment": {
  ///       "entity": {
  ///         "id": "pay_QOokMWodDeXvxs",
  ///         "order_id": "order_QPclREFICc6gWh",
  ///         "amount": 800.00
  ///       }
  ///     }
  ///   }
  /// }
  ///
  /// ```

  /// @apiSuccess {void} response Success response

  Future<Either<ApiException, void>> webhook({
    required Map<String, dynamic> body,
  }) async {
    try {
      return await Feggy.async(
        call: Dio().post<dynamic>(
          ApiUris.webhook,
          options: Options().token,
          data: body,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            return right(null);
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
