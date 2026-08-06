// lib/widgets/resume_preview.dart
import 'package:flutter/material.dart';
import '../models/resume_model.dart';

/// Renders the final resume using real user data in the chosen template.
/// Every template is domain-agnostic: skills sections render whatever keys
/// are present in the data (tech/clinical/legal/financial/etc).
class ResumePreview extends StatelessWidget {
  final ResumeData data;
  final String templateId;
  final String templateColor;
  const ResumePreview({super.key, required this.data, this.templateId = 'classic', this.templateColor = '#1a1a2e'});

  Color get _accent {
    final h = templateColor.replaceAll('#', '');
    try {
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return const Color(0xFF1a1a2e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = data.personal;
    final contacts = <Map<String, String>>[];
    if ((p['phone'] ?? '').toString().isNotEmpty) contacts.add({'icon': '📞', 'val': p['phone'].toString()});
    if ((p['email'] ?? '').toString().isNotEmpty) contacts.add({'icon': '✉️', 'val': p['email'].toString()});
    if ((p['city'] ?? '').toString().isNotEmpty) contacts.add({'icon': '📍', 'val': p['city'].toString()});
    if ((p['linkedin'] ?? '').toString().isNotEmpty) contacts.add({'icon': '💼', 'val': p['linkedin'].toString()});
    if ((p['github'] ?? '').toString().isNotEmpty) contacts.add({'icon': '🐙', 'val': p['github'].toString()});

    final sk = data.skills;

    // ── Domain-agnostic skill extraction ──────────────────────────────────────
    // We read ALL keys from the skills map dynamically, so Healthcare/Law/Finance
    // candidates get their correct section names instead of "Technical Skills".
    final List<_SkillGroup> skillGroups = _extractSkillGroups(sk);

    // For backward-compatible layout helpers, expose first group as "tech":
    final tech = skillGroups.isNotEmpty
        ? skillGroups.first.skills
        : <String>[];

    final langs = _asList(sk['languages'] ?? sk['lang'] ?? []);
    final certs = _asList(sk['certifications'] ?? sk['cert'] ?? []);
    final soft = _asList(sk['soft'] ?? sk['soft_skills'] ?? []);
    final projs = data.projects.where((pr) => (pr['name'] ?? '').isNotEmpty).toList();
    final extra = data.extra.map((x) => x.toString()).where((x) => x.isNotEmpty).toList();
    final exp = data.experience.where((w) => (w['co'] ?? '').isNotEmpty || (w['des'] ?? '').isNotEmpty).toList();
    final edus = data.education.where((e) => (e['deg'] ?? '').isNotEmpty || (e['col'] ?? '').isNotEmpty).toList();

    final ctx = _ResumeContext(
      name: (p['name'] ?? '').toString(),
      role: (p['role'] ?? '').toString(),
      contacts: contacts,
      summary: data.summary,
      exp: exp,
      edus: edus,
      tech: tech,
      soft: soft,
      langs: langs,
      certs: certs,
      projs: projs,
      extra: extra,
      accent: _accent,
      skillGroups: skillGroups,
    );

    Widget layout;
    switch (templateId) {
      case 'original':
        layout = _OriginalBlueprintLayout(ctx: ctx, bp: data.layoutBlueprint);
        break;
      case 'cascade':
        layout = _CascadeLayout(ctx: ctx);
        break;
      case 'primo':
        layout = _PrimoLayout(ctx: ctx);
        break;
      case 'concept':
        layout = _ConceptLayout(ctx: ctx);
        break;
      case 'vibes':
        layout = _VibesLayout(ctx: ctx);
        break;
      case 'cubic':
        layout = _CubicLayout(ctx: ctx);
        break;
      case 'diamond':
        layout = _DiamondLayout(ctx: ctx);
        break;
      case 'modern':
      case 'colorheader':
        layout = _HeaderBandLayout(ctx: ctx);
        break;
      case 'executive':
        layout = _ExecutiveLayout(ctx: ctx);
        break;
      case 'minimal':
        layout = _MinimalLayout(ctx: ctx);
        break;
      case 'bold':
        layout = _BoldLayout(ctx: ctx);
        break;
      case 'timeline':
        layout = _TimelineLayout(ctx: ctx);
        break;
      case 'compact':
        layout = _CompactLayout(ctx: ctx);
        break;
      case 'classic':
      default:
        layout = _ClassicLayout(ctx: ctx);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: layout,
    );
  }
}

// ── Skill group data class ─────────────────────────────────
class _SkillGroup {
  final String label;
  final List<String> skills;
  _SkillGroup({required this.label, required this.skills});
}

/// Convert raw list/string to List<String>
List<String> _asList(dynamic raw) {
  if (raw == null) return [];
  if (raw is List) return raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
  if (raw is String) {
    return raw.split(RegExp(r'[,\n]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
  return [];
}

/// Pretty-print a snake_case / camelCase key as "Title Case"
String _formatLabel(String key) {
  // Replace underscores and hyphens with spaces
  final spaced = key.replaceAll('_', ' ').replaceAll('-', ' ');
  return spaced
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

/// Extract ALL skill groups from the skills map, domain-agnostically.
/// Well-known keys get nicely formatted labels; any unknown key is auto-formatted.
List<_SkillGroup> _extractSkillGroups(Map<String, dynamic> sk) {
  // Keys we treat as non-skill or handle separately
  const skipKeys = {'lang', 'cert', 'languages', 'certifications'};
  // Key → display label mapping (can grow over time)
  const knownLabels = <String, String>{
    'technical': 'Technical Skills',
    'tech': 'Technical Skills',
    'soft': 'Soft Skills',
    'soft_skills': 'Soft Skills',
    'core_competencies': 'Core Competencies',
    'clinical_skills': 'Clinical Skills',
    'medical_skills': 'Medical Skills',
    'nursing_skills': 'Nursing Skills',
    'legal_skills': 'Legal Skills',
    'practice_areas': 'Practice Areas',
    'bar_admissions': 'Bar Admissions',
    'financial_skills': 'Financial Skills',
    'accounting_skills': 'Accounting Skills',
    'domain_tools': 'Domain Tools',
    'tools': 'Tools & Software',
    'management_skills': 'Management Skills',
    'leadership_skills': 'Leadership Skills',
    'primary_skills': 'Core Skills',
    'design_skills': 'Design Skills',
    'creative_skills': 'Creative Skills',
    'teaching_skills': 'Teaching Skills',
    'research_skills': 'Research Skills',
    'engineering_skills': 'Engineering Skills',
    'specializations': 'Specializations',
    'expertise': 'Areas of Expertise',
  };

  final groups = <_SkillGroup>[];
  for (final entry in sk.entries) {
    if (skipKeys.contains(entry.key)) continue;
    final skills = _asList(entry.value);
    if (skills.isEmpty) continue;
    final label = knownLabels[entry.key] ?? _formatLabel(entry.key);
    groups.add(_SkillGroup(label: label, skills: skills));
  }
  return groups;
}

/// Shared data bundle passed to every layout.
class _ResumeContext {
  final String name, role, summary;
  final List<Map<String, String>> contacts;
  final List<String> tech, soft, langs, certs, extra;
  final List<dynamic> exp, edus, projs;
  final Color accent;
  /// All skill groups (domain-agnostic)
  final List<_SkillGroup> skillGroups;

  _ResumeContext({
    required this.name, required this.role, required this.contacts, required this.summary,
    required this.exp, required this.edus, required this.tech, required this.soft,
    required this.langs, required this.certs, required this.projs, required this.extra,
    required this.accent, required this.skillGroups,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'CV';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

// ── Shared building blocks ──────────────────────────────────────────────────

Widget _heading(String text, Color accent, {bool line = true, double size = 12}) => Padding(
  padding: const EdgeInsets.only(top: 14, bottom: 6),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Container(width: 4, height: size + 3, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(
        text.toUpperCase(),
        style: TextStyle(fontSize: size, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: accent),
      ),
    ]),
    if (line) Container(margin: const EdgeInsets.only(top: 4), height: 1, color: accent.withValues(alpha: 0.2)),
  ]),
);

Widget _bulletList(List<dynamic> bullets, {String symbol = '•'}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: bullets.where((b) => b.toString().isNotEmpty).map((b) {
    final cleanB = b.toString().replaceAll(RegExp(r'^[•\-\*\s]+'), '').trim();
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$symbol ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF444444))),
          Expanded(
            child: Text(
              cleanB,
              style: const TextStyle(fontSize: 10.5, color: Color(0xFF222222), height: 1.45),
            ),
          ),
        ],
      ),
    );
  }).toList(),
);

