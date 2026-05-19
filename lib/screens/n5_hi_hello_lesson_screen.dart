// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class N5HiHelloLessonScreen extends StatefulWidget {
  const N5HiHelloLessonScreen({super.key});

  @override
  State<N5HiHelloLessonScreen> createState() => _N5HiHelloLessonScreenState();
}

enum _HiTab { flashcard, quiz, match, rush, listen, read, speak }

class _N5HiHelloLessonScreenState extends State<N5HiHelloLessonScreen> {
  static const _tabs = [
    _HiTab.listen,
    _HiTab.read,
    _HiTab.speak,
    _HiTab.flashcard,
    _HiTab.quiz,
    _HiTab.match,
    _HiTab.rush,
  ];
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
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
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('জাপানিজে হাই-হ্যালো',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                        Text('দৈনন্দিন জাপানি বাক্য: Japanese -> বাংলা',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.74),
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
              child: _HiTabPills(index: _tab, onChange: (i) => setState(() => _tab = i)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: switch (_tabs[_tab]) {
                  _HiTab.flashcard => const _HiFlashGame(key: ValueKey('hiFlash')),
                  _HiTab.quiz => const _HiQuizGame(key: ValueKey('hiQuiz')),
                  _HiTab.match => const _HiMatchGame(key: ValueKey('hiMatch')),
                  _HiTab.rush => const _HiRushGame(key: ValueKey('hiRush')),
                  _HiTab.listen => const _HiListenGame(key: ValueKey('hiListen')),
                  _HiTab.read => const _HiReadGame(key: ValueKey('hiRead')),
                  _HiTab.speak => const _HiSpeakGame(key: ValueKey('hiSpeak')),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Phrase {
  const _Phrase({required this.jp, required this.romaji, required this.bnPronunciation, required this.bn});
  final String jp;
  final String romaji;
  final String bnPronunciation;
  final String bn;
}

const _phrases = <_Phrase>[
  _Phrase(jp: 'おはよう', romaji: 'ohayou', bnPronunciation: 'ওহাইও', bn: 'সুপ্রভাত'),
  _Phrase(jp: 'こんにちは', romaji: 'konnichiwa', bnPronunciation: 'কোন্নিচিওয়া', bn: 'হ্যালো / শুভ দুপুর'),
  _Phrase(jp: 'こんばんは', romaji: 'konbanwa', bnPronunciation: 'কোনবানওয়া', bn: 'শুভ সন্ধ্যা'),
  _Phrase(jp: 'ありがとう', romaji: 'arigatou', bnPronunciation: 'আরিগাতো', bn: 'ধন্যবাদ'),
  _Phrase(jp: 'すみません', romaji: 'sumimasen', bnPronunciation: 'সুমিমাসেন', bn: 'মাফ করবেন'),
  _Phrase(jp: 'ごめんなさい', romaji: 'gomennasai', bnPronunciation: 'গোমেন নাসাই', bn: 'দুঃখিত'),
  _Phrase(jp: 'はい', romaji: 'hai', bnPronunciation: 'হাই', bn: 'হ্যাঁ'),
  _Phrase(jp: 'いいえ', romaji: 'iie', bnPronunciation: 'ইইয়ে', bn: 'না'),
  _Phrase(jp: 'またね', romaji: 'matane', bnPronunciation: 'মাতানে', bn: 'আবার দেখা হবে'),
  _Phrase(jp: 'さようなら', romaji: 'sayounara', bnPronunciation: 'সায়োনারা', bn: 'বিদায়'),
];

// ─── Time-of-day greetings (used by শুনে বলো / পড়ে বলো / বলে দেখাও) ──
class _TimeGreeting {
  const _TimeGreeting({
    required this.id,
    required this.jp,
    required this.romaji,
    required this.bnPron,
    required this.bnMeaning,
    required this.timeLabel,
    required this.icon,
    required this.color,
  });
  final int id;
  final String jp;
  final String romaji;
  final String bnPron;
  final String bnMeaning;
  final String timeLabel;
  final IconData icon;
  final Color color;
}

const _timeGreetings = <_TimeGreeting>[
  _TimeGreeting(
    id: 0,
    jp: 'おはようございます',
    romaji: 'ohayou gozaimasu',
    bnPron: 'ওহাইও গোজাইমাস',
    bnMeaning: 'শুভ সকাল',
    timeLabel: 'সকাল',
    icon: Icons.wb_sunny_rounded,
    color: Color(0xFFFBBF24),
  ),
  _TimeGreeting(
    id: 1,
    jp: 'こんにちは',
    romaji: 'konnichiwa',
    bnPron: 'কোন্নিচিওয়া',
    bnMeaning: 'শুভ দুপুর',
    timeLabel: 'দুপুর',
    icon: Icons.wb_twilight_rounded,
    color: Color(0xFFF97316),
  ),
  _TimeGreeting(
    id: 2,
    jp: 'こんばんは',
    romaji: 'konbanwa',
    bnPron: 'কোনবানওয়া',
    bnMeaning: 'শুভ সন্ধ্যা',
    timeLabel: 'সন্ধ্যা',
    icon: Icons.nights_stay_rounded,
    color: Color(0xFFA855F7),
  ),
  _TimeGreeting(
    id: 3,
    jp: 'おやすみなさい',
    romaji: 'oyasumi nasai',
    bnPron: 'ওইয়াসুমি নাসাই',
    bnMeaning: 'শুভ রাত্রি',
    timeLabel: 'রাত',
    icon: Icons.bedtime_rounded,
    color: Color(0xFF3B82F6),
  ),
];

// Read-game scenarios. answerId references _timeGreetings.id.
class _ReadScenario {
  const _ReadScenario({
    required this.scene,
    required this.icon,
    required this.color,
    required this.answerId,
    this.trick,
  });
  final String scene;
  final IconData icon;
  final Color color;
  final int answerId;
  final String? trick;
}

const _readScenarios = <_ReadScenario>[
  _ReadScenario(
    scene: 'সকাল ৮টা — কী বলবেন?',
    icon: Icons.wb_sunny_rounded,
    color: Color(0xFFFBBF24),
    answerId: 0,
  ),
  _ReadScenario(
    scene: 'দুপুর ১২টা (সাধারণ) — কী বলবেন?',
    icon: Icons.wb_twilight_rounded,
    color: Color(0xFFF97316),
    answerId: 1,
  ),
  _ReadScenario(
    scene: 'অফিসে সহকর্মীর সাথে দিনের প্রথম দেখা (দুপুর ১টা) — কী বলবেন?',
    icon: Icons.business_center_rounded,
    color: Color(0xFFFBBF24),
    answerId: 0,
    trick: 'অফিসের নিয়ম: দিনের প্রথম দেখায় সবসময় Ohayo gozaimasu!',
  ),
  _ReadScenario(
    scene: 'সূর্যাস্তের পর / সন্ধ্যা ৭টা — কী বলবেন?',
    icon: Icons.nights_stay_rounded,
    color: Color(0xFFA855F7),
    answerId: 2,
  ),
  _ReadScenario(
    scene: 'ঘুমাতে যাওয়ার আগে — কী বলবেন?',
    icon: Icons.bedtime_rounded,
    color: Color(0xFF3B82F6),
    answerId: 3,
  ),
  _ReadScenario(
    scene: 'অফিসে বসের সাথে বিকাল ৩টায় প্রথম দেখা — কী বলবেন?',
    icon: Icons.business_center_rounded,
    color: Color(0xFFFBBF24),
    answerId: 0,
    trick: 'বিকেলেও অফিসে প্রথম দেখায় Ohayo gozaimasu!',
  ),
];

class _HiTabPills extends StatelessWidget {
  const _HiTabPills({required this.index, required this.onChange});
  final int index;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    const labels = [
      'শুনে বলো',
      'পড়ে বলো',
      'বলে দেখাও',
      'ফ্ল্যাশকার্ড',
      'কুইজ রান',
      'ফ্রেজ ম্যাচ',
      'রাশ বস',
    ];
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
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

class _HiFlashGame extends StatefulWidget {
  const _HiFlashGame({super.key});
  @override
  State<_HiFlashGame> createState() => _HiFlashGameState();
}

class _HiFlashGameState extends State<_HiFlashGame>
    with TickerProviderStateMixin {
  final _tts = FlutterTts();
  late ConfettiController _confetti;
  bool _ttsReady = false;
  bool _slowMode = false;
  int _index = 0;
  bool _front = true;
  double _flipTurns = 0;
  int _xp = 0;
  int _flips = 0;
  final Set<int> _seen = {};
  bool _doneShown = false;

  _Phrase get _item => _phrases[_index];

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 700));
    _initTts();
    _seen.add(0);
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(_slowMode ? 0.32 : 0.50);
      await _tts.setPitch(1.05);
      if (!mounted) return;
      setState(() => _ttsReady = true);
    } catch (_) {}
  }

  Future<void> _speak() async {
    if (!_ttsReady) return;
    await _tts.stop();
    await _tts.setSpeechRate(_slowMode ? 0.32 : 0.50);
    await _tts.speak(_item.jp);
  }

  void _flip() {
    HapticFeedback.selectionClick();
    setState(() {
      _front = !_front;
      _flipTurns += math.pi;
      _flips += 1;
      _seen.add(_index);
    });
    if (!_front) {
      // ignore: discarded_futures
      _speak();
    }
  }

  void _go(int delta) {
    final next = (_index + delta).clamp(0, _phrases.length - 1);
    if (next == _index) return;
    HapticFeedback.lightImpact();
    setState(() {
      _index = next;
      _front = true;
      _flipTurns = 0;
      if (_seen.add(_index)) _xp += 10;
    });
    if (_seen.length == _phrases.length && !_doneShown) {
      _doneShown = true;
      _confetti.play();
      HapticFeedback.mediumImpact();
    }
    // ignore: discarded_futures
    _speak();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _seen.length / _phrases.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: SizedBox(
                height: 130,
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
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: _deco(),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.style_rounded, color: Color(0xFFFFE000)),
                        const SizedBox(width: 8),
                        Text('কার্ড ${_index + 1}/${_phrases.length}',
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w900)),
                        const SizedBox(width: 10),
                        _HiStatChip(label: 'XP', value: '$_xp'),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: _seen.isEmpty
                              ? null
                              : () => _showHiAwesomeResult(
                                    context: context,
                                    title: 'ফ্ল্যাশকার্ড — রিভিউ',
                                    scoreLabel: 'XP: $_xp',
                                    stats: [
                                      'কার্ড দেখা: ${_seen.length}/${_phrases.length}',
                                      'ফ্লিপ: $_flips',
                                    ],
                                    missed: const [],
                                    onPlayAgain: () {
                                      setState(() {
                                        _xp = 0;
                                        _flips = 0;
                                        _seen.clear();
                                        _seen.add(0);
                                        _index = 0;
                                        _front = true;
                                        _flipTurns = 0;
                                        _doneShown = false;
                                      });
                                    },
                                  ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.22)),
                          ),
                          child: const Text('রিভিউ',
                              style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(99),
                      value: progress.clamp(0, 1),
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFFFFE000)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _flip,
                  child: Container(
                    width: double.infinity,
                    decoration: _deco(radius: 22),
                    child: Stack(
                      children: [
                        Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, anim) {
                              return FadeTransition(
                                opacity: anim,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.94, end: 1.0)
                                      .animate(CurvedAnimation(
                                          parent: anim,
                                          curve: Curves.easeOutCubic)),
                                  child: child,
                                ),
                              );
                            },
                            child: _HiFlipFace(
                              key: ValueKey(_index),
                              item: _item,
                              turns: _flipTurns,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  setState(() => _slowMode = !_slowMode);
                                  await _speak();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _slowMode
                                        ? const Color(0xFFFFE000)
                                        : Colors.white.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.2)),
                                  ),
                                  child: Icon(Icons.pets_rounded,
                                      size: 18,
                                      color: _slowMode
                                          ? const Color(0xFF1E293B)
                                          : Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _speak,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE000)
                                        .withValues(alpha: 0.22),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFFFFE000)
                                            .withValues(alpha: 0.6)),
                                  ),
                                  child: const Icon(Icons.volume_up_rounded,
                                      size: 18, color: Color(0xFFFFE000)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              _front
                                  ? 'কার্ডে ট্যাপ করে অর্থ দেখো'
                                  : 'কার্ডে ট্যাপ করে আবার ঘোরাও',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.55),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _index == 0 ? null : () => _go(-1),
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2)),
                          foregroundColor: Colors.white),
                      icon: const Icon(Icons.navigate_before_rounded),
                      label: const Text('আগেরটি',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _index >= _phrases.length - 1
                          ? null
                          : () => _go(1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.navigate_next_rounded),
                      label: const Text('পরেরটি',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HiQuizGame extends StatefulWidget {
  const _HiQuizGame({super.key});
  @override
  State<_HiQuizGame> createState() => _HiQuizGameState();
}

class _HiQuizGameState extends State<_HiQuizGame>
    with TickerProviderStateMixin {
  final _rng = math.Random();
  final _tts = FlutterTts();
  late ConfettiController _confetti;
  late AnimationController _shakeCtrl;
  bool _ttsReady = false;
  bool _slowMode = false;

  late _Phrase _target;
  late List<_Phrase> _options;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _attempts = 0;
  int _correct = 0;
  final Map<String, int> _missed = {};
  bool _locked = false;
  String? _picked;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 650));
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _initTts();
    _next(speak: false);
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(_slowMode ? 0.32 : 0.50);
      await _tts.setPitch(1.05);
      if (!mounted) return;
      setState(() => _ttsReady = true);
      // ignore: discarded_futures
      _speak();
    } catch (_) {}
  }

  Future<void> _speak() async {
    if (!_ttsReady) return;
    await _tts.stop();
    await _tts.setSpeechRate(_slowMode ? 0.32 : 0.50);
    await _tts.speak(_target.jp);
  }

  void _next({bool speak = true}) {
    final t = _phrases[_rng.nextInt(_phrases.length)];
    final pool = _phrases.where((e) => e.jp != t.jp).toList()..shuffle(_rng);
    setState(() {
      _target = t;
      _options = [t, ...pool.take(3)]..shuffle(_rng);
      _locked = false;
      _picked = null;
    });
    if (speak && _ttsReady) {
      // ignore: discarded_futures
      _speak();
    }
  }

  void _pick(_Phrase p) {
    if (_locked) return;
    final ok = p.jp == _target.jp;
    setState(() {
      _locked = true;
      _picked = p.jp;
      _attempts += 1;
      if (ok) {
        _streak += 1;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _score += 10;
        _correct += 1;
      } else {
        _streak = 0;
        _missed[_target.jp] = (_missed[_target.jp] ?? 0) + 1;
      }
    });
    if (ok) {
      HapticFeedback.mediumImpact();
      _confetti.play();
    } else {
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0);
    }
    Future.delayed(const Duration(milliseconds: 620), () {
      if (!mounted) return;
      _next();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    _shakeCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: SizedBox(
                height: 130,
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
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: _deco(),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: Color(0xFFFFE000)),
                  const SizedBox(width: 8),
                  Text('স্কোর: $_score',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 10),
                  _HiStatChip(label: 'স্ট্রিক', value: '$_streak'),
                  const SizedBox(width: 6),
                  _HiStatChip(label: 'সেরা', value: '$_bestStreak'),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: _attempts == 0
                        ? null
                        : () => _showHiAwesomeResult(
                              context: context,
                              title: 'কুইজ রান — রিভিউ',
                              scoreLabel: 'স্কোর: $_score',
                              stats: [
                                'চেষ্টা: $_attempts',
                                'সঠিক: $_correct',
                                'নির্ভুলতা: ${((_correct * 100) / _attempts).round()}%',
                                'সেরা স্ট্রিক: $_bestStreak',
                              ],
                              missed: _missed.entries.toList()
                                ..sort((a, b) => b.value.compareTo(a.value)),
                              onPlayAgain: () {
                                setState(() {
                                  _score = 0;
                                  _streak = 0;
                                  _bestStreak = 0;
                                  _attempts = 0;
                                  _correct = 0;
                                  _missed.clear();
                                });
                                _next();
                              },
                            ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.22)),
                    ),
                    child: const Text('রিভিউ',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: _shakeCtrl,
              builder: (_, child) {
                final wrong = _picked != null && _picked != _target.jp;
                final dx = wrong
                    ? math.sin(_shakeCtrl.value * math.pi * 6) * 8
                    : 0.0;
                return Transform.translate(
                    offset: Offset(dx, 0), child: child);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: _deco(radius: 18),
                child: Column(
                  children: [
                    const Text('এই জাপানি বাক্যের বাংলা মানে কোনটি?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Text(_target.jp,
                        style: const TextStyle(
                            color: Color(0xFFFFE000),
                            fontSize: 40,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(_target.romaji,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('উচ্চারণ: ${_target.bnPronunciation}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
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
                                  : Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.pets_rounded,
                                    color: _slowMode
                                        ? const Color(0xFF1E293B)
                                        : Colors.white,
                                    size: 18),
                                const SizedBox(width: 6),
                                Text('ধীরে',
                                    style: TextStyle(
                                        color: _slowMode
                                            ? const Color(0xFF1E293B)
                                            : Colors.white,
                                        fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: _options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final o = _options[i];
                  final picked = _picked == o.jp;
                  final correct = o.jp == _target.jp;
                  final bg = _picked == null
                      ? Colors.white.withValues(alpha: 0.06)
                      : (correct
                          ? const Color(0xFF10B981).withValues(alpha: 0.22)
                          : (picked
                              ? const Color(0xFFEF4444).withValues(alpha: 0.22)
                              : Colors.white.withValues(alpha: 0.05)));
                  final border = _picked == null
                      ? Colors.white.withValues(alpha: 0.16)
                      : (correct
                          ? const Color(0xFF10B981)
                          : (picked
                              ? const Color(0xFFEF4444)
                              : Colors.white.withValues(alpha: 0.16)));
                  return GestureDetector(
                    onTap: () => _pick(o),
                    child: AnimatedScale(
                      scale: picked && correct ? 1.03 : 1.0,
                      duration: const Duration(milliseconds: 220),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: border, width: _picked == null ? 1 : 2),
                        ),
                        child: Row(
                          children: [
                            if (picked || (correct && _picked != null))
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  correct
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  color: correct
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                  size: 20,
                                ),
                              ),
                            Expanded(
                              child: Text(o.bn,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _HiPair {
  const _HiPair({required this.keyId, required this.label});
  final String keyId;
  final String label;
}

class _HiMatchGame extends StatefulWidget {
  const _HiMatchGame({super.key});
  @override
  State<_HiMatchGame> createState() => _HiMatchGameState();
}

class _HiMatchGameState extends State<_HiMatchGame>
    with TickerProviderStateMixin {
  final _rng = math.Random();
  final _tts = FlutterTts();
  late ConfettiController _confetti;
  late AnimationController _shakeCtrl;
  bool _ttsReady = false;

  late List<_HiPair> _jpColumn;
  late List<_HiPair> _bnColumn;
  int? _selectedJpIdx;
  int? _selectedBnIdx;
  final _matchedKeys = <String>{};
  int _moves = 0;
  int _wrongJp = -1;
  int _wrongBn = -1;
  int _wrongMoves = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _xp = 0;
  final Map<String, int> _missesByKey = {};
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 700));
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _initTts();
    _reset();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.50);
      await _tts.setPitch(1.05);
      if (!mounted) return;
      setState(() => _ttsReady = true);
    } catch (_) {}
  }

  Future<void> _speak(String jp) async {
    if (!_ttsReady) return;
    await _tts.stop();
    await _tts.speak(jp);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _reset() {
    final take = List<_Phrase>.of(_phrases)..shuffle(_rng);
    final six = take.take(6).toList();
    final jp = <_HiPair>[];
    final bn = <_HiPair>[];
    for (final p in six) {
      jp.add(_HiPair(keyId: p.jp, label: '${p.jp}\n(${p.bnPronunciation})'));
      bn.add(_HiPair(keyId: p.jp, label: p.bn));
    }
    jp.shuffle(_rng);
    bn.shuffle(_rng);
    setState(() {
      _jpColumn = jp;
      _bnColumn = bn;
      _selectedJpIdx = null;
      _selectedBnIdx = null;
      _matchedKeys.clear();
      _missesByKey.clear();
      _moves = 0;
      _wrongJp = -1;
      _wrongBn = -1;
      _wrongMoves = 0;
      _streak = 0;
      _bestStreak = 0;
      _xp = 0;
    });
    _stopwatch
      ..reset()
      ..start();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _tapJp(int idx) {
    final key = _jpColumn[idx].keyId;
    if (_matchedKeys.contains(key)) return;
    HapticFeedback.selectionClick();
    // ignore: discarded_futures
    _speak(key);
    setState(() {
      _wrongJp = -1;
      _wrongBn = -1;
      _selectedJpIdx = idx;
    });
    _tryMatch();
  }

  void _tapBn(int idx) {
    final key = _bnColumn[idx].keyId;
    if (_matchedKeys.contains(key)) return;
    HapticFeedback.selectionClick();
    setState(() {
      _wrongJp = -1;
      _wrongBn = -1;
      _selectedBnIdx = idx;
    });
    _tryMatch();
  }

  void _tryMatch() {
    if (_selectedJpIdx == null || _selectedBnIdx == null) return;
    _moves += 1;
    final jp = _jpColumn[_selectedJpIdx!];
    final bn = _bnColumn[_selectedBnIdx!];
    final ok = jp.keyId == bn.keyId;
    if (ok) {
      HapticFeedback.mediumImpact();
      setState(() {
        _matchedKeys.add(jp.keyId);
        _selectedJpIdx = null;
        _selectedBnIdx = null;
        _streak += 1;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _xp += 10;
      });
      _confetti.play();
      if (_matchedKeys.length == _jpColumn.length) {
        _stopwatch.stop();
        _ticker?.cancel();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          _showHiAwesomeResult(
            context: context,
            title: 'ফ্রেজ ম্যাচ — সব মিলেছে',
            scoreLabel: 'XP: $_xp',
            stats: [
              'মুভ: $_moves',
              'ভুল: $_wrongMoves',
              'নির্ভুলতা: ${_moves == 0 ? 0 : (((_moves - _wrongMoves) * 100) / _moves).round()}%',
              'সেরা স্ট্রিক: $_bestStreak',
              'সময়: ${_formatDuration(_stopwatch.elapsed)}',
            ],
            missed: _missesByKey.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)),
            onPlayAgain: _reset,
          );
        });
      }
      return;
    }
    HapticFeedback.heavyImpact();
    _wrongMoves += 1;
    _missesByKey[jp.keyId] = (_missesByKey[jp.keyId] ?? 0) + 1;
    _missesByKey[bn.keyId] = (_missesByKey[bn.keyId] ?? 0) + 1;
    final wrongJpIdx = _selectedJpIdx!;
    final wrongBnIdx = _selectedBnIdx!;
    setState(() {
      _wrongJp = wrongJpIdx;
      _wrongBn = wrongBnIdx;
      _selectedJpIdx = null;
      _selectedBnIdx = null;
      _streak = 0;
    });
    _shakeCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 460), () {
      if (!mounted) return;
      setState(() {
        if (_wrongJp == wrongJpIdx) _wrongJp = -1;
        if (_wrongBn == wrongBnIdx) _wrongBn = -1;
      });
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    _shakeCtrl.dispose();
    _ticker?.cancel();
    _tts.stop();
    super.dispose();
  }

  Widget _buildCard(_HiPair c, int idx, bool isJp) {
    final selected = isJp ? _selectedJpIdx == idx : _selectedBnIdx == idx;
    final matched = _matchedKeys.contains(c.keyId);
    final wrong = isJp ? _wrongJp == idx : _wrongBn == idx;
    final border = matched
        ? const Color(0xFF10B981)
        : (wrong
            ? const Color(0xFFEF4444)
            : (selected
                ? const Color(0xFFFFE000)
                : Colors.white.withValues(alpha: 0.14)));
    final bg = matched
        ? const Color(0xFF10B981).withValues(alpha: 0.17)
        : (wrong
            ? const Color(0xFFEF4444).withValues(alpha: 0.14)
            : (selected
                ? const Color(0xFFFFE000).withValues(alpha: 0.13)
                : Colors.white.withValues(alpha: 0.06)));
    return AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (_, child) {
        final dx = wrong ? math.sin(_shakeCtrl.value * math.pi * 6) * 6 : 0.0;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: GestureDetector(
        onTap: () => isJp ? _tapJp(idx) : _tapBn(idx),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: selected ? 2.1 : 1.4),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  c.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: isJp ? 20 : 18,
                    height: 1.2,
                  ),
                ),
              ),
              if (isJp)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.volume_up_rounded,
                        size: 12, color: Colors.white),
                  ),
                ),
              if (matched)
                const Positioned(
                  top: 2,
                  left: 2,
                  child: Icon(Icons.check_circle_rounded,
                      size: 16, color: Color(0xFF10B981)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        _jpColumn.isEmpty ? 0.0 : _matchedKeys.length / _jpColumn.length;
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
                height: 130,
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
              decoration: _deco(),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.link_rounded, color: Color(0xFFFFE000)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('ফ্রেজ মিলাও',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900)),
                      ),
                      _HiStatChip(label: 'XP', value: '$_xp'),
                      const SizedBox(width: 6),
                      _HiStatChip(label: 'স্ট্রিক', value: '$_streak'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer_rounded,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Text(elapsed,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w800,
                              fontSize: 12)),
                      const SizedBox(width: 14),
                      Text('মুভ: $_moves',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w800,
                              fontSize: 12)),
                      const Spacer(),
                      Text(
                          '${_matchedKeys.length}/${_jpColumn.length} মিলেছে',
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
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    valueColor:
                        const AlwaysStoppedAnimation(Color(0xFFFFE000)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _jpColumn.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) =>
                          _buildCard(_jpColumn[i], i, true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _bnColumn.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) =>
                          _buildCard(_bnColumn[i], i, false),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                    side:
                        BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    foregroundColor: Colors.white),
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

