// lib/models/patch_result.dart

class PatchOperation {
  final String opType; // 'rewrite', 'add', 'update', 'reorder', 'merge', 'delete'
  final String targetSection;
  final Map<String, dynamic> beforeState;
  final Map<String, dynamic> afterState;
  final String auditReason;
  final List<String> affectedFields;

  PatchOperation({
    required this.opType,
    required this.targetSection,
    required this.beforeState,
    required this.afterState,
    required this.auditReason,
    required this.affectedFields,
  });

  factory PatchOperation.fromJson(Map<String, dynamic> json) {
    return PatchOperation(
      opType: json['op_type'] ?? 'update',
      targetSection: json['target_section'] ?? 'summary',
      beforeState: Map<String, dynamic>.from(json['before_state'] ?? {}),
      afterState: Map<String, dynamic>.from(json['after_state'] ?? {}),
      auditReason: json['audit_reason'] ?? 'Section-scoped differential mutation',
      affectedFields: List<String>.from(json['affected_fields'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'op_type': opType,
      'target_section': targetSection,
      'before_state': beforeState,
      'after_state': afterState,
      'audit_reason': auditReason,
      'affected_fields': affectedFields,
    };
  }
}

class PatchResult {
  final String patchId;
  final int parentVersion;
  final List<String> affectedSections;
  final Map<String, dynamic> beforeSnapshot;
  final Map<String, dynamic> afterSnapshot;
  final List<PatchOperation> patchOperations;
  final String reasoningSummary;
  final bool requiresGuardianValidation;
  final bool rollbackSupported;
  final int estimatedAtsDelta;
  final String estimatedRecruiterDelta;

  PatchResult({
    required this.patchId,
    required this.parentVersion,
    required this.affectedSections,
    required this.beforeSnapshot,
    required this.afterSnapshot,
    required this.patchOperations,
    required this.reasoningSummary,
    this.requiresGuardianValidation = true,
    this.rollbackSupported = true,
    this.estimatedAtsDelta = 8,
    this.estimatedRecruiterDelta = '+1.5/10',
  });

  factory PatchResult.fromJson(Map<String, dynamic> json) {
    return PatchResult(
      patchId: json['patch_id'] ?? 'patch_01',
      parentVersion: json['parent_version'] ?? 0,
      affectedSections: List<String>.from(json['affected_sections'] ?? []),
      beforeSnapshot: Map<String, dynamic>.from(json['before_snapshot'] ?? {}),
      afterSnapshot: Map<String, dynamic>.from(json['after_snapshot'] ?? {}),
      patchOperations: (json['patch_operations'] as List? ?? [])
          .map((e) => PatchOperation.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      reasoningSummary: json['reasoning_summary'] ?? 'Git-style section-scoped patch produced by Module 6.',
      requiresGuardianValidation: json['requires_guardian_validation'] ?? true,
      rollbackSupported: json['rollback_supported'] ?? true,
      estimatedAtsDelta: json['estimated_ats_delta'] ?? 8,
      estimatedRecruiterDelta: json['estimated_recruiter_delta'] ?? '+1.5/10',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patch_id': patchId,
      'parent_version': parentVersion,
      'affected_sections': affectedSections,
      'before_snapshot': beforeSnapshot,
      'after_snapshot': afterSnapshot,
      'patch_operations': patchOperations.map((e) => e.toJson()).toList(),
      'reasoning_summary': reasoningSummary,
      'requires_guardian_validation': requiresGuardianValidation,
      'rollback_supported': rollbackSupported,
      'estimated_ats_delta': estimatedAtsDelta,
      'estimated_recruiter_delta': estimatedRecruiterDelta,
    };
  }
}
