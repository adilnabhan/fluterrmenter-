import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mentor_mobile_app/core/api/constants.dart';
import 'package:mentor_mobile_app/core/api/uris/api_uris.dart';
import 'package:mentor_mobile_app/core/network/token_refresh_result.dart';
import 'package:mentor_mobile_app/src/app/cubit/app_cubit.dart';

/// Pending request waiting for a token refresh to complete.
class _PendingRequest {
  _PendingRequest(this.requestOptions, this.handler);

  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;
}

class AuthInterceptor extends Interceptor {
  AuthInterceptor([this._appCubit, Dio? dio]) : _dio = dio ?? Dio();

  final AppCubit? _appCubit;
  final Dio _dio;

  /// Pending requests queued while a refresh is in progress.
  final List<_PendingRequest> _pendingRequests = [];

  /// The single in-flight refresh future. All concurrent 401 handlers
  /// await this same future so only one refresh HTTP call is made.
  Completer<TokenRefreshResult>? _refreshCompleter;

  /// Returns true when the given request targets the token-refresh endpoint.
  bool _isRefreshRequest(RequestOptions options) {
    final path = options.path;
    final refreshUri = ApiUris.tokenRefresh;
    return path == refreshUri ||
        path.contains('/user/token/refresh') ||
        options.extra['skipAuth'] == true;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Never attach an Authorization header to the refresh endpoint itself.
    if (!_isRefreshRequest(options)) {
      if (!options.headers.containsKey('Authorization') ||
          options.headers['Authorization'] == null ||
          (options.headers['Authorization'] as String).isEmpty) {
        final token = _appCubit?.state.currentUser?.access;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'JWT $token';
        }
      }
    }

    options.headers['X-Platform'] ??= platformSource;

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only intercept 401 responses.
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Never try to refresh in response to the refresh endpoint itself.
    // This prevents infinite recursion:
    //   API 401 → refresh → refresh 401 → refresh again → ...
    if (_isRefreshRequest(err.requestOptions)) {
      if (kDebugMode) {
        print('🔒 AuthInterceptor: 401 from refresh endpoint — passing through (no recursive refresh).');
      }
      return handler.next(err);
    }

    if (_appCubit == null) {
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;

    if (kDebugMode) {
      print('🔒 AuthInterceptor: 401 received from: ${requestOptions.path}');
    }

    // If a refresh is already in progress, queue this request.
    if (_refreshCompleter != null) {
      if (kDebugMode) {
        print('🔒 AuthInterceptor: Refresh already in progress — queuing request (${requestOptions.path}).');
      }
      _pendingRequests.add(_PendingRequest(requestOptions, handler));
      return;
    }

    // Start the single refresh operation.
    _refreshCompleter = Completer<TokenRefreshResult>();

    if (kDebugMode) {
      print('🔒 AuthInterceptor: Starting token refresh...');
    }

    TokenRefreshResult result;
    try {
      result = await _appCubit.refreshToken();
      _refreshCompleter!.complete(result);
    } catch (e) {
      result = TokenRefreshResult.temporaryFailure;
      _refreshCompleter!.complete(result);
    }

    // Grab and clear the queue before draining.
    final pending = List<_PendingRequest>.from(_pendingRequests);
    _pendingRequests.clear();
    _refreshCompleter = null;

    if (kDebugMode) {
      print('🔒 AuthInterceptor: Refresh result=$result. Queued requests: ${pending.length}');
    }

    switch (result) {
      case TokenRefreshResult.success:
        // Retry the original request with the new token.
        final newToken = _appCubit.state.currentUser?.access;
        if (newToken != null && newToken.isNotEmpty) {
          try {
            requestOptions.headers['Authorization'] = 'JWT $newToken';
            final response = await _dio.fetch<dynamic>(requestOptions);
            handler.resolve(response);
          } on DioException catch (e) {
            handler.reject(e);
          }

          // Retry every queued request.
          for (final p in pending) {
            try {
              p.requestOptions.headers['Authorization'] = 'JWT $newToken';
              final response = await _dio.fetch<dynamic>(p.requestOptions);
              p.handler.resolve(response);
            } on DioException catch (e) {
              p.handler.reject(e);
            }
          }
        } else {
          // Shouldn't happen after success, but safety fallback.
          handler.next(err);
          for (final p in pending) {
            p.handler.next(DioException(
              requestOptions: p.requestOptions,
              error: 'Token refresh reported success but no token found',
            ));
          }
        }

      case TokenRefreshResult.invalidToken:
        // Reject original and all queued — the user is being logged out.
        handler.next(err);
        for (final p in pending) {
          p.handler.next(DioException(
            requestOptions: p.requestOptions,
            response: err.response,
            error: 'Refresh token is invalid — logging out',
          ));
        }

      case TokenRefreshResult.temporaryFailure:
      case TokenRefreshResult.noRefreshToken:
      case TokenRefreshResult.noUser:
        // Reject, but the session is preserved — the user stays logged in.
        handler.next(err);
        for (final p in pending) {
          p.handler.next(DioException(
            requestOptions: p.requestOptions,
            error: 'Token refresh failed temporarily ($result)',
          ));
        }
    }
  }
}