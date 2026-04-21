import 'dart:convert';

import 'package:http/http.dart' as http;

class TranscribeResult {
  final String japanese;
  final String romaji;
  final String english;

  const TranscribeResult({
    required this.japanese,
    required this.romaji,
    required this.english,
  });

  factory TranscribeResult.fromJson(Map<String, dynamic> json) {
    return TranscribeResult(
      japanese: (json['japanese'] as String?) ?? '',
      romaji: (json['romaji'] as String?) ?? '',
      english: (json['english'] as String?) ?? '',
    );
  }
}

class TranscribeService {
  static const String baseUrl = 'https://rosia-adulatory-amada.ngrok-free.dev';

  static const _ngrokHeaders = <String, String>{
    'ngrok-skip-browser-warning': 'true',
  };

  static Future<Map<String, dynamic>> health() async {
    final uri = Uri.parse('$baseUrl/health');
    final res = await http
        .get(uri, headers: _ngrokHeaders)
        .timeout(const Duration(seconds: 6));
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return json;
  }

  /// Sends multipart/form-data with field name `file`.
  /// Pass either bytes (web) or a file path (mobile/desktop).
  static Future<TranscribeResult> transcribe({
    required String filename,
    List<int>? bytes,
    String? filePath,
  }) async {
    final uri = Uri.parse('$baseUrl/transcribe');
    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll(_ngrokHeaders);

    http.MultipartFile file;
    if (bytes != null) {
      file = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      );
    } else if (filePath != null) {
      file = await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: filename,
      );
    } else {
      throw const FormatException('No audio data provided.');
    }

    req.files.add(file);

    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw Exception('Transcribe failed (${streamed.statusCode}): $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    return TranscribeResult.fromJson(json);
  }

  // Intentionally omit an explicit content-type: the server can infer it from the bytes/filename.
}

