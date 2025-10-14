import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

@immutable
final class OrganizationListAndDetailsRepository {
  OrganizationListAndDetailsRepository() : _dio = DioClient().dio;

  final Dio _dio;

  Future<Either<ApiException, OrganizationsListModel>> fetch() async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.listOrganizations,
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          if ([200, 201].contains(res.statusCode)) {
            if (res.data != null && res.data is Map) {
              return right(
                OrganizationsListModel.fromJson(
                  res.data as Map<String, dynamic>,
                ),
              );
            }
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, OrganizationDetailsModel>> fetchDetails({
    required int orgId,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.orgDetails(orgId),
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          if ([200, 201].contains(res.statusCode)) {
            if (res.data != null && res.data is Map) {
              return right(
                OrganizationDetailsModel.fromJson(
                  res.data as Map<String, dynamic>,
                ),
              );
            }
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, OrganizationDetailsModel>> updateOrgDetails({
    required int orgId,
    dynamic body,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.patch<dynamic>(
          ApiUris.updateOrg(orgId),
          options: Options(headers: {'X-Platform': platformSource}).token,
          data: body,
        ),
        onSuccess: (res) {
          if ([200, 201].contains(res.statusCode)) {
            if (res.data != null && res.data is Map) {
              return right(
                OrganizationDetailsModel.fromJson(
                  res.data as Map<String, dynamic>,
                ),
              );
            }
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, OrganizationDetailsModel>> deletePhoto({
    required int orgId,
    required int photoId,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.delete<dynamic>(
          ApiUris.deletePhoto(orgId, photoId),
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          if ([200, 201].contains(res.statusCode))
            return fetchDetails(orgId: orgId);
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }

  Future<Either<ApiException, OrganizationHomeDataModel>> fetchHomeData({
    required int orgId,
  }) async {
    try {
      return await Feggy.async(
        call: _dio.get<dynamic>(
          ApiUris.fetchHomeData(orgId),
          options: Options(headers: {'X-Platform': platformSource}).token,
        ),
        onSuccess: (res) {
          if ([200, 201].contains(res.statusCode)) {
            if (res.data != null && res.data is Map) {
              return right(
                OrganizationHomeDataModel.fromJson(
                  res.data as Map<String, dynamic>,
                ),
              );
            }
          }
          return left(const ApiException.unknown());
        },
      );
    } on ApiException catch (e) {
      return left(e);
    } catch (_) {
      return left(const ApiException.unknown());
    }
  }
}
