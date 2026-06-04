import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:ez_trainz/config/elevenlabs_config.dart';

/// Calls [ElevenLabs text-to-speech](https://elevenlabs.io/docs/api-reference/text-to-speech/convert)
/// for natural Japanese audio in JLC lessons and games.
class ElevenLabsTtsService {
  ElevenLabsTtsService._();
  static final ElevenLabsTtsService instance = ElevenLabsTtsService._();

  final AudioPlayer _player = AudioPlayer();
  final http.Client _client = http.Client();
  final Map<String, Uint8List> _webCache = {};
  final Map<String, Future<Uint8List>> _inFlight = {};
  final Map<String, Future<String>> _inFlightFiles = {};
  bool _prewarmed = false;

  VoidCallback? _onStart;
  VoidCallback? _onComplete;

  bool get isAvailable => ElevenLabsConfig.isConfigured;

  void setStartHandler(VoidCallback? handler) => _onStart = handler;
  void setCompletionHandler(VoidCallback? handler) => _onComplete = handler;

  Future<void> prefetchTexts(
    Iterable<String> texts, {
    String? voiceId,
  }) async {
    if (!isAvailable) return;
    for (final raw in texts) {
      final text = raw.trim();
      if (text.isEmpty) continue;
      try {
        if (kIsWeb) {
          await _fetchAudio(text, voiceId: voiceId);
        } else {
          await _ensureLocalFile(text, voiceId: voiceId);
        }
      } catch (_) {
        // Ignore per-item failures during background prefetch.
      }
    }
  }

  /// Best-effort warmup to reduce "first tap" latency.
  Future<void> prewarm() async {
    if (!isAvailable || _prewarmed) return;
    _prewarmed = true;
    try {
      await getTemporaryDirectory();
      final uri = Uri.parse(
        'https://api.elevenlabs.io/v1/voices/${ElevenLabsConfig.voiceId}',
      );
      await _client.get(
        uri,
        headers: {'xi-api-key': ElevenLabsConfig.apiKey},
      ).timeout(const Duration(seconds: 4));
    } catch (_) {
      // Warmup is optional; failures should never affect gameplay.
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> speak(
    String text, {
    double playbackRate = 1.0,
    String? voiceId,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || !isAvailable) {
      throw StateError('ElevenLabs TTS unavailable or empty text');
    }

    await _player.stop();
    await _player.setPlaybackRate(playbackRate.clamp(0.5, 1.25));
    _onStart?.call();
    await _player.play(await _sourceForText(trimmed, voiceId: voiceId));
    await _player.onPlayerComplete.first;
    _onComplete?.call();
  }

  /// iOS AVPlayer needs a real `.mp3` file; in-memory bytes fail on device.
  Future<Source> _sourceForText(
    String text, {
    String? voiceId,
  }) async {
    if (kIsWeb) return BytesSource(await _fetchAudio(text, voiceId: voiceId));

    final path = await _ensureLocalFile(text, voiceId: voiceId);
    return DeviceFileSource(path, mimeType: 'audio/mpeg');
  }

  Future<String> _ensureLocalFile(
    String text, {
    String? voiceId,
  }) async {
    final key = _cacheKey(text, voiceId: voiceId);
    final path = await _cachedPath(text, voiceId: voiceId);
    if (File(path).existsSync()) return path;

    final inFlight = _inFlightFiles[key];
    if (inFlight != null) return inFlight;

    final future = () async {
      final bytes = await _fetchAudio(text, voiceId: voiceId);
      await File(path).writeAsBytes(bytes, flush: true);
      return path;
    }();
    _inFlightFiles[key] = future;
    try {
      return await future;
    } finally {
      _inFlightFiles.remove(key);
    }
  }

  Future<String> _cachedPath(
    String text, {
    String? voiceId,
  }) async {
    final dir = await getTemporaryDirectory();
    final resolvedVoiceId = _resolveVoiceId(voiceId);
    final key = _stableHash(
      '$text|$resolvedVoiceId|${ElevenLabsConfig.modelId}|${ElevenLabsConfig.outputFormat}',
    );
    return '${dir.path}/el_$key.mp3';
  }

  String _stableHash(String input) {
    // 32-bit FNV-1a. Kept to 32 bits and multiplied in 16-bit halves so it
    // stays inside JavaScript's 53-bit safe-integer range (web builds).
    var hash = 0x811c9dc5;
    for (final b in utf8.encode(input)) {
      hash ^= b;
      final lo = (hash & 0xFFFF) * 0x01000193;
      final hi = ((hash >> 16) & 0xFFFF) * 0x01000193;
      hash = (lo + ((hi & 0xFFFF) << 16)) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }

  Future<Uint8List> _fetchAudio(
    String text, {
    String? voiceId,
  }) async {
    final key = _cacheKey(text, voiceId: voiceId);
    final cached = _webCache[key];
    if (cached != null) return cached;
    final inFlight = _inFlight[key];
    if (inFlight != null) return inFlight;

    final future = _fetchAudioRemote(text, voiceId: voiceId);
    _inFlight[key] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(key);
    }
  }

  Future<Uint8List> _fetchAudioRemote(
    String text, {
    String? voiceId,
  }) async {
    final resolvedVoiceId = _resolveVoiceId(voiceId);
    final uri = Uri.parse(
      'https://api.elevenlabs.io/v1/text-to-speech/$resolvedVoiceId',
    ).replace(queryParameters: {
      'output_format': ElevenLabsConfig.outputFormat,
      // Higher values optimize for lower latency.
      'optimize_streaming_latency': '4',
    });

    final response = await _client
        .post(
      uri,
      headers: {
        'xi-api-key': ElevenLabsConfig.apiKey,
        'Content-Type': 'application/json',
        'Accept': 'audio/mpeg',
      },
      body: jsonEncode({
        'text': text,
        'model_id': ElevenLabsConfig.modelId,
        'language_code': 'ja',
        'apply_language_text_normalization': true,
        'voice_settings': {
          'stability': 0.42,
          'similarity_boost': 0.78,
          'style': 0.15,
          'use_speaker_boost': true,
        },
      }),
    )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception(
        'ElevenLabs TTS failed (${response.statusCode}): ${response.body}',
      );
    }

    final bytes = response.bodyBytes;
    _webCache[_cacheKey(text, voiceId: voiceId)] = bytes;
    return bytes;
  }

  String _resolveVoiceId(String? overrideVoiceId) {
    final trimmed = overrideVoiceId?.trim() ?? '';
    if (trimmed.isNotEmpty) return trimmed;
    return ElevenLabsConfig.voiceId;
  }

  String _cacheKey(
    String text, {
    String? voiceId,
  }) {
    final resolvedVoiceId = _resolveVoiceId(voiceId);
    return '$text|$resolvedVoiceId';
  }

  void dispose() {
    _player.dispose();
    _client.close();
  }
}
