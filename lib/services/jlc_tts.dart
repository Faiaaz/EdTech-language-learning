import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:ez_trainz/services/elevenlabs_tts_service.dart';

/// Drop-in replacement for [FlutterTts] on JLC screens.
/// Uses ElevenLabs Japanese voices when configured; falls back to device TTS.
class JlcTts {
  JlcTts({String? elevenLabsVoiceId})
      : _fallback = FlutterTts(),
        _elevenLabsVoiceId = elevenLabsVoiceId?.trim() {
    if (_useElevenLabs) {
      unawaited(ElevenLabsTtsService.instance.prewarm());
      _prefetchCommonPackOnce();
    }
  }

  final FlutterTts _fallback;
  final String? _elevenLabsVoiceId;
  bool _awaitCompletion = false;
  double _speechRate = 0.5;
  VoidCallback? _startHandler;
  VoidCallback? _completionHandler;
  static bool _commonPackPrefetched = false;

  static const List<String> _commonJapanesePack = <String>[
    'あ',
    'い',
    'う',
    'え',
    'お',
    'か',
    'き',
    'く',
    'け',
    'こ',
    'さ',
    'し',
    'す',
    'せ',
    'そ',
    'た',
    'ち',
    'つ',
    'て',
    'と',
    'な',
    'に',
    'ぬ',
    'ね',
    'の',
    'は',
    'ひ',
    'ふ',
    'へ',
    'ほ',
    'ま',
    'み',
    'む',
    'め',
    'も',
    'や',
    'ゆ',
    'よ',
    'ら',
    'り',
    'る',
    'れ',
    'ろ',
    'わ',
    'を',
    'ん',
    'おはよう',
    'こんにちは',
    'こんばんは',
    'さようなら',
    'ありがとう',
    'すみません',
    'いえ',
    'はい',
    'いち',
    'に',
    'さん',
    'よん',
    'ご',
    'ろく',
    'なな',
    'はち',
    'きゅう',
    'じゅう',
    'げつようび',
    'かようび',
    'すいようび',
    'もくようび',
    'きんようび',
    'どようび',
    'にちようび',
  ];

  static bool get _useElevenLabs => ElevenLabsTtsService.instance.isAvailable;

  void _onStart() => _startHandler?.call();
  void _onComplete() => _completionHandler?.call();

  void _prefetchCommonPackOnce() {
    if (_commonPackPrefetched) return;
    _commonPackPrefetched = true;
    unawaited(
      ElevenLabsTtsService.instance.prefetchTexts(
        _commonJapanesePack.expand((t) => <String>[t, '$t。']),
        voiceId: _elevenLabsVoiceId,
      ),
    );
  }

  Future<void> prefetchTexts(Iterable<String> texts) async {
    if (!_useElevenLabs) return;
    await ElevenLabsTtsService.instance.prefetchTexts(
      texts,
      voiceId: _elevenLabsVoiceId,
    );
  }

  Future<void> setLanguage(String language) async {
    if (!_useElevenLabs) await _fallback.setLanguage(language);
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    if (!_useElevenLabs) await _fallback.setSpeechRate(rate);
  }

  Future<void> setPitch(double pitch) async {
    if (!_useElevenLabs) await _fallback.setPitch(pitch);
  }

  Future<void> setVolume(double volume) async {
    if (!_useElevenLabs) await _fallback.setVolume(volume);
  }

  Future<void> setEngine(String engine) async {
    if (!_useElevenLabs) {
      try {
        await _fallback.setEngine(engine);
      } catch (_) {}
    }
  }

  Future<void> awaitSpeakCompletion(bool enabled) async {
    _awaitCompletion = enabled;
    if (!_useElevenLabs) await _fallback.awaitSpeakCompletion(enabled);
  }

  Future<dynamic> get getVoices async {
    if (_useElevenLabs) return const <dynamic>[];
    return _fallback.getVoices;
  }

  Future<void> setVoice(Map<String, String> voice) async {
    if (!_useElevenLabs) await _fallback.setVoice(voice);
  }

  void setStartHandler(VoidCallback? handler) {
    _startHandler = handler;
    if (!_useElevenLabs && handler != null) {
      _fallback.setStartHandler(handler);
    }
  }

  void setCompletionHandler(VoidCallback? handler) {
    _completionHandler = handler;
    if (!_useElevenLabs && handler != null) {
      _fallback.setCompletionHandler(handler);
    }
  }

  Future<void> stop() async {
    if (_useElevenLabs) {
      await ElevenLabsTtsService.instance.stop();
    } else {
      await _fallback.stop();
    }
  }

  Future<void> speak(String text) async {
    if (_useElevenLabs) {
      try {
        ElevenLabsTtsService.instance.setStartHandler(_onStart);
        ElevenLabsTtsService.instance.setCompletionHandler(_onComplete);
        await ElevenLabsTtsService.instance.speak(
          text,
          playbackRate: _speechRateToPlayback(_speechRate),
          voiceId: _elevenLabsVoiceId,
        );
        return;
      } catch (e) {
        debugPrint('ElevenLabs TTS failed, using device voice: $e');
      }
    }

    if (_awaitCompletion) {
      await _fallback.speak(text);
    } else {
      await _fallback.speak(text);
    }
  }

  /// Maps FlutterTts speech rate (0.28–0.55) to ElevenLabs playback speed.
  double _speechRateToPlayback(double speechRate) {
    return (speechRate / 0.52).clamp(0.55, 1.15);
  }
}
