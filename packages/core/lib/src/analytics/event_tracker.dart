import 'package:injectable/injectable.dart';

/// Event tracker for custom analytics events
@singleton
class EventTracker {
  const EventTracker();

  Future<void> trackUserAction(
    String action, [
    Map<String, dynamic>? data,
  ]) async {
    // Track user actions
  }

  Future<void> trackPerformance(String metric, double value) async {
    // Track performance metrics
  }

  Future<void> trackError(String error, [String? stackTrace]) async {
    // Track errors and exceptions
  }

  Future<void> trackNavigation(String from, String to) async {
    // Track navigation events
  }
}
