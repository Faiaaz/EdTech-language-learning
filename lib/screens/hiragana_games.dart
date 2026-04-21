import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/models/hiragana_lesson_data.dart';

const _blue = Color(0xFF4DA6E8);
const _dark = Color(0xFF1A1A2E);
const _yellow = Color(0xFFFFE000);
const _green = Color(0xFF4CAF50);
const _red = Color(0xFFEF5350);

void _hapticTap() => HapticFeedback.selectionClick();
void _hapticLight() => HapticFeedback.lightImpact();
void _hapticCorrect() => HapticFeedback.mediumImpact();
void _hapticWrong() => HapticFeedback.lightImpact();

// ══════════════════════════════════════════════════════════════════
//  1) FLASHCARD DRILL — square cards, row color accent, TTS
// ══════════════════════════════════════════════════════════════════

class FlashcardDrillScreen extends StatefulWidget {
  const FlashcardDrillScreen({super.key});
  @override
  State<FlashcardDrillScreen> createState() => _FlashcardDrillState();
}

class _FlashcardDrillState extends State<FlashcardDrillScreen>
    with SingleTickerProviderStateMixin {
  static const _kana = HiraganaLesson1Data.kanaList;
  final _page = PageController(viewportFraction: 0.85);
  final _tts = FlutterTts();
  int _current = 0;
  final _flipped = <int, bool>{};
  late AnimationController _bounceCtrl;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _bounce = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOutCubic),
    );
    _tts.setLanguage('ja-JP');
    _tts.setSpeechRate(0.2);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _page.dispose();
    _tts.stop();
    super.dispose();
  }

  void _playCardBounce() {
    _bounceCtrl.forward(from: 0).then((_) => _bounceCtrl.reverse());
  }

  void _speak(String text) {
    _tts.stop();
    _tts.speak(text);
  }

  Color _accentFor(String row) {
    switch (row) {
      case 'Vowel':
        return _blue;
      case 'K-row':
        return const Color(0xFFF9A825);
      case 'S-row':
        return const Color(0xFF43A047);
      default:
        return _blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final cardSide = screenW * 0.72;

    return Scaffold(
      backgroundColor: _blue,
      body: SafeArea(
        child: Column(
          children: [
            _header('flashcard_drill'.tr, '${_current + 1} / ${_kana.length}'),
            const SizedBox(height: 8),
            _progressDots(_current, _kana.length),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: _kana.length,
                onPageChanged: (i) {
                  _hapticTap();
                  setState(() => _current = i);
                },
                itemBuilder: (_, i) {
                  final c = _kana[i];
                  final flipped = _flipped[i] ?? false;
                  final accent = _accentFor(c.row);
                  final inner = SizedBox(
                    width: cardSide,
                    height: cardSide,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: flipped
                          ? _cardBack(c, i, accent)
                          : _cardFront(c, i, accent),
                    ),
                  );
                  return GestureDetector(
                    onTap: () {
                      if (i != _current) return;
                      _hapticLight();
                      _playCardBounce();
                      setState(() => _flipped[i] = !flipped);
                      if (!flipped) _speak(c.kana);
                    },
                    child: Center(
                      child: i == _current
                          ? ScaleTransition(scale: _bounce, child: inner)
                          : inner,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleBtn(Icons.arrow_back_rounded, _current > 0, () {
                    _hapticTap();
                    _page.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  }),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [_yellow, _yellow.withValues(alpha: 0.85)]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: _yellow.withValues(alpha: 0.65),
                            blurRadius: 20,
                            spreadRadius: 4,
                            offset: const Offset(0, 4)),
                        BoxShadow(
                            color: _yellow.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        _hapticTap();
                        _speak(_kana[_current].kana);
                      },
                      icon: const Icon(Icons.volume_up_rounded,
                          color: _dark, size: 28),
                    ),
                  ),
                  _circleBtn(Icons.arrow_forward_rounded,
                      _current < _kana.length - 1, () {
                    _hapticTap();
                    _page.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardFront(HiraganaChar c, int key, Color accent) {
    return Container(
      key: ValueKey('front_$key'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 2.5),
        boxShadow: [
          BoxShadow(
              color: accent.withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(0, 8)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(c.row,
                style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          Text(c.kana,
              style: const TextStyle(
                  fontSize: 100, fontWeight: FontWeight.w700, color: _dark)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_rounded,
                  color: _dark.withValues(alpha: 0.2), size: 16),
              const SizedBox(width: 4),
              Text('tap_to_reveal'.tr,
                  style: TextStyle(
                      color: _dark.withValues(alpha: 0.3), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardBack(HiraganaChar c, int key, Color accent) {
    return Container(
      key: ValueKey('back_$key'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accent.withValues(alpha: 0.75)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: accent.withValues(alpha: 0.55),
              blurRadius: 32,
              spreadRadius: 4,
              offset: const Offset(0, 8)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(c.kana,
              style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.4))),
          const SizedBox(height: 4),
          Text(c.romaji,
              style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
          const SizedBox(height: 16),
          Text('tap_to_flip'.tr,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: enabled
              ? Colors.white.withValues(alpha: 0.28)
              : Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(
              color: enabled ? Colors.white54 : Colors.transparent, width: 1.5),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Icon(icon,
            color: enabled ? Colors.white : Colors.white24, size: 24),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  2) KANA RECOGNITION QUIZ — all 15 hiragana
// ══════════════════════════════════════════════════════════════════

class KanaQuizScreen extends StatefulWidget {
  const KanaQuizScreen({super.key});
  @override
  State<KanaQuizScreen> createState() => _KanaQuizState();
}

class _KanaQuizState extends State<KanaQuizScreen> {
  static const _allKana = HiraganaLesson1Data.kanaList;
  late List<HiraganaChar> _questions;
  int _qi = 0;
  int _score = 0;
  int? _picked;
  late List<HiraganaChar> _options;
  bool _answered = false;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _questions = List.of(_allKana)..shuffle(_rng);
    _genOptions();
  }

  void _genOptions() {
    final correct = _questions[_qi];
    final pool = _allKana.where((k) => k.kana != correct.kana).toList()
      ..shuffle(_rng);
    _options = [correct, ...pool.take(3)]..shuffle(_rng);
    _picked = null;
    _answered = false;
  }

  void _pick(int idx) {
    if (_answered) return;
    _hapticTap();
    final isCorrect = _options[idx].kana == _questions[_qi].kana;
    setState(() {
      _picked = idx;
      _answered = true;
      if (isCorrect) _score++;
    });
    if (isCorrect) {
      _hapticCorrect();
    } else {
      _hapticWrong();
    }
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_qi + 1 < _questions.length) {
        setState(() {
          _qi++;
          _genOptions();
        });
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    HapticFeedback.mediumImpact();
    final pct = (_score / _questions.length * 100).round();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        title: 'quiz_complete'.tr,
        score: _score,
        total: _questions.length,
        pct: pct,
        onRetry: () {
          Navigator.pop(context);
          setState(() {
            _qi = 0;
            _score = 0;
            _questions.shuffle(_rng);
            _genOptions();
          });
        },
        onDone: () {
          Navigator.pop(context);
          Get.back();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_qi];
    return Scaffold(
      backgroundColor: _blue,
      body: SafeArea(
        child: Column(
          children: [
            _header('kana_quiz'.tr, '${_qi + 1} / ${_questions.length}'),
            const SizedBox(height: 8),
            _progressDots(_qi, _questions.length),
            const Spacer(flex: 2),
            Text('what_romaji'.tr,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7), fontSize: 15)),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              key: ValueKey(_qi),
              tween: Tween(begin: 0.86, end: 1.0),
              duration: const Duration(milliseconds: 480),
              curve: Curves.elasticOut,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: _yellow.withValues(alpha: 0.65), width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: _yellow.withValues(alpha: 0.45),
                        blurRadius: 28,
                        spreadRadius: 2,
                        offset: const Offset(0, 6)),
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8)),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(q.kana,
                    style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w700,
                        color: _dark)),
              ),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.6,
                children: List.generate(_options.length, (i) {
                  final o = _options[i];
                  final isCorrect = o.kana == q.kana;
                  Color bg = Colors.white;
                  Color fg = _dark;
                  IconData? trail;
                  if (_answered && _picked == i) {
                    bg = isCorrect ? _green : _red;
                    fg = Colors.white;
                    trail = isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded;
                  } else if (_answered && isCorrect) {
                    bg = _green.withValues(alpha: 0.25);
                    fg = _green;
                  }
                  return GestureDetector(
                    onTap: () => _pick(i),
                    child: AnimatedScale(
                      scale: (_answered && _picked == i) ? 1.06 : 1.0,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.elasticOut,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _answered && _picked == i
                                ? (isCorrect ? _green : _red)
                                    .withValues(alpha: 0.5)
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            if (_answered && _picked == i && isCorrect)
                              BoxShadow(
                                  color: _green.withValues(alpha: 0.45),
                                  blurRadius: 18,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 4))
                            else if (_answered && _picked == i && !isCorrect)
                              BoxShadow(
                                  color: _red.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4))
                            else
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3)),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(o.romaji,
                                style: TextStyle(
                                    color: fg,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700)),
                            if (trail != null) ...[
                              const SizedBox(width: 6),
                              Icon(trail, color: fg, size: 20),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: _yellow, size: 22),
                  const SizedBox(width: 4),
                  Text('${'score_label'.tr}: $_score / ${_questions.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  3) MATCHING PAIRS — redesigned with two-column layout
// ══════════════════════════════════════════════════════════════════

class KanaMatchScreen extends StatefulWidget {
  const KanaMatchScreen({super.key});
  @override
  State<KanaMatchScreen> createState() => _KanaMatchState();
}

class _KanaMatchState extends State<KanaMatchScreen> {
  static const _allKana = HiraganaLesson1Data.kanaList;
  late List<HiraganaChar> _pool;
  int? _selectedKanaIdx;
  int? _selectedRomajiIdx;
  final _matchedKana = <int>{};
  final _matchedRomaji = <int>{};
  int _moves = 0;
  int _wrongKana = -1;
  int _wrongRomaji = -1;

  late List<HiraganaChar> _kanaColumn;
  late List<HiraganaChar> _romajiColumn;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() {
    _pool = (List.of(_allKana)..shuffle()).take(8).toList();
    _kanaColumn = List.of(_pool)..shuffle();
    _romajiColumn = List.of(_pool)..shuffle();
    _selectedKanaIdx = null;
    _selectedRomajiIdx = null;
    _matchedKana.clear();
    _matchedRomaji.clear();
    _moves = 0;
    _wrongKana = -1;
    _wrongRomaji = -1;
  }

  void _tapKana(int i) {
    if (_matchedKana.contains(i)) return;
    _hapticTap();
    setState(() {
      _wrongKana = -1;
      _wrongRomaji = -1;
      _selectedKanaIdx = i;
    });
    _tryMatch();
  }

  void _tapRomaji(int i) {
    if (_matchedRomaji.contains(i)) return;
    _hapticTap();
    setState(() {
      _wrongKana = -1;
      _wrongRomaji = -1;
      _selectedRomajiIdx = i;
    });
    _tryMatch();
  }

  void _tryMatch() {
    if (_selectedKanaIdx == null || _selectedRomajiIdx == null) return;
    _moves++;
    final kChar = _kanaColumn[_selectedKanaIdx!];
    final rChar = _romajiColumn[_selectedRomajiIdx!];

    if (kChar.kana == rChar.kana) {
      _hapticCorrect();
      setState(() {
        _matchedKana.add(_selectedKanaIdx!);
        _matchedRomaji.add(_selectedRomajiIdx!);
        _selectedKanaIdx = null;
        _selectedRomajiIdx = null;
      });
      if (_matchedKana.length == _pool.length) {
        Future.delayed(const Duration(milliseconds: 400), _showDone);
      }
    } else {
      _hapticWrong();
      final ki = _selectedKanaIdx!;
      final ri = _selectedRomajiIdx!;
      setState(() {
        _wrongKana = ki;
        _wrongRomaji = ri;
        _selectedKanaIdx = null;
        _selectedRomajiIdx = null;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _wrongKana = -1;
            _wrongRomaji = -1;
          });
        }
      });
    }
  }

  void _showDone() {
    HapticFeedback.mediumImpact();
    final stars = _moves <= _pool.length
        ? 3
        : _moves <= _pool.length * 1.5
            ? 2
            : 1;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        title: 'all_matched'.tr,
        score: _pool.length,
        total: _pool.length,
        pct: 100,
        subtitle: '$_moves ${'moves_label'.tr}  •  ${'⭐' * stars}',
        onRetry: () {
          Navigator.pop(context);
          setState(_setup);
        },
        onDone: () {
          Navigator.pop(context);
          Get.back();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A9ADE),
      body: SafeArea(
        child: Column(
          children: [
            _header('match_pairs'.tr, '${'moves_label'.tr}: $_moves'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _colLabel('hiragana_label'.tr),
                  const SizedBox(width: 14),
                  _colLabel('romaji_label'.tr),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: _buildColumn(true)),
                    const SizedBox(width: 14),
                    Expanded(child: _buildColumn(false)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _colLabel(String label) {
    return Expanded(
      child: Center(
        child: Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2)),
      ),
    );
  }

  Widget _buildColumn(bool isKana) {
    final list = isKana ? _kanaColumn : _romajiColumn;
    final matched = isKana ? _matchedKana : _matchedRomaji;
    final selected = isKana ? _selectedKanaIdx : _selectedRomajiIdx;
    final wrong = isKana ? _wrongKana : _wrongRomaji;

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final c = list[i];
        final isMatched = matched.contains(i);
        final isSelected = selected == i;
        final isWrong = wrong == i;

        Color bg;
        Color fg;
        Color border;
        if (isMatched) {
          bg = _green.withValues(alpha: 0.12);
          fg = _green;
          border = _green.withValues(alpha: 0.4);
        } else if (isWrong) {
          bg = _red.withValues(alpha: 0.15);
          fg = _red;
          border = _red;
        } else if (isSelected) {
          bg = _yellow.withValues(alpha: 0.18);
          fg = _dark;
          border = _yellow;
        } else {
          bg = Colors.white;
          fg = _dark;
          border = Colors.white.withValues(alpha: 0.0);
        }

        return GestureDetector(
          onTap: () => isKana ? _tapKana(i) : _tapRomaji(i),
          child: AnimatedScale(
            scale: isSelected ? 1.05 : (isWrong ? 0.97 : 1.0),
            duration: const Duration(milliseconds: 220),
            curve: Curves.elasticOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border, width: isSelected ? 2.5 : 2),
                boxShadow: isMatched
                    ? [
                        BoxShadow(
                            color: _green.withValues(alpha: 0.45),
                            blurRadius: 14,
                            spreadRadius: 1,
                            offset: const Offset(0, 3)),
                      ]
                    : isSelected
                        ? [
                            BoxShadow(
                                color: _yellow.withValues(alpha: 0.55),
                                blurRadius: 18,
                                spreadRadius: 2,
                                offset: const Offset(0, 3)),
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 3)),
                          ]
                        : isWrong
                            ? [
                                BoxShadow(
                                    color: _red.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 2)),
                              ]
                            : [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2)),
                              ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isMatched)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(Icons.check_circle_rounded,
                          color: _green, size: 18),
                    ),
                  Text(
                    isKana ? c.kana : c.romaji,
                    style: TextStyle(
                      fontSize: isKana ? 26 : 16,
                      fontWeight: FontWeight.w800,
                      color: fg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  4) VOCABULARY PICTURE QUIZ — polished card-based design
// ══════════════════════════════════════════════════════════════════

class VocabQuizScreen extends StatefulWidget {
  const VocabQuizScreen({super.key});
  @override
  State<VocabQuizScreen> createState() => _VocabQuizState();
}

class _VocabQuizState extends State<VocabQuizScreen> {
  static const _vocab = HiraganaLesson1Data.vocabList;
  final _rng = Random();
  late List<_VQ> _questions;
  int _qi = 0;
  int _score = 0;
  int? _picked;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _buildQuestions();
  }

  void _buildQuestions() {
    _questions = [];
    for (final v in _vocab) {
      final opts = _vocab.map((x) => x.kana).toList()..shuffle(_rng);
      _questions.add(_VQ(
          type: _VQType.imageToKana,
          vocab: v,
          options: opts,
          correctAnswer: v.kana));
    }
    for (final v in _vocab) {
      final opts = _vocab.map((x) => x.meaningEn).toList()..shuffle(_rng);
      _questions.add(_VQ(
          type: _VQType.kanaToMeaning,
          vocab: v,
          options: opts,
          correctAnswer: v.meaningEn));
    }
    for (final v in _vocab) {
      final opts = _vocab.map((x) => x.kana).toList()..shuffle(_rng);
      _questions.add(_VQ(
          type: _VQType.meaningToKana,
          vocab: v,
          options: opts,
          correctAnswer: v.kana));
    }
    _questions.shuffle(_rng);
    _qi = 0;
    _score = 0;
    _picked = null;
    _answered = false;
  }

  void _pick(int idx) {
    if (_answered) return;
    _hapticTap();
    final q = _questions[_qi];
    final isCorrect = q.options[idx] == q.correctAnswer;
    setState(() {
      _picked = idx;
      _answered = true;
      if (isCorrect) _score++;
    });
    if (isCorrect) {
      _hapticCorrect();
    } else {
      _hapticWrong();
    }
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_qi + 1 < _questions.length) {
        setState(() {
          _qi++;
          _picked = null;
          _answered = false;
        });
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    HapticFeedback.mediumImpact();
    final pct = (_score / _questions.length * 100).round();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        title: 'vocab_complete'.tr,
        score: _score,
        total: _questions.length,
        pct: pct,
        onRetry: () {
          Navigator.pop(context);
          setState(_buildQuestions);
        },
        onDone: () {
          Navigator.pop(context);
          Get.back();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_qi];
    return Scaffold(
      backgroundColor: const Color(0xFF7E57C2),
      body: SafeArea(
        child: Column(
          children: [
            _header('vocab_master'.tr, '${_qi + 1} / ${_questions.length}'),
            const SizedBox(height: 8),
            _progressDots(_qi, _questions.length),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(_qi),
                  tween: Tween(begin: 0.88, end: 1.0),
                  duration: const Duration(milliseconds: 460),
                  curve: Curves.elasticOut,
                  builder: (_, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: _buildPrompt(q),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                children: List.generate(q.options.length, (i) {
                  final isCorrect = q.options[i] == q.correctAnswer;
                  Color bg = Colors.white;
                  Color fg = _dark;
                  IconData? trail;
                  if (_answered && _picked == i) {
                    bg = isCorrect ? _green : _red;
                    fg = Colors.white;
                    trail = isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded;
                  } else if (_answered && isCorrect) {
                    bg = _green.withValues(alpha: 0.3);
                    fg = _green;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => _pick(i),
                      child: AnimatedScale(
                        scale: (_answered && _picked == i) ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.elasticOut,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 20),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _answered && _picked == i
                                  ? (isCorrect ? _green : _red)
                                      .withValues(alpha: 0.45)
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              if (_answered && _picked == i && isCorrect)
                                BoxShadow(
                                    color: _green.withValues(alpha: 0.4),
                                    blurRadius: 18,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 4))
                              else if (_answered && _picked == i && !isCorrect)
                                BoxShadow(
                                    color: _red.withValues(alpha: 0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4))
                              else
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3)),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(q.options[i],
                                  style: TextStyle(
                                      color: fg,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                              if (trail != null) ...[
                                const SizedBox(width: 8),
                                Icon(trail, color: fg, size: 20),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded, color: _yellow, size: 20),
                  const SizedBox(width: 4),
                  Text('$_score / ${_questions.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrompt(_VQ q) {
    switch (q.type) {
      case _VQType.imageToKana:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('what_word'.tr,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8), fontSize: 16)),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF7E57C2).withValues(alpha: 0.5),
                      blurRadius: 28,
                      spreadRadius: 2,
                      offset: const Offset(0, 6)),
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(q.vocab.imagePath,
                    height: 200, fit: BoxFit.contain),
              ),
            ),
          ],
        );
      case _VQType.kanaToMeaning:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('what_meaning'.tr,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8), fontSize: 16)),
            const SizedBox(height: 16),
            Container(
              width: 160,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                    color: _yellow.withValues(alpha: 0.7), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: _yellow.withValues(alpha: 0.4),
                      blurRadius: 22,
                      spreadRadius: 1,
                      offset: const Offset(0, 6)),
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 6)),
                ],
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(q.vocab.kana,
                      style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: _dark)),
                  Text(q.vocab.romaji,
                      style: TextStyle(
                          color: _dark.withValues(alpha: 0.4), fontSize: 14)),
                ],
              ),
            ),
          ],
        );
      case _VQType.meaningToKana:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('which_word_means'.tr,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8), fontSize: 16)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Column(
                children: [
                  Text(q.vocab.meaningEn,
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(q.vocab.meaningBn,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 16)),
                ],
              ),
            ),
          ],
        );
    }
  }
}

