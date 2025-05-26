/// Common constants used throughout the application

class AppConstants {
  AppConstants._();

  // API Constants
  static const String apiVersion = 'v1';
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 24);

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';

  // Cache Keys
  static const String userCacheKey = 'user_cache';
  static const String contentCacheKey = 'content_cache';

  // Error Messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String authError = 'Authentication failed';
  static const String unknownError = 'An unknown error occurred';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxUsernameLength = 30;
  static const int maxBioLength = 500;
}