class _HiRushGame extends StatefulWidget {
  const _HiRushGame({super.key});

  @override
  State<_HiRushGame> createState() => _HiRushGameState();
}

class _HiRushGameState extends State<_HiRushGame>
    with TickerProviderStateMixin {
  final _rng = math.Random();
  final _tts = FlutterTts();
  late ConfettiController _confetti;
  late AnimationController _shakeCtrl;
  Timer? _timer;
  static const _totalSeconds = 25;
  static const _sessionXpBonus = 50;

  int _timeLeft = _totalSeconds;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  bool _locked = false;
  bool? _lastCorrect;
  int _attempts = 0;
  int _correct = 0;
  bool _ttsReady = false;
  bool _slowMode = false;
  final Map<String, int> _missed = {};
  late _Phrase _target;
  late String _shownMeaning;
  late bool _isActuallyCorrect;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 650));
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _initTts();
    _next(speak: false);
    _startTimer();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(_slowMode ? 0.32 : 0.50);
      await _tts.setPitch(1.05);
      if (!mounted) return;
      setState(() => _ttsReady = true);
      // ignore: discarded_futures
      _speak();
    } catch (_) {}
  }

  Future<void> _speak() async {
    if (!_ttsReady) return;
    await _tts.stop();
    await _tts.setSpeechRate(_slowMode ? 0.32 : 0.50);
    await _tts.speak(_target.jp);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timeLeft <= 1) {
        timer.cancel();
        _showEnd();
      } else {
        setState(() => _timeLeft -= 1);
      }
    });
  }

  void _next({bool speak = true}) {
    final t = _phrases[_rng.nextInt(_phrases.length)];
    final showCorrect = _rng.nextBool();
    String meaning = t.bn;
    if (!showCorrect) {
      final wrongPool = _phrases.where((p) => p.jp != t.jp).toList()
        ..shuffle(_rng);
      meaning = wrongPool.first.bn;
    }
    setState(() {
      _target = t;
      _shownMeaning = meaning;
      _isActuallyCorrect = showCorrect;
      _locked = false;
      _lastCorrect = null;
    });
    if (speak && _ttsReady) {
      // ignore: discarded_futures
      _speak();
    }
  }

  void _answer(bool saysCorrect) {
    if (_locked) return;
    final ok = saysCorrect == _isActuallyCorrect;
    setState(() {
      _locked = true;
      _lastCorrect = ok;
      _attempts += 1;
      if (ok) {
        _streak += 1;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _score += 10;
        _correct += 1;
      } else {
        _streak = 0;
        _missed[_target.jp] = (_missed[_target.jp] ?? 0) + 1;
      }
    });
    if (ok) {
      HapticFeedback.mediumImpact();
      _confetti.play();
    } else {
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0);
    }
    Future.delayed(const Duration(milliseconds: 480), () {
      if (!mounted) return;
      _next();
    });
  }

  void _showEnd() {
    _timer?.cancel();
    _showHiAwesomeResult(
      context: context,
      title: 'রাশ বস — রেজাল্ট',
      scoreLabel: 'XP: ${_score + _sessionXpBonus}',
      stats: [
        'চেষ্টা: $_attempts',
        'সঠিক: $_correct',
        'নির্ভুলতা: ${_attempts == 0 ? 0 : ((_correct * 100) / _attempts).round()}%',
        'সেরা স্ট্রিক: $_bestStreak',
        'সেশন বোনাস: +$_sessionXpBonus XP',
      ],
      missed: _missed.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
      onPlayAgain: () {
        setState(() {
          _timeLeft = _totalSeconds;
          _score = 0;
          _streak = 0;
          _bestStreak = 0;
          _lastCorrect = null;
          _attempts = 0;
          _correct = 0;
          _missed.clear();
        });
        _next();
        _startTimer();
      },
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
    final timeProgress = _timeLeft / _totalSeconds;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: SizedBox(
                height: 130,
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
                decoration: _deco(),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer_rounded,
                            color: _timeLeft <= 5
                                ? const Color(0xFFFF6B6B)
                                : const Color(0xFFFFE000)),
                        const SizedBox(width: 8),
                        Text('সময়: ${_timeLeft}s',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900)),
                        const Spacer(),
                        Text('স্কোর: $_score',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(width: 10),
                        _HiStatChip(label: 'সেরা', value: '$_bestStreak'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(99),
                      value: timeProgress.clamp(0, 1),
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation(_timeLeft <= 5
                          ? const Color(0xFFFF6B6B)
                          : const Color(0xFFFFE000)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: _shakeCtrl,
                builder: (_, child) {
                  final wrong = _lastCorrect == false;
                  final dx = wrong
                      ? math.sin(_shakeCtrl.value * math.pi * 6) * 8
                      : 0.0;
                  return Transform.translate(
                      offset: Offset(dx, 0), child: child);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: _deco(radius: 20),
                  child: Column(
                    children: [
                      const Text('জাপানি বাক্য আর বাংলা মানে মিলছে?',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      Text(_target.jp,
                          style: const TextStyle(
                              color: Color(0xFFFFE000),
                              fontSize: 48,
                              fontWeight: FontWeight.w900)),
                      Text('${_target.romaji} • ${_target.bnPronunciation}',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _speak,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
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
                                      color: Color(0xFFFFE000), size: 16),
                                  SizedBox(width: 4),
                                  Text('শুনি',
                                      style: TextStyle(
                                          color: Color(0xFFFFE000),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              setState(() => _slowMode = !_slowMode);
                              await _speak();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _slowMode
                                    ? const Color(0xFFFFE000)
                                    : Colors.white.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.pets_rounded,
                                      color: _slowMode
                                          ? const Color(0xFF1E293B)
                                          : Colors.white,
                                      size: 16),
                                  const SizedBox(width: 4),
                                  Text('ধীরে',
                                      style: TextStyle(
                                          color: _slowMode
                                              ? const Color(0xFF1E293B)
                                              : Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _lastCorrect == null
                              ? Colors.white.withValues(alpha: 0.07)
                              : (_lastCorrect!
                                  ? const Color(0xFF10B981).withValues(alpha: 0.16)
                                  : const Color(0xFFEF4444).withValues(alpha: 0.16)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _lastCorrect == null
                                ? Colors.white.withValues(alpha: 0.14)
                                : (_lastCorrect!
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444)),
                            width: _lastCorrect == null ? 1 : 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (_lastCorrect != null) ...[
                              Icon(
                                _lastCorrect!
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: _lastCorrect!
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: Text(
                                _shownMeaning,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 24),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _answer(true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('ঠিক',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _answer(false),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      icon: const Icon(Icons.cancel_rounded),
                      label: const Text('ভুল',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// শুনে বলো — Listening MCQ: audio plays Japanese, pick Bengali meaning
// ═════════════════════════════════════════════════════════════════════

class _HiListenGame extends StatefulWidget {
  const _HiListenGame({super.key});

  @override
  State<_HiListenGame> createState() => _HiListenGameState();
}

class _HiListenGameState extends State<_HiListenGame>
    with TickerProviderStateMixin {
  static const _teal = Color(0xFF14B8A6);
  static const _totalRounds = 8;
  static const _sessionXpBonus = 50;

  final _rng = math.Random();
  final _tts = FlutterTts();
  late final Future<void> _ttsReady;
  late ConfettiController _confetti;
  late AnimationController _shakeCtrl;

  late _TimeGreeting _target;
  late List<_TimeGreeting> _options;
  int _roundIdx = 0;
  int? _pickedId;
  bool _locked = false;
  bool _slowMode = false;
  bool _showCorrectBanner = false;

  late List<int> _deck;
  int? _lastTargetId;

  final Stopwatch _sessionTimer = Stopwatch();
  int _correct = 0;
  int _totalAttempts = 0;
  int _xp = 0;
  int _streak = 0;
  int _bestStreak = 0;
  final Map<int, int> _missed = {};

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 650));
    _shakeCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _ttsReady = _initTts();
    _newSession();
  }

  Future<void> _initTts() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(0.46);
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);
  }

  Future<void> _applyRate() async {
    await _ttsReady;
    await _tts.setSpeechRate(_slowMode ? 0.30 : 0.46);
  }

  Future<void> _speak() async {
    await _ttsReady;
    await _tts.stop();
    await _tts.speak(_target.jp);
  }

  void _newSession() {
    _roundIdx = 0;
    _correct = 0;
    _totalAttempts = 0;
    _xp = 0;
    _streak = 0;
    _bestStreak = 0;
    _missed.clear();
    _deck = [];
    _lastTargetId = null;
    _sessionTimer
      ..reset()
      ..start();
    _buildRound();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speak());
  }

  int _drawTargetId() {
    if (_deck.isEmpty) {
      _deck = _timeGreetings.map((g) => g.id).toList()..shuffle(_rng);
      // avoid back-to-back duplicate when refilling
      if (_lastTargetId != null && _deck.length > 1 && _deck.first == _lastTargetId) {
        _deck.add(_deck.removeAt(0));
      }
    }
    final id = _deck.removeAt(0);
    _lastTargetId = id;
    return id;
  }

  void _buildRound() {
    final id = _drawTargetId();
    _target = _timeGreetings.firstWhere((g) => g.id == id);
    final pool = _timeGreetings.where((g) => g.id != _target.id).toList()..shuffle(_rng);
    setState(() {
      _options = [_target, ...pool.take(3)]..shuffle(_rng);
      _locked = false;
      _pickedId = null;
      _showCorrectBanner = false;
    });
  }

  String _fmtDur(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _pick(_TimeGreeting o) {
    if (_locked) return;
    _totalAttempts += 1;
    final ok = o.id == _target.id;
    setState(() {
      _locked = true;
      _pickedId = o.id;
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
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        if (_roundIdx >= _totalRounds - 1) {
          _sessionTimer.stop();
          _xp += _sessionXpBonus;
          _showEnd();
        } else {
          _roundIdx += 1;
          _buildRound();
          _speak();
        }
      });
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _streak = 0;
        _missed[_target.id] = (_missed[_target.id] ?? 0) + 1;
      });
      _shakeCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          _pickedId = null;
          _locked = false;
        });
      });
    }
  }

  void _showEnd() {
    final acc = _totalAttempts == 0 ? 0 : ((_correct * 100) / _totalAttempts).round();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _HiAwesomeResultSheet(
        title: 'শুনে বলো — সেশন শেষ',
        scoreLabel: 'মোট XP: $_xp',
        stats: [
          'সঠিক: $_correct/$_totalRounds',
          'নির্ভুলতা: $acc%',
          'সেরা স্ট্রিক: $_bestStreak',
          'সময়: ${_fmtDur(_sessionTimer.elapsed)}',
        ],
        missed: _missed.entries.map((e) {
          final g = _timeGreetings.firstWhere((x) => x.id == e.key);
          return '${g.bnPron} — ${g.bnMeaning}  ×${e.value}';
        }).toList(),
        onPlayAgain: () {
          Navigator.of(context, rootNavigator: true).maybePop();
          _newSession();
        },
      ),
    );
  }

  @override
  void dispose() {
    _confetti.dispose();
    _shakeCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

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
                    _teal,
                    Color(0xFF3B82F6),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              _HiHeaderPanel(
                color: _teal,
                title: 'শুনে বলো — অডিও শুনে অর্থ বাছুন',
                progress: progress,
                roundText: 'রাউন্ড ${_roundIdx + 1}/$_totalRounds',
                xp: _xp,
                streak: _streak,
                timer: _fmtDur(_sessionTimer.elapsed),
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _shakeCtrl,
                builder: (context, child) {
                  final t = _shakeCtrl.value;
                  final dx = math.sin(t * math.pi * 6) * 10 * (1 - t);
                  return Transform.translate(offset: Offset(dx, 0), child: child);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _teal.withValues(alpha: 0.55), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _teal.withValues(alpha: 0.18),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _teal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          'অডিও শুনুন',
                          style: TextStyle(
                            color: _teal,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _target.bnPron,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFFFE000),
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _locked ? null : _speak,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _teal,
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
                                      await _applyRate();
                                      await _speak();
                                    },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _slowMode ? _teal : Colors.white,
                                side: BorderSide(
                                    color: _slowMode
                                        ? _teal
                                        : Colors.white.withValues(alpha: 0.28)),
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
              const SizedBox(height: 14),
              const Text(
                'এই অভিবাদনের বাংলা অর্থ কী?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Column(
                  children: [
                    for (int i = 0; i < _options.length; i++) ...[
                      if (i != 0) const SizedBox(height: 10),
                      _HiOptionTile(
                        label: _options[i].bnMeaning,
                        sublabel: _options[i].timeLabel,
                        picked: _pickedId == _options[i].id,
                        isCorrect: _options[i].id == _target.id,
                        revealed: _pickedId != null,
                        onTap: _locked ? null : () => _pick(_options[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          _HiCorrectBanner(
            visible: _showCorrectBanner,
            streak: _streak,
            text: '${_target.bnPron} → ${_target.bnMeaning}',
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// পড়ে বলো — Reading MCQ: scenario in Bengali → pick Bengali pronunciation
// of the correct Japanese greeting (includes office trick questions)
// ═════════════════════════════════════════════════════════════════════

class _HiReadGame extends StatefulWidget {
  const _HiReadGame({super.key});

  @override
  State<_HiReadGame> createState() => _HiReadGameState();
}

class _HiReadGameState extends State<_HiReadGame> with TickerProviderStateMixin {
  static const _violet = Color(0xFF8B5CF6);
  static const _totalRounds = 8;
  static const _sessionXpBonus = 50;

  final _rng = math.Random();
  late ConfettiController _confetti;
  late AnimationController _shakeCtrl;
  late AnimationController _cardCtrl;

  late _ReadScenario _scenario;
  late _TimeGreeting _target;
  late List<_TimeGreeting> _options;
  int _roundIdx = 0;
  int? _pickedId;
  bool _locked = false;
  bool _showCorrectBanner = false;
  bool _showTrick = false;

  final Stopwatch _sessionTimer = Stopwatch();
  int _correct = 0;
  int _totalAttempts = 0;
  int _xp = 0;
  int _streak = 0;
  int _bestStreak = 0;
  final Map<int, int> _missed = {};

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 650));
    _shakeCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _cardCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _newSession();
  }

  late List<int> _scenarioDeck;
  int? _lastScenarioIdx;

  void _newSession() {
    _roundIdx = 0;
    _correct = 0;
    _totalAttempts = 0;
    _xp = 0;
    _streak = 0;
    _bestStreak = 0;
    _missed.clear();
    _scenarioDeck = [];
    _lastScenarioIdx = null;
    _sessionTimer
      ..reset()
      ..start();
    _buildRound();
  }

  int _drawScenarioIdx() {
    if (_scenarioDeck.isEmpty) {
      _scenarioDeck = List<int>.generate(_readScenarios.length, (i) => i)
        ..shuffle(_rng);
      if (_lastScenarioIdx != null &&
          _scenarioDeck.length > 1 &&
          _scenarioDeck.first == _lastScenarioIdx) {
        _scenarioDeck.add(_scenarioDeck.removeAt(0));
      }
    }
    final idx = _scenarioDeck.removeAt(0);
    _lastScenarioIdx = idx;
    return idx;
  }

  void _buildRound() {
    _scenario = _readScenarios[_drawScenarioIdx()];
    _target = _timeGreetings.firstWhere((g) => g.id == _scenario.answerId);
    final pool = _timeGreetings.where((g) => g.id != _target.id).toList()..shuffle(_rng);
    setState(() {
      _options = [_target, ...pool.take(3)]..shuffle(_rng);
      _locked = false;
      _pickedId = null;
      _showCorrectBanner = false;
      _showTrick = false;
    });
    _cardCtrl.forward(from: 0);
  }

  String _fmtDur(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _pick(_TimeGreeting o) {
    if (_locked) return;
    _totalAttempts += 1;
    final ok = o.id == _target.id;
    setState(() {
      _locked = true;
      _pickedId = o.id;
    });
    if (ok) {
      HapticFeedback.mediumImpact();
      setState(() {
        _correct += 1;
        _streak += 1;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _xp += 10;
        _showCorrectBanner = true;
        _showTrick = _scenario.trick != null;
      });
      _confetti.play();
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        if (_roundIdx >= _totalRounds - 1) {
          _sessionTimer.stop();
          _xp += _sessionXpBonus;
          _showEnd();
        } else {
          _roundIdx += 1;
          _buildRound();
        }
      });
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _streak = 0;
        _missed[_target.id] = (_missed[_target.id] ?? 0) + 1;
        if (_scenario.trick != null) _showTrick = true;
      });
      _shakeCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _pickedId = null;
          _locked = false;
        });
      });
    }
  }

  void _showEnd() {
    final acc = _totalAttempts == 0 ? 0 : ((_correct * 100) / _totalAttempts).round();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _HiAwesomeResultSheet(
        title: 'পড়ে বলো — সেশন শেষ',
        scoreLabel: 'মোট XP: $_xp',
        stats: [
          'সঠিক: $_correct/$_totalRounds',
          'নির্ভুলতা: $acc%',
          'সেরা স্ট্রিক: $_bestStreak',
          'সময়: ${_fmtDur(_sessionTimer.elapsed)}',
        ],
        missed: _missed.entries.map((e) {
          final g = _timeGreetings.firstWhere((x) => x.id == e.key);
          return '${g.bnPron} — ${g.bnMeaning}  ×${e.value}';
        }).toList(),
        onPlayAgain: () {
          Navigator.of(context, rootNavigator: true).maybePop();
          _newSession();
        },
      ),
    );
  }

  @override
  void dispose() {
    _confetti.dispose();
    _shakeCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

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
              _HiHeaderPanel(
                color: _violet,
                title: 'পড়ে বলো — দৃশ্য পড়ে সঠিক উত্তর বাছুন',
                progress: progress,
                roundText: 'রাউন্ড ${_roundIdx + 1}/$_totalRounds',
                xp: _xp,
                streak: _streak,
                timer: _fmtDur(_sessionTimer.elapsed),
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _shakeCtrl,
                builder: (context, child) {
                  final t = _shakeCtrl.value;
                  final dx = math.sin(t * math.pi * 6) * 10 * (1 - t);
                  return Transform.translate(offset: Offset(dx, 0), child: child);
                },
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.94, end: 1).animate(
                      CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutBack)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF111827)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: _violet.withValues(alpha: 0.55), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _violet.withValues(alpha: 0.22),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(_scenario.icon, color: _scenario.color, size: 52),
                        const SizedBox(height: 10),
                        Text(
                          _scenario.scene,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            height: 1.3,
                          ),
                        ),
                        if (_scenario.trick != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                            ),
                            child: const Text(
                              '⚠️ ট্রিক প্রশ্ন',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                        if (_showTrick && _scenario.trick != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              _scenario.trick!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'জাপানিতে সঠিক উত্তর কোনটি?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Column(
                  children: [
                    for (int i = 0; i < _options.length; i++) ...[
                      if (i != 0) const SizedBox(height: 10),
                      _HiOptionTile(
                        label: _options[i].bnPron,
                        sublabel: _options[i].bnMeaning,
                        picked: _pickedId == _options[i].id,
                        isCorrect: _options[i].id == _target.id,
                        revealed: _pickedId != null,
                        onTap: _locked ? null : () => _pick(_options[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          _HiCorrectBanner(
            visible: _showCorrectBanner,
            streak: _streak,
            text: '${_target.bnMeaning} → ${_target.bnPron}',
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// বলে দেখাও — Speaking: Bengali shown → user speaks Japanese
// STT (ja-JP) evaluates with fuzzy matching
// ═════════════════════════════════════════════════════════════════════

class _HiSpeakGame extends StatefulWidget {
  const _HiSpeakGame({super.key});

  @override
  State<_HiSpeakGame> createState() => _HiSpeakGameState();
}

class _HiSpeakGameState extends State<_HiSpeakGame> with TickerProviderStateMixin {
  static const _rose = Color(0xFFE11D48);
  static const _maxSeconds = 6;
  static const _totalRounds = 6;
  static const _sessionXpBonus = 50;

  final _rng = math.Random();
  final _tts = FlutterTts();
  final _stt = SpeechToText();
  bool _sttReady = false;
  bool _ttsReady = false;
  String? _locale;
  String? _error;
  bool _listening = false;
  String _heard = '';
  double _soundLevel = 0;
  int _secondsLeft = 0;
  Timer? _recordTimer;

  late _TimeGreeting _target;
  int _roundIdx = 0;
  int? _lastScore;
  bool _evaluated = false;
  bool _showHint = false;

  late ConfettiController _confetti;
  late AnimationController _pulseCtrl;
  late AnimationController _shakeCtrl;

  final Stopwatch _sessionTimer = Stopwatch();
  int _correct = 0;
  int _attempts = 0;
  int _xp = 0;
  int _streak = 0;
  int _bestStreak = 0;
  final Map<int, int> _missed = {};

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 700));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _shakeCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _sessionTimer.start();
    _initTts();
    _initStt();
    _newRound();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.45);
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
      final ja = locales.where((l) => l.localeId.toLowerCase().startsWith('ja'));
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

  List<int> _speakDeck = [];
  int? _lastSpeakId;

  int _drawSpeakId() {
    if (_speakDeck.isEmpty) {
      _speakDeck = _timeGreetings.map((g) => g.id).toList()..shuffle(_rng);
      if (_lastSpeakId != null &&
          _speakDeck.length > 1 &&
          _speakDeck.first == _lastSpeakId) {
        _speakDeck.add(_speakDeck.removeAt(0));
      }
    }
    final id = _speakDeck.removeAt(0);
    _lastSpeakId = id;
    return id;
  }

  void _newRound() {
    final id = _drawSpeakId();
    setState(() {
      _target = _timeGreetings.firstWhere((g) => g.id == id);
      _heard = '';
      _lastScore = null;
      _evaluated = false;
      _showHint = false;
      _error = null;
    });
  }

  // ─── Normalize Japanese STT output ─────────────────────────────────
  static String _normJp(String s) {
    var out = s.toLowerCase();
    final buf = StringBuffer();
    for (final r in out.runes) {
      if (r >= 0xFF10 && r <= 0xFF19) {
        buf.writeCharCode(r - 0xFF10 + 0x30);
        continue;
      }
      if (r == 0x30FC) continue; // strip ー
      // Small kana → big
      const smallToBig = {
        0x3041: 0x3042, 0x3043: 0x3044, 0x3045: 0x3046,
        0x3047: 0x3048, 0x3049: 0x304A,
        0x30A1: 0x30A2, 0x30A3: 0x30A4, 0x30A5: 0x30A6,
        0x30A7: 0x30A8, 0x30A9: 0x30AA,
      };
      // Drop punctuation and common particles' filler
      if (r == 0x3001 || r == 0x3002 || r == 0x002E || r == 0x002C ||
          r == 0x0021 || r == 0x003F || r == 0x0020) {
        continue;
      }
      buf.writeCharCode(smallToBig[r] ?? r);
    }
    return buf.toString();
  }

  // List of acceptable forms per greeting id.
  static const Map<int, List<String>> _accepts = {
    0: [
      'おはようございます', 'おはようごさいます', 'おはよう', 'おはよ',
      'ohayougozaimasu', 'ohayogozaimasu', 'ohayou', 'ohayo',
    ],
    1: [
      'こんにちは', 'こんにちわ', 'konnichiwa', 'konnichiha',
    ],
    2: [
      'こんばんは', 'こんばんわ', 'konbanwa', 'konbanha',
    ],
    3: [
      'おやすみなさい', 'おやすみ', 'oyasuminasai', 'oyasumi',
    ],
  };

  int _grade(String raw, _TimeGreeting target) {
    final heard = _normJp(raw);
    if (heard.isEmpty) return 0;
    final accepts = (_accepts[target.id] ?? <String>[])
        .map((e) => _normJp(e))
        .toList();
    for (final a in accepts) {
      if (heard == a) return 100;
    }
    int best = 0;
    for (final a in accepts) {
      if (heard.contains(a) || a.contains(heard)) {
        best = math.max(best, 92);
      }
      final sim = _similarity(heard, a);
      best = math.max(best, (sim * 88).round());
    }
    return best.clamp(0, 100);
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

  Future<void> _startListening() async {
    if (_listening) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _heard = '';
      _error = null;
      _lastScore = null;
      _evaluated = false;
      _secondsLeft = _maxSeconds;
      _soundLevel = 0;
    });
    try {
      if (!_sttReady) await _initStt();
      if (!_sttReady) {
        throw Exception('Speech recognition এই ডিভাইসে কাজ করছে না।');
      }
      await _stt.listen(
        localeId: _locale,
        listenMode: ListenMode.confirmation,
        partialResults: true,
        cancelOnError: true,
        listenFor: const Duration(seconds: _maxSeconds),
        pauseFor: const Duration(seconds: 3),
        onResult: (SpeechRecognitionResult r) {
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
          await _stopAndCheck();
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

  Future<void> _stopAndCheck() async {
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
    final score = _grade(_heard, _target);
    final ok = score >= 75;
    _attempts += 1;
    setState(() {
      _lastScore = score;
      _evaluated = true;
      if (ok) {
        _correct += 1;
        _streak += 1;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _xp += 10;
      } else {
        _streak = 0;
        _missed[_target.id] = (_missed[_target.id] ?? 0) + 1;
      }
    });
    if (ok) {
      HapticFeedback.mediumImpact();
      _confetti.play();
    } else {
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0);
    }
  }

  Future<void> _playNative() async {
    if (!_ttsReady) return;
    HapticFeedback.selectionClick();
    await _tts.stop();
    await _tts.speak(_target.jp);
  }

  Future<void> _next() async {
    if (_roundIdx >= _totalRounds - 1) {
      _sessionTimer.stop();
      _xp += _sessionXpBonus;
      _showEnd();
      return;
    }
    _roundIdx += 1;
    _newRound();
  }

  String _fmtDur(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showEnd() {
    final acc = _attempts == 0 ? 0 : ((_correct * 100) / _attempts).round();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _HiAwesomeResultSheet(
        title: 'বলে দেখাও — সেশন শেষ',
        scoreLabel: 'মোট XP: $_xp',
        stats: [
          'সঠিক: $_correct/$_totalRounds',
          'নির্ভুলতা: $acc%',
          'সেরা স্ট্রিক: $_bestStreak',
          'সময়: ${_fmtDur(_sessionTimer.elapsed)}',
        ],
        missed: _missed.entries.map((e) {
          final g = _timeGreetings.firstWhere((x) => x.id == e.key);
          return '${g.bnPron} — ${g.bnMeaning}  ×${e.value}';
        }).toList(),
        onPlayAgain: () {
          Navigator.of(context, rootNavigator: true).maybePop();
          setState(() {
            _roundIdx = 0;
            _correct = 0;
            _attempts = 0;
            _xp = 0;
            _streak = 0;
            _bestStreak = 0;
            _missed.clear();
            _speakDeck = [];
            _lastSpeakId = null;
            _sessionTimer
              ..reset()
              ..start();
          });
          _newRound();
        },
      ),
    );
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _confetti.dispose();
    _pulseCtrl.dispose();
    _shakeCtrl.dispose();
    _stt.stop();
    _tts.stop();
    super.dispose();
  }

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
                    _rose,
                    Color(0xFF3B82F6),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              _HiHeaderPanel(
                color: _rose,
                title: 'বলে দেখাও — বাংলা দেখে জাপানিতে বলুন',
                progress: progress,
                roundText: 'রাউন্ড ${_roundIdx + 1}/$_totalRounds',
                xp: _xp,
                streak: _streak,
                timer: _fmtDur(_sessionTimer.elapsed),
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _shakeCtrl,
                builder: (context, child) {
                  final t = _shakeCtrl.value;
                  final dx = math.sin(t * math.pi * 6) * 10 * (1 - t);
                  return Transform.translate(offset: Offset(dx, 0), child: child);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
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
                      Icon(_target.icon, color: _target.color, size: 44),
                      const SizedBox(height: 8),
                      Text(
                        _target.bnMeaning,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'জাপানিতে বলুন',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (_showHint || _evaluated) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _rose.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            _target.bnPron,
                            style: const TextStyle(
                              color: Color(0xFFFFE000),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _target.jp,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _listening ? _stopAndCheck : _startListening,
                child: AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (context, _) {
                    final scale = _listening
                        ? 1 + (_pulseCtrl.value * 0.08) + (_soundLevel.clamp(0, 10) / 60)
                        : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _listening
                                ? const [Color(0xFFEF4444), Color(0xFFB91C1C)]
                                : const [_rose, Color(0xFFBE123C)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_listening
                                      ? const Color(0xFFEF4444)
                                      : _rose)
                                  .withValues(alpha: 0.5),
                              blurRadius: 22,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _listening ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _listening
                    ? 'শুনছি… $_secondsLeft s'
                    : (_evaluated ? 'আবার বলতে মাইক চাপুন' : 'মাইক চাপুন'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              if (_heard.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Text(
                    'শোনা গেল: $_heard',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFE000),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              if (_evaluated) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ((_lastScore ?? 0) >= 75
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: ((_lastScore ?? 0) >= 75
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444))
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        (_lastScore ?? 0) >= 75
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: (_lastScore ?? 0) >= 75
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (_lastScore ?? 0) >= 92
                              ? 'চমৎকার উচ্চারণ! (${_lastScore ?? 0}%)'
                              : (_lastScore ?? 0) >= 75
                                  ? 'ভালো হয়েছে! (${_lastScore ?? 0}%)'
                                  : 'আরেকবার চেষ্টা করুন (${_lastScore ?? 0}%)',
                          style: TextStyle(
                            color: (_lastScore ?? 0) >= 75
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 6),
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
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _ttsReady ? _playNative : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.volume_up_rounded),
                      label: const Text('সঠিক শুনুন',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _showHint = !_showHint),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _showHint ? _rose : Colors.white,
                        side: BorderSide(
                            color: _showHint
                                ? _rose
                                : Colors.white.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(_showHint ? Icons.visibility_off_rounded : Icons.lightbulb_rounded),
                      label: Text(_showHint ? 'হিন্ট লুকান' : 'হিন্ট দেখুন',
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _evaluated ? _next : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _rose,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('পরবর্তী',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// Shared widgets used by the three new games
// ═════════════════════════════════════════════════════════════════════

class _HiHeaderPanel extends StatelessWidget {
  const _HiHeaderPanel({
    required this.color,
    required this.title,
    required this.progress,
    required this.roundText,
    required this.xp,
    required this.streak,
    required this.timer,
  });

  final Color color;
  final String title;
  final double progress;
  final String roundText;
  final int xp;
  final int streak;
  final String timer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
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
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13)),
              ),
              Text(timer,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            minHeight: 8,
            borderRadius: BorderRadius.circular(99),
            value: progress.clamp(0, 1),
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(roundText,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('XP: $xp',
                  style: const TextStyle(
                      color: Color(0xFFFFE000),
                      fontWeight: FontWeight.w900)),
              const SizedBox(width: 10),
              Text('স্ট্রিক: $streak',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HiOptionTile extends StatelessWidget {
  const _HiOptionTile({
    required this.label,
    required this.sublabel,
    required this.picked,
    required this.isCorrect,
    required this.revealed,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final bool picked;
  final bool isCorrect;
  final bool revealed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color border;
    Color bg;
    Color textColor = Colors.white;
    if (!revealed) {
      border = Colors.white.withValues(alpha: 0.18);
      bg = Colors.white.withValues(alpha: 0.07);
    } else if (isCorrect) {
      border = const Color(0xFF10B981);
      bg = const Color(0xFF10B981).withValues(alpha: 0.22);
      textColor = const Color(0xFF10B981);
    } else if (picked) {
      border = const Color(0xFFEF4444);
      bg = const Color(0xFFEF4444).withValues(alpha: 0.18);
      textColor = const Color(0xFFEF4444);
    } else {
      border = Colors.white.withValues(alpha: 0.10);
      bg = Colors.white.withValues(alpha: 0.04);
    }
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: border,
                width: (picked || (isCorrect && revealed)) ? 2.4 : 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        sublabel,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.65),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (revealed && isCorrect)
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF10B981), size: 22),
                if (revealed && picked && !isCorrect)
                  const Icon(Icons.cancel_rounded,
                      color: Color(0xFFEF4444), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HiCorrectBanner extends StatelessWidget {
  const _HiCorrectBanner({
    required this.visible,
    required this.streak,
    required this.text,
  });

  final bool visible;
  final int streak;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
        offset: visible ? Offset.zero : const Offset(0, 1.2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: visible ? 1 : 0,
          child: IgnorePointer(
            ignoring: !visible,
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
                      const Icon(Icons.thumb_up_alt_rounded,
                          color: Colors.white, size: 26),
                      const SizedBox(width: 10),
                      const Text('সঠিক!',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 22)),
                      const Spacer(),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Icon(
                              Icons.star_rounded,
                              color: i < math.min(5, streak)
                                  ? const Color(0xFFFFE000)
                                  : Colors.white.withValues(alpha: 0.22),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
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
    );
  }
}

class _HiStatChip extends StatelessWidget {
  const _HiStatChip({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
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

class _HiFlipFace extends StatelessWidget {
  const _HiFlipFace({super.key, required this.item, required this.turns});
  final _Phrase item;
  final double turns;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: turns),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
      builder: (context, value, _) {
        final v = value % (2 * math.pi);
        final showFront = v <= math.pi / 2 || v >= (3 * math.pi) / 2;
        final angle = showFront ? v : v + math.pi;

        final front = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.jp,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 52,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Text(item.romaji,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 22,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('উচ্চারণ: ${item.bnPronunciation}',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontWeight: FontWeight.w700)),
          ],
        );

        final back = Text(
          item.bn,
          style: const TextStyle(
              color: Color(0xFFFFE000),
              fontSize: 46,
              fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        );

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle),
          child: showFront ? front : back,
        );
      },
    );
  }
}

BoxDecoration _deco({double radius = 16}) => BoxDecoration(
      color: const Color(0xFF1E293B),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
    );


void _showHiAwesomeResult({
  required BuildContext context,
  required String title,
  required String scoreLabel,
  required List<String> stats,
  required List<MapEntry<String, int>> missed,
  required VoidCallback onPlayAgain,
}) {
  final missedLines = <String>[];
  for (final e in missed.take(6)) {
    final p = _phrases.firstWhere((x) => x.jp == e.key);
    missedLines.add('${p.jp} (${p.bnPronunciation}) → ${p.bn}  ×${e.value}');
  }
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _HiAwesomeResultSheet(
      title: title,
      scoreLabel: scoreLabel,
      stats: stats,
      missed: missedLines,
      onPlayAgain: onPlayAgain,
    ),
  );
}

class _HiAwesomeResultSheet extends StatelessWidget {
  const _HiAwesomeResultSheet({
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
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
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
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                          ),
                          child: Text(s,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.92),
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
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              for (final m in missed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                    ),
                    child: Text(m,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.92), fontWeight: FontWeight.w800)),
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
                foregroundColor: const Color(0xFF1E293B),
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
