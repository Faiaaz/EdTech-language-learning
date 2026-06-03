// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:ez_trainz/utils/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:ez_trainz/services/jlc_tts.dart';
import 'package:get/get.dart';
import 'package:ez_trainz/services/jlc_stt.dart';

class N5HeroNumber1LessonScreen extends StatefulWidget {
  const N5HeroNumber1LessonScreen({super.key});

  @override
  State<N5HeroNumber1LessonScreen> createState() => _N5HeroNumber1LessonScreenState();
}

enum _HeroTab { speak, match, blitz, tapHear, read, order, speakSeq }

class _N5HeroNumber1LessonScreenState extends State<N5HeroNumber1LessonScreen> {
  static const _tabs = [
    _HeroTab.tapHear,
    _HeroTab.read,
    _HeroTab.order,
    _HeroTab.speakSeq,
    _HeroTab.speak,
    _HeroTab.match,
    _HeroTab.blitz,
  ];
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: Get.back,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('হিরো নাম্বার ১',
                            style: TextStyle(
                                color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 18)),
                        Text('১-১০ সংখ্যা: কানজি + হিরাগানা -> বাংলা',
                            style: TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _HeroTabPills(
                index: _tab,
                onChange: (i) => setState(() => _tab = i),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: switch (_tabs[_tab]) {
                  _HeroTab.speak => const _HeroSpeakGame(key: ValueKey('heroSpeak')),
                  _HeroTab.match => const _HeroMatchGame(key: ValueKey('heroMatch')),
                  _HeroTab.blitz => const _HeroBlitzGame(key: ValueKey('heroBlitz')),
                  _HeroTab.tapHear => const _HeroTapWhatYouHearGame(key: ValueKey('heroTapHear')),
                  _HeroTab.read => const _HeroReadGame(key: ValueKey('heroRead')),
                  _HeroTab.order => const _HeroOrderGame(key: ValueKey('heroOrder')),
                  _HeroTab.speakSeq => const _HeroSpeakSequenceGame(key: ValueKey('heroSpeakSeq')),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroNum {
  const _HeroNum({
    required this.n,
    required this.kanji,
    required this.kana,
    required this.romaji,
    required this.bnPronunciation,
    required this.bnDigit,
    required this.bnWord,
  });
  final int n;
  final String kanji;
  final String kana;
  final String romaji;
  final String bnPronunciation;
  final String bnDigit;
  final String bnWord;
}

const _heroNumbers = <_HeroNum>[
  _HeroNum(
      n: 1,
      kanji: '一',
      kana: 'いち',
      romaji: 'ichi',
      bnPronunciation: 'ইচি',
      bnDigit: '১',
      bnWord: 'এক'),
  _HeroNum(
      n: 2,
      kanji: '二',
      kana: 'に',
      romaji: 'ni',
      bnPronunciation: 'নি',
      bnDigit: '২',
      bnWord: 'দুই'),
  _HeroNum(
      n: 3,
      kanji: '三',
      kana: 'さん',
      romaji: 'san',
      bnPronunciation: 'সান',
      bnDigit: '৩',
      bnWord: 'তিন'),
  _HeroNum(
      n: 4,
      kanji: '四',
      kana: 'よん',
      romaji: 'yon',
      bnPronunciation: 'ইয়োন',
      bnDigit: '৪',
      bnWord: 'চার'),
  _HeroNum(
      n: 5,
      kanji: '五',
      kana: 'ご',
      romaji: 'go',
      bnPronunciation: 'গো',
      bnDigit: '৫',
      bnWord: 'পাঁচ'),
  _HeroNum(
      n: 6,
      kanji: '六',
      kana: 'ろく',
      romaji: 'roku',
      bnPronunciation: 'রোকু',
      bnDigit: '৬',
      bnWord: 'ছয়'),
  _HeroNum(
      n: 7,
      kanji: '七',
      kana: 'なな',
      romaji: 'nana',
      bnPronunciation: 'নানা',
      bnDigit: '৭',
      bnWord: 'সাত'),
  _HeroNum(
      n: 8,
      kanji: '八',
      kana: 'はち',
      romaji: 'hachi',
      bnPronunciation: 'হাচি',
      bnDigit: '৮',
      bnWord: 'আট'),
  _HeroNum(
      n: 9,
      kanji: '九',
      kana: 'きゅう',
      romaji: 'kyuu',
      bnPronunciation: 'কিউ',
      bnDigit: '৯',
      bnWord: 'নয়'),
  _HeroNum(
      n: 10,
      kanji: '十',
      kana: 'じゅう',
      romaji: 'juu',
      bnPronunciation: 'জু',
      bnDigit: '১০',
      bnWord: 'দশ'),
];

class _HeroTabPills extends StatelessWidget {
  const _HeroTabPills({required this.index, required this.onChange});
  final int index;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    const labels = ['শুনে ট্যাপ', 'পড়া মাস্টার', 'সাজাও', '১-১০ বলো', 'বলতে পারো', 'ম্যাচ মাস্টার', 'স্পিড বস'];
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bg),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              GestureDetector(
                onTap: () => onChange(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: i == index ? const Color(0xFF3B82F6) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(labels[i],
                      style: TextStyle(
                          color: i == index ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w900, fontSize: 12)),
                ),
              ),
              if (i != labels.length - 1) const SizedBox(width: 6),
            ]
          ],
        ),
      ),
    );
  }
}

class _HeroSpeakGame extends StatefulWidget {
  const _HeroSpeakGame({super.key});

  @override
  State<_HeroSpeakGame> createState() => _HeroSpeakGameState();
}

