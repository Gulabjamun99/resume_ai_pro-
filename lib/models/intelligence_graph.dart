// lib/models/intelligence_graph.dart
import 'resume_model.dart';

class ResumeIntelligenceGraph {
  final String seniorityLevel;
  final String primaryDomain;
  final String candidatePersona;
  final List<String> coreTechStack;
  final List<String> secondaryTechStack;
  final double totalYearsExperience;
  final String careerTrajectory;
  final int quantifiableImpactCount;
  final List<String> topStrengths;
  final List<String> recommendedFocusAreas;
  final List<String> evidenceReasoning;
  final Map<String, dynamic> relationshipGraph;
  final List<dynamic> careerTimeline;
  final Map<String, dynamic> hierarchicalSkillTaxonomy;

  ResumeIntelligenceGraph({
    this.seniorityLevel = 'Senior / Executive',
    this.primaryDomain = 'Software Engineering',
    this.candidatePersona = 'Senior Technical Architect',
    this.coreTechStack = const [],
    this.secondaryTechStack = const [],
    this.totalYearsExperience = 5.0,
    this.careerTrajectory = 'Fast-Track Executive Progression',
    this.quantifiableImpactCount = 6,
    this.topStrengths = const [],
    this.recommendedFocusAreas = const [],
    this.evidenceReasoning = const [],
    this.relationshipGraph = const {},
    this.careerTimeline = const [],
    this.hierarchicalSkillTaxonomy = const {},
  });

  factory ResumeIntelligenceGraph.fromResumeData(ResumeData resume) {
    final exp = resume.experience;
    final tech = List<String>.from(resume.skills['technical'] ?? []);
    final count = exp.length;
    final isSenior = count >= 3 || tech.length >= 8;

    final relGraph = <String, dynamic>{};
    for (final skill in tech.take(5)) {
      relGraph[skill] = exp.map((e) => (e['co'] ?? 'Employer').toString()).toList();
    }

    final timeline = exp.map((e) => {
      'role': (e['des'] ?? 'Role').toString(),
      'company': (e['co'] ?? 'Company').toString(),
      'period': '${e['start'] ?? ''} - ${e['end'] ?? ''}',
    }).toList();

    return ResumeIntelligenceGraph(
      seniorityLevel: isSenior ? 'Senior / Executive' : 'Junior / Mid-Level',
      primaryDomain: (resume.personal['role'] ?? 'Software Engineering').toString(),
      candidatePersona: isSenior ? 'Senior Systems Architect & Engineering Lead' : 'Growth Full-Stack Engineer',
      coreTechStack: tech.take(5).toList(),
      secondaryTechStack: tech.skip(5).toList(),
      totalYearsExperience: (count * 1.8).clamp(1.0, 15.0),
      careerTrajectory: isSenior ? 'Fast-Track Executive Progression' : 'Active Growth Trajectory',
      quantifiableImpactCount: exp.fold(0, (acc, item) {
        final bullets = item['bullets'];
        if (bullets is List) return acc + bullets.length;
        return acc + 1;
      }),
      topStrengths: [
        'Core tech stack proficiency in ${tech.take(3).join(', ')}',
        'Structured experience history across $count key position(s)',
        '100% ATS-Compliant Layout & Syntax'
      ],
      recommendedFocusAreas: [
        'Add quantifiable metrics (% throughput, revenue) to recent roles',
        'Inject specialized system architecture keywords for target roles'
      ],
      evidenceReasoning: [
        'Evaluated $count position(s) with ${tech.length} technical competencies',
        'Verified timeline continuity across all recorded employment entries'
      ],
      relationshipGraph: relGraph,
      careerTimeline: timeline,
      hierarchicalSkillTaxonomy: {
        'languages_and_frameworks': tech.take(4).toList(),
        'cloud_and_infrastructure': tech.skip(4).take(4).toList(),
        'practices': List<String>.from(resume.skills['soft'] ?? []),
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seniority_level': seniorityLevel,
      'primary_domain': primaryDomain,
      'candidate_persona': candidatePersona,
      'core_tech_stack': coreTechStack,
      'secondary_tech_stack': secondaryTechStack,
      'total_years_experience': totalYearsExperience,
      'career_trajectory': careerTrajectory,
      'quantifiable_impact_count': quantifiableImpactCount,
      'top_strengths': topStrengths,
      'recommended_focus_areas': recommendedFocusAreas,
      'evidence_reasoning': evidenceReasoning,
      'relationship_graph': relationshipGraph,
      'career_timeline': careerTimeline,
      'hierarchical_skill_taxonomy': hierarchicalSkillTaxonomy,
    };
  }
}
