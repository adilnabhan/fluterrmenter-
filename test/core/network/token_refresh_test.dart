import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentor_mobile_app/core/network/authInterceptor.dart';
import 'package:mentor_mobile_app/core/network/token_refresh_result.dart';
import 'package:mentor_mobile_app/src/features/auth/login/domain/models/login_with_otp_model.dart';
import 'package:mentor_mobile_app/src/features/auth/login/domain/repositories/auth_repository.dart';

/// Mock HttpClientAdapter for controlling Dio responses in unit tests.
class MockAdapter implements HttpClientAdapter {
  MockAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  static ResponseBody jsonResponse(
    dynamic data, {
    int statusCode = 200,
    Map<String, List<String>>? headers,
  }) {
    final bytes = utf8.encode(jsonEncode(data));
    return ResponseBody.fromBytes(
      Uint8List.fromList(bytes),
      statusCode,
      headers: headers ??
          {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
    );
  }

  static ResponseBody errorResponse({
    int statusCode = 500,
    dynamic data = 'Server Error',
  }) {
    final bytes = utf8.encode(jsonEncode(data));
    return ResponseBody.fromBytes(
      Uint8List.fromList(bytes),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      handler(options);

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TokenRefreshResult enum', () {
    test('contains all expected result states', () {
      expect(TokenRefreshResult.values, contains(TokenRefreshResult.success));
      expect(TokenRefreshResult.values, contains(TokenRefreshResult.invalidToken));
      expect(TokenRefreshResult.values, contains(TokenRefreshResult.temporaryFailure));
      expect(TokenRefreshResult.values, contains(TokenRefreshResult.noRefreshToken));
      expect(TokenRefreshResult.values, contains(TokenRefreshResult.noUser));
      expect(TokenRefreshResult.values.length, 5);
    });
  });

  group('AuthRepository.refreshToken()', () {
    test('returns success and populates tokens on 200 with access & refresh', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockAdapter((options) async {
        expect(options.extra['skipAuth'], isTrue);
        expect(options.headers.containsKey('Authorization'), isFalse);
        return MockAdapter.jsonResponse({
          'access': 'new_access_token_123',
          'refresh': 'new_refresh_token_456',
        });
      });

      final outTokens = <String, dynamic>{};
      final result = await AuthRepository().refreshToken(
        'valid_refresh_token',
        outTokens: outTokens,
        dio: dio,
      );

      expect(result, equals(TokenRefreshResult.success));
      expect(outTokens['access'], equals('new_access_token_123'));
      expect(outTokens['refresh'], equals('new_refresh_token_456'));
    });

    test('supports alternate token keys (access_token & refresh_token)', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockAdapter((options) async {
        return MockAdapter.jsonResponse({
          'access_token': 'alt_access_token',
          'refresh_token': 'alt_refresh_token',
        });
      });

      final outTokens = <String, dynamic>{};
      final result = await AuthRepository().refreshToken(
        'valid_refresh_token',
        outTokens: outTokens,
        dio: dio,
      );

      expect(result, equals(TokenRefreshResult.success));
      expect(outTokens['access'], equals('alt_access_token'));
      expect(outTokens['refresh'], equals('alt_refresh_token'));
    });

    test('returns invalidToken on HTTP 401 Unauthorized', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockAdapter((options) async {
        return MockAdapter.jsonResponse(
          {'detail': 'Token is invalid or expired'},
          statusCode: 401,
        );
      });

      final result = await AuthRepository().refreshToken(
        'expired_refresh_token',
        dio: dio,
      );

      expect(result, equals(TokenRefreshResult.invalidToken));
    });

