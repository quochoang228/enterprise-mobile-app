import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import '../di/injection.dart';

class ExampleUsagePage extends ConsumerWidget {
  const ExampleUsagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Architecture Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AnalyticsSection(),
              SizedBox(height: 20),
              _CacheSection(),
              SizedBox(height: 20),
              _PerformanceSection(),
              SizedBox(height: 20),
              _MemorySection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsSection extends StatefulWidget {
  const _AnalyticsSection();

  @override
  State<_AnalyticsSection> createState() => _AnalyticsSectionState();
}

class _AnalyticsSectionState extends State<_AnalyticsSection> {
  late final AnalyticsService analytics;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    try {
      analytics = getIt<AnalyticsService>();
    } catch (e) {
      debugPrint('Error initializing analytics: $e');
    }
  }

  Future<void> _trackEvent() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      await analytics.track('button_clicked', {
        'button_name': 'analytics_demo',
        'screen': 'example_usage',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[DEBUG ANALYTICS] Error tracking event: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Analytics error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Analytics Service',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Track events, user properties, and errors'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isLoading ? null : _trackEvent,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Track Event'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CacheSection extends StatefulWidget {
  const _CacheSection();

  @override
  State<_CacheSection> createState() => _CacheSectionState();
}

class _CacheSectionState extends State<_CacheSection> {
  String? _cachedValue;
  final _cacheManager = getIt<CacheManager>();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💾 Cache Manager',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Multi-layer caching (Memory + Disk)'),
            const SizedBox(height: 12),
            if (_cachedValue != null)
              Text('Cached value: $_cachedValue')
            else
              const Text('No cached value'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _setCacheValue,
                    child: const Text('Set Cache'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _getCacheValue,
                    child: const Text('Get Cache'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearCache,
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setCacheValue() async {
    final value = 'Cached at ${DateTime.now().toString()}';
    await _cacheManager.set('demo_key', value);
    setState(() => _cachedValue = value);
  }

  Future<void> _getCacheValue() async {
    final value = await _cacheManager.get<String>('demo_key');
    setState(() => _cachedValue = value);
  }

  Future<void> _clearCache() async {
    await _cacheManager.remove('demo_key');
    setState(() => _cachedValue = null);
  }
}

class _PerformanceSection extends StatelessWidget {
  const _PerformanceSection();

  @override
  Widget build(BuildContext context) {
    final performance = getIt<PerformanceMonitor>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ Performance Monitor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Measure operation performance'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _simulateSlowOperation(performance),
              child: const Text('Simulate Slow Operation'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _simulateSlowOperation(PerformanceMonitor performance) async {
    await performance.measureOperation(
      'simulate_slow_operation',
      () async {
        // Simulate some work
        await Future.delayed(const Duration(milliseconds: 500));

        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 200));

        return 'Operation completed';
      },
      extra: {'operation_type': 'simulation', 'complexity': 'medium'},
    );
  }
}

class _MemorySection extends StatelessWidget {
  const _MemorySection();

  @override
  Widget build(BuildContext context) {
    final memoryManager = getIt<MemoryManager>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🧠 Memory Manager',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Monitor and manage app memory usage'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => memoryManager.onLowMemoryWarning(),
              child: const Text('Simulate Low Memory'),
            ),
          ],
        ),
      ),
    );
  }
}
