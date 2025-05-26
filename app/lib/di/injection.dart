import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:core/core.dart';
import '../app/app_config.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Initialize injectable - this will register all services defined with @injectable annotations
  // and those defined in app_module.dart
  await getIt.init();

  // Set up analytics environment
  await _setupAnalytics();
}

Future<void> _setupAnalytics() async {
  final appConfig = getIt<AppConfig>();
  final analytics = getIt<AnalyticsService>();
  final analyticsEnv = AnalyticsEnvironment(analytics);

  await analyticsEnv.setupProviders(appConfig.environment);

  getIt.registerSingleton<AnalyticsEnvironment>(analyticsEnv);
}

// Note: All core services are now registered through app_module.dart using @injectable annotations
// User management services are registered in their respective modules using @injectable annotations
