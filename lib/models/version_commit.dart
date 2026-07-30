// lib/models/version_commit.dart

class VersionCommit {
  final String versionId; // e.g. 'v1', 'v2'
  final int versionIndex; // 0, 1, 2...
  final int parentVersionIndex;
  final String timestamp;
  final String author; // 'AI Assistant', 'User'
  final String triggerPrompt;
  final String commitMessage;
  final String patchId;
  final String guardianValidationId;
  final String guardianSignature;
  final String renderFingerprint;
  final String healthReportId;
  final double atsScore;
  final double recruiterScore;
  final double overallHealthScore;
  final Map<String, dynamic> differentialSnapshot; // Changed sections only
  final Map<String, dynamic> fullResumeSnapshot; // Deterministic reconstructed snapshot

  VersionCommit({
    required this.versionId,
    required this.versionIndex,
    required this.parentVersionIndex,
    required this.timestamp,
    required this.author,
    required this.triggerPrompt,
    required this.commitMessage,
    required this.patchId,
    required this.guardianValidationId,
    required this.guardianSignature,
    required this.renderFingerprint,
    required this.healthReportId,
    required this.atsScore,
    required this.recruiterScore,
    required this.overallHealthScore,
    required this.differentialSnapshot,
    required this.fullResumeSnapshot,
  });

  factory VersionCommit.fromJson(Map<String, dynamic> json) {
    return VersionCommit(
      versionId: json['version_id'] ?? 'v0',
      versionIndex: json['version_index'] ?? 0,
      parentVersionIndex: json['parent_version_index'] ?? 0,
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      author: json['author'] ?? 'AI Assistant',
      triggerPrompt: json['trigger_prompt'] ?? 'Initial Upload',
      commitMessage: json['commit_message'] ?? 'Initial baseline resume committed.',
      patchId: json['patch_id'] ?? '',
      guardianValidationId: json['guardian_validation_id'] ?? '',
      guardianSignature: json['guardian_signature'] ?? '',
      renderFingerprint: json['render_fingerprint'] ?? '',
      healthReportId: json['health_report_id'] ?? '',
      atsScore: (json['ats_score'] as num?)?.toDouble() ?? 90.0,
      recruiterScore: (json['recruiter_score'] as num?)?.toDouble() ?? 9.0,
      overallHealthScore: (json['overall_health_score'] as num?)?.toDouble() ?? 90.0,
      differentialSnapshot: Map<String, dynamic>.from(json['differential_snapshot'] ?? {}),
      fullResumeSnapshot: Map<String, dynamic>.from(json['full_resume_snapshot'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version_id': versionId,
      'version_index': versionIndex,
      'parent_version_index': parentVersionIndex,
      'timestamp': timestamp,
      'author': author,
      'trigger_prompt': triggerPrompt,
      'commit_message': commitMessage,
      'patch_id': patchId,
      'guardian_validation_id': guardianValidationId,
      'guardian_signature': guardianSignature,
      'render_fingerprint': renderFingerprint,
      'health_report_id': healthReportId,
      'ats_score': atsScore,
      'recruiter_score': recruiterScore,
      'overall_health_score': overallHealthScore,
      'differential_snapshot': differentialSnapshot,
      'full_resume_snapshot': fullResumeSnapshot,
    };
  }
}
