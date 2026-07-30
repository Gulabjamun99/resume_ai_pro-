// lib/models/render_report.dart

class RenderReport {
  final String renderId;
  final String templateUsed; // 'Classic', 'Modern', 'Executive', 'ATS', 'Sidebar', 'Minimal'
  final int pageCount;
  final double renderDurationMs;
  final Map<String, dynamic> layoutValidation;
  final Map<String, dynamic> typographyValidation;
  final Map<String, dynamic> pageBudgetValidation;
  final List<String> outputFormats; // ['PDF', 'DOCX']
  final String renderingVersion;
  final String timestamp;

  RenderReport({
    required this.renderId,
    required this.templateUsed,
    required this.pageCount,
    required this.renderDurationMs,
    required this.layoutValidation,
    required this.typographyValidation,
    required this.pageBudgetValidation,
    required this.outputFormats,
    this.renderingVersion = '2.0-DesignPreservationEngine',
    required this.timestamp,
  });

  factory RenderReport.fromJson(Map<String, dynamic> json) {
    return RenderReport(
      renderId: json['render_id'] ?? 'render_01',
      templateUsed: json['template_used'] ?? 'Executive',
      pageCount: json['page_count'] ?? 1,
      renderDurationMs: (json['render_duration_ms'] as num?)?.toDouble() ?? 12.5,
      layoutValidation: Map<String, dynamic>.from(json['layout_validation'] ?? {}),
      typographyValidation: Map<String, dynamic>.from(json['typography_validation'] ?? {}),
      pageBudgetValidation: Map<String, dynamic>.from(json['page_budget_validation'] ?? {}),
      outputFormats: List<String>.from(json['output_formats'] ?? ['PDF', 'DOCX']),
      renderingVersion: json['rendering_version'] ?? '2.0-DesignPreservationEngine',
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'render_id': renderId,
      'template_used': templateUsed,
      'page_count': pageCount,
      'render_duration_ms': renderDurationMs,
      'layout_validation': layoutValidation,
      'typography_validation': typographyValidation,
      'page_budget_validation': pageBudgetValidation,
      'output_formats': outputFormats,
      'rendering_version': renderingVersion,
      'timestamp': timestamp,
    };
  }
}
