// lib/screens/landing_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import 'cv_source_screen.dart';
import 'jd_paste_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Brand Logo
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accent2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'R',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'ResumeAI Pro',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'ATS-Optimized Resume Intelligence Engine',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.text3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

              const SizedBox(height: 28),

              // Hero Headline
              const Text(
                'Job-Winning Resume\nDesigned for Impact',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 450.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 10),

              const Text(
                'Add your career details — our engine structures your experience, validates historical accuracy, and builds an ATS-optimized resume.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.text2,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 450.ms),

              const SizedBox(height: 20),

              // Enterprise Badges
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  AccentBadge('✅ ATS Score 90+', color: AppColors.green, bg: Color(0x1F3ECF8E)),
                  AccentBadge('🎯 5-Stage Guardian Gate', color: AppColors.accent),
                  AccentBadge('📜 Version History & Diff', color: AppColors.gold, bg: Color(0x1FF6C90E)),
                  AccentBadge('📄 Binary PDF + DOCX', color: AppColors.blue, bg: Color(0x1F60A5FA)),
                ],
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

              const SizedBox(height: 28),

              // Features Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: const [
                  _FeatureCard('✍️', 'ATS Optimizer', 'Action verbs & strategic keyword density'),
                  _FeatureCard('🛡️', 'AI Guardian Gate', '5-stage validation prevents hallucinations'),
                  _FeatureCard('💬', 'Chat Assistant', 'Issue natural language section edits'),
                  _FeatureCard('📜', 'Time-Travel Versioning', 'Visual visual diffs & non-destructive rollbacks'),
                ],
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),

              const SizedBox(height: 24),

              // Pricing Tiers
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      child: Column(
                        children: const [
                          Text('Junior (0–3 yr)', style: TextStyle(fontSize: 11, color: AppColors.text3, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('₹20', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.text)),
                          SizedBox(height: 2),
                          Text('3 Edits • PDF + DOCX', style: TextStyle(fontSize: 10, color: AppColors.text3)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      borderColor: AppColors.accent.withOpacity(0.5),
                      color: AppColors.accent.withOpacity(0.06),
                      child: Column(
                        children: const [
                          Text('Senior (4+ yr)', style: TextStyle(fontSize: 11, color: AppColors.text3, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('₹50', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.accent)),
                          SizedBox(height: 2),
                          Text('3 Edits • Executive Focus', style: TextStyle(fontSize: 10, color: AppColors.text3)),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

              const SizedBox(height: 28),

              // Main CTA Button (Minimum 52dp Touch Target)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CVSourceScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    elevation: 4,
                    shadowColor: AppColors.accent.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Start Building My Resume',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 20),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 12),

              // Secondary CTA Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JDPasteScreen()),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.blue,
                    side: BorderSide(color: AppColors.blue.withOpacity(0.5), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.target, color: AppColors.blue, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Tailor to Job Description — ₹10',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms, duration: 500.ms),

              const SizedBox(height: 28),

              // Career Tips Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.lightbulb_outline_rounded, color: AppColors.gold, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'FREE CAREER TIPS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text3,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...[
                      'Use impact action verbs: Architected, Spearheaded, Delivered',
                      'Quantify metrics: "Improved API latency by 45%"',
                      'Match core ATS keywords from target job specs',
                      'Keep experience under 5 years strictly on 1 page',
                      'Include verified LinkedIn and GitHub URLs',
                    ].map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                tip,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.text2,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 500.ms),

              const SizedBox(height: 24),
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
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.text3,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
