import 'package:dio/dio.dart';
import '../../core.dart';

class ErrorHandler {
  static Failure handleException(Exception exception) {
    if (exception is NetworkException) {
      return NetworkFailure(exception.message, code: exception.code);
    } else if (exception is ServerException) {
      return ServerFailure(exception.message, code: exception.code);
    } else if (exception is AuthException) {
      return AuthFailure(exception.message, code: exception.code);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message, code: exception.code);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message, code: exception.code);
    } else if (exception is DioException) {
      return _handleDioException(exception);
    } else {
      return UnknownFailure(exception.toString());
    }
  }

  static NetworkFailure _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkFailure('Connection timeout');
      case DioExceptionType.sendTimeout:
        return const NetworkFailure('Send timeout');
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Receive timeout');
      case DioExceptionType.badResponse:
        return NetworkFailure(
          'Bad response: ${exception.response?.statusMessage ?? 'Unknown error'}',
          code: exception.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const NetworkFailure('Request cancelled');
      case DioExceptionType.connectionError:
        return const NetworkFailure('Connection error');
      case DioExceptionType.badCertificate:
        return const NetworkFailure('Bad certificate');
      case DioExceptionType.unknown:
        return NetworkFailure('Unknown network error: ${exception.message}');
    }
  }
}
