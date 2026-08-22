enum ApiErrorType {
  badRequest, // 400
  unauthorized, // 401
  forbidden, // 403
  notFound, // 404
  requestTimeout, // 408
  rateLimited, // 429
  serverError, // 500
  badGateway, // 502
  serviceUnavailable, // 503
  gatewayTimeout, // 504
  connectionTimeout,
  connectionRefused,
  networkUnavailable,
  cancelled,
  unknown,
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorType errorType;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errorType = ApiErrorType.unknown,
    this.data,
  });

  bool get isAuthError => statusCode == 401 || statusCode == 403;
  bool get isNetworkError =>
      errorType == ApiErrorType.connectionTimeout ||
      errorType == ApiErrorType.connectionRefused ||
      errorType == ApiErrorType.networkUnavailable;

  @override
  String toString() {
    if (statusCode != null) {
      return '$message (HTTP $statusCode)';
    }
    return message;
  }
}