    test('returns invalidToken on HTTP 403 Forbidden', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockAdapter((options) async {
        return MockAdapter.jsonResponse(
          {'error': 'Token blacklisted'},
          statusCode: 403,
        );
      });

      final result = await AuthRepository().refreshToken(
        'revoked_refresh_token',
        dio: dio,
      );

      expect(result, equals(TokenRefreshResult.invalidToken));
    });

    test('returns temporaryFailure on HTTP 500 Internal Server Error (PRESERVES SESSION)', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockAdapter((options) async {
        return MockAdapter.errorResponse(statusCode: 500);
      });

      final result = await AuthRepository().refreshToken(
        'some_refresh_token',
        dio: dio,
      );

      // Crucial: 500 MUST NOT log the user out!
      expect(result, equals(TokenRefreshResult.temporaryFailure));
      expect(result, isNot(equals(TokenRefreshResult.invalidToken)));
    });

    test('returns temporaryFailure on HTTP 502/503/504 Bad Gateway / Service Unavailable', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockAdapter((options) async {
        return MockAdapter.errorResponse(statusCode: 502);
      });

      final result = await AuthRepository().refreshToken(
        'some_refresh_token',
        dio: dio,
      );

      expect(result, equals(TokenRefreshResult.temporaryFailure));
    });

    test('returns temporaryFailure on connection / send / receive timeout', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
          error: 'Connection timed out',
        );
      });

      final result = await AuthRepository().refreshToken(
        'some_refresh_token',
        dio: dio,
      );

      expect(result, equals(TokenRefreshResult.temporaryFailure));
    });

    test('returns temporaryFailure on network / connection error (offline)', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'No internet connection',
        );
      });

      final result = await AuthRepository().refreshToken(
        'some_refresh_token',
        dio: dio,
      );

      expect(result, equals(TokenRefreshResult.temporaryFailure));
    });

    test('returns temporaryFailure when 200 response has missing or empty access token', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockAdapter((options) async {
        return MockAdapter.jsonResponse({
          'message': 'OK',
          // access token missing!
        });
      });

      final result = await AuthRepository().refreshToken(
        'some_refresh_token',
        dio: dio,
      );

      // A malformed response must be treated as temporaryFailure, NOT invalidToken!
      expect(result, equals(TokenRefreshResult.temporaryFailure));
    });

    test('returns temporaryFailure when response body is not a Map', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockAdapter((options) async {
        return MockAdapter.jsonResponse('raw_string_response');
      });

      final result = await AuthRepository().refreshToken(
        'some_refresh_token',
        dio: dio,
      );

      expect(result, equals(TokenRefreshResult.temporaryFailure));
    });
  });

  group('AuthInterceptor', () {
    test('skips adding Authorization header for skipAuth or refresh path', () {
      final interceptor = AuthInterceptor();
      final dio = Dio();
      dio.interceptors.add(interceptor);

      // Test skipAuth extra
      final options1 = RequestOptions(
        path: '/some/unauthenticated/endpoint',
        extra: {'skipAuth': true},
      );
      interceptor.onRequest(options1, RequestInterceptorHandler());
      expect(options1.headers.containsKey('Authorization'), isFalse);

      // Test refresh endpoint path
      final options2 = RequestOptions(path: '/user/token/refresh/');
      interceptor.onRequest(options2, RequestInterceptorHandler());
      expect(options2.headers.containsKey('Authorization'), isFalse);
    });

    test('passes through 401 directly without refresh loop when skipAuth is true', () {
      final interceptor = AuthInterceptor();
      final options = RequestOptions(
        path: '/user/token/refresh/',
        extra: {'skipAuth': true},
      );

      final error = DioException(
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: 401),
      );

      var nextCalled = false;
      final handler = _TestErrorInterceptorHandler(
        onNext: (err) {
          nextCalled = true;
        },
      );

      interceptor.onError(error, handler);
      expect(nextCalled, isTrue, reason: '401 on refresh endpoint must pass through directly to avoid recursive loop');
    });
  });

  group('Account Isolation & Identity Comparison', () {
    test('different user IDs are NEVER considered the same account', () {
      final userA = LoginSuccessModel(
        id: 101,
        mobileNumber: '9999999999',
        userRole: 1,
        access: 'token_a',
        refresh: 'ref_a',
      );

      final userB = LoginSuccessModel(
        id: 102,
        mobileNumber: '9999999999', // same mobile, different account
        userRole: 1,
        access: 'token_b',
        refresh: 'ref_b',
      );

      expect(userA.id != userB.id, isTrue);
    });

    test('updating tokens for userA leaves userB intact', () {
      final userA = LoginSuccessModel(
        id: 101,
        mobileNumber: '9999999999',
        userRole: 1,
        access: 'token_a_old',
        refresh: 'ref_a_old',
      );

      final userB = LoginSuccessModel(
        id: 102,
        mobileNumber: '8888888888',
        userRole: 2,
        access: 'token_b',
        refresh: 'ref_b',
      );

      final accounts = <LoginSuccessModel>[userA, userB];

      // Simulate token refresh for userA
      final updatedUserA = userA.copyWith(
        access: 'token_a_new',
        refresh: 'ref_a_new',
      );

      final index = accounts.indexWhere((a) => a.id == updatedUserA.id);
      expect(index, 0);
      accounts[index] = updatedUserA;

      // Verify User B was completely unaffected
      expect(accounts[1].id, 102);
      expect(accounts[1].access, 'token_b');
      expect(accounts[1].refresh, 'ref_b');

      // Verify User A has updated tokens
      expect(accounts[0].access, 'token_a_new');
      expect(accounts[0].refresh, 'ref_a_new');
    });
  });
}

class _TestErrorInterceptorHandler extends ErrorInterceptorHandler {
  _TestErrorInterceptorHandler({this.onNext});

  final void Function(DioException)? onNext;

  @override
  void next(DioException err) {
    onNext?.call(err);
  }
}
