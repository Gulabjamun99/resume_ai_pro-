// lib/screens/result_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../models/resume_model.dart';
import '../services/api_service.dart';
import '../widgets/resume_preview.dart';

class ResultScreen extends StatefulWidget {
  final ResumeData resumeData;
  final String plan;
  final String templateId;
  final String templateColor;
  final int editsMax;
  final bool isJDTailored;
  const ResultScreen({super.key, required this.resumeData, required this.plan, this.templateId = 'classic', this.templateColor = '#1a1a2e', this.editsMax = 3, this.isJDTailored = false});
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late ResumeData _resume;
  late TabController _tabController;
  int _editsUsed = 0;
  late int _editsMax;
  final _chatCtrl = TextEditingController();
  final List<_ChatMsg> _messages = [];
  final _scrollCtrl = ScrollController();
  bool _isSending = false;
  bool _isDownloading = false;
  bool _isPaid = false;

  int get _amount => widget.isJDTailored ? 10 : (widget.plan == 'senior' ? 50 : 20);

  final _suggestions = [
    'Make summary more specific',
    'Add 2 more bullets to Job 1',
    'Reorder skills — most important first',
    'Expand the achievements section',
    'Add a certifications section',
    'Add impact numbers to projects',
  ];

  @override
  void initState() {
    super.initState();
    _resume = widget.resumeData;
    _editsMax = widget.editsMax;
    _tabController = TabController(length: 2, vsync: this);
    final jdLine = widget.isJDTailored && _resume.jdMatchScore != null
        ? '\n🎯 JD Match Score: ${_resume.jdMatchScore}/100\n'
        : '';
    _messages.add(_ChatMsg(
      isAI: true,
      text: '🎉 Your resume is ready!\n\nATS Score: ${_resume.atsScore}/100$jdLine\n\nWant to make changes? Type below or pick a suggestion:\n• "Make summary more specific"\n• "Move Python to top of skills"\n• "Add team size to Job 1"\n\nI will update it instantly!\n\nYou have $_editsMax free edit${_editsMax != 1 ? 's' : ''} included.',
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  int get _editsLeft => _editsMax - _editsUsed;

  Future<void> _sendEdit(String msg) async {
    if (msg.trim().isEmpty) return;
    if (_isSending) return;

    if (_editsLeft <= 0) {
      final ok = await _showExtraEditDialog();
      if (!ok) return;
      setState(() => _editsMax++);
    }

    setState(() {
      _messages.add(_ChatMsg(isAI: false, text: msg));
      _messages.add(_ChatMsg(isAI: true, text: '', isThinking: true));
      _isSending = true;
      _editsUsed++;
    });
    _chatCtrl.clear();
    _scrollToBottom();

    try {
      final updated = await ApiService.editResume(_resume, msg);
      setState(() {
        _messages.removeLast();
        _messages.add(_ChatMsg(
          isAI: true,
          text: '✅ Resume updated successfully!\n\n${_editsLeft > 0 ? "$_editsLeft edit${_editsLeft != 1 ? 's' : ''} remaining." : "All free edits used up."}\n\nAnything else you would like to change?',
        ));
        _resume = updated;
        _isSending = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add(_ChatMsg(isAI: true, text: '❌ Something went wrong. Please try again.\n\n$e'));
        _isSending = false;
        _editsUsed--;
      });
    }
  }

  Future<bool> _showExtraEditDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: const Text('Extra Edit', style: TextStyle(color: AppColors.gold)),
        content: Text('Your $_editsMax free edits are used up.\nPay ₹10 extra for one more edit?', style: const TextStyle(color: AppColors.text2)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppColors.text3))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, pay ₹10')),
        ],
      ),
    ) ?? false;
  }

  Future<void> _download(String format) async {
    if (!_isPaid) {
      final paid = await _showPaymentModal();
      if (!paid) return;
      setState(() => _isPaid = true);
    }
    await _executeDownload(format);
  }

  Future<void> _share(String format) async {
    if (!_isPaid) {
      final paid = await _showPaymentModal();
      if (!paid) return;
      setState(() => _isPaid = true);
    }
    await _executeShare(format);
  }

  Future<void> _executeDownload(String format) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    _showSnack('${format.toUpperCase()} file is being generated...');
    try {
      final file = await ApiService.downloadFile(_resume, format, templateId: widget.templateId, templateColor: widget.templateColor);
      setState(() => _isDownloading = false);
      _showSnack('✅ ${format.toUpperCase()} downloaded!', isSuccess: true);
      await OpenFile.open(file.path);
    } catch (e) {
      setState(() => _isDownloading = false);
      _showSnack('❌ Download failed: $e', isError: true);
    }
  }

  Future<void> _executeShare(String format) async {
    try {
      final file = await ApiService.downloadFile(_resume, format, templateId: widget.templateId, templateColor: widget.templateColor);
      await Share.shareXFiles([XFile(file.path)], text: 'My ATS-Optimized Resume');
    } catch (e) {
      _showSnack('❌ Share failed', isError: true);
    }
  }

  Future<bool> _showPaymentModal() async {
    final utrCtrl = TextEditingController();
    bool isVerifying = false;

    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('🔓 Unlock Full Download', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
                      IconButton(onPressed: () => Navigator.pop(ctx, false), icon: const Icon(Icons.close, color: AppColors.text3)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your resume is 100% complete and ATS-optimized! Pay ₹$_amount once via UPI to unlock high-resolution PDF & DOCX download.',
                    style: const TextStyle(fontSize: 13, color: AppColors.text2, height: 1.4),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final upiUrl = 'upi://pay?pa=${ApiService.paymentUpiId}&pn=ResumeAI_Pro&am=$_amount&cu=INR&tn=Resume_Download';
                        try {
                          final uri = Uri.parse(upiUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            _showSnack('UPI ID: ${ApiService.paymentUpiId}', isSuccess: true);
                          }
                        } catch (_) {}
                      },
                      icon: const Icon(Icons.account_balance_wallet_outlined),
                      label: Text('Pay ₹$_amount via UPI (GPay / PhonePe / Paytm)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('Enter 12-Digit UTR / Transaction ID:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text3)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: utrCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    style: const TextStyle(color: AppColors.text, letterSpacing: 2, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: 'e.g. 412356789012',
                      counterText: '',
                      hintStyle: TextStyle(color: AppColors.text3, letterSpacing: 0),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isVerifying ? null : () async {
                        final utr = utrCtrl.text.trim();
                        if (utr.length != 12 || int.tryParse(utr) == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid 12-digit UTR'), backgroundColor: AppColors.red));
                          return;
                        }
                        setModalState(() => isVerifying = true);
                        try {
                          final ok = await ApiService.verifyPayment(utr, _amount);
                          setModalState(() => isVerifying = false);
                          if (ok) {
                            Navigator.pop(ctx, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification failed. Double check UTR number.'), backgroundColor: AppColors.red));
                          }
                        } catch (e) {
                          setModalState(() => isVerifying = false);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red));
                        }
                      },
                      child: isVerifying
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Text('✅ Verify Payment & Download'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ) ?? false;
  }

  void _showSnack(String msg, {bool isSuccess=false, bool isError=false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.red : (isSuccess ? AppColors.green : AppColors.bg3),
    ));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('Your Resume'),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.green.withOpacity(0.3))),
            child: Text('ATS: ${_resume.atsScore}/100', style: const TextStyle(fontSize: 11, color: AppColors.green, fontWeight: FontWeight.w700)),
          ),
          if (widget.isJDTailored && _resume.jdMatchScore != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.blue.withOpacity(0.3))),
              child: Text('🎯 ${_resume.jdMatchScore}%', style: const TextStyle(fontSize: 11, color: AppColors.blue, fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.text3,
          indicatorColor: AppColors.accent,
          tabs: const [Tab(text: '📄 Preview'), Tab(text: '💬 Edit Chat')],
        ),
        actions: [
          PopupMenuButton<String>(
            color: AppColors.bg2,
            icon: const Icon(Icons.download_rounded, color: AppColors.accent),
            onSelected: (v) {
              if (v == 'pdf' || v == 'doc') _download(v);
              if (v == 'share_pdf' || v == 'share_doc') _share(v.split('_')[1]);
            },
            itemBuilder: (_) => [
              _menuItem('pdf', '📄 Download PDF'),
              _menuItem('doc', '📝 Download DOCX'),
              const PopupMenuDivider(),
              _menuItem('share_pdf', '📤 Share PDF'),
              _menuItem('share_doc', '📤 Share DOCX'),
            ],
          ),
        ],
      ),
      body: TabBarView(controller: _tabController, children: [
        // ─── PREVIEW TAB ───
        Column(children: [
          // Edit counter bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.bg2,
            child: Row(children: [
              const Text('Edits: ', style: TextStyle(fontSize: 12, color: AppColors.text3)),
              ...List.generate(_editsMax, (i) => Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _editsUsed ? AppColors.red.withOpacity(0.15) : AppColors.green.withOpacity(0.15),
                    border: Border.all(color: i < _editsUsed ? AppColors.red.withOpacity(0.4) : AppColors.green.withOpacity(0.4)),
                  ),
                  child: Center(child: Text('${i+1}', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: i < _editsUsed ? AppColors.red : AppColors.green))),
                ),
              )),
              const Spacer(),
              Text(_editsLeft > 0 ? '$_editsLeft free edits remaining' : '⚠ No edits left', style: TextStyle(fontSize: 11, color: _editsLeft > 0 ? AppColors.text3 : AppColors.gold)),
            ]),
          ),
          // Resume
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: ResumePreview(data: _resume, templateId: widget.templateId, templateColor: widget.templateColor),
          )),
          // Download bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border)), color: AppColors.bg2),
            child: Row(children: [
              Expanded(child: _DownloadBtn(label: '📄 PDF', color: const Color(0xFFFCA5A5), bg: const Color(0x1FEF4444), onTap: () => _download('pdf'), loading: _isDownloading)),
              const SizedBox(width: 10),
              Expanded(child: _DownloadBtn(label: '📝 DOCX', color: const Color(0xFF93C5FD), bg: const Color(0x1F60A5FA), onTap: () => _download('doc'), loading: _isDownloading)),
              const SizedBox(width: 10),
              Expanded(child: _DownloadBtn(label: '📤 Share', color: AppColors.accent, bg: AppColors.accent.withOpacity(0.12), onTap: () => _share('pdf'), loading: false)),
            ]),
          ),
        ]),

        // ─── CHAT TAB ───
        Column(children: [
          Expanded(child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (_, i) {
              final msg = _messages[i];
              return _ChatBubble(msg: msg);
            },
          )),
          // Suggestion chips
          Container(
            height: 40,
            color: AppColors.bg2,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: _suggestions.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _sendEdit(_suggestions[i]),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(color: AppColors.bg3, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(20)),
                  child: Center(child: Text(_suggestions[i], style: const TextStyle(fontSize: 11, color: AppColors.text3))),
                ),
              ),
            ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border)), color: AppColors.bg2),
            child: Row(children: [
              Expanded(child: TextField(
                controller: _chatCtrl,
                maxLines: 3,
                minLines: 1,
                style: const TextStyle(color: AppColors.text, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'What would you like to change? Type here...',
                  hintStyle: const TextStyle(color: AppColors.text3, fontSize: 12),
                  filled: true,
                  fillColor: AppColors.bg3,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border2)),
                  contentPadding: const EdgeInsets.all(10),
                ),
                onSubmitted: _sendEdit,
              )),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _sendEdit(_chatCtrl.text),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: _isSending ? AppColors.bg3 : AppColors.accent, borderRadius: BorderRadius.circular(10)),
                  child: Center(child: _isSending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.text3))
                    : const Icon(Icons.arrow_upward, color: Colors.black, size: 20)),
                ),
              ),
            ]),
          ),
        ]),
      ]),
    );
  }

  PopupMenuItem<String> _menuItem(String v, String label) => PopupMenuItem(
    value: v,
    child: Text(label, style: const TextStyle(color: AppColors.text, fontSize: 13)),
  );
}

