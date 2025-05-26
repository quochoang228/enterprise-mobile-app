import 'package:injectable/injectable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:core/core.dart';
import '../app/app_config.dart';

@module
abstract class AppModule {
  @singleton
  @factoryMethod
  AppConfig appConfig() => AppConfig.fromEnvironment();

  @singleton
  ApiClient apiClient(AppConfig config) =>
      ApiClient(baseUrl: config.apiBaseUrl);

  @singleton
  @Named('cacheBox')
  @preResolve
  Future<Box> cacheBox() => Hive.openBox('cache');

  @singleton
  @Named('userBox')
  @preResolve
  Future<Box> userBox() => Hive.openBox('user');

  @singleton
  @Named('authBox')
  @preResolve
  Future<Box> authBox() => Hive.openBox('auth');

  @singleton
  @preResolve
  Future<CacheManager> cacheManager(@Named('cacheBox') Box cacheBox) async {
    final manager = CacheManager(cacheBox);
    await manager.init();
    return manager;
  }

  @singleton
  @preResolve
  Future<AnalyticsService> analyticsService() async {
    final service = AnalyticsService();
    await service.init();
    return service;
  }

  @singleton
  PerformanceMonitor performanceMonitor(AnalyticsService analytics) =>
      PerformanceMonitor(analytics);

  @singleton
  MemoryManager memoryManager(CacheManager cache, AnalyticsService analytics) =>
      MemoryManager(cache, analytics);

  @singleton
  SecureStorage secureStorage() => SecureStorage();

  @singleton
  AuthService authService() => AuthService();

  @singleton
  TokenManager tokenManager() => TokenManager();

  @singleton
  AppLogger appLogger() => AppLogger();
}
