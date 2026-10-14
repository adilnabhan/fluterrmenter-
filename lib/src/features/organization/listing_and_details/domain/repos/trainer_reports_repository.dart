import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/organization/listing_and_details/domain/model/trainer_reports_model.dart';

@immutable
final class TrainerReportsRepository {
  TrainerReportsRepository() : _dio = DioClient().dio;

  final Dio _dio;

  Future<Either<ApiException, TrainerReportsResponseModel>> fetchTrainerReports({
    required int organizationId,
    int? year,
    int? month,
  }) async {
    try {
      final uri = ApiUris.fitnessCenterTrainerReports(
        organizationId: organizationId,
        year: year,
        month: month,
      );

      final response = await _dio.get<dynamic>(
        uri,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if ([200, 201].contains(response.statusCode) && response.data is Map) {
        return right(
          TrainerReportsResponseModel.fromJson(
            Map<String, dynamic>.from(response.data as Map),
          ),
        );
      }
      return left(const ApiException.unknown());
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response!.data as Map)['detail'] != null
          ? (e.response!.data as Map)['detail'].toString()
          : (e.message ?? 'Failed to load trainer reports');
      return left(ApiException.unknown(msg: msg));
    } catch (e) {
      return left(ApiException.unknown(msg: e.toString()));
    }
  }
}
