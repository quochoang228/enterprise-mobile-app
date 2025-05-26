import 'package:dio/dio.dart';

class CacheInterceptor extends Interceptor {
  final Map<String, Response> _cache = {};
  final Duration _cacheDuration;

  CacheInterceptor({Duration? cacheDuration})
    : _cacheDuration = cacheDuration ?? const Duration(minutes: 5);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Only cache GET requests
    if (options.method.toUpperCase() != 'GET') {
      return handler.next(options);
    }

    final cacheKey = _generateCacheKey(options);
    final cachedResponse = _cache[cacheKey];

    if (cachedResponse != null && _isCacheValid(cachedResponse)) {
      return handler.resolve(cachedResponse);
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Cache successful GET responses
    if (response.requestOptions.method.toUpperCase() == 'GET' &&
        response.statusCode == 200) {
      final cacheKey = _generateCacheKey(response.requestOptions);
      response.extra['cache_time'] = DateTime.now().millisecondsSinceEpoch;
      _cache[cacheKey] = response;
    }

    handler.next(response);
  }

  String _generateCacheKey(RequestOptions options) {
    return '${options.method}_${options.uri}';
  }

  bool _isCacheValid(Response response) {
    final cacheTime = response.extra['cache_time'] as int?;
    if (cacheTime == null) return false;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cacheTime);
    return DateTime.now().difference(cachedAt) < _cacheDuration;
  }

  void clearCache() {
    _cache.clear();
  }
}
