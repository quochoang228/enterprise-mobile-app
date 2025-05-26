import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final shouldRetry = _shouldRetry(err);
    final currentRetryAttempt =
        err.requestOptions.extra['retry_attempt'] as int? ?? 0;

    if (shouldRetry && currentRetryAttempt < retries) {
      final delay = retryDelays.length > currentRetryAttempt
          ? retryDelays[currentRetryAttempt]
          : retryDelays.last;

      await Future.delayed(delay);

      final requestOptions = err.requestOptions;
      requestOptions.extra['retry_attempt'] = currentRetryAttempt + 1;

      try {
        final response = await dio.fetch(requestOptions);
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException error) {
    final statusCode = error.response?.statusCode;

    // Retry on network errors
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on specific status codes
    if (statusCode != null) {
      return statusCode >= 500 ||
          statusCode == 429; // Server errors or rate limiting
    }

    return false;
  }
}
