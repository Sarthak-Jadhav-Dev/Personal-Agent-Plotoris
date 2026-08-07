// Data models for the AI email analysis API response.

/// A single analyzed email with priority, category, deadline, and action.
class AnalyzedEmail {
  final String emailId;
  final String summary;
  final int priority; // 1=low, 2=normal, 3=medium, 4=high, 5=urgent
  final String category;
  final String? deadline; // ISO date or null
  final String? deadlineLabel; // human-readable
  final bool actionRequired;
  final String? action;

  AnalyzedEmail({
    required this.emailId,
    required this.summary,
    required this.priority,
    required this.category,
    this.deadline,
    this.deadlineLabel,
    required this.actionRequired,
    this.action,
  });

  factory AnalyzedEmail.fromJson(Map<String, dynamic> json) {
    return AnalyzedEmail(
      emailId: json['emailId'] ?? '',
      summary: json['summary'] ?? '',
      priority: (json['priority'] as num?)?.toInt() ?? 2,
      category: json['category'] ?? 'other',
      deadline: json['deadline'],
      deadlineLabel: json['deadlineLabel'],
      actionRequired: json['actionRequired'] ?? false,
      action: json['action'],
    );
  }
}

/// A matched hook from the analysis.
class MatchedHook {
  final String hookName;
  final String emailId;
  final String reason;

  MatchedHook({
    required this.hookName,
    required this.emailId,
    required this.reason,
  });

  factory MatchedHook.fromJson(Map<String, dynamic> json) {
    return MatchedHook(
      hookName: json['hookName'] ?? '',
      emailId: json['emailId'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}

/// Full AI analysis result.
class AiAnalysis {
  final List<MatchedHook> matchedHooks;
  final List<AnalyzedEmail> emails;
  final String overallSummary;
  final List<String> manualReview;
  final String? error;

  AiAnalysis({
    required this.matchedHooks,
    required this.emails,
    required this.overallSummary,
    required this.manualReview,
    this.error,
  });

  factory AiAnalysis.fromJson(Map<String, dynamic> json) {
    return AiAnalysis(
      matchedHooks: (json['matchedHooks'] as List<dynamic>?)
              ?.map((e) => MatchedHook.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      emails: (json['emails'] as List<dynamic>?)
              ?.map((e) => AnalyzedEmail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      overallSummary: json['overallSummary'] ?? '',
      manualReview: (json['manualReview'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      error: json['error'],
    );
  }
}

/// Complete scan result from the backend.
class ScanResult {
  final List<AiAnalysis> scans; // history of scans
  final AiAnalysis? latestScan;
  final int totalEmails;
  final int safeEmails;
  final int flaggedEmails;
  final DateTime scannedAt;

  ScanResult({
    required this.scans,
    this.latestScan,
    required this.totalEmails,
    required this.safeEmails,
    required this.flaggedEmails,
    required this.scannedAt,
  });
}
