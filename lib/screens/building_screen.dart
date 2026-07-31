// lib/screens/building_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  late final List<Map<String, String>> _pipelineStages = [
    {'title': 'Module 1 & 2: Resume Parsing & Intelligence Graph', 'desc': 'Extracting career taxonomy & skill graph'},
    {'title': 'Module 3: Design Preservation Engine', 'desc': 'Structuring typography & visual specs'},
    {'title': 'Module 5: Cognitive Thinking Engine', 'desc': 'Formulating section-scoped edit plan'},
    {'title': 'Module 6: Differential Patch Engine', 'desc': 'Generating non-destructive JSON patch'},
    {'title': 'Module 7: AI Resume Guardian Safety Gate', 'desc': 'Evaluating 5-stage historical truthfulness'},
    {'title': 'Module 8: Multi-Dimensional Health Engine', 'desc': 'Calculating ATS compatibility score'},
    {'title': 'Module 9: Real-Time Rendering Engine', 'desc': 'Computing layout stability & SHA-256 fingerprint'},
    {'title': 'Module 10: Multi-Version Control Engine', 'desc': 'Persisting version commit in SQLite'},
  ];

  int _currentStage = 0;
  double _progress = 0.05;
  String _error = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _executeBuildPipeline();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _executeBuildPipeline() async {
    setState(() {
      _error = '';
      _progress = 0.05;
      _currentStage = 0;
    });

    // Animate stage progression smoothly while API runs
    final stageDuration = const Duration(milliseconds: 350);
    for (int i = 0; i < _pipelineStages.length - 1; i++) {
      await Future.delayed(stageDuration);
      if (mounted) {
        setState(() {
          _currentStage = i + 1;
          _progress = (i + 1) / _pipelineStages.length * 0.90;
        });
      }
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
        resumeData = await ApiService.generateJDTailoredResume(
          widget.request!,
          widget.jobDescription,
          templateId: widget.templateId,
          templateColor: widget.templateColor,
        );
      } else {
        resumeData = await ApiService.generateResume(
          widget.request!,
          templateId: widget.templateId,
          templateColor: widget.templateColor,
        );
      }

      if (mounted) {
        setState(() {
          _progress = 1.0;
          _currentStage = _pipelineStages.length;
        });
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              resumeData: resumeData,
              plan: widget.plan,
              templateId: widget.templateId,
              templateColor: widget.templateColor,
              editsMax: widget.editsMax,
              isJDTailored: _isJD,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentInt = (_progress * 100).toInt();
    final remainingSecs = (100 - percentInt) ~/ 20;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Glowing AI Sphere
                ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                    CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                  ),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.green],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.auto_awesome_rounded, color: Colors.black, size: 36),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  _isJD ? 'Tailoring Resume to Target Job...' : 'Building Resume Workspace...',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 6),
                Text(
                  _isJD
                      ? 'Executing 10-module AI intelligence pipeline & ATS keyword alignment'
                      : 'Executing 10-module AI engine with Guardian safety checks',
                  style: const TextStyle(fontSize: 13, color: AppColors.text2),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Percentage Progress Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$percentInt% Completed',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.bg3,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'Est. ${remainingSecs > 0 ? remainingSecs : 1}s remaining',
                        style: const TextStyle(fontSize: 11, color: AppColors.text3, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    backgroundColor: AppColors.bg3,
                    color: AppColors.accent,
                  ),
                ),

                const SizedBox(height: 24),

                // 8-Stage Pipeline Card
                AppCard(
                  child: Column(
                    children: _pipelineStages.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final stage = entry.value;
                      final isDone = idx < _currentStage;
                      final isActive = idx == _currentStage;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone
                                    ? AppColors.green
                                    : (isActive ? AppColors.accent : AppColors.border2),
                              ),
                              child: Center(
                                child: isDone
                                    ? const Icon(Icons.check_rounded, color: Colors.black, size: 13)
                                    : (isActive
                                        ? const SizedBox(
                                            width: 10,
                                            height: 10,
                                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                                          )
                                        : Text('${idx + 1}', style: const TextStyle(fontSize: 9, color: Colors.white70))),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stage['title']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                      color: isDone ? AppColors.text : (isActive ? AppColors.accent : AppColors.text3),
                                    ),
                                  ),
                                  if (isActive)
                                    Text(
                                      stage['desc']!,
                                      style: const TextStyle(fontSize: 10, color: AppColors.text2),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Error Retry Box
                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(0.12),
                      border: Border.all(color: AppColors.red.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.error_outline_rounded, color: AppColors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Build Failed', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w700, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_error, style: const TextStyle(color: AppColors.text2, fontSize: 12), textAlign: TextAlign.center),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.border2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Back', style: TextStyle(color: AppColors.text)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _executeBuildPipeline,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Retry Build', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
