// lib/screens/verify_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../models/resume_model.dart';
import 'payment_screen.dart';

class VerifyScreen extends StatelessWidget {
  final ResumeRequest request;
  final String templateId;
  final String templateColor;
  final String jobDescription;
  const VerifyScreen({
    super.key,
    required this.request,
    this.templateId = 'classic',
    this.templateColor = '#1a1a2e',
    this.jobDescription = '',
  });

  bool get _isJD => jobDescription.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final d = request;
    final plan = _isJD ? 'JD-Tailored — ₹10' : (d.exp >= 4 ? 'Senior — ₹50' : 'Junior — ₹20');
    final planColor = _isJD ? AppColors.blue : (d.exp >= 4 ? AppColors.accent : AppColors.green);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Verify Resume Workspace', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const _StepBar(current: 2),
                  const SizedBox(height: 20),

                  if (_isJD)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.1),
                        border: Border.all(color: AppColors.blue.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.target, color: AppColors.blue, size: 16),
                              SizedBox(width: 6),
                              Text('Tailoring to Target Job Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.blue)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            jobDescription.length > 220 ? '${jobDescription.substring(0, 220)}...' : jobDescription,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.text2, height: 1.5),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),

                  // Data Verification Notice
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: AppColors.gold, size: 18),
                            SizedBox(width: 6),
                            Text('Verify Data Accuracy', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...[
                          'Check phone number and email for recruiter outreach',
                          'Verify company designations, employment dates, and metrics',
                          'Confirm experience duration (determines your plan pricing)',
                        ].map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.bold)),
                                Expanded(child: Text(t, style: const TextStyle(fontSize: 12, color: AppColors.gold, height: 1.4))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                  // Personal
                  _VCard(
                    title: 'Personal Contact Info',
                    items: {
                      'Full Name': d.name,
                      'Phone': d.phone,
                      'Email': d.email,
                      'City': d.city,
                      if (d.linkedin.isNotEmpty) 'LinkedIn': d.linkedin,
                      if (d.github.isNotEmpty) 'GitHub': d.github,
                    },
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                  // Career
                  _VCard(
                    title: 'Career Profile',
                    items: {
                      'Target Role': d.role,
                      'Experience Level': '${d.exp} yr',
                      'Industry': d.industry.isEmpty ? 'General' : d.industry,
                    },
                    highlight: {'Experience Level': '${d.exp} yr → $plan'},
                    highlightColor: planColor,
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  // Education
                  if (d.edus.isNotEmpty)
                    _VCard(
                      title: 'Education',
                      items: {
                        for (var e in d.edus.where((e) => e.deg.isNotEmpty || e.col.isNotEmpty))
                          '${e.deg}': '${e.col}${e.yr.isNotEmpty ? ' | ${e.yr}' : ''}${e.grade.isNotEmpty ? ' | ${e.grade}' : ''}'
                      },
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                  // Work
                  if (d.works.isNotEmpty)
                    ...d.works.where((w) => w.co.isNotEmpty).map(
                          (w) => _VCard(
                            title: 'Work — ${w.co}',
                            items: {
                              'Designation': w.des.isEmpty ? '—' : w.des,
                              'Duration': '${w.start} – ${w.end}',
                              'Location': w.loc.isEmpty ? '—' : w.loc,
                              'Responsibilities': w.pts.isEmpty ? 'Not provided' : w.pts,
                            },
                          ),
                        ),

                  // Skills
                  _VCard(
                    title: 'Skills Taxonomy',
                    items: {
                      'Technical': d.skills.tech,
                      if (d.skills.soft.isNotEmpty) 'Soft Skills': d.skills.soft,
                      if (d.skills.cert.isNotEmpty) 'Certifications': d.skills.cert,
                    },
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Footer Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bg2,
              border: const Border(top: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.text,
                          side: const BorderSide(color: AppColors.border2, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Edit Details', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(
                              request: request,
                              templateId: templateId,
                              templateColor: templateColor,
                              jobDescription: jobDescription,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          elevation: 4,
                          shadowColor: AppColors.accent.withOpacity(0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Confirm & Continue', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 15)),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.text3, letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 0,
            runSpacing: 10,
            children: items.entries.map((e) {
              final isHighlight = highlight?.containsKey(e.key) ?? false;
              final displayVal = isHighlight ? highlight![e.key]! : e.value;
              return SizedBox(
                width: e.key == 'Responsibilities' || e.key == 'Certifications' ? double.infinity : (MediaQuery.of(context).size.width - 72) / 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.key, style: const TextStyle(fontSize: 11, color: AppColors.text3)),
                    const SizedBox(height: 2),
                    Text(
                      displayVal.isEmpty ? '—' : displayVal,
                      style: TextStyle(
                        fontSize: 13,
                        color: isHighlight ? (highlightColor ?? AppColors.accent) : AppColors.text,
                        fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
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
    return Row(
      children: steps.asMap().entries.map((e) {
        final i = e.key + 1;
        Color col = i < current ? AppColors.green : (i == current ? AppColors.accent : AppColors.text3);
        return Expanded(
          child: Row(
            children: [
              if (e.key > 0) Expanded(child: Container(height: 1.5, color: i <= current ? AppColors.accent.withOpacity(0.5) : AppColors.border)),
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: i < current ? AppColors.green.withOpacity(0.2) : (i == current ? AppColors.accent.withOpacity(0.2) : AppColors.bg3),
                      shape: BoxShape.circle,
                      border: Border.all(color: col, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        i < current ? '✓' : '$i',
                        style: TextStyle(fontSize: 10, color: col, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(e.value, style: TextStyle(fontSize: 10, color: col, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
