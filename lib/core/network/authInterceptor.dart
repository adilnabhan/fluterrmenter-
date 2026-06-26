import 'package:dio/dio.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._appCubit, this._dio);

  final AppCubit _appCubit;
  final Dio _dio;

  bool _isRefreshing = false;
  final List<Function()> _retryQueue = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _appCubit.state.currentUser?.access;

    if (token != null) {
      options.headers['Authorization'] = 'JWT $token';
    }

    options.headers['X-Platform'] = platformSource;

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;

    // 🧵 If refresh already happening → queue request
    if (_isRefreshing) {
      _retryQueue.add(() async {
        final newToken = _appCubit.state.currentUser?.access;
        if (newToken != null) {
          requestOptions.headers['Authorization'] = 'JWT $newToken';
          final response = await _dio.fetch(requestOptions);
          handler.resolve(response);
        }
      });
      return;
    }

    _isRefreshing = true;

    await _appCubit.refreshToken();

    final newToken = _appCubit.state.currentUser?.access;

    if (newToken == null) {
      _isRefreshing = false;
      return handler.next(err);
    }

    // 🔁 Retry original request
    requestOptions.headers['Authorization'] = 'JWT $newToken';
    final response = await _dio.fetch(requestOptions);

    // 🔁 Retry queued requests
    for (final retry in _retryQueue) {
      retry();
    }
    _retryQueue.clear();

    _isRefreshing = false;

    handler.resolve(response);
  }
}
