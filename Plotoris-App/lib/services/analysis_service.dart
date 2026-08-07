import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/analysis_models.dart';
import 'auth_service.dart';

/// Service for calling the email analysis API.
class AnalysisService {
  static final AnalysisService _instance = AnalysisService._internal();
  factory AnalysisService() => _instance;
  AnalysisService._internal();

  final AuthService _authService = AuthService();

  /// Trigger an email scan via the backend.
  ///
  /// Calls `GET /api/analysis/email?maxEmails=[maxEmails]`
  /// with the stored JWT access token.
  ///
  /// Returns an [AiAnalysis] on success, or throws on failure.
  Future<ScanResult> analyseEmails({int maxEmails = 10}) async {
    final token = await _authService.getAccessToken();

    if (token == null) {
      throw Exception('Not authenticated. Please sign in again.');
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.analyseEmails}?maxEmails=$maxEmails',
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final aiData = data['aiAnalysis'];
      AiAnalysis? analysis;

      if (aiData != null && aiData is Map<String, dynamic>) {
        if (aiData.containsKey('error')) {
          analysis = AiAnalysis(
            matchedHooks: [],
            emails: [],
            overallSummary: '',
            manualReview: [],
            error: aiData['error'],
          );
        } else {
          analysis = AiAnalysis.fromJson(aiData);
        }
      }

      final emails = data['emails'] as List<dynamic>? ?? [];
      final safe = data['safeEmails'] as List<dynamic>? ?? [];
      final flagged = data['flaggedEmails'] as List<dynamic>? ?? [];

      return ScanResult(
        scans: analysis != null ? [analysis] : [],
        latestScan: analysis,
        totalEmails: emails.length,
        safeEmails: safe.length,
        flaggedEmails: flagged.length,
        scannedAt: DateTime.now(),
      );
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please sign in again.');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Analysis failed');
    }
  }
}
