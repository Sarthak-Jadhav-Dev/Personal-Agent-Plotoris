/// API configuration constants for the Plotoris app.
///
/// Change [baseUrl] to point to your backend server.
/// For Android emulator → localhost, use 10.0.2.2
/// For physical device on same network, use your machine's local IP.
class ApiConfig {
  // Android emulator maps 10.0.2.2 to host machine's localhost
  static const String baseUrl = 'http://10.0.2.2:8000';

  // Auth endpoints
  static const String googleMobileAuth = '/api/auth/google/mobile';

  // Analysis endpoints
  static const String analyseEmails = '/api/analysis/email';

  // Hooks endpoints
  static const String getHooks = '/api/hooks/getHooks';
  static const String setHook = '/api/hooks/setHook';
  static const String deleteHook = '/api/hooks/deleteHook';

  // Token storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
}
