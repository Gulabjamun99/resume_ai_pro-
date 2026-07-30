// lib/models/suggestion_model.dart

class AutoSuggestion {
  final String id;
  final String title;
  final String priority; // 'Critical', 'High', 'Medium', 'Low'
  final String category; // 'ATS', 'Recruiter', 'Writing', 'Career', 'Design'
  final String confidenceTier; // 'High Confidence', 'Medium Confidence', 'Needs User Confirmation'
  final String whySuggesting;
  final String whatWillChange;
  final String howItImprovesChances;
  final String evidence;
  final int estimatedAtsImprovement;
  final String estimatedRecruiterImprovement;
  final Map<String, dynamic> expectedImpact;
  final List<String> affectedSections;
  final String prompt;
  final List<String> actions; // ['Apply', 'Preview', 'Dismiss']
  final Map<String, dynamic> previewPatch;
  bool isApplied;
  bool isDismissed;

  AutoSuggestion({
    required this.id,
    required this.title,
    this.priority = 'High',
    required this.category,
    this.confidenceTier = 'High Confidence',
    required this.whySuggesting,
    required this.whatWillChange,
    required this.howItImprovesChances,
    required this.evidence,
    this.estimatedAtsImprovement = 8,
    this.estimatedRecruiterImprovement = '+1.5/10',
    required this.expectedImpact,
    required this.affectedSections,
    required this.prompt,
    this.actions = const ['Apply', 'Preview', 'Dismiss'],
    required this.previewPatch,
    this.isApplied = false,
    this.isDismissed = false,
  });

  factory AutoSuggestion.fromJson(Map<String, dynamic> json) {
    return AutoSuggestion(
      id: json['id'] ?? 'sug_01',
      title: json['title'] ?? 'Optimization Suggestion',
      priority: json['priority'] ?? 'High',
      category: json['category'] ?? 'ATS',
      confidenceTier: json['confidence_tier'] ?? 'High Confidence',
      whySuggesting: json['why_suggesting'] ?? 'Recruiter Intelligence Gap Analysis',
      whatWillChange: json['what_will_change'] ?? 'Refines relevant resume sections',
      howItImprovesChances: json['how_it_improves_chances'] ?? 'Increases ATS alignment and recruiter readability',
      evidence: json['evidence'] ?? 'Evidence-based intelligence analysis',
      estimatedAtsImprovement: json['estimated_ats_improvement'] ?? 8,
      estimatedRecruiterImprovement: json['estimated_recruiter_improvement'] ?? '+1.5/10',
      expectedImpact: Map<String, dynamic>.from(json['expected_impact'] ?? {}),
      affectedSections: List<String>.from(json['affected_sections'] ?? []),
      prompt: json['prompt'] ?? '',
      actions: List<String>.from(json['actions'] ?? ['Apply', 'Preview', 'Dismiss']),
      previewPatch: Map<String, dynamic>.from(json['preview_patch'] ?? {}),
      isApplied: json['is_applied'] ?? false,
      isDismissed: json['is_dismissed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'category': category,
      'confidence_tier': confidenceTier,
      'why_suggesting': whySuggesting,
      'what_will_change': whatWillChange,
      'how_it_improves_chances': howItImprovesChances,
      'evidence': evidence,
      'estimated_ats_improvement': estimatedAtsImprovement,
      'estimated_recruiter_improvement': estimatedRecruiterImprovement,
      'expected_impact': expectedImpact,
      'affected_sections': affectedSections,
      'prompt': prompt,
      'actions': actions,
      'preview_patch': previewPatch,
      'is_applied': isApplied,
      'is_dismissed': isDismissed,
    };
  }
}
