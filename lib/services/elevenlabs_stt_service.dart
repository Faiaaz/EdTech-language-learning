import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:ez_trainz/config/elevenlabs_config.dart';

/// Calls [ElevenLabs Speech-to-Text (Scribe)](https://elevenlabs.io/docs/api-reference/speech-to-text/convert)
/// to transcribe a recorded audio file into Japanese text.
///
/// Unlike on-device recognition, this is a batch operation: record a clip,
/// stop, upload, and receive the transcript. Requires the API key to have the
/// **Speech to Text** scope enabled.
class ElevenLabsSttService {
  ElevenLabsSttService._();
  static final ElevenLabsSttService instance = ElevenLabsSttService._();

  static const _endpoint = 'https://api.elevenlabs.io/v1/speech-to-text';
  final http.Client _client = http.Client();
  bool _prewarmed = false;

  bool get isAvailable => ElevenLabsConfig.isConfigured;

  /// Best-effort warmup to reduce first STT round-trip latency.
  Future<void> prewarm() async {
    if (!isAvailable || _prewarmed) return;
    _prewarmed = true;
    try {
      await _client
          .get(
            Uri.parse('https://api.elevenlabs.io/v1/models'),
            headers: {'xi-api-key': ElevenLabsConfig.apiKey},
          )
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      // Warmup is optional.
    }
  }

  /// Uploads [file] and returns the recognised text ('' if nothing recognised).
  Future<String> transcribe(File file) async {
    if (!isAvailable) {
      throw StateError('ElevenLabs STT unavailable (no API key)');
    }
    if (!await file.exists()) {
      throw StateError('Recording file not found: ${file.path}');
    }

    final request = http.MultipartRequest('POST', Uri.parse(_endpoint))
      ..headers['xi-api-key'] = ElevenLabsConfig.apiKey
      ..fields['model_id'] = ElevenLabsConfig.sttModelId
      ..fields['language_code'] = 'ja'
      ..fields['tag_audio_events'] = 'false'
      ..fields['diarize'] = 'false'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await _client.send(request).timeout(
      const Duration(seconds: 30),
    );
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception(
        'ElevenLabs STT failed (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final text = (decoded is Map && decoded['text'] is String)
        ? (decoded['text'] as String).trim()
        : '';
    if (kDebugMode) debugPrint('Scribe transcript: "$text"');
    return text;
  }
}
