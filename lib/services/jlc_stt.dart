import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:ez_trainz/config/elevenlabs_config.dart';
import 'package:ez_trainz/services/elevenlabs_stt_service.dart';

/// Listening mode shim — kept so existing call sites that passed
/// `listenMode: ListenMode.confirmation` compile unchanged. The value is
/// ignored by the ElevenLabs backend.
enum ListenMode { deviceDefault, dictation, search, confirmation }

/// Result delivered to `onResult`, shaped like the old
/// `SpeechRecognitionResult` (recognizedWords / confidence / finalResult).
class JlcSttResult {
  const JlcSttResult(this.recognizedWords, this.confidence, this.finalResult);

  final String recognizedWords;

  /// Scribe's weakest per-word acoustic probability (0..1). Low values mean
  /// the transcript may be a language-model auto-correction of what was
  /// actually said — treat "perfect" matches sceptically.
  final double confidence;
  final bool finalResult;
}

/// Drop-in replacement for `SpeechToText` on the speaking games.
///
/// Records the microphone to a temp file, then transcribes it with ElevenLabs
/// Scribe. There are no live partial results — `onResult` fires once, after
/// [stop] finishes uploading. While the upload is in flight, [isProcessing]
/// is true so screens can show a "checking…" state.
class JlcStt {
  final AudioRecorder _recorder = AudioRecorder();

  void Function(JlcSttResult)? _onResult;
  String? _path;
  bool _recording = false;
  bool _processing = false;

  /// True once the API key is configured and mic permission is granted.
  bool get isAvailable => ElevenLabsConfig.isConfigured;

  /// True while a recording is being uploaded/transcribed.
  bool get isProcessing => _processing;

  /// True while the mic is actively capturing.
  bool get isListening => _recording;

  /// Mirrors `SpeechToText.initialize`. Returns false if STT can't be used.
  Future<bool> initialize({
    Function(dynamic error)? onError,
    Function(dynamic status)? onStatus,
  }) async {
    if (!ElevenLabsConfig.isConfigured) return false;
    try {
      final ok = await _recorder.hasPermission();
      if (ok) {
        // Do not block UI; just warm networking in the background.
        unawaited(ElevenLabsSttService.instance.prewarm());
      }
      return ok;
    } catch (e) {
      onError?.call(e);
      return false;
    }
  }

  /// Mirrors `SpeechToText.locales`. Not used by Scribe (language is fixed to
  /// Japanese), so returns empty.
  Future<List<dynamic>> locales() async => const <dynamic>[];

  /// Begins recording. [onResult] is invoked once from [stop].
  Future<void> listen({
    String? localeId,
    ListenMode? listenMode,
    bool partialResults = false,
    bool cancelOnError = false,
    Duration? listenFor,
    Duration? pauseFor,
    void Function(double level)? onSoundLevelChange,
    void Function(JlcSttResult)? onResult,
  }) async {
    if (_recording) return;
    _onResult = onResult;

    final dir = await getTemporaryDirectory();
    _path =
        '${dir.path}/jlc_stt_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 16000,
        numChannels: 1,
        // Smaller upload for quicker STT round-trips.
        bitRate: 24000,
      ),
      path: _path!,
    );
    _recording = true;
  }

  /// Stops recording, uploads to ElevenLabs, and emits the transcript via
  /// the `onResult` handler registered in [listen]. Awaiting this future
  /// guarantees the result has been delivered.
  Future<void> stop() async {
    if (!_recording) return;
    _recording = false;
    _processing = true;

    String? file;
    try {
      file = await _recorder.stop();
    } catch (e) {
      debugPrint('JlcStt: recorder.stop failed: $e');
    }
    file ??= _path;

    if (file == null) {
      _processing = false;
      _onResult?.call(const JlcSttResult('', 0, true));
      return;
    }

    try {
      final result =
          await ElevenLabsSttService.instance.transcribe(File(file));
      _onResult?.call(JlcSttResult(
        result.text,
        result.text.isEmpty ? 0 : result.minWordProbability,
        true,
      ));
    } catch (e) {
      debugPrint('JlcStt: transcription failed: $e');
      _onResult?.call(const JlcSttResult('', 0, true));
    } finally {
      _processing = false;
      try {
        await File(file).delete();
      } catch (_) {}
    }
  }

  /// Discards the in-progress recording without transcribing.
  Future<void> cancel() async {
    _recording = false;
    _processing = false;
    try {
      await _recorder.cancel();
    } catch (_) {}
  }
}
