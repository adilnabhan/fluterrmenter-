import 'package:dio/dio.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/domain/models/payment_history/payment_history_model.dart';
import 'package:mentor_mobile_app/src/features/organization/members_and_leads/domain/models/upcoming_renewals/upcoming_renewal_model.dart';
import 'package:mentor_mobile_app/src/features/organization/membership/domain/models/package_group_model.dart';

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
  ///
  // Future<Either<ApiException, MembershipPackageModel>> create({
  //   required Map<String, dynamic> body,
  // }) async {
  //   try {
  //     return await Feggy.async(
  //       call: _dio.post<dynamic>(
  //         ApiUris.createMembershipPackage,
  //         data: body,
  //         options: Options(headers: {'X-Platform': platformSource}).token,
  //       ),
  //       onSuccess:
  //           (res) => _handleResponse(res, MembershipPackageModel.fromJson),
  //     );
  //   } catch (e) {
  //     return left(ApiException.unknown(msg: e.toString()));
  //   }
  // }

  Future<Either<ApiException, MembershipPackageModel>> create({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiUris.createMembershipPackage,
        data: body,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      final statusCode = response.statusCode ?? 0;

      if ((statusCode == 200 || statusCode == 201) &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        try {
          final model = MembershipPackageModel.fromJson(
            response.data as Map<String, dynamic>,
          );
          return right(model);
        } catch (e) {
          return left(
            ApiException.unknown(
              msg: 'Failed to parse response: ${e.toString()}',
            ),
          );
        }
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      print('errr iss--$e');
      // API level errors (validation, bad request, etc.)
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

  /// Fetch next page of membership packages using next URL
  Future<Either<ApiException, ListMembershipPackagesModel>> listByUrl({
    required String url,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          url,
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

  /// List Package Groups
  Future<Either<ApiException, List<MembershipPackageGroupModel>>> listPackageGroups({
    required String orgId,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiUris.packageGroups,
        queryParameters: {'organization_id': orgId},
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 && response.data != null) {
        final dynamic data = response.data;
        final rawList = data is List
            ? data
            : (data is Map && data['results'] != null)
                ? data['results'] as List
                : [];
        final groups = rawList
            .map((e) =>
                MembershipPackageGroupModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return right(groups);
      }
      return left(
          const ApiException.unknown(msg: 'Failed to load package groups'));
    } catch (e) {
      return left(ApiException.unknown(msg: e.toString()));
    }
  }

  /// Create Package Group
  Future<Either<ApiException, MembershipPackageGroupModel>> createPackageGroup({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiUris.packageGroups,
        data: body,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      final statusCode = response.statusCode ?? 0;
      if ((statusCode == 200 || statusCode == 201) &&
          response.data is Map<String, dynamic>) {
        return right(MembershipPackageGroupModel.fromJson(
            response.data as Map<String, dynamic>));
      }
      return left(
          const ApiException.unknown(msg: 'Failed to create package group'));
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        return left(ApiException.unknown(msg: e.response!.data.toString()));
      }
      return left(
          ApiException.unknown(msg: e.message ?? 'Unknown network error'));
    } catch (e) {
      return left(ApiException.unknown(msg: e.toString()));
    }
  }

  /// Delete Package Group
  Future<Either<ApiException, void>> deletePackageGroup({
    required int id,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        ApiUris.packageGroupDetail(id),
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 204) {
        return right(null);
      }
      return left(
          const ApiException.unknown(msg: 'Failed to delete package group'));
    } catch (e) {
      return left(ApiException.unknown(msg: e.toString()));
    }
  }

  /// Get Grouped Membership Packages
  Future<Either<ApiException, GroupedMembershipPackagesModel>>
      getGroupedMembershipPackages({
    required String orgId,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiUris.groupedMembershipPackages,
        queryParameters: {'organization_id': orgId},
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic>) {
        return right(GroupedMembershipPackagesModel.fromJson(
            response.data as Map<String, dynamic>));
      }
      return left(
          const ApiException.unknown(msg: 'Failed to load grouped packages'));
    } catch (e) {
      return left(ApiException.unknown(msg: e.toString()));
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
  // Future<Either<ApiException, void>> update({
  //   required int id,
  //   required Map<String, dynamic> body,
  // }) async {
  //   try {
  //     return await Feggy.async(
  //       call: _dio.patch<dynamic>(
  //         ApiUris.updateMembershipPackage(id),
  //         data: body,
  //         options: Options(headers: {'X-Platform': platformSource}).token,
  //       ),
  //       onSuccess: (res) {
  //         if (res.statusCode == 200) return right(null);
  //         return left(const ApiException.unknown());
  //       },
  //     );
  //   } on ApiException {
  //     return left(const ApiException.unknown());
  //   } catch (_) {
  //     return left(const ApiException.unknown());
  //   }
  // }

  Future<Either<ApiException, MembershipPackageModel>> update({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        ApiUris.updateMembershipPackage(id),
        data: body,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      final statusCode = response.statusCode ?? 0;

      // SUCCESS CASE — validate status codes and data type
      if ((statusCode == 200 || statusCode == 201) &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        try {
          final model = MembershipPackageModel.fromJson(
            response.data as Map<String, dynamic>,
          );
          return right(model);
        } catch (e) {
          return left(
            ApiException.unknown(
              msg: 'Failed to parse response: ${e.toString()}',
            ),
          );
        }
      }

      // UNEXPECTED RESPONSE
      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      print('Update API error → $e');

      // API-level validation errors
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

  /// @api {DELETE https://discipl-backend.onrender.com/api/v1/fitnesscenter/membership-plans/2} https://discipl-backend.onrender.com/api/v1/fitnesscenter/membership-plans/2
  /// @apiName delete
  /// @apiGroup Membership
  ///
  /// @apiSuccess {void} response Success response
  // Future<Either<ApiException, void>> delete({required int id}) async {
  //   try {
  //     return await Feggy.async(
  //       call: _dio.delete<dynamic>(
  //         ApiUris.deleteMembershipPackage(id),
  //         options: Options(headers: {'X-Platform': platformSource}).token,
  //       ),
  //       onSuccess: (res) {
  //         if (res.statusCode == 200) return right(null);
  //         return left(const ApiException.unknown());
  //       },
  //     );
  //   } on ApiException {
  //     return left(const ApiException.unknown());
  //   } catch (_) {
  //     return left(const ApiException.unknown());
  //   }
  // }

  Future<Either<ApiException, void>> delete({required int id}) async {
    try {
      final response = await Dio().request<dynamic>(
        ApiUris.deleteMembershipPackage(id),
        options:
            Options(
              method: 'DELETE',
              headers: {
                'X-Platform': platformSource,
                'Content-Type': 'application/json',
              },
            ).token,
      );

      final statusCode = response.statusCode ?? 0;
      print('Delete status code: $statusCode');

      if (statusCode == 200 || statusCode == 204) {
        return right(null);
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      print('Delete error: $e');

      // If backend sends structured error message
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          return left(ApiException.unknown(msg: data.toString()));
        }
      }

      return left(
        ApiException.unknown(
          msg: e.message ?? 'Something went wrong during deletion.',
        ),
      );
    } catch (e) {
      return left(
        ApiException.unknown(msg: 'Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// @api {GET https://discipl-backend.onrender.com/api/v1/fitnesscenter/expiring-memberships}
  /// @apiParamExample {json} Request-Example:
  /// ```json
  /// organization_id=48
  /// ```
  ///
  /// @apiSuccess {ListMembershipPackagesModel} response Success response
  // Future<Either<ApiException, UpComingPayments>> listExpiringMembership({
  //   required Map<String, dynamic> queryParameters,
  // }) async {
  //   try {
  //     return await Feggy.async(
  //       call: _dio.get<dynamic>(
  //         ApiUris.expiringMembershipPackages,
  //         queryParameters: queryParameters,
  //         options: Options(headers: {'X-Platform': platformSource}).token,
  //       ),
  //       onSuccess:
  //           (res) => _handleResponse(res, UpComingPayments.fromJson),
  //     );
  //   } on ApiException {
  //     return left(const ApiException.unknown());
  //   } catch (_) {
  //     return left(const ApiException.unknown());
  //   }
  // }

  Future<Either<ApiException, UpComingPayments>> listExpiringMembership({
    required Map<String, dynamic> queryParameters,
    String? nextUrl,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          nextUrl ?? ApiUris.customerRenewals,
          queryParameters: queryParameters,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          final data = res.data;
          return right(UpComingPayments.fromJson(data as Map<String, dynamic>));
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, UpcomingRenewalResponseModel>> listUpcomingRenewals({
    required Map<String, dynamic> queryParameters,
    String? nextUrl,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          nextUrl ?? ApiUris.customerRenewals,
          queryParameters: queryParameters,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          final data = res.data;
          
          if (data is List<dynamic>) {
            final results = data.map((e) => UpcomingRenewalModel.fromJson(e as Map<String, dynamic>)).toList();
            return right(UpcomingRenewalResponseModel(results: results));
          } else if (data is Map<String, dynamic>) {
            if (data.containsKey('results')) {
              return right(UpcomingRenewalResponseModel.fromJson(data));
            } else if (data.containsKey('data') && data['data'] is List) {
              final resultsList = data['data'] as List<dynamic>;
              final results = resultsList.map((e) => UpcomingRenewalModel.fromJson(e as Map<String, dynamic>)).toList();
              return right(UpcomingRenewalResponseModel(
                count: data['count'] as int?,
                next: data['next'] as String?,
                previous: data['previous'] as String?,
                results: results,
              ));
            } else {
               // Fallback to original parsing if it's some other map structure
               return right(UpcomingRenewalResponseModel.fromJson(data));
            }
          }
          
          return right(UpcomingRenewalResponseModel.fromJson(data as Map<String, dynamic>));
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, PaymentHistory>> listPaymentHistory({
    Map<String, dynamic>? queryParameters,
    String? nextUrl,
    required int orgId,
  }) async {
    try {
      final qParams = <String, dynamic>{
        'organization_id': orgId,
        ...?queryParameters,
      };
      return await Feggy.async(
        call: _dio.get<dynamic>(
          nextUrl ?? ApiUris.paymentHistory,
          queryParameters: nextUrl != null ? null : qParams,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          final data = res.data;
          return right(PaymentHistory.fromJson(data as Map<String, dynamic>));
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }

  /// @api {GET https://discipl-backend.onrender.com/api/v1/fitnesscenter/expiring-memberships}
  /// @apiParamExample {json} Request-Example:
  /// ```json
  /// organization_id=48
  /// ```
  ///
  /// @apiSuccess {ListMembershipPackagesModel} response Success response
  Future<Either<ApiException, BankDetailsModel>> fetchBankDetails({
    required String? id,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.bankDetails(id!),
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
              BankDetailsModel.fromJson(res.data as Map<String, dynamic>),
            );
          }
          if (res.statusCode == 404) {
            return left(ApiException.notFound(msg: res.data.toString()));
          }
          return left(ApiException.unknown(msg: res.data.toString()));
        },
      );
    } on ApiException {
      return left(const ApiException.notFound());
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }

  /// @api {POST https://discipl-backend.onrender.com/api/v1/fitnesscenter/bank-details/} https://discipl-backend.onrender.com/api/v1/fitnesscenter/membership-plans

  /// @apiBody {json} body Request payload
  /// ```json
  // {
  // "account_holder_name": "jisham",
  // "account_number": "42563",
  // "ifsc_code": "CSBK000060",
  // "bank_name": "CSB",
  // "branch_name": "malappuram",
  // "organization_id": 48
  // }
  /// ```
  ///
  /// @apiSuccess {MembershipPackageModel} response Success response
  Future<Either<ApiException, BankDetailsModel>> createBankDetails({
    required Map<String, dynamic> body,
  }) async {
    return await Feggy.async(
      call: _dio.post<dynamic>(
        ApiUris.addBankDetails,
        data: body,
        options:
            Options(
              headers: {'X-Platform': platformSource},
              validateStatus: (_) => true,
            ).token,
      ),
      onSuccess: (res) {
        if (res.statusCode != null &&
            res.statusCode! >= 200 &&
            res.statusCode! < 300) {
          if (res.data != null && res.data is Map<String, dynamic>) {
            return right(
              BankDetailsModel.fromJson(res.data as Map<String, dynamic>),
            );
          } else {
            return left(
              const ApiException.unknown(msg: "Invalid response format"),
            );
          }
        }
        final data = res.data;
        String message = "Something went wrong";

        if (data is Map<String, dynamic> && data.values.isNotEmpty) {
          message = data.values.first.toString();
        } else if (data is String) {
          message = data;
        }

        return left(ApiException.unknown(msg: message));
      },
    );
  }

  /// @api {patch https://discipl-backend.onrender.com/api/v1/fitnesscenter/bank-details/}

  /// @apiBody {json} body Request payload
  /// ```json
  // {
  // "account_holder_name": "jisham",
  // "account_number": "42563",
  // "ifsc_code": "CSBK000060",
  // "bank_name": "CSB",
  // "branch_name": "malappuram",
  // "organization_id": 48
  // }
  /// ```
  ///
  /// @apiSuccess {MembershipPackageModel} response Success respons
  Future<Either<ApiException, void>> updateBankDetails({
    required Map<String, dynamic> body,
    int? detailsId,
  }) async {
    return await Feggy.async(
      call: _dio.patch<dynamic>(
        ApiUris.bankDetails(detailsId.toString()),
        data: body,
        options:
            Options(
              headers: {'X-Platform': platformSource},
              validateStatus: (_) => true,
            ).token,
      ),
      onSuccess: (res) {
        if (res.statusCode != null &&
            res.statusCode! >= 200 &&
            res.statusCode! < 300) {
          return right(null);
        }

        final data = res.data;
        String message = "Something went wrong";
        if (data is Map<String, dynamic> && data.values.isNotEmpty) {
          message = data.values.first.toString();
        } else if (data is String) {
          message = data;
        }
        return left(ApiException.unknown(msg: message));
      },
    );
  }

  /// PATCH /api/v1/fitnesscenter/customer-memberships/{id}/
  /// Updates a customer membership (plan, dates, amount, etc.)
  Future<Either<ApiException, void>> updateCustomerMembership({
    required int customerMembershipId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        ApiUris.updateCustomerMembership(customerMembershipId),
        data: body,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 201) {
        return right(null);
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        String message = 'Access denied: You do not have permission to modify this membership';
        if (data is Map && data.isNotEmpty) {
          message = data.values.first.toString();
        }
        return left(ApiException.unknown(msg: message));
      }

      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          // Extract first meaningful error message
          final firstValue = data.values.first;
          if (firstValue is List && firstValue.isNotEmpty) {
            return left(ApiException.unknown(msg: firstValue.first.toString()));
          }
          return left(ApiException.unknown(msg: firstValue.toString()));
        }
      }

      return left(
        ApiException.unknown(
          msg: e.message ?? 'Something went wrong while updating membership.',
        ),
      );
    } catch (e) {
      return left(
        ApiException.unknown(msg: 'Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// POST /api/v1/fitnesscenter/customer-memberships/{id}/cancel/
  /// Cancels a customer membership
  Future<Either<ApiException, void>> cancelCustomerMembership({
    required int customerMembershipId,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiUris.cancelCustomerMembership(customerMembershipId),
        data: body ?? {},
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 201) {
        return right(null);
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        String message = 'Access denied: You do not have permission to cancel this membership';
        if (data is Map && data.isNotEmpty) {
          message = data.values.first.toString();
        }
        return left(ApiException.unknown(msg: message));
      }

      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          final firstValue = data.values.first;
          if (firstValue is List && firstValue.isNotEmpty) {
            return left(ApiException.unknown(msg: firstValue.first.toString()));
          }
          return left(ApiException.unknown(msg: firstValue.toString()));
        }
      }

      return left(
        ApiException.unknown(
          msg: e.message ?? 'Something went wrong while cancelling membership.',
        ),
      );
    } catch (e) {
      return left(
        ApiException.unknown(msg: 'Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// POST /api/v1/fitnesscenter/customer-memberships/{id}/pause/
  /// Pauses a customer membership
  Future<Either<ApiException, Map<String, dynamic>>> pauseCustomerMembership({
    required int customerMembershipId,
    required int duration,
    required String durationType, // 'days' or 'months'
    String? reason,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiUris.pauseCustomerMembership(customerMembershipId),
        data: {
          'duration': duration,
          'duration_type': durationType,
          if (reason != null && reason.trim().isNotEmpty)
            'reason': reason.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        return right(data);
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          final firstValue = data['message'] ?? data['detail'] ?? data.values.first;
          if (firstValue is List && firstValue.isNotEmpty) {
            return left(ApiException.unknown(msg: firstValue.first.toString()));
          }
          return left(ApiException.unknown(msg: firstValue.toString()));
        }
      }
      return left(
        ApiException.unknown(
          msg: e.message ?? 'Something went wrong while pausing membership.',
        ),
      );
    } catch (e) {
      return left(
        ApiException.unknown(msg: 'Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// POST /api/v1/fitnesscenter/customer-memberships/{id}/resume/
  /// Resumes a paused customer membership
  Future<Either<ApiException, Map<String, dynamic>>> resumeCustomerMembership({
    required int customerMembershipId,
    String? reason,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiUris.resumeCustomerMembership(customerMembershipId),
        data: {
          if (reason != null && reason.trim().isNotEmpty)
            'reason': reason.trim(),
        },
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        return right(data);
      }

      return left(
        ApiException.unknown(
          msg: 'Unexpected response from server. Code: $statusCode',
        ),
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          final firstValue = data['message'] ?? data['detail'] ?? data.values.first;
          if (firstValue is List && firstValue.isNotEmpty) {
            return left(ApiException.unknown(msg: firstValue.first.toString()));
          }
          return left(ApiException.unknown(msg: firstValue.toString()));
        }
      }
      return left(
        ApiException.unknown(
          msg: e.message ?? 'Something went wrong while resuming membership.',
        ),
      );
    } catch (e) {
      return left(
        ApiException.unknown(msg: 'Unexpected error: ${e.toString()}'),
      );
    }
  }
}
