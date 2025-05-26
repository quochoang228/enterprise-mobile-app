import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Analytics service for tracking user events and app usage
@singleton
class AnalyticsService {

  AnalyticsService();
  final List<AnalyticsProvider> _providers = [];
  bool _isInitialized = false;

  static Future<void> initialize() async {
    // This will be called from main.dart
    if (kDebugMode) {
      print('🔧 Initializing Analytics Service...');
    }
  }

  Future<void> addProvider(AnalyticsProvider provider) async {
    _providers.add(provider);
    if (_isInitialized) {
      await provider.initialize();
    }
  }

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    for (final provider in _providers) {
      await provider.initialize();
    }
    _isInitialized = true;

    if (kDebugMode) {
      print(
        '✅ Analytics Service initialized with ${_providers.length} providers',
      );
    }
  }

  Future<void> track(String event, Map<String, dynamic> properties) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('⚠️  Analytics not initialized, queuing event: $event');
      }
      return;
    }

    // Track with all providers
    for (final provider in _providers) {
      try {
        await provider.track(event, properties);
      } on Exception catch (e) {
        if (kDebugMode) {
          print('❌ Analytics provider error: $e');
        }
      }
    }

    // Debug logging
    if (kDebugMode) {
      print('📊 Analytics: $event with $properties');
    }
  }

  Future<void> trackEvent(
    String eventName, [
    Map<String, dynamic>? parameters,
  ]) async {
    await track(eventName, parameters ?? {});
  }

  Future<void> setUserId(String userId) async {
    for (final provider in _providers) {
      try {
        await provider.setUserId(userId);
      } on Exception catch (e) {
        if (kDebugMode) {
          print('❌ Analytics setUserId error: $e');
        }
      }
    }
  }

  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    for (final provider in _providers) {
      try {
        await provider.setUserProperties(properties);
      } on Exception catch (e) {
        if (kDebugMode) {
          print('❌ Analytics setUserProperties error: $e');
        }
      }
    }
  }

  Future<void> setUserProperty(String name, String value) async {
    await setUserProperties({name: value});
  }

  Future<void> logScreen(String screenName) async {
    await track('screen_view', {'screen_name': screenName});
  }

  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? extra,
  }) async {
    for (final provider in _providers) {
      try {
        await provider.recordError(error, stackTrace, extra: extra);
      } on Exception catch (e) {
        if (kDebugMode) {
          print('❌ Analytics recordError error: $e');
        }
      }
    }
  }

  void dispose() {
    for (final provider in _providers) {
      provider.dispose();
    }
    _providers.clear();
    _isInitialized = false;
  }
}

abstract class AnalyticsProvider {
  Future<void> initialize();
  Future<void> track(String event, Map<String, dynamic> properties);
  Future<void> setUserId(String userId);
  Future<void> setUserProperties(Map<String, dynamic> properties);
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? extra,
  });
  void dispose();
}
