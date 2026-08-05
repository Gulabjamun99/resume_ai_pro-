// lib/screens/landing_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import 'cv_upload_screen.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Brand Logo
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'R',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'ResumeAI Pro',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Universal Domain AI Resume Studio v6.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

              const SizedBox(height: 30),

              // Hero Title
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                    height: 1.15,
                    letterSpacing: -0.6,
                  ),
                  children: [
                    TextSpan(text: 'AI-Powered Resume\n'),
                    TextSpan(text: 'Built for Any Domain', style: TextStyle(color: AppColors.accent)),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 450.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 12),

              const Text(
                'Upload your resume in any format (PDF, DOCX, DOC, Image). Our Deep AI Engine extracts 100% of your career data, locks your original design, and allows multilingual AI editing.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.text2,
                  height: 1.55,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 450.ms),

              const SizedBox(height: 20),

              // Live Badges
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  AccentBadge('✨ 100% Free Beta', color: Color(0xFF10B981)),
                  AccentBadge('⚡ Universal Domain AI', color: Color(0xFF06B6D4)),
                  AccentBadge('🛡️ Layout Locked & Preserved', color: Color(0xFF8B5CF6)),
                  AccentBadge('📄 DOCX & PDF Export', color: Color(0xFFF59E0B)),
                ],
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

              const SizedBox(height: 28),

              // Primary Action 1: Upload CV Card (Glassmorphic Hero Card)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CVUploadScreen()),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF101420), Color(0xFF172033)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.6), width: 1.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Upload Existing Resume',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'PDF • DOCX • DOC • JPG • PNG • TXT',
                                style: TextStyle(fontSize: 12, color: AppColors.text2),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.accent, size: 18),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms).scale(begin: const Offset(0.96, 0.96)),

              const SizedBox(height: 14),

              // Primary Action 2: Tailor to Job Description
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JDPasteScreen()),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bg2,
                      border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4), width: 1.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.gps_fixed_rounded, color: AppColors.cyan, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Tailor to Target Job (JD Match)',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Paste Job Description to optimize ATS score',
                                style: TextStyle(fontSize: 11.5, color: AppColors.text2),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.cyan, size: 16),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

              const SizedBox(height: 28),

              // Feature Grid
              const Text(
                'Powerful Resume AI Features',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
              ),
              const SizedBox(height: 14),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: const [
                  _FeatureCard('⚡', 'Deep XML Parser', 'Reads text boxes, sidebars & 2-column layouts without missing details'),
                  _FeatureCard('🛡️', 'Layout Preserved', 'Keeps original fonts, text sizes, and visual hierarchy 100% locked'),
                  _FeatureCard('💬', 'Multilingual Chat', 'Edit resume using Hinglish, Hindi, or English natural language'),
                  _FeatureCard('📜', 'Version Control', 'Visual diff highlighting with instant Undo & Redo rollbacks'),
                ],
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms),

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
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.text),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(fontSize: 10.5, color: AppColors.text2, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