class _HeroSpeakGameState extends State<_HeroSpeakGame>
    with TickerProviderStateMixin {
  final _rng = math.Random();
  final _tts = JlcTts();
  final _stt = JlcStt();
  bool _ttsReady = false;
  bool _sttReady = false;
  String? _locale;
  late _HeroNum _target;
  String _heard = '';
  bool _listening = false;
  bool _grading = false;
  int? _lastScore;
  Set<int> _matchedKanaIdx = {};
  bool _slowMode = false;
  String _status = 'মাইক চাপো এবং উচ্চারণ বলো';
  String? _error;
  int _attempts = 0;
  int _correct = 0;
  int _streak = 0;
  final Map<int, int> _missed = {};
  Timer? _recordTimer;
  Timer? _gradingTimer;
  int _recordSecondsLeft = 0;
  int _score = 0;
  int _totalXp = 0;
  double _soundLevel = 0;
  late final AnimationController _waveCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _badgePopCtrl;

  @override
  void initState() {
    super.initState();
    _target = _heroNumbers[_rng.nextInt(_heroNumbers.length)];
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _badgePopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _initTts();
    _initStt();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(_slowMode ? 0.30 : 0.50);
      await _tts.prefetchTexts(
        _heroNumbers.expand((h) => <String>[h.kana, '${h.kana}。']),
      );
      if (!mounted) return;
      setState(() => _ttsReady = true);
    } catch (_) {}
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
        setState(() => _sttReady = false);
        return;
      }
      final locales = await _stt.locales();
      final ja = locales.where((l) => l.localeId.toLowerCase().startsWith('ja'));
      setState(() {
        _locale = ja.isNotEmpty ? ja.first.localeId : (locales.isNotEmpty ? locales.first.localeId : null);
        _sttReady = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sttReady = false;
        _error = '$e';
      });
    }
  }

  Future<void> _speakModel({bool? slow}) async {
    if (!_ttsReady) return;
    final useSlow = slow ?? _slowMode;
    HapticFeedback.selectionClick();
    await _tts.stop();
    await _tts.setSpeechRate(useSlow ? 0.30 : 0.50);
    await _tts.speak(_target.kana);
  }

  Future<void> _toggleSlow() async {
    setState(() => _slowMode = !_slowMode);
    await _speakModel(slow: _slowMode);
  }

  Future<void> _compareNative() async {
    if (!_ttsReady) return;
    HapticFeedback.selectionClick();
    await _tts.stop();
    await _tts.setSpeechRate(0.50);
    await _tts.speak(_target.kana);
    await Future.delayed(const Duration(milliseconds: 900));
    await _tts.setSpeechRate(0.30);
    await _tts.speak(_target.kana);
  }

  String _norm(String s) {
    final lower = s.toLowerCase();
    final sb = StringBuffer();
    for (final r in lower.runes) {
      final ascii = (r >= 0x30 && r <= 0x39) || (r >= 0x61 && r <= 0x7A);
      final jp = (r >= 0x3040 && r <= 0x30FF) || (r >= 0x4E00 && r <= 0x9FFF);
      if (ascii || jp) sb.write(String.fromCharCode(r));
    }
    return sb.toString();
  }

  ({int score, Set<int> matchedIdx}) _grade(String raw, _HeroNum target) {
    final heard = _norm(raw);
    final kana = _norm(target.kana);
    final romaji = _norm(target.romaji);
    final kanji = _norm(target.kanji);
    final digit = target.n.toString();
    if (heard.isEmpty) return (score: 0, matchedIdx: <int>{});

    int base;
    if (heard == kana || heard == romaji || heard == kanji || heard == digit) {
      base = 100;
    } else if (heard.contains(kana)) {
      base = 96;
    } else if (heard.contains(romaji)) {
      base = 92;
    } else if (kanji.isNotEmpty && heard.contains(kanji)) {
      base = 90;
    } else if (heard.contains(digit)) {
      base = 88;
    } else {
      final ref = kana.isNotEmpty ? kana : romaji;
      base = (_similarity(heard, ref) * 70).round();
    }

    final matchedIdx = <int>{};
    final kanaRunes = target.kana.runes.toList();
    final remaining = heard.runes.toList();
    for (var i = 0; i < kanaRunes.length; i++) {
      final idx = remaining.indexOf(kanaRunes[i]);
      if (idx >= 0) {
        matchedIdx.add(i);
        remaining.removeAt(idx);
      }
    }
    if (base >= 88 && matchedIdx.isEmpty) {
      for (var i = 0; i < kanaRunes.length; i++) {
        matchedIdx.add(i);
      }
    }
    return (score: base.clamp(0, 100), matchedIdx: matchedIdx);
  }

  double _similarity(String a, String b) {
    if (b.isEmpty) return 0;
    int matches = 0;
    final remaining = a.split('').toList();
    for (final c in b.split('')) {
      final idx = remaining.indexOf(c);
      if (idx >= 0) {
        matches++;
        remaining.removeAt(idx);
      }
    }
    return matches / b.length;
  }

  Future<void> _start() async {
    if (_listening || _grading) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _heard = '';
      _error = null;
      _lastScore = null;
      _matchedKanaIdx = {};
      _status = 'রেকর্ডিং শুরু হচ্ছে...';
      _recordSecondsLeft = 5;
      _soundLevel = 0;
    });
    try {
      if (!_sttReady) {
        await _initStt();
      }
      if (!_sttReady) {
        throw Exception('Speech recognition এই ডিভাইসে কাজ করছে না।');
      }
      await _stt.listen(
        localeId: _locale,
        listenMode: ListenMode.confirmation,
        partialResults: true,
        cancelOnError: true,
        onResult: (JlcSttResult r) {
          if (!mounted) return;
          setState(() => _heard = r.recognizedWords);
        },
        onSoundLevelChange: (level) {
          if (!mounted) return;
          setState(() => _soundLevel = level);
        },
      );
      if (!mounted) return;
      setState(() {
        _listening = true;
        _status = 'রেকর্ড হচ্ছে...';
      });
      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
        if (!mounted || !_listening) return;
        if (_recordSecondsLeft <= 1) {
          await _stopAndCheck();
          return;
        }
        setState(() {
          _recordSecondsLeft -= 1;
        });
      });
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.lightImpact();
      _recordTimer?.cancel();
      setState(() {
        _listening = false;
        _error = '$e';
        _status = 'রেকর্ডিং শুরু হয়নি';
        _recordSecondsLeft = 0;
      });
    }
  }

  Future<void> _stopAndCheck() async {
    if (!_listening) return;
    _recordTimer?.cancel();
    HapticFeedback.selectionClick();
    setState(() {
      _soundLevel = 0;
      _status = 'যাচাই হচ্ছে...';
    });
    await _stt.stop();
    final heardNorm = _norm(_heard);
    if (!mounted) return;
    setState(() {
      _listening = false;
      _recordSecondsLeft = 0;
      _soundLevel = 0;
      if (heardNorm.isEmpty) {
        _lastScore = 0;
        _matchedKanaIdx = {};
        _status = 'কিছু শোনা যায়নি — আবার চেষ্টা করো';
        _streak = 0;
      } else {
        _grading = true;
        _status = 'Grading your recording now...';
      }
    });
    if (heardNorm.isEmpty) return;

    final result = _grade(_heard, _target);
    _gradingTimer?.cancel();
    _gradingTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final ok = result.score >= 80;
      setState(() {
        _grading = false;
        _lastScore = result.score;
        _matchedKanaIdx = result.matchedIdx;
        _attempts += 1;
        if (ok) {
          _streak += 1;
          _correct += 1;
          _score += 10;
          _totalXp += 10;
          _status = result.score >= 90 ? 'দারুণ! সঠিক উচ্চারণ' : 'ভালো হয়েছে!';
          HapticFeedback.lightImpact();
        } else {
          _streak = 0;
          _missed[_target.n] = (_missed[_target.n] ?? 0) + 1;
          _status = 'আরেকবার চেষ্টা করো';
        }
      });
      _badgePopCtrl.forward(from: 0);
    });
  }

  void _next() {
    setState(() {
      _target = _heroNumbers[_rng.nextInt(_heroNumbers.length)];
      _heard = '';
      _lastScore = null;
      _matchedKanaIdx = {};
      _status = 'মাইক চাপো এবং উচ্চারণ বলো';
    });
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _gradingTimer?.cancel();
    _waveCtrl.dispose();
    _pulseCtrl.dispose();
    _badgePopCtrl.dispose();
    _stt.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = _lastScore;
    final scoreColor = score == null
        ? Colors.transparent
        : (score >= 90 ? const Color(0xFF22C55E) : const Color(0xFFFFA726));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(children: [
        _TopBar(score: _score, lives: 3),
        const SizedBox(height: 12),
        _SpeechCard(
          target: _target,
          matchedIdx: _matchedKanaIdx,
          showHighlight: _lastScore != null,
          scoreBadge: score == null
              ? null
              : ScaleTransition(
                  scale: CurvedAnimation(parent: _badgePopCtrl, curve: Curves.elasticOut),
                  child: _ScoreBadge(score: score, color: scoreColor),
                ),
        ),
        const SizedBox(height: 18),
        _UtilityRow(
          slow: _slowMode,
          onSlow: _toggleSlow,
          onPlay: () => _speakModel(slow: false),
          onCompare: _compareNative,
          disabled: _listening || _grading,
        ),
        const SizedBox(height: 18),
        _MicButton(
          listening: _listening,
          grading: _grading,
          pulse: _pulseCtrl,
          onTap: _grading
              ? () {}
              : (_listening ? _stopAndCheck : _start),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 56,
          child: _listening
              ? _WaveformBars(level: _soundLevel, anim: _waveCtrl)
              : (_grading
                  ? const _GradingDots()
                  : _StatusLine(
                      status: _status,
                      lastScore: _lastScore,
                    )),
        ),
        if (_heard.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'শোনা: $_heard',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 6),
          Text(_error!,
              style: TextStyle(color: Colors.red.shade300, fontWeight: FontWeight.w700)),
        ],
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _attempts == 0 && _missed.isEmpty
                  ? null
                  : () => _showAwesomeResult(
                        context: context,
                        title: 'বলতে পারো — রিভিউ',
                        scoreLabel: '+$_totalXp XP',
                        stats: [
                          'চেষ্টা: $_attempts',
                          'সঠিক: $_correct',
                          'Accuracy: ${_attempts == 0 ? 0 : ((_correct * 100) / _attempts).round()}%',
                          'সেরা স্ট্রিক: $_streak',
                        ],
                        missedLines: _missed.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value)),
                        onPlayAgain: () {
                          setState(() {
                            _score = 0;
                            _attempts = 0;
                            _correct = 0;
                            _streak = 0;
                            _totalXp = 0;
                            _missed.clear();
                            _heard = '';
                            _status = 'মাইক চাপো এবং উচ্চারণ বলো';
                            _lastScore = null;
                            _matchedKanaIdx = {};
                          });
                        },
                      ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.border),
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.insights_rounded),
              label: const Text('রিভিউ', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _grading ? null : _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFE000),
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.navigate_next_rounded),
              label: const Text('পরের সংখ্যা', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ])
      ]),
    );
  }
}

class _SpeechCard extends StatelessWidget {
  const _SpeechCard({
    required this.target,
    required this.matchedIdx,
    required this.showHighlight,
    this.scoreBadge,
  });
  final _HeroNum target;
  final Set<int> matchedIdx;
  final bool showHighlight;
  final Widget? scoreBadge;

  @override
  Widget build(BuildContext context) {
    final kanaRunes = target.kana.runes.toList();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          decoration: _cardDeco(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE000), Color(0xFFFFA726)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                      color: AppColors.border, width: 2),
                ),
                alignment: Alignment.center,
                child: const Text('先生',
                    style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w900,
                        fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: -8,
                      top: 16,
                      child: CustomPaint(
                        size: const Size(10, 14),
                        painter: _BubbleTailPainter(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            target.kanji,
                            style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                height: 1.0),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            children: [
                              for (var i = 0; i < kanaRunes.length; i++)
                                _KanaChar(
                                  ch: String.fromCharCode(kanaRunes[i]),
                                  highlight:
                                      showHighlight && matchedIdx.contains(i),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            target.romaji,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'উচ্চারণ: ${target.bnPronunciation}',
                            style: const TextStyle(
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'বাংলা: ${target.bnDigit} ${target.bnWord}',
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (scoreBadge != null)
          Positioned(top: -10, right: -6, child: scoreBadge!),
      ],
    );
  }
}

class _KanaChar extends StatelessWidget {
  const _KanaChar({required this.ch, required this.highlight});
  final String ch;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 2),
      padding: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: highlight ? const Color(0xFF22C55E) : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Text(
        ch,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 26,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, required this.color});
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: AppColors.textPrimary, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$score',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _UtilityRow extends StatelessWidget {
  const _UtilityRow({
    required this.slow,
    required this.onSlow,
    required this.onPlay,
    required this.onCompare,
    required this.disabled,
  });
  final bool slow;
  final VoidCallback onSlow;
  final VoidCallback onPlay;
  final VoidCallback onCompare;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _UtilityButton(
          icon: Icons.pets_rounded,
          active: slow,
          onTap: disabled ? null : onSlow,
          tooltip: 'ধীরে',
        ),
        const SizedBox(width: 18),
        _UtilityButton(
          icon: Icons.volume_up_rounded,
          onTap: disabled ? null : onPlay,
          tooltip: 'শুনি',
        ),
        const SizedBox(width: 18),
        _UtilityButton(
          icon: Icons.compare_arrows_rounded,
          onTap: disabled ? null : onCompare,
          tooltip: 'তুলনা',
        ),
      ],
    );
  }
}

