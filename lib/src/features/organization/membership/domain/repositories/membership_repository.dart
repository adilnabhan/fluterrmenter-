import 'package:dio/dio.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

@immutable
final class MembershipRepository {
  ///* This constructor body for creating singleton widget
  factory MembershipRepository() {
    _instance ??= MembershipRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  MembershipRepository._internal();

  //* This variable for store this class object globally
  static MembershipRepository? _instance;

  final Dio _dio = DioClient().dio;

  /// Helper to parse API responses consistently
  Either<ApiException, T> _handleResponse<T>(
    Response<dynamic> res,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if ([200, 201].contains(res.statusCode)) {
      if (res.data != null && res.data is Map) {
        return right(fromJson(res.data as Map<String, dynamic>));
      }
    }
    return left(const ApiException.unknown());
  }

  /// @api {POST https://discipl-backend.onrender.com/api/v1/fitnesscenter/membership-plans} https://discipl-backend.onrender.com/api/v1/fitnesscenter/membership-plans
  /// @apiName create
  /// @apiGroup Membership
  ///
  /// @apiBody {json} body Request payload
  /// ```json
  /// {
  ///     "organization": 4,
  ///     "package_type": "Quarterly Plan",
  ///     "name": "Basic Quarterly Membership",
  ///     "description": "Access to gym facilities, group classes, and showers.",
  ///     "actual_price": "2997.00",
  ///     "offer_price": "2199.00",
  ///     "features": ["Unlimited access", "Group classes", "Locker facility"],
  ///     "is_active": true
  ///   }
  /// ```
  ///
  /// @apiSuccess {MembershipPackageModel} response Success response
  Future<Either<ApiException, MembershipPackageModel>> create({
    required Map<String, dynamic> body,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.post<dynamic>(
          ApiUris.createMembershipPackage,
          data: body,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess:
            (res) => _handleResponse(res, MembershipPackageModel.fromJson),
      );
    } catch (e) {
      return left(ApiException.unknown(msg: e.toString()));
    }
  }

  /// @api {GET https://discipl-backend.onrender.com/api/v1/fitnesscenter/membership-plans} https://discipl-backend.onrender.com/api/v1/fitnesscenter/membership-plans
  /// @apiName list
  /// @apiGroup Membership
  ///
  /// @apiParamExample {json} Request-Example:
  /// ```json
  /// organization_id=4
  /// ```
  ///
  /// @apiSuccess {ListMembershipPackagesModel} response Success response
  Future<Either<ApiException, ListMembershipPackagesModel>> list({
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.listMembershipPackages,
          queryParameters: queryParameters,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess:
            (res) => _handleResponse(res, ListMembershipPackagesModel.fromJson),
      );
    } on ApiException {
      return left(const ApiException.unknown());
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }

  /// @api {PATCH https://discipl-backend.onrender.com/api/v1/fitnesscenter/membership-plans/2} https://discipl-backend.onrender.com/api/v1/fitnesscenter/membership-plans/2
  /// @apiName update
  /// @apiGroup Membership
  ///
  /// @apiBody {json} body Request payload
  /// ```json
  /// {
  ///   "is_active": false
  /// }
  /// ```
  ///
  /// @apiSuccess {void} response Success response
  Future<Either<ApiException, void>> update({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.patch<dynamic>(
          ApiUris.updateMembershipPackage(id),
          data: body,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) return right(null);
          return left(const ApiException.unknown());
        },
      );
    } on ApiException {
      return left(const ApiException.unknown());
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }

  /// @api {DELETE https://discipl-backend.onrender.com/api/v1/fitnesscenter/membership-plans/2} https://discipl-backend.onrender.com/api/v1/fitnesscenter/membership-plans/2
  /// @apiName delete
  /// @apiGroup Membership
  ///
  /// @apiSuccess {void} response Success response
  Future<Either<ApiException, void>> delete({required int id}) async {
    try {
      return await Feggy.async(
        call: _dio.delete<dynamic>(
          ApiUris.deleteMembershipPackage(id),
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) return right(null);
          return left(const ApiException.unknown());
        },
      );
    } on ApiException {
      return left(const ApiException.unknown());
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }
}
