import 'package:flutter_riverpod/flutter_riverpod.dart';

// Note: This class is registered in app_module.dart
class AppConfig {
  final String appName;
  final String apiBaseUrl;
  final String environment;
  final bool isDebug;
  final String sentryDsn;
  final String databaseUrl;
  final String firebaseProjectId;
  final bool enableAnalytics;
  final bool enableCrashlytics;
  final bool showDebugInfo;

  const AppConfig({
    required this.appName,
    required this.apiBaseUrl,
    required this.environment,
    required this.isDebug,
    this.sentryDsn = '',
    this.databaseUrl = '',
    this.firebaseProjectId = '',
    this.enableAnalytics = true,
    this.enableCrashlytics = true,
    this.showDebugInfo = false,
  });

  factory AppConfig.fromEnvironment() {
    const environment = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'development',
    );

    switch (environment) {
      case 'production':
        return AppConfig.production();
      case 'staging':
        return AppConfig.staging();
      default:
        return AppConfig.development();
    }
  }

  factory AppConfig.development() => const AppConfig(
    appName: 'Enterprise App (Dev)',
    apiBaseUrl: 'https://api-dev.example.com',
    environment: 'development',
    isDebug: true,
    sentryDsn: 'https://dev-sentry-dsn@sentry.io/project',
    databaseUrl: 'sqlite://dev_database.db',
    firebaseProjectId: 'enterprise-app-dev',
    enableAnalytics: false,
    enableCrashlytics: false,
    showDebugInfo: true,
  );

  factory AppConfig.staging() => const AppConfig(
    appName: 'Enterprise App (Staging)',
    apiBaseUrl: 'https://api-staging.example.com',
    environment: 'staging',
    isDebug: false,
    sentryDsn: 'https://staging-sentry-dsn@sentry.io/project',
    databaseUrl: 'sqlite://staging_database.db',
    firebaseProjectId: 'enterprise-app-staging',
    enableAnalytics: true,
    enableCrashlytics: true,
    showDebugInfo: false,
  );

  factory AppConfig.production() => const AppConfig(
    appName: 'Enterprise App',
    apiBaseUrl: 'https://api.example.com',
    environment: 'production',
    isDebug: false,
    sentryDsn: 'https://prod-sentry-dsn@sentry.io/project',
    databaseUrl: 'sqlite://prod_database.db',
    firebaseProjectId: 'enterprise-app-prod',
    enableAnalytics: true,
    enableCrashlytics: true,
    showDebugInfo: false,
  );

  // Environment checks
  bool get isProduction => environment == 'production';
  bool get isDevelopment => environment == 'development';
  bool get isStaging => environment == 'staging';

  Map<String, dynamic> toMap() => {
    'appName': appName,
    'apiBaseUrl': apiBaseUrl,
    'environment': environment,
    'isDebug': isDebug,
    'enableAnalytics': enableAnalytics,
    'enableCrashlytics': enableCrashlytics,
    'showDebugInfo': showDebugInfo,
  };

  @override
  String toString() =>
      'AppConfig(environment: $environment, isDebug: $isDebug)';
}

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});