class _UtilityButton extends StatelessWidget {
  const _UtilityButton({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback? onTap;
  final bool active;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? const Color(0xFFFFE000)
        : AppColors.border;
    final fg = active ? AppColors.textPrimary : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: fg, size: 24),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.listening,
    required this.grading,
    required this.pulse,
    required this.onTap,
  });
  final bool listening;
  final bool grading;
  final Animation<double> pulse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final base = listening ? const Color(0xFFEF4444) : const Color(0xFFFF6B35);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (_, __) {
          final scale = listening ? 1.0 + (pulse.value * 0.08) : 1.0;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: grading ? Colors.grey.shade600 : base,
                boxShadow: [
                  BoxShadow(
                    color: base.withValues(alpha: 0.45),
                    blurRadius: 22,
                    spreadRadius: listening ? 4 : 0,
                  ),
                ],
                border: Border.all(color: AppColors.textPrimary, width: 4),
              ),
              child: Icon(
                listening ? Icons.stop_rounded : Icons.mic_rounded,
                color: AppColors.textPrimary,
                size: 42,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WaveformBars extends StatelessWidget {
  const _WaveformBars({required this.level, required this.anim});
  final double level;
  final Animation<double> anim;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) {
        final base = (level.clamp(-2, 12) + 2) / 14; // 0..1 roughly
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(11, (i) {
            final phase = (anim.value * 2 * math.pi) + (i * 0.55);
            final wob = 0.55 + 0.45 * math.sin(phase).abs();
            final h = (8 + base * 36 * wob + 4 * math.sin(phase * 1.7)).clamp(6.0, 52.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                width: 6,
                height: h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7B9C),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _GradingDots extends StatefulWidget {
  const _GradingDots();
  @override
  State<_GradingDots> createState() => _GradingDotsState();
}

class _GradingDotsState extends State<_GradingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Grading your recording now',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Opacity(
                  opacity: ((_c.value * 3 + i / 3) % 1.0 > 0.5) ? 1.0 : 0.3,
                  child: const Text('.',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 22)),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.status, required this.lastScore});
  final String status;
  final int? lastScore;

  @override
  Widget build(BuildContext context) {
    final ok = lastScore != null && lastScore! >= 80;
    final showXp = lastScore != null && lastScore! >= 80;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lastScore != null) ...[
              Icon(
                ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: ok ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                size: 20,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              status,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            if (showXp) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE000),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+${lastScore! >= 90 ? 30 : 20} XP',
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _HeroPair {
  const _HeroPair({required this.id, required this.n, required this.label, required this.jp});
  final String id;
  final int n;
  final String label;
  final bool jp;
}

class _HeroMatchGame extends StatefulWidget {
  const _HeroMatchGame({super.key});
  @override
  State<_HeroMatchGame> createState() => _HeroMatchGameState();
}

class _HeroMatchGameState extends State<_HeroMatchGame>
    with TickerProviderStateMixin {
  final _rng = math.Random();
  final _tts = JlcTts();
  late ConfettiController _confetti;
  late AnimationController _shakeCtrl;
  bool _ttsReady = false;

  late List<_HeroPair> _cards;
  String? _picked;
  int? _pickedN;
  final _matched = <String>{};
  final Map<int, int> _missesByPair = {};
  int _moves = 0;
  int _wrongMoves = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _xp = 0;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  String _wrongId = '';

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 700));
    _shakeCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _initTts();
    _reset();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.50);
      await _tts.setPitch(1.05);
      await _tts.prefetchTexts(
        _heroNumbers.expand((h) => <String>[h.kana, '${h.kana}。']),
      );
      if (!mounted) return;
      setState(() => _ttsReady = true);
    } catch (_) {}
  }

  void _reset() {
    final pool = List<_HeroNum>.of(_heroNumbers)..shuffle(_rng);
    final take = pool.take(6).toList();
    final cards = <_HeroPair>[];
    for (final n in take) {
      cards.add(_HeroPair(
          id: 'jp_${n.n}',
          n: n.n,
          label: '${n.kanji}\n${n.kana}\n(${n.bnPronunciation})',
          jp: true));
      cards.add(_HeroPair(
          id: 'bn_${n.n}', n: n.n, label: '${n.bnDigit} ${n.bnWord}', jp: false));
    }
    cards.shuffle(_rng);
    setState(() {
      _cards = cards;
      _picked = null;
      _pickedN = null;
      _matched.clear();
      _missesByPair.clear();
      _moves = 0;
      _wrongMoves = 0;
      _streak = 0;
      _bestStreak = 0;
      _xp = 0;
      _wrongId = '';
    });
    _stopwatch
      ..reset()
      ..start();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _speak(int n) async {
    if (!_ttsReady) return;
    final hero = _heroNumbers.firstWhere((x) => x.n == n);
    await _tts.stop();
    await _tts.speak(hero.kana);
  }

  void _tap(_HeroPair c) {
    if (_matched.contains(c.id)) return;
    if (c.jp) {
      // ignore: discarded_futures
      _speak(c.n);
    }
    if (_picked == null) {
      HapticFeedback.selectionClick();
      setState(() {
        _picked = c.id;
        _pickedN = c.n;
      });
      return;
    }
    if (_picked == c.id) return;
    _moves += 1;
    final ok = _pickedN == c.n;
    if (ok) {
      HapticFeedback.mediumImpact();
      setState(() {
        _matched.add(_picked!);
        _matched.add(c.id);
        _picked = null;
        _pickedN = null;
        _streak += 1;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _xp += 10;
      });
      _confetti.play();
      if (_matched.length == _cards.length) {
        _stopwatch.stop();
        _ticker?.cancel();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          _showAwesomeResult(
            context: context,
            title: 'ম্যাচ মাস্টার — সব মিলেছে',
            scoreLabel: 'XP: $_xp',
            stats: [
              'মুভ: $_moves',
              'ভুল: $_wrongMoves',
              'নির্ভুলতা: ${_moves == 0 ? 0 : (((_moves - _wrongMoves) * 100) / _moves).round()}%',
              'সেরা স্ট্রিক: $_bestStreak',
              'সময়: ${_formatDuration(_stopwatch.elapsed)}',
            ],
            missedLines: _missesByPair.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)),
            onPlayAgain: _reset,
          );
        });
      }
    } else {
      HapticFeedback.heavyImpact();
      _wrongMoves += 1;
      _missesByPair[c.n] = (_missesByPair[c.n] ?? 0) + 1;
      _missesByPair[_pickedN!] = (_missesByPair[_pickedN!] ?? 0) + 1;
      final now = c.id;
      setState(() {
        _wrongId = now;
        _picked = now;
        _pickedN = c.n;
        _streak = 0;
      });
      _shakeCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 520), () {
        if (!mounted) return;
        setState(() {
          if (_picked == now) {
            _picked = null;
            _pickedN = null;
          }
          _wrongId = '';
        });
      });
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _confetti.dispose();
    _shakeCtrl.dispose();
    _ticker?.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _cards.isEmpty ? 0.0 : _matched.length / _cards.length;
    final elapsed = _formatDuration(_stopwatch.elapsed);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  maxBlastForce: 14,
                  minBlastForce: 6,
                  emissionFrequency: 0.08,
                  numberOfParticles: 12,
                  gravity: 0.22,
                  shouldLoop: false,
                  colors: const [
                    Color(0xFFFFE000),
                    Color(0xFF10B981),
                    Color(0xFFFF8A34),
                    Color(0xFF3B82F6),
                  ],
                ),
              ),
            ),
          ),
          Column(children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: _cardDeco(),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.extension_rounded, color: Color(0xFFFFE000)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('জাপানি ↔ বাংলা মিলাও',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900)),
                      ),
                      _MatchStatChip(label: 'XP', value: '$_xp'),
                      const SizedBox(width: 6),
                      _MatchStatChip(label: 'স্ট্রিক', value: '$_streak'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer_rounded,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(elapsed,
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w800,
                              fontSize: 12)),
                      const SizedBox(width: 14),
                      Text('মুভ: $_moves',
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w800,
                              fontSize: 12)),
                      const Spacer(),
                      Text('${_matched.length ~/ 2}/${_cards.length ~/ 2} মিলেছে',
                          style: const TextStyle(
                              color: Color(0xFFFFE000),
                              fontWeight: FontWeight.w900,
                              fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(99),
                    value: progress.clamp(0, 1),
                    backgroundColor: AppColors.border,
                    valueColor:
                        const AlwaysStoppedAnimation(Color(0xFFFFE000)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                itemCount: _cards.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (_, i) {
                  final c = _cards[i];
                  final selected = _picked == c.id;
                  final matched = _matched.contains(c.id);
                  final wrong = _wrongId == c.id;
                  final border = matched
                      ? const Color(0xFF10B981)
                      : wrong
                          ? const Color(0xFFEF4444)
                          : (selected
                              ? const Color(0xFFFFE000)
                              : AppColors.border);
                  final bg = matched
                      ? const Color(0xFF10B981).withValues(alpha: 0.18)
                      : wrong
                          ? const Color(0xFFEF4444).withValues(alpha: 0.18)
                          : (selected
                              ? const Color(0xFFFFE000).withValues(alpha: 0.14)
                              : AppColors.bg);
                  return AnimatedBuilder(
                    animation: _shakeCtrl,
                    builder: (_, child) {
                      final dx = wrong
                          ? math.sin(_shakeCtrl.value * math.pi * 6) * 8
                          : 0.0;
                      return Transform.translate(
                          offset: Offset(dx, 0), child: child);
                    },
                    child: GestureDetector(
                      onTap: () => _tap(c),
                      child: AnimatedScale(
                        scale: matched ? 1.04 : (selected ? 1.02 : 1.0),
                        duration: const Duration(milliseconds: 220),
                        child: Container(
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: border,
                                width: selected || wrong ? 2.4 : 1.5),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    c.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: c.jp ? 18 : 14,
                                    ),
                                  ),
                                ),
                              ),
                              if (c.jp)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.border,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.volume_up_rounded,
                                        size: 12, color: AppColors.textPrimary),
                                  ),
                                ),
                              if (matched)
                                const Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Icon(Icons.check_circle_rounded,
                                      size: 16, color: Color(0xFF10B981)),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                    side:
                        BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.textPrimary),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('রি-স্টার্ট',
                    style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _MatchStatChip extends StatelessWidget {
  const _MatchStatChip({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800)),
          const SizedBox(width: 4),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFFFFE000),
                  fontWeight: FontWeight.w900,
                  fontSize: 12)),
        ],
      ),
    );
  }
}

class _HeroBlitzGame extends StatefulWidget {
  const _HeroBlitzGame({super.key});

  @override
  State<_HeroBlitzGame> createState() => _HeroBlitzGameState();
}