Widget _skillChips(List<String> skills, Color accent, {bool solid = false, bool darkBg = false}) => Wrap(
  spacing: 6, runSpacing: 6,
  children: skills.map((s) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
    decoration: BoxDecoration(
      color: darkBg ? Colors.white.withValues(alpha: 0.15) : (solid ? accent : accent.withValues(alpha: 0.08)),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: darkBg ? Colors.white.withValues(alpha: 0.3) : accent.withValues(alpha: solid ? 1.0 : 0.3)),
    ),
    child: Text(
      s,
      style: TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        color: darkBg ? Colors.white : (solid ? Colors.white : accent),
      ),
    ),
  )).toList(),
);

Widget _jobBlock(dynamic w, Color accent, {String bulletSymbol = '•'}) {
  // Support both 'bullets' list and 'pts' string
  final rawBullets = w['bullets'];
  final rawPts = (w['pts'] ?? '').toString();
  List<dynamic> bullets;
  if (rawBullets is List && rawBullets.isNotEmpty) {
    bullets = rawBullets;
  } else if (rawPts.isNotEmpty) {
    bullets = rawPts.split('\n').where((s) => s.trim().isNotEmpty).toList();
  } else {
    bullets = [];
  }
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(
          (w['des'] ?? w['role'] ?? '').toString(),
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF111111)),
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4)),
          child: Text(
            '${w['start'] ?? ''} – ${w['end'] ?? 'Present'}',
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
          ),
        ),
      ]),
      const SizedBox(height: 2),
      Text(
        '${(w['co'] ?? w['company'] ?? '').toString()}${(w['loc'] ?? '').toString().isNotEmpty ? '  |  ${w['loc']}' : ''}',
        style: TextStyle(fontSize: 11, color: accent, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 4),
      if (bullets.isNotEmpty) _bulletList(bullets, symbol: bulletSymbol),
    ]),
  );
}

