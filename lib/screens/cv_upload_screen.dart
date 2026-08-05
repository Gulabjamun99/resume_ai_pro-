// lib/screens/cv_upload_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../services/api_service.dart';

import 'design_choice_screen.dart';

class CVUploadScreen extends StatefulWidget {
  final bool startInPasteMode;
  final String jobDescription;
  const CVUploadScreen({
    super.key,
    this.startInPasteMode = false,
    this.jobDescription = '',
  });

  @override
  State<CVUploadScreen> createState() => _CVUploadScreenState();
}

enum _Stage { pickSource, readingFile, confirmText, askNewInfo, parsing, error }

class _CVUploadScreenState extends State<CVUploadScreen> {
  _Stage _stage = _Stage.pickSource;
  String? _pickedFileName;
  String _extractedText = '';
  final _pasteCtrl = TextEditingController();
  final _newInfoCtrl = TextEditingController();
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    if (widget.startInPasteMode) _stage = _Stage.confirmText;
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'jpg', 'jpeg', 'png', 'txt', 'xps'],
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.path == null) {
        _showErr('Could not get file path. Please try again.');
        return;
      }

      setState(() {
        _stage = _Stage.readingFile;
        _pickedFileName = file.name;
      });

      final text = await ApiService.uploadAndExtractCV(file.path!, file.name);
      setState(() {
        _extractedText = text;
        _stage = _Stage.confirmText;
      });
    } catch (e) {
      _showErr('Could not read file: $e');
    }
  }

  void _showErr(String msg) {
    setState(() {
      _errorMsg = msg;
      _stage = _Stage.error;
    });
  }

  void _proceedToNewInfo() {
    if (_stage == _Stage.confirmText && widget.startInPasteMode) {
      _extractedText = _pasteCtrl.text.trim();
    }
    if (_extractedText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please paste or upload your resume text first'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    setState(() => _stage = _Stage.askNewInfo);
  }

  void _finalizeParse() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DesignChoiceScreen(
          extractedText: _extractedText,
          additionalInfo: _newInfoCtrl.text.trim(),
          jobDescription: widget.jobDescription,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Import Resume Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: switch (_stage) {
            _Stage.pickSource => _buildPickSource(),
            _Stage.readingFile => _buildLoading('Reading File...', 'Extracting text from $_pickedFileName'),
            _Stage.confirmText => _buildConfirmText(),
            _Stage.askNewInfo => _buildAskNewInfo(),
            _Stage.parsing => _buildLoading('Processing Data...', 'Organizing your resume details'),
            _Stage.error => _buildError(),
          },
        ),
      ),
    );
  }

  Widget _buildPickSource() {
    return Padding(
      key: const ValueKey('pickSource'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload your Resume',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text, letterSpacing: -0.3),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 6),
          const Text(
            'Upload PDF, Word document (.docx), or scanned image',
            style: TextStyle(fontSize: 13, color: AppColors.text2),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 24),

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.bg2,
                      AppColors.bg3.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      blurRadius: 20,
                      spreadRadius: -2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
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
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.cloud_upload_rounded, size: 34, color: Colors.white),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Tap to Select Resume File',
                      style: TextStyle(fontSize: 16, color: AppColors.text, fontWeight: FontWeight.bold, letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Supported Formats: PDF • DOCX • DOC • JPG • PNG • TXT • XPS',
                      style: TextStyle(fontSize: 11.5, color: AppColors.text2, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),

                    // Badges Row
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: const [
                        AccentBadge('✨ Universal Domain AI', color: Color(0xFF06B6D4)),
                        AccentBadge('⚡ Deep XML Parser', color: Color(0xFF10B981)),
                        AccentBadge('🛡️ Layout Locked', color: Color(0xFF8B5CF6)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 450.ms).scale(begin: const Offset(0.96, 0.96)),

          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('or paste directly', style: TextStyle(color: AppColors.text3, fontSize: 12)),
              ),
              Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _stage = _Stage.confirmText),
              icon: const Icon(Icons.content_paste_rounded, size: 18),
              label: const Text('Paste Resume Text Instead', style: TextStyle(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.text,
                side: const BorderSide(color: AppColors.border2, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 450.ms),
        ],
      ),
    );
  }

  Widget _buildConfirmText() {
    final isPasteMode = _extractedText.isEmpty;
    if (isPasteMode && _pasteCtrl.text.isEmpty && _extractedText.isNotEmpty) {
      _pasteCtrl.text = _extractedText;
    }
    return Padding(
      key: const ValueKey('confirmText'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPasteMode ? 'Paste Resume Text' : 'Extracted Text Review',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text),
          ),
          const SizedBox(height: 6),
          Text(
            isPasteMode
                ? 'Copy and paste experience, contact info, and education'
                : 'Review extracted text below. You can edit any errors before proceeding.',
            style: const TextStyle(fontSize: 12, color: AppColors.text2),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bg3,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: isPasteMode ? _pasteCtrl : (_pasteCtrl..text = _extractedText),
                maxLines: null,
                expands: true,
                style: const TextStyle(color: AppColors.text, fontSize: 13, height: 1.5),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                  hintText: 'Paste name, phone, email, experience, education, skills...',
                  hintStyle: TextStyle(color: AppColors.text3, fontSize: 12),
                ),
                onChanged: (v) => _extractedText = v,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                _extractedText = _pasteCtrl.text;
                _proceedToNewInfo();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continue', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 15)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAskNewInfo() {
    return SingleChildScrollView(
      key: const ValueKey('askNewInfo'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✨', style: TextStyle(fontSize: 34)).animate().scale(),
          const SizedBox(height: 10),
          const Text(
            'Anything New to Add?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text),
          ),
          const SizedBox(height: 8),
          const Text(
            'Added a new job, learned a skill, or earned a certification? Add updates below and AI will merge them cleanly.',
            style: TextStyle(fontSize: 13, color: AppColors.text2, height: 1.5),
          ),
          const SizedBox(height: 20),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RECENT CAREER UPDATES (OPTIONAL)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.text3, letterSpacing: 0.8),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _newInfoCtrl,
                  maxLines: 5,
                  style: const TextStyle(color: AppColors.text, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Examples:\n"Promoted to Senior Developer in 2024"\n"Earned AWS Solutions Architect certification"',
                    hintStyle: TextStyle(color: AppColors.text3, fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['+ New Promotion', '+ New Skill', '+ New Certification', '+ Recent Project'].map(
              (s) => ActionChip(
                label: Text(s, style: const TextStyle(fontSize: 11, color: AppColors.text)),
                backgroundColor: AppColors.bg3,
                side: const BorderSide(color: AppColors.border),
                onPressed: () {
                  _newInfoCtrl.text = _newInfoCtrl.text.isEmpty ? '$s: ' : '${_newInfoCtrl.text}\n$s: ';
                },
              ),
            ).toList(),
          ),

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _finalizeParse,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Build Resume Workspace',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: _finalizeParse,
              child: const Text('Skip & Build Direct', style: TextStyle(color: AppColors.text3, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(String title, String sub) {
    return Center(
      key: ValueKey(title),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 48, height: 48, child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 3.5)),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
            const SizedBox(height: 8),
            Text(sub, style: const TextStyle(fontSize: 13, color: AppColors.text2), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF161922),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_done_rounded, size: 14, color: AppColors.accent),
                  SizedBox(width: 6),
                  Text('Cloud AI Engine • Processing 100% of CV details', style: TextStyle(fontSize: 10.5, color: Colors.white60)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      key: const ValueKey('error'),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 48),
            const SizedBox(height: 16),
            const Text('Parsing Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text)),
            const SizedBox(height: 8),
            Text(_errorMsg, style: const TextStyle(fontSize: 13, color: AppColors.text2, height: 1.5), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => setState(() => _stage = _Stage.pickSource),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Try Again', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
