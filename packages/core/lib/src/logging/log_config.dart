import 'package:injectable/injectable.dart';

/// Configuration for logging system
@singleton
class LogConfig {
  const LogConfig();

  bool get isDebugMode => true; // Should be environment-based

  bool get enableFileLogging => true;

  bool get enableRemoteLogging => false;

  String get logLevel => 'debug'; // debug, info, warning, error, fatal

  int get maxLogFileSize => 10 * 1024 * 1024; // 10MB

  int get maxLogFiles => 5;
}
