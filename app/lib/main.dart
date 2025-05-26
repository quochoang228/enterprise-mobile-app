import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'app/app.dart';
import 'di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (if needed)
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // Setup dependency injection (this also initializes analytics and other services)
  await configureDependencies();

  // Initialize error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    final analytics = getIt<AnalyticsService>();
    analytics.recordError(
      details.exception,
      details.stack,
      extra: {
        'context': details.context?.toString(),
        'library': details.library,
      },
    );
  };

  runApp(const ProviderScope(child: App()));
}
