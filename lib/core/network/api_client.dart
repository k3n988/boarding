import 'package:dio/dio.dart';

class ApiClient {
  static const String _baseUrl = 'https://api.bacolodboardingguard.com/v1';
  // TODO: Replace with your actual API base URL

  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _LoggingInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  // ── Convenience Methods ───────────────────────────────────

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
  }) async {
    return _dio.post(path, data: data);
  }

  Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }
}

// ── Auth Interceptor ──────────────────────────────────────
// Automatically attaches the Bearer token to every request
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: Pull token from secure storage (e.g., flutter_secure_storage)
    const token = '';
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // TODO: Trigger logout / token refresh
    }
    handler.next(err);
  }
}

// ── Logging Interceptor ───────────────────────────────────
// Prints requests and responses in debug mode
class _LoggingInterceptor extends LogInterceptor {
  _LoggingInterceptor()
      : super(
          request: true,
          requestBody: true,
          responseBody: true,
          error: true,
        );
}