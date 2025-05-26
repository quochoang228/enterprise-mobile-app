import 'package:flutter/foundation.dart';
import '../analytics_service.dart';

/// Debug analytics provider for development
class DebugAnalyticsProvider implements AnalyticsProvider {
  final List<Map<String, dynamic>> _events = [];
  String? _userId;
  Map<String, dynamic> _userProperties = {};

  @override
  Future<void> initialize() async {
    if (kDebugMode) {
      print('🐛 Debug Analytics Provider initialized');
    }
  }

  @override
  Future<void> track(String event, Map<String, dynamic> properties) async {
    final eventData = {
      'event': event,
      'properties': properties,
      'timestamp': DateTime.now().toIso8601String(),
      'user_id': _userId,
    };

    _events.add(eventData);

    if (kDebugMode) {
      print('📊 [DEBUG ANALYTICS] $event: $properties');
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    _userId = userId;
    if (kDebugMode) {
      print('👤 [DEBUG ANALYTICS] User ID set: $userId');
    }
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    _userProperties.addAll(properties);
    if (kDebugMode) {
      print('👤 [DEBUG ANALYTICS] User properties: $properties');
    }
  }

  @override
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? extra,
  }) async {
    if (kDebugMode) {
      print('❌ [DEBUG ANALYTICS] Error: $error');
      print('📍 Stack trace: $stackTrace');
      if (extra != null) {
        print('📋 Extra: $extra');
      }
    }
  }

  @override
  void dispose() {
    _events.clear();
    _userProperties.clear();
    _userId = null;
  }

  // Debug methods
  List<Map<String, dynamic>> getEvents() => List.unmodifiable(_events);

  Map<String, dynamic> getUserProperties() => Map.unmodifiable(_userProperties);

  String? getUserId() => _userId;

  void clearEvents() => _events.clear();
}
