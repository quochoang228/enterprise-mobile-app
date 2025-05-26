import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

@singleton
class CacheManager {
  final Map<String, CacheEntry> _memoryCache = {};
  final Box _diskCache;
  final Duration _defaultTtl;
  Timer? _cleanupTimer;

  CacheManager(this._diskCache, {Duration? defaultTtl})
    : _defaultTtl = defaultTtl ?? const Duration(hours: 1);

  Future<void> init() async {
    _startPeriodicCleanup();
  }

  void _startPeriodicCleanup() {
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _performCleanup(),
    );
  }

  Future<T?> get<T>(String key, {Duration? ttl}) async {
    // L1: Memory cache
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      return memoryEntry.data as T;
    }

    // L2: Disk cache
    final diskData = _diskCache.get(key);
    if (diskData != null) {
      final entry = CacheEntry.fromMap(Map<String, dynamic>.from(diskData));
      if (!entry.isExpired) {
        // Promote to memory cache
        _memoryCache[key] = entry;
        return entry.data as T;
      } else {
        // Remove expired entry
        await _diskCache.delete(key);
      }
    }

    return null;
  }

  Future<void> set<T>(String key, T data, {Duration? ttl}) async {
    final entry = CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(ttl ?? _defaultTtl),
    );

    // Store in both layers
    _memoryCache[key] = entry;
    await _diskCache.put(key, entry.toMap());
  }

  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    await _diskCache.delete(key);
  }

  Future<void> clear() async {
    _memoryCache.clear();
    await _diskCache.clear();
  }

  Future<void> clearMemoryCache() async {
    _memoryCache.clear();
  }

  Future<void> cleanExpired() async {
    // Clean memory cache
    _memoryCache.removeWhere((key, entry) => entry.isExpired);

    // Clean disk cache
    final keys = _diskCache.keys.toList();
    for (final key in keys) {
      final data = _diskCache.get(key);
      if (data != null) {
        final entry = CacheEntry.fromMap(Map<String, dynamic>.from(data));
        if (entry.isExpired) {
          await _diskCache.delete(key);
        }
      }
    }
  }

  Future<void> _performCleanup() async {
    await cleanExpired();
  }

  Future<void> dispose() async {
    _cleanupTimer?.cancel();
    await _diskCache.close();
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  CacheEntry({required this.data, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toMap() => {
    'data': data,
    'expires_at': expiresAt.toIso8601String(),
  };

  factory CacheEntry.fromMap(Map<String, dynamic> map) => CacheEntry(
    data: map['data'],
    expiresAt: DateTime.parse(map['expires_at']),
  );
}
