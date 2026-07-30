// lib/models/guardian_result.dart

class GuardianValidationResult {
  final String guardianStatus; // 'PASS', 'REPAIRED', 'REJECTED'
  final int validationScore; // 0 - 100
  final List<String> violations;
  final List<String> warnings;
  final List<String> autoRepairs;
  final Map<String, dynamic> approvedPatch;
  final bool rollbackRequired;
  final Map<String, dynamic> guardianReport;

  GuardianValidationResult({
    required this.guardianStatus,
    this.validationScore = 100,
    this.violations = const [],
    this.warnings = const [],
    this.autoRepairs = const [],
    required this.approvedPatch,
    this.rollbackRequired = false,
    required this.guardianReport,
  });

  factory GuardianValidationResult.fromJson(Map<String, dynamic> json) {
    return GuardianValidationResult(
      guardianStatus: json['guardian_status'] ?? 'PASS',
      validationScore: json['validation_score'] ?? 100,
      violations: List<String>.from(json['violations'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
      autoRepairs: List<String>.from(json['auto_repairs'] ?? []),
      approvedPatch: Map<String, dynamic>.from(json['approved_patch'] ?? {}),
      rollbackRequired: json['rollback_required'] ?? false,
      guardianReport: Map<String, dynamic>.from(json['guardian_report'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guardian_status': guardianStatus,
      'validation_score': validationScore,
      'violations': violations,
      'warnings': warnings,
      'auto_repairs': autoRepairs,
      'approved_patch': approvedPatch,
      'rollback_required': rollbackRequired,
      'guardian_report': guardianReport,
    };
  }
}
