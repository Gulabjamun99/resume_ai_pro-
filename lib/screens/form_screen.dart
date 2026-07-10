// lib/screens/form_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/resume_model.dart';
import 'template_selector_screen.dart';

class FormScreen extends StatefulWidget {
  final Map<String, dynamic>? prefillData;
  final String jobDescription;
  const FormScreen({super.key, this.prefillData, this.jobDescription = ''});
  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  // Personal
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _city = TextEditingController();
  final _linkedin = TextEditingController();
  final _github = TextEditingController();
  // Career
  final _role = TextEditingController();
  final _exp = TextEditingController();
  final _industry = TextEditingController();
  final _ctc = TextEditingController();
  final _summary = TextEditingController();
  // Skills
  final _tech = TextEditingController();
  final _soft = TextEditingController();
  final _lang = TextEditingController();
  final _cert = TextEditingController();
  // Extra
  final _extra = TextEditingController();

  // Dynamic edu fields
  List<Map<String, TextEditingController>> _edus = [];
  List<Map<String, TextEditingController>> _works = [];
  List<Map<String, TextEditingController>> _projs = [];

  @override
  void initState() {
    super.initState();
    if (widget.prefillData != null) {
      _applyPrefillData(widget.prefillData!);
    } else {
      _addEdu();
      _addWork();
      _addProj();
    }
  }

  /// Fills all form fields from AI-parsed old CV data.
  /// User can verify and edit anything before proceeding.
  void _applyPrefillData(Map<String, dynamic> d) {
    _name.text = d['name']?.toString() ?? '';
    _phone.text = d['phone']?.toString() ?? '';
    _email.text = d['email']?.toString() ?? '';
    _city.text = d['city']?.toString() ?? '';
    _linkedin.text = d['linkedin']?.toString() ?? '';
    _github.text = d['github']?.toString() ?? '';
    _role.text = d['role']?.toString() ?? '';
    _exp.text = (d['exp']?.toString() ?? '0');
    _industry.text = d['industry']?.toString() ?? '';
    _ctc.text = d['ctc']?.toString() ?? '';
    _summary.text = d['summary']?.toString() ?? '';

    final sk = d['skills'] as Map<String, dynamic>? ?? {};
    _tech.text = sk['tech']?.toString() ?? '';
    _soft.text = sk['soft']?.toString() ?? '';
    _lang.text = sk['lang']?.toString() ?? '';
    _cert.text = sk['cert']?.toString() ?? '';

    _extra.text = d['extra']?.toString() ?? '';

    final edus = (d['edus'] as List?) ?? [];
    if (edus.isEmpty) {
      _addEdu();
    } else {
      for (var e in edus) {
        final c = _newEdu();
        c['deg']!.text = e['deg']?.toString() ?? '';
        c['col']!.text = e['col']?.toString() ?? '';
        c['yr']!.text = e['yr']?.toString() ?? '';
        c['grade']!.text = e['grade']?.toString() ?? '';
        c['honors']!.text = e['honors']?.toString() ?? '';
        _edus.add(c);
      }
    }

    final works = (d['works'] as List?) ?? [];
    if (works.isEmpty) {
      _addWork();
    } else {
      for (var w in works) {
        final c = _newWork();
        c['co']!.text = w['co']?.toString() ?? '';
        c['des']!.text = w['des']?.toString() ?? '';
        c['start']!.text = w['start']?.toString() ?? '';
        c['end']!.text = w['end']?.toString() ?? '';
        c['loc']!.text = w['loc']?.toString() ?? '';
        c['pts']!.text = w['pts']?.toString() ?? '';
        _works.add(c);
      }
    }

    final projs = (d['projs'] as List?) ?? [];
    if (projs.isEmpty) {
      _addProj();
    } else {
      for (var p in projs) {
        final c = _newProj();
        c['name']!.text = p['name']?.toString() ?? '';
        c['tech']!.text = p['tech']?.toString() ?? '';
        c['desc']!.text = p['desc']?.toString() ?? '';
        _projs.add(c);
      }
    }
  }

