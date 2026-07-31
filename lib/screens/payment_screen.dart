// lib/screens/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../models/resume_model.dart';
import '../services/api_service.dart';
import 'building_screen.dart';

class PaymentScreen extends StatefulWidget {
  final ResumeRequest request;
  final String templateId;
  final String templateColor;
  final String jobDescription;
  const PaymentScreen({super.key, required this.request, this.templateId = 'classic', this.templateColor = '#1a1a2e', this.jobDescription = ''});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late String _plan;
  final _utrController = TextEditingController();
  bool _isVerifying = false;

  bool get _isJD => widget.jobDescription.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _plan = _isJD ? 'jd_tailored' : (widget.request.exp >= 4 ? 'senior' : 'junior');
  }

  int get _amount => _isJD ? 10 : (_plan == 'senior' ? 50 : 20);
  int get _editsIncluded => _isJD ? 2 : 3;

  @override
  void dispose() {
    _utrController.dispose();
    super.dispose();
  }

  Future<void> _launchUPI() async {
    final upiUrl = 'upi://pay?pa=${ApiService.paymentUpiId}&pn=ResumeAI_Pro&am=$_amount&cu=INR&tn=ResumeAI_Pro_Order';
    try {
      final uri = Uri.parse(upiUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnack('No UPI apps found. Please pay manually to UPI: ${ApiService.paymentUpiId}', isError: true);
      }
    } catch (e) {
      _showSnack('Could not launch UPI app: $e', isError: true);
    }
  }

  Future<void> _verifyAndProceed() async {
    final utr = _utrController.text.trim();
    if (utr.length != 12 || int.tryParse(utr) == null) {
      _showSnack('Please enter a valid 12-digit UPI UTR number', isError: true);
      return;
    }

    setState(() => _isVerifying = true);
    try {
      final success = await ApiService.verifyPayment(utr, _amount);
      setState(() => _isVerifying = false);

      if (success) {
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => BuildingScreen(
            request: widget.request, plan: _plan,
            templateId: widget.templateId, templateColor: widget.templateColor,
            jobDescription: widget.jobDescription, editsMax: _editsIncluded,
          ),
        ));
      } else {
        _showErrorDialog(
          'Verification Failed',
          'This UTR has either been used before, or the payment was not received. Please double-check your UTR and try again in 1 minute.',
        );
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      _showSnack('Error verifying payment: $e', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.red : AppColors.green,
    ));
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(title, style: const TextStyle(color: AppColors.red, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(content, style: const TextStyle(color: AppColors.text2, fontSize: 13, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Plan & Pay'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(value: 0.75, backgroundColor: AppColors.bg3, color: AppColors.accent),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _StepBar(current: 3),
          const SizedBox(height: 20),

          if (_isJD)
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(0.06),
                border: Border.all(color: AppColors.blue.withOpacity(0.3), width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(children: [
                const Text('🎯 JD-Tailored Resume', style: TextStyle(fontSize: 13, color: AppColors.blue)),
                const SizedBox(height: 4),
                const Text('₹10', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.blue)),
                const SizedBox(height: 4),
                const Text('2 free edits • PDF + DOCX', style: TextStyle(fontSize: 11, color: AppColors.text3)),
              ]),
            )
          else
            Row(children: [
              _PlanCard(
                label: 'Junior', sub: '0–3 yr',
                price: '₹20', selected: _plan == 'junior',
                onTap: () => setState(() => _plan = 'junior'),
              ),
              const SizedBox(width: 10),
              _PlanCard(
                label: 'Senior', sub: '4+ yr',
                price: '₹50', selected: _plan == 'senior',
                highlighted: true,
                onTap: () => setState(() => _plan = 'senior'),
              ),
            ]),
          const SizedBox(height: 16),

          // What you get
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('What You Get', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
            const SizedBox(height: 10),
            Wrap(spacing: 0, runSpacing: 8, children: [
              'ATS-friendly layout', 'Action verbs enhanced',
              if (_isJD) 'Matched to this JD\'s keywords' else 'Industry keywords',
              'PDF + DOCX download',
              '$_editsIncluded free chat edits', 'Data 100% private',
            ].map((t) => SizedBox(
              width: (MediaQuery.of(context).size.width - 52) / 2,
              child: Row(children: [
                const Text('✓ ', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold)),
                Expanded(child: Text(t, style: const TextStyle(fontSize: 12, color: AppColors.text2))),
              ]),
            )).toList()),
          ])),
          const SizedBox(height: 14),

          // Payment form
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🔒 SECURE UPI PAYMENT (₹0 SETUP)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text3, letterSpacing: 0.8)),
            const SizedBox(height: 14),
            
            // Step 1 Button
            ElevatedButton(
              onPressed: _launchUPI,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📱 Pay via PhonePe / GPay / Paytm ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('(₹$_amount)', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step 2 Instructions
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.bg3,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('How to verify payment:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.text)),
                SizedBox(height: 4),
                Text('1. Click the button above to pay using any UPI app.', style: TextStyle(fontSize: 11, color: AppColors.text2)),
                Text('2. After payment, copy the 12-digit UTR/UPI Ref No.', style: TextStyle(fontSize: 11, color: AppColors.text2)),
                Text('3. Paste the UTR below and click Verify.', style: TextStyle(fontSize: 11, color: AppColors.text2)),
              ]),
            ),
            const SizedBox(height: 16),

            // Step 3 Text Input
            AppTextField(
              controller: _utrController,
              label: '12-DIGIT UPI UTR / REF NO',
              hint: 'e.g. 306912345678',
              keyboardType: TextInputType.number,
              required: true,
            ),
          ])),
          const SizedBox(height: 14),

          // Total
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.05),
              border: Border.all(color: AppColors.accent.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Expanded(child: Text('Resume + $_editsIncluded Edits + PDF + DOCX', style: const TextStyle(fontSize: 13, color: AppColors.text))),
              Text('₹$_amount', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.accent)),
            ]),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : _verifyAndProceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                elevation: 4,
                shadowColor: AppColors.accent.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isVerifying
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Verify UTR & Build Resume', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 15)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 18),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String label, sub, price;
  final bool selected, highlighted;
  final VoidCallback onTap;
  const _PlanCard({required this.label, required this.sub, required this.price, required this.selected, required this.onTap, this.highlighted=false});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withOpacity(0.06) : AppColors.bg2,
          border: Border.all(color: selected ? AppColors.accent : AppColors.border, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Text(label, style: TextStyle(fontSize: 12, color: selected ? AppColors.accent : AppColors.text2)),
          Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.text3)),
          const SizedBox(height: 6),
          Text(price, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: selected ? AppColors.accent : AppColors.text)),
          const SizedBox(height: 4),
          const Text('3 edits • PDF + DOCX', style: TextStyle(fontSize: 10, color: AppColors.text3)),
          if (selected) ...[
            const SizedBox(height: 6),
            Container(width: 20, height: 20, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle), child: const Center(child: Text('✓', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)))),
          ]
        ]),
      ),
    ));
  }
}

class _StepBar extends StatelessWidget {
  final int current;
  const _StepBar({required this.current});
  @override
  Widget build(BuildContext context) {
    final steps = ['Details', 'Verify', 'Pay', 'Resume'];
    return Row(children: steps.asMap().entries.map((e) {
      final i = e.key + 1;
      Color col = i < current ? AppColors.green : (i == current ? AppColors.accent : AppColors.text3);
      return Expanded(child: Row(children: [
        if (e.key > 0) Expanded(child: Container(height: 1, color: i <= current ? AppColors.accent.withOpacity(0.3) : AppColors.border)),
        Column(children: [
          Container(width: 22, height: 22, decoration: BoxDecoration(color: i < current ? AppColors.green.withOpacity(0.2) : (i == current ? AppColors.accent.withOpacity(0.2) : AppColors.bg3), shape: BoxShape.circle, border: Border.all(color: col, width: 1.5)),
            child: Center(child: Text(i < current ? '✓' : '$i', style: TextStyle(fontSize: 9, color: col, fontWeight: FontWeight.w700)))),
          const SizedBox(height: 3),
          Text(e.value, style: TextStyle(fontSize: 9, color: col)),
        ]),
      ]));
    }).toList());
  }
}
