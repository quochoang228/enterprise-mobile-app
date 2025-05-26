class AppException implements Exception {
  final String message;
  final int? code;

  const AppException(this.message, {this.code});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

class ServerException extends AppException {
  const ServerException(String message, {int? code})
    : super(message, code: code);
}

class AuthException extends AppException {
  const AuthException(String message, {int? code}) : super(message, code: code);
}

class CacheException extends AppException {
  const CacheException(String message, {int? code})
    : super(message, code: code);
}

class ValidationException extends AppException {
  const ValidationException(String message, {int? code})
    : super(message, code: code);
}

class TimeoutException extends AppException {
  const TimeoutException(String message, {int? code})
    : super(message, code: code);
}

class ConnectionException extends AppException {
  const ConnectionException(String message, {int? code})
    : super(message, code: code);
}