class _HeroBlitzGameState extends State<_HeroBlitzGame>
    with TickerProviderStateMixin {
  final _rng = math.Random();
  final _tts = JlcTts();
  late ConfettiController _confetti;
  late AnimationController _shakeCtrl;
  static const _totalSeconds = 25;
  static const _maxRounds = 8;
  static const _sessionXpBonus = 50;

  late _HeroNum _target;
  late List<_HeroNum> _options;
  Timer? _timer;
  int _timeLeft = _totalSeconds;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _round = 1;
  int _attempts = 0;
  int _correct = 0;
  final Map<int, int> _missed = {};
  bool _locked = false;
  int? _picked;
  bool _slowMode = false;
  bool _ttsReady = false;

  @override
  void initState() {
    super.initState();
    _confetti =
        ConfettiController(duration: const Duration(milliseconds: 650));
    _shakeCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _initTts();
    _prepareRound(resetRoundCount: true);
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(_slowMode ? 0.32 : 0.50);
      await _tts.setPitch(1.05);
      await _tts.prefetchTexts(
        _heroNumbers.expand((h) => <String>[h.kana, '${h.kana}。']),
      );
      if (!mounted) return;
      setState(() => _ttsReady = true);
      WidgetsBinding.instance.addPostFrameCallback((_) => _speak());
    } catch (_) {}
  }

  Future<void> _speak() async {
    if (!_ttsReady) return;
    await _tts.stop();
    await _tts.setSpeechRate(_slowMode ? 0.32 : 0.50);
    await _tts.speak(_target.kana);
  }

  void _prepareRound({bool resetRoundCount = false}) {
    if (resetRoundCount) {
      _round = 1;
      _score = 0;
      _streak = 0;
      _bestStreak = 0;
      _timeLeft = _totalSeconds;
      _attempts = 0;
      _correct = 0;
      _missed.clear();
    }
    final t = _heroNumbers[_rng.nextInt(_heroNumbers.length)];
    final pool =
        _heroNumbers.where((e) => e.n != t.n).toList()..shuffle(_rng);
    setState(() {
      _target = t;
      _options = [t, ...pool.take(3)]..shuffle(_rng);
      _locked = false;
      _picked = null;
    });
    if (_ttsReady) {
      // ignore: discarded_futures
      _speak();
    }
    if (resetRoundCount) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        if (_timeLeft <= 1) {
          timer.cancel();
          _showEndDialog();
        } else {
          setState(() => _timeLeft -= 1);
        }
      });
    }
  }

  void _pick(_HeroNum n) {
    if (_locked) return;
    _completeRound(correct: n.n == _target.n, picked: n.n);
  }

  void _completeRound({required bool correct, int? picked}) {
    if (_locked) return;
    setState(() {
      _locked = true;
      _picked = picked;
      _attempts += 1;
      if (correct) {
        _score += 10;
        _streak += 1;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _correct += 1;
      } else {
        _streak = 0;
        _missed[_target.n] = (_missed[_target.n] ?? 0) + 1;
      }
    });
    if (correct) {
      HapticFeedback.mediumImpact();
      _confetti.play();
    } else {
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0);
    }
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      if (_timeLeft <= 0 || _round >= _maxRounds) {
        _showEndDialog();
      } else {
        _round += 1;
        _prepareRound();
      }
    });
  }

  void _showEndDialog() {
    _timer?.cancel();
    final acc = _attempts == 0 ? 0 : ((_correct * 100) / _attempts).round();
    _showAwesomeResult(
      context: context,
      title: 'স্পিড বস — রেজাল্ট',
      scoreLabel: 'XP: ${_score + _sessionXpBonus}',
      stats: [
        'চেষ্টা: $_attempts',
        'সঠিক: $_correct',
        'নির্ভুলতা: $acc%',
        'সেরা স্ট্রিক: $_bestStreak',
        'সেশন বোনাস: +$_sessionXpBonus XP',
      ],
      missedLines: _missed.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
      onPlayAgain: () => _prepareRound(resetRoundCount: true),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confetti.dispose();
    _shakeCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _round / _maxRounds;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  maxBlastForce: 14,
                  minBlastForce: 6,
                  emissionFrequency: 0.08,
                  numberOfParticles: 12,
                  gravity: 0.22,
                  shouldLoop: false,
                  colors: const [
                    Color(0xFFFFE000),
                    Color(0xFF10B981),
                    Color(0xFFFF8A34),
                    Color(0xFF3B82F6),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: _cardDeco(),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flash_on_rounded,
                            color: Color(0xFFFFE000)),
                        const SizedBox(width: 8),
                        Text('রাউন্ড: $_round/$_maxRounds',
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900)),
                        const Spacer(),
                        Text('স্কোর: $_score',
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(99),
                      value: progress.clamp(0, 1),
                      backgroundColor: AppColors.border,
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFFFFE000)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: _shakeCtrl,
                builder: (_, child) {
                  final wrong = _picked != null && _picked != _target.n;
                  final dx = wrong
                      ? math.sin(_shakeCtrl.value * math.pi * 6) * 8
                      : 0.0;
                  return Transform.translate(
                      offset: Offset(dx, 0), child: child);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDeco(),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    (_timeLeft <= 5
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFFFFE000))
                                        .withValues(alpha: 0.22),
                                    AppColors.bg,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _timeLeft <= 5
                                      ? const Color(0xFFFF6B6B)
                                          .withValues(alpha: 0.9)
                                      : const Color(0xFFFFE000)
                                          .withValues(alpha: 0.85),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.timer_rounded,
                                    color: _timeLeft <= 5
                                        ? const Color(0xFFFF6B6B)
                                        : const Color(0xFFFFE000),
                                    size: 26,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('মোট সময়',
                                          style: TextStyle(
                                              color: AppColors.border,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11)),
                                      Text('$_timeLeft',
                                          style: TextStyle(
                                              color: _timeLeft <= 5
                                                  ? const Color(0xFFFFB4B4)
                                                  : const Color(0xFFFFE000),
                                              fontWeight: FontWeight.w900,
                                              fontSize: 32,
                                              height: 1)),
                                      Text('সেকেন্ড বাকি',
                                          style: TextStyle(
                                              color: AppColors.border,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _BlitzStatChip(
                                  label: 'স্ট্রিক', value: '$_streak'),
                              const SizedBox(height: 6),
                              _BlitzStatChip(
                                  label: 'সেরা', value: '$_bestStreak'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(_target.kanji,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 58,
                              fontWeight: FontWeight.w900)),
                      Text('${_target.kana} (${_target.bnPronunciation})',
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _speak,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE000)
                                    .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                    color: const Color(0xFFFFE000)
                                        .withValues(alpha: 0.6)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.volume_up_rounded,
                                      color: Color(0xFFFFE000), size: 18),
                                  SizedBox(width: 6),
                                  Text('শুনি',
                                      style: TextStyle(
                                          color: Color(0xFFFFE000),
                                          fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              setState(() => _slowMode = !_slowMode);
                              await _speak();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _slowMode
                                    ? const Color(0xFFFFE000)
                                    : AppColors.border,
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                    color:
                                        AppColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.pets_rounded,
                                      color: _slowMode
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                      size: 18),
                                  const SizedBox(width: 6),
                                  Text('ধীরে',
                                      style: TextStyle(
                                          color: _slowMode
                                              ? AppColors.textPrimary
                                              : AppColors.textMuted,
                                          fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('সঠিক বাংলা সংখ্যা বেছে নাও',
                          style: TextStyle(
                              color: Color(0xFFFFE000),
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  itemCount: _options.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.7),
                  itemBuilder: (_, i) {
                    final o = _options[i];
                    final picked = _picked == o.n;
                    final correct = o.n == _target.n;
                    final bg = _picked == null
                        ? AppColors.bg
                        : (correct
                            ? const Color(0xFF10B981).withValues(alpha: 0.22)
                            : (picked
                                ? const Color(0xFFEF4444)
                                    .withValues(alpha: 0.22)
                                : AppColors.bg));
                    final border = _picked == null
                        ? AppColors.border
                        : (correct
                            ? const Color(0xFF10B981)
                            : (picked
                                ? const Color(0xFFEF4444)
                                : AppColors.border));
                    return GestureDetector(
                      onTap: () => _pick(o),
                      child: AnimatedScale(
                        scale: picked && correct ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 220),
                        child: Container(
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: border,
                                width: _picked == null ? 1 : 2),
                          ),
                          child: Center(
                            child: Text('${o.bnDigit} ${o.bnWord}',
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlitzStatChip extends StatelessWidget {
  const _BlitzStatChip({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 10)),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFFFFE000),
                  fontWeight: FontWeight.w900,
                  fontSize: 16)),
        ],
      ),
    );
  }
}

/// শুনে যা বলেছে সেটার বাংলা বেছে নিন — শুধু ১–১০ জাপানি সংখ্যা।
class _HeroTapWhatYouHearGame extends StatefulWidget {
  const _HeroTapWhatYouHearGame({super.key});

  @override
  State<_HeroTapWhatYouHearGame> createState() => _HeroTapWhatYouHearGameState();
}

class _HeroTapWhatYouHearGameState extends State<_HeroTapWhatYouHearGame>
    with TickerProviderStateMixin {
  static const _totalRounds = 10;
  static const _sessionXpBonus = 50;

  final _rng = math.Random();
  final _tts = JlcTts();
  late final Future<void> _ttsReady;
  late ConfettiController _confetti;
  late AnimationController _shakeCtrl;

  late List<_HeroNum> _deck;
  int _roundIdx = 0;
  late _HeroNum _target;
  late List<_HeroNum> _options;

  bool _slowMode = false;
  bool _locked = false;
  int? _pickedN;
  bool? _lastWasCorrect;
  bool _showCorrectBanner = false;

  final Stopwatch _sessionTimer = Stopwatch();
  int _correct = 0;
  int _totalAttempts = 0;
  int _xp = 0;
  int _bestStreak = 0;
  int _streak = 0;
  final Map<int, int> _missed = {};

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 650));
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _ttsReady = _initTts();
    _newSession();
  }

  Future<void> _initTts() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(0.52);
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);
    await _tts.prefetchTexts(
      _heroNumbers.expand((h) => <String>[h.kana, '${h.kana}。']),
    );
  }

  Future<void> _applySpeechRate() async {
    await _ttsReady;
    await _tts.setSpeechRate(_slowMode ? 0.34 : 0.52);
  }

  void _newSession() {
    _deck = List<_HeroNum>.of(_heroNumbers)..shuffle(_rng);
    _roundIdx = 0;
    _correct = 0;
    _totalAttempts = 0;
    _xp = 0;
    _bestStreak = 0;
    _streak = 0;
    _missed.clear();
    _sessionTimer
      ..reset()
      ..start();
    _buildRound();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakPrompt());
  }

  void _buildRound() {
    _target = _deck[_roundIdx];
    final pool = _heroNumbers.where((e) => e.n != _target.n).toList()..shuffle(_rng);
    setState(() {
      _options = [_target, ...pool.take(3)]..shuffle(_rng);
      _locked = false;
      _pickedN = null;
      _lastWasCorrect = null;
      _showCorrectBanner = false;
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _speakPrompt() async {
    await _ttsReady;
    await _tts.stop();
    await _tts.speak('${_target.kana}。');
  }

  Future<void> _shake() async {
    await _shakeCtrl.forward(from: 0);
  }

  void _pick(_HeroNum o) {
    if (_locked) return;
    _totalAttempts += 1;
    final ok = o.n == _target.n;
    setState(() {
      _locked = true;
      _pickedN = o.n;
      _lastWasCorrect = ok;
    });
    if (ok) {
      HapticFeedback.mediumImpact();
      setState(() {
        _correct += 1;
        _streak += 1;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _xp += 10;
        _showCorrectBanner = true;
      });
      _confetti.play();
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (!mounted) return;
        setState(() {
          _showCorrectBanner = false;
          _pickedN = null;
          _lastWasCorrect = null;
          _locked = false;
        });
        if (_roundIdx >= _totalRounds - 1) {
          _sessionTimer.stop();
          _xp += _sessionXpBonus;
          _showSessionEnd();
        } else {
          _roundIdx += 1;
          _buildRound();
          _speakPrompt();
        }
      });
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _streak = 0;
        _missed[_target.n] = (_missed[_target.n] ?? 0) + 1;
      });
      // ignore: discarded_futures
      _shake();
      Future.delayed(const Duration(milliseconds: 520), () {
        if (!mounted) return;
        setState(() {
          _pickedN = null;
          _lastWasCorrect = null;
          _locked = false;
        });
      });
    }
  }

  void _showSessionEnd() {
    final acc = _totalAttempts == 0 ? 0 : ((_correct * 100) / _totalAttempts).round();
    _showAwesomeResult(
      context: context,
      title: 'শুনে ট্যাপ — সেশন শেষ',
      scoreLabel: 'মোট XP: $_xp',
      stats: [
        'সঠিক: $_correct/$_totalRounds',
        'নির্ভুলতা: $acc%',
        'সেশন বোনাস: +$_sessionXpBonus XP',
        'সেরা স্ট্রিক: $_bestStreak',
        'সময়: ${_formatDuration(_sessionTimer.elapsed)}',
      ],
      missedLines: _missed.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
      onPlayAgain: _newSession,
    );
  }

  @override
  void dispose() {
    _confetti.dispose();
    _shakeCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  Widget _buildMcqTile(_HeroNum o, Color orange) {
    final picked = _pickedN == o.n;
    final isCorrect = o.n == _target.n;
    final revealed = _pickedN != null;

    Color border;
    Color bg;
    Color textColor = AppColors.textPrimary;
    if (!revealed) {
      border = AppColors.border;
      bg = AppColors.bg;
    } else if (isCorrect) {
      border = const Color(0xFF10B981);
      bg = const Color(0xFF10B981).withValues(alpha: 0.22);
      textColor = const Color(0xFF10B981);
    } else if (picked) {
      border = const Color(0xFFEF4444);
      bg = const Color(0xFFEF4444).withValues(alpha: 0.18);
      textColor = const Color(0xFFEF4444);
    } else {
      border = AppColors.border;
      bg = AppColors.bg;
    }

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _locked ? null : () => _pick(o),
          child: Ink(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: border,
                width: (picked || (isCorrect && revealed)) ? 2.2 : 1.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  o.bnDigit,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.7),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  o.bnWord,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (revealed && isCorrect) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF10B981), size: 22),
                ] else if (revealed && picked && !isCorrect) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.cancel_rounded,
                      color: Color(0xFFEF4444), size: 22),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8A34);
    final progress = (_roundIdx + 1) / _totalRounds;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  maxBlastForce: 16,
                  minBlastForce: 6,
                  emissionFrequency: 0.08,
                  numberOfParticles: 14,
                  gravity: 0.22,
                  shouldLoop: false,
                  colors: const [
                    Color(0xFFFFE000),
                    Color(0xFF10B981),
                    Color(0xFFFF8A34),
                    Color(0xFF3B82F6),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: orange.withValues(alpha: 0.45)),
                  boxShadow: [
                    BoxShadow(
                      color: orange.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.headphones_rounded, color: orange, size: 22),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'শুনে ট্যাপ — জাপানি বলা শুনে বাংলা বেছে নিন',
                            style: TextStyle(
                                color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                        ),
                        Text(
                          _formatDuration(_sessionTimer.elapsed),
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(99),
                      value: progress.clamp(0, 1),
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(orange),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'রাউন্ড ${_roundIdx + 1}/$_totalRounds',
                          style: TextStyle(
                              color: AppColors.textMuted, fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        Text('XP: $_xp',
                            style: const TextStyle(color: Color(0xFFFFE000), fontWeight: FontWeight.w900)),
                        const SizedBox(width: 10),
                        Text('স্ট্রিক: $_streak',
                            style: TextStyle(
                                color: AppColors.textMuted, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'নির্ভুলতা: ${_totalAttempts == 0 ? 0 : ((_correct * 100) / _totalAttempts).round()}%',
                      style: TextStyle(
                          color: AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // ── Number card ──────────────────────────────────────────
              AnimatedBuilder(
                animation: _shakeCtrl,
                builder: (context, child) {
                  final t = _shakeCtrl.value;
                  final dx = math.sin(t * math.pi * 6) * 10 * (1 - t);
                  return Transform.translate(offset: Offset(dx, 0), child: child);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: orange.withValues(alpha: 0.55), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: orange.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          _target.bnPronunciation,
                          style: const TextStyle(
                            color: Color(0xFFFFE000),
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _locked ? null : _speakPrompt,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.volume_up_rounded),
                              label: const Text('আবার শুনুন',
                                  style: TextStyle(fontWeight: FontWeight.w900)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _locked
                                  ? null
                                  : () async {
                                      setState(() => _slowMode = !_slowMode);
                                      await _applySpeechRate();
                                      if (mounted) setState(() {});
                                      await _speakPrompt();
                                    },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _slowMode ? orange : AppColors.textPrimary,
                                side: BorderSide(
                                    color: _slowMode
                                        ? orange
                                        : AppColors.border),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: Icon(_slowMode
                                  ? Icons.speed_rounded
                                  : Icons.hourglass_bottom_rounded),
                              label: Text(_slowMode ? 'স্বাভাবিক' : 'ধীর শোনা',
                                  style: const TextStyle(fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ── MCQ ──────────────────────────────────────────────────
              const Text(
                'এইবার আপনি বলেন সঠিক উত্তর কোনটি?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Column(
                  children: [
                    for (int _i = 0; _i < _options.length; _i++) ...[
                      if (_i != 0) const SizedBox(height: 10),
                      _buildMcqTile(_options[_i], orange),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              offset: _showCorrectBanner ? Offset.zero : const Offset(0, 1.2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: _showCorrectBanner ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !_showCorrectBanner,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.thumb_up_alt_rounded, color: AppColors.textPrimary, size: 26),
                            const SizedBox(width: 10),
                            const Text(
                              'সঠিক!',
                              style: TextStyle(
                                  color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 22),
                            ),
                            const Spacer(),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: Icon(
                                    Icons.star_rounded,
                                    color: i < math.min(5, _streak)
                                        ? const Color(0xFFFFE000)
                                        : AppColors.border,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_target.kana} (${_target.kanji}) → ${_target.bnDigit} ${_target.bnWord}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
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
}

// ═════════════════════════════════════════════════════════════════════
// পড়া মাস্টার — Reading game with 3 question modes
// Mode A: BN digit → JP pronunciation (BN options)
// Mode B: BN word  → JP pronunciation (BN options)
// Mode C: JP pronunciation → BN word + digit
// ═════════════════════════════════════════════════════════════════════

enum _ReadMode { bnDigitToJp, bnWordToJp, jpToBn }

class _HeroReadGame extends StatefulWidget {
  const _HeroReadGame({super.key});

  @override
  State<_HeroReadGame> createState() => _HeroReadGameState();
}

class _HeroReadGameState extends State<_HeroReadGame>
    with TickerProviderStateMixin {
  static const _totalRounds = 10;
  static const _sessionXpBonus = 50;
  static const _violet = Color(0xFF8B5CF6);
  static const _violetDark = Color(0xFF6D28D9);

  final _rng = math.Random();
  final _tts = JlcTts();
  late final Future<void> _ttsReady;
  late ConfettiController _confetti;
  late AnimationController _shakeCtrl;
  late AnimationController _cardCtrl;

  late List<_HeroNum> _deck;
  int _roundIdx = 0;
  late _HeroNum _target;
  late List<_HeroNum> _options;
  late _ReadMode _mode;

  bool _locked = false;
  int? _pickedN;
  bool? _lastWasCorrect;
  bool _showCorrectBanner = false;
  bool _revealed = false;

  final Stopwatch _sessionTimer = Stopwatch();
  int _correct = 0;
  int _totalAttempts = 0;
  int _xp = 0;
  int _bestStreak = 0;
  int _streak = 0;
  final Map<int, int> _missed = {};

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 700));
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 360));
    _ttsReady = _initTts();
    _newSession();
  }

  Future<void> _initTts() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);
    await _tts.prefetchTexts(
      _heroNumbers.expand((h) => <String>[h.kana, '${h.kana}。']),
    );
  }

  Future<void> _speakTarget() async {
    await _ttsReady;
    await _tts.stop();
    await _tts.speak('${_target.kana}。');
  }

  void _newSession() {
    _deck = List<_HeroNum>.of(_heroNumbers)..shuffle(_rng);
    _roundIdx = 0;
    _correct = 0;
    _totalAttempts = 0;
    _xp = 0;
    _bestStreak = 0;
    _streak = 0;
    _missed.clear();
    _sessionTimer
      ..reset()
      ..start();
    _buildRound();
  }

  void _buildRound() {
    _target = _deck[_roundIdx];
    // Strict alternation: even rounds = BN→JP, odd rounds = JP→BN.
    // Within BN→JP, alternate between digit and word for variety.
    if (_roundIdx.isEven) {
      _mode = (_roundIdx ~/ 2).isEven
          ? _ReadMode.bnDigitToJp
          : _ReadMode.bnWordToJp;
    } else {
      _mode = _ReadMode.jpToBn;
    }
    final pool = _heroNumbers.where((e) => e.n != _target.n).toList()
      ..shuffle(_rng);
    setState(() {
      _options = [_target, ...pool.take(3)]..shuffle(_rng);
      _locked = false;
      _pickedN = null;
      _lastWasCorrect = null;
      _showCorrectBanner = false;
      _revealed = false;
    });
    _cardCtrl.forward(from: 0);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _pick(_HeroNum o) {
    if (_locked) return;
    _totalAttempts += 1;
    final ok = o.n == _target.n;
    setState(() {
      _locked = true;
      _pickedN = o.n;
      _lastWasCorrect = ok;
      _revealed = true;
    });
    if (ok) {
      HapticFeedback.mediumImpact();
      setState(() {
        _correct += 1;
        _streak += 1;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _xp += 10;
        _showCorrectBanner = true;
      });
      _confetti.play();
      // ignore: discarded_futures
      _speakTarget();
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(() {
          _showCorrectBanner = false;
          _pickedN = null;
          _lastWasCorrect = null;
          _locked = false;
        });
        if (_roundIdx >= _totalRounds - 1) {
          _sessionTimer.stop();
          _xp += _sessionXpBonus;
          _showSessionEnd();
        } else {
          _roundIdx += 1;
          _buildRound();
        }
      });
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _streak = 0;
        _missed[_target.n] = (_missed[_target.n] ?? 0) + 1;
      });
      _shakeCtrl.forward(from: 0);
      // brief flash, then unlock so the user can try again or continue
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          _pickedN = null;
          _lastWasCorrect = null;
          _locked = false;
          _revealed = false;
        });
      });
    }
  }

  void _showSessionEnd() {
    final acc = _totalAttempts == 0
        ? 0
        : ((_correct * 100) / _totalAttempts).round();
    _showAwesomeResult(
      context: context,
      title: 'পড়া মাস্টার — সেশন শেষ',
      scoreLabel: 'মোট XP: $_xp',
      stats: [
        'সঠিক: $_correct/$_totalRounds',
        'নির্ভুলতা: $acc%',
        'সেশন বোনাস: +$_sessionXpBonus XP',
        'সেরা স্ট্রিক: $_bestStreak',
        'সময়: ${_formatDuration(_sessionTimer.elapsed)}',
      ],
      missedLines: _missed.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
      onPlayAgain: _newSession,
    );
  }

  @override
  void dispose() {
    _confetti.dispose();
    _shakeCtrl.dispose();
    _cardCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  // ─── Mode-aware getters ─────────────────────────────────────────────
  String get _modeBadge => switch (_mode) {
        _ReadMode.bnDigitToJp => 'BN → JP',
        _ReadMode.bnWordToJp => 'BN → JP',
        _ReadMode.jpToBn => 'JP → BN',
      };

  String get _questionText => switch (_mode) {
        _ReadMode.bnDigitToJp =>
          'এটি জাপানিতে কী বলব? — সঠিক উত্তর কোনটি?',
        _ReadMode.bnWordToJp =>
          'এটি জাপানিতে কী বলব? — সঠিক উত্তর কোনটি?',
        _ReadMode.jpToBn => 'এটি বাংলায় কী? — সঠিক উত্তর কোনটি?',
      };

  bool get _isJpToBn => _mode == _ReadMode.jpToBn;

  @override
  Widget build(BuildContext context) {
    final progress = (_roundIdx + 1) / _totalRounds;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  maxBlastForce: 16,
                  minBlastForce: 6,
                  emissionFrequency: 0.08,
                  numberOfParticles: 14,
                  gravity: 0.22,
                  shouldLoop: false,
                  colors: const [
                    Color(0xFFFFE000),
                    Color(0xFF10B981),
                    _violet,
                    Color(0xFF3B82F6),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              // ── Header panel ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _violet.withValues(alpha: 0.45)),
                  boxShadow: [
                    BoxShadow(
                      color: _violet.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book_rounded,
                            color: _violet, size: 22),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'পড়া মাস্টার — পড়ে বুঝে সঠিক উত্তর বাছুন',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 13),
                          ),
                        ),
                        Text(
                          _formatDuration(_sessionTimer.elapsed),
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(99),
                      value: progress.clamp(0, 1),
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(_violet),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'রাউন্ড ${_roundIdx + 1}/$_totalRounds',
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        Text('XP: $_xp',
                            style: const TextStyle(
                                color: Color(0xFFFFE000),
                                fontWeight: FontWeight.w900)),
                        const SizedBox(width: 10),
                        Text('স্ট্রিক: $_streak',
                            style: TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Prompt card with mode-aware content ────────────────
              AnimatedBuilder(
                animation: _shakeCtrl,
                builder: (context, child) {
                  final t = _shakeCtrl.value;
                  final dx = math.sin(t * math.pi * 6) * 10 * (1 - t);
                  return Transform.translate(
                      offset: Offset(dx, 0), child: child);
                },
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.94, end: 1.0).animate(
                      CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutBack)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.card, AppColors.card],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _violet.withValues(alpha: 0.55), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _violet.withValues(alpha: 0.22),
                          blurRadius: 26,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Mode badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_violet, _violetDark],
                            ),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            _modeBadge,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _isJpToBn ? 'জাপানি উচ্চারণ পড়ুন' : 'বাংলা পড়ুন',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPromptBody(),
                        if (_revealed && _lastWasCorrect == true) ...[
                          const SizedBox(height: 14),
                          _buildAnswerReveal(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),
              // ── Question line ──────────────────────────────────────
              Text(
                _questionText,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),

              // ── Options ────────────────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    for (int _i = 0; _i < _options.length; _i++) ...[
                      if (_i != 0) const SizedBox(height: 10),
                      _buildOptionTile(_options[_i]),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // ── Correct banner ───────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              offset: _showCorrectBanner ? Offset.zero : const Offset(0, 1.2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: _showCorrectBanner ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !_showCorrectBanner,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.thumb_up_alt_rounded,
                                color: AppColors.textPrimary, size: 26),
                            const SizedBox(width: 10),
                            const Text(
                              'সঠিক!',
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22),
                            ),
                            const Spacer(),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: Icon(
                                    Icons.star_rounded,
                                    color: i < math.min(5, _streak)
                                        ? const Color(0xFFFFE000)
                                        : AppColors.border,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_target.kanji} ${_target.kana} (${_target.bnPronunciation}) → ${_target.bnDigit} ${_target.bnWord}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
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

  Widget _buildPromptBody() {
    switch (_mode) {
      case _ReadMode.bnDigitToJp:
        return Text(
          _target.bnDigit,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 84,
            fontWeight: FontWeight.w900,
            height: 1.0,
          ),
        );
      case _ReadMode.bnWordToJp:
        return Text(
          _target.bnWord,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 56,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        );
      case _ReadMode.jpToBn:
        return Text(
          _target.bnPronunciation,
          style: const TextStyle(
            color: Color(0xFFFFE000),
            fontSize: 56,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        );
    }
  }

  Widget _buildAnswerReveal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _target.kanji,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _target.kana,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '· ${_target.bnDigit} ${_target.bnWord}',
            style: const TextStyle(
              color: Color(0xFF10B981),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(_HeroNum o) {
    final picked = _pickedN == o.n;
    final isCorrect = o.n == _target.n;
    final revealed = _pickedN != null;

    Color border;
    Color bg;
    Color textColor = AppColors.textPrimary;
    if (!revealed) {
      border = AppColors.border;
      bg = AppColors.bg;
    } else if (isCorrect) {
      border = const Color(0xFF10B981);
      bg = const Color(0xFF10B981).withValues(alpha: 0.22);
      textColor = const Color(0xFF10B981);
    } else if (picked) {
      border = const Color(0xFFEF4444);
      bg = const Color(0xFFEF4444).withValues(alpha: 0.18);
      textColor = const Color(0xFFEF4444);
    } else {
      border = AppColors.border;
      bg = AppColors.bg;
    }

    // Option label depends on mode
    final String optionLabel;
    if (_isJpToBn) {
      optionLabel = '${o.bnDigit}  ${o.bnWord}';
    } else {
      optionLabel = o.bnPronunciation;
    }

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _locked ? null : () => _pick(o),
          child: Ink(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: border,
                width: (picked || (isCorrect && revealed)) ? 2.4 : 1.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  optionLabel,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (revealed && isCorrect) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF10B981), size: 22),
                ] else if (revealed && picked && !isCorrect) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.cancel_rounded,
                      color: Color(0xFFEF4444), size: 22),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// সাজাও — Ordering game: drag JP pronunciations to BN positions 1..10
