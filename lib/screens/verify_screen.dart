// lib/screens/verify_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/resume_model.dart';
import 'payment_screen.dart';

class VerifyScreen extends StatelessWidget {
  final ResumeRequest request;
  final String templateId;
  final String templateColor;
  final String jobDescription;
  const VerifyScreen({super.key, required this.request, this.templateId = 'classic', this.templateColor = '#1a1a2e', this.jobDescription = ''});

  bool get _isJD => jobDescription.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final d = request;
    final plan = _isJD ? 'JD-Tailored — ₹10' : (d.exp >= 4 ? 'Senior — ₹50' : 'Junior — ₹20');
    final planColor = _isJD ? AppColors.blue : (d.exp >= 4 ? AppColors.accent : AppColors.green);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Data'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(value: 0.5, backgroundColor: AppColors.bg3, color: AppColors.accent),
        ),
      ),
      body: Column(children: [
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _StepBar(current: 2),
            const SizedBox(height: 16),

            if (_isJD) Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(0.06),
                border: Border.all(color: AppColors.blue.withOpacity(0.25)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('🎯 Tailoring to this Job Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.blue)),
                const SizedBox(height: 6),
                Text(
                  jobDescription.length > 220 ? '${jobDescription.substring(0, 220)}...' : jobDescription,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.text2, height: 1.5),
                ),
              ]),
            ),

            // Warning box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.06),
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('⚠ Please check carefully before proceeding', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gold)),
                const SizedBox(height: 8),
                ...[
                  'Is your phone number and email correct?',
                  'Are company names, designations and dates exact?',
                  'Is your experience in years correct? (This determines your plan price)',
                  'Did you miss any important achievement or skill?',
                ].map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('⚠ ', style: TextStyle(fontSize: 10, color: AppColors.gold)),
                    Expanded(child: Text(t, style: const TextStyle(fontSize: 12, color: AppColors.gold, height: 1.4))),
                  ]),
                )),
              ]),
            ),

            // Personal
            _VCard(title: 'Personal Info', items: {
              'Full Name': d.name, 'Phone': d.phone,
              'Email': d.email, 'City': d.city,
              if (d.linkedin.isNotEmpty) 'LinkedIn': d.linkedin,
              if (d.github.isNotEmpty) 'GitHub': d.github,
            }),

            // Career
            _VCard(title: 'Career Profile', items: {
              'Target Role': d.role,
              'Experience → Plan': '${d.exp} yr',
              'Industry': d.industry.isEmpty ? '—' : d.industry,
            }, highlight: {'Experience → Plan': '${d.exp} yr → $plan'}, highlightColor: planColor),

            // Education
            if (d.edus.isNotEmpty) _VCard(
              title: 'Education',
              items: {for (var e in d.edus.where((e) => e.deg.isNotEmpty || e.col.isNotEmpty))
                '${e.deg}': '${e.col}${e.yr.isNotEmpty ? ' | ${e.yr}' : ''}${e.grade.isNotEmpty ? ' | ${e.grade}' : ''}'},
            ),

            // Work
            if (d.works.isNotEmpty) ...d.works.where((w) => w.co.isNotEmpty).map((w) =>
              _VCard(title: 'Work — ${w.co}', items: {
                'Designation': w.des.isEmpty ? '—' : w.des,
                'Duration': '${w.start} – ${w.end}',
                'Location': w.loc.isEmpty ? '—' : w.loc,
                'Responsibilities': w.pts.isEmpty ? 'Not provided' : w.pts,
              }),
            ),

            // Skills
            _VCard(title: 'Skills', items: {
              'Technical': d.skills.tech,
              if (d.skills.soft.isNotEmpty) 'Soft Skills': d.skills.soft,
              if (d.skills.cert.isNotEmpty) 'Certifications': d.skills.cert,
            }),

            const SizedBox(height: 10),
          ]),
        )),

        // Footer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
            color: AppColors.bg2,
          ),
          child: Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.text, side: const BorderSide(color: AppColors.border2), padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('← Edit Details'),
            )),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(request: request, templateId: templateId, templateColor: templateColor, jobDescription: jobDescription))),
              child: const Text('✅ All Correct — Continue'),
            )),
          ]),
        ),
      ]),
    );
  }
}

class _VCard extends StatelessWidget {
  final String title;
  final Map<String, String> items;
  final Map<String, String>? highlight;
  final Color? highlightColor;
  const _VCard({required this.title, required this.items, this.highlight, this.highlightColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.bg2, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.text3, letterSpacing: 1)),
        const SizedBox(height: 12),
        Wrap(spacing: 0, runSpacing: 10, children: items.entries.map((e) {
          final isHighlight = highlight?.containsKey(e.key) ?? false;
          final displayVal = isHighlight ? highlight![e.key]! : e.value;
          return SizedBox(
            width: e.key == 'Responsibilities' || e.key == 'Certifications' ? double.infinity : (MediaQuery.of(context).size.width - 60) / 2,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.key, style: const TextStyle(fontSize: 10, color: AppColors.text3)),
              const SizedBox(height: 2),
              Text(displayVal.isEmpty ? '—' : displayVal,
                style: TextStyle(fontSize: 12, color: isHighlight ? (highlightColor ?? AppColors.accent) : AppColors.text, fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500),
              ),
            ]),
          );
        }).toList()),
      ]),
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
      final i = e.key + 1;
      Color col = i < current ? AppColors.green : (i == current ? AppColors.accent : AppColors.text3);
      return Expanded(child: Row(children: [
        if (e.key > 0) Expanded(child: Container(height: 1, color: i <= current ? AppColors.accent.withOpacity(0.3) : AppColors.border)),
        Column(children: [
          Container(width: 22, height: 22,
            decoration: BoxDecoration(color: i < current ? AppColors.green.withOpacity(0.2) : (i == current ? AppColors.accent.withOpacity(0.2) : AppColors.bg3), shape: BoxShape.circle, border: Border.all(color: col, width: 1.5)),
            child: Center(child: Text(i < current ? '✓' : '$i', style: TextStyle(fontSize: 9, color: col, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(height: 3),
          Text(e.value, style: TextStyle(fontSize: 9, color: col)),
        ]),
      ]));
    }).toList());
  }
}
