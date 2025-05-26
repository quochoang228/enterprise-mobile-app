import 'dart:async';
import 'package:injectable/injectable.dart';
import '../analytics/analytics_service.dart';

@singleton
class PerformanceMonitor {
  final AnalyticsService _analytics;
  final Map<String, Stopwatch> _activeOperations = {};

  PerformanceMonitor(this._analytics);

  void startOperation(String operationName) {
    _activeOperations[operationName] = Stopwatch()..start();
  }

  void endOperation(String operationName, {Map<String, dynamic>? extra}) {
    final stopwatch = _activeOperations.remove(operationName);
    if (stopwatch != null) {
      stopwatch.stop();

      _analytics.track('operation_completed', {
        'operation': operationName,
        'duration_ms': stopwatch.elapsedMilliseconds,
        'duration_readable': _formatDuration(stopwatch.elapsed),
        ...?extra,
      });

      // Log slow operations
      if (stopwatch.elapsedMilliseconds > 1000) {
        _analytics.track('slow_operation', {
          'operation': operationName,
          'duration_ms': stopwatch.elapsedMilliseconds,
        });
      }
    }
  }

  Future<T> measureOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? extra,
  }) async {
    startOperation(operationName);

    try {
      final result = await operation();
      endOperation(operationName, extra: {'success': true, ...?extra});
      return result;
    } catch (e) {
      endOperation(
        operationName,
        extra: {'success': false, 'error': e.toString(), ...?extra},
      );
      rethrow;
    }
  }

  T measureSyncOperation<T>(
    String operationName,
    T Function() operation, {
    Map<String, dynamic>? extra,
  }) {
    startOperation(operationName);

    try {
      final result = operation();
      endOperation(operationName, extra: {'success': true, ...?extra});
      return result;
    } catch (e) {
      endOperation(
        operationName,
        extra: {'success': false, 'error': e.toString(), ...?extra},
      );
      rethrow;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds}ms';
    } else if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
  }

  Map<String, dynamic> getActiveOperations() {
    return _activeOperations.map(
      (key, stopwatch) => MapEntry(key, {
        'duration_ms': stopwatch.elapsedMilliseconds,
        'duration_readable': _formatDuration(stopwatch.elapsed),
      }),
    );
  }

  void dispose() {
    _activeOperations.clear();
  }
}
