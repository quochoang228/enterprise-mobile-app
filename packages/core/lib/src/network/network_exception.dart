import 'package:dio/dio.dart';
import '../error/exceptions.dart';

class NetworkException extends AppException {
  const NetworkException(String message, {int? code})
    : super(message, code: code);

  factory NetworkException.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkException('Connection timeout');
      case DioExceptionType.sendTimeout:
        return const NetworkException('Send timeout');
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Receive timeout');
      case DioExceptionType.badResponse:
        return NetworkException(
          'Bad response: ${dioError.response?.statusMessage ?? 'Unknown error'}',
          code: dioError.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const NetworkException('Request cancelled');
      case DioExceptionType.connectionError:
        return const NetworkException('Connection error');
      case DioExceptionType.badCertificate:
        return const NetworkException('Bad certificate');
      case DioExceptionType.unknown:
      return NetworkException('Unknown network error: ${dioError.message}');
    }
  }
}
