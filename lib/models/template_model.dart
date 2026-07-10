// lib/models/template_model.dart

/// All available resume templates. Every template is single-column
/// and ATS-safe — color is used only in headers, section titles and
/// skill tags, never in sidebars or tables, so parsers never lose data.
class ResumeTemplate {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int atsScore;
  final List<String> bestFor;
  final List<String> categories;

  const ResumeTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.atsScore,
    required this.bestFor,
    required this.categories,
  });
}

class TemplateColor {
  final String hex;
  final String name;
  const TemplateColor(this.hex, this.name);
}

const List<ResumeTemplate> kResumeTemplates = [
  ResumeTemplate(
    id: 'classic',
    name: 'Classic Chronological',
    icon: '📋',
    description: 'Timeless single-column layout — most trusted by recruiters globally',
    atsScore: 98,
    bestFor: ['Finance', 'Banking', 'Law', 'Healthcare', 'Government', 'Academia'],
    categories: ['classic', 'modern'],
  ),
  ResumeTemplate(
    id: 'modern',
    name: 'Modern with Header',
    icon: '⚡',
    description: 'Colored header band, clean body — perfect for IT and startups',
    atsScore: 95,
    bestFor: ['IT', 'Startups', 'Product', 'Engineering', 'Marketing'],
    categories: ['modern'],
  ),
  ResumeTemplate(
    id: 'bold',
    name: 'Bold Accent Lines',
    icon: '🔷',
    description: 'Bold left accent bars on section headings — confident and structured',
    atsScore: 93,
    bestFor: ['Sales', 'Business Development', 'Operations', 'Project Management'],
    categories: ['modern', 'creative'],
  ),
  ResumeTemplate(
    id: 'executive',
    name: 'Executive',
    icon: '👔',
    description: 'Formal layout with accent divider lines — commanding presence for leadership',
    atsScore: 97,
    bestFor: ['C-Suite', 'Senior Management', 'Consulting', 'Investment Banking'],
    categories: ['executive'],
  ),
  ResumeTemplate(
    id: 'minimal',
    name: 'Ultra Minimalist',
    icon: '◻️',
    description: 'Maximum white space, light typography — refined and elegant',
    atsScore: 91,
    bestFor: ['UX Design', 'Architecture', 'Creative Tech', 'Research'],
    categories: ['modern', 'creative'],
  ),
  ResumeTemplate(
    id: 'colorheader',
    name: 'Full Color Header',
    icon: '🎨',
    description: 'Large color header band — eye-catching but fully ATS-safe body',
    atsScore: 94,
    bestFor: ['Design', 'Media', 'Content', 'HR', 'Public Relations'],
    categories: ['modern', 'creative'],
  ),
  ResumeTemplate(
    id: 'timeline',
    name: 'Timeline with Dots',
    icon: '🕐',
    description: 'Dot timeline marks each role — shows career progression clearly',
    atsScore: 90,
    bestFor: ['Mid-career', 'Career changers', 'Multi-industry backgrounds'],
    categories: ['modern', 'creative'],
  ),
  ResumeTemplate(
    id: 'compact',
    name: 'Compact & Dense',
    icon: '📄',
    description: 'Maximum content in minimum space — ideal for senior professionals',
    atsScore: 96,
    bestFor: ['Senior Engineers', 'Managers', '10+ years experience', 'Two-page resumes'],
    categories: ['executive', 'modern'],
  ),
];

const List<TemplateColor> kTemplateColors = [
  TemplateColor('#1a1a2e', 'Midnight Navy'),
  TemplateColor('#0f3460', 'Royal Blue'),
  TemplateColor('#1b4332', 'Forest Green'),
  TemplateColor('#6d28d9', 'Deep Purple'),
  TemplateColor('#b91c1c', 'Crimson Red'),
  TemplateColor('#92400e', 'Warm Brown'),
  TemplateColor('#0e7490', 'Teal'),
  TemplateColor('#374151', 'Slate Gray'),
  TemplateColor('#be185d', 'Berry Pink'),
  TemplateColor('#065f46', 'Emerald'),
  TemplateColor('#1e40af', 'Cobalt'),
  TemplateColor('#7c3aed', 'Violet'),
];
