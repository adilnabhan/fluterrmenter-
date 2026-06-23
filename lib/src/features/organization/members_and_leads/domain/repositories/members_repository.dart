import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';


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

  Future<Either<ApiException, MembersListingModel>> membersListing({
    required Map<String, dynamic> queryParameters,
    String? nextUrl,
  }) async {
    try {
      return await Feggy.async(
        call: DioClient().dio.get<dynamic>(
          nextUrl ?? ApiUris.membersListing,
          queryParameters: queryParameters,
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(
                MembersListingModel.fromJson(res.data as Map<String, dynamic>),
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

  // Future<Either<ApiException, MemberDetailsModel>> createOrUpdateMember({
  //   required int? memberId,
  //   required dynamic body,
  // }) async {
  //   try {
  //     return await Feggy.async(
  //       call: switch (memberId == null) {
  //         true => Dio().post<dynamic>(
  //           ApiUris.createMember,
  //           data: body,
  //           options: Options(headers: {'X-Platform': platformSource}).token,
  //         ),
  //         false => Dio().patch<dynamic>(
  //           ApiUris.updateMember(memberId!),
  //           data: body,
  //           options: Options(headers: {'X-Platform': platformSource}).token,
  //         ),
  //       },
  //       onSuccess: (res) {
  //         if (res.statusCode == 200 || res.statusCode == 201) {
  //           if (res.data != null && res.data is Map) {
  //             return right(
  //               MemberDetailsModel.fromJson(res.data as Map<String, dynamic>),
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

  Future<Either<ApiException, MemberDetailsModel>> createOrUpdateMember({
    required int? memberId,
    required dynamic body,
  }) async {
    try {
      final bool isCreate = memberId == null;
      final response = await DioClient().dio.request<dynamic>(
        isCreate ? ApiUris.createMember : ApiUris.updateMember(memberId),
        data: body,
        options:
            Options(
              method: isCreate ? 'POST' : 'PATCH',
              headers: {
                'X-Platform': platformSource,
                'Content-Type': 'application/json',
              },
            ),
      );

      print(' status code is--${response.statusCode}');
      final statusCode = response.statusCode ?? 0;
      if ((statusCode == 200 || statusCode == 201) &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        try {
          final model = MemberDetailsModel.fromJson(
            response.data as Map<String, dynamic>,
          );
          return right(model);
        } catch (e) {
          return left(
            ApiException.unknown(
              msg: 'Failed to parse member details: ${e.toString()}',
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
      print('rtkejs---$e');
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

  Future<Either<ApiException, MemberDetailsModel>> memberDetails({
    required int id,
  }) async {
    try {
      return await Feggy.async(
        call: DioClient().dio.get<dynamic>(
          ApiUris.memberDetails(id),
          options: Options(headers: {'X-Platform': platformSource}),
        ),
        onSuccess: (res) {
          if (res.statusCode == 200) {
            if (res.data != null && res.data is Map) {
              return right(
                MemberDetailsModel.fromJson(res.data as Map<String, dynamic>),
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
