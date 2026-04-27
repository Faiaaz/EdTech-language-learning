import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechGameScreen extends StatefulWidget {
  const SpeechGameScreen({super.key});

  @override
  State<SpeechGameScreen> createState() => _SpeechGameScreenState();
}

class _SpeechGameScreenState extends State<SpeechGameScreen> {
  // Lesson 1 only.
  static const _items = <_SpeechPrompt>[
    _SpeechPrompt(japanese: 'あ', romaji: 'a', english: 'a'),
    _SpeechPrompt(japanese: 'い', romaji: 'i', english: 'i'),
    _SpeechPrompt(japanese: 'う', romaji: 'u', english: 'u'),
    _SpeechPrompt(japanese: 'え', romaji: 'e', english: 'e'),
    _SpeechPrompt(japanese: 'お', romaji: 'o', english: 'o'),
    _SpeechPrompt(japanese: 'か', romaji: 'ka', english: 'ka'),
    _SpeechPrompt(japanese: 'き', romaji: 'ki', english: 'ki'),
    _SpeechPrompt(japanese: 'く', romaji: 'ku', english: 'ku'),
    _SpeechPrompt(japanese: 'け', romaji: 'ke', english: 'ke'),
    _SpeechPrompt(japanese: 'こ', romaji: 'ko', english: 'ko'),
    _SpeechPrompt(japanese: 'さ', romaji: 'sa', english: 'sa'),
    _SpeechPrompt(japanese: 'し', romaji: 'shi', english: 'shi'),
    _SpeechPrompt(japanese: 'す', romaji: 'su', english: 'su'),
    _SpeechPrompt(japanese: 'せ', romaji: 'se', english: 'se'),
    _SpeechPrompt(japanese: 'そ', romaji: 'so', english: 'so'),
    _SpeechPrompt(
      japanese: 'あさ',
      romaji: 'asa',
      english: 'morning',
      asset: 'assets/images/vocab_asa.png',
    ),
    _SpeechPrompt(
      japanese: 'いえ',
      romaji: 'ie',
      english: 'house',
      asset: 'assets/images/vocab_ie.png',
    ),
    _SpeechPrompt(
      japanese: 'すし',
      romaji: 'sushi',
      english: 'sushi',
      asset: 'assets/images/vocab_sushi.png',
    ),
  ];

  final _rng = math.Random();
  late List<_SpeechPrompt> _deck;
  int _i = 0;

  final _stt = SpeechToText();
  bool _sttReady = false;
  String? _sttLocaleId;
  bool _listening = false;
  Duration _recorded = Duration.zero;
  Timer? _recTimer;
  static const _maxLen = Duration(seconds: 10);
  String _recognized = '';
  double _confidence = 0.0;
  _Judge? _judge;

  final _tts = FlutterTts();
  bool _ttsReady = false;
  String? _error;

  _SpeechPrompt get _prompt => _deck[_i];

