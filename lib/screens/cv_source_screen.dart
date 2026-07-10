// lib/screens/cv_source_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import 'cv_upload_screen.dart';
import 'form_screen.dart';

/// Pehla screen jaha user decide karta hai:
/// "Purana CV hai ya bilkul shuru se banana hai?"
/// Bilkul wahi sawaal jo Claude khud puchta hai jab koi resume banwata hai.
class CVSourceScreen extends StatelessWidget {
  final String jobDescription;
  const CVSourceScreen({super.key, this.jobDescription = ''});

  bool get _isJD => jobDescription.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isJD ? 'Build Your Tailored Resume' : 'Build Resume')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(_isJD ? '🎯' : '🤔', style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 12),
              Text(
                _isJD ? 'Now, Tell Us About You' : 'Do you already have\na CV/Resume?',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.3),
              ),
              const SizedBox(height: 8),
              Text(
                _isJD
                  ? 'Give us your CV or details — AI will tailor everything specifically to the job description you just pasted.'
                  : 'If yes, upload it — AI will read and extract the data. You can also add any new experience along with it.',
                style: const TextStyle(fontSize: 13, color: AppColors.text2, height: 1.5),
              ),
              const SizedBox(height: 28),

              // Option 1 — Upload Old CV
              _OptionCard(
                icon: '📄',
                title: 'Yes, I Have an Old CV',
                subtitle: 'Upload PDF, DOCX, or a photo',
                badge: 'Fast & Smart',
                badgeColor: AppColors.accent,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CVUploadScreen(jobDescription: jobDescription))),
              ),
              const SizedBox(height: 14),

              // Option 2 — Paste old details as text
              _OptionCard(
                icon: '📋',
                title: 'I Want to Paste Text',
                subtitle: 'Copy-paste from LinkedIn or anywhere',
                badge: 'Quick',
                badgeColor: AppColors.blue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CVUploadScreen(startInPasteMode: true, jobDescription: jobDescription))),
              ),
              const SizedBox(height: 14),

              // Option 3 — Start fresh
              _OptionCard(
                icon: '✏️',
                title: 'No, Start From Scratch',
                subtitle: 'Fill out the form with your details',
                badge: 'Full Control',
                badgeColor: AppColors.gold,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FormScreen(jobDescription: jobDescription))),
              ),

              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.bg3, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  const Text('💡 ', style: TextStyle(fontSize: 14)),
                  Expanded(child: Text(
                    _isJD
                      ? 'AI will reorder your skills, rewrite bullets, and tailor your summary to match this specific job — no fake experience, just better framing of your real background.'
                      : 'Even after uploading your old CV, you can still add new experience and new skills — AI will merge everything into one perfect resume.',
                    style: const TextStyle(fontSize: 11, color: AppColors.text3, height: 1.4),
                  )),
                ]),
              ),
              const SizedBox(height: 10),
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
    required this.icon, required this.title, required this.subtitle,
    required this.badge, required this.badgeColor, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bg2,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.bg3, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text))),
              ]),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.text3)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: badgeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Text(badge, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: badgeColor)),
              ),
            ],
          )),
          const Icon(Icons.chevron_right, color: AppColors.text3),
        ]),
      ),
    );
  }
}
