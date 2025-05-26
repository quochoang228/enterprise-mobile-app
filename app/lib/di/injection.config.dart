// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:core/core.dart' as _i494;
import 'package:get_it/get_it.dart' as _i174;
import 'package:hive_flutter/hive_flutter.dart' as _i986;
import 'package:injectable/injectable.dart' as _i526;

import '../app/app_config.dart' as _i975;
import 'app_module.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.singleton<_i975.AppConfig>(() => appModule.appConfig());
    await gh.singletonAsync<_i494.AnalyticsService>(
      () => appModule.analyticsService(),
      preResolve: true,
    );
    gh.singleton<_i494.SecureStorage>(() => appModule.secureStorage());
    gh.singleton<_i494.AuthService>(() => appModule.authService());
    gh.singleton<_i494.TokenManager>(() => appModule.tokenManager());
    gh.singleton<_i494.AppLogger>(() => appModule.appLogger());
    await gh.singletonAsync<_i986.Box<dynamic>>(
      () => appModule.userBox(),
      instanceName: 'userBox',
      preResolve: true,
    );
    await gh.singletonAsync<_i986.Box<dynamic>>(
      () => appModule.cacheBox(),
      instanceName: 'cacheBox',
      preResolve: true,
    );
    gh.singleton<_i494.PerformanceMonitor>(
      () => appModule.performanceMonitor(gh<_i494.AnalyticsService>()),
    );
    await gh.singletonAsync<_i986.Box<dynamic>>(
      () => appModule.authBox(),
      instanceName: 'authBox',
      preResolve: true,
    );
    await gh.singletonAsync<_i494.CacheManager>(
      () => appModule.cacheManager(
        gh<_i986.Box<dynamic>>(instanceName: 'cacheBox'),
      ),
      preResolve: true,
    );
    gh.singleton<_i494.ApiClient>(
      () => appModule.apiClient(gh<_i975.AppConfig>()),
    );
    gh.singleton<_i494.MemoryManager>(
      () => appModule.memoryManager(
        gh<_i494.CacheManager>(),
        gh<_i494.AnalyticsService>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}