Widget _eduBlock(dynamic e, Color accent) {
  final colParts = [e['col'] ?? e['school'], e['grade'], e['honors']].where((v) => (v ?? '').isNotEmpty).join('  |  ');
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(e['deg'] ?? e['degree'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF111111)))),
        if ((e['yr'] ?? '').isNotEmpty)
          Text(e['yr']!, style: const TextStyle(fontSize: 10, color: Color(0xFF666666), fontWeight: FontWeight.w500)),
      ]),
      if (colParts.isNotEmpty)
        Text(colParts, style: TextStyle(fontSize: 10.5, color: accent, fontWeight: FontWeight.w500)),
    ]),
  );
}

Widget _projBlock(dynamic pr, Color accent) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Expanded(child: Text(pr['name'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF111111)))),
      if ((pr['tech'] ?? '').isNotEmpty)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
          child: Text(pr['tech']!, style: TextStyle(fontSize: 9.5, color: accent, fontWeight: FontWeight.w600)),
        ),
    ]),
    if ((pr['desc'] ?? '').isNotEmpty) ...[
      const SizedBox(height: 2),
      Text(pr['desc'], style: const TextStyle(fontSize: 10.5, color: Color(0xFF333333), height: 1.45)),
    ],
  ]),
);

/// Renders all skill groups dynamically — works for any domain.
Widget _dynamicSkillsSection(_ResumeContext ctx, {bool solid = false}) {
  if (ctx.skillGroups.isEmpty && ctx.certs.isEmpty && ctx.langs.isEmpty) return const SizedBox.shrink();
  final c = ctx.accent;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Render each skill group with its domain-specific label
      ...ctx.skillGroups.map((grp) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(grp.label, c),
          _skillChips(grp.skills, c, solid: solid),
        ],
      )),
      // Certifications
      if (ctx.certs.isNotEmpty) ...[
        _heading('Certifications', c),
        ...ctx.certs.map((x) => Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(children: [
            Icon(Icons.verified, size: 12, color: c),
            const SizedBox(width: 6),
            Expanded(child: Text(x, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF222222)))),
          ]),
        )),
      ],
      // Languages
      if (ctx.langs.isNotEmpty) ...[
        _heading('Languages', c),
        _skillChips(ctx.langs, c, solid: solid),
      ],
    ],
  );
}

