import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

/// Data model for a single hook.
class Hook {
  final String name;
  final String value;
  final String description;

  Hook({
    required this.name,
    required this.value,
    required this.description,
  });

  factory Hook.fromJson(Map<String, dynamic> json) {
    return Hook(
      name: json['hook_name'] ?? '',
      value: json['hook_value'] ?? '',
      description: json['hook_description'] ?? '',
    );
  }
}

/// Service for managing user hooks via the backend API.
class HooksService {
  static final HooksService _instance = HooksService._internal();
  factory HooksService() => _instance;
  HooksService._internal();

  final AuthService _authService = AuthService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _authService.getAccessToken();
    if (token == null) throw Exception('Not authenticated');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Fetch all hooks for the current user.
  Future<List<Hook>> getHooks() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getHooks}'),
      headers: headers,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final hooksList = data['hooks'] as List<dynamic>?;
      if (hooksList == null) return [];
      return hooksList
          .map((h) => Hook.fromJson(h as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please sign in again.');
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['messege'] ?? 'Failed to fetch hooks');
    }
  }

  /// Create a new hook.
  Future<List<Hook>> createHook({
    required String name,
    required String value,
    required String description,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.setHook}'),
      headers: headers,
      body: jsonEncode({
        'hook_name': name,
        'hook_value': value,
        'hook_description': description,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final hooksList = data['hooks'] as List<dynamic>?;
      if (hooksList == null) return [];
      return hooksList
          .map((h) => Hook.fromJson(h as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 409) {
      throw Exception('A hook with this name already exists');
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please sign in again.');
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['messege'] ?? 'Failed to create hook');
    }
  }

  /// Delete a hook by name.
  Future<List<Hook>> deleteHook(String hookName) async {
    final headers = await _authHeaders();
    final request = http.Request(
      'DELETE',
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.deleteHook}'),
    );
    request.headers.addAll(headers);
    request.body = jsonEncode({'deleteHookName': hookName});

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final hooksList = data['hooks'] as List<dynamic>?;
      if (hooksList == null) return [];
      return hooksList
          .map((h) => Hook.fromJson(h as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please sign in again.');
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['messege'] ?? 'Failed to delete hook');
    }
  }
}
