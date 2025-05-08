import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/details/details.dart';

@immutable
final class OrganizationListRepository {
  ///* This constructor body for creating singleton widget
  factory OrganizationListRepository() {
    _instance ??= const OrganizationListRepository._internal();
    return _instance!;
  }

  //* This named constructor for create object for this class
  const OrganizationListRepository._internal();

  //* This variable for store this class object globally
  static OrganizationListRepository? _instance;

  Future<Either<ApiException, OrganizationsListEntity>> fetch() async {
    try {
      return await Feggy.async(
        call: Dio().post<dynamic>(ApiUris.createOrg, options: Options(headers: {'X-Platform': platformSource}).token),
        onSuccess: (res) {
          if ([200, 201].contains(res.statusCode)) {
            if (res.data != null && res.data is Map) {
              return right(OrganizationsListEntity.fromJson(res.data as Map<String, dynamic>));
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
