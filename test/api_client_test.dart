import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meal_finder/services/api_client.dart';
import 'package:meal_finder/services/token_storage.dart';

void main() {
  test('AuthInterceptor attaches bearer token to requests', () async {
    final storage = InMemoryTokenStorage();
    await storage.writeToken('secret-token');

    final interceptor = AuthInterceptor(tokenStorage: storage);
    final options = RequestOptions(path: '/meals');
    final handler = _CapturingRequestHandler();

    await interceptor.onRequest(options, handler);

    expect(handler.proceeded, isTrue);
    expect(options.headers['Authorization'], 'Bearer secret-token');
  });

  test('AuthInterceptor calls onUnauthorized for 401 responses', () {
    final storage = InMemoryTokenStorage();
    var unauthorized = false;
    final interceptor = AuthInterceptor(
      tokenStorage: storage,
      onUnauthorized: () => unauthorized = true,
    );
    final handler = _CapturingErrorHandler();
    final error = DioException(
      requestOptions: RequestOptions(path: '/meals'),
      response: Response(
        requestOptions: RequestOptions(path: '/meals'),
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    );

    interceptor.onError(error, handler);

    expect(unauthorized, isTrue);
    expect(handler.proceeded, isTrue);
  });

  test('AuthInterceptor ignores non-401 errors', () {
    var unauthorized = false;
    final interceptor = AuthInterceptor(
      tokenStorage: InMemoryTokenStorage(),
      onUnauthorized: () => unauthorized = true,
    );
    final handler = _CapturingErrorHandler();
    final error = DioException(
      requestOptions: RequestOptions(path: '/meals'),
      response: Response(
        requestOptions: RequestOptions(path: '/meals'),
        statusCode: 500,
      ),
      type: DioExceptionType.badResponse,
    );

    interceptor.onError(error, handler);

    expect(unauthorized, isFalse);
    expect(handler.proceeded, isTrue);
  });
}

class _CapturingRequestHandler extends RequestInterceptorHandler {
  bool proceeded = false;

  @override
  void next(RequestOptions options) {
    proceeded = true;
    super.next(options);
  }
}

class _CapturingErrorHandler extends ErrorInterceptorHandler {
  bool proceeded = false;

  @override
  void next(DioException err) {
    proceeded = true;
  }
}
