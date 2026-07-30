// lib/models/resume_workspace.dart
import 'resume_model.dart';
import 'intelligence_graph.dart';
import 'design_spec_model.dart';
import 'health_model.dart';

/// Single Canonical Root Model for the AI Resume Editor Workspace.
/// Preserves Goal Awareness, Conversational Memory, Dual Scores, and Opportunity Radar.
class ResumeWorkspace {
  ResumeData resumeData;
  ResumeIntelligenceGraph intelligenceGraph;
  DesignSpecification designSpec;
  ResumeHealth health;
  List<ResumeData> versionHistory;
  int currentVersionIndex;

  // Executive AI Assistant Extensions
  String candidateGoal;
  double recruiterImpactScore;
  List<String> sessionMemory;
  List<String> opportunityRadar;
  Map<String, dynamic> industryBenchmark;
  List<String> smartFollowups;

  ResumeWorkspace({
    required this.resumeData,
    ResumeIntelligenceGraph? intelligenceGraph,
    DesignSpecification? designSpec,
    ResumeHealth? health,
    List<ResumeData>? versionHistory,
    this.currentVersionIndex = 0,
    this.candidateGoal = 'Target Executive Senior / FAANG Level Role',
    this.recruiterImpactScore = 8.6,
    List<String>? sessionMemory,
    List<String>? opportunityRadar,
    Map<String, dynamic>? industryBenchmark,
    List<String>? smartFollowups,
  })  : intelligenceGraph = intelligenceGraph ?? ResumeIntelligenceGraph.fromResumeData(resumeData),
        designSpec = designSpec ?? DesignSpecification(),
        health = health ?? ResumeHealth(),
        versionHistory = versionHistory ?? [resumeData],
        sessionMemory = sessionMemory ?? [],
        opportunityRadar = opportunityRadar ?? [
          'Highlight recent AI Agent & Automation experience in Summary',
          'Position as Senior Technical Architect for Product-based companies',
          'Add quantitative latency & throughput metrics to experience'
        ],
        industryBenchmark = industryBenchmark ?? {
          'domain': 'Software Engineering',
          'top_20_percentile_comparison': {
            'measurable_achievements': 'Below Industry Average (Recommend adding metrics)',
            'technical_depth': 'Above Industry Average (Top 10%)',
            'executive_presence': 'Competitive'
          }
        },
        smartFollowups = smartFollowups ?? [];

  factory ResumeWorkspace.fromInitialResume(ResumeData resume, {DesignSpecification? spec, String goal = ''}) {
    final graph = ResumeIntelligenceGraph.fromResumeData(resume);
    final healthScore = ResumeHealth(atsScore: resume.atsScore);
    return ResumeWorkspace(
      resumeData: resume,
      intelligenceGraph: graph,
      designSpec: spec ?? DesignSpecification(),
      health: healthScore,
      versionHistory: [resume],
      currentVersionIndex: 0,
      candidateGoal: goal.isNotEmpty ? goal : 'Target Executive Senior / FAANG Level Role',
    );
  }

  void pushNewVersion(ResumeData newResume, {String? memoryNote}) {
    if (currentVersionIndex < versionHistory.length - 1) {
      versionHistory.removeRange(currentVersionIndex + 1, versionHistory.length);
    }
    versionHistory.add(newResume);
    currentVersionIndex = versionHistory.length - 1;
    resumeData = newResume;
    intelligenceGraph = ResumeIntelligenceGraph.fromResumeData(newResume);
    if (memoryNote != null && memoryNote.isNotEmpty) {
      sessionMemory.add(memoryNote);
    }
  }

  bool undo() {
    if (currentVersionIndex > 0) {
      currentVersionIndex--;
      resumeData = versionHistory[currentVersionIndex];
      intelligenceGraph = ResumeIntelligenceGraph.fromResumeData(resumeData);
      return true;
    }
    return false;
  }

  bool redo() {
    if (currentVersionIndex < versionHistory.length - 1) {
      currentVersionIndex++;
      resumeData = versionHistory[currentVersionIndex];
      intelligenceGraph = ResumeIntelligenceGraph.fromResumeData(resumeData);
      return true;
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'resume_data': resumeData.toJson(),
      'intelligence_graph': intelligenceGraph.toJson(),
      'design_spec': designSpec.toJson(),
      'health': health.toJson(),
      'current_version_index': currentVersionIndex,
      'total_versions': versionHistory.length,
      'candidate_goal': candidateGoal,
      'recruiter_impact_score': recruiterImpactScore,
      'session_memory': sessionMemory,
      'opportunity_radar': opportunityRadar,
      'industry_benchmark': industryBenchmark,
      'smart_followups': smartFollowups,
    };
  }
}