/// Full sections body including all dynamic skills, experience, education, projects, extra.
Widget _sectionsBody(_ResumeContext ctx, {bool skillsSolid = false}) {
  final c = ctx.accent;
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    if (ctx.summary.isNotEmpty) ...[
      _heading('Professional Summary', c),
      Text(ctx.summary, style: const TextStyle(fontSize: 11, color: Color(0xFF2D3748), height: 1.6)),
    ],
    if (ctx.exp.isNotEmpty) ...[
      _heading('Work Experience', c),
      ...ctx.exp.map((w) => _jobBlock(w, c)),
    ],
    if (ctx.edus.isNotEmpty) ...[
      _heading('Education', c),
      ...ctx.edus.map((e) => _eduBlock(e, c)),
    ],
    // Dynamic domain-agnostic skills
    _dynamicSkillsSection(ctx, solid: skillsSolid),
    if (ctx.projs.isNotEmpty) ...[
      _heading('Projects', c),
      ...ctx.projs.map((pr) => _projBlock(pr, c)),
    ],
    if (ctx.extra.isNotEmpty) ...[
      _heading('Achievements & Key Honors', c),
      ...ctx.extra.map((x) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.star, size: 12, color: c),
          const SizedBox(width: 6),
          Expanded(child: Text(x, style: const TextStyle(fontSize: 10.5, color: Color(0xFF222222)))),
        ]),
      )),
    ],
    const SizedBox(height: 20),
    Center(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.check_circle_outline, size: 11, color: Color(0xFFA0AEC0)),
        const SizedBox(width: 4),
        Text('ATS Approved & Verified • Built with ResumeAI Pro', style: TextStyle(fontSize: 9.5, color: Colors.grey[500], fontWeight: FontWeight.w500)),
      ]),
    ),
  ]);
}

// ── 🌟 CASCADE SIDEBAR PRO ─────────────────────────────────────────────────
class _CascadeLayout extends StatelessWidget {
  final _ResumeContext ctx;
  const _CascadeLayout({required this.ctx});
  @override
  Widget build(BuildContext context) {
    final c = ctx.accent;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Colored Sidebar
          Container(
            width: 130,
            color: c,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: Center(child: Text(ctx.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                ),
                const SizedBox(height: 12),
                Text(ctx.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
                if (ctx.role.isNotEmpty) Text(ctx.role, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
                const SizedBox(height: 14),

                const Text('CONTACT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.2)),
                const SizedBox(height: 6),
                ...ctx.contacts.map((contact) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('${contact['icon']} ${contact['val']}', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.9), height: 1.3)),
                )),

                // All skill groups in sidebar
                ...ctx.skillGroups.map((grp) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(grp.label.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.2)),
                    const SizedBox(height: 6),
                    _skillChips(grp.skills, c, darkBg: true),
                  ],
                )),

                if (ctx.langs.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('LANGUAGES', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.2)),
                  const SizedBox(height: 6),
                  ...ctx.langs.map((l) => Text('• $l', style: TextStyle(fontSize: 9.5, color: Colors.white.withValues(alpha: 0.9)))),
                ],
              ],
            ),
          ),

          // Right Main Panel
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ctx.summary.isNotEmpty) ...[
                    _heading('Professional Summary', c),
                    Text(ctx.summary, style: const TextStyle(fontSize: 10.5, color: Color(0xFF2D3748), height: 1.5)),
                  ],
                  if (ctx.exp.isNotEmpty) ...[
                    _heading('Work Experience', c),
                    ...ctx.exp.map((w) => _jobBlock(w, c)),
                  ],
                  if (ctx.edus.isNotEmpty) ...[
                    _heading('Education', c),
                    ...ctx.edus.map((e) => _eduBlock(e, c)),
                  ],
                  if (ctx.certs.isNotEmpty) ...[
                    _heading('Certifications', c),
                    ...ctx.certs.map((x) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(children: [
                        Icon(Icons.verified, size: 12, color: c),
                        const SizedBox(width: 6),
                        Expanded(child: Text(x, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF222222)))),
                      ]),
                    )),
                  ],
                  if (ctx.projs.isNotEmpty) ...[
                    _heading('Projects', c),
                    ...ctx.projs.map((pr) => _projBlock(pr, c)),
                  ],
                  if (ctx.extra.isNotEmpty) ...[
                    _heading('Achievements', c),
                    ...ctx.extra.map((x) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(Icons.star, size: 12, color: c),
                        const SizedBox(width: 6),
                        Expanded(child: Text(x, style: const TextStyle(fontSize: 10.5, color: Color(0xFF222222)))),
                      ]),
                    )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 🌟 PRIMO EXECUTIVE ─────────────────────────────────────────────────────