  Map<String, TextEditingController> _newEdu() => {
    'deg': TextEditingController(), 'col': TextEditingController(),
    'yr': TextEditingController(), 'grade': TextEditingController(),
    'honors': TextEditingController(),
  };
  Map<String, TextEditingController> _newWork() => {
    'co': TextEditingController(), 'des': TextEditingController(),
    'start': TextEditingController(), 'end': TextEditingController(),
    'loc': TextEditingController(), 'pts': TextEditingController(),
  };
  Map<String, TextEditingController> _newProj() => {
    'name': TextEditingController(), 'tech': TextEditingController(),
    'desc': TextEditingController(),
  };

  void _addEdu() => setState(() => _edus.add(_newEdu()));
  void _addWork() => setState(() => _works.add(_newWork()));
  void _addProj() => setState(() => _projs.add(_newProj()));

  void _proceed() {
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final email = _email.text.trim();
    final role = _role.text.trim();
    final exp = _exp.text.trim();
    final tech = _tech.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || role.isEmpty || exp.isEmpty) {
      _showError('These fields are required:\n• Full Name\n• Phone Number\n• Email\n• Target Role\n• Experience Years');
      return;
    }
    if (tech.isEmpty) {
      _showError('Technical Skills cannot be empty. Please add at least a few skills.');
      return;
    }

    final req = ResumeRequest(
      name: name, phone: phone, email: email,
      city: _city.text.trim(), linkedin: _linkedin.text.trim(), github: _github.text.trim(),
      role: role, exp: int.tryParse(exp) ?? 0,
      industry: _industry.text.trim(), ctc: _ctc.text.trim(), summary: _summary.text.trim(),
      edus: _edus.map((e) => EduEntry(
        deg: e['deg']!.text.trim(), col: e['col']!.text.trim(),
        yr: e['yr']!.text.trim(), grade: e['grade']!.text.trim(),
        honors: e['honors']!.text.trim(),
      )).where((e) => e.deg.isNotEmpty || e.col.isNotEmpty).toList(),
      works: _works.map((w) => WorkEntry(
        co: w['co']!.text.trim(), des: w['des']!.text.trim(),
        start: w['start']!.text.trim(), end: w['end']!.text.trim().isEmpty ? 'Present' : w['end']!.text.trim(),
        loc: w['loc']!.text.trim(), pts: w['pts']!.text.trim(),
      )).where((w) => w.co.isNotEmpty).toList(),
      skills: SkillsData(
        tech: tech, soft: _soft.text.trim(),
        lang: _lang.text.trim(), cert: _cert.text.trim(),
      ),
      projs: _projs.map((p) => ProjectEntry(
        name: p['name']!.text.trim(), tech: p['tech']!.text.trim(),
        desc: p['desc']!.text.trim(),
      )).where((p) => p.name.isNotEmpty).toList(),
      extra: _extra.text.trim(),
    );

