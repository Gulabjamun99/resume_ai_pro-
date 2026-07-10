// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/resume_model.dart';

class ApiService {
  // ⚠️ Apna backend URL yahan daalo
  // Local testing: 'http://10.0.2.2:8000'  (Android emulator)
  // Real phone:    'http://192.168.1.XX:8000' (apna WiFi IP)
  // Production:    'https://your-backend.onrender.com'
  static const String baseUrl = 'https://resume-ai-backend-85zs.onrender.com';
  // ⚠️ Owner ka UPI ID yahan change krein
  static const String paymentUpiId = 'rahul@upi';

  static Future<ResumeData> generateResume(ResumeRequest req, {String templateId = 'classic', String templateColor = '#1a1a2e'}) async {
    final body = req.toJson();
    body['template_id'] = templateId;
    body['template_color'] = templateColor;
    final resp = await http.post(
      Uri.parse('$baseUrl/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 60));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return ResumeData.fromJson(data['data']);
    }
    throw Exception('Generate failed: ${resp.body}');
  }

  /// Builds a resume specifically tailored to one job description — same
  /// shape response as generateResume, but the AI reorders skills and
  /// reframes bullets to match what this JD is actually asking for.
  static Future<ResumeData> generateJDTailoredResume(ResumeRequest req, String jobDescription, {String templateId = 'classic', String templateColor = '#1a1a2e'}) async {
    final body = req.toJson();
    body['job_description'] = jobDescription;
    body['template_id'] = templateId;
    body['template_color'] = templateColor;
    final resp = await http.post(
      Uri.parse('$baseUrl/generate-jd-tailored'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 60));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return ResumeData.fromJson(data['data']);
    }
    throw Exception('JD-tailored generate failed: ${resp.body}');
  }

  static Future<ResumeData> editResume(ResumeData current, String message) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/edit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'current_data': current.toJson(),
        'user_message': message,
      }),
    ).timeout(const Duration(seconds: 45));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return ResumeData.fromJson(data['data']);
    }
    throw Exception('Edit failed: ${resp.body}');
  }

  static Future<File> downloadFile(ResumeData resumeData, String format, {String templateId = 'classic', String templateColor = '#1a1a2e'}) async {
    final endpoint = format == 'pdf' ? '/download/pdf' : '/download/doc';
    final resp = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'resume_data': resumeData.toJson(),
        'format': format,
        'template_id': templateId,
        'template_color': templateColor,
      }),
    ).timeout(const Duration(seconds: 30));

    if (resp.statusCode == 200) {
      final dir = await getApplicationDocumentsDirectory();
      final name = (resumeData.personal['name'] ?? 'Resume')
          .toString().replaceAll(' ', '_');
      final ext = format == 'pdf' ? 'pdf' : 'docx';
      final file = File('${dir.path}/${name}_Resume.$ext');
      await file.writeAsBytes(resp.bodyBytes);
      return file;
    }
    throw Exception('Download failed');
  }

  static Future<bool> checkHealth() async {
    try {
      final resp = await http.get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Uploads an old CV file (PDF/DOCX/Image) and returns the extracted raw text
  static Future<String> uploadAndExtractCV(String filePath, String fileName) async {
    final uri = Uri.parse('$baseUrl/upload-cv');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', filePath, filename: fileName));

    final streamedResp = await request.send().timeout(const Duration(seconds: 60));
    final resp = await http.Response.fromStream(streamedResp);

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data['extracted_text'] ?? '';
    }
    final err = jsonDecode(resp.body);
    throw Exception(err['detail'] ?? 'Upload failed');
  }

  /// Converts raw CV text + any new additional info into structured form-fillable data using AI
  static Future<Map<String, dynamic>> parseCV(String extractedText, String additionalInfo) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/parse-cv'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'extracted_text': extractedText,
        'additional_info': additionalInfo,
      }),
    ).timeout(const Duration(seconds: 60));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data['data'];
    }
    final err = jsonDecode(resp.body);
    throw Exception(err['detail'] ?? 'Parse failed');
  }

  static Future<bool> verifyPayment(String utr, int amount) async {
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/verify-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'utr': utr, 'amount': amount}),
      ).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return data['status'] == 'success';
      }
    } catch (_) {}
    return false;
  }
}