class _PrimoLayout extends StatelessWidget {
  final _ResumeContext ctx;
  const _PrimoLayout({required this.ctx});
  @override
  Widget build(BuildContext context) {
    final c = ctx.accent;
    return Container(color: Colors.white, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(18),
        color: c.withValues(alpha: 0.06),
        child: Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            child: Center(child: Text(ctx.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ctx.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: c)),
            if (ctx.role.isNotEmpty) Text(ctx.role.toUpperCase(), style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: c.withValues(alpha: 0.8), letterSpacing: 1.2)),
            const SizedBox(height: 4),
            Wrap(spacing: 8, runSpacing: 4, children: ctx.contacts.map((cn) => Text('${cn['icon']} ${cn['val']}', style: const TextStyle(fontSize: 9.5, color: Color(0xFF555555)))).toList()),
          ])),
        ]),
      ),
      Padding(padding: const EdgeInsets.all(18), child: _sectionsBody(ctx, skillsSolid: true)),
    ]));
  }
}

// ── 🌟 CONCEPT TIMELINE ────────────────────────────────────────────────────
class _ConceptLayout extends StatelessWidget {
  final _ResumeContext ctx;
  const _ConceptLayout({required this.ctx});
  @override
  Widget build(BuildContext context) {
    final c = ctx.accent;
    return Container(color: Colors.white, padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(width: 5, height: 40, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ctx.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c)),
          if (ctx.role.isNotEmpty) Text(ctx.role, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.withValues(alpha: 0.8))),
        ]),
      ]),
      const SizedBox(height: 8),
      Wrap(spacing: 12, runSpacing: 4, children: ctx.contacts.map((cn) => Text('${cn['icon']} ${cn['val']}', style: const TextStyle(fontSize: 10, color: Color(0xFF666666)))).toList()),
      const SizedBox(height: 10),
      Container(height: 2, color: c),
      _sectionsBody(ctx),
    ]));
  }
}

// ── 🌟 VIBES CREATIVE ──────────────────────────────────────────────────────
class _VibesLayout extends StatelessWidget {
  final _ResumeContext ctx;
  const _VibesLayout({required this.ctx});
  @override
  Widget build(BuildContext context) {
    final c = ctx.accent;
    return Container(color: Colors.white, padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Text(ctx.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c))),
      if (ctx.role.isNotEmpty) Center(child: Text(ctx.role.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c, letterSpacing: 1.5))),
      const SizedBox(height: 6),
      Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 4, children: ctx.contacts.map((cn) => Text('${cn['icon']} ${cn['val']}', style: const TextStyle(fontSize: 10, color: Color(0xFF555555)))).toList()),
      const SizedBox(height: 10),
      _sectionsBody(ctx, skillsSolid: false),
    ]));
  }
}

// ── 🌟 CUBIC CARD BLOCKS ───────────────────────────────────────────────────
class _CubicLayout extends StatelessWidget {
  final _ResumeContext ctx;
  const _CubicLayout({required this.ctx});
  @override
  Widget build(BuildContext context) {
    final c = ctx.accent;
    return Container(color: Colors.white, padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: c.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: c.withValues(alpha: 0.2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ctx.name, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: c)),
          if (ctx.role.isNotEmpty) Text(ctx.role, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c)),
          const SizedBox(height: 6),
          Wrap(spacing: 12, runSpacing: 4, children: ctx.contacts.map((cn) => Text('${cn['icon']} ${cn['val']}', style: const TextStyle(fontSize: 9.5, color: Color(0xFF4A5568)))).toList()),
        ]),
      ),
      _sectionsBody(ctx),
    ]));
  }
}

// ── 🌟 DIAMOND LEADERSHIP ──────────────────────────────────────────────────
class _DiamondLayout extends StatelessWidget {
  final _ResumeContext ctx;
  const _DiamondLayout({required this.ctx});
  @override
  Widget build(BuildContext context) {
    final c = ctx.accent;
    return Container(color: Colors.white, padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Text(ctx.name.toUpperCase(), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: 2.5))),
      const SizedBox(height: 4),
      Center(child: Container(height: 2, width: 100, color: c)),
      const SizedBox(height: 4),
      if (ctx.role.isNotEmpty) Center(child: Text(ctx.role.toUpperCase(), style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w700, letterSpacing: 1.5))),
      const SizedBox(height: 8),
      Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 4, children: ctx.contacts.map((cn) => Text('${cn['icon']} ${cn['val']}', style: const TextStyle(fontSize: 10, color: Color(0xFF4B5563)))).toList()),
      _sectionsBody(ctx),
    ]));
  }
}

