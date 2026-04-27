import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/screens/speech_game_screen.dart';

class Lesson1GameHubScreen extends StatelessWidget {
  const Lesson1GameHubScreen({super.key});

  static const _bgTop = Color(0xFF0B1220);
  static const _bgMid = Color(0xFF123B8A);
  static const _bgBottom = Color(0xFF2BA8D6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgTop, _bgMid, _bgBottom],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Lesson 1 Games',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const _Pill(
                      icon: Icons.auto_awesome_rounded,
                      text: 'あ い う え お / か き く け こ / さ し す せ そ',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const _HeroHeader(),
                const SizedBox(height: 14),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final isWide = c.maxWidth >= 720;
                      final crossAxisCount = isWide ? 3 : 1;
                      final childAspectRatio = isWide ? 0.92 : 1.25;
                      return GridView.count(
                        physics: const BouncingScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: childAspectRatio,
                        children: const [
                          _GameCard(
                            icon: Icons.mic_rounded,
                            title: 'Speech Game',
                            subtitle:
                                'Record a short clip and see Japanese + romaji + English.',
                            tint: Color(0xFFFFD86B),
                            route: _Route.speech,
                          ),
                          _GameCard(
                            icon: Icons.flash_on_rounded,
                            title: 'Kana Sprint',
                            subtitle:
                                'Fast multiple-choice: pick the right hiragana for romaji.',
                            tint: Color(0xFF7CFFCB),
                            route: _Route.kana,
                          ),
                          _GameCard(
                            icon: Icons.image_search_rounded,
                            title: 'Picture Words',
                            subtitle:
                                'Match the image to あさ / いえ / すし. Quick and fun.',
                            tint: Color(0xFF9AD0FF),
                            route: _Route.vocab,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                _FooterHint(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _Route { speech, kana, vocab }

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 26,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE000).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: const Icon(Icons.videogame_asset_rounded,
                  color: Color(0xFFFFE000), size: 26),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pick a game to practice Lesson 1',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Everything here uses only Lesson 1 kana and 3 words.',
                    style: TextStyle(
                      color: Color(0xFFD1D5DB),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final _Route route;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          switch (route) {
            case _Route.speech:
              Get.to(() => const SpeechGameScreen());
              return;
            case _Route.kana:
              Get.to(() => const KanaSprintScreen());
              return;
            case _Route.vocab:
              Get.to(() => const PictureWordsScreen());
              return;
          }
        },
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 16),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: tint.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14)),
                      ),
                      child: Icon(icon, color: tint, size: 26),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow_rounded,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Play',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: _SparkBar(tint: tint),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SparkBar extends StatelessWidget {
  const _SparkBar({required this.tint});
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final r = math.Random(7);
    return Row(
      children: List.generate(10, (i) {
        final h = 6.0 + r.nextDouble() * 16.0;
        return Container(
          width: 6,
          height: h,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.25 + (i / 30)),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _FooterHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        'Tip: play Kana Sprint once, then Picture Words, then try Speech.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
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
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Game 2: Kana Sprint (lesson 1 only)
// ─────────────────────────────────────────────────────────────────────────────

class KanaSprintScreen extends StatefulWidget {
  const KanaSprintScreen({super.key});

  @override
  State<KanaSprintScreen> createState() => _KanaSprintScreenState();
}

class _KanaSprintScreenState extends State<KanaSprintScreen> {
  static const _bgTop = Color(0xFF0B1220);
  static const _bgBottom = Color(0xFF164E63);
  static const _accent = Color(0xFF7CFFCB);

  static const _pairs = <(String romaji, String kana)>[
    ('a', 'あ'),
    ('i', 'い'),
    ('u', 'う'),
    ('e', 'え'),
    ('o', 'お'),
    ('ka', 'か'),
    ('ki', 'き'),
    ('ku', 'く'),
    ('ke', 'け'),
    ('ko', 'こ'),
    ('sa', 'さ'),
    ('shi', 'し'),
    ('su', 'す'),
    ('se', 'せ'),
    ('so', 'そ'),
  ];

  final _rng = math.Random();
  late List<(String romaji, String kana)> _deck;
  int _i = 0;
  int _score = 0;
  bool _locked = false;
  String? _picked;
  bool? _correct;
  late List<String> _opts;

  @override
  void initState() {
    super.initState();
    _deck = List.of(_pairs)..shuffle(_rng);
    _opts = _optionsFor(_deck[_i].$2);
  }

  List<String> _optionsFor(String correctKana) {
    final all = _pairs.map((p) => p.$2).toList();
    all.shuffle(_rng);
    final out = <String>{correctKana};
    for (final k in all) {
      if (out.length >= 4) break;
      out.add(k);
    }
    final list = out.toList()..shuffle(_rng);
    return list;
  }

  Future<void> _tap(String kana) async {
    if (_locked) return;
    HapticFeedback.selectionClick();
    final correct = kana == _deck[_i].$2;
    setState(() {
      _locked = true;
      _picked = kana;
      _correct = correct;
      if (correct) _score++;
    });
    await Future.delayed(const Duration(milliseconds: 520));
    if (!mounted) return;
    if (_i >= _deck.length - 1) {
      await _finish();
      return;
    }
    setState(() {
      _i++;
      _locked = false;
      _picked = null;
      _correct = null;
      _opts = _optionsFor(_deck[_i].$2);
    });
  }

  Future<void> _finish() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
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
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.flash_on_rounded,
                        color: Color(0xFF0F766E), size: 30),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sprint complete!',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Score: $_score/${_deck.length}',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Back to games',
                          style: TextStyle(fontWeight: FontWeight.w900)),
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

  @override
  Widget build(BuildContext context) {
    final q = _deck[_i];
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
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Kana Sprint',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Text(
                        '${_i + 1}/${_deck.length}  •  $_score',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Tap the hiragana for',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.80),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          q.$1.toUpperCase(),
                          style: const TextStyle(
                            color: _accent,
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 160),
                          child: _correct == null
                              ? const SizedBox(height: 18)
                              : Text(
                                  _correct! ? 'Nice!' : 'Close—next one.',
                                  key: ValueKey(_correct),
                                  style: TextStyle(
                                    color: _correct!
                                        ? const Color(0xFFB6F6C9)
                                        : const Color(0xFFFFB4B4),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final isWide = c.maxWidth >= 520;
                      final cross = isWide ? 2 : 2;
                      return GridView.count(
                        physics: const BouncingScrollPhysics(),
                        crossAxisCount: cross,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: isWide ? 2.6 : 2.4,
                        children: [
                          for (final k in _opts)
                            _KanaChoice(
                              kana: k,
                              selected: _picked == k,
                              state: _correct == null
                                  ? null
                                  : (k == q.$2
                                      ? _ChoiceState.correct
                                      : (_picked == k
                                          ? _ChoiceState.wrong
                                          : null)),
                              onTap: _locked ? null : () => _tap(k),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _ChoiceState { correct, wrong }

class _KanaChoice extends StatelessWidget {
  const _KanaChoice({
    required this.kana,
    required this.selected,
    required this.state,
    required this.onTap,
  });

  final String kana;
  final bool selected;
  final _ChoiceState? state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = switch (state) {
      _ChoiceState.correct => const Color(0xFF14B86A).withValues(alpha: 0.18),
      _ChoiceState.wrong => const Color(0xFFEF4444).withValues(alpha: 0.16),
      _ => Colors.white.withValues(alpha: 0.10),
    };
    final border = switch (state) {
      _ChoiceState.correct => const Color(0xFFB6F6C9),
      _ChoiceState.wrong => const Color(0xFFFFB4B4),
      _ => Colors.white.withValues(alpha: selected ? 0.55 : 0.16),
    };
    final width = selected ? 2.0 : 1.2;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border, width: width),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 10),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              kana,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Game 3: Picture Words (lesson 1 only)
// ─────────────────────────────────────────────────────────────────────────────

class PictureWordsScreen extends StatefulWidget {
  const PictureWordsScreen({super.key});

  @override
  State<PictureWordsScreen> createState() => _PictureWordsScreenState();
}

class _PictureWordsScreenState extends State<PictureWordsScreen> {
  static const _bgTop = Color(0xFF0B1220);
  static const _bgBottom = Color(0xFF1D4ED8);
  static const _accent = Color(0xFF9AD0FF);

  static const _items = <_VocabItem>[
    _VocabItem(word: 'あさ', meaning: 'Morning', asset: 'assets/images/vocab_asa.png'),
    _VocabItem(word: 'いえ', meaning: 'House', asset: 'assets/images/vocab_ie.png'),
    _VocabItem(word: 'すし', meaning: 'Sushi', asset: 'assets/images/vocab_sushi.png'),
  ];

  final _rng = math.Random();
  late List<_VocabItem> _deck;
  int _i = 0;
  int _score = 0;
  bool _locked = false;
  String? _picked;
  bool? _correct;
  late List<String> _opts;

  @override
  void initState() {
    super.initState();
    _deck = List.of(_items)
      ..shuffle(_rng)
      ..addAll(List.of(_items)..shuffle(_rng)); // 6 rounds feels better.
    _opts = _optionsFor(_deck[_i].word);
  }

  List<String> _optionsFor(String correctWord) {
    final all = _items.map((e) => e.word).toList()..shuffle(_rng);
    final out = <String>{correctWord};
    for (final w in all) {
      if (out.length >= 3) break;
      out.add(w);
    }
    final list = out.toList()..shuffle(_rng);
    return list;
  }

  Future<void> _tap(String word) async {
    if (_locked) return;
    HapticFeedback.selectionClick();
    final correct = word == _deck[_i].word;
    setState(() {
      _locked = true;
      _picked = word;
      _correct = correct;
      if (correct) _score++;
    });
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    if (_i >= _deck.length - 1) {
      await _finish();
      return;
    }
    setState(() {
      _i++;
      _locked = false;
      _picked = null;
      _correct = null;
      _opts = _optionsFor(_deck[_i].word);
    });
  }

  Future<void> _finish() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
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
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.image_search_rounded,
                        color: Color(0xFF1D4ED8), size: 30),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nice matching!',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Score: $_score/${_deck.length}',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Back to games',
                          style: TextStyle(fontWeight: FontWeight.w900)),
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

  @override
  Widget build(BuildContext context) {
    final q = _deck[_i];
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
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Picture Words',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Text(
                        '${_i + 1}/${_deck.length}  •  $_score',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Which word is this?',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.80),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.asset(
                              q.asset,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 160),
                          child: _correct == null
                              ? Text(
                                  q.meaning,
                                  key: const ValueKey('meaning'),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.72),
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : Text(
                                  _correct! ? 'Correct!' : 'Almost—next one.',
                                  key: ValueKey(_correct),
                                  style: TextStyle(
                                    color: _correct!
                                        ? const Color(0xFFB6F6C9)
                                        : const Color(0xFFFFB4B4),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Column(
                    children: [
                      for (final w in _opts)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _WordChoice(
                            word: w,
                            selected: _picked == w,
                            state: _correct == null
                                ? null
                                : (w == q.word
                                    ? _ChoiceState.correct
                                    : (_picked == w
                                        ? _ChoiceState.wrong
                                        : null)),
                            onTap: _locked ? null : () => _tap(w),
                          ),
                        ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WordChoice extends StatelessWidget {
  const _WordChoice({
    required this.word,
    required this.selected,
    required this.state,
    required this.onTap,
  });

  final String word;
  final bool selected;
  final _ChoiceState? state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = switch (state) {
      _ChoiceState.correct => const Color(0xFF14B86A).withValues(alpha: 0.18),
      _ChoiceState.wrong => const Color(0xFFEF4444).withValues(alpha: 0.16),
      _ => Colors.white.withValues(alpha: 0.10),
    };
    final border = switch (state) {
      _ChoiceState.correct => const Color(0xFFB6F6C9),
      _ChoiceState.wrong => const Color(0xFFFFB4B4),
      _ => Colors.white.withValues(alpha: selected ? 0.55 : 0.16),
    };
    final width = selected ? 2.0 : 1.2;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border, width: width),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 10),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  word,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.85)),
            ],
          ),
        ),
      ),
    );
  }
}

class _VocabItem {
  const _VocabItem({
    required this.word,
    required this.meaning,
    required this.asset,
  });

  final String word;
  final String meaning;
  final String asset;
}

