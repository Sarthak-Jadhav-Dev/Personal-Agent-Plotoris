import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Handles all authentication operations:
/// - Google Sign-In (mobile ID token → backend JWT exchange)
/// - JWT token persistence (SharedPreferences)
/// - Session management
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  // ── Google Sign-In ──────────────────────────────────────────────────

  /// Initiates Google Sign-In, gets ID token, sends to backend,
  /// stores returned JWT tokens.
  ///
  /// Returns a map with user data on success, or throws on failure.
  Future<Map<String, dynamic>> signInWithGoogle() async {
    // Trigger native Google Sign-In UI
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In was cancelled');
    }

    // Get the ID token
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final String? idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('Failed to get Google ID token');
    }

    // Send ID token to backend for verification and JWT exchange
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.googleMobileAuth}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Store tokens
      await _storeTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );

      // Store user data
      await _storeUserData(data['user']);

      return data['user'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Authentication failed');
    }
  }

  // ── Token Management ────────────────────────────────────────────────

  Future<void> _storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.accessTokenKey, accessToken);
    await prefs.setString(ApiConfig.refreshTokenKey, refreshToken);
  }

  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.userDataKey, jsonEncode(userData));
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConfig.accessTokenKey);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(ApiConfig.userDataKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  /// Check if user has stored tokens (session exists).
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all stored auth data and sign out of Google.
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.accessTokenKey);
    await prefs.remove(ApiConfig.refreshTokenKey);
    await prefs.remove(ApiConfig.userDataKey);

    // Sign out of Google as well
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore errors during Google sign-out
    }
  }
}
