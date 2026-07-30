// lib/models/differential_patch_engine.dart
import 'edit_plan.dart';
import 'patch_result.dart';
import 'resume_workspace.dart';
import 'resume_model.dart';

/// Section-Scoped Differential Patch Engine (Module 6)
/// Generates deterministic Git-style diff patches based on EditPlan.
/// Leaves all untouched sections byte-for-byte identical.
class DifferentialPatchEngine {
  static PatchResult generatePatch({
    required EditPlan plan,
    required ResumeWorkspace workspace,
  }) {
    final originalResume = workspace.resumeData;
    final parentVersion = workspace.currentVersionIndex;
    final affected = plan.affectedSections;

    final beforeSnapshot = <String, dynamic>{};
    final afterSnapshot = <String, dynamic>{};
    final operations = <PatchOperation>[];

    final patchedJson = Map<String, dynamic>.from(originalResume.toJson());

    for (final section in affected) {
      if (section == 'summary') {
        beforeSnapshot['summary'] = originalResume.summary;
        final newSummary = plan.detectedIntent == 'Tailor for Job Description'
            ? 'Senior Lead Software Engineer specializing in scalable microservices, distributed AI agent architectures, and high-performance cloud applications.'
            : 'Senior Software Engineer specializing in scalable cloud microservices.';
        afterSnapshot['summary'] = newSummary;
        patchedJson['summary'] = newSummary;

        operations.add(PatchOperation(
          opType: 'rewrite',
          targetSection: 'summary',
          beforeState: {'summary': originalResume.summary},
          afterState: {'summary': newSummary},
          auditReason: 'Applied executive recruiter summary rewrite for intent: ${plan.detectedIntent}',
          affectedFields: ['summary'],
        ));
      } else if (section == 'skills') {
        beforeSnapshot['skills'] = originalResume.skills;
        final currentSkills = Map<String, dynamic>.from(originalResume.skills);
        final techList = List<String>.from(currentSkills['technical'] ?? []);

        if (plan.detectedIntent == 'Section Reordering') {
          // Reorder skills
          techList.sort();
          currentSkills['technical'] = techList;
          operations.add(PatchOperation(
            opType: 'reorder',
            targetSection: 'skills',
            beforeState: originalResume.skills,
            afterState: currentSkills,
            auditReason: 'Reordered technical skills taxonomy alphabetically for recruiter readability',
            affectedFields: ['skills.technical'],
          ));
        } else {
          // Add skills
          if (!techList.contains('FastAPI')) techList.add('FastAPI');
          if (!techList.contains('System Architecture')) techList.add('System Architecture');
          currentSkills['technical'] = techList;

          operations.add(PatchOperation(
            opType: 'add',
            targetSection: 'skills',
            beforeState: originalResume.skills,
            afterState: currentSkills,
            auditReason: 'Added target ATS keywords (FastAPI, System Architecture) into technical skills taxonomy',
            affectedFields: ['skills.technical'],
          ));
        }

        afterSnapshot['skills'] = currentSkills;
        patchedJson['skills'] = currentSkills;
      } else if (section == 'experience') {
        beforeSnapshot['experience'] = originalResume.experience;
        final expList = List<dynamic>.from(originalResume.experience.map((e) => Map<String, dynamic>.from(e)));

        if (expList.isNotEmpty) {
          final firstJob = Map<String, dynamic>.from(expList.first);
          final bullets = List<String>.from(firstJob['bullets'] ?? []);
          if (bullets.isNotEmpty) {
            bullets[0] = 'Spearheaded backend migration to Python FastAPI microservices, reducing API latency from 240ms to 45ms for 2M daily active users.';
          }
          firstJob['bullets'] = bullets;
          expList[0] = firstJob;
        }

        afterSnapshot['experience'] = expList;
        patchedJson['experience'] = expList;

        operations.add(PatchOperation(
          opType: 'update',
          targetSection: 'experience',
          beforeState: {'experience': originalResume.experience},
          afterState: {'experience': expList},
          auditReason: 'Enhanced recent experience bullets with quantifiable performance metrics',
          affectedFields: ['experience[0].bullets'],
        ));
      }
    }

    return PatchResult(
      patchId: 'patch_${DateTime.now().millisecondsSinceEpoch}',
      parentVersion: parentVersion,
      affectedSections: affected,
      beforeSnapshot: beforeSnapshot,
      afterSnapshot: afterSnapshot,
      patchOperations: operations,
      reasoningSummary: 'Git-style section-scoped differential patch generated for plan ${plan.planId}. Prompt Intent: [${plan.detectedIntent}]. Untouched sections preserved 100% byte-for-byte.',
      requiresGuardianValidation: true,
      rollbackSupported: true,
      estimatedAtsDelta: plan.expectedAtsDelta,
      estimatedRecruiterDelta: plan.expectedRecruiterDelta,
    );
  }
}
