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

  DesignSpecification({
    this.layoutType = 'two_column_sidebar',
    this.fontFamily = 'Inter',
    this.primaryColorHex = '#1e293b',
    this.secondaryColorHex = '#64748b',
    this.bulletStyle = 'dot',
    this.hasSidebar = true,
    this.sidebarPosition = 'left',
    this.maxPageBudget = 1,
  });

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
    };
  }
}
