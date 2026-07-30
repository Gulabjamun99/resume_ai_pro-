// lib/models/guardian_result.dart

class GuardianValidationResult {
  final String validationId;
  final String guardianStatus; // 'PASS', 'REPAIRED', 'REJECTED'
  final int validationScore; // 0 - 100
  final double confidenceScore; // 0.0 - 1.0
  final List<String> violations;
  final List<String> warnings;
  final List<Map<String, dynamic>> autoRepairs;
  final Map<String, dynamic> sectionValidationResults;
  final Map<String, dynamic> approvedPatch;
  final bool rollbackRequired;
  final String guardianSignature;
  final Map<String, bool> commitReadiness;
  final Map<String, dynamic> validationTrace;
  final Map<String, dynamic> guardianReport;

  GuardianValidationResult({
    required this.validationId,
    required this.guardianStatus,
    this.validationScore = 100,
    this.confidenceScore = 0.98,
    this.violations = const [],
    this.warnings = const [],
    this.autoRepairs = const [],
    this.sectionValidationResults = const {},
    required this.approvedPatch,
    this.rollbackRequired = false,
    required this.guardianSignature,
    this.commitReadiness = const {'ready_for_commit': true, 'ready_for_render': true, 'ready_for_version_history': true},
    this.validationTrace = const {},
    required this.guardianReport,
  });

  factory GuardianValidationResult.fromJson(Map<String, dynamic> json) {
    return GuardianValidationResult(
      validationId: json['validation_id'] ?? 'val_01',
      guardianStatus: json['guardian_status'] ?? 'PASS',
      validationScore: json['validation_score'] ?? 100,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.98,
      violations: List<String>.from(json['violations'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
      autoRepairs: (json['auto_repairs'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      sectionValidationResults: Map<String, dynamic>.from(json['section_validation_results'] ?? {}),
      approvedPatch: Map<String, dynamic>.from(json['approved_patch'] ?? {}),
      rollbackRequired: json['rollback_required'] ?? false,
      guardianSignature: json['guardian_signature'] ?? '',
      commitReadiness: Map<String, bool>.from(json['commit_readiness'] ?? {}),
      validationTrace: Map<String, dynamic>.from(json['validation_trace'] ?? {}),
      guardianReport: Map<String, dynamic>.from(json['guardian_report'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'validation_id': validationId,
      'guardian_status': guardianStatus,
      'validation_score': validationScore,
      'confidence_score': confidenceScore,
      'violations': violations,
      'warnings': warnings,
      'auto_repairs': autoRepairs,
      'section_validation_results': sectionValidationResults,
      'approved_patch': approvedPatch,
      'rollback_required': rollbackRequired,
      'guardian_signature': guardianSignature,
      'commit_readiness': commitReadiness,
      'validation_trace': validationTrace,
      'guardian_report': guardianReport,
    };
  }
}
