import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'token_storage.dart';

typedef UnauthorizedCallback = void Function();

/// Attaches Bearer token and handles 401 session expiry.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    UnauthorizedCallback? onUnauthorized,
  }) : _tokenStorage = tokenStorage,
       _onUnauthorized = onUnauthorized;

  final TokenStorage _tokenStorage;
  final UnauthorizedCallback? _onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      debugPrint('AuthInterceptor: received 401, session expired');
      _onUnauthorized?.call();
    }
    handler.next(err);
  }
}

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    UnauthorizedCallback? onUnauthorized,
    BaseOptions? baseOptions,
  }) : _tokenStorage = tokenStorage,
       _onUnauthorized = onUnauthorized,
       _baseOptions =
           baseOptions ??
           BaseOptions(
             connectTimeout: const Duration(seconds: 15),
             receiveTimeout: const Duration(seconds: 15),
           );

  final TokenStorage _tokenStorage;
  final UnauthorizedCallback? _onUnauthorized;
  final BaseOptions _baseOptions;

  Dio create() {
    final dio = Dio(_baseOptions);
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: _tokenStorage,
        onUnauthorized: _onUnauthorized,
      ),
    );
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          logPrint: (message) {
            final text = message.toString();
            if (text.contains('Authorization')) {
              debugPrint('[Dio] Authorization: Bearer ***');
              return;
            }
            debugPrint('[Dio] $text');
          },
        ),
      );
    }
    return dio;
  }
}