  @override
  void initState() {
    super.initState();
    _deck = List.of(_items)..shuffle(_rng);
    // ignore: discarded_futures
    _initTts();
    // ignore: discarded_futures
    _initStt();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.46);
      await _tts.setPitch(1.05);
      await _tts.setVolume(1.0);
      if (!mounted) return;
      setState(() => _ttsReady = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _ttsReady = false);
    }
  }

  Future<void> _initStt() async {
    try {
      final ok = await _stt.initialize(
        onError: (e) {
          if (!mounted) return;
          setState(() => _error = e.errorMsg);
        },
        onStatus: (_) {},
      );
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _sttReady = false;
          _sttLocaleId = null;
        });
        return;
      }
      final locales = await _stt.locales();
      // Prefer Japanese locale if available.
      final ja = locales.where((l) => l.localeId.toLowerCase().startsWith('ja'));
      _sttLocaleId = ja.isNotEmpty ? ja.first.localeId : (locales.isNotEmpty ? locales.first.localeId : null);
      setState(() => _sttReady = true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sttReady = false;
        _sttLocaleId = null;
      });
    }
  }

  @override
  void dispose() {
    _recTimer?.cancel();
    // ignore: discarded_futures
    _stt.stop();
    // ignore: discarded_futures
    _tts.stop();
    super.dispose();
  }

  void _tickTimer() {
    _recTimer?.cancel();
    _recTimer = Timer.periodic(const Duration(milliseconds: 120), (_) async {
      if (!mounted || !_listening) return;

      setState(() => _recorded += const Duration(milliseconds: 120));
      if (_recorded >= _maxLen) await _stopListening();
    });
  }

  Future<void> _startListening() async {
    if (_listening) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _error = null;
      _judge = null;
      _recognized = '';
      _confidence = 0;
    });
    try {
      if (!_sttReady) {
        throw Exception('Speech recognition not available on this device.');
      }
      _recorded = Duration.zero;
      await _stt.listen(
        localeId: _sttLocaleId,
        listenMode: ListenMode.confirmation,
        partialResults: true,
        cancelOnError: true,
        onResult: _onSttResult,
      );

      if (!mounted) return;
      setState(() {
        _listening = true;
      });
      _tickTimer();
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.lightImpact();
      setState(() {
        _error = e.toString();
        _listening = false;
      });
    }
  }

  void _onSttResult(SpeechRecognitionResult r) {
    if (!mounted) return;
    setState(() {
      _recognized = r.recognizedWords;
      _confidence = r.confidence;
    });
  }

  Future<void> _stopListening() async {
    if (!_listening) return;
    HapticFeedback.selectionClick();
    _recTimer?.cancel();
    setState(() {
      _listening = false;
      _error = null;
    });
    try {
      await _stt.stop();
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      setState(() => _judge = _evaluate(_recognized));
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.lightImpact();
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _playModel() async {
    if (!_ttsReady) {
      HapticFeedback.lightImpact();
      setState(() => _error = 'TTS not available on this device.');
      return;
    }
    HapticFeedback.selectionClick();
    try {
      await _tts.stop();
      await _tts.speak(_prompt.japanese);
    } catch (e) {
      setState(() => _error = 'TTS error: $e');
    }
  }

  void _nextPrompt() {
    HapticFeedback.selectionClick();
    setState(() {
      _error = null;
      _judge = null;
      _recognized = '';
      _confidence = 0;
      _recorded = Duration.zero;
      if (_i >= _deck.length - 1) {
        _deck = List.of(_items)..shuffle(_rng);
        _i = 0;
      } else {
        _i++;
      }
    });
  }

  static const _bgTop = Color(0xFF0B1220);
  static const _bgBottom = Color(0xFF1C3A8A);
  static const _card = Color(0xFF0F172A);
  static const _accent = Color(0xFFFFD86B);

  _Judge _evaluate(String raw) {
    final r = _normalize(raw);
    final wantKana = _normalize(_prompt.japanese);
    final wantRomaji = _normalize(_prompt.romaji);
    if (r.isEmpty) return _Judge.wrong;
    // Prefer kana match. If STT returns romaji/latin, accept romaji too.
    if (r.contains(wantKana) || r == wantKana) return _Judge.correct;
    if (r.contains(wantRomaji) || r == wantRomaji) return _Judge.correct;
    return _Judge.wrong;
  }

  String _normalize(String s) {
    final lower = s.toLowerCase();
    final buf = StringBuffer();
    for (final rune in lower.runes) {
      final ch = String.fromCharCode(rune);
      // Keep hiragana/katakana/kanji + ascii letters/numbers.
      final isAsciiAlphaNum = rune >= 0x30 && rune <= 0x39 || rune >= 0x61 && rune <= 0x7A;
      final isJapanese = (rune >= 0x3040 && rune <= 0x30FF) || (rune >= 0x4E00 && rune <= 0x9FFF);
      if (isAsciiAlphaNum || isJapanese) buf.write(ch);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Speech (Lesson 1)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    _Pill(
                      icon: Icons.filter_1_rounded,
                      text: '${_i + 1}/${_deck.length}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: _SimplePromptCard(prompt: _prompt),
                    ),
                  ),
                ),
                if (_judge != null) ...[
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: _JudgeBanner(
                      judge: _judge!,
                      recognized: _recognized,
                      confidence: _confidence,
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  _ErrorCard(text: _error!),
                ],
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _card.withValues(alpha: 0.80),
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _listening ? null : _playModel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: const Color(0xFF0B1220),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.volume_up_rounded, size: 18),
                            label: const Text('Hear',
                                style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (_listening) {
                                await _stopListening();
                              } else {
                                await _startListening();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _listening
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: Icon(
                              _listening ? Icons.stop_rounded : Icons.mic_rounded,
                              size: 18,
                            ),
                            label: Text(
                              _listening ? 'Stop' : 'Speak',
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _listening ? null : _nextPrompt,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.20)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.skip_next_rounded, size: 18),
                            label: const Text('Next',
                                style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _listening
                      ? 'Recording… (${_fmt(_recorded)}/${_fmt(_maxLen)})'
                      : 'Hear → Record → Next',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final s = d.inSeconds;
    final mm = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

enum _Judge { correct, wrong }

class _SpeechPrompt {
  const _SpeechPrompt({
    required this.japanese,
    required this.romaji,
    required this.english,
    this.asset,
  });

  final String japanese;
  final String romaji;
  final String english;
  final String? asset;
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimplePromptCard extends StatelessWidget {
  const _SimplePromptCard({required this.prompt});
  final _SpeechPrompt prompt;

  @override
  Widget build(BuildContext context) {
    final isWord = prompt.asset != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isWord) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(prompt.asset!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            prompt.japanese,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFD86B),
              fontSize: 64,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${prompt.romaji} • ${prompt.english}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _JudgeBanner extends StatelessWidget {
  const _JudgeBanner({
    required this.judge,
    required this.recognized,
    required this.confidence,
  });

  final _Judge judge;
  final String recognized;
  final double confidence;

  @override
  Widget build(BuildContext context) {
    final ok = judge == _Judge.correct;
    final bg = ok
        ? const Color(0xFF22C55E).withValues(alpha: 0.14)
        : const Color(0xFFEF4444).withValues(alpha: 0.14);
    final border = ok ? const Color(0xFF86EFAC) : const Color(0xFFFFB4B4);
    final title = ok ? 'Correct' : 'Try again';
    final said = recognized.trim().isEmpty ? '—' : recognized.trim();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Heard: $said',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Confidence: ${(confidence * 100).round()}%',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

