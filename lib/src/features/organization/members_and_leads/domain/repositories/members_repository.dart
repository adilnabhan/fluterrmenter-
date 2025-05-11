import 'package:mentor_mobile_app/imports_bindings.dart';

@immutable
final class MembersRepository {
  ///* This constructor body for creating singleton widget
  factory MembersRepository() {
    _instance ??= const MembersRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  const MembersRepository._internal();

  //* This variable for store this class object globally
  static MembersRepository? _instance;

  /// @api {GET https://discipl-backend.onrender.com/api/v1/fitnesscenter/customers} https://discipl-backend.onrender.com/api/v1/fitnesscenter/customers
  /// @apiName members_listing
  /// @apiGroup Members

  /// @apiParamExample {json} Request-Example:
  /// ```json
  /// status=active, sort=recent, organization_id=4
  /// ```

  /// @apiSuccess {MembersListingModel} response Success response

  Future<Either<ApiException, MembersListingModel>> membersListing({required Map<String, dynamic> queryParameters, String? nextUrl}) async {
    try {
      return await Feggy.async(
        call: Dio().get<dynamic>(nextUrl ?? ApiUris.membersListing, queryParameters: queryParameters, options: Options(headers: {'X-Platform': platformSource}).token),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(MembersListingModel.fromJson(res.data as Map<String, dynamic>));
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

  /// @api {POST https://discipl-backend.onrender.com/api/v1/customer/manage/create} https://discipl-backend.onrender.com/api/v1/customer/manage/create
  /// @apiName create_member
  /// @apiGroup Members

  /// @apiBody {json} body Request payload
  /// ```json
  /// {
  ///   "first_name": "Ravi",
  ///   "last_name": "Sharma",
  ///   "mobile_number": "+919812345678",
  ///   "email": "ravi.sharma@example.com",
  ///   "date_of_birth": "1988-05-15",
  ///   "gender": "male",
  ///   "blood_group": "B+",
  ///   "user_role": 45,
  ///   "organization_id": 4,
  ///   "emergency_contact_name": "Neha Sharma",
  ///   "emergency_contact_number": "+919876543210",
  ///   "height": 180.00,
  ///   "weight": 75.50,
  ///   "profession": "Doctor",
  ///   "membership_plan_id": 2,
  ///   "profile_picture": ""
  /// }
  ///
  /// ```

  /// @apiSuccess {CreateMemberModel} response Success response

  Future<Either<ApiException, MemberDetailsModel>> createOrUpdateMember({required int? memberId, required Map<String, dynamic> body}) async {
    try {
      return await Feggy.async(
        call: Dio().post<dynamic>(
          switch (memberId == null) {
            true => ApiUris.createMember,
            false => ApiUris.updateMember(memberId!),
          },
          data: body,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(MemberDetailsModel.fromJson(res.data as Map<String, dynamic>));
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

  /// @api {PATCH https://discipl-backend.onrender.com/api/v1/customer/manage/1/update} https://discipl-backend.onrender.com/api/v1/customer/manage/1/update
  /// @apiName update_member
  /// @apiGroup Members

  /// @apiBody {json} body Request payload
  /// ```json
  /// {
  ///   "first_name": "Ravi",
  ///   "last_name": "Sharma",
  ///   "mobile_number": "+919812345678",
  ///   "email": "ravi.sharma@example.com",
  ///   "date_of_birth": "1988-05-15",
  ///   "gender": "male",
  ///   "blood_group": "B+",
  ///   "user_role": 45,
  ///   "organization_id": 4,
  ///   "emergency_contact_name": "Neha Sharma",
  ///   "emergency_contact_number": "+919876543210",
  ///   "height": 180.00,
  ///   "weight": 78.0,
  ///   "profession": "Surgeon",
  ///   "membership_plan_id": 2,
  ///   "profile_picture": ""
  /// }
  ///
  /// ```

  /// @apiSuccess {UpdateMemberModel} response Success response

  Future<Either<ApiException, MemberDetailsModel>> memberDetails({required int id}) async {
    try {
      return await Feggy.async(
        call: Dio().get<dynamic>(ApiUris.memberDetails(id), options: Options(headers: {'X-Platform': platformSource}).token),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(MemberDetailsModel.fromJson(res.data as Map<String, dynamic>));
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
