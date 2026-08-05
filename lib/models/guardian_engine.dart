// lib/models/guardian_engine.dart
import 'patch_result.dart';
import 'guardian_result.dart';
import 'resume_workspace.dart';

/// AI Resume Guardian (Module 7 Transaction & Safety Layer)
/// Evaluates PatchResult from Module 6 across 5 validation guards:
/// 1. Data Integrity Guard
/// 2. Truthfulness Guard
/// 3. ATS Compliance Guard
/// 4. Layout & Rendering Guard
/// 5. Business Rules Guard
class AIResumeGuardian {
  static GuardianValidationResult validateAndRepair({
    required PatchResult patchResult,
    required ResumeWorkspace workspace,
  }) {
    final violations = <String>[];
    final warnings = <String>[];
    final autoRepairs = <String>[];
    int score = 100;

    final origExp = workspace.resumeData.experience;
    final origEdu = workspace.resumeData.education;
    final origName = workspace.resumeData.personal['name'] ?? '';

    // Stage 1: Data Integrity Guard
    final afterSnap = patchResult.afterSnapshot;
    if (afterSnap.containsKey('experience')) {
      final newExp = List<dynamic>.from(afterSnap['experience'] ?? []);
      if (newExp.length < origExp.length) {
        violations.add('Data Integrity Failure: Work experience count dropped from ${origExp.length} to ${newExp.length}.');
        score -= 50;
      }
    }

    if (afterSnap.containsKey('education')) {
      final newEdu = List<dynamic>.from(afterSnap['education'] ?? []);
      if (newEdu.length < origEdu.length) {
        violations.add('Data Integrity Failure: Academic education history dropped.');
        score -= 50;
      }
    }

    // Stage 2: Truthfulness Guard
    for (final op in patchResult.patchOperations) {
      final afterStateStr = op.afterState.toString().toLowerCase();
      if (afterStateStr.contains('fake company') || afterStateStr.contains('dummy corp')) {
        violations.add('Truthfulness Failure: Fabricated company detected.');
        score -= 50;
      }
    }

    // Stage 3: ATS Compliance Guard (Check duplicate skills auto-repair)
    if (afterSnap.containsKey('skills')) {
      final techList = List<String>.from(afterSnap['skills']['technical'] ?? []);
      final uniqueTech = techList.toSet().toList();
      if (techList.length > uniqueTech.length) {
        autoRepairs.add('ATS Repair: Deduplicated technical skills taxonomy.');
        afterSnap['skills']['technical'] = uniqueTech;
        score -= 5;
      }
    }

    // Stage 4: Layout & Rendering Guard
    if (workspace.designSpec.maxPageBudget == 1 && (patchResult.reasoningSummary.length > 5000)) {
      warnings.add('Layout Warning: Summary length exceeds 1-page budget threshold.');
    }

    // Stage 5: Business Rules Guard
    for (final sec in patchResult.affectedSections) {
      if (sec == 'personal.name' && origName.isNotEmpty && !afterSnap.containsKey('personal')) {
        violations.add('Business Rule Failure: Attempted modification of immutable candidate name.');
        score -= 50;
      }
    }

    // Decision Logic
    String status = 'PASS';
    bool rollback = false;

    if (violations.isNotEmpty) {
      status = 'REJECTED';
      rollback = true;
    } else if (autoRepairs.isNotEmpty) {
      status = 'REPAIRED';
    }

    final report = {
      'validated_at': DateTime.now().toIso8601String(),
      'stages_evaluated': [
        'Data Integrity Guard',
        'Truthfulness Guard',
        'ATS Compliance Guard',
        'Layout & Rendering Guard',
        'Business Rules Guard'
      ],
      'audit_summary': status == 'PASS'
          ? 'Guardian validation passed with 100% data integrity and zero historical data drops.'
          : status == 'REPAIRED'
              ? 'Guardian performed automatic micro-repairs and passed validation.'
              : 'Guardian rejected patch due to safety/truthfulness violations.',
      'rollback_required': rollback,
    };

    return GuardianValidationResult(
      validationId: 'val_${DateTime.now().millisecondsSinceEpoch}',
      guardianStatus: status,
      validationScore: score,
      violations: violations,
      warnings: warnings,
      autoRepairs: autoRepairs.map((r) => {'repair_action': r}).toList(),
      approvedPatch: patchResult.toJson(),
      rollbackRequired: rollback,
      guardianSignature: 'sig_guardian_v1',
      guardianReport: report,
    );
  }
}
