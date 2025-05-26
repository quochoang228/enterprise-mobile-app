import 'package:injectable/injectable.dart';

/// Token manager for handling JWT tokens
@singleton
class TokenManager {
  const TokenManager();

  Future<String?> getAccessToken() async {
    // Get access token from secure storage
    return null;
  }

  Future<String?> getRefreshToken() async {
    // Get refresh token from secure storage
    return null;
  }

  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    // Store tokens securely
  }

  Future<void> clearTokens() async {
    // Clear all tokens
  }

  Future<bool> isTokenValid(String token) async {
    // Check if token is valid and not expired
    return false;
  }
}