enum _VQType { imageToKana, kanaToMeaning, meaningToKana }

class _VQ {
  final _VQType type;
  final VocabWord vocab;
  final List<String> options;
  final String correctAnswer;
  const _VQ({
    required this.type,
    required this.vocab,
    required this.options,
    required this.correctAnswer,
  });
}

// ══════════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ══════════════════════════════════════════════════════════════════

Widget _header(String title, String badge) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    child: Row(
      children: [
        GestureDetector(
          onTap: () {
            _hapticLight();
            Get.back();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(badge,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
}

Widget _progressDots(int current, int total) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Row(
      children: List.generate(
        total,
        (i) => Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: i <= current
                  ? _yellow
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    ),
  );
}

class _ResultDialog extends StatelessWidget {
  final String title;
  final int score;
  final int total;
  final int pct;
  final String? subtitle;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  const _ResultDialog({
    required this.title,
    required this.score,
    required this.total,
    required this.pct,
    this.subtitle,
    required this.onRetry,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final stars = pct == 100
        ? 3
        : pct >= 70
            ? 2
            : 1;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                3,
                (i) => Icon(Icons.star_rounded,
                    color: i < stars ? _yellow : const Color(0xFFE0E0E0),
                    size: 36)),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: _dark)),
          const SizedBox(height: 8),
          Text('${'correct_count'.trParams({'score': '$score', 'total': '$total'})}  ($pct%)',
              style: TextStyle(
                  color: _dark.withValues(alpha: 0.6), fontSize: 14)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: TextStyle(
                    color: _dark.withValues(alpha: 0.5), fontSize: 13)),
          ],
          const SizedBox(height: 6),
          Text(
              pct == 100
                  ? 'perfect'.tr
                  : pct >= 70
                      ? 'great_job'.tr
                      : 'keep_practising'.tr,
              style: TextStyle(
                  color: pct >= 70 ? _green : _red,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _hapticTap();
                    onRetry();
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: _blue.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('retry'.tr,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: _blue)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _hapticTap();
                    onDone();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('done'.tr,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
