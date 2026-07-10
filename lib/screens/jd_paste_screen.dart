// lib/screens/jd_paste_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import 'cv_source_screen.dart';

/// First screen in the "Tailor to a Job Description" flow.
/// User pastes the JD text here, then goes on to provide their CV
/// (upload / paste / manual) same as the normal flow, but everything
/// downstream knows a jobDescription is set — which changes pricing
/// (₹10 flat), the AI prompt used, and the free-edit count (2 instead of 3).
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
        const SnackBar(content: Text('Please paste the full job description (at least a few lines)'), backgroundColor: AppColors.red),
      );
      return;
    }
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => CVSourceScreen(jobDescription: jd),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tailor to a Job')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🎯', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 10),
            const Text('Paste the Job Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
            const SizedBox(height: 8),
            const Text(
              'Copy the full JD from LinkedIn, Naukri, or the company site and paste it below. AI will read exactly what this job wants and build your resume around it.',
              style: TextStyle(fontSize: 13, color: AppColors.text2, height: 1.5),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), border: Border.all(color: AppColors.gold.withOpacity(0.3)), borderRadius: BorderRadius.circular(20)),
              child: const Text('💳 Flat ₹10 for this feature • 2 free edits included', style: TextStyle(fontSize: 11.5, color: AppColors.gold, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: _jdCtrl,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(color: AppColors.text, fontSize: 12.5, height: 1.5),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                    hintText: 'Paste the complete job description here...\n\ne.g.\n"We are looking for a Senior Backend Engineer with 5+ years experience in Go, Kubernetes, and distributed systems. You will lead a team of engineers building our payments platform..."',
                    hintStyle: TextStyle(color: AppColors.text3, fontSize: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: _continue,
              child: const Text('Continue with This JD →'),
            )),
          ]),
        ),
      ),
    );
  }
}
