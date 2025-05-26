import 'package:injectable/injectable.dart';

/// Application logger for structured logging
@singleton
class AppLogger {
  const AppLogger();

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    // Log debug messages
    print('[DEBUG] $message');
    if (error != null) print('[DEBUG] Error: $error');
  }

  void info(String message, [Object? error, StackTrace? stackTrace]) {
    // Log info messages
    print('[INFO] $message');
    if (error != null) print('[INFO] Error: $error');
  }

  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    // Log warning messages
    print('[WARNING] $message');
    if (error != null) print('[WARNING] Error: $error');
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    // Log error messages
    print('[ERROR] $message');
    if (error != null) print('[ERROR] Error: $error');
    if (stackTrace != null) print('[ERROR] StackTrace: $stackTrace');
  }

  void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    // Log fatal errors
    print('[FATAL] $message');
    if (error != null) print('[FATAL] Error: $error');
    if (stackTrace != null) print('[FATAL] StackTrace: $stackTrace');
  }
}
