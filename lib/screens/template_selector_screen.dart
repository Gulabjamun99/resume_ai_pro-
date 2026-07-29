// lib/screens/template_selector_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/template_model.dart';
import '../models/resume_model.dart';
import 'verify_screen.dart';

/// Lets the user pick a resume template + accent color before payment.
/// All templates are single-column and ATS-safe — color only touches
/// headers, section titles, and skill tags, never sidebars or tables.
class TemplateSelectorScreen extends StatefulWidget {
  final ResumeRequest request;
  final String jobDescription;
  const TemplateSelectorScreen({super.key, required this.request, this.jobDescription = ''});
  @override
  State<TemplateSelectorScreen> createState() => _TemplateSelectorScreenState();
}

class _TemplateSelectorScreenState extends State<TemplateSelectorScreen> {
  String _filter = 'all';
  String? _selectedId;
  Color _selectedColor = _hexToColor(kTemplateColors[0].hex);

  static Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  List<ResumeTemplate> get _filtered => _filter == 'all'
      ? kResumeTemplates
      : kResumeTemplates.where((t) => t.categories.contains(_filter)).toList();

  ResumeTemplate? get _selectedTemplate =>
      _selectedId == null ? null : kResumeTemplates.firstWhere((t) => t.id == _selectedId);

  void _selectTemplate(String id) {
    setState(() => _selectedId = id);
  }

  void _continue() {
    if (_selectedTemplate == null) return;
    final colorHex = '#${_selectedColor.value.toRadixString(16).substring(2)}';
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => VerifyScreen(
        request: widget.request,
        templateId: _selectedTemplate!.id,
        templateColor: colorHex,
        jobDescription: widget.jobDescription,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Template')),
      body: Column(children: [
        // ATS safety note
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.green.withOpacity(0.07),
            border: Border.all(color: AppColors.green.withOpacity(0.25)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('✅ ', style: TextStyle(fontSize: 15)),
            Expanded(child: Text(
              'All templates are 100% ATS-safe. Every layout is single-column — color only appears in headers and section titles, never in sidebars or tables that confuse parsers.',
              style: TextStyle(fontSize: 11.5, color: AppColors.text2, height: 1.4),
            )),
          ]),
        ),

        // Filter chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SizedBox(
            height: 32,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              _FilterChip(label: 'All (${kResumeTemplates.length})', value: 'all', active: _filter, onTap: (v) => setState(() => _filter = v)),
              _FilterChip(label: '✨ Zety Style (6)', value: 'zety', active: _filter, onTap: (v) => setState(() => _filter = v)),
              _FilterChip(label: 'Classic', value: 'classic', active: _filter, onTap: (v) => setState(() => _filter = v)),
              _FilterChip(label: 'Modern', value: 'modern', active: _filter, onTap: (v) => setState(() => _filter = v)),
              _FilterChip(label: 'Creative', value: 'creative', active: _filter, onTap: (v) => setState(() => _filter = v)),
              _FilterChip(label: 'Executive', value: 'executive', active: _filter, onTap: (v) => setState(() => _filter = v)),
            ]),
          ),
        ),

        // Template grid
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filtered.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (_, i) {
                  final t = _filtered[i];
                  return _TemplateCard(
                    template: t,
                    selected: _selectedId == t.id,
                    accent: _selectedId == t.id ? _selectedColor : _hexToColor(kTemplateColors[0].hex),
                    onTap: () => _selectTemplate(t.id),
                  );
                },
              ),

              // Detail panel — color picker + preview + CTA
              if (_selectedTemplate != null) ...[
                const SizedBox(height: 16),
                _DetailPanel(
                  template: _selectedTemplate!,
                  selectedColor: _selectedColor,
                  onColorChange: (c) => setState(() => _selectedColor = c),
                  onContinue: _continue,
                ),
              ],
            ]),
          ),
        ),
      ]),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, value, active;
  final void Function(String) onTap;
  const _FilterChip({required this.label, required this.value, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = active == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.text : Colors.transparent,
            border: Border.all(color: isActive ? AppColors.text : AppColors.border2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(child: Text(label, style: TextStyle(fontSize: 12, color: isActive ? AppColors.bg : AppColors.text2))),
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final ResumeTemplate template;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  const _TemplateCard({required this.template, required this.selected, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.text : AppColors.border, width: selected ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          Expanded(child: Container(
            color: const Color(0xFFF5F5F5),
            padding: const EdgeInsets.all(8),
            child: MiniResumePreview(templateId: template.id, accentColor: accent),
          )),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${template.icon} ${template.name}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text('ATS ${template.atsScore}%', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.green)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  final ResumeTemplate template;
  final Color selectedColor;
  final void Function(Color) onColorChange;
  final VoidCallback onContinue;
  const _DetailPanel({required this.template, required this.selectedColor, required this.onColorChange, required this.onContinue});

  static Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${template.icon} ${template.name}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 3),
          Text(template.description, style: const TextStyle(fontSize: 12, color: AppColors.text2, height: 1.4)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${template.atsScore}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.green)),
          const Text('ATS Safe', style: TextStyle(fontSize: 10, color: AppColors.text3)),
        ]),
      ]),
      const SizedBox(height: 16),

      const Text('CHOOSE YOUR ACCENT COLOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text3, letterSpacing: 0.5)),
      const SizedBox(height: 10),
      Wrap(spacing: 10, runSpacing: 10, children: kTemplateColors.map((c) {
        final color = _hexToColor(c.hex);
        final isSelected = selectedColor.value == color.value;
        return GestureDetector(
          onTap: () => onColorChange(color),
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: color, shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
              boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 8, spreadRadius: 1)] : null,
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
          ),
        );
      }).toList()),
      const SizedBox(height: 16),

      const Text('LIVE PREVIEW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text3, letterSpacing: 0.5)),
      const SizedBox(height: 10),
      Container(
        height: 340,
        width: double.infinity,
        decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(12),
        child: MiniResumePreview(templateId: template.id, accentColor: selectedColor, detailed: true),
      ),
      const SizedBox(height: 14),

      const Text('BEST FOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text3, letterSpacing: 0.5)),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: template.bestFor.map((b) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: AppColors.bg3, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
        child: Text(b, style: const TextStyle(fontSize: 10.5, color: AppColors.text2)),
      )).toList()),
      const SizedBox(height: 18),

      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: onContinue,
        child: Text('Use "${template.name}" →'),
      )),
    ]));
  }
}

