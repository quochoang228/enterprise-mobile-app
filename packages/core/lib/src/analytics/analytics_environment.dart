import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../analytics/analytics_service.dart';
import '../analytics/providers/debug_analytics_provider.dart';
import '../analytics/providers/firebase_analytics_provider.dart';

@singleton
class AnalyticsEnvironment {
  final AnalyticsService _analytics;

  AnalyticsEnvironment(this._analytics);

  Future<void> setupProviders(String environment) async {
    switch (environment) {
      case 'development':
        await _setupDevelopmentProviders();
        break;
      case 'staging':
        await _setupStagingProviders();
        break;
      case 'production':
        await _setupProductionProviders();
        break;
      default:
        await _setupDevelopmentProviders();
    }
  }

  Future<void> _setupDevelopmentProviders() async {
    // Only debug provider in development
    await _analytics.addProvider(DebugAnalyticsProvider());

    if (kDebugMode) {
      print('🔧 Analytics: Development environment setup');
    }
  }

  Future<void> _setupStagingProviders() async {
    // Debug + Firebase in staging
    await _analytics.addProvider(DebugAnalyticsProvider());
    await _analytics.addProvider(FirebaseAnalyticsProvider());

    if (kDebugMode) {
      print('🧪 Analytics: Staging environment setup');
    }
  }

  Future<void> _setupProductionProviders() async {
    // Only Firebase in production
    await _analytics.addProvider(FirebaseAnalyticsProvider());

    if (kDebugMode) {
      print('🚀 Analytics: Production environment setup');
    }
  }
}
