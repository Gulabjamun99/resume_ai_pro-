// lib/models/render_report.dart

class RenderReport {
  final String renderId;
  final String renderFingerprint;
  final String templateUsed; // 'Classic', 'Modern', 'Executive', 'ATS', 'Sidebar', 'Minimal'
  final String templateVersion;
  final String renderEngineVersion;
  final int pageCount;
  final double renderDurationMs;
  final Map<String, dynamic> layoutValidation;
  final Map<String, dynamic> typographyValidation;
  final Map<String, dynamic> exportValidation;
  final double layoutStabilityScore; // 0 - 100
  final bool renderDeterministic;
  final bool immutableWorkspaceVerified;
  final Map<String, dynamic> templateCapabilityMatrix;
  final List<String> outputFormats; // ['PDF', 'DOCX']
  final String timestamp;

  RenderReport({
    required this.renderId,
    required this.renderFingerprint,
    required this.templateUsed,
    this.templateVersion = '1.0.0',
    this.renderEngineVersion = '2.0-DesignPreservationEngine',
    required this.pageCount,
    required this.renderDurationMs,
    required this.layoutValidation,
    required this.typographyValidation,
    required this.exportValidation,
    this.layoutStabilityScore = 100.0,
    this.renderDeterministic = true,
    this.immutableWorkspaceVerified = true,
    this.templateCapabilityMatrix = const {},
    required this.outputFormats,
    required this.timestamp,
  });

  factory RenderReport.fromJson(Map<String, dynamic> json) {
    return RenderReport(
      renderId: json['render_id'] ?? 'render_01',
      renderFingerprint: json['render_fingerprint'] ?? '',
      templateUsed: json['template_used'] ?? 'Executive',
      templateVersion: json['template_version'] ?? '1.0.0',
      renderEngineVersion: json['render_engine_version'] ?? '2.0-DesignPreservationEngine',
      pageCount: json['page_count'] ?? 1,
      renderDurationMs: (json['render_duration_ms'] as num?)?.toDouble() ?? 12.5,
      layoutValidation: Map<String, dynamic>.from(json['layout_validation'] ?? {}),
      typographyValidation: Map<String, dynamic>.from(json['typography_validation'] ?? {}),
      exportValidation: Map<String, dynamic>.from(json['export_validation'] ?? {}),
      layoutStabilityScore: (json['layout_stability_score'] as num?)?.toDouble() ?? 100.0,
      renderDeterministic: json['render_deterministic'] ?? true,
      immutableWorkspaceVerified: json['immutable_workspace_verified'] ?? true,
      templateCapabilityMatrix: Map<String, dynamic>.from(json['template_capability_matrix'] ?? {}),
      outputFormats: List<String>.from(json['output_formats'] ?? ['PDF', 'DOCX']),
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'render_id': renderId,
      'render_fingerprint': renderFingerprint,
      'template_used': templateUsed,
      'template_version': templateVersion,
      'render_engine_version': renderEngineVersion,
      'page_count': pageCount,
      'render_duration_ms': renderDurationMs,
      'layout_validation': layoutValidation,
      'typography_validation': typographyValidation,
      'export_validation': exportValidation,
      'layout_stability_score': layoutStabilityScore,
      'render_deterministic': renderDeterministic,
      'immutable_workspace_verified': immutableWorkspaceVerified,
      'template_capability_matrix': templateCapabilityMatrix,
      'output_formats': outputFormats,
      'timestamp': timestamp,
    };
  }
}