// ═════════════════════════════════════════════════════════════════════

class _HeroOrderGame extends StatefulWidget {
  const _HeroOrderGame({super.key});

  @override
  State<_HeroOrderGame> createState() => _HeroOrderGameState();
}

class _HeroOrderGameState extends State<_HeroOrderGame>
    with TickerProviderStateMixin {
  static const _teal = Color(0xFF14B8A6);
  static const _tealDark = Color(0xFF0F766E);
  static const _sessionXpBonus = 50;

  final _rng = math.Random();
  late ConfettiController _confetti;
  late AnimationController _shakeCtrl;
  int? _shakeSlot;

  // Slot number (1..10) → placed item (null if empty).
  final Map<int, _HeroNum?> _placed = {};
  // Remaining draggable chips, shuffled.
  late List<_HeroNum> _pool;

  final Stopwatch _sessionTimer = Stopwatch();
  int _correct = 0;
  int _wrongAttempts = 0;
  int _xp = 0;
  int _streak = 0;
  int _bestStreak = 0;
  final Map<int, int> _missed = {};

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 850));
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _newSession();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _newSession() {
    _placed
      ..clear()
      ..addEntries(_heroNumbers.map((h) => MapEntry(h.n, null)));
    _pool = List<_HeroNum>.of(_heroNumbers)..shuffle(_rng);
    _correct = 0;
    _wrongAttempts = 0;
    _xp = 0;
    _streak = 0;
    _bestStreak = 0;
    _missed.clear();
    _sessionTimer
      ..reset()
      ..start();
    setState(() {});
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onDrop(int slotN, _HeroNum chip) {
    if (_placed[slotN] != null) return;
    final ok = chip.n == slotN;
    if (ok) {
      HapticFeedback.mediumImpact();
      setState(() {
        _placed[slotN] = chip;
        _pool.remove(chip);
        _correct += 1;
        _streak += 1;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _xp += 10;
      });
      _confetti.play();
      if (_pool.isEmpty) {
        _sessionTimer.stop();
        _xp += _sessionXpBonus;
        Future.delayed(const Duration(milliseconds: 500), _showSessionEnd);
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _wrongAttempts += 1;
        _streak = 0;
        _missed[slotN] = (_missed[slotN] ?? 0) + 1;
        _shakeSlot = slotN;
      });
      _shakeCtrl.forward(from: 0).whenComplete(() {
        if (!mounted) return;
        setState(() => _shakeSlot = null);
      });
    }
  }

  void _showSessionEnd() {
    final attempts = _correct + _wrongAttempts;
    final acc = attempts == 0 ? 0 : ((_correct * 100) / attempts).round();
    _showAwesomeResult(
      context: context,
      title: 'সাজাও — সেশন শেষ',
      scoreLabel: 'মোট XP: $_xp',
      stats: [
        'সঠিক স্থাপন: $_correct/${_heroNumbers.length}',
        'ভুল চেষ্টা: $_wrongAttempts',
        'নির্ভুলতা: $acc%',
        'সেশন বোনাস: +$_sessionXpBonus XP',
        'সেরা স্ট্রিক: $_bestStreak',
        'সময়: ${_formatDuration(_sessionTimer.elapsed)}',
      ],
      missedLines: _missed.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
      onPlayAgain: _newSession,
    );
  }

  @override
  Widget build(BuildContext context) {
    final placedCount = _correct;
    final progress = placedCount / _heroNumbers.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  maxBlastForce: 16,
                  minBlastForce: 6,
                  emissionFrequency: 0.08,
                  numberOfParticles: 12,
                  gravity: 0.22,
                  shouldLoop: false,
                  colors: const [
                    Color(0xFFFFE000),
                    Color(0xFF10B981),
                    _teal,
                    Color(0xFF3B82F6),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              // ── Header panel ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _teal.withValues(alpha: 0.45)),
                  boxShadow: [
                    BoxShadow(
                      color: _teal.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.format_list_numbered_rounded,
                            color: _teal, size: 22),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'সাজাও — ক্রম অনুযায়ী টেনে বসান',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 13),
                          ),
                        ),
                        Text(
                          _formatDuration(_sessionTimer.elapsed),
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(99),
                      value: progress.clamp(0, 1),
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(_teal),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'স্থাপন: $placedCount/${_heroNumbers.length}',
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        Text('XP: $_xp',
                            style: const TextStyle(
                                color: Color(0xFFFFE000),
                                fontWeight: FontWeight.w900)),
                        const SizedBox(width: 10),
                        Text('স্ট্রিক: $_streak',
                            style: TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Slots grid (5 rows x 2 cols = 10) ─────────────────
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _heroNumbers.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 64,
                  ),
                  itemBuilder: (_, i) {
                    final h = _heroNumbers[i];
                    return _buildSlot(h);
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ── Chip pool ─────────────────────────────────────────
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 90),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppColors.bg),
                ),
                child: _pool.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'সব ঠিকঠাক সাজানো হয়েছে! 🎉',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final chip in _pool) _buildChip(chip),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Slot widget (drop target) ───────────────────────────────────────
  Widget _buildSlot(_HeroNum h) {
    final placed = _placed[h.n];
    final isFilled = placed != null;
    final isShaking = _shakeSlot == h.n;

    return AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (context, child) {
        final t = isShaking ? _shakeCtrl.value : 0.0;
        final dx = math.sin(t * math.pi * 6) * 8 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: DragTarget<_HeroNum>(
        onWillAcceptWithDetails: (_) => !isFilled,
        onAcceptWithDetails: (d) => _onDrop(h.n, d.data),
        builder: (context, candidate, rejected) {
          final hovering = candidate.isNotEmpty;
          Color border;
          Color bg;
          if (isFilled) {
            border = const Color(0xFF10B981);
            bg = const Color(0xFF10B981).withValues(alpha: 0.18);
          } else if (hovering) {
            border = _teal;
            bg = _teal.withValues(alpha: 0.18);
          } else {
            border = AppColors.border;
            bg = AppColors.bg;
          }
          return AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: border,
                width: hovering || isFilled ? 2.2 : 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: isFilled
                        ? const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)])
                        : const LinearGradient(
                            colors: [_teal, _tealDark]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    h.bnDigit,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: isFilled
                      ? Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    placed.bnPronunciation,
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      height: 1.0,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${placed.kanji}  ${placed.kana}',
                                    style: TextStyle(
                                      color: AppColors.border,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      height: 1.0,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF10B981), size: 20),
                          ],
                        )
                      : Text(
                          hovering ? 'এখানে বসান' : 'এখানে টেনে আনুন',
                          style: TextStyle(
                            color: hovering
                                ? _teal
                                : AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Draggable chip ────────────────────────────────────────────────
  Widget _buildChip(_HeroNum h) {
    final chipWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_teal, _tealDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: _teal.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        h.bnPronunciation,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    return Draggable<_HeroNum>(
      data: h,
      onDragStarted: HapticFeedback.selectionClick,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.15,
          child: Opacity(opacity: 0.95, child: chipWidget),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: chipWidget,
      ),
      child: chipWidget,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// ১-১০ বলো — Speak the entire sequence 1..10 in Japanese in one go
// STT listens, then per-position evaluation (correct/wrong/missed)
// ═════════════════════════════════════════════════════════════════════

enum _SeqStatus { pending, correct, wrong, missed, extra }

class _SeqEvalEntry {
  const _SeqEvalEntry({required this.expected, required this.heard, required this.status});
  final _HeroNum expected;
  final int? heard; // heard number (1..10) or null if missed
  final _SeqStatus status;
}

class _HeroSpeakSequenceGame extends StatefulWidget {
  const _HeroSpeakSequenceGame({super.key});

  @override
  State<_HeroSpeakSequenceGame> createState() => _HeroSpeakSequenceGameState();
}

class _HeroSpeakSequenceGameState extends State<_HeroSpeakSequenceGame>
    with TickerProviderStateMixin {
  static const _rose = Color(0xFFE11D48);
  static const _roseDark = Color(0xFFBE123C);

  final _stt = JlcStt();
  final _tts = JlcTts();
  bool _sttReady = false;
  bool _ttsReady = false;
  String? _locale;
  String? _error;

  bool _listening = false;
  String _heard = '';
  double _soundLevel = 0;
  int _secondsLeft = 0;
  Timer? _recordTimer;
  static const _maxSeconds = 25;

  late List<_SeqEvalEntry> _results;
  List<int> _extras = const [];
  bool _evaluated = false;

  int _xp = 0;
  int _attempts = 0;
  int _bestCorrect = 0;
  final Stopwatch _sessionTimer = Stopwatch();

  late ConfettiController _confetti;
  late AnimationController _pulseCtrl;
  late AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _results = _heroNumbers
        .map((h) =>
            _SeqEvalEntry(expected: h, heard: null, status: _SeqStatus.pending))
        .toList();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 900));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _waveCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
    _sessionTimer.start();
    _initTts();
    _initStt();
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _confetti.dispose();
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _stt.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.05);
      await _tts.prefetchTexts(
        _heroNumbers.expand((h) => <String>[h.kana, '${h.kana}。']),
      );
      if (mounted) setState(() => _ttsReady = true);
    } catch (_) {}
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
        setState(() => _sttReady = false);
        return;
      }
      final locales = await _stt.locales();
      final ja =
          locales.where((l) => l.localeId.toLowerCase().startsWith('ja'));
      setState(() {
        _locale = ja.isNotEmpty
            ? ja.first.localeId
            : (locales.isNotEmpty ? locales.first.localeId : null);
        _sttReady = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sttReady = false;
        _error = '$e';
      });
    }
  }

  // ─── Token → number matcher ───────────────────────────────────────
  static int? _matchToken(String s) {
    switch (s) {
      case 'ichi':
      case 'いち':
      case 'イチ':
      case '一':
      case '1':
      case '১':
        return 1;
      case 'ni':
      case 'に':
      case 'ニ':
      case '二':
      case '2':
      case '২':
        return 2;
      case 'san':
      case 'sun':
      case 'さん':
      case 'サン':
      case '三':
      case '3':
      case '৩':
        return 3;
      case 'yon':
      case 'shi':
      case 'yo':
      case 'よん':
      case 'ヨン':
      case 'し':
      case 'シ':
      case '四':
      case '4':
      case '৪':
        return 4;
      case 'go':
      case 'ご':
      case 'ゴ':
      case '五':
      case '5':
      case '৫':
        return 5;
      case 'roku':
      case 'ろく':
      case 'ロク':
      case '六':
      case '6':
      case '৬':
        return 6;
      case 'nana':
      case 'shichi':
      case 'なな':
      case 'ナナ':
      case 'しち':
      case 'シチ':
      case '七':
      case '7':
      case '৭':
        return 7;
      case 'hachi':
      case 'はち':
      case 'ハチ':
      case '八':
      case '8':
      case '৮':
        return 8;
      case 'kyu':
      case 'kyuu':
      case 'kyou':
      case 'ku':
      case 'きゅう':
      case 'キュウ':
      case 'きゅ':
      case 'く':
      case 'ク':
      case '九':
      case '9':
      case '৯':
        return 9;
      case 'ju':
      case 'juu':
      case 'jyu':
      case 'jyuu':
      case 'jou':
      case 'zyu':
      case 'zyuu':
      case 'じゅう':
      case 'ジュウ':
      case 'じゅ':
      case 'ジュ':
      case 'じょう':
      case 'ジョウ':
      case 'じょ':
      case 'ジョ':
      case '十':
      case '拾':
      case '10':
      case '১০':
        return 10;
    }
    return null;
  }

  // Normalize STT output for robust matching.
  // - Lowercase ASCII
  // - Fullwidth digits (０-９) → halfwidth (0-9)
  // - Strip Japanese long-vowel mark "ー"
  // - Small kana (ぁぃぅぇぉ etc.) → large equivalents
  static String _normalize(String s) {
    var out = s.toLowerCase();
    final buf = StringBuffer();
    for (final r in out.runes) {
      // Fullwidth digit → halfwidth
      if (r >= 0xFF10 && r <= 0xFF19) {
        buf.writeCharCode(r - 0xFF10 + 0x30);
        continue;
      }
      // Skip long vowel mark
      if (r == 0x30FC) continue;
      // Small hiragana → big
      const smallToBig = {
        0x3041: 0x3042, // ぁ→あ
        0x3043: 0x3044, // ぃ→い
        0x3045: 0x3046, // ぅ→う
        0x3047: 0x3048, // ぇ→え
        0x3049: 0x304A, // ぉ→お
        // Small katakana → big
        0x30A1: 0x30A2, // ァ→ア
        0x30A3: 0x30A4, // ィ→イ
        0x30A5: 0x30A6, // ゥ→ウ
        0x30A7: 0x30A8, // ェ→エ
        0x30A9: 0x30AA, // ォ→オ
      };
      buf.writeCharCode(smallToBig[r] ?? r);
    }
    return buf.toString();
  }

  List<int> _parseHeard(String raw) {
    final cleaned = _normalize(raw)
        .replaceAll(RegExp(r'[、。,.!?・〜\-‐–—()\[\]「」]'), ' ');
    final tokens =
        cleaned.split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
    final out = <int>[];
    for (final t in tokens) {
      final exact = _matchToken(t);
      if (exact != null) {
        out.add(exact);
        continue;
      }
      // Greedy substring match for concatenated kana/kanji (e.g. "いちにさん").
      int i = 0;
      while (i < t.length) {
        bool matched = false;
        final maxLen = math.min(6, t.length - i);
        for (int len = maxLen; len >= 1 && !matched; len--) {
          final sub = t.substring(i, i + len);
          final n = _matchToken(sub);
          if (n != null) {
            out.add(n);
            i += len;
            matched = true;
          }
        }
        if (!matched) i++;
      }
    }
    return out;
  }

  void _evaluate(List<int> heard) {
    final entries = <_SeqEvalEntry>[];
    int correctCount = 0;
    for (var i = 0; i < _heroNumbers.length; i++) {
      final expected = _heroNumbers[i];
      if (i >= heard.length) {
        entries.add(_SeqEvalEntry(
            expected: expected, heard: null, status: _SeqStatus.missed));
        continue;
      }
      final h = heard[i];
      if (h == expected.n) {
        entries.add(_SeqEvalEntry(
            expected: expected, heard: h, status: _SeqStatus.correct));
        correctCount++;
      } else {
        entries.add(_SeqEvalEntry(
            expected: expected, heard: h, status: _SeqStatus.wrong));
      }
    }
    final extras = heard.length > _heroNumbers.length
        ? heard.sublist(_heroNumbers.length)
        : const <int>[];

    _attempts += 1;
    if (correctCount > _bestCorrect) _bestCorrect = correctCount;
    // XP: +10 per correct slot, +50 bonus for perfect run.
    final delta = correctCount * 10 + (correctCount == 10 ? 50 : 0);
    _xp += delta;

    setState(() {
      _results = entries;
      _extras = extras;
      _evaluated = true;
    });

    if (correctCount == 10 && extras.isEmpty) {
      HapticFeedback.heavyImpact();
      _confetti.play();
    } else if (correctCount >= 7) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _startListening() async {
    if (_listening) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _heard = '';
      _error = null;
      _evaluated = false;
      _extras = const [];
      _results = _heroNumbers
          .map((h) => _SeqEvalEntry(
              expected: h, heard: null, status: _SeqStatus.pending))
          .toList();
      _secondsLeft = _maxSeconds;
      _soundLevel = 0;
    });
    try {
      if (!_sttReady) {
        await _initStt();
      }
      if (!_sttReady) {
        throw Exception('Speech recognition এই ডিভাইসে কাজ করছে না।');
      }
      await _stt.listen(
        localeId: _locale,
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
        listenFor: const Duration(seconds: _maxSeconds),
        pauseFor: const Duration(seconds: 4),
        onResult: (JlcSttResult r) {
          if (!mounted) return;
          setState(() => _heard = r.recognizedWords);
        },
        onSoundLevelChange: (level) {
          if (!mounted) return;
          setState(() => _soundLevel = level);
        },
      );
      if (!mounted) return;
      setState(() => _listening = true);
      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
        if (!mounted || !_listening) return;
        if (_secondsLeft <= 1) {
          await _stopAndEvaluate();
          return;
        }
        setState(() => _secondsLeft -= 1);
      });
    } catch (e) {
      if (!mounted) return;
      _recordTimer?.cancel();
      setState(() {
        _listening = false;
        _error = '$e';
      });
    }
  }

  Future<void> _stopAndEvaluate() async {
    if (!_listening) return;
    _recordTimer?.cancel();
    HapticFeedback.selectionClick();
    await _stt.stop();
    if (!mounted) return;
    setState(() {
      _listening = false;
      _secondsLeft = 0;
      _soundLevel = 0;
    });
    final parsed = _parseHeard(_heard);
    _evaluate(parsed);
  }

  Future<void> _speakSequence() async {
    if (!_ttsReady) return;
    HapticFeedback.selectionClick();
    await _tts.stop();
    for (final h in _heroNumbers) {
      if (!mounted) return;
      await _tts.speak(h.kana);
      await Future.delayed(const Duration(milliseconds: 320));
    }
  }

  Future<void> _speakMistakes() async {
    if (!_ttsReady) return;
    HapticFeedback.selectionClick();
    await _tts.stop();
    final mistakes = _results.where(
        (r) => r.status == _SeqStatus.wrong || r.status == _SeqStatus.missed);
    for (final r in mistakes) {
      if (!mounted) return;
      await _tts.speak(r.expected.kana);
      await Future.delayed(const Duration(milliseconds: 380));
    }
  }

  // ─── UI ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final correctCount =
        _results.where((r) => r.status == _SeqStatus.correct).length;
    final wrongCount =
        _results.where((r) => r.status == _SeqStatus.wrong).length;
    final missedCount =
        _results.where((r) => r.status == _SeqStatus.missed).length;
    final accuracy =
        _evaluated ? ((correctCount * 100) / _heroNumbers.length).round() : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  maxBlastForce: 18,
                  minBlastForce: 6,
                  emissionFrequency: 0.08,
                  numberOfParticles: 18,
                  gravity: 0.22,
                  shouldLoop: false,
                  colors: const [
                    Color(0xFFFFE000),
                    Color(0xFF10B981),
                    _rose,
                    Color(0xFF3B82F6),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              _buildHeader(correctCount, accuracy),
              const SizedBox(height: 12),
              _buildMicCard(),
              const SizedBox(height: 12),
              if (_evaluated)
                _buildResultsSummary(correctCount, wrongCount, missedCount),
              if (_evaluated) const SizedBox(height: 10),
              Expanded(child: _buildPositionGrid()),
              if (_evaluated) ...[
                const SizedBox(height: 10),
                _buildActionRow(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int correctCount, int accuracy) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rose.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: _rose.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.record_voice_over_rounded,
                  color: _rose, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '১-১০ বলো — এক টানে জাপানিতে বলুন',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 13),
                ),
              ),
              if (_listening)
                Text(
                  '$_secondsLeft s',
                  style: const TextStyle(
                    color: _rose,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            minHeight: 8,
            borderRadius: BorderRadius.circular(99),
            value: _evaluated ? correctCount / _heroNumbers.length : 0,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(_rose),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _evaluated
                    ? 'সঠিক: $correctCount/${_heroNumbers.length}'
                    : 'মাইক চাপুন',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text('XP: $_xp',
                  style: const TextStyle(
                      color: Color(0xFFFFE000),
                      fontWeight: FontWeight.w900)),
              const SizedBox(width: 10),
              Text(
                'সেরা: $_bestCorrect/10',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
          if (_evaluated)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'নির্ভুলতা: $accuracy%',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMicCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.card, AppColors.card],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _rose.withValues(alpha: 0.55), width: 2),
        boxShadow: [
          BoxShadow(
            color: _rose.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!_listening && !_evaluated)
            Text(
              'ইচি, নি, সান, ইয়োন … জু — সব এক সাথে বলুন',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _listening ? _stopAndEvaluate : _startListening,
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (context, _) {
                final scale = _listening
                    ? 1 + (_pulseCtrl.value * 0.08) + (_soundLevel.clamp(0, 10) / 60)
                    : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _listening
                            ? const [Color(0xFFEF4444), Color(0xFFB91C1C)]
                            : const [_rose, _roseDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_listening ? const Color(0xFFEF4444) : _rose)
                              .withValues(alpha: 0.5),
                          blurRadius: 22,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _listening
                          ? Icons.stop_rounded
                          : Icons.mic_rounded,
                      color: AppColors.textPrimary,
                      size: 38,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _listening ? 'শুনছি — বলতে থাকুন…' : (_evaluated ? 'আবার চেষ্টা করতে মাইক চাপুন' : 'মাইক চাপুন'),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          if (_heard.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.border),
              ),
              child: Text(
                _heard,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFFE000),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsSummary(int correct, int wrong, int missed) {
    return Row(
      children: [
        _summaryChip(
            label: 'সঠিক', value: '$correct', color: const Color(0xFF10B981)),
        const SizedBox(width: 8),
        _summaryChip(
            label: 'ভুল', value: '$wrong', color: const Color(0xFFEF4444)),
        const SizedBox(width: 8),
        _summaryChip(
            label: 'বাদ', value: '$missed', color: const Color(0xFFF59E0B)),
        if (_extras.isNotEmpty) ...[
          const SizedBox(width: 8),
          _summaryChip(
              label: 'অতিরিক্ত',
              value: '${_extras.length}',
              color: const Color(0xFF8B5CF6)),
        ],
      ],
    );
  }

  Widget _summaryChip(
      {required String label, required String value, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900)),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionGrid() {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _results.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 78,
      ),
      itemBuilder: (_, i) => _buildPositionTile(_results[i]),
    );
  }

  Widget _buildPositionTile(_SeqEvalEntry r) {
    Color color;
    IconData icon;
    String detail;
    switch (r.status) {
      case _SeqStatus.correct:
        color = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
        detail = 'বলেছেন ✓';
        break;
      case _SeqStatus.wrong:
        final heardItem =
            _heroNumbers.firstWhere((h) => h.n == r.heard, orElse: () => r.expected);
        color = const Color(0xFFEF4444);
        icon = Icons.cancel_rounded;
        detail = 'বলেছেন: ${heardItem.bnPronunciation}';
        break;
      case _SeqStatus.missed:
        color = const Color(0xFFF59E0B);
        icon = Icons.remove_circle_outline_rounded;
        detail = 'বাদ পড়েছে';
        break;
      case _SeqStatus.pending:
        color = AppColors.border;
        icon = Icons.radio_button_unchecked_rounded;
        detail = 'অপেক্ষমাণ';
        break;
      case _SeqStatus.extra:
        color = const Color(0xFF8B5CF6);
        icon = Icons.add_circle_outline_rounded;
        detail = 'অতিরিক্ত';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              r.expected.bnDigit,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  r.expected.bnPronunciation,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(icon, color: color, size: 22),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _ttsReady ? _speakSequence : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: AppColors.textMuted),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.volume_up_rounded),
            label: const Text('সব শুনুন',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _ttsReady ? _speakMistakes : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _rose,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.school_rounded),
            label: const Text('ভুলগুলি শুনুন',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.score, required this.lives});
  final int score;
  final int lives;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDeco(),
      child: Row(
        children: [
          const Icon(Icons.score_rounded, color: Color(0xFFFFE000), size: 18),
          const SizedBox(width: 6),
          Text('স্কোর: $score',
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900)),
          const Spacer(),
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(Icons.favorite_rounded,
                  size: 18, color: i < lives ? const Color(0xFFEF4444) : const Color(0xFF94A3B8)),
            )
        ],
      ),
    );
  }
}

