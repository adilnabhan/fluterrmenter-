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

  Future<Either<ApiException, LeadsListingModel>> leadsListing({required Map<String, dynamic> queryParameters, String? nextUrl}) async {
    try {
      return await Feggy.async(
        call: Dio().get<dynamic>(nextUrl ?? ApiUris.leadsListing, queryParameters: queryParameters, options: Options(headers: {'X-Platform': platformSource}).token),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(LeadsListingModel.fromJson(res.data as Map<String, dynamic>));
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

  Future<Either<ApiException, CreateOrUpdateLeadModel>> createOrupdateLead({required int? leadId, required dynamic body}) async {
    try {
      return await Feggy.async(
        call: Dio().patch<dynamic>(
          switch (leadId == null) {
            true => ApiUris.createLead,
            false => ApiUris.updateLead(leadId!),
          },
          data: body,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(CreateOrUpdateLeadModel.fromJson(res.data as Map<String, dynamic>));
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

  /// @api {GET https://discipl-backend.onrender.com/api/v1/mentor/trainers/12} https://discipl-backend.onrender.com/api/v1/mentor/trainers/12
  /// @apiName lead_details
  /// @apiGroup Leads

  /// @apiSuccess {LeadDetailsModel} response Success response

  Future<Either<ApiException, LeadDetailsModel>> leadDetails({required int id}) async {
    try {
      return await Feggy.async(
        call: Dio().get<dynamic>(ApiUris.leadDetails(id), options: Options(headers: {'X-Platform': platformSource}).token),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(LeadDetailsModel.fromJson(res.data as Map<String, dynamic>));
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
