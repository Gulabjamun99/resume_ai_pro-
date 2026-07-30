// lib/models/edit_plan.dart

class EditPlan {
  final String planId;
  final String detectedIntent;
  final String reasoning;
  final List<String> affectedSections;
  final List<String> immutableSections;
  final bool requiredFollowup;
  final String followupQuestion;
  final double confidenceLevel;
  final int expectedAtsDelta;
  final String expectedRecruiterDelta;
  final Map<String, dynamic> safetyConstraints;
  final List<String> executionOrder;
  final bool rollbackPossible;

  EditPlan({
    required this.planId,
    required this.detectedIntent,
    required this.reasoning,
    required this.affectedSections,
    this.immutableSections = const ['personal.name', 'education', 'contact'],
    this.requiredFollowup = false,
    this.followupQuestion = '',
    this.confidenceLevel = 0.95,
    this.expectedAtsDelta = 8,
    this.expectedRecruiterDelta = '+1.5/10',
    required this.safetyConstraints,
    required this.executionOrder,
    this.rollbackPossible = true,
  });

  factory EditPlan.fromJson(Map<String, dynamic> json) {
    return EditPlan(
      planId: json['plan_id'] ?? 'plan_01',
      detectedIntent: json['detected_intent'] ?? 'ATS Optimization',
      reasoning: json['reasoning'] ?? 'Cognitive edit planning based on candidate workspace state.',
      affectedSections: List<String>.from(json['affected_sections'] ?? []),
      immutableSections: List<String>.from(json['immutable_sections'] ?? ['personal.name', 'education']),
      requiredFollowup: json['required_followup'] ?? false,
      followupQuestion: json['followup_question'] ?? '',
      confidenceLevel: (json['confidence_level'] as num?)?.toDouble() ?? 0.95,
      expectedAtsDelta: json['expected_ats_delta'] ?? 8,
      expectedRecruiterDelta: json['expected_recruiter_delta'] ?? '+1.5/10',
      safetyConstraints: Map<String, dynamic>.from(json['safety_constraints'] ?? {}),
      executionOrder: List<String>.from(json['execution_order'] ?? []),
      rollbackPossible: json['rollback_possible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'detected_intent': detectedIntent,
      'reasoning': reasoning,
      'affected_sections': affectedSections,
      'immutable_sections': immutableSections,
      'required_followup': requiredFollowup,
      'followup_question': followupQuestion,
      'confidence_level': confidenceLevel,
      'expected_ats_delta': expectedAtsDelta,
      'expected_recruiter_delta': expectedRecruiterDelta,
      'safety_constraints': safetyConstraints,
      'execution_order': executionOrder,
      'rollback_possible': rollbackPossible,
    };
  }
}
