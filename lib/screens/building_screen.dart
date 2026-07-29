// lib/screens/building_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/resume_model.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class BuildingScreen extends StatefulWidget {
  final ResumeRequest? request;
  final String plan;
  final String templateId;
  final String templateColor;
  final String jobDescription;
  final int editsMax;
  final bool isAutoBuildFromCV;
  final String extractedText;
  final String additionalInfo;
  const BuildingScreen({
    super.key,
    this.request,
    required this.plan,
    this.templateId = 'classic',
    this.templateColor = '#1a1a2e',
    this.jobDescription = '',
    this.editsMax = 3,
    this.isAutoBuildFromCV = false,
    this.extractedText = '',
    this.additionalInfo = '',
  });
  @override
  State<BuildingScreen> createState() => _BuildingScreenState();
}

class _BuildingScreenState extends State<BuildingScreen> with TickerProviderStateMixin {
  bool get _isJD => widget.jobDescription.isNotEmpty;

  late final List<String> _steps = widget.isAutoBuildFromCV ? [
    'Reading old CV & analyzing user updates...',
    'Translating Hinglish/English updates into professional phrasing...',
    'Merging work experience, skills & education...',
    'Generating ATS-optimized professional summary...',
    'Building responsive layout & ATS keyword score...',
  ] : (_isJD ? [
    'Reading the job description carefully...',
    'Identifying key skills and keywords this JD wants...',
    'Setting up personal info and contact section...',
    'Reframing your experience to match this JD...',
    'Reordering skills — JD-relevant ones first...',
    'Writing a summary tailored to this specific role...',
    'Checking JD match score...',
    'Final layout and ATS check...',
  ] : [
    'Setting up personal info and contact section...',
    'Formatting education and qualifications...',
    'Enhancing work experience with strong action verbs...',
    'Injecting industry-specific ATS keywords...',
    'Generating a powerful professional summary...',
    'Arranging skills in ATS-friendly format...',
    'Polishing projects and achievements...',
    'Final layout and ATS score check...',
  ]);
  int _currentStep = 0;
  double _progress = 0;
  String _error = '';
  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -8).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _startBuild();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _startBuild() async {
    // Animate steps while API call happens
    final stepInterval = Duration(milliseconds: 500);
    for (int i = 0; i < _steps.length - 1; i++) {
      await Future.delayed(stepInterval);
      if (mounted) setState(() {
        _currentStep = i + 1;
        _progress = (i + 1) / _steps.length * 0.85;
      });
    }

    try {
      final ResumeData resumeData;
      if (widget.isAutoBuildFromCV) {
        resumeData = await ApiService.autoBuildFromCV(
          extractedText: widget.extractedText,
          additionalInfo: widget.additionalInfo,
          jobDescription: widget.jobDescription,
          templateId: widget.templateId,
          templateColor: widget.templateColor,
        );
      } else if (_isJD) {
        resumeData = await ApiService.generateJDTailoredResume(widget.request!, widget.jobDescription, templateId: widget.templateId, templateColor: widget.templateColor);
      } else {
        resumeData = await ApiService.generateResume(widget.request!, templateId: widget.templateId, templateColor: widget.templateColor);
      }

      if (mounted) {
        setState(() { _progress = 1.0; _currentStep = _steps.length; });
        await Future.delayed(const Duration(milliseconds: 400));
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => ResultScreen(
            resumeData: resumeData, plan: widget.plan,
            templateId: widget.templateId, templateColor: widget.templateColor,
            editsMax: widget.editsMax, isJDTailored: _isJD,
          ),
        ));
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              // Floating document icon
              AnimatedBuilder(
                animation: _floatAnim,
                builder: (_, child) => Transform.translate(offset: Offset(0, _floatAnim.value), child: child),
                child: const Text('📄', style: TextStyle(fontSize: 52)),
              ),
              const SizedBox(height: 20),
              Text(_isJD ? 'Tailoring Your Resume to This Job...' : 'Writing Your Resume...', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 6),
              Text(_isJD ? 'Matching your experience to this job description' : 'Reading your data and structuring your resume', style: const TextStyle(fontSize: 13, color: AppColors.text2)),
              const SizedBox(height: 24),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 6,
                  backgroundColor: AppColors.bg3,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 20),

              // Steps
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.bg3, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                child: Column(children: _steps.asMap().entries.map((entry) {
                  final i = entry.key;
                  final isDone = i < _currentStep;
                  final isActive = i == _currentStep;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone ? AppColors.green : (isActive ? AppColors.accent : AppColors.border2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDone ? AppColors.text2 : (isActive ? AppColors.accent : AppColors.text3),
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      )),
                      if (isDone) const Text('✓', style: TextStyle(color: AppColors.green, fontSize: 12)),
                    ]),
                  );
                }).toList()),
              ),

              // Error
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.red.withOpacity(0.1), border: Border.all(color: AppColors.red.withOpacity(0.3)), borderRadius: BorderRadius.circular(10)),
                  child: Column(children: [
                    const Text('❌ Error', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(_error, style: const TextStyle(color: AppColors.text2, fontSize: 12), textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    const Text('Is the backend running?\nuvicorn main:app --port 8000 --reload', style: TextStyle(color: AppColors.text3, fontSize: 11), textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('← Back')),
                  ]),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
