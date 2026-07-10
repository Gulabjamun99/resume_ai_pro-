// lib/screens/landing_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import 'cv_source_screen.dart';
import 'jd_paste_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Text('R', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 20))),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('ResumeAI Pro', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text)),
                  const Text('ATS-Optimized Resume Builder', style: TextStyle(fontSize: 11, color: AppColors.text3)),
                ]),
              ]),
              const SizedBox(height: 32),

              // Hero
              const Text('Job-Winning Resume\nBuilt by AI', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.2)),
              const SizedBox(height: 8),
              const Text('Add your details — AI will understand, you verify, then it builds an ATS-optimized resume.', style: TextStyle(fontSize: 14, color: AppColors.text2, height: 1.5)),
              const SizedBox(height: 20),

              // Badges
              Wrap(spacing: 8, runSpacing: 8, children: const [
                AccentBadge('✅ ATS Score 90+', color: AppColors.green, bg: Color(0x1F3ECF8E)),
                AccentBadge('🤖 Real AI', color: AppColors.accent),
                AccentBadge('🔄 3 Free Edits', color: AppColors.gold, bg: Color(0x1FF6C90E)),
                AccentBadge('📄 PDF + DOCX', color: AppColors.blue, bg: Color(0x1F60A5FA)),
              ]),
              const SizedBox(height: 24),

              // Features
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
                children: const [
                  _FeatureCard('🤖', 'Claude AI', 'Action verbs, keywords — AI handles it all'),
                  _FeatureCard('✅', 'Verify First', 'Confirm your data before we build'),
                  _FeatureCard('💬', 'Chat to Edit', 'Just say "change this" — instant updates'),
                  _FeatureCard('📥', 'PDF + DOCX', 'Real files — ready to apply'),
                ],
              ),
              const SizedBox(height: 20),

              // Pricing
              Row(children: [
                Expanded(child: AppCard(
                  child: Column(children: const [
                    Text('Junior (0–3 yr)', style: TextStyle(fontSize: 11, color: AppColors.text3)),
                    SizedBox(height: 4),
                    Text('₹20', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.text)),
                    SizedBox(height: 2),
                    Text('3 edits • PDF + DOCX', style: TextStyle(fontSize: 10, color: AppColors.text3)),
                  ]),
                )),
                const SizedBox(width: 10),
                Expanded(child: AppCard(
                  borderColor: AppColors.accent.withOpacity(0.4),
                  color: AppColors.accent.withOpacity(0.04),
                  child: Column(children: const [
                    Text('Senior (4+ yr)', style: TextStyle(fontSize: 11, color: AppColors.text3)),
                    SizedBox(height: 4),
                    Text('₹50', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.accent)),
                    SizedBox(height: 2),
                    Text('3 edits • Achievements focus', style: TextStyle(fontSize: 10, color: AppColors.text3)),
                  ]),
                )),
              ]),
              const SizedBox(height: 20),

              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CVSourceScreen())),
                  child: const Text('🚀  Start Building My Resume'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JDPasteScreen())),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.blue,
                    side: BorderSide(color: AppColors.blue.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('🎯  Tailor to a Job Description — ₹10'),
                ),
              ),
              const SizedBox(height: 20),

              // Free Tips
              AppCard(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🎁 FREE RESUME TIPS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text3, letterSpacing: 0.8)),
                  const SizedBox(height: 10),
                  ...[
                    'Use action verbs: Led, Built, Achieved, Delivered',
                    'Add numbers: "40% increase" not just "improved"',
                    'Match keywords from the job description',
                    '0–5 yr experience = 1 page, 5+ yr = max 2 pages',
                    'Skip photo, DOB, religion — modern ATS ignores them',
                    'Always include your LinkedIn and GitHub links',
                  ].map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('→ ', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                      Expanded(child: Text(tip, style: const TextStyle(fontSize: 12, color: AppColors.text2, height: 1.4))),
                    ]),
                  )),
                ],
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String icon, title, desc;
  const _FeatureCard(this.icon, this.title, this.desc);

  @override
  Widget build(BuildContext context) {
    return AppCard(padding: const EdgeInsets.all(12), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text)),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.text3, height: 1.3)),
      ],
    ));
  }
}