// ── 1. Classic Premium ─────────────────────────────────────────────────────
class _ClassicLayout extends StatelessWidget {
  final _ResumeContext ctx;
  const _ClassicLayout({required this.ctx});
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Text(ctx.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ctx.accent, letterSpacing: 0.5))),
      if (ctx.role.isNotEmpty) Center(child: Text(ctx.role.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ctx.accent.withValues(alpha: 0.8), letterSpacing: 1.5))),
      const SizedBox(height: 8),
      Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 6, children: ctx.contacts.map((c) => Row(mainAxisSize: MainAxisSize.min, children: [
        Text(c['icon']!, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 4),
        Text(c['val']!, style: const TextStyle(fontSize: 10.5, color: Color(0xFF4A5568), fontWeight: FontWeight.w500)),
      ])).toList()),
      const SizedBox(height: 12),
      Container(height: 2, decoration: BoxDecoration(gradient: LinearGradient(colors: [ctx.accent, ctx.accent.withValues(alpha: 0.2)]))),
      _sectionsBody(ctx),
    ]));
  }
}

// ── 2. Modern Header Band ──────────────────────────────────────────────────
class _HeaderBandLayout extends StatelessWidget {
  final _ResumeContext ctx;
  const _HeaderBandLayout({required this.ctx});
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity, color: ctx.accent, padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ctx.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
          if (ctx.role.isNotEmpty) Text(ctx.role.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9), letterSpacing: 1.5)),
          const SizedBox(height: 10),
          Wrap(spacing: 12, runSpacing: 6, children: ctx.contacts.map((c) => Row(mainAxisSize: MainAxisSize.min, children: [
            Text(c['icon']!, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
            Text(c['val']!, style: TextStyle(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500)),
          ])).toList()),
        ]),
      ),
      Padding(padding: const EdgeInsets.all(20), child: _sectionsBody(ctx, skillsSolid: false)),
    ]));
  }
}

// ── 3. Executive Gold ──────────────────────────────────────────────────────
class _ExecutiveLayout extends StatelessWidget {
  final _ResumeContext ctx;
  const _ExecutiveLayout({required this.ctx});
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Text(ctx.name.toUpperCase(), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: 2.5, color: Color(0xFF111827)))),
      const SizedBox(height: 4),
      Center(child: Container(height: 2, width: 100, color: ctx.accent)),
      const SizedBox(height: 4),
      if (ctx.role.isNotEmpty) Center(child: Text(ctx.role.toUpperCase(), style: TextStyle(fontSize: 11, color: ctx.accent, fontWeight: FontWeight.w700, letterSpacing: 1.5))),
      const SizedBox(height: 8),
      Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 6, children: ctx.contacts.map((c) => Row(mainAxisSize: MainAxisSize.min, children: [
        Text(c['icon']!, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 4),
        Text(c['val']!, style: const TextStyle(fontSize: 10.5, color: Color(0xFF4B5563), fontWeight: FontWeight.w500)),
      ])).toList()),
      _sectionsBody(ctx),
    ]));
  }
}

// ── 4. Minimal Clean ───────────────────────────────────────────────────────
class _MinimalLayout extends StatelessWidget {
  final _ResumeContext ctx;
  const _MinimalLayout({required this.ctx});
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(ctx.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, letterSpacing: 3, color: ctx.accent)),
      if (ctx.role.isNotEmpty) Text(ctx.role.toUpperCase(), style: TextStyle(fontSize: 10.5, color: ctx.accent.withValues(alpha: 0.8), fontWeight: FontWeight.w700, letterSpacing: 2)),
      const SizedBox(height: 8),
      Wrap(spacing: 12, runSpacing: 6, children: ctx.contacts.map((c) => Row(mainAxisSize: MainAxisSize.min, children: [
        Text(c['icon']!, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 4),
        Text(c['val']!, style: const TextStyle(fontSize: 10.5, color: Color(0xFF718096))),
      ])).toList()),
      const SizedBox(height: 8),
      Container(height: 1, color: const Color(0xFFE2E8F0)),
      _sectionsBody(ctx),
    ]));
  }
}

// ── 5. Bold Accent Bar ────────────────────────────────────────────────────
class _BoldLayout extends StatelessWidget {
  final _ResumeContext ctx;
  const _BoldLayout({required this.ctx});
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 6, height: 46, decoration: BoxDecoration(color: ctx.accent, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ctx.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ctx.accent)),
          if (ctx.role.isNotEmpty) Text(ctx.role, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4A5568))),
        ])),
      ]),
      const SizedBox(height: 10),
      Wrap(spacing: 12, runSpacing: 6, children: ctx.contacts.map((c) => Row(mainAxisSize: MainAxisSize.min, children: [
        Text(c['icon']!, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 4),
        Text(c['val']!, style: const TextStyle(fontSize: 10.5, color: Color(0xFF4A5568))),
      ])).toList()),
      const SizedBox(height: 8),
      Container(height: 2, color: ctx.accent.withValues(alpha: 0.3)),
      _sectionsBody(ctx),
    ]));
  }
}

