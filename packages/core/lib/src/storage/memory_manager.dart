import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../storage/cache_manager.dart';
import '../analytics/analytics_service.dart';

@singleton
class MemoryManager {
  final CacheManager _cacheManager;
  final AnalyticsService _analytics;
  Timer? _cleanupTimer;
  Timer? _memoryMonitorTimer;

  MemoryManager(this._cacheManager, this._analytics) {
    _startPeriodicCleanup();
    _startMemoryMonitoring();
  }

  void _startPeriodicCleanup() {
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _performCleanup(),
    );
  }

  void _startMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _monitorMemoryUsage(),
    );
  }

  Future<void> _performCleanup() async {
    try {
      // Clean expired cache entries
      await _cacheManager.cleanExpired();

      // Check memory usage and force cleanup if needed
      if (await _isMemoryPressureHigh()) {
        await _performAggressiveCleanup();
      }

      _analytics.track('memory_cleanup_performed', {
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Memory cleanup error: $e');
      }
    }
  }

  Future<void> _monitorMemoryUsage() async {
    try {
      final memoryInfo = await _getMemoryInfo();

      _analytics.track('memory_usage_report', memoryInfo);

      if (memoryInfo['memory_pressure'] == 'high') {
        await _performAggressiveCleanup();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Memory monitoring error: $e');
      }
    }
  }

  Future<Map<String, dynamic>> _getMemoryInfo() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Get memory info from platform
        final info = await _getPlatformMemoryInfo();
        return {
          'used_memory_mb': info['usedMemory'] ?? 0,
          'total_memory_mb': info['totalMemory'] ?? 0,
          'memory_pressure': _calculateMemoryPressure(info),
          'platform': Platform.operatingSystem,
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Platform memory info error: $e');
      }
    }

    return {
      'used_memory_mb': 0,
      'total_memory_mb': 0,
      'memory_pressure': 'unknown',
      'platform': Platform.operatingSystem,
    };
  }

  Future<Map<String, dynamic>> _getPlatformMemoryInfo() async {
    // This would integrate with platform channels to get actual memory info
    // For now, returning mock data
    return {
      'usedMemory': 150, // MB
      'totalMemory': 512, // MB
    };
  }

  String _calculateMemoryPressure(Map<String, dynamic> info) {
    final used = info['usedMemory'] ?? 0;
    final total = info['totalMemory'] ?? 1;
    final percentage = (used / total) * 100;

    if (percentage > 85) return 'high';
    if (percentage > 70) return 'medium';
    return 'low';
  }

  Future<bool> _isMemoryPressureHigh() async {
    final memoryInfo = await _getMemoryInfo();
    return memoryInfo['memory_pressure'] == 'high';
  }

  Future<void> _performAggressiveCleanup() async {
    if (kDebugMode) {
      print('🧹 Performing aggressive memory cleanup...');
    }

    // Clear memory cache
    await _cacheManager.clearMemoryCache();

    // Force garbage collection (not guaranteed but can help)
    _forceGarbageCollection();

    _analytics.track('aggressive_memory_cleanup', {
      'timestamp': DateTime.now().toIso8601String(),
      'reason': 'high_memory_pressure',
    });
  }

  void _forceGarbageCollection() {
    // Create temporary objects to trigger GC
    for (int i = 0; i < 3; i++) {
      final List<int> temp = List.filled(100000, 0);
      temp.clear();
    }
  }

  Future<void> onLowMemoryWarning() async {
    if (kDebugMode) {
      print('⚠️  Low memory warning received');
    }

    await _performAggressiveCleanup();

    _analytics.track('low_memory_warning_handled', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> onAppBackgrounded() async {
    // Perform cleanup when app goes to background
    await _performCleanup();

    _analytics.track('background_cleanup_performed', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Map<String, dynamic> getMemoryStats() {
    return {
      'cleanup_timer_active': _cleanupTimer?.isActive ?? false,
      'monitor_timer_active': _memoryMonitorTimer?.isActive ?? false,
      'last_cleanup': DateTime.now().toIso8601String(),
    };
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _memoryMonitorTimer?.cancel();

    if (kDebugMode) {
      print('🗑️  Memory Manager disposed');
    }
  }
}
