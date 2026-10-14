import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/src/features/trainer/domain/models/trainer_personal_records_model.dart';

@immutable
final class TrainerPersonalRecordsRepository {
  TrainerPersonalRecordsRepository() : _dio = DioClient().dio;

  final Dio _dio;

  Future<Either<ApiException, TrainerPersonalRecordsResponseModel>>
      fetchPersonalRecords(int customerId) async {
    try {
      final uri = ApiUris.trainerCustomerPersonalRecords(customerId);
      final response = await _dio.get<dynamic>(
        uri,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if ([200, 201].contains(response.statusCode) && response.data != null) {
        final raw = response.data;
        Map<String, dynamic> dataMap = {};
        if (raw is Map) {
          if (raw['data'] is Map) {
            dataMap = Map<String, dynamic>.from(raw['data'] as Map);
          } else {
            dataMap = Map<String, dynamic>.from(raw);
          }
        }
        return right(TrainerPersonalRecordsResponseModel.fromJson(dataMap));
      }
      return left(const ApiException.unknown());
    } on DioException catch (e) {
      final msg = e.response?.data is Map &&
              (e.response!.data as Map)['detail'] != null
          ? (e.response!.data as Map)['detail'].toString()
          : (e.message ?? 'Failed to load personal records');
      return left(ApiException.unknown(msg: msg));
    } catch (e) {
      return left(ApiException.unknown(msg: e.toString()));
    }
  }

  Future<Either<ApiException, ExercisePrRecordModel>> fetchExerciseRecord({
    required int customerId,
    required int workoutId,
  }) async {
    try {
      final uri =
          ApiUris.trainerCustomerExerciseRecord(customerId, workoutId);
      final response = await _dio.get<dynamic>(
        uri,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if ([200, 201].contains(response.statusCode) && response.data != null) {
        final raw = response.data;
        Map<String, dynamic> dataMap = {};
        if (raw is Map) {
          if (raw['data'] is Map) {
            dataMap = Map<String, dynamic>.from(raw['data'] as Map);
          } else {
            dataMap = Map<String, dynamic>.from(raw);
          }
        }
        return right(ExercisePrRecordModel.fromJson(dataMap));
      }
      return left(const ApiException.unknown());
    } on DioException catch (e) {
      final msg = e.response?.data is Map &&
              (e.response!.data as Map)['detail'] != null
          ? (e.response!.data as Map)['detail'].toString()
          : (e.message ?? 'Failed to load exercise record');
      return left(ApiException.unknown(msg: msg));
    } catch (e) {
      return left(ApiException.unknown(msg: e.toString()));
    }
  }
}
