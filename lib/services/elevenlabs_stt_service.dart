import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:ez_trainz/config/elevenlabs_config.dart';

/// One transcribed token with Scribe's acoustic confidence for it.
class SttWord {
  const SttWord(this.text, this.probability);

  final String text;

  /// exp(logprob) — 0..1. 1.0 when the API returned no logprob.
  final double probability;
}

/// Transcript plus per-word confidence.
///
/// STT language models "snap" mispronounced speech to the nearest real
/// phrase (こんにちぱ → こんにちは), so the text alone can hide errors.
/// The per-word probability is the tell: a snapped word has weak acoustic
/// support and a visibly lower probability.
class SttTranscription {
  const SttTranscription(this.text, this.words);

  final String text;
  final List<SttWord> words;

  /// Weakest word in the utterance (1.0 when no word data).
  double get minWordProbability => words.isEmpty
      ? 1.0
      : words.map((w) => w.probability).reduce((a, b) => a < b ? a : b);
}

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

  /// Uploads [file] and returns the recognised text with per-word confidence
  /// (empty text if nothing recognised).
  Future<SttTranscription> transcribe(File file) async {
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
      // Deterministic decoding so the same clip always scores the same.
      ..fields['temperature'] = '0'
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
    if (decoded is! Map) return const SttTranscription('', []);

    final text =
        decoded['text'] is String ? (decoded['text'] as String).trim() : '';

    final words = <SttWord>[];
    final rawWords = decoded['words'];
    if (rawWords is List) {
      for (final w in rawWords) {
        if (w is! Map || w['type'] != 'word') continue;
        final wText = w['text'];
        if (wText is! String || wText.trim().isEmpty) continue;
        final logprob = w['logprob'];
        final prob = logprob is num
            ? math.exp(logprob.toDouble()).clamp(0.0, 1.0)
            : 1.0;
        words.add(SttWord(wText, prob));
      }
    }

    if (kDebugMode) {
      debugPrint('Scribe transcript: "$text" '
          '(words: ${words.map((w) => '${w.text}:${w.probability.toStringAsFixed(2)}').join(' ')})');
    }
    return SttTranscription(text, words);
  }
}
