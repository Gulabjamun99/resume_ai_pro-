// lib/models/health_report.dart

class HealthMetricDimension {
  final String dimensionName;
  final double score; // 0 - 100 or 0 - 10
  final String status; // 'EXCELLENT', 'GOOD', 'NEEDS_IMPROVEMENT', 'CRITICAL'
  final List<String> evidence;
  final String reasoning;
  final double confidence; // 0.0 - 1.0
  final List<String> improvementRecommendations;
  final String expectedImpactAfterFixes;
  final String historicalComparison; // e.g. "+5 points vs Version 0"

  HealthMetricDimension({
    required this.dimensionName,
    required this.score,
    required this.status,
    required this.evidence,
    required this.reasoning,
    required this.confidence,
    required this.improvementRecommendations,
    required this.expectedImpactAfterFixes,
    required this.historicalComparison,
  });

  factory HealthMetricDimension.fromJson(Map<String, dynamic> json) {
    return HealthMetricDimension(
      dimensionName: json['dimension_name'] ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'GOOD',
      evidence: List<String>.from(json['evidence'] ?? []),
      reasoning: json['reasoning'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.95,
      improvementRecommendations: List<String>.from(json['improvement_recommendations'] ?? []),
      expectedImpactAfterFixes: json['expected_impact_after_fixes'] ?? '',
      historicalComparison: json['historical_comparison'] ?? 'Baseline Version',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dimension_name': dimensionName,
      'score': score,
      'status': status,
      'evidence': evidence,
      'reasoning': reasoning,
      'confidence': confidence,
      'improvement_recommendations': improvementRecommendations,
      'expected_impact_after_fixes': expectedImpactAfterFixes,
      'historical_comparison': historicalComparison,
    };
  }
}

class HealthReport {
  final String reportId;
  final int resumeVersion;
  final double overallHealthScore; // 0 - 100
  final double atsCompatibilityScore; // 0 - 100
  final double recruiterImpactScore; // 0 - 10
  final Map<String, HealthMetricDimension> dimensions;
  final List<String> criticalWeaknesses;
  final List<String> topStrengths;
  final String executiveSummary;
  final String timestamp;

  HealthReport({
    required this.reportId,
    required this.resumeVersion,
    required this.overallHealthScore,
    required this.atsCompatibilityScore,
    required this.recruiterImpactScore,
    required this.dimensions,
    required this.criticalWeaknesses,
    required this.topStrengths,
    required this.executiveSummary,
    required this.timestamp,
  });

  factory HealthReport.fromJson(Map<String, dynamic> json) {
    final dimsRaw = json['dimensions'] as Map<String, dynamic>? ?? {};
    final dims = <String, HealthMetricDimension>{};
    dimsRaw.forEach((k, v) {
      dims[k] = HealthMetricDimension.fromJson(Map<String, dynamic>.from(v));
    });

    return HealthReport(
      reportId: json['report_id'] ?? 'health_01',
      resumeVersion: json['resume_version'] ?? 0,
      overallHealthScore: (json['overall_health_score'] as num?)?.toDouble() ?? 92.0,
      atsCompatibilityScore: (json['ats_compatibility_score'] as num?)?.toDouble() ?? 94.0,
      recruiterImpactScore: (json['recruiter_impact_score'] as num?)?.toDouble() ?? 9.0,
      dimensions: dims,
      criticalWeaknesses: List<String>.from(json['critical_weaknesses'] ?? []),
      topStrengths: List<String>.from(json['top_strengths'] ?? []),
      executiveSummary: json['executive_summary'] ?? 'Comprehensive multi-dimensional health audit completed.',
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    final dimsJson = <String, dynamic>{};
    dimensions.forEach((k, v) {
      dimsJson[k] = v.toJson();
    });

    return {
      'report_id': reportId,
      'resume_version': resumeVersion,
      'overall_health_score': overallHealthScore,
      'ats_compatibility_score': atsCompatibilityScore,
      'recruiter_impact_score': recruiterImpactScore,
      'dimensions': dimsJson,
      'critical_weaknesses': criticalWeaknesses,
      'top_strengths': topStrengths,
      'executive_summary': executiveSummary,
      'timestamp': timestamp,
    };
  }
}
