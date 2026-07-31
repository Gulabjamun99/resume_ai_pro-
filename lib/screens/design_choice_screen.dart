// lib/screens/design_choice_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../models/resume_model.dart';
import '../models/template_model.dart';
import 'building_screen.dart';

class DesignChoiceScreen extends StatefulWidget {
  final String extractedText;
  final String additionalInfo;
  final String jobDescription;
  final Map<String, dynamic>? parsedData;
  const DesignChoiceScreen({
    super.key,
    required this.extractedText,
    this.additionalInfo = '',
    this.jobDescription = '',
    this.parsedData,
  });

  @override
  State<DesignChoiceScreen> createState() => _DesignChoiceScreenState();
}

class _DesignChoiceScreenState extends State<DesignChoiceScreen> {
  late LayoutBlueprint _detectedBlueprint;

  @override
  void initState() {
    super.initState();
    if (widget.parsedData != null && widget.parsedData!['layout_blueprint'] != null) {
      _detectedBlueprint = LayoutBlueprint.fromJson(
        Map<String, dynamic>.from(widget.parsedData!['layout_blueprint']),
      );
    } else {
      _detectedBlueprint = LayoutBlueprint(
        templateType: 'original',
        primaryColorHex: '#1A365D',
        fontFamilyHeader: 'Roboto',
        fontFamilyBody: 'Roboto',
        headerStyle: 'left_aligned',
        marginHorizontalPx: 20.0,
      );
    }
  }

  void _chooseOptionA() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BuildingScreen(
          plan: widget.jobDescription.isNotEmpty ? 'jd_tailored' : 'senior',
          isAutoBuildFromCV: true,
          extractedText: widget.extractedText,
          additionalInfo: widget.additionalInfo,
          jobDescription: widget.jobDescription,
          templateId: 'original',
          templateColor: _detectedBlueprint.primaryColorHex,
        ),
      ),
    );
  }

  void _chooseOptionB(String templateId, String templateColor) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BuildingScreen(
          plan: widget.jobDescription.isNotEmpty ? 'jd_tailored' : 'senior',
          isAutoBuildFromCV: true,
          extractedText: widget.extractedText,
          additionalInfo: widget.additionalInfo,
          jobDescription: widget.jobDescription,
          templateId: templateId,
          templateColor: templateColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Resume Layout & Design Strategy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✨', style: TextStyle(fontSize: 36)).animate().scale(),
              const SizedBox(height: 10),
              const Text(
                'Resume Parsed Successfully!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: -0.3,
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 6),
              const Text(
                'Module 3 analyzed your uploaded file. Choose how you want AI to format your final resume.',
                style: TextStyle(fontSize: 13, color: AppColors.text2, height: 1.5),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 24),

              // Option A Card
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _chooseOptionA,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.08),
                      border: Border.all(color: AppColors.accent, width: 2),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'RECOMMENDED FOR UPLOADED CVs',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Icon(Icons.palette_outlined, color: AppColors.accent, size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Option A: Keep My Original Design',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'AI preserves your uploaded visual layout tokens (colors, typography, margins, spacing, and header style) while enhancing content quality.',
                          style: TextStyle(fontSize: 12, color: AppColors.text2, height: 1.5),
                        ),
                        const SizedBox(height: 14),

                        // Detected Layout Blueprint Tokens
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.bg3,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('DETECTED LAYOUT BLUEPRINT (MODULE 3)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.text3, letterSpacing: 0.8)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text('Accent Color: ', style: TextStyle(fontSize: 11, color: AppColors.text3)),
                                  Container(
                                    width: 14, height: 14,
                                    decoration: BoxDecoration(
                                      color: Color(int.parse('FF${_detectedBlueprint.primaryColorHex.replaceAll('#', '')}', radix: 16)),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(_detectedBlueprint.primaryColorHex, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text)),
                                  const Spacer(),
                                  Text('Header Font: ${_detectedBlueprint.fontFamilyHeader}', style: const TextStyle(fontSize: 11, color: AppColors.text2)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Header Style: ${_detectedBlueprint.headerStyle.toUpperCase()} • Margins: ${_detectedBlueprint.marginHorizontalPx.toInt()}px',
                                style: const TextStyle(fontSize: 11, color: AppColors.text3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _chooseOptionA,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Keep Original Layout & Build Resume', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14)),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 450.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Option B Header
              Row(
                children: const [
                  Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OR CHOOSE NEW TEMPLATE', style: TextStyle(fontSize: 11, color: AppColors.text3, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                  ),
                  Expanded(child: Divider(color: AppColors.border)),
                ],
              ),

              const SizedBox(height: 16),

              // Option B Catalog
              const Text(
                'Option B: Switch to Executive Template Catalog',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select one of our 6 single-column, 100% ATS-optimized executive templates.',
                style: TextStyle(fontSize: 12, color: AppColors.text2),
              ),
              const SizedBox(height: 16),

              // Template Cards Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: kResumeTemplates.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.35,
                ),
                itemBuilder: (context, index) {
                  final t = kResumeTemplates[index];
                  return AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(t.icon, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                t.name,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ATS ${t.atsScore}% Score',
                          style: const TextStyle(fontSize: 10, color: AppColors.green, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: OutlinedButton(
                            onPressed: () => _chooseOptionB(t.id, kTemplateColors[0].hex),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.border2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Use Template', style: TextStyle(fontSize: 10.5, color: AppColors.text, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ).animate().fadeIn(delay: 300.ms, duration: 450.ms),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
