// lib/screens/jd_paste_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import 'cv_source_screen.dart';

class JDPasteScreen extends StatefulWidget {
  const JDPasteScreen({super.key});
  @override
  State<JDPasteScreen> createState() => _JDPasteScreenState();
}

class _JDPasteScreenState extends State<JDPasteScreen> {
  final _jdCtrl = TextEditingController();

  void _continue() {
    final jd = _jdCtrl.text.trim();
    if (jd.length < 40) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please paste the complete job description (at least a few lines)'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CVSourceScreen(jobDescription: jd),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Tailor to Job Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
              const Text('🎯', style: TextStyle(fontSize: 36)).animate().scale(),
              const SizedBox(height: 10),
              const Text(
                'Paste Target Job Description',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: -0.3,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 8),
              const Text(
                'Copy the full job description from LinkedIn, Naukri, or company portal. AI will align your experience bullets directly to its requirements.',
                style: TextStyle(fontSize: 13, color: AppColors.text2, height: 1.5),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Flat ₹10 Special Feature • Includes 2 Free Re-Edits',
                        style: TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              const SizedBox(height: 16),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.bg3,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _jdCtrl,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(color: AppColors.text, fontSize: 13, height: 1.5),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                      hintText:
                          'Paste complete Job Description here...\n\ne.g.,\n"We are looking for a Lead Android Engineer with 5+ years experience in Kotlin, Jetpack Compose, and CI/CD pipelines..."',
                      hintStyle: TextStyle(color: AppColors.text3, fontSize: 12),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 450.ms),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Continue with Job Description', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 15)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 18),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 450.ms),
            ],
          ),
        ),
      ),
    );
  }
}
