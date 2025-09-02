import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioClient {
  factory DioClient() => _instance;
  DioClient._internal() {
    _dio = Dio();
    _dio.interceptors.add(
      PrettyDioLogger(requestHeader: true, requestBody: true),
    );
  }

  static final DioClient _instance = DioClient._internal();

  late final Dio _dio;

  Dio get dio => _dio;
}
