import 'package:mentor_mobile_app/imports_bindings.dart';

@immutable
final class OrganizationListAndDetailsRepository {
  ///* This constructor body for creating singleton widget
  factory OrganizationListAndDetailsRepository() {
    _instance ??= const OrganizationListAndDetailsRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  const OrganizationListAndDetailsRepository._internal();

  //* This variable for store this class object globally
  static OrganizationListAndDetailsRepository? _instance;

  Future<Either<ApiException, OrganizationsListModel>> fetch() async {
    try {
      return await Feggy.async(
        call: Dio().get<dynamic>(ApiUris.listOrganizations, options: Options(headers: {'X-Platform': platformSource}).token),
        onSuccess: (res) {
          if ([200, 201].contains(res.statusCode)) {
            if (res.data != null && res.data is Map) {
              return right(OrganizationsListModel.fromJson(res.data as Map<String, dynamic>));
            }
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

  Future<Either<ApiException, OrganizationDetailsModel>> fetchDetails({required int orgId}) async {
    try {
      return await Feggy.async(
        call: Dio().get<dynamic>(ApiUris.orgDetails(orgId), options: Options(headers: {'X-Platform': platformSource}).token),
        onSuccess: (res) {
          if ([200, 201].contains(res.statusCode)) {
            if (res.data != null && res.data is Map) {
              return right(OrganizationDetailsModel.fromJson(res.data as Map<String, dynamic>));
            }
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

  Future<Either<ApiException, OrganizationHomeDataModel>> fetchHomeData({required int orgId}) async {
    try {
      return await Feggy.async(
        call: Dio().get<dynamic>(ApiUris.fetchHomeData(orgId), options: Options(headers: {'X-Platform': platformSource}).token),
        onSuccess: (res) {
          if ([200, 201].contains(res.statusCode)) {
            if (res.data != null && res.data is Map) {
              return right(OrganizationHomeDataModel.fromJson(res.data as Map<String, dynamic>));
            }
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
}
