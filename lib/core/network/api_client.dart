import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../error/api_exception.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: AppConfig.connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: AppConfig.receiveTimeoutSeconds),
        sendTimeout: const Duration(seconds: AppConfig.sendTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Platform': 'Mobile-Flutter',
        },
      ),
    );

    // Custom sanitized security logging interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final sanitizedHeaders = Map<String, dynamic>.from(options.headers);
          if (sanitizedHeaders.containsKey('Authorization')) {
            sanitizedHeaders['Authorization'] = 'Bearer [REDACTED]';
          }
          final sanitizedData = _sanitizePayload(options.data);
          dev.log(
            '--> ${options.method.toUpperCase()} ${options.baseUrl}${options.path} | Data: $sanitizedData',
            name: 'ApiClient',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          dev.log(
            '<-- [${response.statusCode}] ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.path}',
            name: 'ApiClient',
          );
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          dev.log(
            '<-- ERROR [${error.response?.statusCode ?? error.type.name}] ${error.requestOptions.path}: ${error.message}',
            name: 'ApiClient',
          );
          return handler.next(error);
        },
      ),
    );
  }

  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  String get baseUrl => _dio.options.baseUrl;

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  bool get hasAuthToken => _dio.options.headers.containsKey('Authorization');

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> delete(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.delete(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Performs an actual network ping / health probe against the configured backend URL
  Future<({bool isReachable, int statusCode, int latencyMs, String message})> checkHealth({
    String? targetUrl,
  }) async {
    final effectiveBaseUrl = targetUrl ?? _dio.options.baseUrl;
    final testDio = Dio(
      BaseOptions(
        baseUrl: effectiveBaseUrl,
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
        headers: {
          'Accept': 'application/json',
          'X-Client-Platform': 'Mobile-Flutter-Ping',
        },
      ),
    );

    final stopwatch = Stopwatch()..start();
    try {
      final response = await testDio.get(ApiEndpoints.health);
      stopwatch.stop();
      return (
        isReachable: true,
        statusCode: response.statusCode ?? 200,
        latencyMs: stopwatch.elapsedMilliseconds,
        message: 'FastAPI Backend Online (${response.statusCode ?? 200} OK)',
      );
    } on DioException catch (e) {
      stopwatch.stop();
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        final handled = _handleDioError(e);
        return (
          isReachable: false,
          statusCode: handled.statusCode ?? 0,
          latencyMs: stopwatch.elapsedMilliseconds,
          message: handled.message,
        );
      }
      if (e.response != null) {
        final code = e.response!.statusCode ?? 0;
        final isAlive = code >= 200 && code < 500;
        return (
          isReachable: isAlive,
          statusCode: code,
          latencyMs: stopwatch.elapsedMilliseconds,
          message: isAlive
              ? 'Server Reachable (HTTP $code)'
              : 'Server Error (HTTP $code)',
        );
      }
      final handled = _handleDioError(e);
      return (
        isReachable: false,
        statusCode: handled.statusCode ?? 0,
        latencyMs: stopwatch.elapsedMilliseconds,
        message: handled.message,
      );
    } catch (e) {
      stopwatch.stop();
      return (
        isReachable: false,
        statusCode: 0,
        latencyMs: stopwatch.elapsedMilliseconds,
        message: 'Network unreachable: $e',
      );
    }
  }

  ApiException _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    String? extractedDetail;
    if (responseData is Map<String, dynamic>) {
      final detail = responseData['detail'] ?? responseData['message'] ?? responseData['error'];
      if (detail is String) {
        extractedDetail = detail;
      } else if (detail is List && detail.isNotEmpty) {
        // FastAPI 422 validation errors: [{"msg": "...", "loc": ...}]
        final first = detail.first;
        if (first is Map && first.containsKey('msg')) {
          extractedDetail = first['msg'].toString();
        }
      }
    }

    ApiErrorType errorType;
    String fallbackMessage;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        errorType = ApiErrorType.connectionTimeout;
        fallbackMessage = 'Connection to FastAPI backend timed out (${AppConfig.connectTimeoutSeconds}s). Verify host is running.';
        break;
      case DioExceptionType.receiveTimeout:
        errorType = ApiErrorType.connectionTimeout;
        fallbackMessage = 'Response receive timeout from backend server.';
        break;
      case DioExceptionType.connectionError:
        errorType = ApiErrorType.connectionRefused;
        fallbackMessage = 'Connection refused. No FastAPI server listening at ${_dio.options.baseUrl}.';
        break;
      case DioExceptionType.cancel:
        errorType = ApiErrorType.cancelled;
        fallbackMessage = 'Network request was cancelled.';
        break;
      case DioExceptionType.badCertificate:
        errorType = ApiErrorType.forbidden;
        fallbackMessage = 'TLS certificate verification failed.';
        break;
      case DioExceptionType.badResponse:
        switch (statusCode) {
          case 400:
            errorType = ApiErrorType.badRequest;
            fallbackMessage = 'Bad request. Invalid parameters provided.';
            break;
          case 401:
            errorType = ApiErrorType.unauthorized;
            fallbackMessage = 'Authentication required or session expired. Please log in.';
            break;
          case 403:
            errorType = ApiErrorType.forbidden;
            fallbackMessage = 'Access forbidden. Insufficient permissions for this resource.';
            break;
          case 404:
            errorType = ApiErrorType.notFound;
            fallbackMessage = 'API endpoint not found on FastAPI server (${error.requestOptions.path}).';
            break;
          case 408:
            errorType = ApiErrorType.requestTimeout;
            fallbackMessage = 'Server request timed out.';
            break;
          case 429:
            errorType = ApiErrorType.rateLimited;
            fallbackMessage = 'Rate limit exceeded. Too many requests to security gateway.';
            break;
          case 500:
            errorType = ApiErrorType.serverError;
            fallbackMessage = 'Internal FastAPI server error.';
            break;
          case 502:
            errorType = ApiErrorType.badGateway;
            fallbackMessage = 'Bad gateway. Upstream proxy unable to reach application.';
            break;
          case 503:
            errorType = ApiErrorType.serviceUnavailable;
            fallbackMessage = 'FastAPI security service is currently unavailable or under maintenance.';
            break;
          case 504:
            errorType = ApiErrorType.gatewayTimeout;
            fallbackMessage = 'Gateway timeout waiting for upstream response.';
            break;
          default:
            errorType = ApiErrorType.unknown;
            fallbackMessage = 'HTTP error status: $statusCode';
        }
        break;
      case DioExceptionType.unknown:
      default:
        errorType = ApiErrorType.networkUnavailable;
        fallbackMessage = error.message != null && error.message!.isNotEmpty
            ? 'Network communication error: ${error.message}'
            : 'Unable to reach backend network.';
        break;
    }

    final finalMessage = extractedDetail ?? fallbackMessage;
    return ApiException(
      message: finalMessage,
      statusCode: statusCode,
      errorType: errorType,
      data: responseData,
    );
  }

  dynamic _sanitizePayload(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      final sanitized = Map<String, dynamic>.from(data);
      const sensitiveKeys = {
        'password',
        'token',
        'authorization',
        'secret',
        'key',
        'apikey',
        'api_key',
        'access_token',
        'refresh_token',
        'client_secret',
      };
      for (final key in sanitized.keys) {
        if (sensitiveKeys.contains(key.toString().toLowerCase())) {
          sanitized[key] = '********';
        }
      }
      return sanitized;
    }
    return data;
  }
}
