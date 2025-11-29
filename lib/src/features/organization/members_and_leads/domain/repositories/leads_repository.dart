import 'package:mentor_mobile_app/imports_bindings.dart';

@immutable
final class LeadsRepository {
  ///* This constructor body for creating singleton widget
  factory LeadsRepository() {
    _instance ??= const LeadsRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  const LeadsRepository._internal();

  //* This variable for store this class object globally
  static LeadsRepository? _instance;

  /// @api {GET https://discipl-backend.onrender.com/api/v1/fitnesscenter/trainers} https://discipl-backend.onrender.com/api/v1/fitnesscenter/trainers
  /// @apiName leads_listing
  /// @apiGroup Leads

  /// @apiParamExample {json} Request-Example:
  /// ```json
  /// organization_id=4, sort=recent
  /// ```

  /// @apiSuccess {LeadsListingModel} response Success response

  Future<Either<ApiException, LeadsListingModel>> leadsListing({
    required Map<String, dynamic> queryParameters,
    String? nextUrl,
  }) async {
    try {
      return await Feggy.async(
        call: Dio().get<dynamic>(
          nextUrl ?? ApiUris.leadsListing,
          queryParameters: queryParameters,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(
                LeadsListingModel.fromJson(res.data as Map<String, dynamic>),
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

  /// @api {PATCH https://discipl-backend.onrender.com/api/v1/mentor/trainers/12} https://discipl-backend.onrender.com/api/v1/mentor/trainers/12
  /// @apiName update_lead
  /// @apiGroup Leads

  /// @apiBody {json} body Request payload
  /// ```json
  // null
  /// ```

  /// @apiSuccess {UpdateLeadModel} response Success response

  // Future<Either<ApiException, CreateOrUpdateLeadModel>> createOrupdateLead({
  //   required int? leadId,
  //   required dynamic body,
  // }) async {
  //   try {
  //     return await Feggy.async(
  //       call: switch (leadId == null) {
  //         true => Dio().post<dynamic>(
  //           ApiUris.createLead,
  //           data: body,
  //           options: Options(headers: {'X-Platform': platformSource}).token,
  //         ),
  //         false => Dio().patch<dynamic>(
  //           ApiUris.updateLead(leadId!),
  //           data: body,
  //           options: Options(headers: {'X-Platform': platformSource}).token,
  //         ),
  //       },
  //       onSuccess: (res) {
  //         if (res.statusCode == 200 || res.statusCode == 201) {
  //           if (res.data != null && res.data is Map) {
  //             return right(
  //               CreateOrUpdateLeadModel.fromJson(
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

  Future<Either<ApiException, CreateOrUpdateLeadModel>> createOrupdateLead({
    required int? leadId,
    required dynamic body,
  }) async {
    try {
      final response =
          leadId == null
              ? await Dio().post<dynamic>(
                ApiUris.createLead,
                data: body,
                options: Options(headers: {'X-Platform': platformSource}).token,
              )
              : await Dio().patch<dynamic>(
                ApiUris.updateLead(leadId),
                data: body,
                options: Options(headers: {'X-Platform': platformSource}).token,
              );

      final statusCode = response.statusCode ?? 0;

      if ((statusCode == 200 || statusCode == 201) &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        try {
          final model = CreateOrUpdateLeadModel.fromJson(
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
      print('error is---$e');
      print('status code is---${e.response?.statusCode}');
      // API returned structured error
      if (e.response?.data != null) {
        final data = e.response!.data;

        if (data is Map && data.isNotEmpty) {
          // Take first key
          final firstKey = data.keys.first;

          // Take first error message
          final firstMessage = data[firstKey][0];

          return left(ApiException.unknown(msg: firstMessage.toString()));
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

  /// @api {GET https://discipl-backend.onrender.com/api/v1/mentor/trainers/12} https://discipl-backend.onrender.com/api/v1/mentor/trainers/12
  /// @apiName lead_details
  /// @apiGroup Leads

  /// @apiSuccess {LeadDetailsModel} response Success response

  Future<Either<ApiException, LeadDetailsModel>> leadDetails({
    required String id,
  }) async {
    try {
      return await Feggy.async(
        call: Dio().get<dynamic>(
          ApiUris.leadDetails(id),
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(
                LeadDetailsModel.fromJson(res.data as Map<String, dynamic>),
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
}
