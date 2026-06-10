import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/journey_controller.dart';
import 'package:ez_trainz/models/xp_event.dart';
import 'package:ez_trainz/services/jlc_stt.dart';
import 'package:ez_trainz/services/jlc_tts.dart';
import 'package:ez_trainz/utils/app_theme.dart';
import 'package:ez_trainz/widgets/game_fx.dart';

/// AI উচ্চারণ কোচ — shadowing game.
///
/// Plays a native model phrase (ElevenLabs TTS), records the learner,
/// transcribes with Scribe (ElevenLabs STT), then aligns the heard morae
/// against the target morae and colours each mora green / amber / red.
class PronunciationCoachScreen extends StatefulWidget {
  const PronunciationCoachScreen({super.key});

  @override
  State<PronunciationCoachScreen> createState() =>
      _PronunciationCoachScreenState();
}

enum _Phase { idle, recording, analyzing, scored }

class _PronunciationCoachScreenState extends State<PronunciationCoachScreen>
    with SingleTickerProviderStateMixin {
  static const _phrases = <_CoachPhrase>[
    _CoachPhrase(kana: 'おはよう', pron: 'ওহায়ো', bengali: 'সুপ্রভাত'),
    _CoachPhrase(
        kana: 'こんにちは',
        pron: 'কোন্‌নিচিওয়া',
        bengali: 'হ্যালো / শুভ দুপুর',
        pronOverrides: {4: 'ওয়া'}),
    _CoachPhrase(kana: 'ありがとう', pron: 'আরিগাতো', bengali: 'ধন্যবাদ'),
    _CoachPhrase(
        kana: 'すみません', pron: 'সুমিমাসেন', bengali: 'মাফ করবেন / শুনুন'),
    _CoachPhrase(
        kana: 'こんばんは',
        pron: 'কোনবানওয়া',
        bengali: 'শুভ সন্ধ্যা',
        pronOverrides: {4: 'ওয়া'}),
    _CoachPhrase(kana: 'さようなら', pron: 'সায়োনারা', bengali: 'বিদায়'),
    _CoachPhrase(
        kana: 'おはようございます',
        pron: 'ওহায়ো গোজাইমাস',
        bengali: 'সুপ্রভাত (সম্মানসূচক)'),
    _CoachPhrase(
        kana: 'ありがとうございます',
        pron: 'আরিগাতো গোজাইমাস',
        bengali: 'অনেক ধন্যবাদ'),
    _CoachPhrase(
        kana: 'わたしはがくせいです',
        pron: 'ওয়াতাশি ওয়া গাকুসেই দেস',
        bengali: 'আমি ছাত্র/ছাত্রী',
        pronOverrides: {3: 'ওয়া'}),
    _CoachPhrase(
        kana: 'あのひとはせんせいです',
        pron: 'আনো হিতো ওয়া সেনসেই দেস',
        bengali: 'ওই ব্যক্তি একজন শিক্ষক',
        pronOverrides: {4: 'ওয়া'}),
  ];

  final _tts = JlcTts();
  final _stt = JlcStt();
  final _fx = GameFx();

  late final AnimationController _pulse;

  _Phase _phase = _Phase.idle;
  int _index = 0;
  bool _sttReady = false;
  String? _error;

  String _heard = '';
  List<_MoraResult> _moraResults = const [];
  int _score = 0;
  final List<int> _bestScores = List.filled(_phrases.length, -1);
  bool _sessionDone = false;
  bool _xpGranted = false;
  int _xpEarned = 0;

  Duration _recorded = Duration.zero;
  Timer? _recTimer;
  static const _maxLen = Duration(seconds: 8);

  _CoachPhrase get _phrase => _phrases[_index];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 0.92,
      upperBound: 1.08,
    );
    // ignore: discarded_futures
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.46);
      await _tts.setPitch(1.05);
      await _tts.setVolume(1.0);
      unawaited(_tts.prefetchTexts(_phrases.map((p) => p.kana)));
    } catch (_) {}
    try {
      final ok = await _stt.initialize(
        onError: (e) {
          if (!mounted) return;
          setState(() => _error = '$e');
        },
      );
      if (!mounted) return;
      setState(() => _sttReady = ok);
    } catch (_) {
      if (!mounted) return;
      setState(() => _sttReady = false);
    }
  }

  @override
  void dispose() {
    _recTimer?.cancel();
    _pulse.dispose();
    // ignore: discarded_futures
    _stt.cancel();
    // ignore: discarded_futures
    _tts.stop();
    _fx.dispose();
    super.dispose();
  }

  // ── Playback ──────────────────────────────────────────────────────
  Future<void> _playModel({bool slow = false}) async {
    unawaited(_fx.tap());
    HapticFeedback.selectionClick();
    try {
      await _tts.stop();
      await _tts.setSpeechRate(slow ? 0.30 : 0.46);
      await _tts.speak(_phrase.kana);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'TTS error: $e');
    }
  }

  // ── Recording ─────────────────────────────────────────────────────
  Future<void> _toggleMic() async {
    switch (_phase) {
      case _Phase.recording:
        await _stopAndScore();
      case _Phase.idle || _Phase.scored:
        await _startRecording();
      case _Phase.analyzing:
        break;
    }
  }

  Future<void> _startRecording() async {
    if (!_sttReady) {
      unawaited(_fx.error());
      setState(() =>
          _error = 'এই ডিভাইসে স্পিচ সুবিধা চালু নেই (মাইক/ইন্টারনেট দেখুন)।');
      return;
    }
    unawaited(_fx.tap());
    HapticFeedback.mediumImpact();
    await _tts.stop();
    setState(() {
      _error = null;
      _heard = '';
      _moraResults = const [];
      _phase = _Phase.recording;
      _recorded = Duration.zero;
    });
    _pulse.repeat(reverse: true);
    try {
      await _stt.listen(onResult: (r) => _heard = r.recognizedWords);
      _recTimer?.cancel();
      _recTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
        if (!mounted || _phase != _Phase.recording) return;
        setState(() => _recorded += const Duration(milliseconds: 100));
        if (_recorded >= _maxLen) await _stopAndScore();
      });
    } catch (e) {
      _pulse.stop();
      if (!mounted) return;
      unawaited(_fx.error());
      setState(() {
        _phase = _Phase.idle;
        _error = '$e';
      });
    }
  }

  Future<void> _stopAndScore() async {
    if (_phase != _Phase.recording) return;
    _recTimer?.cancel();
    _pulse
      ..stop()
      ..value = 1.0;
    HapticFeedback.selectionClick();
    setState(() => _phase = _Phase.analyzing);
    try {
      await _stt.stop(); // awaits upload + transcription; fills _heard
      if (!mounted) return;
      final eval = _PronunciationScorer.evaluate(_phrase, _heard);
      final isBest = eval.score > _bestScores[_index];
      setState(() {
        _moraResults = eval.morae;
        _score = eval.score;
        if (isBest) _bestScores[_index] = eval.score;
        _phase = _Phase.scored;
      });
      HapticFeedback.mediumImpact();
      unawaited(_score >= 85
          ? _fx.combo()
          : _score >= 60
              ? _fx.success()
              : _fx.error());
    } catch (e) {
      if (!mounted) return;
      unawaited(_fx.error());
      setState(() {
        _phase = _Phase.idle;
        _error = '$e';
      });
    }
  }

  // ── Flow ──────────────────────────────────────────────────────────
  Future<void> _next() async {
    unawaited(_fx.tap());
    HapticFeedback.selectionClick();
    await _tts.stop();
    if (_index >= _phrases.length - 1) {
      await _finishSession();
      return;
    }
    setState(() {
      _index++;
      _phase = _Phase.idle;
      _heard = '';
      _moraResults = const [];
      _error = null;
    });
  }

  Future<void> _finishSession() async {
    final scored = _bestScores.where((s) => s >= 0).toList();
    final avg = scored.isEmpty
        ? 0
        : (scored.reduce((a, b) => a + b) / scored.length).round();
    if (!_xpGranted) {
      _xpGranted = true;
      _xpEarned = 25 + avg;
      try {
        await JourneyController.to.grantXp(
          source: XpSource.game,
          amount: _xpEarned,
          note: 'উচ্চারণ কোচ',
        );
      } catch (_) {}
    }
    if (!mounted) return;
    unawaited(avg >= 60 ? _fx.success() : _fx.tap());
    setState(() => _sessionDone = true);
  }

  void _restart() {
    unawaited(_fx.tap());
    setState(() {
      _sessionDone = false;
      _xpGranted = false;
      _xpEarned = 0;
      _index = 0;
      _phase = _Phase.idle;
      _heard = '';
      _moraResults = const [];
      _error = null;
      for (var i = 0; i < _bestScores.length; i++) {
        _bestScores[i] = -1;
      }
    });
  }

  // ── UI ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: SafeArea(
          child: _sessionDone ? _buildSummary() : _buildGame(),
        ),
      ),
    );
  }

  Widget _buildGame() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Color(0xFF1E293B)),
              ),
              const Expanded(
                child: Text(
                  'উচ্চারণ কোচ',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              _AiPill(text: '${_index + 1}/${_phrases.length}'),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (_index + (_phase == _Phase.scored ? 1 : 0)) /
                  _phrases.length,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      _PhraseCard(
                        phrase: _phrase,
                        morae: _moraResults,
                        scored: _phase == _Phase.scored,
                      ),
                      if (_phase == _Phase.scored) ...[
                        const SizedBox(height: 12),
                        _ScoreCard(score: _score, heard: _heard),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        _ErrorCard(text: _error!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _buildControls(),
          ),
          const SizedBox(height: 6),
          Text(
            switch (_phase) {
              _Phase.recording =>
                'শুনছি… ${_recorded.inSeconds}s / ${_maxLen.inSeconds}s — শেষ হলে মাইকে চাপুন',
              _Phase.analyzing => 'AI আপনার উচ্চারণ বিশ্লেষণ করছে…',
              _Phase.scored => 'আবার চেষ্টা করুন বা পরের বাক্যে যান',
              _Phase.idle => 'শুনুন → মাইকে চেপে বলুন → AI স্কোর',
            },
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    final busy = _phase == _Phase.analyzing;
    final recording = _phase == _Phase.recording;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RoundAction(
                  icon: Icons.volume_up_rounded,
                  label: 'শুনুন',
                  color: const Color(0xFFFFD86B),
                  onTap: recording || busy ? null : () => _playModel(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: ScaleTransition(
                scale: _pulse,
                child: GestureDetector(
                  onTap: busy ? null : _toggleMic,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: recording
                            ? const [Color(0xFFEF4444), Color(0xFFB91C1C)]
                            : const [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (recording
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF8B5CF6))
                              .withValues(alpha: 0.45),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: busy
                        ? const Padding(
                            padding: EdgeInsets.all(22),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Icon(
                            recording ? Icons.stop_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _phase == _Phase.scored
                ? _RoundAction(
                    icon: _index >= _phrases.length - 1
                        ? Icons.flag_rounded
                        : Icons.arrow_forward_rounded,
                    label: _index >= _phrases.length - 1 ? 'শেষ' : 'পরের',
                    color: const Color(0xFF7CFFCB),
                    onTap: _next,
                  )
                : _RoundAction(
                    icon: Icons.slow_motion_video_rounded,
                    label: 'ধীরে',
                    color: const Color(0xFF9AD0FF),
                    onTap:
                        recording || busy ? null : () => _playModel(slow: true),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final scored = _bestScores.where((s) => s >= 0).toList();
    final avg = scored.isEmpty
        ? 0
        : (scored.reduce((a, b) => a + b) / scored.length).round();
    final verdict = _verdictFor(avg);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Color(0xFF1E293B)),
              ),
              const Expanded(
                child: Text(
                  'উচ্চারণ কোচ — ফলাফল',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 24,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _ScoreRing(score: avg, size: 132),
                        const SizedBox(height: 10),
                        Text(
                          verdict,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '+$_xpEarned XP অর্জিত 🎉',
                            style: const TextStyle(
                              color: Color(0xFF6D28D9),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (var i = 0; i < _phrases.length; i++) ...[
                          _SummaryRow(
                            phrase: _phrases[i],
                            score: _bestScores[i],
                          ),
                          if (i < _phrases.length - 1)
                            const Divider(height: 14),
                        ],
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textPrimary,
                                  side: const BorderSide(
                                      color: Color(0xFF94A3B8)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                                icon: const Icon(Icons.home_rounded, size: 18),
                                label: const Text('ফিরে যান',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _restart,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B5CF6),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                                icon: const Icon(Icons.replay_rounded,
                                    size: 18),
                                label: const Text('আবার খেলুন',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _verdictFor(int score) {
    if (score >= 85) return 'অসাধারণ! একদম নেটিভের মতো! 🇯🇵';
    if (score >= 70) return 'দারুণ! খুব ভালো হয়েছে 🎉';
    if (score >= 50) return 'ভালো! আরেকটু চর্চা করলেই হবে 💪';
    return 'আবার শুনে চেষ্টা করুন 🔁';
  }
}

// ── Data ──────────────────────────────────────────────────────────────
class _CoachPhrase {
  const _CoachPhrase({
    required this.kana,
    required this.pron,
    required this.bengali,
    this.pronOverrides = const {},
  });

  final String kana;

  /// Bengali phonetic spelling of the whole phrase.
  final String pron;
  final String bengali;

  /// Mora-index → Bengali label, for particles like は pronounced "ওয়া".
  final Map<int, String> pronOverrides;
}

enum _MoraStatus { perfect, close, wrong, missing }

class _MoraResult {
  const _MoraResult(this.mora, this.label, this.status);
  final String mora;

  /// Bengali phonetic label shown under the kana.
  final String label;
  final _MoraStatus status;
}

class _Evaluation {
  const _Evaluation(this.morae, this.score);
  final List<_MoraResult> morae;
  final int score;
}

// ── Scoring engine ────────────────────────────────────────────────────
/// Mora-level pronunciation scorer.
///
/// Normalizes the STT transcript (kanji→kana for deck vocabulary,
/// katakana→hiragana, long-vowel expansion), splits both sides into morae,
/// then runs an edit-distance alignment so each target mora is judged
/// perfect / close / wrong / missing.
class _PronunciationScorer {
  static const Map<String, String> _romaji = {
    'あ': 'a', 'い': 'i', 'う': 'u', 'え': 'e', 'お': 'o',
    'か': 'ka', 'き': 'ki', 'く': 'ku', 'け': 'ke', 'こ': 'ko',
    'さ': 'sa', 'し': 'shi', 'す': 'su', 'せ': 'se', 'そ': 'so',
    'た': 'ta', 'ち': 'chi', 'つ': 'tsu', 'て': 'te', 'と': 'to',
    'な': 'na', 'に': 'ni', 'ぬ': 'nu', 'ね': 'ne', 'の': 'no',
    'は': 'ha', 'ひ': 'hi', 'ふ': 'fu', 'へ': 'he', 'ほ': 'ho',
    'ま': 'ma', 'み': 'mi', 'む': 'mu', 'め': 'me', 'も': 'mo',
    'や': 'ya', 'ゆ': 'yu', 'よ': 'yo',
    'ら': 'ra', 'り': 'ri', 'る': 'ru', 'れ': 're', 'ろ': 'ro',
    'わ': 'wa', 'を': 'wo', 'ん': 'n',
    'が': 'ga', 'ぎ': 'gi', 'ぐ': 'gu', 'げ': 'ge', 'ご': 'go',
    'ざ': 'za', 'じ': 'ji', 'ず': 'zu', 'ぜ': 'ze', 'ぞ': 'zo',
    'だ': 'da', 'ぢ': 'ji', 'づ': 'zu', 'で': 'de', 'ど': 'do',
    'ば': 'ba', 'び': 'bi', 'ぶ': 'bu', 'べ': 'be', 'ぼ': 'bo',
    'ぱ': 'pa', 'ぴ': 'pi', 'ぷ': 'pu', 'ぺ': 'pe', 'ぽ': 'po',
    'っ': 'ʔ',
    'きゃ': 'kya', 'きゅ': 'kyu', 'きょ': 'kyo',
    'しゃ': 'sha', 'しゅ': 'shu', 'しょ': 'sho',
    'ちゃ': 'cha', 'ちゅ': 'chu', 'ちょ': 'cho',
    'にゃ': 'nya', 'にゅ': 'nyu', 'にょ': 'nyo',
    'ひゃ': 'hya', 'ひゅ': 'hyu', 'ひょ': 'hyo',
    'みゃ': 'mya', 'みゅ': 'myu', 'みょ': 'myo',
    'りゃ': 'rya', 'りゅ': 'ryu', 'りょ': 'ryo',
    'ぎゃ': 'gya', 'ぎゅ': 'gyu', 'ぎょ': 'gyo',
    'じゃ': 'ja', 'じゅ': 'ju', 'じょ': 'jo',
    'びゃ': 'bya', 'びゅ': 'byu', 'びょ': 'byo',
    'ぴゃ': 'pya', 'ぴゅ': 'pyu', 'ぴょ': 'pyo',
  };

  /// Bengali phonetic label per mora, shown under each kana chip.
  static const Map<String, String> _bengali = {
    'あ': 'আ', 'い': 'ই', 'う': 'উ', 'え': 'এ', 'お': 'ও',
    'か': 'কা', 'き': 'কি', 'く': 'কু', 'け': 'কে', 'こ': 'কো',
    'さ': 'সা', 'し': 'শি', 'す': 'সু', 'せ': 'সে', 'そ': 'সো',
    'た': 'তা', 'ち': 'চি', 'つ': 'ৎসু', 'て': 'তে', 'と': 'তো',
    'な': 'না', 'に': 'নি', 'ぬ': 'নু', 'ね': 'নে', 'の': 'নো',
    'は': 'হা', 'ひ': 'হি', 'ふ': 'ফু', 'へ': 'হে', 'ほ': 'হো',
    'ま': 'মা', 'み': 'মি', 'む': 'মু', 'め': 'মে', 'も': 'মো',
    'や': 'ইয়া', 'ゆ': 'ইউ', 'よ': 'ইয়ো',
    'ら': 'রা', 'り': 'রি', 'る': 'রু', 'れ': 'রে', 'ろ': 'রো',
    'わ': 'ওয়া', 'を': 'ও', 'ん': 'ন',
    'が': 'গা', 'ぎ': 'গি', 'ぐ': 'গু', 'げ': 'গে', 'ご': 'গো',
    'ざ': 'জা', 'じ': 'জি', 'ず': 'জু', 'ぜ': 'জে', 'ぞ': 'জো',
    'だ': 'দা', 'ぢ': 'জি', 'づ': 'জু', 'で': 'দে', 'ど': 'দো',
    'ば': 'বা', 'び': 'বি', 'ぶ': 'বু', 'べ': 'বে', 'ぼ': 'বো',
    'ぱ': 'পা', 'ぴ': 'পি', 'ぷ': 'পু', 'ぺ': 'পে', 'ぽ': 'পো',
    'っ': 'ৎ',
    'きゃ': 'কিয়া', 'きゅ': 'কিউ', 'きょ': 'কিয়ো',
    'しゃ': 'শা', 'しゅ': 'শু', 'しょ': 'শো',
    'ちゃ': 'চা', 'ちゅ': 'চু', 'ちょ': 'চো',
    'にゃ': 'নিয়া', 'にゅ': 'নিউ', 'にょ': 'নিয়ো',
    'ひゃ': 'হিয়া', 'ひゅ': 'হিউ', 'ひょ': 'হিয়ো',
    'みゃ': 'মিয়া', 'みゅ': 'মিউ', 'みょ': 'মিয়ো',
    'りゃ': 'রিয়া', 'りゅ': 'রিউ', 'りょ': 'রিয়ো',
    'ぎゃ': 'গিয়া', 'ぎゅ': 'গিউ', 'ぎょ': 'গিয়ো',
    'じゃ': 'জা', 'じゅ': 'জু', 'じょ': 'জো',
    'びゃ': 'বিয়া', 'びゅ': 'বিউ', 'びょ': 'বিয়ো',
    'ぴゃ': 'পিয়া', 'ぴゅ': 'পিউ', 'ぴょ': 'পিয়ো',
  };

  /// Kanji / alternate spellings Scribe may return for deck vocabulary.
  static const Map<String, String> _kanaSpellings = {
    'お早うございます': 'おはようございます',
    'お早う': 'おはよう',
    '有り難うございます': 'ありがとうございます',
    '有難うございます': 'ありがとうございます',
    '有り難う': 'ありがとう',
    '有難う': 'ありがとう',
    '今日は': 'こんにちは',
    '今晩は': 'こんばんは',
    '済みません': 'すみません',
    '左様なら': 'さようなら',
    '私': 'わたし',
    '学生': 'がくせい',
    '先生': 'せんせい',
    'あの人': 'あのひと',
    '人': 'ひと',
  };

  static const Map<String, String> _devoiced = {
    'が': 'か', 'ぎ': 'き', 'ぐ': 'く', 'げ': 'け', 'ご': 'こ',
    'ざ': 'さ', 'じ': 'し', 'ず': 'す', 'ぜ': 'せ', 'ぞ': 'そ',
    'だ': 'た', 'ぢ': 'ち', 'づ': 'つ', 'で': 'て', 'ど': 'と',
    'ば': 'は', 'び': 'ひ', 'ぶ': 'ふ', 'べ': 'へ', 'ぼ': 'ほ',
    'ぱ': 'は', 'ぴ': 'ひ', 'ぷ': 'ふ', 'ぺ': 'へ', 'ぽ': 'ほ',
  };

  static String bengaliOf(String mora) => _bengali[mora] ?? mora;

  static _Evaluation evaluate(_CoachPhrase phrase, String transcript) {
    final target = segmentMorae(phrase.kana);
    final said = segmentMorae(normalize(transcript));

    final statuses = _align(target, said);
    final morae = <_MoraResult>[
      for (var i = 0; i < target.length; i++)
        _MoraResult(
          target[i],
          phrase.pronOverrides[i] ?? bengaliOf(target[i]),
          statuses.$1[i],
        ),
    ];

    var points = 0.0;
    for (final s in statuses.$1) {
      points += switch (s) {
        _MoraStatus.perfect => 1.0,
        _MoraStatus.close => 0.5,
        _ => 0.0,
      };
    }
    points -= statuses.$2 * 0.15; // small penalty per extra mora
    final score =
        (points / target.length * 100).clamp(0, 100).round();
    return _Evaluation(morae, score);
  }

  /// Kanji→kana for known words, katakana→hiragana, strips everything that
  /// is not hiragana, and expands ー into the previous mora's vowel.
  static String normalize(String raw) {
    var s = raw;
    final spellings = _kanaSpellings.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final e in spellings) {
      s = s.replaceAll(e.key, e.value);
    }

    final buf = StringBuffer();
    for (final rune in s.runes) {
      var r = rune;
      if (r >= 0x30A1 && r <= 0x30F6) r -= 0x60; // katakana → hiragana
      if (r >= 0x3041 && r <= 0x3096) {
        buf.write(String.fromCharCode(r));
      } else if (r == 0x30FC && buf.isNotEmpty) {
        final prev = buf.toString();
        final vowel = _vowelOf(prev[prev.length - 1]);
        if (vowel != null) buf.write(vowel);
      }
    }
    return buf.toString();
  }

  static String? _vowelOf(String kana) {
    final r = _romaji[kana];
    if (r == null || r.isEmpty) return null;
    return switch (r[r.length - 1]) {
      'a' => 'あ',
      'i' => 'い',
      'u' => 'う',
      'e' => 'え',
      'o' => 'お',
      _ => null,
    };
  }

  static const _smallKana = {'ゃ', 'ゅ', 'ょ', 'ぁ', 'ぃ', 'ぅ', 'ぇ', 'ぉ', 'ゎ'};

  static List<String> segmentMorae(String hira) {
    final morae = <String>[];
    for (final rune in hira.runes) {
      final ch = String.fromCharCode(rune);
      if (_smallKana.contains(ch) && morae.isNotEmpty) {
        morae[morae.length - 1] += ch;
      } else {
        morae.add(ch);
      }
    }
    return morae;
  }

  /// Needleman–Wunsch alignment. Returns per-target-mora statuses and the
  /// number of extra (inserted) morae the learner said.
  static (List<_MoraStatus>, int) _align(
      List<String> target, List<String> said) {
    final m = target.length, n = said.length;
    const gap = 2, sub = 3, close = 1;

    final dp =
        List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
    for (var i = 1; i <= m; i++) {
      dp[i][0] = i * gap;
    }
    for (var j = 1; j <= n; j++) {
      dp[0][j] = j * gap;
    }
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        final diag = dp[i - 1][j - 1] +
            (target[i - 1] == said[j - 1]
                ? 0
                : _isClose(target[i - 1], said[j - 1])
                    ? close
                    : sub);
        dp[i][j] = math.min(
            diag, math.min(dp[i - 1][j] + gap, dp[i][j - 1] + gap));
      }
    }

    final statuses = List<_MoraStatus>.filled(m, _MoraStatus.missing);
    var insertions = 0;
    var i = m, j = n;
    while (i > 0 || j > 0) {
      if (i > 0 && j > 0) {
        final cost = target[i - 1] == said[j - 1]
            ? 0
            : _isClose(target[i - 1], said[j - 1])
                ? close
                : sub;
        if (dp[i][j] == dp[i - 1][j - 1] + cost) {
          statuses[i - 1] = cost == 0
              ? _MoraStatus.perfect
              : cost == close
                  ? _MoraStatus.close
                  : _MoraStatus.wrong;
          i--;
          j--;
          continue;
        }
      }
      if (i > 0 && dp[i][j] == dp[i - 1][j] + gap) {
        statuses[i - 1] = _MoraStatus.missing;
        i--;
      } else {
        insertions++;
        j--;
      }
    }
    return (statuses, insertions);
  }

  static bool _isClose(String a, String b) {
    if (a == b) return true;
    String devoice(String mora) {
      final head = _devoiced[mora[0]] ?? mora[0];
      return head + mora.substring(1);
    }

    if (devoice(a) == devoice(b)) return true;

    final ra = _romaji[a], rb = _romaji[b];
    if (ra == null || rb == null || ra == 'ʔ' || rb == 'ʔ') return false;
    if (ra == 'n' || rb == 'n') return false;

    final va = ra[ra.length - 1], vb = rb[rb.length - 1];
    final ca = ra.substring(0, ra.length - 1);
    final cb = rb.substring(0, rb.length - 1);
    // Same consonant, different vowel (か vs こ) — close.
    if (ca.isNotEmpty && ca == cb) return true;
    // Same vowel, different consonant (か vs た) — close.
    if (va == vb && ca.isNotEmpty && cb.isNotEmpty) return true;
    return false;
  }
}

// ── Widgets ───────────────────────────────────────────────────────────
class _AiPill extends StatelessWidget {
  const _AiPill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded,
              color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            'AI • $text',
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

class _PhraseCard extends StatelessWidget {
  const _PhraseCard({
    required this.phrase,
    required this.morae,
    required this.scored,
  });

  final _CoachPhrase phrase;
  final List<_MoraResult> morae;
  final bool scored;

  @override
  Widget build(BuildContext context) {
    final targetMorae = _PronunciationScorer.segmentMorae(phrase.kana);
    final chips = scored
        ? morae
        : [
            for (var i = 0; i < targetMorae.length; i++)
              _MoraResult(
                targetMorae[i],
                phrase.pronOverrides[i] ??
                    _PronunciationScorer.bengaliOf(targetMorae[i]),
                _MoraStatus.missing,
              ),
          ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 8,
            children: [
              for (final r in chips)
                _MoraChip(result: r, neutral: !scored),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            phrase.pron,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w800,
              fontSize: 15,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            phrase.bengali,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoraChip extends StatelessWidget {
  const _MoraChip({required this.result, required this.neutral});
  final _MoraResult result;
  final bool neutral;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = neutral
        ? (
            const Color(0xFFF1F5F9),
            const Color(0xFF1E293B),
            const Color(0xFFCBD5E1)
          )
        : switch (result.status) {
            _MoraStatus.perfect => (
                const Color(0xFFDCFCE7),
                const Color(0xFF15803D),
                const Color(0xFF86EFAC)
              ),
            _MoraStatus.close => (
                const Color(0xFFFEF9C3),
                const Color(0xFFA16207),
                const Color(0xFFFDE047)
              ),
            _MoraStatus.wrong => (
                const Color(0xFFFEE2E2),
                const Color(0xFFB91C1C),
                const Color(0xFFFCA5A5)
              ),
            _MoraStatus.missing => (
                const Color(0xFFF8FAFC),
                const Color(0xFF94A3B8),
                const Color(0xFFE2E8F0)
              ),
          };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            result.mora,
            style: TextStyle(
              color: fg,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          Text(
            result.label,
            style: TextStyle(
              color: fg.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score, required this.heard});
  final int score;
  final String heard;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _ScoreRing(score: score, size: 84),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'あなたの発音: $score%',
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _PronunciationCoachScreenState._verdictFor(score),
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  heard.trim().isEmpty
                      ? 'AI কিছু শুনতে পায়নি — একটু জোরে বলুন!'
                      : 'AI শুনেছে: 「${heard.trim()}」',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score, required this.size});
  final int score;
  final double size;

  Color get _color => score >= 85
      ? const Color(0xFF22C55E)
      : score >= 60
          ? const Color(0xFFEAB308)
          : const Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score / 100),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: size / 12,
                strokeCap: StrokeCap.round,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(_color),
              ),
              Center(
                child: Text(
                  '${(value * 100).round()}%',
                  style: TextStyle(
                    color: _color,
                    fontWeight: FontWeight.w900,
                    fontSize: size / 4.2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.phrase, required this.score});
  final _CoachPhrase phrase;
  final int score;

  @override
  Widget build(BuildContext context) {
    final attempted = score >= 0;
    final color = !attempted
        ? const Color(0xFF94A3B8)
        : score >= 85
            ? const Color(0xFF22C55E)
            : score >= 60
                ? const Color(0xFFEAB308)
                : const Color(0xFFEF4444);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                phrase.kana,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              Text(
                phrase.bengali,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            attempted ? '$score%' : '—',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.25),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1.6),
              ),
              child: Icon(icon, color: const Color(0xFF1E293B), size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ],
        ),
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
        color: const Color(0xFFEF4444).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFB91C1C)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF7F1D1D),
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
