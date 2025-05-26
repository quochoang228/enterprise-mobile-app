/// Validation utilities for input validation

class Validators {
  Validators._();

  /// Email validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Password validation - at least 8 characters with letters and numbers
  static bool isValidPassword(String password) {
    if (password.length < 8) return false;
    return RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$',
    ).hasMatch(password);
  }

  /// Phone number validation
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

  /// URL validation
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Check if string is not null or empty
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Minimum length validation
  static bool hasMinLength(String value, int minLength) {
    return value.length >= minLength;
  }

  /// Maximum length validation
  static bool hasMaxLength(String value, int maxLength) {
    return value.length <= maxLength;
  }
}