void _showAwesomeResult({
  required BuildContext context,
  required String title,
  required String scoreLabel,
  required List<String> stats,
  required List<MapEntry<int, int>> missedLines,
  required VoidCallback onPlayAgain,
}) {
  final missed = <String>[];
  for (final e in missedLines.take(6)) {
    final it = _heroNumbers.firstWhere((x) => x.n == e.key);
    missed.add('${it.kanji} ${it.kana} (${it.bnPronunciation}) → ${it.bnDigit} ${it.bnWord}  ×${e.value}');
  }
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _AwesomeResultSheet(
      title: title,
      scoreLabel: scoreLabel,
      stats: stats,
      missed: missed,
      onPlayAgain: onPlayAgain,
    ),
  );
}

class _AwesomeResultSheet extends StatelessWidget {
  const _AwesomeResultSheet({
    required this.title,
    required this.scoreLabel,
    required this.stats,
    required this.missed,
    required this.onPlayAgain,
  });

  final String title;
  final String scoreLabel;
  final List<String> stats;
  final List<String> missed;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1326),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFFE000).withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 12),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFE000)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 16)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scoreLabel,
                      style: const TextStyle(color: Color(0xFFFFE000), fontWeight: FontWeight.w900, fontSize: 22)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in stats)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(s,
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (missed.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('যেগুলো মিস হয়েছে',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              for (final m in missed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(m,
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
                  ),
                ),
            ],
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onPlayAgain();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFE000),
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('আবার খেলি', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _cardDeco() => BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    );
