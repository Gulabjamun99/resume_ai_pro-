// lib/models/cognitive_engine.dart
import 'edit_plan.dart';
import 'resume_workspace.dart';

/// Intent Classifier supporting English, Hindi, and Hinglish prompts.
class IntentClassifier {
  static String classify(String userPrompt) {
    final p = userPrompt.lowerCaseTrim();
    if (p.contains('google') || p.contains('amazon') || p.contains('faang') || p.contains('jd') || p.contains('job description')) {
      return 'Tailor for Job Description';
    } else if (p.contains('chhoti') || p.contains('shorten') || p.contains('summary') || p.contains('rewrite')) {
      return 'Rewrite';
    } else if (p.contains('add') || p.contains('jodo') || p.contains('include') || p.contains('certif')) {
      return 'Add Information';
    } else if (p.contains('delete') || p.contains('hata') || p.contains('remove')) {
      return 'Delete Information';
    } else if (p.contains('ats') || p.contains('keyword')) {
      return 'ATS Optimization';
    } else if (p.contains('recruiter') || p.contains('senior') || p.contains('executive')) {
      return 'Recruiter Optimization';
    } else if (p.contains('skill') || p.contains('upar')) {
      return 'Section Reordering';
    } else if (p.contains('grammar') || p.contains('english')) {
      return 'Grammar Improvement';
    } else if (p.contains('template') || p.contains('layout') || p.contains('one page')) {
      return 'Design/Layout Change';
    } else {
      return 'Career Coaching';
    }
  }
}

extension StringUtils on String {
  String lowerCaseTrim() => toLowerCase().trim();
}

/// Context Builder that gathers full context from ResumeWorkspace without mutating it.
class ResumeContextBuilder {
  static Map<String, dynamic> buildContext(ResumeWorkspace workspace) {
    return {
      'resume_data': workspace.resumeData.toJson(),
      'intelligence_graph': workspace.intelligenceGraph.toJson(),
      'candidate_goal': workspace.candidateGoal,
      'session_memory': workspace.sessionMemory,
      'recruiter_impact_score': workspace.recruiterImpactScore,
      'ats_score': workspace.health.atsScore,
    };
  }
}

/// Follow-up Decision Engine that detects missing information and asks at most one question.
class FollowUpDecisionEngine {
  static Map<String, dynamic> evaluate(String intent, String userPrompt, Map<String, dynamic> context) {
    if (intent == 'Add Information' && !userPrompt.contains('202') && !userPrompt.contains('year') && !userPrompt.contains('month')) {
      if (userPrompt.toLowerCase().contains('consultant') || userPrompt.toLowerCase().contains('freelance')) {
        return {
          'required_followup': true,
          'followup_question': 'You mentioned consulting experience — approximately how many clients or project dates should we include?'
        };
      }
    }
    return {
      'required_followup': false,
      'followup_question': ''
    };
  }
}

/// Plan Validator that verifies non-destructive constraints on immutable sections.
class PlanValidator {
  static bool validate(EditPlan plan, ResumeWorkspace workspace) {
    for (final sec in plan.immutableSections) {
      if (plan.affectedSections.contains(sec)) {
        return false; // Violates immutable section rule
      }
    }
    return true;
  }
}

/// Core Cognitive Thinking Engine Top-Level Orchestrator.
class CognitiveThinkingEngine {
  static EditPlan planEdit({
    required String userPrompt,
    required ResumeWorkspace workspace,
  }) {
    // 1. Build Context
    final context = ResumeContextBuilder.buildContext(workspace);

    // 2. Classify Intent
    final intent = IntentClassifier.classify(userPrompt);

    // 3. Evaluate Follow-up Need
    final followup = FollowUpDecisionEngine.evaluate(intent, userPrompt, context);

    // 4. Construct Affected Sections
    final affected = <String>[];
    if (intent == 'Tailor for Job Description') {
      affected.addAll(['summary', 'skills', 'experience']);
    } else if (intent == 'Rewrite') {
      affected.add('summary');
    } else if (intent == 'Add Information') {
      affected.addAll(['experience', 'skills']);
    } else if (intent == 'Section Reordering') {
      affected.add('skills');
    } else {
      affected.addAll(['summary', 'experience']);
    }

    final plan = EditPlan(
      planId: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      detectedIntent: intent,
      reasoning: 'Executive recruiter cognitive pipeline evaluated prompt "${userPrompt}" against candidate goal "${workspace.candidateGoal}". Affected sections: ${affected.join(', ')}.',
      affectedSections: affected,
      immutableSections: ['personal.name', 'education', 'contact'],
      requiredFollowup: followup['required_followup'] ?? false,
      followupQuestion: followup['followup_question'] ?? '',
      confidenceLevel: 0.96,
      expectedAtsDelta: intent == 'Tailor for Job Description' ? 14 : 8,
      expectedRecruiterDelta: intent == 'Recruiter Optimization' ? '+2.0/10' : '+1.4/10',
      safetyConstraints: {
        'no_hallucination': true,
        'preserve_education': true,
        'zero_data_loss': true
      },
      executionOrder: ['audit_context', 'prepare_differential_patch', 'guardian_validation'],
      rollbackPossible: true,
    );

    // 5. Validate Plan Safety
    final isSafe = PlanValidator.validate(plan, workspace);
    if (!isSafe) {
      throw Exception('Cognitive plan safety check failed: Attempted modification of immutable sections.');
    }

    return plan;
  }
}