// ── 6. Timeline Layout ────────────────────────────────────────────────────
class _TimelineLayout extends StatelessWidget {
  final _ResumeContext ctx;
  const _TimelineLayout({required this.ctx});
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(ctx.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ctx.accent)),
      if (ctx.role.isNotEmpty) Text(ctx.role, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ctx.accent.withValues(alpha: 0.8))),
      const SizedBox(height: 8),
      Wrap(spacing: 12, runSpacing: 6, children: ctx.contacts.map((c) => Row(mainAxisSize: MainAxisSize.min, children: [
        Text(c['icon']!, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 4),
        Text(c['val']!, style: const TextStyle(fontSize: 10.5, color: Color(0xFF4A5568))),
      ])).toList()),
      const SizedBox(height: 10),
      Container(height: 2, color: ctx.accent),
      _sectionsBody(ctx),
    ]));
  }
}

// ── 7. Compact Executive ──────────────────────────────────────────────────
class _CompactLayout extends StatelessWidget {
  final _ResumeContext ctx;
  const _CompactLayout({required this.ctx});
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ctx.name, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: ctx.accent)),
          if (ctx.role.isNotEmpty) Text(ctx.role, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ctx.accent.withValues(alpha: 0.8))),
        ])),
      ]),
      const SizedBox(height: 6),
      Wrap(spacing: 10, runSpacing: 4, children: ctx.contacts.map((c) => Text('${c['icon']} ${c['val']}', style: const TextStyle(fontSize: 10, color: Color(0xFF4A5568)))).toList()),
      const SizedBox(height: 6),
      Container(height: 1.5, color: ctx.accent),
      _sectionsBody(ctx),
    ]));
  }
}

// ── 8. Original Blueprint Layout (Module 3 Preservation) ─────────────────
class _OriginalBlueprintLayout extends StatelessWidget {
  final _ResumeContext ctx;
  final LayoutBlueprint bp;
  const _OriginalBlueprintLayout({required this.ctx, required this.bp});

  Color _parseColor(String hex, Color fallback) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (templateId == 'original' || templateId == 'cascade' || bp.hasSidebar) {
      return _CascadeLayout(ctx: ctx);
    }

    final primary = _parseColor(bp.primaryColorHex, ctx.accent);
    final secondary = _parseColor(bp.secondaryColorHex, ctx.accent.withValues(alpha: 0.8));
    final textColor = _parseColor(bp.textColorHex, const Color(0xFF2D3748));

