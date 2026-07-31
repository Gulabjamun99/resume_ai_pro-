// lib/screens/cv_source_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import 'cv_upload_screen.dart';
import 'form_screen.dart';

class CVSourceScreen extends StatelessWidget {
  final String jobDescription;
  const CVSourceScreen({super.key, this.jobDescription = ''});

  bool get _isJD => jobDescription.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          _isJD ? 'Build Your Tailored Resume' : 'Choose Import Source',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isJD ? '🎯' : '🤔', style: const TextStyle(fontSize: 38))
                  .animate()
                  .scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 12),
              Text(
                _isJD ? 'Tell Us About Your Background' : 'Do you already have\na CV or Resume?',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  height: 1.25,
                  letterSpacing: -0.3,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                _isJD
                    ? 'Upload your existing CV or paste text — AI will tailor every bullet specifically to your target Job Description.'
                    : 'Upload your file — AI will parse, extract, and auto-populate your canonical Resume Workspace.',
                style: const TextStyle(fontSize: 13, color: AppColors.text2, height: 1.5),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 28),

              // Option 1 — Upload Old CV
              _OptionCard(
                icon: '📄',
                title: 'Upload Existing Resume File',
                subtitle: 'Supports PDF, DOCX, JPG, PNG',
                badge: 'Fastest & Smartest',
                badgeColor: AppColors.accent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CVUploadScreen(jobDescription: jobDescription),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 450.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 14),

              // Option 2 — Paste old details as text
              _OptionCard(
                icon: '📋',
                title: 'Paste Resume or LinkedIn Text',
                subtitle: 'Copy-paste raw text from anywhere',
                badge: 'Quick Copy',
                badgeColor: AppColors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CVUploadScreen(
                      startInPasteMode: true,
                      jobDescription: jobDescription,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 450.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 14),

              // Option 3 — Start fresh
              _OptionCard(
                icon: '✏️',
                title: 'Build From Scratch',
                subtitle: 'Fill out interactive step-by-step forms',
                badge: 'Full Control',
                badgeColor: AppColors.gold,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FormScreen(jobDescription: jobDescription),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 450.ms).slideY(begin: 0.1, end: 0),

              const Spacer(),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bg3,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        _isJD
                            ? 'AI reorders skills, refines experience bullets, and aligns keywords with historical accuracy preserved.'
                            : 'Even after importing an existing CV, you can edit skills, add achievements, or use chat commands.',
                        style: const TextStyle(fontSize: 11, color: AppColors.text3, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String icon, title, subtitle, badge;
  final Color badgeColor;
  final VoidCallback onTap;
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bg2,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.bg3,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.text3),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.text3, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
