// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../models/resume_model.dart';
import '../models/template_model.dart';
import '../services/api_service.dart';
import '../widgets/resume_preview.dart';

class ResultScreen extends StatefulWidget {
  final ResumeData resumeData;
  final String plan;
  final String templateId;
  final String templateColor;
  final int editsMax;
  final bool isJDTailored;
  const ResultScreen({
    super.key,
    required this.resumeData,
    required this.plan,
    this.templateId = 'cascade',
    this.templateColor = '#1a1a2e',
    this.editsMax = 10,
    this.isJDTailored = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late ResumeData _resume;
  late String _activeTemplateId;
  late String _activeTemplateColor;
  late TabController _tabController;

  final _chatCtrl = TextEditingController();
  final List<_ChatMsg> _messages = [];
  final _scrollCtrl = ScrollController();

  final _jdTextCtrl = TextEditingController();
  bool _isSending = false;
  bool _isDownloading = false;
  bool _isPaid = false;

  // Analysis State
  Map<String, dynamic>? _recruiterReview;
  List<dynamic> _smartSuggestions = [];
  Map<String, dynamic>? _jdMatchResult;
  bool _isLoadingReview = false;
  bool _isLoadingSuggestions = false;
  bool _isMatchingJD = false;

  int get _amount => widget.isJDTailored ? 10 : (widget.plan == 'senior' ? 50 : 20);

  final List<String> _quickPrompts = [
    'Summary short karo',
    '2025 me AWS certification ki',
    'Python skills top pe kar do',
    'Experience bullets dynamic banao',
    'Resume Google ke liye optimize karo',
    'Internship bullets tighten karo',
  ];

  // Version History State Machine (Git Commit Tree)
  final List<ResumeData> _versionHistory = [];
  int _currentVersionIndex = 0;

  void _undo() {
    if (_currentVersionIndex > 0) {
      setState(() {
        _currentVersionIndex--;
        _resume = _versionHistory[_currentVersionIndex];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⏪ Restored Version ${_currentVersionIndex + 1}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _redo() {
    if (_currentVersionIndex < _versionHistory.length - 1) {
      setState(() {
        _currentVersionIndex++;
        _resume = _versionHistory[_currentVersionIndex];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⏩ Redid to Version ${_currentVersionIndex + 1}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _resume = widget.resumeData;
    _versionHistory.add(widget.resumeData);
    _currentVersionIndex = 0;
    _activeTemplateId = widget.templateId;
    _activeTemplateColor = widget.templateColor;
    _tabController = TabController(length: 6, vsync: this);

    _messages.add(_ChatMsg(
      isAI: true,
      text: '✨ Welcome to your Live Resume Workspace!\n\nATS Optimization Score: ${_resume.atsScore}/100\n\nYou can chat naturally in Hinglish or English to edit any section (e.g. "Summary short karo" or "2025 me AWS certification complete ki"). I will update your resume live with zero data loss!',
    ));

    _loadInitialAnalysis();
    _loadUserPreferences();
    _fetchServerVersions();
  }


  @override
  void dispose() {
    _tabController.dispose();
    _chatCtrl.dispose();
    _scrollCtrl.dispose();
    _jdTextCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialAnalysis() async {
    setState(() {
      _isLoadingReview = true;
      _isLoadingSuggestions = true;
    });

    try {
      final review = await ApiService.fetchRecruiterReview(_resume);
      final suggs = await ApiService.fetchSmartSuggestions(_resume);
      if (mounted) {
        setState(() {
          _recruiterReview = review;
          _smartSuggestions = suggs;
          _isLoadingReview = false;
          _isLoadingSuggestions = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingReview = false;
          _isLoadingSuggestions = false;
        });
      }
    }
  }

  Future<void> _sendEdit(String msg) async {
    if (msg.trim().isEmpty || _isSending) return;

    setState(() {
      _messages.add(_ChatMsg(isAI: false, text: msg));
      _messages.add(_ChatMsg(isAI: true, text: '', isThinking: true));
      _isSending = true;
    });
    _chatCtrl.clear();
    _scrollToBottom();

    try {
      final updated = await ApiService.chatEditResume(_resume, msg);
      if (mounted) {
        setState(() {
          _messages.removeLast();
          _messages.add(_ChatMsg(
            isAI: true,
            text: '✅ Resume updated successfully! All requested changes are live in your preview canvas.',
          ));
          if (_currentVersionIndex < _versionHistory.length - 1) {
            _versionHistory.removeRange(_currentVersionIndex + 1, _versionHistory.length);
          }
          _versionHistory.add(updated);
          _currentVersionIndex = _versionHistory.length - 1;
          _resume = updated;
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.removeLast();
          _messages.add(_ChatMsg(
            isAI: true,
            text: '⚠️ Could not reach server to apply this edit. Please check your internet connection or try again in a moment.',
          ));
          _isSending = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _applySingleSuggestion(dynamic sug) async {
    final title = sug['title'] ?? 'Improvement';
    await _sendEdit('Apply suggestion: $title. Replace current content with: ${sug['suggested']}');
  }

  Future<void> _applyAllSuggestions() async {
    if (_smartSuggestions.isEmpty) return;
    final combined = _smartSuggestions.map((s) => '${s['section']}: ${s['suggested']}').join('\n');
    await _sendEdit('Apply all recommended recruiter suggestions to resume sections:\n$combined');
  }

  Future<void> _runJDMatch() async {
    final jdText = _jdTextCtrl.text.trim();
    if (jdText.isEmpty) return;

    setState(() => _isMatchingJD = true);
    try {
      final res = await ApiService.matchJD(_resume, jdText);
      if (mounted) {
        setState(() {
          _jdMatchResult = res;
          _isMatchingJD = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isMatchingJD = false);
    }
  }

  void _applyJDOptimization() {
    if (_jdMatchResult != null && _jdMatchResult!['optimized_data'] != null) {
      final opt = _jdMatchResult!['optimized_data'];
      setState(() {
        _resume = ResumeData.fromJson(opt);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚡ Resume tailored & optimized for Job Description!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  bool _hasUsedFreeDownload = false;
  String _userEmail = '';
  String _userPhone = '';

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasUsedFreeDownload = prefs.getBool('free_download_used') ?? false;
      _userEmail = prefs.getString('user_email') ?? '';
      _userPhone = prefs.getString('user_phone') ?? '';
    });
  }

  Future<void> _handleDownload(String format) async {
    // If candidate email/phone is missing, capture lead details first
    if (_userEmail.isEmpty || _userPhone.isEmpty) {
      _showLeadCaptureModal(format);
      return;
    }

    // 1st Resume Download is 100% FREE!
    if (!_hasUsedFreeDownload) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('free_download_used', true);
      setState(() => _hasUsedFreeDownload = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎁 1st Resume Download Unlocked 100% FREE!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
      await _executeDownload(format);
      return;
    }

    // Subsequent downloads require payment
    if (!_isPaid) {
      _showPaymentModal(format);
      return;
    }
    await _executeDownload(format);
  }

  void _showLeadCaptureModal(String format) {
    final emailCtrl = TextEditingController(text: (_resume.personal['email'] ?? '').toString());
    final phoneCtrl = TextEditingController(text: (_resume.personal['phone'] ?? '').toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          String err = '';

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF13151C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.card_giftcard, color: Color(0xFF10B981), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🎁 1st Download is 100% FREE!', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                          Text('Enter email & phone to claim your free download', style: TextStyle(color: Colors.white54, fontSize: 11.5)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Enter Email ID (e.g. rahul@gmail.com)',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Enter 10-digit Phone Number',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      prefixIcon: const Icon(Icons.phone_android, color: Colors.white54, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  if (err.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(err, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ],
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final em = emailCtrl.text.trim();
                        final ph = phoneCtrl.text.trim();
                        if (em.isEmpty || !em.contains('@')) {
                          setModalState(() => err = 'Please enter a valid Email Address');
                          return;
                        }
                        if (ph.length < 10) {
                          setModalState(() => err = 'Please enter a valid 10-digit Phone Number');
                          return;
                        }

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('user_email', em);
                        await prefs.setString('user_phone', ph);

                        if (ctx.mounted) Navigator.pop(ctx);
                        setState(() {
                          _userEmail = em;
                          _userPhone = ph;
                        });
                        _handleDownload(format);
                      },
                      icon: const Icon(Icons.download, color: Colors.white, size: 18),
                      label: const Text('Unlock 1st Free Download', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _executeDownload(String format) async {
    setState(() => _isDownloading = true);
    try {
      final file = await ApiService.downloadFile(
        _resume,
        format,
        templateId: _activeTemplateId,
        templateColor: _activeTemplateColor,
      );
      setState(() => _isDownloading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${format.toUpperCase()} downloaded to Downloads!'),
          action: SnackBarAction(
            label: 'Open File',
            textColor: AppColors.accent,
            onPressed: () => OpenFile.open(file.path),
          ),
        ),
      );
    } catch (e) {
      setState(() => _isDownloading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showPaymentModal(String format) {
    final utrCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          bool isVerifying = false;
          String errorMsg = '';

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF13151C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.download_for_offline, color: AppColors.accent, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Download HD ${format.toUpperCase()} Resume',
                            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          const Text('ATS Compliant • Lifetime Access', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            widget.isJDTailored ? 'Job Tailoring Unlock' : '${widget.plan.toUpperCase()} Resume Download',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const Text('Instant PDF & Editable DOCX', style: TextStyle(color: Colors.white38, fontSize: 11)),
                        ]),
                        Text('₹$_amount', style: const TextStyle(color: AppColors.accent, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Pay via UPI ID or QR code:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ApiService.paymentUpiId, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        GestureDetector(
                          onTap: () async {
                            final upiUrl = 'upi://pay?pa=${ApiService.paymentUpiId}&pn=ResumeAI%20Pro&am=$_amount&cu=INR';
                            if (await canLaunchUrl(Uri.parse(upiUrl))) {
                              await launchUrl(Uri.parse(upiUrl));
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: const BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.all(Radius.circular(6))),
                            child: const Text('Pay Now', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: utrCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter 12-digit UTR / Reference No.',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  if (errorMsg.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(errorMsg, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isVerifying
                          ? null
                          : () async {
                              final utr = utrCtrl.text.trim();
                              if (utr.length != 12 || int.tryParse(utr) == null) {
                                setModalState(() => errorMsg = 'Please enter valid 12-digit UTR number');
                                return;
                              }
                              setModalState(() {
                                isVerifying = true;
                                errorMsg = '';
                              });
                              final ok = await ApiService.verifyPayment(utr, _amount);
                              if (ok) {
                                if (ctx.mounted) Navigator.pop(ctx);
                                setState(() => _isPaid = true);
                                _executeDownload(format);
                              } else {
                                setModalState(() {
                                  isVerifying = false;
                                  errorMsg = 'Payment verification pending. Try again in a moment.';
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isVerifying
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Verify & Download ${format.toUpperCase()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openTemplateSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13151C),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose Template Design', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: kResumeTemplates.length,
                    itemBuilder: (context, index) {
                      final t = kResumeTemplates[index];
                      final isSelected = t.id == _activeTemplateId;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _activeTemplateId = t.id);
                          setSheetState(() {});
                        },
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? AppColors.accent : Colors.white12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(t.icon, style: const TextStyle(fontSize: 22)),
                              const SizedBox(height: 6),
                              Text(
                                t.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: isSelected ? AppColors.accent : Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Accent Theme Color', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                Row(
                  children: kTemplateColors.map((c) {
                    final hex = c.hex;
                    final isSel = hex.toLowerCase() == _activeTemplateColor.toLowerCase();
                    final colorVal = Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
                    return GestureDetector(
                      onTap: () {
                        setState(() => _activeTemplateColor = hex);
                        setSheetState(() {});
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: colorVal,
                          shape: BoxShape.circle,
                          border: Border.all(color: isSel ? Colors.white : Colors.transparent, width: 2.5),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _resume.personal;
    final name = (p['name'] ?? 'Candidate').toString();
    final role = (p['role'] ?? 'Professional').toString();

    String currentTemplateName = 'Cascade Sidebar Pro';
    for (final t in kResumeTemplates) {
      if (t.id == _activeTemplateId) {
        currentTemplateName = t.name;
        break;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161922),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(role, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
          ],
        ),
        actions: [
          // Undo Button
          IconButton(
            icon: Icon(Icons.undo, color: _currentVersionIndex > 0 ? Colors.white : Colors.white24, size: 20),
            tooltip: 'Undo Edit (⏪)',
            onPressed: _currentVersionIndex > 0 ? _undo : null,
          ),
          // Redo Button
          IconButton(
            icon: Icon(Icons.redo, color: _currentVersionIndex < _versionHistory.length - 1 ? Colors.white : Colors.white24, size: 20),
            tooltip: 'Redo Edit (⏩)',
            onPressed: _currentVersionIndex < _versionHistory.length - 1 ? _redo : null,
          ),
          // ATS Score Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, size: 12, color: Color(0xFF10B981)),
                const SizedBox(width: 4),
                Text('ATS ${_resume.atsScore}/100', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined, color: Colors.white),
            tooltip: 'Choose Template & Colors',
            onPressed: _openTemplateSelector,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.picture_as_pdf, size: 18), text: '📄 Live Preview'),
            Tab(icon: Icon(Icons.chat_bubble_outline, size: 18), text: '💬 Live Assistant'),
            Tab(icon: Icon(Icons.analytics_outlined, size: 18), text: '📊 ATS Audit'),
            Tab(icon: Icon(Icons.assignment_ind_outlined, size: 18), text: '👔 Recruiter Review'),
            Tab(icon: Icon(Icons.center_focus_strong, size: 18), text: '🎯 JD Matcher'),
            Tab(icon: Icon(Icons.history, size: 18), text: '📜 Version Control'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Live Preview Canvas
          _buildLivePreviewTab(currentTemplateName),

          // Tab 2: Conversational Live Assistant
          _buildLiveAssistantTab(),

          // Tab 3: ATS Audit & Suggestions
          _buildATSAuditTab(),

          // Tab 4: Recruiter Review Perspective
          _buildRecruiterReviewTab(),

          // Tab 5: JD Matcher
          _buildJDMatcherTab(),

          // Tab 6: Version Control (Module 10)
          _buildVersionControlTab(),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color(0xFF161922),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isDownloading ? null : () => _handleDownload('doc'),
                  icon: const Icon(Icons.description, color: Colors.white, size: 18),
                  label: const Text('Download DOCX', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isDownloading ? null : () => _handleDownload('pdf'),
                  icon: const Icon(Icons.download, color: Colors.white, size: 18),
                  label: Text(_isPaid ? 'Download PDF' : 'Download PDF (₹$_amount)', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab 1: Live Preview Canvas ──────────────────────────
  Widget _buildLivePreviewTab(String templateName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Quick template switcher bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D27),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.auto_awesome, color: AppColors.accent, size: 16),
                  const SizedBox(width: 8),
                  Text('Template: $templateName', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ]),
                GestureDetector(
                  onTap: _openTemplateSelector,
                  child: const Text('Change Template', style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          ResumePreview(
            data: _resume,
            templateId: _activeTemplateId,
            templateColor: _activeTemplateColor,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ── Tab 2: Conversational Live Assistant ────────────────
  Widget _buildLiveAssistantTab() {
    return Column(
      children: [
        // Prompt Chips
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: _quickPrompts.length,
            itemBuilder: (ctx, i) {
              final chip = _quickPrompts[i];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(chip, style: const TextStyle(color: Colors.white, fontSize: 11)),
                  backgroundColor: const Color(0xFF1A1D27),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white12)),
                  onPressed: () => _sendEdit(chip),
                ),
              );
            },
          ),
        ),

        // Chat List
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (ctx, i) {
              final msg = _messages[i];
              return _buildChatBubble(msg);
            },
          ),
        ),

        // Input Field
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFF161922),
            border: Border(top: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Type instructions in Hinglish/English (e.g. "Summary short karo")...',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF0F1117),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: _sendEdit,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: _isSending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))
                    : const Icon(Icons.send, color: AppColors.accent),
                onPressed: () => _sendEdit(_chatCtrl.text),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatBubble(_ChatMsg msg) {
    if (msg.isThinking) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: const Color(0xFF1A1D27), borderRadius: BorderRadius.circular(16)),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)),
              SizedBox(width: 10),
              Text('Updating resume section...', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    final isUser = !msg.isAI;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.accent : const Color(0xFF1A1D27),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
            bottomLeft: !isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 12.5, height: 1.45)),
      ),
    );
  }

  // ── Tab 3: ATS Audit & Suggestions ──────────────────────
  Widget _buildATSAuditTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D27),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60, height: 60,
                      child: CircularProgressIndicator(
                        value: _resume.atsScore / 100,
                        backgroundColor: Colors.white10,
                        color: const Color(0xFF10B981),
                        strokeWidth: 6,
                      ),
                    ),
                    Text('${_resume.atsScore}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ATS Compliance Audit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        _resume.atsScore >= 90
                            ? 'Excellent! Highly optimized for Indian & Global ATS scanners.'
                            : 'Good baseline. Follow recommendations below to hit 95%+ score.',
                        style: const TextStyle(color: Colors.white60, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Smart Recruiter Improvements', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              if (_smartSuggestions.isNotEmpty)
                TextButton.icon(
                  onPressed: _applyAllSuggestions,
                  icon: const Icon(Icons.bolt, color: AppColors.accent, size: 16),
                  label: const Text('1-Click Apply All', style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (_isLoadingSuggestions)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.accent)))
          else if (_smartSuggestions.isEmpty)
            const Padding(padding: EdgeInsets.all(16), child: Text('No critical improvements needed! Resume is in top shape.', style: TextStyle(color: Colors.white54, fontSize: 12)))
          else
            ..._smartSuggestions.map((sug) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF161922),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                        child: Text((sug['section'] ?? 'GENERAL').toString().toUpperCase(), style: const TextStyle(color: AppColors.accent, fontSize: 9.5, fontWeight: FontWeight.bold)),
                      ),
                      GestureDetector(
                        onTap: () => _applySingleSuggestion(sug),
                        child: const Row(children: [
                          Icon(Icons.check_circle, color: Color(0xFF10B981), size: 14),
                          SizedBox(width: 4),
                          Text('Apply', style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text((sug['title'] ?? '').toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text((sug['suggested'] ?? '').toString(), style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11.5, height: 1.4)),
                  if ((sug['reason'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('💡 ${sug['reason']}', style: const TextStyle(color: Colors.white38, fontSize: 10.5)),
                  ],
                ],
              ),
            )),
        ],
      ),
    );
  }

  // ── Tab 4: Recruiter Review Perspective ─────────────────
  Widget _buildRecruiterReviewTab() {
    if (_isLoadingReview) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    final rev = _recruiterReview ?? {};
    final prob = (rev['interview_probability'] ?? 88).toString();
    final firstImp = (rev['first_impression'] ?? 'Executive ready resume structure').toString();
    final strongPts = (rev['strong_points'] as List? ?? ['Clear experience timeline', 'Strong skills breakdown']).map((e) => e.toString()).toList();
    final weakPts = (rev['weak_points'] as List? ?? ['Add quantifiable metrics']).map((e) => e.toString()).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.accent.withValues(alpha: 0.4), const Color(0xFF161922)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                  child: Text('$prob%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Interview Call Probability', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      SizedBox(height: 2),
                      Text('Estimated based on recruiter screening benchmarks', style: TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          const Text('Recruiter First Impression', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF161922), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
            child: Text(firstImp, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, height: 1.5)),
          ),
          const SizedBox(height: 18),

          const Text('Strong Candidate Points', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          ...strongPts.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 14),
              const SizedBox(width: 8),
              Expanded(child: Text(p, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12))),
            ]),
          )),
          const SizedBox(height: 14),

          const Text('Areas for Improvement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          ...weakPts.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              const Icon(Icons.error_outline, color: Colors.orangeAccent, size: 14),
              const SizedBox(width: 8),
              Expanded(child: Text(w, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12))),
            ]),
          )),
        ],
      ),
    );
  }

  // ── Tab 5: JD Matcher ───────────────────────────────────
  Widget _buildJDMatcherTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tailor Resume to Target Job (JD Match)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          const Text('Paste the job description from LinkedIn, Naukri, or Company Portal to get instant match score and 1-click alignment.', style: TextStyle(color: Colors.white60, fontSize: 11.5)),
          const SizedBox(height: 14),

          TextField(
            controller: _jdTextCtrl,
            maxLines: 5,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Paste Job Description text here...',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
              filled: true,
              fillColor: const Color(0xFF161922),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isMatchingJD ? null : _runJDMatch,
              icon: _isMatchingJD
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.compare_arrows, color: Colors.white, size: 18),
              label: const Text('Calculate Match Score & Analyze', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_jdMatchResult != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161922),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('JD Match Score: ${_jdMatchResult!['match_score'] ?? 80}%', style: const TextStyle(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: _applyJDOptimization,
                        icon: const Icon(Icons.bolt, color: Colors.white, size: 14),
                        label: const Text('1-Click Optimize', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Matching Keywords Found:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: ((_jdMatchResult!['matching_keywords'] as List?) ?? []).map((k) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text(k.toString(), style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                    )).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text('Missing ATS Keywords:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: ((_jdMatchResult!['missing_keywords'] as List?) ?? []).map((k) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text(k.toString(), style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<dynamic> _serverVersions = [];
  bool _isLoadingVersions = false;
  Map<String, dynamic>? _selectedDiff;
  bool _isTimeTravelMode = false;
  int? _previewingVersionIndex;

  Future<void> _fetchServerVersions() async {
    setState(() => _isLoadingVersions = true);
    final vers = await ApiService.fetchVersionList();
    if (mounted) {
      setState(() {
        _serverVersions = vers;
        _isLoadingVersions = false;
      });
    }
  }

  Future<void> _handleServerRollback(int index) async {
    try {
      final res = await ApiService.rollbackVersion(index);
      if (res['full_resume_snapshot'] != null) {
        setState(() {
          _resume = ResumeData.fromJson(res['full_resume_snapshot']);
          _isTimeTravelMode = false;
          _previewingVersionIndex = null;
        });
        await _fetchServerVersions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⏪ Rolled back state to match ${res['version_id']}!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rollback failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _handleTimeTravelPreview(int index) async {
    final prev = await ApiService.previewVersion(index);
    if (prev['full_resume_snapshot'] != null) {
      setState(() {
        _resume = ResumeData.fromJson(prev['full_resume_snapshot']);
        _isTimeTravelMode = true;
        _previewingVersionIndex = index;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('👁 Time Travel Previewing Version ${prev['version_id']} (Read-Only)'),
            backgroundColor: Colors.amber[800],
          ),
        );
      }
    }
  }

  void _exitTimeTravel() {
    if (_serverVersions.isNotEmpty) {
      final latest = _serverVersions.last['full_resume_snapshot'];
      if (latest != null) {
        setState(() {
          _resume = ResumeData.fromJson(latest);
          _isTimeTravelMode = false;
          _previewingVersionIndex = null;
        });
      }
    } else {
      setState(() {
        _isTimeTravelMode = false;
        _previewingVersionIndex = null;
      });
    }
  }

  Future<void> _handleDiffVersions(int indexA, int indexB) async {
    final diff = await ApiService.diffVersions(indexA, indexB);
    setState(() => _selectedDiff = diff);
  }

  Widget _buildVersionControlTab() {
    return RefreshIndicator(
      onRefresh: _fetchServerVersions,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isTimeTravelMode) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[900]?.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history_toggle_off, color: Colors.amber, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Time Travel Mode Active: Previewing Version v${(_previewingVersionIndex ?? 0) + 1} (Read-Only)',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _exitTimeTravel,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[800]),
                      child: const Text('Exit Preview', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📜 Version History & Time-Travel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('SQLite Persisted • Non-Destructive Rollbacks', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.accent),
                  onPressed: _fetchServerVersions,
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoadingVersions)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            else if (_serverVersions.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF161922),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'No versions recorded in database yet.\nMake an edit in Live Assistant to create Version v1!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _serverVersions.length,
                itemBuilder: (context, index) {
                  final v = _serverVersions[index];
                  final vId = (v['version_id'] ?? 'v${index + 1}').toString();
                  final msg = (v['commit_message'] ?? 'Applied edit').toString();
                  final ats = (v['ats_score'] ?? 88.0).toString();
                  final author = (v['author'] ?? 'AI').toString();
                  final isCurrent = index == _serverVersions.length - 1 && !_isTimeTravelMode;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.accent.withValues(alpha: 0.12) : const Color(0xFF161922),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isCurrent ? AppColors.accent : Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCurrent ? AppColors.accent : Colors.white24,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(vId, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                Text('by $author', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('ATS $ats', style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (index > 0)
                              TextButton.icon(
                                onPressed: () => _handleDiffVersions(0, index),
                                icon: const Icon(Icons.compare_arrows, size: 14, color: AppColors.accent),
                                label: const Text('Diff vs v1', style: TextStyle(color: AppColors.accent, fontSize: 11)),
                              ),
                            const SizedBox(width: 6),
                            TextButton.icon(
                              onPressed: () => _handleTimeTravelPreview(index),
                              icon: const Icon(Icons.visibility_outlined, size: 14, color: Colors.amber),
                              label: const Text('Preview', style: TextStyle(color: Colors.amber, fontSize: 11)),
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton.icon(
                              onPressed: () => _handleServerRollback(index),
                              icon: const Icon(Icons.undo, size: 14, color: Colors.white),
                              label: const Text('Rollback', style: TextStyle(color: Colors.white, fontSize: 11)),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

            if (_selectedDiff != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF161922),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Visual Diff: ${_selectedDiff!['version_a']} ➔ ${_selectedDiff!['version_b']}',
                          style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                          onPressed: () => setState(() => _selectedDiff = null),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_selectedDiff!['recruiter_explanation'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 12.5)),
                    const SizedBox(height: 10),
                    Text('Modified Sections: ${(_selectedDiff!['modified_sections'] ?? []).join(', ')}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


class _ChatMsg {
  final bool isAI;
  final String text;
  final bool isThinking;
  _ChatMsg({required this.isAI, required this.text, this.isThinking = false});
}