class _ChatMsg {
  final bool isAI, isThinking;
  final String text;
  _ChatMsg({required this.isAI, required this.text, this.isThinking=false});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMsg msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: msg.isAI ? AppColors.bg3 : AppColors.accent.withOpacity(0.12),
          border: Border.all(color: msg.isAI ? AppColors.border : AppColors.accent.withOpacity(0.25)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10),
            bottomLeft: Radius.circular(msg.isAI ? 2 : 10),
            bottomRight: Radius.circular(msg.isAI ? 10 : 2),
          ),
        ),
        child: msg.isThinking
          ? _ThinkingDots()
          : Text(msg.text, style: TextStyle(fontSize: 13, color: msg.isAI ? AppColors.text2 : AppColors.text, height: 1.5)),
      ),
    );
  }
}

class _ThinkingDots extends StatefulWidget {
  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) => AnimationController(vsync: this, duration: const Duration(milliseconds: 400))
      ..repeat(reverse: true, period: Duration(milliseconds: 800 + i * 150)));
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) =>
      AnimatedBuilder(
        animation: _controllers[i],
        builder: (_, __) => Container(
          margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
          width: 7, height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.text3.withOpacity(0.4 + _controllers[i].value * 0.6),
          ),
        ),
      ),
    ));
  }
}

class _DownloadBtn extends StatelessWidget {
  final String label;
  final Color color, bg;
  final VoidCallback onTap;
  final bool loading;
  const _DownloadBtn({required this.label, required this.color, required this.bg, required this.onTap, required this.loading});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: bg, border: Border.all(color: color.withOpacity(0.3)), borderRadius: BorderRadius.circular(8)),
        child: Center(child: loading
          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: color))
          : Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color))),
      ),
    );
  }
}
