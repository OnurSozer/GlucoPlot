/// Base exception class for data layer errors
class AppException implements Exception {
  const AppException({this.message, this.code});

  final String? message;
  final String? code;

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server exceptions (API errors)
class ServerException extends AppException {
  const ServerException({super.message, super.code, this.statusCode});

  final int? statusCode;

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code = 'NETWORK_ERROR',
  });
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException({super.message, super.code});
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException({super.message, super.code});
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException({super.message, super.code});
}
