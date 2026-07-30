// lib/models/design_spec_model.dart

class DesignSpecification {
  final String layoutType; // 'single_column', 'two_column_sidebar', 'classic_executive'
  final String fontFamily; // 'Inter', 'Roboto', 'Outfit'
  final String primaryColorHex; // e.g. '#1e293b'
  final String secondaryColorHex; // e.g. '#64748b'
  final String bulletStyle; // 'dot', 'square', 'diamond'
  final bool hasSidebar;
  final String sidebarPosition; // 'left', 'right'
  final int maxPageBudget; // 1 or 2

  // Deep Design Behavior Preservation Fields
  final Map<String, dynamic> typographyHierarchy;
  final Map<String, dynamic> spacingSystem;
  final Map<String, dynamic> margins;
  final String headerLayout;
  final double sectionSpacing;
  final Map<String, dynamic> renderHints;
  final Map<String, dynamic> layoutConstraints;
  final String templateMapping;

  DesignSpecification({
    this.layoutType = 'two_column_sidebar',
    this.fontFamily = 'Inter',
    this.primaryColorHex = '#1e293b',
    this.secondaryColorHex = '#64748b',
    this.bulletStyle = 'dot',
    this.hasSidebar = true,
    this.sidebarPosition = 'left',
    this.maxPageBudget = 1,
    Map<String, dynamic>? typographyHierarchy,
    Map<String, dynamic>? spacingSystem,
    Map<String, dynamic>? margins,
    this.headerLayout = 'split_header',
    this.sectionSpacing = 14.0,
    Map<String, dynamic>? renderHints,
    Map<String, dynamic>? layoutConstraints,
    this.templateMapping = 'cascade_sidebar_pro',
  })  : typographyHierarchy = typographyHierarchy ?? {
          'title_size': 22.0,
          'header_size': 14.0,
          'body_size': 10.5,
          'line_height': 1.4,
          'title_weight': 'bold',
          'header_weight': 'w600'
        },
        spacingSystem = spacingSystem ?? {
          'section_gap': 14.0,
          'item_gap': 8.0,
          'bullet_padding': 4.0
        },
        margins = margins ?? {
          'top': 36.0,
          'bottom': 36.0,
          'left': 36.0,
          'right': 36.0
        },
        renderHints = renderHints ?? {
          'keep_together_experience': true,
          'orphan_suppression': true,
          'strict_page_budget': true
        },
        layoutConstraints = layoutConstraints ?? {
          'sidebar_width_ratio': 0.32,
          'max_bullets_per_job': 5,
          'max_page_budget': 1
        };

  factory DesignSpecification.fromJson(Map<String, dynamic> json) {
    return DesignSpecification(
      layoutType: json['layout_type'] ?? 'two_column_sidebar',
      fontFamily: json['font_family'] ?? 'Inter',
      primaryColorHex: json['primary_color_hex'] ?? '#1e293b',
      secondaryColorHex: json['secondary_color_hex'] ?? '#64748b',
      bulletStyle: json['bullet_style'] ?? 'dot',
      hasSidebar: json['has_sidebar'] ?? true,
      sidebarPosition: json['sidebar_position'] ?? 'left',
      maxPageBudget: json['max_page_budget'] ?? 1,
      typographyHierarchy: Map<String, dynamic>.from(json['typography_hierarchy'] ?? {}),
      spacingSystem: Map<String, dynamic>.from(json['spacing_system'] ?? {}),
      margins: Map<String, dynamic>.from(json['margins'] ?? {}),
      headerLayout: json['header_layout'] ?? 'split_header',
      sectionSpacing: (json['section_spacing'] as num?)?.toDouble() ?? 14.0,
      renderHints: Map<String, dynamic>.from(json['render_hints'] ?? {}),
      layoutConstraints: Map<String, dynamic>.from(json['layout_constraints'] ?? {}),
      templateMapping: json['template_mapping'] ?? 'cascade_sidebar_pro',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'layout_type': layoutType,
      'font_family': fontFamily,
      'primary_color_hex': primaryColorHex,
      'secondary_color_hex': secondaryColorHex,
      'bullet_style': bulletStyle,
      'has_sidebar': hasSidebar,
      'sidebar_position': sidebarPosition,
      'max_page_budget': maxPageBudget,
      'typography_hierarchy': typographyHierarchy,
      'spacing_system': spacingSystem,
      'margins': margins,
      'header_layout': headerLayout,
      'section_spacing': sectionSpacing,
      'render_hints': renderHints,
      'layout_constraints': layoutConstraints,
      'template_mapping': templateMapping,
    };
  }
}
