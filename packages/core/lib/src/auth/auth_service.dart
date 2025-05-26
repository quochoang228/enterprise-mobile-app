import 'package:injectable/injectable.dart';

/// Authentication service for handling auth operations
@singleton
class AuthService {
  const AuthService();

  Future<bool> isUserLoggedIn() async {
    // Check if user is logged in
    return false;
  }

  Future<void> clearAuthData() async {
    // Clear authentication data
  }

  Future<String?> getAccessToken() async {
    // Get current access token
    return null;
  }

  Future<void> setAccessToken(String token) async {
    // Set access token
  }
}