/// Renders a scaled-down live preview of a resume template with sample data,
/// so the user can see exactly what their final resume will look like.
class MiniResumePreview extends StatelessWidget {
  final String templateId;
  final Color accentColor;
  final bool detailed;
  const MiniResumePreview({super.key, required this.templateId, required this.accentColor, this.detailed = false});

  @override
  Widget build(BuildContext context) {
    final scale = detailed ? 0.62 : 0.32;
    return ClipRect(
      child: Align(
        alignment: Alignment.topLeft,
        heightFactor: scale,
        widthFactor: scale,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 380,
            child: _buildTemplateBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateBody() {
    switch (templateId) {
      case 'modern':
      case 'colorheader':
        return _headerBandStyle();
      case 'executive':
        return _executiveStyle();
      case 'minimal':
        return _minimalStyle();
      case 'bold':
        return _boldStyle();
      case 'timeline':
        return _timelineStyle();
      case 'compact':
        return _compactStyle();
      case 'classic':
      default:
        return _classicStyle();
    }
  }

  static const _name = 'Rahul Kumar Sharma';
  static const _role = 'Senior Software Engineer';
  static const _contact = '+91 98765 43210 • rahul@gmail.com • Mumbai';
  static const _summary = '6+ years architecting scalable systems and leading engineering teams. Reduced API latency 35%, led 5-engineer teams to deliver on schedule.';
  static const _skills = ['Python', 'React', 'Node.js', 'SQL', 'AWS', 'Docker', 'Redis', 'Git'];

  Widget _sectionHeading(String text, {bool underline = true}) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 3),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(text.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: accentColor)),
      if (underline) Container(margin: const EdgeInsets.only(top: 2), height: 0.6, color: const Color(0xFFCCCCCC)),
    ]),
  );

  Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.only(left: 10, bottom: 2),
    child: Text('• $text', style: const TextStyle(fontSize: 9.5, color: Color(0xFF222222), height: 1.4)),
  );

  Widget _skillTags({bool white = false}) => Wrap(spacing: 4, runSpacing: 4, children: _skills.map((s) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: white ? accentColor.withOpacity(0.9) : accentColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(s, style: TextStyle(fontSize: 8.5, color: white ? Colors.white : accentColor)),
  )).toList());

  Widget _classicStyle() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Text(_name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: accentColor))),
      Center(child: Text(_role, style: TextStyle(fontSize: 10, color: accentColor))),
      const SizedBox(height: 2),
      const Center(child: Text(_contact, style: TextStyle(fontSize: 8.5, color: Color(0xFF666666)))),
      Container(margin: const EdgeInsets.only(top: 6), height: 1.5, color: accentColor),
      _sectionHeading('Professional Summary'),
      const Text(_summary, style: TextStyle(fontSize: 9.5, color: Color(0xFF333333), height: 1.45)),
      _sectionHeading('Work Experience'),
      const Text('Senior Software Engineer — Infosys Ltd.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
      const Text('Jun 2021 – Present', style: TextStyle(fontSize: 8.5, color: Color(0xFF666666))),
      _bullet('Architected REST APIs for 50,000+ daily users, 99.9% uptime'),
      _bullet('Led team of 5 engineers, delivered 2 weeks early'),
      _sectionHeading('Technical Skills'),
      _skillTags(),
    ]),
  );

  Widget _headerBandStyle() => Container(
    color: Colors.white,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        color: accentColor,
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          Text(_role, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.9))),
          Text(_contact, style: TextStyle(fontSize: 8.5, color: Colors.white.withOpacity(0.75))),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionHeading('Summary'),
          const Text(_summary, style: TextStyle(fontSize: 9.5, color: Color(0xFF333333), height: 1.45)),
          _sectionHeading('Work Experience'),
          const Text('Senior Software Engineer', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
          const Text('Infosys Ltd. • Jun 2021 – Present', style: TextStyle(fontSize: 8.5, color: Color(0xFF666666))),
          _bullet('Architected REST APIs for 50,000+ daily users'),
          _bullet('Led 5-engineer team, 2 weeks ahead of schedule'),
          _sectionHeading('Technical Skills'),
          _skillTags(),
        ]),
      ),
    ]),
  );

  Widget _executiveStyle() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Text(_name.toUpperCase(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 2, fontFamily: 'serif'))),
      Center(child: Container(margin: const EdgeInsets.symmetric(vertical: 3), height: 1.5, width: 100, color: accentColor)),
      Center(child: Text(_role, style: TextStyle(fontSize: 10, color: accentColor, fontStyle: FontStyle.italic))),
      const Center(child: Text(_contact, style: TextStyle(fontSize: 8.5, color: Color(0xFF666666)))),
      _sectionHeading('Executive Summary'),
      const Text(_summary, style: TextStyle(fontSize: 9.5, color: Color(0xFF222222), fontStyle: FontStyle.italic, height: 1.45)),
      _sectionHeading('Professional Experience'),
      const Text('Senior Software Engineer', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
      const Text('Infosys Ltd., Pune', style: TextStyle(fontSize: 8.5, color: Color(0xFF666666), fontStyle: FontStyle.italic)),
      _bullet('Spearheaded API architecture serving 50,000+ users'),
      _bullet('Directed cross-functional team of 5 engineers'),
    ]),
  );

  Widget _minimalStyle() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, letterSpacing: 3, color: accentColor)),
      Text(_role.toUpperCase(), style: TextStyle(fontSize: 8.5, color: accentColor.withOpacity(0.7), letterSpacing: 1.5)),
      const SizedBox(height: 4),
      const Text(_contact, style: TextStyle(fontSize: 8.5, color: Color(0xFFAAAAAA))),
      _sectionHeading('Experience'),
      const Text('Senior Software Engineer — Infosys Ltd.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
      const Text('2021 – Present', style: TextStyle(fontSize: 8.5, color: Color(0xFFBBBBBB))),
      _bullet('Architected REST APIs for 50,000+ daily users'),
      _sectionHeading('Skills'),
      _skillTags(),
    ]),
  );

  Widget _boldStyle() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: accentColor)),
      const Text(_role, style: TextStyle(fontSize: 10, color: Color(0xFF555555))),
      const Text(_contact, style: TextStyle(fontSize: 8.5, color: Color(0xFF888888))),
      Container(margin: const EdgeInsets.symmetric(vertical: 6), height: 3, color: accentColor),
      Container(
        padding: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(border: Border(left: BorderSide(color: accentColor, width: 2.5))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SUMMARY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: accentColor)),
          const SizedBox(height: 2),
          const Text(_summary, style: TextStyle(fontSize: 9.5, color: Color(0xFF333333), height: 1.4)),
        ]),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(border: Border(left: BorderSide(color: accentColor, width: 2.5))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('EXPERIENCE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: accentColor)),
          const Text('Senior Software Engineer', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
          _bullet('Architected REST APIs for 50,000+ daily users'),
        ]),
      ),
    ]),
  );

  Widget _timelineStyle() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: accentColor)),
      const Text(_role, style: TextStyle(fontSize: 10, color: Color(0xFF666666))),
      const Text(_contact, style: TextStyle(fontSize: 8.5, color: Color(0xFF888888))),
      Container(margin: const EdgeInsets.symmetric(vertical: 6), height: 2, color: accentColor),
      _sectionHeading('Work Experience', underline: false),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 3, right: 8), decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle)),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Senior Software Engineer — 2021-Present', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
          const Text('Infosys Ltd.', style: TextStyle(fontSize: 8.5, color: Color(0xFF666666))),
          _bullet('Architected REST APIs for 50,000+ daily users'),
        ])),
      ]),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 3, right: 8), decoration: BoxDecoration(color: accentColor.withOpacity(0.4), shape: BoxShape.circle)),
        const Expanded(child: Text('Software Engineer — 2019-2021 • TCS', style: TextStyle(fontSize: 9.5, color: Color(0xFF555555)))),
      ]),
    ]),
  );

  Widget _compactStyle() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: accentColor)),
      Text(_role, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w500, color: accentColor)),
      Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.only(bottom: 3),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: accentColor, width: 1))),
        child: const Text(_contact, style: TextStyle(fontSize: 8.5, color: Color(0xFF666666))),
      ),
      _sectionHeading('Summary'),
      const Text(_summary, style: TextStyle(fontSize: 9, color: Color(0xFF333333), height: 1.35)),
      _sectionHeading('Experience'),
      const Text('Senior Software Engineer — Infosys', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700)),
      _bullet('APIs for 50K+ daily users, 99.9% uptime'),
      _bullet('Led team of 5, delivered 2 weeks early'),
      const Text('Software Engineer — TCS', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700)),
      _bullet('12+ microservices, ₹2Cr+ monthly GMV'),
    ]),
  );
}
