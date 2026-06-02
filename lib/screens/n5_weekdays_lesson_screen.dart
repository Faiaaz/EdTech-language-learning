// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ez_trainz/services/jlc_tts.dart';
import 'package:get/get.dart';
import 'package:ez_trainz/services/jlc_stt.dart';

class N5WeekdaysLessonScreen extends StatefulWidget {
  const N5WeekdaysLessonScreen({super.key});

  @override
  State<N5WeekdaysLessonScreen> createState() => _N5WeekdaysLessonScreenState();
}

enum _WeekTab { flash, quiz, match, sequence, listen, read, speak, seqSpeak }

class _N5WeekdaysLessonScreenState extends State<N5WeekdaysLessonScreen> {
  static const _tabs = [
    _WeekTab.listen,
    _WeekTab.read,
    _WeekTab.speak,
    _WeekTab.seqSpeak,
    _WeekTab.flash,
    _WeekTab.quiz,
    _WeekTab.match,
    _WeekTab.sequence,
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
                        const Text('শুক্র-শনি বাকিটা জানি',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                        Text('সপ্তাহের দিন: Japanese -> বাংলা',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
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
              child: _WeekTabPills(index: _tab, onChange: (i) => setState(() => _tab = i)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: switch (_tabs[_tab]) {
                  _WeekTab.flash => const _WeekFlashGame(key: ValueKey('weekFlash')),
                  _WeekTab.quiz => const _WeekQuizGame(key: ValueKey('weekQuiz')),
                  _WeekTab.match => const _WeekMatchGame(key: ValueKey('weekMatch')),
                  _WeekTab.sequence => const _WeekSequenceGame(key: ValueKey('weekSequence')),
                  _WeekTab.listen => const _WeekListenGame(key: ValueKey('weekListen')),
                  _WeekTab.read => const _WeekReadGame(key: ValueKey('weekRead')),
                  _WeekTab.speak => const _WeekSpeakGame(key: ValueKey('weekSpeak')),
                  _WeekTab.seqSpeak => const _WeekSeqSpeakGame(key: ValueKey('weekSeqSpeak')),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Weekday {
  const _Weekday({required this.jp, required this.kana, required this.bnPronunciation, required this.bn});
  final String jp;
  final String kana;
  final String bnPronunciation;
  final String bn;
}

const _weekdays = <_Weekday>[
  _Weekday(jp: '月曜日', kana: 'げつようび', bnPronunciation: 'গেৎসুওবি', bn: 'সোমবার'),
  _Weekday(jp: '火曜日', kana: 'かようび', bnPronunciation: 'কায়োবি', bn: 'মঙ্গলবার'),
  _Weekday(jp: '水曜日', kana: 'すいようび', bnPronunciation: 'সুইয়োবি', bn: 'বুধবার'),
  _Weekday(jp: '木曜日', kana: 'もくようび', bnPronunciation: 'মোকুওবি', bn: 'বৃহস্পতিবার'),
  _Weekday(jp: '金曜日', kana: 'きんようび', bnPronunciation: 'কিনয়োবি', bn: 'শুক্রবার'),
  _Weekday(jp: '土曜日', kana: 'どようび', bnPronunciation: 'দোয়োবি', bn: 'শনিবার'),
  _Weekday(jp: '日曜日', kana: 'にちようび', bnPronunciation: 'নিচিয়োবি', bn: 'রবিবার'),
];

// ─── Conceptual prompts used in পড়ে বলো (Heijitsu / Shumatsu rules) ──
class _WeekConcept {
  const _WeekConcept({
    required this.prompt,
    required this.options, // shown labels (Bengali)
    required this.correctIdx,
    required this.explanation,
    this.icon = Icons.lightbulb_rounded,
    this.color = const Color(0xFFFBBF24),
  });
  final String prompt;
  final List<String> options;
  final int correctIdx;
  final String explanation;
  final IconData icon;
  final Color color;
}

const _weekConcepts = <_WeekConcept>[
  _WeekConcept(
    prompt: 'জাপানে সাপ্তাহিক কাজের দিনগুলোকে কী বলা হয়?',
    options: ['হেইজিৎসু (平日)', 'শুমাৎসু (週末)', 'গেৎসুওবি', 'নিচিয়োবি'],
    correctIdx: 0,
    explanation: 'কাজের দিন = হেইজিৎসু (Heijitsu, 平日)। সাপ্তাহিক ছুটি = শুমাৎসু (Shumatsu, 週末)।',
    icon: Icons.business_center_rounded,
    color: Color(0xFF06B6D4),
  ),
  _WeekConcept(
    prompt: 'হেইজিৎসু-র মধ্যে কোন দিনগুলো অন্তর্ভুক্ত?',
    options: ['সোম–শুক্র', 'শনি–বুধ', 'শনি ও রবি', 'সোম–রবি (সব)'],
    correctIdx: 0,
    explanation: 'হেইজিৎসু = সোমবার থেকে শুক্রবার পর্যন্ত (গেৎসু → কিন)।',
    icon: Icons.calendar_view_week_rounded,
    color: Color(0xFF10B981),
  ),
  _WeekConcept(
    prompt: 'শুমাৎসু (উইকএন্ড) কোন দিনগুলো?',
    options: ['শনিবার ও রবিবার', 'শুক্রবার ও শনিবার', 'শুধু রবিবার', 'শুক্র, শনি, রবি'],
    correctIdx: 0,
    explanation: 'জাপানে শুমাৎসু = শনি (দোয়োবি) + রবি (নিচিয়োবি)। শুক্রবার এর মধ্যে নয়।',
    icon: Icons.weekend_rounded,
    color: Color(0xFF8B5CF6),
  ),
  _WeekConcept(
    prompt: 'হেইজিৎসু কোন বার থেকে শুরু হয়?',
    options: ['গেৎসুওবি (সোমবার)', 'নিচিয়োবি (রবিবার)', 'কায়োবি (মঙ্গলবার)', 'দোয়োবি (শনিবার)'],
    correctIdx: 0,
    explanation: 'কাজের সপ্তাহ গেৎসুওবি (সোমবার) থেকে শুরু হয়।',
    icon: Icons.event_available_rounded,
    color: Color(0xFFFBBF24),
  ),
  _WeekConcept(
    prompt: 'নিচের কোন দিনটি শুমাৎসু-এর মধ্যে পড়ে?',
    options: ['নিচিয়োবি', 'গেৎসুওবি', 'সুইয়োবি', 'মোকুওবি'],
    correctIdx: 0,
    explanation: 'নিচিয়োবি (রবিবার) শুমাৎসু-এর অংশ। বাকিগুলো হেইজিৎসু।',
    icon: Icons.weekend_rounded,
    color: Color(0xFFA855F7),
  ),
  _WeekConcept(
    prompt: 'হেইজিৎসু-এর শেষ দিন কোনটি?',
    options: ['কিনয়োবি (শুক্রবার)', 'দোয়োবি (শনিবার)', 'মোকুওবি (বৃহস্পতিবার)', 'নিচিয়োবি (রবিবার)'],
    correctIdx: 0,
    explanation: 'হেইজিৎসু-এর শেষ দিন = কিনয়োবি (শুক্রবার)।',
    icon: Icons.event_busy_rounded,
    color: Color(0xFFF97316),
  ),
];

class _WeekTabPills extends StatelessWidget {
  const _WeekTabPills({required this.index, required this.onChange});
  final int index;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    const labels = [
      'শুনে বলো',
      'পড়ে বলো',
      'বলে দেখাও',
      'ক্রম বলো',
      'ফ্ল্যাশকার্ড',
      'কুইজ রান',
      'ডে ম্যাচ',
      'নেক্সট ডে',
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

class _WeekFlashGame extends StatefulWidget {
  const _WeekFlashGame({super.key});
  @override
  State<_WeekFlashGame> createState() => _WeekFlashGameState();
}

class _WeekFlashGameState extends State<_WeekFlashGame>
    with TickerProviderStateMixin {
  final _tts = JlcTts();
  late ConfettiController _confetti;
  bool _ttsReady = false;
  bool _slowMode = false;
  int _i = 0;
  bool _front = true;
  double _flipTurns = 0;
  int _xp = 0;
  int _flips = 0;
  final Set<int> _seen = {};
  bool _doneShown = false;

  _Weekday get _item => _weekdays[_i];

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
    await _tts.speak(_item.kana);
  }

  void _flip() {
    HapticFeedback.selectionClick();
    setState(() {
      _front = !_front;
      _flipTurns += math.pi;
      _flips += 1;
      _seen.add(_i);
    });
    if (!_front) {
      // ignore: discarded_futures
      _speak();
    }
  }

  void _go(int delta) {
    final next = (_i + delta).clamp(0, _weekdays.length - 1);
    if (next == _i) return;
    HapticFeedback.lightImpact();
    setState(() {
      _i = next;
      _front = true;
      _flipTurns = 0;
      if (_seen.add(_i)) _xp += 10;
    });
    if (_seen.length == _weekdays.length && !_doneShown) {
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
    final progress = _seen.length / _weekdays.length;
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
              decoration: _card(),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded,
                          color: Color(0xFFFFE000)),
                      const SizedBox(width: 8),
                      Text('দিন ${_i + 1}/${_weekdays.length}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 10),
                      _WeekStatChip(label: 'XP', value: '$_xp'),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: _seen.isEmpty
                            ? null
                            : () => _showWeekAwesomeResult(
                                  context: context,
                                  title: 'ফ্ল্যাশকার্ড — রিভিউ',
                                  scoreLabel: 'XP: $_xp',
                                  stats: [
                                    'দিন দেখা: ${_seen.length}/${_weekdays.length}',
                                    'ফ্লিপ: $_flips',
                                  ],
                                  missed: const [],
                                  onPlayAgain: () {
                                    setState(() {
                                      _xp = 0;
                                      _flips = 0;
                                      _seen.clear();
                                      _seen.add(0);
                                      _i = 0;
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
                  decoration: _card(radius: 22),
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
                          child: _WeekFlipFace(
                            key: ValueKey(_i),
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
                    onPressed: _i == 0 ? null : () => _go(-1),
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
                    onPressed:
                        _i >= _weekdays.length - 1 ? null : () => _go(1),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white),
                    icon: const Icon(Icons.navigate_next_rounded),
                    label: const Text('পরেরটি',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ]),
        ],
      ),
    );
  }
}

class _WeekQuizGame extends StatefulWidget {
  const _WeekQuizGame({super.key});
  @override
  State<_WeekQuizGame> createState() => _WeekQuizGameState();
}

class _WeekQuizGameState extends State<_WeekQuizGame>
    with TickerProviderStateMixin {
  final _rng = math.Random();
  final _tts = JlcTts();
  late ConfettiController _confetti;
  late AnimationController _shakeCtrl;
  bool _ttsReady = false;
  bool _slowMode = false;

  late _Weekday _target;
  late List<_Weekday> _options;
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
    _confetti =
        ConfettiController(duration: const Duration(milliseconds: 650));
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
    await _tts.speak(_target.kana);
  }

  void _next({bool speak = true}) {
    final t = _weekdays[_rng.nextInt(_weekdays.length)];
    final pool = _weekdays.where((e) => e.jp != t.jp).toList()..shuffle(_rng);
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

  void _pick(_Weekday p) {
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
              decoration: _card(),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: Color(0xFFFFE000)),
                  const SizedBox(width: 8),
                  Text('স্কোর: $_score',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 10),
                  _WeekStatChip(label: 'স্ট্রিক', value: '$_streak'),
                  const SizedBox(width: 6),
                  _WeekStatChip(label: 'সেরা', value: '$_bestStreak'),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: _attempts == 0
                        ? null
                        : () => _showWeekAwesomeResult(
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
                decoration: _card(radius: 18),
                child: Column(
                  children: [
                    const Text('এই জাপানি দিনটির বাংলা কোনটি?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Text(_target.jp,
                        style: const TextStyle(
                            color: Color(0xFFFFE000),
                            fontSize: 44,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(_target.kana,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontWeight: FontWeight.w700,
                            fontSize: 20)),
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

class _DayPair {
  final String keyId;
  final String label;
  const _DayPair({required this.keyId, required this.label});
}

class _WeekMatchGame extends StatefulWidget {
  const _WeekMatchGame({super.key});
  @override
  State<_WeekMatchGame> createState() => _WeekMatchGameState();
}

class _WeekMatchGameState extends State<_WeekMatchGame>
    with TickerProviderStateMixin {
  final _rng = math.Random();
  final _tts = JlcTts();
  late ConfettiController _confetti;
  late AnimationController _shakeCtrl;
  bool _ttsReady = false;

  late List<_DayPair> _jpColumn;
  late List<_DayPair> _bnColumn;
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

  Future<void> _speak(String key) async {
    if (!_ttsReady) return;
    final day = _weekdays.firstWhere((d) => d.jp == key);
    await _tts.stop();
    await _tts.speak(day.kana);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _reset() {
    final jp = <_DayPair>[];
    final bn = <_DayPair>[];
    for (final d in _weekdays) {
      jp.add(_DayPair(keyId: d.jp, label: '${d.jp}\n(${d.bnPronunciation})'));
      bn.add(_DayPair(keyId: d.jp, label: d.bn));
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
          _showWeekAwesomeResult(
            context: context,
            title: 'ডে ম্যাচ — সব মিলেছে',
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

  Widget _buildCard(_DayPair c, int idx, bool isJp) {
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
                    fontSize: isJp ? 18 : 18,
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
              decoration: _card(),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.link_rounded,
                          color: Color(0xFFFFE000)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('জাপানি ↔ বাংলা দিন মিলাও',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900)),
                      ),
                      _WeekStatChip(label: 'XP', value: '$_xp'),
                      const SizedBox(width: 6),
                      _WeekStatChip(label: 'স্ট্রিক', value: '$_streak'),
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
                    side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2)),
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

class _WeekSequenceGame extends StatefulWidget {
  const _WeekSequenceGame({super.key});

  @override
  State<_WeekSequenceGame> createState() => _WeekSequenceGameState();
}

class _WeekSequenceGameState extends State<_WeekSequenceGame>
    with TickerProviderStateMixin {
  final _rng = math.Random();
  final _tts = JlcTts();
  late ConfettiController _confetti;
  late AnimationController _shakeCtrl;
  Timer? _timer;
  static const _totalRounds = 10;
  static const _totalSeconds = 60;
  static const _sessionXpBonus = 50;

  int _round = 1;
  int _timeLeft = _totalSeconds;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _attempts = 0;
  int _correct = 0;
  bool _ttsReady = false;
  bool _slowMode = false;
  final Map<String, int> _missed = {};
  late _Weekday _current;
  late _Weekday _correctNext;
  late List<_Weekday> _options;
  String? _picked;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 650));
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _initTts();
    _buildRound(reset: true);
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
    await _tts.speak(_current.kana);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timeLeft <= 1) {
        timer.cancel();
        _showResult();
      } else {
        setState(() => _timeLeft -= 1);
      }
    });
  }

  void _buildRound({bool reset = false}) {
    if (reset) {
      _round = 1;
      _score = 0;
      _streak = 0;
      _bestStreak = 0;
      _timeLeft = _totalSeconds;
      _attempts = 0;
      _correct = 0;
      _missed.clear();
    }
    final idx = _rng.nextInt(_weekdays.length);
    final now = _weekdays[idx];
    final next = _weekdays[(idx + 1) % _weekdays.length];
    final pool =
        _weekdays.where((d) => d.jp != next.jp).toList()..shuffle(_rng);
    setState(() {
      _current = now;
      _correctNext = next;
      _options = [next, ...pool.take(3)]..shuffle(_rng);
      _picked = null;
    });
    if (_ttsReady) {
      // ignore: discarded_futures
      _speak();
    }
  }

  void _pick(_Weekday day) {
    if (_picked != null) return;
    final ok = day.jp == _correctNext.jp;
    setState(() {
      _picked = day.jp;
      _attempts += 1;
      if (ok) {
        _streak += 1;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _score += 10;
        _correct += 1;
      } else {
        _streak = 0;
        _missed[_correctNext.jp] = (_missed[_correctNext.jp] ?? 0) + 1;
      }
    });
    if (ok) {
      HapticFeedback.mediumImpact();
      _confetti.play();
    } else {
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0);
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      if (_round >= _totalRounds) {
        _showResult();
      } else {
        _round += 1;
        _buildRound();
      }
    });
  }

  void _showResult() {
    _timer?.cancel();
    _showWeekAwesomeResult(
      context: context,
      title: 'নেক্সট ডে — রেজাল্ট',
      scoreLabel: 'XP: ${_score + _sessionXpBonus}',
      stats: [
        'রাউন্ড: $_round/$_totalRounds',
        'চেষ্টা: $_attempts',
        'সঠিক: $_correct',
        'নির্ভুলতা: ${_attempts == 0 ? 0 : ((_correct * 100) / _attempts).round()}%',
        'সেরা স্ট্রিক: $_bestStreak',
        'সেশন বোনাস: +$_sessionXpBonus XP',
      ],
      missed: _missed.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
      onPlayAgain: () {
        _buildRound(reset: true);
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
    final roundProgress = _round / _totalRounds;
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
                decoration: _card(),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.speed_rounded,
                            color: Color(0xFFFFE000)),
                        const SizedBox(width: 8),
                        Text('রাউন্ড: $_round/$_totalRounds',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(width: 10),
                        _WeekStatChip(label: 'স্কোর', value: '$_score'),
                        const SizedBox(width: 6),
                        _WeekStatChip(label: 'সেরা', value: '$_bestStreak'),
                        const Spacer(),
                        Icon(Icons.timer_rounded,
                            size: 16,
                            color: _timeLeft <= 5
                                ? const Color(0xFFFF6B6B)
                                : const Color(0xFFFFE000)),
                        const SizedBox(width: 4),
                        Text('${_timeLeft}s',
                            style: TextStyle(
                                color: _timeLeft <= 5
                                    ? const Color(0xFFFFB4B4)
                                    : const Color(0xFFFFE000),
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(99),
                      value: roundProgress.clamp(0, 1),
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFFFFE000)),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(99),
                      value: timeProgress.clamp(0, 1),
                      backgroundColor: Colors.white.withValues(alpha: 0.10),
                      valueColor: AlwaysStoppedAnimation(_timeLeft <= 5
                          ? const Color(0xFFFF6B6B)
                          : const Color(0xFF3B82F6)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: _shakeCtrl,
                builder: (_, child) {
                  final wrong = _picked != null && _picked != _correctNext.jp;
                  final dx = wrong
                      ? math.sin(_shakeCtrl.value * math.pi * 6) * 8
                      : 0.0;
                  return Transform.translate(
                      offset: Offset(dx, 0), child: child);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: _card(radius: 18),
                  child: Column(
                    children: [
                      const Text('এই দিনের পরের দিন কোনটি?',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      Text(_current.jp,
                          style: const TextStyle(
                              color: Color(0xFFFFE000),
                              fontWeight: FontWeight.w900,
                              fontSize: 44)),
                      Text('${_current.kana} • ${_current.bnPronunciation}',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.84),
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
                                    color:
                                        Colors.white.withValues(alpha: 0.2)),
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
                    final correct = o.jp == _correctNext.jp;
                    final bg = _picked == null
                        ? Colors.white.withValues(alpha: 0.06)
                        : (correct
                            ? const Color(0xFF10B981).withValues(alpha: 0.22)
                            : (picked
                                ? const Color(0xFFEF4444)
                                    .withValues(alpha: 0.22)
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
                                child: Text(
                                    '${o.jp}  (${o.bnPronunciation})',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 22)),
                              ),
                            ],
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

// ═════════════════════════════════════════════════════════════════════
// শুনে বলো — Listening MCQ: TTS plays JP, pick Bengali day name
// ═════════════════════════════════════════════════════════════════════

class _WeekListenGame extends StatefulWidget {
  const _WeekListenGame({super.key});
  @override
  State<_WeekListenGame> createState() => _WeekListenGameState();
}

class _WeekListenGameState extends State<_WeekListenGame>
    with TickerProviderStateMixin {
  static const _teal = Color(0xFF14B8A6);
  static const _totalRounds = 8;
  static const _sessionXpBonus = 50;

  final _rng = math.Random();
  final _tts = JlcTts();
  late final Future<void> _ttsReady;
  late ConfettiController _confetti;
  late AnimationController _shakeCtrl;

  late _Weekday _target;
  late List<_Weekday> _options;
  int _roundIdx = 0;
  int? _pickedIdx;
  bool _locked = false;
  bool _slowMode = false;
  bool _showCorrectBanner = false;

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
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
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
    await _tts.speak(_target.kana);
  }

  List<int> _deck = [];
  int? _lastTargetIdx;

  void _newSession() {
    _roundIdx = 0;
    _correct = 0;
    _totalAttempts = 0;
    _xp = 0;
    _streak = 0;
    _bestStreak = 0;
    _missed.clear();
    _deck = [];
    _lastTargetIdx = null;
    _sessionTimer
      ..reset()
      ..start();
    _buildRound();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speak());
  }

  int _drawTargetIdx() {
    if (_deck.isEmpty) {
      _deck = List<int>.generate(_weekdays.length, (i) => i)..shuffle(_rng);
      if (_lastTargetIdx != null &&
          _deck.length > 1 &&
          _deck.first == _lastTargetIdx) {
        _deck.add(_deck.removeAt(0));
      }
    }
    final idx = _deck.removeAt(0);
    _lastTargetIdx = idx;
    return idx;
  }

  void _buildRound() {
    final targetIdx = _drawTargetIdx();
    _target = _weekdays[targetIdx];
    final pool = List<int>.generate(_weekdays.length, (i) => i)
        .where((i) => i != targetIdx)
        .toList()
      ..shuffle(_rng);
    final selected = <int>{targetIdx, ...pool.take(3)};
    final shuffledIdx = selected.toList()..shuffle(_rng);
    setState(() {
      _options = shuffledIdx.map((i) => _weekdays[i]).toList();
      _locked = false;
      _pickedIdx = null;
      _showCorrectBanner = false;
    });
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _pick(int idx) {
    if (_locked) return;
    final o = _options[idx];
    _totalAttempts += 1;
    final ok = o.bn == _target.bn;
    setState(() {
      _locked = true;
      _pickedIdx = idx;
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
        final ti = _weekdays.indexOf(_target);
        _missed[ti] = (_missed[ti] ?? 0) + 1;
      });
      _shakeCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          _pickedIdx = null;
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
      builder: (_) => _WeekAwesomeResultSheet(
        title: 'শুনে বলো — সেশন শেষ',
        scoreLabel: 'মোট XP: $_xp',
        stats: [
          'সঠিক: $_correct/$_totalRounds',
          'নির্ভুলতা: $acc%',
          'সেরা স্ট্রিক: $_bestStreak',
          'সময়: ${_fmt(_sessionTimer.elapsed)}',
        ],
        missed: _missed.entries.map((e) {
          final w = _weekdays[e.key];
          return '${w.bnPronunciation} — ${w.bn}  ×${e.value}';
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
          _WeekConfettiOverlay(controller: _confetti, accent: _teal),
          Column(
            children: [
              _WeekHeaderPanel(
                color: _teal,
                title: 'শুনে বলো — অডিও শুনে বার বাছুন',
                progress: progress,
                roundText: 'রাউন্ড ${_roundIdx + 1}/$_totalRounds',
                xp: _xp,
                streak: _streak,
                timer: _fmt(_sessionTimer.elapsed),
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
                        child: const Text('অডিও শুনুন',
                            style: TextStyle(
                              color: _teal,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            )),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _target.bnPronunciation,
                        style: const TextStyle(
                          color: Color(0xFFFFE000),
                          fontSize: 28,
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
                'এই বারের বাংলা নাম কোনটি?',
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
                      _WeekOptionTile(
                        label: _options[i].bn,
                        sublabel: _options[i].bnPronunciation,
                        picked: _pickedIdx == i,
                        isCorrect: _options[i].bn == _target.bn,
                        revealed: _pickedIdx != null,
                        onTap: _locked ? null : () => _pick(i),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          _WeekCorrectBanner(
            visible: _showCorrectBanner,
            streak: _streak,
            text: '${_target.bnPronunciation} → ${_target.bn}',
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// পড়ে বলো — Reading MCQ: BN day → JP (BN pronunciation) + Heijitsu/Shumatsu concepts
// ═════════════════════════════════════════════════════════════════════

class _WeekReadGame extends StatefulWidget {
  const _WeekReadGame({super.key});
  @override
  State<_WeekReadGame> createState() => _WeekReadGameState();
}

class _WeekReadGameState extends State<_WeekReadGame>
    with TickerProviderStateMixin {
  static const _violet = Color(0xFF8B5CF6);
  static const _totalRounds = 8;
  static const _sessionXpBonus = 50;

  final _rng = math.Random();
  late ConfettiController _confetti;
  late AnimationController _shakeCtrl;
  late AnimationController _cardCtrl;

  bool _isConcept = false;
  late _WeekConcept _concept;
  late _Weekday _target;
  late List<String> _options;
  late int _correctOptionIdx;
  int _roundIdx = 0;
  int? _pickedIdx;
  bool _locked = false;
  bool _showCorrectBanner = false;
  bool _showExplanation = false;

  final Stopwatch _sessionTimer = Stopwatch();
  int _correct = 0;
  int _totalAttempts = 0;
  int _xp = 0;
  int _streak = 0;
  int _bestStreak = 0;
  final Map<String, int> _missed = {};

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 650));
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _newSession();
  }

  List<int> _dayDeck = [];
  List<int> _conceptDeck = [];
  int? _lastDayIdx;
  int? _lastConceptIdx;

  void _newSession() {
    _roundIdx = 0;
    _correct = 0;
    _totalAttempts = 0;
    _xp = 0;
    _streak = 0;
    _bestStreak = 0;
    _missed.clear();
    _dayDeck = [];
    _conceptDeck = [];
    _lastDayIdx = null;
    _lastConceptIdx = null;
    _sessionTimer
      ..reset()
      ..start();
    _buildRound();
  }

  int _drawDayIdx() {
    if (_dayDeck.isEmpty) {
      _dayDeck = List<int>.generate(_weekdays.length, (i) => i)..shuffle(_rng);
      if (_lastDayIdx != null &&
          _dayDeck.length > 1 &&
          _dayDeck.first == _lastDayIdx) {
        _dayDeck.add(_dayDeck.removeAt(0));
      }
    }
    final idx = _dayDeck.removeAt(0);
    _lastDayIdx = idx;
    return idx;
  }

  int _drawConceptIdx() {
    if (_conceptDeck.isEmpty) {
      _conceptDeck =
          List<int>.generate(_weekConcepts.length, (i) => i)..shuffle(_rng);
      if (_lastConceptIdx != null &&
          _conceptDeck.length > 1 &&
          _conceptDeck.first == _lastConceptIdx) {
        _conceptDeck.add(_conceptDeck.removeAt(0));
      }
    }
    final idx = _conceptDeck.removeAt(0);
    _lastConceptIdx = idx;
    return idx;
  }

  void _buildRound() {
    // ~35% concept, 65% direct translation rounds.
    _isConcept = _rng.nextInt(100) < 35;
    if (_isConcept) {
      _concept = _weekConcepts[_drawConceptIdx()];
      // Shuffle the concept options while tracking the correct index.
      final indexed = List<int>.generate(_concept.options.length, (i) => i)..shuffle(_rng);
      _options = indexed.map((i) => _concept.options[i]).toList();
      _correctOptionIdx = indexed.indexOf(_concept.correctIdx);
    } else {
      final targetIdx = _drawDayIdx();
      _target = _weekdays[targetIdx];
      final pool = List<int>.generate(_weekdays.length, (i) => i)
          .where((i) => i != targetIdx)
          .toList()
        ..shuffle(_rng);
      final selected = <int>{targetIdx, ...pool.take(3)}.toList()..shuffle(_rng);
      _options = selected.map((i) => _weekdays[i].bnPronunciation).toList();
      _correctOptionIdx = selected.indexOf(targetIdx);
    }
    setState(() {
      _locked = false;
      _pickedIdx = null;
      _showCorrectBanner = false;
      _showExplanation = false;
    });
    _cardCtrl.forward(from: 0);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _bannerText {
    if (_isConcept) return _concept.options[_concept.correctIdx];
    return '${_target.bn} → ${_target.bnPronunciation}';
  }

  String get _missKey {
    if (_isConcept) return 'C:${_concept.prompt}';
    return 'W:${_target.bn}';
  }

  void _pick(int idx) {
    if (_locked) return;
    _totalAttempts += 1;
    final ok = idx == _correctOptionIdx;
    setState(() {
      _locked = true;
      _pickedIdx = idx;
    });
    if (ok) {
      HapticFeedback.mediumImpact();
      setState(() {
        _correct += 1;
        _streak += 1;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _xp += 10;
        _showCorrectBanner = true;
        _showExplanation = _isConcept;
      });
      _confetti.play();
      Future.delayed(const Duration(milliseconds: 1500), () {
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
        _missed[_missKey] = (_missed[_missKey] ?? 0) + 1;
        if (_isConcept) _showExplanation = true;
      });
      _shakeCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          _pickedIdx = null;
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
      builder: (_) => _WeekAwesomeResultSheet(
        title: 'পড়ে বলো — সেশন শেষ',
        scoreLabel: 'মোট XP: $_xp',
        stats: [
          'সঠিক: $_correct/$_totalRounds',
          'নির্ভুলতা: $acc%',
          'সেরা স্ট্রিক: $_bestStreak',
          'সময়: ${_fmt(_sessionTimer.elapsed)}',
        ],
        missed: _missed.entries.map((e) {
          if (e.key.startsWith('W:')) {
            final bn = e.key.substring(2);
            final w = _weekdays.firstWhere((x) => x.bn == bn);
            return '${w.bn} → ${w.bnPronunciation}  ×${e.value}';
          }
          return 'কনসেপ্ট: ${e.key.substring(2)}  ×${e.value}';
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
          _WeekConfettiOverlay(controller: _confetti, accent: _violet),
          Column(
            children: [
              _WeekHeaderPanel(
                color: _violet,
                title: 'পড়ে বলো — পড়ে বুঝে সঠিক উত্তর',
                progress: progress,
                roundText: 'রাউন্ড ${_roundIdx + 1}/$_totalRounds',
                xp: _xp,
                streak: _streak,
                timer: _fmt(_sessionTimer.elapsed),
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
                        Icon(
                          _isConcept ? _concept.icon : Icons.calendar_month_rounded,
                          color: _isConcept ? _concept.color : Colors.white,
                          size: 44,
                        ),
                        const SizedBox(height: 8),
                        if (_isConcept)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _concept.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: _concept.color.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              '🧠 কনসেপ্ট',
                              style: TextStyle(
                                color: _concept.color,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        if (_isConcept) const SizedBox(height: 8),
                        Text(
                          _isConcept ? _concept.prompt : '${_target.bn} — জাপানিতে কী?',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            height: 1.3,
                          ),
                        ),
                        if (_showExplanation && _isConcept) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              _concept.explanation,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
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
                'সঠিক উত্তর কোনটি?',
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
                      if (i != 0) const SizedBox(height: 8),
                      _WeekOptionTile(
                        label: _options[i],
                        sublabel: '',
                        picked: _pickedIdx == i,
                        isCorrect: i == _correctOptionIdx,
                        revealed: _pickedIdx != null,
                        onTap: _locked ? null : () => _pick(i),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          _WeekCorrectBanner(
            visible: _showCorrectBanner,
            streak: _streak,
            text: _bannerText,
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// বলে দেখাও — Speaking: Show BN day, user speaks JP, STT evaluates
// ═════════════════════════════════════════════════════════════════════

class _WeekSpeakGame extends StatefulWidget {
  const _WeekSpeakGame({super.key});
  @override
  State<_WeekSpeakGame> createState() => _WeekSpeakGameState();
}

class _WeekSpeakGameState extends State<_WeekSpeakGame>
    with TickerProviderStateMixin {
  static const _rose = Color(0xFFE11D48);
  static const _maxSeconds = 6;
  static const _totalRounds = 7;
  static const _sessionXpBonus = 50;

  final _rng = math.Random();
  final _tts = JlcTts();
  final _stt = JlcStt();
  bool _sttReady = false;
  bool _ttsReady = false;
  String? _locale;
  String? _error;
  bool _listening = false;
  String _heard = '';
  double _soundLevel = 0;
  int _secondsLeft = 0;
  Timer? _recordTimer;

  late _Weekday _target;
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
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
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
  int? _lastSpeakIdx;

  int _drawSpeakIdx() {
    if (_speakDeck.isEmpty) {
      _speakDeck = List<int>.generate(_weekdays.length, (i) => i)..shuffle(_rng);
      if (_lastSpeakIdx != null &&
          _speakDeck.length > 1 &&
          _speakDeck.first == _lastSpeakIdx) {
        _speakDeck.add(_speakDeck.removeAt(0));
      }
    }
    final idx = _speakDeck.removeAt(0);
    _lastSpeakIdx = idx;
    return idx;
  }

  void _newRound() {
    final idx = _drawSpeakIdx();
    setState(() {
      _target = _weekdays[idx];
      _heard = '';
      _lastScore = null;
      _evaluated = false;
      _showHint = false;
      _error = null;
    });
  }

  // Acceptable forms for each weekday (index = weekday list index).
  static const _accepts = <int, List<String>>{
    0: ['げつようび', 'getsuyoubi', 'getsuyobi', '月曜日', 'げつよう'],
    1: ['かようび', 'kayoubi', 'kayobi', '火曜日', 'かよう'],
    2: ['すいようび', 'suiyoubi', 'suiyobi', '水曜日', 'すいよう'],
    3: ['もくようび', 'mokuyoubi', 'mokuyobi', '木曜日', 'もくよう'],
    4: ['きんようび', 'kinyoubi', 'kinyobi', '金曜日', 'きんよう'],
    5: ['どようび', 'doyoubi', 'doyobi', '土曜日', 'どよう'],
    6: ['にちようび', 'nichiyoubi', 'nichiyobi', '日曜日', 'にちよう'],
  };

  static String _normJp(String s) {
    var out = s.toLowerCase();
    final buf = StringBuffer();
    for (final r in out.runes) {
      if (r >= 0xFF10 && r <= 0xFF19) {
        buf.writeCharCode(r - 0xFF10 + 0x30);
        continue;
      }
      if (r == 0x30FC) continue;
      const smallToBig = {
        0x3041: 0x3042, 0x3043: 0x3044, 0x3045: 0x3046,
        0x3047: 0x3048, 0x3049: 0x304A,
        0x30A1: 0x30A2, 0x30A3: 0x30A4, 0x30A5: 0x30A6,
        0x30A7: 0x30A8, 0x30A9: 0x30AA,
      };
      if (r == 0x3001 || r == 0x3002 || r == 0x002E ||
          r == 0x002C || r == 0x0020) continue;
      buf.writeCharCode(smallToBig[r] ?? r);
    }
    return buf.toString();
  }

  int _grade(String raw, int targetIdx) {
    final heard = _normJp(raw);
    if (heard.isEmpty) return 0;
    final accepts = (_accepts[targetIdx] ?? <String>[]).map(_normJp).toList();
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
    final targetIdx = _weekdays.indexOf(_target);
    final score = _grade(_heard, targetIdx);
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
        _missed[targetIdx] = (_missed[targetIdx] ?? 0) + 1;
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
    await _tts.speak(_target.kana);
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

  String _fmt(Duration d) {
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
      builder: (_) => _WeekAwesomeResultSheet(
        title: 'বলে দেখাও — সেশন শেষ',
        scoreLabel: 'মোট XP: $_xp',
        stats: [
          'সঠিক: $_correct/$_totalRounds',
          'নির্ভুলতা: $acc%',
          'সেরা স্ট্রিক: $_bestStreak',
          'সময়: ${_fmt(_sessionTimer.elapsed)}',
        ],
        missed: _missed.entries.map((e) {
          final w = _weekdays[e.key];
          return '${w.bn} — ${w.bnPronunciation}  ×${e.value}';
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
            _lastSpeakIdx = null;
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
          _WeekConfettiOverlay(controller: _confetti, accent: _rose),
          Column(
            children: [
              _WeekHeaderPanel(
                color: _rose,
                title: 'বলে দেখাও — বাংলা দেখে জাপানিতে বলুন',
                progress: progress,
                roundText: 'রাউন্ড ${_roundIdx + 1}/$_totalRounds',
                xp: _xp,
                streak: _streak,
                timer: _fmt(_sessionTimer.elapsed),
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
                      const Icon(Icons.calendar_month_rounded,
                          color: _rose, size: 38),
                      const SizedBox(height: 8),
                      Text(
                        _target.bn,
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
                            _target.bnPronunciation,
                            style: const TextStyle(
                              color: Color(0xFFFFE000),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_target.jp}  •  ${_target.kana}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 13,
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
                              color: (_listening ? const Color(0xFFEF4444) : _rose)
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(_showHint
                          ? Icons.visibility_off_rounded
                          : Icons.lightbulb_rounded),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
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
// ক্রম বলো — Sequential speaking: say all 7 days in order, evaluate per slot
// ═════════════════════════════════════════════════════════════════════

enum _WeekSlotStatus { pending, correct, wrong, missed }

class _WeekSlotResult {
  const _WeekSlotResult({required this.expected, required this.heardIdx, required this.status});
  final _Weekday expected;
  final int? heardIdx; // index into _weekdays
  final _WeekSlotStatus status;
}

class _WeekSeqSpeakGame extends StatefulWidget {
  const _WeekSeqSpeakGame({super.key});
  @override
  State<_WeekSeqSpeakGame> createState() => _WeekSeqSpeakGameState();
}

class _WeekSeqSpeakGameState extends State<_WeekSeqSpeakGame>
    with TickerProviderStateMixin {
  static const _amber = Color(0xFFF59E0B);
  static const _maxSeconds = 20;

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

  late List<_WeekSlotResult> _results;
  List<int> _extras = const [];
  bool _evaluated = false;

  int _xp = 0;
  int _attempts = 0;
  int _bestCorrect = 0;
  final Stopwatch _sessionTimer = Stopwatch();

  late ConfettiController _confetti;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _results = _weekdays
        .map((w) => _WeekSlotResult(
            expected: w, heardIdx: null, status: _WeekSlotStatus.pending))
        .toList();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 900));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _sessionTimer.start();
    _initTts();
    _initStt();
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _confetti.dispose();
    _pulseCtrl.dispose();
    _stt.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.42);
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

  // ─── Match a token to a weekday index (0..6) ─────────────────────
  static const _wordTable = <String, int>{
    // Monday
    'げつようび': 0, 'getsuyoubi': 0, 'getsuyobi': 0, '月曜日': 0, 'げつよう': 0, 'げつ': 0,
    // Tuesday
    'かようび': 1, 'kayoubi': 1, 'kayobi': 1, '火曜日': 1, 'かよう': 1, 'か': 1,
    // Wednesday
    'すいようび': 2, 'suiyoubi': 2, 'suiyobi': 2, '水曜日': 2, 'すいよう': 2, 'すい': 2,
    // Thursday
    'もくようび': 3, 'mokuyoubi': 3, 'mokuyobi': 3, '木曜日': 3, 'もくよう': 3, 'もく': 3,
    // Friday
    'きんようび': 4, 'kinyoubi': 4, 'kinyobi': 4, '金曜日': 4, 'きんよう': 4, 'きん': 4,
    // Saturday
    'どようび': 5, 'doyoubi': 5, 'doyobi': 5, '土曜日': 5, 'どよう': 5, 'ど': 5,
    // Sunday
    'にちようび': 6, 'nichiyoubi': 6, 'nichiyobi': 6, '日曜日': 6, 'にちよう': 6, 'にち': 6,
  };

  static String _normalize(String s) {
    var out = s.toLowerCase();
    final buf = StringBuffer();
    for (final r in out.runes) {
      if (r >= 0xFF10 && r <= 0xFF19) {
        buf.writeCharCode(r - 0xFF10 + 0x30);
        continue;
      }
      if (r == 0x30FC) continue;
      const smallToBig = {
        0x3041: 0x3042, 0x3043: 0x3044, 0x3045: 0x3046,
        0x3047: 0x3048, 0x3049: 0x304A,
        0x30A1: 0x30A2, 0x30A3: 0x30A4, 0x30A5: 0x30A6,
        0x30A7: 0x30A8, 0x30A9: 0x30AA,
      };
      buf.writeCharCode(smallToBig[r] ?? r);
    }
    return buf.toString();
  }

  List<int> _parseHeard(String raw) {
    final cleaned = _normalize(raw)
        .replaceAll(RegExp(r'[、。,.!?・〜\-‐–—()\[\]「」]'), ' ');
    final tokens = cleaned.split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
    final out = <int>[];
    for (final t in tokens) {
      final exact = _wordTable[t];
      if (exact != null) {
        out.add(exact);
        continue;
      }
      // Greedy substring scan for concatenated speech.
      int i = 0;
      while (i < t.length) {
        bool matched = false;
        final maxLen = math.min(8, t.length - i);
        for (int len = maxLen; len >= 1 && !matched; len--) {
          final sub = t.substring(i, i + len);
          final n = _wordTable[sub];
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
    final entries = <_WeekSlotResult>[];
    int correctCount = 0;
    for (var i = 0; i < _weekdays.length; i++) {
      if (i >= heard.length) {
        entries.add(_WeekSlotResult(
            expected: _weekdays[i],
            heardIdx: null,
            status: _WeekSlotStatus.missed));
        continue;
      }
      final h = heard[i];
      if (h == i) {
        entries.add(_WeekSlotResult(
            expected: _weekdays[i],
            heardIdx: h,
            status: _WeekSlotStatus.correct));
        correctCount++;
      } else {
        entries.add(_WeekSlotResult(
            expected: _weekdays[i],
            heardIdx: h,
            status: _WeekSlotStatus.wrong));
      }
    }
    final extras = heard.length > _weekdays.length
        ? heard.sublist(_weekdays.length)
        : const <int>[];

    _attempts += 1;
    if (correctCount > _bestCorrect) _bestCorrect = correctCount;
    // XP: +10 per correct slot, +50 bonus for perfect run.
    final delta = correctCount * 10 + (correctCount == 7 ? 50 : 0);
    _xp += delta;

    setState(() {
      _results = entries;
      _extras = extras;
      _evaluated = true;
    });

    if (correctCount == 7 && extras.isEmpty) {
      HapticFeedback.heavyImpact();
      _confetti.play();
    } else if (correctCount >= 5) {
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
      _results = _weekdays
          .map((w) => _WeekSlotResult(
              expected: w, heardIdx: null, status: _WeekSlotStatus.pending))
          .toList();
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
    _evaluate(_parseHeard(_heard));
  }

  Future<void> _speakAll() async {
    if (!_ttsReady) return;
    HapticFeedback.selectionClick();
    await _tts.stop();
    for (final w in _weekdays) {
      if (!mounted) return;
      await _tts.speak(w.kana);
      await Future.delayed(const Duration(milliseconds: 320));
    }
  }

  Future<void> _speakMistakes() async {
    if (!_ttsReady) return;
    HapticFeedback.selectionClick();
    await _tts.stop();
    final mistakes = _results.where((r) =>
        r.status == _WeekSlotStatus.wrong || r.status == _WeekSlotStatus.missed);
    for (final r in mistakes) {
      if (!mounted) return;
      await _tts.speak(r.expected.kana);
      await Future.delayed(const Duration(milliseconds: 380));
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final correctCount =
        _results.where((r) => r.status == _WeekSlotStatus.correct).length;
    final wrongCount =
        _results.where((r) => r.status == _WeekSlotStatus.wrong).length;
    final missedCount =
        _results.where((r) => r.status == _WeekSlotStatus.missed).length;
    final accuracy =
        _evaluated ? ((correctCount * 100) / _weekdays.length).round() : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _WeekConfettiOverlay(controller: _confetti, accent: _amber),
          Column(
            children: [
              _WeekHeaderPanel(
                color: _amber,
                title: 'ক্রম বলো — সোম থেকে রবি একবারে বলুন',
                progress: _evaluated ? correctCount / _weekdays.length : 0,
                roundText: _evaluated
                    ? 'সঠিক: $correctCount/${_weekdays.length}'
                    : 'মাইক চাপুন',
                xp: _xp,
                streak: _bestCorrect,
                timer: _listening ? '$_secondsLeft s' : _fmt(_sessionTimer.elapsed),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF111827)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _amber.withValues(alpha: 0.55), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _amber.withValues(alpha: 0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (!_listening && !_evaluated)
                      Text(
                        'গেৎসুওবি → কায়োবি → … → নিচিয়োবি একবারে বলুন',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    const SizedBox(height: 8),
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
                                      : const [_amber, Color(0xFFB45309)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_listening ? const Color(0xFFEF4444) : _amber)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 22,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _listening ? Icons.stop_rounded : Icons.mic_rounded,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _listening ? 'শুনছি — বলতে থাকুন…' : (_evaluated ? 'আবার চেষ্টা' : 'মাইক চাপুন'),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        child: Text(
                          _heard,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFFE000),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
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
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (_evaluated)
                Row(
                  children: [
                    _summaryChip(
                        label: 'সঠিক',
                        value: '$correctCount',
                        color: const Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    _summaryChip(
                        label: 'ভুল',
                        value: '$wrongCount',
                        color: const Color(0xFFEF4444)),
                    const SizedBox(width: 8),
                    _summaryChip(
                        label: 'বাদ',
                        value: '$missedCount',
                        color: const Color(0xFFF59E0B)),
                    if (_extras.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _summaryChip(
                          label: 'অতিরিক্ত',
                          value: '${_extras.length}',
                          color: const Color(0xFF8B5CF6)),
                    ],
                  ],
                ),
              if (_evaluated)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'নির্ভুলতা: $accuracy%',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              if (_evaluated) const SizedBox(height: 8),
              Expanded(child: _buildSlotsList()),
              if (_evaluated) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _ttsReady ? _speakAll : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
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
                          backgroundColor: _amber,
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
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryChip({required String label, required String value, required Color color}) {
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
                    fontSize: 17,
                    fontWeight: FontWeight.w900)),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotsList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _results.length,
      itemBuilder: (_, i) {
        final r = _results[i];
        Color color;
        IconData icon;
        String detail;
        switch (r.status) {
          case _WeekSlotStatus.correct:
            color = const Color(0xFF10B981);
            icon = Icons.check_circle_rounded;
            detail = 'বলেছেন ✓';
            break;
          case _WeekSlotStatus.wrong:
            final heard = _weekdays[r.heardIdx!];
            color = const Color(0xFFEF4444);
            icon = Icons.cancel_rounded;
            detail = 'বলেছেন: ${heard.bnPronunciation}';
            break;
          case _WeekSlotStatus.missed:
            color = const Color(0xFFF59E0B);
            icon = Icons.remove_circle_outline_rounded;
            detail = 'বাদ পড়েছে';
            break;
          case _WeekSlotStatus.pending:
            color = Colors.white.withValues(alpha: 0.3);
            icon = Icons.radio_button_unchecked_rounded;
            detail = 'অপেক্ষমাণ';
            break;
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
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
                    '${i + 1}',
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${r.expected.bn} — ${r.expected.bnPronunciation}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        detail,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(icon, color: color, size: 22),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// Shared widgets used by the new games
// ═════════════════════════════════════════════════════════════════════

class _WeekConfettiOverlay extends StatelessWidget {
  const _WeekConfettiOverlay({required this.controller, required this.accent});
  final ConfettiController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: IgnorePointer(
        child: SizedBox(
          height: 140,
          width: double.infinity,
          child: ConfettiWidget(
            confettiController: controller,
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 16,
            minBlastForce: 6,
            emissionFrequency: 0.08,
            numberOfParticles: 14,
            gravity: 0.22,
            shouldLoop: false,
            colors: [
              const Color(0xFFFFE000),
              const Color(0xFF10B981),
              accent,
              const Color(0xFF3B82F6),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekHeaderPanel extends StatelessWidget {
  const _WeekHeaderPanel({
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

class _WeekOptionTile extends StatelessWidget {
  const _WeekOptionTile({
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
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (sublabel.isNotEmpty)
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

class _WeekCorrectBanner extends StatelessWidget {
  const _WeekCorrectBanner({
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

class _WeekStatChip extends StatelessWidget {
  const _WeekStatChip({required this.label, required this.value});
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

class _WeekFlipFace extends StatelessWidget {
  const _WeekFlipFace({super.key, required this.item, required this.turns});
  final _Weekday item;
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
                    fontSize: 56,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Text(item.kana,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 24,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('উচ্চারণ: ${item.bnPronunciation}',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w700)),
          ],
        );

        final back = Text(
          item.bn,
          style: const TextStyle(
              color: Color(0xFFFFE000),
              fontSize: 50,
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

BoxDecoration _card({double radius = 16}) => BoxDecoration(
      color: const Color(0xFF1E293B),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
    );

void _showWeekAwesomeResult({
  required BuildContext context,
  required String title,
  required String scoreLabel,
  required List<String> stats,
  required List<MapEntry<String, int>> missed,
  required VoidCallback onPlayAgain,
}) {
  final missedLines = <String>[];
  for (final e in missed.take(6)) {
    final d = _weekdays.firstWhere((x) => x.jp == e.key);
    missedLines.add('${d.jp} (${d.bnPronunciation}) → ${d.bn}  ×${e.value}');
  }
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _WeekAwesomeResultSheet(
      title: title,
      scoreLabel: scoreLabel,
      stats: stats,
      missed: missedLines,
      onPlayAgain: onPlayAgain,
    ),
  );
}

class _WeekAwesomeResultSheet extends StatelessWidget {
  const _WeekAwesomeResultSheet({
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
