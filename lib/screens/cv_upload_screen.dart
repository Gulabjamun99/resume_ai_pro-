// lib/screens/cv_upload_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'form_screen.dart';

class CVUploadScreen extends StatefulWidget {
  final bool startInPasteMode;
  final String jobDescription;
  const CVUploadScreen({super.key, this.startInPasteMode = false, this.jobDescription = ''});
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

  // ── Pick file from device ──────────────────────────────
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'jpg', 'jpeg', 'png', 'txt'],
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
      _showErr('Could not read the file: $e');
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
        const SnackBar(content: Text('Please paste or upload your CV text first'), backgroundColor: AppColors.red),
      );
      return;
    }
    setState(() => _stage = _Stage.askNewInfo);
  }

  Future<void> _finalizeParse() async {
    setState(() => _stage = _Stage.parsing);
    try {
      final parsedData = await ApiService.parseCV(_extractedText, _newInfoCtrl.text.trim());
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => FormScreen(prefillData: parsedData, jobDescription: widget.jobDescription),
        ));
      }
    } catch (e) {
      _showErr('Trouble extracting data with AI: $e\n\nCheck if the backend is running, or try again in a moment.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Old CV')),
      body: SafeArea(
        child: switch (_stage) {
          _Stage.pickSource => _buildPickSource(),
          _Stage.readingFile => _buildLoading('Reading File...', 'Extracting text from $_pickedFileName'),
          _Stage.confirmText => _buildConfirmText(),
          _Stage.askNewInfo => _buildAskNewInfo(),
          _Stage.parsing => _buildLoading('AI Is Understanding Your Data...', 'Extracting all details from your CV'),
          _Stage.error => _buildError(),
        },
      ),
    );
  }

  // ── Stage 1: Pick file or switch to paste ──────────────
  Widget _buildPickSource() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Upload your CV', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 6),
        const Text('PDF, Word (.docx), or a photo — all work', style: TextStyle(fontSize: 13, color: AppColors.text2)),
        const SizedBox(height: 24),

        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border2, style: BorderStyle.solid, width: 1.5),
              borderRadius: BorderRadius.circular(14),
              color: AppColors.bg2,
            ),
            child: Column(children: [
              const Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.accent),
              const SizedBox(height: 10),
              const Text('Tap to choose a file', style: TextStyle(fontSize: 14, color: AppColors.text, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('PDF • DOCX • JPG • PNG', style: TextStyle(fontSize: 11, color: AppColors.text3)),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: const [
          Expanded(child: Divider(color: AppColors.border)),
          Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('or', style: TextStyle(color: AppColors.text3, fontSize: 12))),
          Expanded(child: Divider(color: AppColors.border)),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _stage = _Stage.confirmText),
            icon: const Icon(Icons.content_paste, size: 18),
            label: const Text('Paste Text Instead'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.text,
              side: const BorderSide(color: AppColors.border2),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Stage 2: Show extracted text / paste box for confirmation ──
  Widget _buildConfirmText() {
    final isPasteMode = _extractedText.isEmpty;
    if (isPasteMode && _pasteCtrl.text.isEmpty && _extractedText.isNotEmpty) {
      _pasteCtrl.text = _extractedText;
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          isPasteMode ? 'Paste your CV text here' : 'This text was extracted from your CV',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text),
        ),
        const SizedBox(height: 6),
        Text(
          isPasteMode ? 'LinkedIn profile, old resume — paste from anywhere' : 'Check it looks right — you can edit it below too',
          style: const TextStyle(fontSize: 12, color: AppColors.text2),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
            child: TextField(
              controller: isPasteMode ? _pasteCtrl : (_pasteCtrl..text = _extractedText),
              maxLines: null,
              expands: true,
              style: const TextStyle(color: AppColors.text, fontSize: 12.5, height: 1.5),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
                hintText: 'Paste your name, phone, email, work experience, education, skills — everything...',
                hintStyle: TextStyle(color: AppColors.text3, fontSize: 12),
              ),
              onChanged: (v) => _extractedText = v,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () { _extractedText = _pasteCtrl.text; _proceedToNewInfo(); },
            child: const Text('Continue →'),
          ),
        ),
      ]),
    );
  }

  // ── Stage 3: "Anything new to add?" ────────────────────
  Widget _buildAskNewInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('✨', style: TextStyle(fontSize: 32)),
        const SizedBox(height: 10),
        const Text('Anything New to Add?', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 8),
        const Text(
          'If you got a new job, learned a new skill, completed a certification, or built a new project since your old CV — mention it here. AI will merge it with your existing data.',
          style: TextStyle(fontSize: 13, color: AppColors.text2, height: 1.5),
        ),
        const SizedBox(height: 18),

        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('NEW UPDATE (optional)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text3, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          TextField(
            controller: _newInfoCtrl,
            maxLines: 6,
            style: const TextStyle(color: AppColors.text, fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Examples:\n\n"Joined XYZ Company in 2024 as Senior Developer — still working there"\n\n"Recently got AWS Certified"\n\n"Built an e-commerce app with 1000+ users"',
              hintStyle: TextStyle(color: AppColors.text3, fontSize: 12, height: 1.6),
            ),
          ),
        ])),
        const SizedBox(height: 10),

        // Suggestion chips
        Wrap(spacing: 8, runSpacing: 8, children: [
          'New job', 'New skill', 'New certification', 'Got promoted', 'New project',
        ].map((s) => GestureDetector(
          onTap: () {
            _newInfoCtrl.text = _newInfoCtrl.text.isEmpty ? '$s: ' : '${_newInfoCtrl.text}\n$s: ';
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.bg3, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(20)),
            child: Text('+ $s', style: const TextStyle(fontSize: 11, color: AppColors.text3)),
          ),
        )).toList()),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _finalizeParse,
            child: const Text('✅ Prepare My Resume Data'),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: _finalizeParse,
            child: const Text('Nothing new, skip this step', style: TextStyle(color: AppColors.text3, fontSize: 12)),
          ),
        ),
      ]),
    );
  }

  Widget _buildLoading(String title, String sub) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(width: 44, height: 44, child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 3)),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 6),
          Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.text2), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('❌', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 14),
          const Text('Something Went Wrong', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 8),
          Text(_errorMsg, style: const TextStyle(fontSize: 12, color: AppColors.text2, height: 1.5), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => setState(() => _stage = _Stage.pickSource), child: const Text('Try Again')),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => FormScreen(jobDescription: widget.jobDescription))),
            child: const Text('Fill form manually instead', style: TextStyle(color: AppColors.text3)),
          ),
        ]),
      ),
    );
  }
}