    Navigator.push(context, MaterialPageRoute(builder: (_) => TemplateSelectorScreen(request: req, jobDescription: widget.jobDescription)));
  }

  void _showError(String msg) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.bg2,
      title: const Text('⚠ Fields Missing', style: TextStyle(color: AppColors.gold)),
      content: Text(msg, style: const TextStyle(color: AppColors.text2, height: 1.5)),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: AppColors.accent)))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Details'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(value: 0.25, backgroundColor: AppColors.bg3, color: AppColors.accent),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Step indicator
          _StepBar(current: 1),
          const SizedBox(height: 16),

          if (widget.jobDescription.isNotEmpty) Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.08),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(children: [
              Text('🎯 ', style: TextStyle(fontSize: 15)),
              Expanded(child: Text(
                'Tailoring mode ON — this resume will be built to match the job description you pasted.',
                style: TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w500),
              )),
            ]),
          ),

          if (widget.prefillData != null) Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.06),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('🤖 ', style: TextStyle(fontSize: 16)),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Pre-filled from your uploaded CV', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent)),
                const SizedBox(height: 4),
                const Text('Review everything below — fix anything that looks wrong or is missing before continuing.', style: TextStyle(fontSize: 11, color: AppColors.text2, height: 1.4)),
                if ((widget.prefillData!['confidence_notes'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('⚠ ${widget.prefillData!['confidence_notes']}', style: const TextStyle(fontSize: 11, color: AppColors.gold, height: 1.4)),
                ],
              ])),
            ]),
          ),

          // ─── PERSONAL ───
          _SectionCard(title: '👤 Personal Info', children: [
            _row([
              AppTextField(controller: _name, label: 'Full Name', hint: 'Rahul Kumar Sharma', required: true),
              AppTextField(controller: _phone, label: 'Phone', hint: '+91 98765 43210', required: true, keyboardType: TextInputType.phone),
            ]),
            const SizedBox(height: 12),
            _row([
              AppTextField(controller: _email, label: 'Email', hint: 'rahul@gmail.com', required: true, keyboardType: TextInputType.emailAddress),
              AppTextField(controller: _city, label: 'City', hint: 'Mumbai, Maharashtra'),
            ]),
            const SizedBox(height: 12),
            _row([
              AppTextField(controller: _linkedin, label: 'LinkedIn URL', hint: 'linkedin.com/in/rahul'),
              AppTextField(controller: _github, label: 'GitHub / Portfolio', hint: 'github.com/rahul'),
            ]),
          ]),

          // ─── CAREER ───
          _SectionCard(title: '🎯 Career Profile', children: [
            _row([
              AppTextField(controller: _role, label: 'Target Role', hint: 'Software Engineer', required: true),
              AppTextField(controller: _exp, label: 'Experience (years)', hint: '4', required: true, keyboardType: TextInputType.number),
            ]),
            const SizedBox(height: 12),
            _row([
              AppTextField(controller: _industry, label: 'Industry', hint: 'IT / Finance / Healthcare'),
              AppTextField(controller: _ctc, label: 'Current CTC (optional)', hint: '8 LPA'),
            ]),
            const SizedBox(height: 12),
            AppTextField(
              controller: _summary, label: 'Professional Summary',
              hint: '''Write your profile or paste from LinkedIn...

Or leave it blank — AI will generate a strong summary automatically.''',
              multiline: true,
            ),
            const SizedBox(height: 4),
            const Text('💡 Leave blank and AI will write a powerful summary for you', style: TextStyle(fontSize: 11, color: AppColors.text3)),
          ]),

          // ─── EDUCATION ───
          _SectionCard(title: '🎓 Education', children: [
            ..._edus.asMap().entries.map((entry) {
              final i = entry.key; final e = entry.value;
              return Column(children: [
                if (i > 0) const Divider(color: AppColors.border, height: 20),
                if (i > 0) Text('Degree ${i+1}', style: const TextStyle(fontSize: 10, color: AppColors.text3, fontWeight: FontWeight.w700)),
                if (i > 0) const SizedBox(height: 8),
                _row([
                  AppTextField(controller: e['deg']!, label: 'Degree', hint: 'B.Tech Computer Science'),
                  AppTextField(controller: e['col']!, label: 'College', hint: 'IIT Delhi / DU'),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: AppTextField(controller: e['yr']!, label: 'Year', hint: '2020')),
                  const SizedBox(width: 10),
                  Expanded(child: AppTextField(controller: e['grade']!, label: 'CGPA / %', hint: '8.2 CGPA')),
                  const SizedBox(width: 10),
                  Expanded(child: AppTextField(controller: e['honors']!, label: 'Board/Honors', hint: 'CBSE')),
                ]),
              ]);
            }),
            const SizedBox(height: 12),
            _AddMoreBtn(label: '+ Add Degree / Diploma / 12th', onTap: _addEdu),
          ]),

          // ─── WORK ───
          _SectionCard(title: '💼 Work Experience', children: [
            ..._works.asMap().entries.map((entry) {
              final i = entry.key; final w = entry.value;
              return Column(children: [
                if (i > 0) const Divider(color: AppColors.border, height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(i == 0 ? 'Job 1 (Most Recent)' : 'Job ${i+1}', style: const TextStyle(fontSize: 10, color: AppColors.text3, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _row([
                      AppTextField(controller: w['co']!, label: 'Company Name', hint: 'Infosys / TCS', required: i==0),
                      AppTextField(controller: w['des']!, label: 'Job Title', hint: 'Software Engineer'),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: AppTextField(controller: w['start']!, label: 'Start Date', hint: 'Jun 2020')),
                      const SizedBox(width: 10),
                      Expanded(child: AppTextField(controller: w['end']!, label: 'End Date', hint: 'Present')),
                      const SizedBox(width: 10),
                      Expanded(child: AppTextField(controller: w['loc']!, label: 'Location', hint: 'Pune')),
                    ]),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: w['pts']!, label: 'Responsibilities & Achievements',
                      hint: '• Developed REST APIs for 50K+ users\n• Led team of 5 engineers\n• Reduced latency by 35%\n\n💡 Tip: Copy-paste directly from LinkedIn or your old CV!',
                      multiline: true,
                    ),
                  ]),
                ),
              ]);
            }),
            const SizedBox(height: 12),
            _AddMoreBtn(label: '+ Add Another Job / Internship', onTap: _addWork),
          ]),

          // ─── SKILLS ───
          _SectionCard(title: '⚡ Skills', children: [
            AppTextField(
              controller: _tech, label: 'Technical Skills', required: true,
              hint: 'Python, React, SQL, AWS, Docker, Excel, Tableau...',
            ),
            const SizedBox(height: 4),
            const Text('Separate with commas. More relevant skills = better ATS score.', style: TextStyle(fontSize: 11, color: AppColors.text3)),
            const SizedBox(height: 12),
            _row([
              AppTextField(controller: _soft, label: 'Soft Skills', hint: 'Leadership, Communication'),
              AppTextField(controller: _lang, label: 'Languages Known', hint: 'Hindi, English'),
            ]),
            const SizedBox(height: 12),
            AppTextField(controller: _cert, label: 'Certifications & Courses', hint: 'AWS Certified (2023)\nGoogle Analytics Certificate\nPMP Certified', multiline: true),
          ]),

          // ─── PROJECTS ───
          _SectionCard(title: '🚀 Projects (Optional)', children: [
            ..._projs.asMap().entries.map((entry) {
              final i = entry.key; final p = entry.value;
              return Column(children: [
                if (i > 0) const Divider(color: AppColors.border, height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                  child: Column(children: [
                    _row([
                      AppTextField(controller: p['name']!, label: 'Project Name', hint: 'E-commerce Platform'),
                      AppTextField(controller: p['tech']!, label: 'Tech Stack', hint: 'React, Node.js, AWS'),
                    ]),
                    const SizedBox(height: 12),
                    AppTextField(controller: p['desc']!, label: 'Description & Impact', hint: 'What did you build and what was the impact...', multiline: true),
                  ]),
                ),
              ]);
            }),
            const SizedBox(height: 12),
            _AddMoreBtn(label: '+ Add Another Project', onTap: _addProj),
          ]),

          // ─── EXTRA ───
          _SectionCard(title: '🏆 Achievements & Extra (Optional)', children: [
            AppTextField(
              controller: _extra, label: 'Awards, Volunteering, Hobbies',
              hint: '• Won Best Employee Award Q2 2023\n• Speaker at PyCon India 2023\n• NSS Volunteer, University (2016–2020)\n• Hobbies: Chess, Trekking, Open Source',
              multiline: true,
            ),
          ]),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _proceed,
              child: const Text('Review & Verify My Data →'),
            ),
          ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _row(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.asMap().entries.map((e) => Expanded(
        child: Padding(padding: EdgeInsets.only(left: e.key > 0 ? 10 : 0), child: e.value),
      )).toList(),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
        const SizedBox(height: 14),
        ...children,
      ]),
    );
  }
}

class _AddMoreBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddMoreBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.text3))),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  final int current;
  const _StepBar({required this.current});

  @override
  Widget build(BuildContext context) {
    final steps = ['Details', 'Verify', 'Pay', 'Resume'];
    return Row(children: steps.asMap().entries.map((e) {
      final i = e.key + 1; final label = e.value;
      Color col = i < current ? AppColors.green : (i == current ? AppColors.accent : AppColors.text3);
      return Expanded(child: Row(children: [
        if (e.key > 0) Expanded(child: Container(height: 1, color: i <= current ? AppColors.accent.withOpacity(0.3) : AppColors.border)),
        Column(children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: i < current ? AppColors.green.withOpacity(0.2) : (i == current ? AppColors.accent.withOpacity(0.2) : AppColors.bg3),
              shape: BoxShape.circle,
              border: Border.all(color: col, width: 1.5),
            ),
            child: Center(child: Text(i < current ? '✓' : '$i', style: TextStyle(fontSize: 9, color: col, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 9, color: col)),
        ]),
      ]));
    }).toList());
  }
}
