// lib/models/health_model.dart

class ResumeHealth {
  final int atsScore; // 0 - 100
  final int grammarScore; // 0 - 100
  final int readabilityScore; // 0 - 100
  final String leadershipRating; // e.g. "8.5/10"
  final String technicalDepth; // e.g. "9.0/10"
  final int businessImpactScore; // 0 - 100
  final int actionVerbCount; // Number of strong action verbs
  final String timelineConsistency; // e.g. "Consistent Timeline"
  final List<String> missingKeywords;
  final List<String> weakPhrases;

  ResumeHealth({
    this.atsScore = 88,
    this.grammarScore = 95,
    this.readabilityScore = 90,
    this.leadershipRating = '8.0/10',
    this.technicalDepth = '8.5/10',
    this.businessImpactScore = 86,
    this.actionVerbCount = 14,
    this.timelineConsistency = 'Consistent',
    this.missingKeywords = const [],
    this.weakPhrases = const [],
  });

  factory ResumeHealth.fromJson(Map<String, dynamic> json) {
    return ResumeHealth(
      atsScore: json['ats_score'] ?? 88,
      grammarScore: json['grammar_score'] ?? 95,
      readabilityScore: json['readability_score'] ?? 90,
      leadershipRating: json['leadership_rating'] ?? '8.0/10',
      technicalDepth: json['technical_depth'] ?? '8.5/10',
      businessImpactScore: json['business_impact_score'] ?? 86,
      actionVerbCount: json['action_verb_count'] ?? 14,
      timelineConsistency: json['timeline_consistency'] ?? 'Consistent',
      missingKeywords: List<String>.from(json['missing_keywords'] ?? []),
      weakPhrases: List<String>.from(json['weak_phrases'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ats_score': atsScore,
      'grammar_score': grammarScore,
      'readability_score': readabilityScore,
      'leadership_rating': leadershipRating,
      'technical_depth': technicalDepth,
      'business_impact_score': businessImpactScore,
      'action_verb_count': actionVerbCount,
      'timeline_consistency': timelineConsistency,
      'missing_keywords': missingKeywords,
      'weak_phrases': weakPhrases,
    };
  }
}
