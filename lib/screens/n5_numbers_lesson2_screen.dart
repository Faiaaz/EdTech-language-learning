import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ez_trainz/utils/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:ez_trainz/services/jlc_tts.dart';
import 'package:get/get.dart';

class N5NumbersLesson2Screen extends StatefulWidget {
  const N5NumbersLesson2Screen({super.key});

  @override
  State<N5NumbersLesson2Screen> createState() => _N5NumbersLesson2ScreenState();
}

class _N5NumbersLesson2ScreenState extends State<N5NumbersLesson2Screen> {
  static const _bg = Colors.transparent;
  static const _card = AppColors.card;
  static const _muted = Color(0xFF94A3B8);
  static const _blue = Color(0xFF3B82F6);
  static const _yellow = Color(0xFFFFE000);

  final _tabs = const <_NumbersTab>[
    _NumbersTab.learn,
    _NumbersTab.falling,
    _NumbersTab.matching,
  ];
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'পাঠ ২: সংখ্যা',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '১–১০ জাপানিতে গোনা শিখুন + গেম খেলুন',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _TabPills(
                tabs: _tabs,
                index: _tab,
                onChange: (i) => setState(() => _tab = i),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: switch (_tabs[_tab]) {
                  _NumbersTab.learn => const _LearnNumbersView(key: ValueKey('learn')),
                  _NumbersTab.falling => const _FallingNumbersGame(key: ValueKey('fall')),
                  _NumbersTab.matching => const _TapTwinsGame(key: ValueKey('match')),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _NumbersTab { learn, falling, matching }

extension on _NumbersTab {
  String get label {
    switch (this) {
      case _NumbersTab.learn:
        return 'শিখুন';
      case _NumbersTab.falling:
        return 'ফলিং নাম্বার';
      case _NumbersTab.matching:
        return 'ম্যাচিং';
    }
  }
}

class _TabPills extends StatelessWidget {
  const _TabPills({
    required this.tabs,
    required this.index,
    required this.onChange,
  });

  final List<_NumbersTab> tabs;
  final int index;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bg),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            Expanded(
              child: GestureDetector(
                onTap: () => onChange(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: i == index
                        ? const Color(0xFF3B82F6)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      tabs[i].label,
                      style: TextStyle(
                        color: i == index ? Colors.white : AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (i != tabs.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _NumItem {
  final int n;
  final String kanji;
  final String kana;
  final String romaji;
  final String bnDigit;
  final String bnWord;
  const _NumItem({
    required this.n,
    required this.kanji,
    required this.kana,
    required this.romaji,
    required this.bnDigit,
    required this.bnWord,
  });
}

const _numbers = <_NumItem>[
  _NumItem(n: 1, kanji: '一', kana: 'いち', romaji: 'ichi', bnDigit: '১', bnWord: 'এক'),
  _NumItem(n: 2, kanji: '二', kana: 'に', romaji: 'ni', bnDigit: '২', bnWord: 'দুই'),
  _NumItem(n: 3, kanji: '三', kana: 'さん', romaji: 'san', bnDigit: '৩', bnWord: 'তিন'),
  _NumItem(n: 4, kanji: '四', kana: 'よん', romaji: 'yon', bnDigit: '৪', bnWord: 'চার'),
  _NumItem(n: 5, kanji: '五', kana: 'ご', romaji: 'go', bnDigit: '৫', bnWord: 'পাঁচ'),
  _NumItem(n: 6, kanji: '六', kana: 'ろく', romaji: 'roku', bnDigit: '৬', bnWord: 'ছয়'),
  _NumItem(n: 7, kanji: '七', kana: 'なな', romaji: 'nana', bnDigit: '৭', bnWord: 'সাত'),
  _NumItem(n: 8, kanji: '八', kana: 'はち', romaji: 'hachi', bnDigit: '৮', bnWord: 'আট'),
  _NumItem(n: 9, kanji: '九', kana: 'きゅう', romaji: 'kyuu', bnDigit: '৯', bnWord: 'নয়'),
  _NumItem(n: 10, kanji: '十', kana: 'じゅう', romaji: 'juu', bnDigit: '১০', bnWord: 'দশ'),
];

class _LearnNumbersView extends StatefulWidget {
  const _LearnNumbersView({super.key});

  @override
  State<_LearnNumbersView> createState() => _LearnNumbersViewState();
}

class _LearnNumbersViewState extends State<_LearnNumbersView> {
  static const _card = AppColors.card;
  static const _muted = Color(0xFF94A3B8);
  static const _yellow = Color(0xFFFFE000);

  final _tts = JlcTts();
  late final Future<void> _ttsReady;

  int _i = 0;

  @override
  void initState() {
    super.initState();
    _ttsReady = _initTts();
  }

  Future<void> _initTts() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(0.52);
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);
  }

  Future<void> _speak(_NumItem it) async {
    await _ttsReady;
    await _tts.stop();
    await _tts.speak('${it.kana}。');
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final it = _numbers[_i];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    it.kanji,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 92,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    it.kana,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          it.bnDigit,
                          style: const TextStyle(
                            color: Color(0xFFFFE000),
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          it.bnWord,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'শুনুন এবং মনে রাখুন',
                    style: TextStyle(
                      color: _muted.withValues(alpha: 0.95),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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
                child: OutlinedButton(
                  onPressed: _i == 0
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          setState(() => _i--);
                        },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.accentBlue.withValues(alpha: 0.5)),
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('আগেরটি',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _speak(it);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _yellow,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.volume_up_rounded),
                  label: const Text('শুনুন',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _i == _numbers.length - 1
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          setState(() => _i++);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('পরেরটি',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Falling Numbers (tap the correct Bangla)
// ─────────────────────────────────────────────────────────────────────────────

class _FallingNumbersGame extends StatefulWidget {
  const _FallingNumbersGame({super.key});

  @override
  State<_FallingNumbersGame> createState() => _FallingNumbersGameState();
}

class _FallingNumbersGameState extends State<_FallingNumbersGame>
    with SingleTickerProviderStateMixin {
  static const _bg = Colors.transparent;
  static const _card = AppColors.card;
  static const _muted = Color(0xFF94A3B8);
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);

  final _rng = math.Random();
  final _tts = JlcTts();
  late final Future<void> _ttsReady;

  late AnimationController _fall;
  late _NumItem _target;
  late List<_NumItem> _options;

  int _score = 0;
  int _lives = 3;
  bool _started = false;
  bool _locked = false;
  bool _answered = false;
  int? _pickedN;

  @override
  void initState() {
    super.initState();
    _ttsReady = _initTts();
    _fall = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          if (!_started || _locked || _answered) return;
          _miss();
        }
      });
    _nextRound(resetSpeed: true);
  }

  Future<void> _initTts() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(0.55);
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);
  }

  Future<void> _speak(_NumItem it) async {
    await _ttsReady;
    await _tts.stop();
    await _tts.speak('${it.kana}。');
  }

  void _nextRound({bool resetSpeed = false}) {
    final nextTarget = _numbers[_rng.nextInt(_numbers.length)];
    final pool =
        _numbers.where((e) => e.n != nextTarget.n).toList()..shuffle(_rng);
    final nextOptions = <_NumItem>[nextTarget, ...pool.take(3)]..shuffle(_rng);

    final nextDuration = resetSpeed
        ? const Duration(milliseconds: 2600)
        : Duration(
            milliseconds:
                (_fall.duration!.inMilliseconds - 120).clamp(1200, 2600),
          );

    if (!mounted) return;
    setState(() {
      _target = nextTarget;
      _options = nextOptions;
      _locked = false;
      _answered = false;
      _pickedN = null;
      _fall.duration = nextDuration;
    });

    _fall.forward(from: 0);
    // ignore: discarded_futures
    _speak(_target);
  }

  void _start() {
    HapticFeedback.mediumImpact();
    setState(() {
      _started = true;
      _locked = false;
      _answered = false;
      _pickedN = null;
      _score = 0;
      _lives = 3;
    });
    _nextRound(resetSpeed: true);
  }

  void _miss() {
    // Prevent double-miss triggers while transitioning rounds.
    _locked = true;
    HapticFeedback.heavyImpact();
    setState(() => _lives = (_lives - 1).clamp(0, 3));
    if (_lives <= 0) {
      _fall.stop();
      setState(() {
        _locked = true;
      });
      _showGameOver();
      return;
    }
    _nextRound();
  }

  void _pick(_NumItem picked) {
    if (!_started || _locked || _answered) return;
    setState(() {
      _answered = true;
      _pickedN = picked.n;
      _locked = true;
    });
    _fall.stop();
    final ok = picked.n == _target.n;
    if (ok) {
      HapticFeedback.mediumImpact();
      setState(() => _score += 1);
    } else {
      HapticFeedback.heavyImpact();
      setState(() => _lives = (_lives - 1).clamp(0, 3));
    }
    Future.delayed(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      if (_lives <= 0) {
        _locked = true;
        _showGameOver();
      } else {
        _nextRound();
      }
    });
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('গেম শেষ!', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('আপনার স্কোর: $_score', style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _score = 0;
                _lives = 3;
                _started = true;
              });
              _nextRound(resetSpeed: true);
            },
            child: const Text('আবার খেলুন'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back();
            },
            child: const Text('শেষ'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fall.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.score_rounded, color: Color(0xFFFFE000), size: 18),
                  const SizedBox(width: 6),
                  Text('স্কোর: $_score',
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.favorite_rounded,
                        size: 18,
                        color: i < _lives ? _red : _muted.withValues(alpha: 0.4),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  color: _card,
                  child: Stack(
                    children: [
                      if (!_started)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.sports_esports_rounded,
                                    color: AppColors.textPrimary, size: 44),
                                const SizedBox(height: 10),
                                const Text(
                                  'জাপানি সংখ্যা দেখলে সঠিক বাংলা সংখ্যা ট্যাপ করুন',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _start,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text('শুরু করুন',
                                        style: TextStyle(fontWeight: FontWeight.w900)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        AnimatedBuilder(
                          animation: _fall,
                          builder: (context, _) {
                            if (!_started) return const SizedBox.shrink();
                            final t = _fall.value;
                            final top = (t * 0.78) *
                                (MediaQuery.sizeOf(context).height * 0.45);
                            return Positioned(
                              top: 20 + top,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    borderRadius: BorderRadius.circular(26),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.18),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _target.kanji,
                                    style: const TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontSize: 72,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, c) {
                // 2×2 grid is far more reliable than 4-in-a-row on phones.
                final w = c.maxWidth;
                final tileW = (w - 10) / 2;
                final tileH = 66.0;
                final aspect = tileW / tileH;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: aspect,
                  ),
                  itemCount: _options.length,
                  itemBuilder: (_, i) {
                    final opt = _options[i];
                    final isCorrect = opt.n == _target.n;
                    final isPicked = _pickedN == opt.n;

                    Color bg = AppColors.bg;
                    Color border = AppColors.border;
                    Color digit = const Color(0xFFFFE000);
                    Color word = AppColors.textPrimary;

                    if (_answered) {
                      if (isCorrect) {
                        bg = _green.withValues(alpha: 0.22);
                        border = _green.withValues(alpha: 0.8);
                        digit = _green;
                        word = Colors.white;
                      } else if (isPicked) {
                        bg = _red.withValues(alpha: 0.22);
                        border = _red.withValues(alpha: 0.9);
                        digit = _red;
                        word = Colors.white;
                      }
                    } else if (isPicked) {
                      bg = AppColors.bg;
                      border = AppColors.border;
                    }

                    return GestureDetector(
                      onTap: () => _pick(opt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border, width: 1.6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              opt.bnDigit,
                              style: TextStyle(
                                color: digit,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                opt.bnWord,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: word,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            if (_answered && isCorrect) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle_rounded,
                                  color: _green, size: 18),
                            ] else if (_answered && isPicked && !isCorrect) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.cancel_rounded,
                                  color: _red, size: 18),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'টিপ: শব্দটি শুনতে উপরের সংখ্যাটি পড়া হচ্ছে',
                    style: TextStyle(
                      color: _muted.withValues(alpha: 0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: !_started ? null : () => _speak(_target),
                  icon: const Icon(Icons.volume_up_rounded, color: AppColors.accentBlueDk),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tap the Twins (match JP reading to Bangla digit/word)
// ─────────────────────────────────────────────────────────────────────────────

class _TapTwinsGame extends StatefulWidget {
  const _TapTwinsGame({super.key});

  @override
  State<_TapTwinsGame> createState() => _TapTwinsGameState();
}

class _TwinCard {
  final String id;
  final int n;
  final String label;
  final bool isJp;
  const _TwinCard({
    required this.id,
    required this.n,
    required this.label,
    required this.isJp,
  });
}

class _TapTwinsGameState extends State<_TapTwinsGame> {
  static const _bg = Colors.transparent;
  static const _card = AppColors.card;
  static const _muted = Color(0xFF94A3B8);
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);

  final _rng = math.Random();
  late List<_TwinCard> _cards;
  String? _pickedId;
  int? _pickedN;
  final _matched = <String>{};
  int _moves = 0;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    final pool = List<_NumItem>.of(_numbers)..shuffle(_rng);
    final take = pool.take(6).toList(); // 12 cards total
    final cards = <_TwinCard>[];
    for (final it in take) {
      cards.add(_TwinCard(
        id: 'jp_${it.n}',
        n: it.n,
        label: it.kana,
        isJp: true,
      ));
      cards.add(_TwinCard(
        id: 'bn_${it.n}',
        n: it.n,
        label: '${it.bnDigit}  ${it.bnWord}',
        isJp: false,
      ));
    }
    cards.shuffle(_rng);
    _cards = cards;
    _pickedId = null;
    _pickedN = null;
    _matched.clear();
    _moves = 0;
    setState(() {});
  }

  void _tap(_TwinCard c) {
    if (_matched.contains(c.id)) return;
    HapticFeedback.selectionClick();
    if (_pickedId == null) {
      setState(() {
        _pickedId = c.id;
        _pickedN = c.n;
      });
      return;
    }

    if (_pickedId == c.id) return;
    _moves++;
    final ok = _pickedN == c.n;
    if (ok) {
      HapticFeedback.mediumImpact();
      setState(() {
        _matched.add(_pickedId!);
        _matched.add(c.id);
        _pickedId = null;
        _pickedN = null;
      });
      if (_matched.length == _cards.length) {
        Future.delayed(const Duration(milliseconds: 350), _showDone);
      }
    } else {
      HapticFeedback.heavyImpact();
      final prev = _pickedId;
      setState(() {
        _pickedId = c.id;
        _pickedN = c.n;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          // clear both picks
          if (_pickedId == c.id) {
            _pickedId = null;
            _pickedN = null;
          }
        });
      });
      // also visually unselect previous by clearing after a tick
      if (prev != null) {
        // no-op: selection is single by design; mismatch resets via timer
      }
    }
  }

  void _showDone() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('সব মিলেছে!', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('মুভ: $_moves', style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            child: const Text('আবার খেলুন'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back();
            },
            child: const Text('শেষ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.extension_rounded,
                      color: Color(0xFFFFE000), size: 18),
                  const SizedBox(width: 6),
                  const Text('জাপানি ↔ বাংলা মিলান',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  Text('মুভ: $_moves',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w900,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.15,
                ),
                itemCount: _cards.length,
                itemBuilder: (_, i) {
                  final c = _cards[i];
                  final matched = _matched.contains(c.id);
                  final selected = _pickedId == c.id;

                  Color border = AppColors.border;
                  Color bg = AppColors.bg;
                  if (matched) {
                    border = _green.withValues(alpha: 0.7);
                    bg = _green.withValues(alpha: 0.12);
                  } else if (selected) {
                    border = const Color(0xFFFFE000);
                    bg = const Color(0xFFFFE000).withValues(alpha: 0.10);
                  }

                  return GestureDetector(
                    onTap: () => _tap(c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border, width: selected ? 2.5 : 1.5),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            c.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: c.isJp ? 20 : 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            c.isJp ? 'জাপানি' : 'বাংলা',
                            style: TextStyle(
                              color: _muted.withValues(alpha: 0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.accentBlue.withValues(alpha: 0.5)),
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('রিসেট',
                    style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