    // Build all sections ordered by the layout blueprint
    final sectionWidgets = <Widget>[];
    for (final sectionKey in bp.sectionOrdering) {
      switch (sectionKey) {
        case 'summary':
          if (ctx.summary.isNotEmpty) {
            sectionWidgets.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heading('PROFESSIONAL SUMMARY', primary),
                Text(ctx.summary, style: TextStyle(fontSize: bp.fontSizeBodyPt, color: textColor, height: 1.5)),
              ],
            ));
          }
          break;

        case 'experience':
          if (ctx.exp.isNotEmpty) {
            sectionWidgets.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heading('WORK EXPERIENCE', primary),
                ...ctx.exp.map((w) {
                  final rawBullets = w['bullets'];
                  final rawPts = (w['pts'] ?? '').toString();
                  List<dynamic> bullets;
                  if (rawBullets is List && rawBullets.isNotEmpty) {
                    bullets = rawBullets;
                  } else if (rawPts.isNotEmpty) {
                    bullets = rawPts.split('\n').where((s) => s.trim().isNotEmpty).toList();
                  } else {
                    bullets = [];
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(child: Text(
                          '${(w['co'] ?? w['company'] ?? '').toString()} — ${(w['des'] ?? w['role'] ?? '').toString()}',
                          style: TextStyle(fontSize: bp.fontSizeBodyPt + 0.5, fontWeight: FontWeight.bold, color: primary),
                        )),
                        Text('${w['start'] ?? ''} – ${w['end'] ?? 'Present'}', style: TextStyle(fontSize: bp.fontSizeBodyPt - 1, color: secondary)),
                      ]),
                      if (bullets.isNotEmpty)
                        _bulletList(bullets),
                    ]),
                  );
                }),
              ],
            ));
          }
          break;

        case 'skills':
          // Domain-agnostic: render all skill groups
          if (ctx.skillGroups.isNotEmpty || ctx.certs.isNotEmpty || ctx.langs.isNotEmpty) {
            sectionWidgets.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heading('CORE COMPETENCIES & SKILLS', primary),
                ...ctx.skillGroups.map((grp) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ctx.skillGroups.length > 1) ...[
                      const SizedBox(height: 4),
                      Text(grp.label.toUpperCase(), style: TextStyle(fontSize: bp.fontSizeBodyPt - 1.5, fontWeight: FontWeight.w700, color: secondary, letterSpacing: 0.8)),
                      const SizedBox(height: 4),
                    ],
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: grp.skills.map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: primary.withValues(alpha: 0.2)),
                        ),
                        child: Text(s, style: TextStyle(fontSize: bp.fontSizeBodyPt - 1, fontWeight: FontWeight.w600, color: primary)),
                      )).toList(),
                    ),
                  ],
                )),
                if (ctx.certs.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('CERTIFICATIONS', style: TextStyle(fontSize: bp.fontSizeBodyPt - 1.5, fontWeight: FontWeight.w700, color: secondary, letterSpacing: 0.8)),
                  const SizedBox(height: 4),
                  ...ctx.certs.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text('• $c', style: TextStyle(fontSize: bp.fontSizeBodyPt - 0.5, color: textColor)),
                  )),
                ],
              ],
            ));
          }
          break;

        case 'education':
          if (ctx.edus.isNotEmpty) {
            sectionWidgets.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heading('EDUCATION', primary),
                ...ctx.edus.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text(
                      '${e['deg'] ?? e['degree'] ?? ''}${(e['col'] ?? e['school'] ?? '').isNotEmpty ? ' | ${e['col'] ?? e['school']}' : ''}',
                      style: TextStyle(fontSize: bp.fontSizeBodyPt, fontWeight: FontWeight.bold, color: textColor),
                    )),
                    Text('${e['yr'] ?? ''}', style: TextStyle(fontSize: bp.fontSizeBodyPt - 1, color: secondary)),
                  ]),
                )),
              ],
            ));
          }
          break;

        case 'projects':
          if (ctx.projs.isNotEmpty) {
            sectionWidgets.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heading('PROJECTS', primary),
                ...ctx.projs.map((pr) => _projBlock(pr, primary)),
              ],
            ));
          }
          break;

        case 'extra':
        case 'achievements':
          if (ctx.extra.isNotEmpty) {
            sectionWidgets.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heading('ACHIEVEMENTS', primary),
                ...ctx.extra.map((x) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(children: [
                    Icon(Icons.star, size: 11, color: primary),
                    const SizedBox(width: 6),
                    Expanded(child: Text(x, style: TextStyle(fontSize: bp.fontSizeBodyPt - 0.5, color: textColor))),
                  ]),
                )),
              ],
            ));
          }
          break;

        default:
          break;
      }
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: bp.marginHorizontalPx,
        vertical: bp.marginVerticalPx,
      ),
      child: Column(
        crossAxisAlignment: bp.alignment == 'center'
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          // Reconstructed Header
          Container(
            padding: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: primary, width: 2)),
            ),
            child: Column(
              crossAxisAlignment: bp.alignment == 'center'
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  ctx.name,
                  style: TextStyle(
                    fontSize: bp.fontSizeHeaderPt + 4,
                    fontWeight: FontWeight.w900,
                    color: primary,
                    letterSpacing: -0.5,
                  ),
                ),
                if (ctx.role.isNotEmpty)
                  Text(
                    ctx.role.toUpperCase(),
                    style: TextStyle(
                      fontSize: bp.fontSizeBodyPt + 1,
                      fontWeight: FontWeight.w700,
                      color: secondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  alignment: bp.alignment == 'center'
                      ? WrapAlignment.center
                      : WrapAlignment.start,
                  children: ctx.contacts
                      .map((c) => Text(
                            '${c['icon']} ${c['val']}',
                            style: TextStyle(fontSize: bp.fontSizeBodyPt - 0.5, color: textColor),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...sectionWidgets,
          // Footer
          const SizedBox(height: 16),
          Center(
            child: Text(
              'ATS Verified • Built with ResumeAI Pro',
              style: TextStyle(fontSize: 9, color: Colors.grey[400], fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
