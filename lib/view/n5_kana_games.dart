// Lesson-specific kana mini-games for পাঠ ৪ (আকাসাতানা), পাঠ ৫ (বর্ণে বর্ণে
// বর্ণমালা) and পাঠ ৬ (জাপানের চন্দ্রবিন্দু). Each game is a self-contained
// widget reachable as a tab in N5AkasatanaLessonScreen and as a card in the
// lesson video screen. Built on the same AppColors / LessonSessionScope / JlcTts
// helpers the existing kana games use.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ez_trainz/services/jlc_tts.dart';
import 'package:ez_trainz/utils/app_theme.dart';
import 'package:ez_trainz/utils/lesson_practice_config.dart';

enum KanaLesson { akasatana, bornomala, dakuten }

enum KanaGameType {
  // পাঠ ৪
  gridFill,
  rowRace,
  vowelSort,
  listenLocate,
  // পাঠ ৫
  spotGap,
  buildWord,
  alphabetBoss,
  traceBattle,
  // পাঠ ৬
  addMark,
  tenMaru,
  hearDiff,
  transformMatch,
}

/// Public dispatcher. The lesson screen instantiates one of these per tab.
class KanaGame extends StatelessWidget {
  const KanaGame({super.key, required this.type, required this.lesson});

  final KanaGameType type;
  final KanaLesson lesson;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case KanaGameType.gridFill:
        return _GridFillGame(
          board: _akasatanaBoard,
          blanks: 8,
          accent: AppColors.accentBlue,
          title: 'খালি ঘর পূরণ করো',
        );
      case KanaGameType.alphabetBoss:
        return _GridFillGame(
          board: _fullBoard,
          blanks: 12,
          accent: AppColors.accentPurple,
          title: 'পূর্ণ বর্ণমালা সাজাও',
        );
      case KanaGameType.rowRace:
        return _ArrangeGame(rounds: _rowRaceRounds(), accent: AppColors.audio);
      case KanaGameType.buildWord:
        return _ArrangeGame(rounds: _buildWordRounds(), accent: AppColors.accentGreen);
      case KanaGameType.vowelSort:
        return _McqGame(rounds: _vowelSortRounds(), accent: AppColors.tabActive);
      case KanaGameType.spotGap:
        return _McqGame(rounds: _spotGapRounds(), accent: AppColors.accentBlueDk);
      case KanaGameType.addMark:
        return _McqGame(rounds: _addMarkRounds(), accent: AppColors.wrong);
      case KanaGameType.tenMaru:
        return _McqGame(rounds: _tenMaruRounds(), accent: AppColors.accentPink);
      case KanaGameType.listenLocate:
        return _ListenGame(pool: _akasatanaListenPool, accent: AppColors.accentBlue);
      case KanaGameType.hearDiff:
        return _ListenGame(pool: _dakutenListenPool, accent: AppColors.wrong, minimalPairs: true);
      case KanaGameType.transformMatch:
        return _PairMatchGame(pairs: _transformPairs(), accent: AppColors.accentPink);
      case KanaGameType.traceBattle:
        return _TraceBattleGame(targets: _bornomalaFlat, accent: AppColors.accentGreen);
    }
  }
}

// ─── Shared data ──────────────────────────────────────────────────────────────

class _Celld {
  const _Celld(this.kana, this.romaji, this.bn);
  final String kana;
  final String romaji;
  final String bn;
}

class _BoardRow {
  const _BoardRow(this.bn, this.cells);
  final String bn;
  final List<_Celld?> cells; // length 5; null = gap (e.g. や/わ rows)
}

const _fullBoard = <_BoardRow>[
  _BoardRow('আ', [_Celld('あ', 'a', 'আ'), _Celld('い', 'i', 'ই'), _Celld('う', 'u', 'উ'), _Celld('え', 'e', 'এ'), _Celld('お', 'o', 'ও')]),
  _BoardRow('কা', [_Celld('か', 'ka', 'কা'), _Celld('き', 'ki', 'কি'), _Celld('く', 'ku', 'কু'), _Celld('け', 'ke', 'কে'), _Celld('こ', 'ko', 'কো')]),
  _BoardRow('সা', [_Celld('さ', 'sa', 'সা'), _Celld('し', 'shi', 'শি'), _Celld('す', 'su', 'সু'), _Celld('せ', 'se', 'সে'), _Celld('そ', 'so', 'সো')]),
  _BoardRow('তা', [_Celld('た', 'ta', 'তা'), _Celld('ち', 'chi', 'চি'), _Celld('つ', 'tsu', 'তসু'), _Celld('て', 'te', 'তে'), _Celld('と', 'to', 'তো')]),
  _BoardRow('না', [_Celld('な', 'na', 'না'), _Celld('に', 'ni', 'নি'), _Celld('ぬ', 'nu', 'নু'), _Celld('ね', 'ne', 'নে'), _Celld('の', 'no', 'নো')]),
  _BoardRow('হা', [_Celld('は', 'ha', 'হা'), _Celld('ひ', 'hi', 'হি'), _Celld('ふ', 'fu', 'ফু'), _Celld('へ', 'he', 'হে'), _Celld('ほ', 'ho', 'হো')]),
  _BoardRow('মা', [_Celld('ま', 'ma', 'মা'), _Celld('み', 'mi', 'মি'), _Celld('む', 'mu', 'মু'), _Celld('め', 'me', 'মে'), _Celld('も', 'mo', 'মো')]),
  _BoardRow('ইয়া', [_Celld('や', 'ya', 'ইয়া'), null, _Celld('ゆ', 'yu', 'ইউ'), null, _Celld('よ', 'yo', 'ইও')]),
  _BoardRow('রা', [_Celld('ら', 'ra', 'রা'), _Celld('り', 'ri', 'রি'), _Celld('る', 'ru', 'রু'), _Celld('れ', 're', 'রে'), _Celld('ろ', 'ro', 'রো')]),
  _BoardRow('ওয়া', [_Celld('わ', 'wa', 'ওয়া'), null, null, null, _Celld('を', 'wo', 'ও')]),
];

const _akasatanaBoard = <_BoardRow>[
  _BoardRow('আ', [_Celld('あ', 'a', 'আ'), _Celld('い', 'i', 'ই'), _Celld('う', 'u', 'উ'), _Celld('え', 'e', 'এ'), _Celld('お', 'o', 'ও')]),
  _BoardRow('কা', [_Celld('か', 'ka', 'কা'), _Celld('き', 'ki', 'কি'), _Celld('く', 'ku', 'কু'), _Celld('け', 'ke', 'কে'), _Celld('こ', 'ko', 'কো')]),
  _BoardRow('সা', [_Celld('さ', 'sa', 'সা'), _Celld('し', 'shi', 'শি'), _Celld('す', 'su', 'সু'), _Celld('せ', 'se', 'সে'), _Celld('そ', 'so', 'সো')]),
  _BoardRow('তা', [_Celld('た', 'ta', 'তা'), _Celld('ち', 'chi', 'চি'), _Celld('つ', 'tsu', 'তসু'), _Celld('て', 'te', 'তে'), _Celld('と', 'to', 'তো')]),
  _BoardRow('না', [_Celld('な', 'na', 'না'), _Celld('に', 'ni', 'নি'), _Celld('ぬ', 'nu', 'নু'), _Celld('ね', 'ne', 'নে'), _Celld('の', 'no', 'নো')]),
];

List<_Celld> _flatten(List<_BoardRow> board) =>
    [for (final r in board) for (final c in r.cells) ?c];

final _akasatanaFlat = _flatten(_akasatanaBoard);
final _bornomalaFlat = _flatten(_fullBoard.sublist(5)); // は..わ rows
final _akasatanaListenPool =
    _akasatanaFlat.map((c) => (kana: c.kana, romaji: c.romaji)).toList();

const _vowels = ['আ (a)', 'ই (i)', 'উ (u)', 'এ (e)', 'ও (o)'];

class _Dak {
  const _Dak(this.clean, this.voiced, this.romaji, this.bn, this.maru);
  final String clean;
  final String voiced;
  final String romaji;
  final String bn;
  final bool maru; // true = handakuten ゜ (まる); false = dakuten ゛ (てんてん)
}

const _dak = <_Dak>[
  _Dak('か', 'が', 'ga', 'গা', false),
  _Dak('き', 'ぎ', 'gi', 'গি', false),
  _Dak('く', 'ぐ', 'gu', 'গু', false),
  _Dak('け', 'げ', 'ge', 'গে', false),
  _Dak('こ', 'ご', 'go', 'গো', false),
  _Dak('さ', 'ざ', 'za', 'জা', false),
  _Dak('し', 'じ', 'ji', 'জি', false),
  _Dak('す', 'ず', 'zu', 'জু', false),
  _Dak('た', 'だ', 'da', 'দা', false),
  _Dak('て', 'で', 'de', 'দে', false),
  _Dak('と', 'ど', 'do', 'দো', false),
  _Dak('は', 'ば', 'ba', 'বা', false),
  _Dak('ひ', 'び', 'bi', 'বি', false),
  _Dak('ふ', 'ぶ', 'bu', 'বু', false),
  _Dak('へ', 'べ', 'be', 'বে', false),
  _Dak('ほ', 'ぼ', 'bo', 'বো', false),
  _Dak('は', 'ぱ', 'pa', 'পা', true),
  _Dak('ひ', 'ぴ', 'pi', 'পি', true),
  _Dak('ふ', 'ぷ', 'pu', 'পু', true),
  _Dak('へ', 'ぺ', 'pe', 'পে', true),
  _Dak('ほ', 'ぽ', 'po', 'পো', true),
];

final _dakutenListenPool =
    _dak.map((d) => (kana: d.voiced, romaji: d.romaji)).toList();

class _Word {
  const _Word(this.kana, this.romaji, this.bn);
  final List<String> kana;
  final String romaji;
  final String bn;
}

const _words = <_Word>[
  _Word(['や', 'ま'], 'yama', 'পাহাড়'),
  _Word(['ね', 'こ'], 'neko', 'বিড়াল'),
  _Word(['い', 'ぬ'], 'inu', 'কুকুর'),
  _Word(['あ', 'め'], 'ame', 'বৃষ্টি'),
  _Word(['う', 'み'], 'umi', 'সমুদ্র'),
  _Word(['さ', 'く', 'ら'], 'sakura', 'চেরি ফুল'),
  _Word(['と', 'り'], 'tori', 'পাখি'),
  _Word(['か', 'わ'], 'kawa', 'নদী'),
  _Word(['も', 'り'], 'mori', 'বন'),
  _Word(['や', 'ね'], 'yane', 'ছাদ'),
];

// ─── Round builders ─────────────────────────────────────────────────────────

final _rng = math.Random();

List<String> _pickDistractors(String correct, Iterable<String> pool, int n) {
  final others = pool.where((e) => e != correct).toList()..shuffle(_rng);
  return others.take(n).toList();
}

List<_McqRound> _vowelSortRounds() {
  final rounds = <_McqRound>[];
  for (final c in _akasatanaFlat) {
    final vowelIdx = 'aiueo'.indexOf(c.romaji.characters.last);
    if (vowelIdx < 0) continue;
    rounds.add(_McqRound(
      prompt: 'এই বর্ণটি কোন স্বর-কলামের?',
      display: c.kana,
      options: List.of(_vowels),
      correct: vowelIdx,
    ));
  }
  rounds.shuffle(_rng);
  return rounds;
}

List<_McqRound> _spotGapRounds() {
  return [
    _McqRound(prompt: 'や সারিতে আসলে কয়টি বর্ণ আছে?', display: 'や ゆ よ', displaySize: 40, options: ['৩টি', '৪টি', '৫টি', '২টি'], correct: 0),
    _McqRound(prompt: 'নিচের কোন বর্ণটি や সারিতে নেই?', display: 'や', options: ['ゆ', 'よ', 'い', 'や'], correct: 2),
    _McqRound(prompt: 'わ সারির শেষে কোন বিশেষ বর্ণ আসে?', display: 'わ ・ を ・ ?', displaySize: 36, options: ['ん', 'お', 'の', 'ぬ'], correct: 0),
    _McqRound(prompt: 'কোন বর্ণটি বাক্যে কর্ম-চিহ্ন (object) হিসেবে বসে?', display: 'を', options: ['を', 'わ', 'お', 'ん'], correct: 0),
    _McqRound(prompt: 'わ সারিতে কয়টি স্বাভাবিক স্বর-বর্ণ আছে?', display: 'わ ・ を', displaySize: 40, options: ['২টি', '৫টি', '৩টি', '৪টি'], correct: 0),
    _McqRound(prompt: 'ら সারিতে নিচের কোনটি আছে?', display: 'ら', options: ['り', 'い', 'に', 'ち'], correct: 0),
  ]..shuffle(_rng);
}

List<_McqRound> _addMarkRounds() {
  final rounds = <_McqRound>[];
  for (final d in _dak) {
    final mark = d.maru ? 'まる ゜' : 'てんてん ゛';
    rounds.add(_McqRound(
      prompt: '$mark যোগ করলে কোনটি হবে?',
      display: d.clean,
      options: [d.voiced, ..._pickDistractors(d.voiced, _dak.map((e) => e.voiced), 3)]..shuffle(_rng),
      correct: -1, // resolved below
      correctLabel: d.voiced,
    ));
  }
  rounds.shuffle(_rng);
  return rounds;
}

List<_McqRound> _tenMaruRounds() {
  final rounds = <_McqRound>[];
  for (final d in _dak) {
    rounds.add(_McqRound(
      prompt: 'এই বর্ণে কোন চিহ্ন আছে?',
      display: d.voiced,
      options: const ['てんてん ゛', 'まる ゜'],
      correct: d.maru ? 1 : 0,
    ));
  }
  rounds.shuffle(_rng);
  return rounds.take(12).toList();
}

List<_ArrangeRound> _rowRaceRounds() {
  return [
    for (final row in _akasatanaBoard)
      _ArrangeRound(
        prompt: '${row.bn} সারি সাজাও — আ→ই→উ→এ→ও ক্রমে',
        target: [for (final c in row.cells) if (c != null) c.kana],
      )
  ];
}

List<_ArrangeRound> _buildWordRounds() {
  final list = List.of(_words)..shuffle(_rng);
  return [
    for (final w in list)
      _ArrangeRound(
        prompt: 'বানাও: ${w.bn} (${w.romaji})',
        target: w.kana,
        distractors: _pickDistractors(
          w.kana.first,
          _bornomalaFlat.map((e) => e.kana).followedBy(_akasatanaFlat.map((e) => e.kana)),
          2,
        ),
      )
  ];
}

List<({String a, String b})> _transformPairs() {
  final base = _dak.where((d) => !d.maru).toList()..shuffle(_rng);
  return base.take(6).map((d) => (a: d.clean, b: d.voiced)).toList();
}

// ─── Shared UI helpers ────────────────────────────────────────────────────────

void _showResult(
  BuildContext context, {
  required String title,
  required String detail,
  required Color accent,
  required IconData icon,
  required VoidCallback onAgain,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(22)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, color: accent, size: 30),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(detail, style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onAgain();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('আবার খেলো', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

enum _TileState { correct, wrong }

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({required this.label, required this.selected, required this.state, required this.onTap, this.fontSize = 18});

  final String label;
  final bool selected;
  final _TileState? state;
  final VoidCallback? onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final bg = switch (state) {
      _TileState.correct => AppColors.correct.withValues(alpha: 0.18),
      _TileState.wrong => AppColors.wrong.withValues(alpha: 0.16),
      _ => AppColors.bg,
    };
    final border = switch (state) {
      _TileState.correct => AppColors.correct.withValues(alpha: 0.65),
      _TileState.wrong => AppColors.wrong.withValues(alpha: 0.6),
      _ => AppColors.border,
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: selected ? 2 : 1.2),
        ),
        child: Center(
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textPrimary, fontSize: fontSize, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

// ─── MCQ engine (vowelSort, spotGap, addMark, tenMaru) ────────────────────────

class _McqRound {
  _McqRound({
    required this.prompt,
    required this.display,
    required this.options,
    required this.correct,
    this.correctLabel,
    this.displaySize = 72,
  });
  final String prompt;
  final String display;
  final List<String> options;
  int correct; // index into options
  final String? correctLabel; // when set, correct is resolved from label
  final double displaySize;
}

class _McqGame extends StatefulWidget {
  const _McqGame({required this.rounds, required this.accent});
  final List<_McqRound> rounds;
  final Color accent;

  @override
  State<_McqGame> createState() => _McqGameState();
}

class _McqGameState extends State<_McqGame> {
  late List<_McqRound> _deck;
  int _i = 0;
  int _score = 0;
  bool _locked = false;
  int? _picked;

  @override
  void initState() {
    super.initState();
    _deck = List.of(widget.rounds);
    _resolve();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final rounds = LessonSessionScope.roundsFor(context, widget.rounds.length);
    if (rounds < _deck.length) {
      _deck = List.of(widget.rounds.take(rounds));
      _reset();
    }
  }

  void _resolve() {
    for (final r in _deck) {
      if (r.correctLabel != null) r.correct = r.options.indexOf(r.correctLabel!);
    }
  }

  void _reset() {
    _i = 0;
    _score = 0;
    _locked = false;
    _picked = null;
    _resolve();
  }

  Future<void> _tap(int idx) async {
    if (_locked) return;
    HapticFeedback.selectionClick();
    final ok = idx == _deck[_i].correct;
    setState(() {
      _locked = true;
      _picked = idx;
      if (ok) _score++;
    });
    await Future.delayed(const Duration(milliseconds: 560));
    if (!mounted) return;
    if (_i >= _deck.length - 1) {
      _showResult(context,
          title: 'শেষ!',
          detail: 'স্কোর: $_score / ${_deck.length}',
          accent: widget.accent,
          icon: Icons.emoji_events_rounded,
          onAgain: () => setState(_reset));
      return;
    }
    setState(() {
      _i++;
      _locked = false;
      _picked = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = _deck[_i];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_i + 1} / ${_deck.length}', style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 13)),
              Text('স্কোর: $_score', style: TextStyle(color: widget.accent, fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.bg)),
            child: Column(
              children: [
                Text(r.prompt, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 12),
                Text(r.display, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textPrimary, fontSize: r.displaySize, fontWeight: FontWeight.w900, height: 1)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.6,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var k = 0; k < r.options.length; k++)
                  _ChoiceTile(
                    label: r.options[k],
                    selected: _picked == k,
                    state: _picked == null
                        ? null
                        : (k == r.correct ? _TileState.correct : (_picked == k ? _TileState.wrong : null)),
                    onTap: _locked ? null : () => _tap(k),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Listen engine (listenLocate, hearDiff) ───────────────────────────────────

class _ListenGame extends StatefulWidget {
  const _ListenGame({required this.pool, required this.accent, this.minimalPairs = false});
  final List<({String kana, String romaji})> pool;
  final Color accent;
  final bool minimalPairs;

  @override
  State<_ListenGame> createState() => _ListenGameState();
}

class _ListenGameState extends State<_ListenGame> {
  final _tts = JlcTts();
  bool _ttsReady = false;
  int _total = 8;
  int _round = 0;
  int _score = 0;
  bool _locked = false;
  String? _picked;
  late ({String kana, String romaji}) _target;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _initTts();
    _next(speak: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _total = LessonSessionScope.roundsFor(context, 8).clamp(3, widget.pool.length);
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.05);
      if (!mounted) return;
      setState(() => _ttsReady = true);
      _speak();
    } catch (_) {}
  }

  Future<void> _speak() async {
    if (!_ttsReady) return;
    await _tts.stop();
    await _tts.speak(_target.kana);
  }

  void _next({bool speak = true}) {
    final target = widget.pool[_rng.nextInt(widget.pool.length)];
    final opts = <String>{target.kana};
    if (widget.minimalPairs) {
      // Prefer the clean/voiced partner as the hard distractor.
      final partner = _dak.firstWhere(
        (d) => d.voiced == target.kana,
        orElse: () => _dak.first,
      );
      opts.add(partner.clean);
    }
    final pool = List.of(widget.pool)..shuffle(_rng);
    for (final p in pool) {
      if (opts.length >= 4) break;
      opts.add(p.kana);
    }
    final list = opts.toList()..shuffle(_rng);
    setState(() {
      _target = target;
      _options = list;
      _picked = null;
      _locked = false;
    });
    if (speak) _speak();
  }

  Future<void> _tap(String kana) async {
    if (_locked) return;
    HapticFeedback.selectionClick();
    final ok = kana == _target.kana;
    setState(() {
      _locked = true;
      _picked = kana;
      if (ok) _score++;
    });
    await Future.delayed(const Duration(milliseconds: 640));
    if (!mounted) return;
    if (_round >= _total - 1) {
      _showResult(context,
          title: 'শেষ!',
          detail: 'স্কোর: $_score / $_total',
          accent: widget.accent,
          icon: Icons.hearing_rounded,
          onAgain: () => setState(() {
                _round = 0;
                _score = 0;
                _next(speak: true);
              }));
      return;
    }
    setState(() => _round++);
    _next();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_round + 1} / $_total', style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 13)),
              Text('স্কোর: $_score', style: TextStyle(color: widget.accent, fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.bg)),
            child: Column(
              children: [
                Text(widget.minimalPairs ? 'কোনটি শুনলে?' : 'শুনে সঠিক বর্ণটি বাছো', style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _speak,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(color: widget.accent.withValues(alpha: 0.16), shape: BoxShape.circle, border: Border.all(color: widget.accent.withValues(alpha: 0.5), width: 2)),
                    child: Icon(Icons.volume_up_rounded, color: widget.accent, size: 44),
                  ),
                ),
                const SizedBox(height: 10),
                Text('আবার শুনতে চাপো', style: TextStyle(color: AppColors.textDim, fontWeight: FontWeight.w600, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.6,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final opt in _options)
                  _ChoiceTile(
                    label: opt,
                    fontSize: 34,
                    selected: _picked == opt,
                    state: _picked == null
                        ? null
                        : (opt == _target.kana ? _TileState.correct : (_picked == opt ? _TileState.wrong : null)),
                    onTap: _locked ? null : () => _tap(opt),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Arrange engine (rowRace, buildWord) ──────────────────────────────────────

class _ArrangeRound {
  const _ArrangeRound({required this.prompt, required this.target, this.distractors = const []});
  final String prompt;
  final List<String> target;
  final List<String> distractors;
}

class _ArrangeTile {
  _ArrangeTile(this.id, this.kana);
  final int id;
  final String kana;
  bool used = false;
}

class _ArrangeGame extends StatefulWidget {
  const _ArrangeGame({required this.rounds, required this.accent});
  final List<_ArrangeRound> rounds;
  final Color accent;

  @override
  State<_ArrangeGame> createState() => _ArrangeGameState();
}

class _ArrangeGameState extends State<_ArrangeGame> {
  late List<_ArrangeRound> _deck;
  int _i = 0;
  int _errors = 0;
  final List<int> _placed = []; // tile ids in placed order
  late List<_ArrangeTile> _tiles;

  @override
  void initState() {
    super.initState();
    _deck = List.of(widget.rounds);
    _build();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final rounds = LessonSessionScope.roundsFor(context, widget.rounds.length);
    if (rounds < _deck.length) {
      _deck = List.of(widget.rounds.take(rounds));
      _i = 0;
      _errors = 0;
      _build();
    }
  }

  void _build() {
    _placed.clear();
    final r = _deck[_i];
    final all = [...r.target, ...r.distractors];
    var id = 0;
    _tiles = [for (final k in all) _ArrangeTile(id++, k)]..shuffle(_rng);
  }

  List<String> get _answer => _placed.map((id) => _tiles.firstWhere((t) => t.id == id).kana).toList();

  Future<void> _tapTile(_ArrangeTile t) async {
    if (t.used) return;
    final target = _deck[_i].target;
    final expected = target[_placed.length];
    if (t.kana == expected) {
      HapticFeedback.lightImpact();
      setState(() {
        t.used = true;
        _placed.add(t.id);
      });
      if (_placed.length == target.length) {
        await Future.delayed(const Duration(milliseconds: 360));
        if (!mounted) return;
        if (_i >= _deck.length - 1) {
          _showResult(context,
              title: 'দারুণ!',
              detail: 'ভুল: $_errors',
              accent: widget.accent,
              icon: Icons.task_alt_rounded,
              onAgain: () => setState(() {
                    _i = 0;
                    _errors = 0;
                    _build();
                  }));
        } else {
          setState(() {
            _i++;
            _build();
          });
        }
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(() => _errors++);
    }
  }

  void _undo() {
    if (_placed.isEmpty) return;
    setState(() {
      final id = _placed.removeLast();
      _tiles.firstWhere((t) => t.id == id).used = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = _deck[_i];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_i + 1} / ${_deck.length}', style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 13)),
              Text('ভুল: $_errors', style: TextStyle(color: _errors > 0 ? AppColors.wrong : AppColors.textMuted, fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.bg)),
            child: Column(
              children: [
                Text(r.prompt, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    for (var s = 0; s < r.target.length; s++)
                      Container(
                        width: 52,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: s < _placed.length ? widget.accent.withValues(alpha: 0.14) : AppColors.bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: s < _placed.length ? widget.accent.withValues(alpha: 0.5) : AppColors.border),
                        ),
                        child: Text(s < _answer.length ? _answer[s] : '', style: TextStyle(color: widget.accent, fontSize: 30, fontWeight: FontWeight.w900)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              for (final t in _tiles)
                Opacity(
                  opacity: t.used ? 0.25 : 1,
                  child: GestureDetector(
                    onTap: t.used ? null : () => _tapTile(t),
                    child: Container(
                      width: 60,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border, width: 1.2)),
                      child: Text(t.kana, style: const TextStyle(color: AppColors.textPrimary, fontSize: 30, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _placed.isEmpty ? null : _undo,
            icon: const Icon(Icons.backspace_rounded, size: 18),
            label: const Text('মুছো', style: TextStyle(fontWeight: FontWeight.w800)),
            style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ─── Grid fill engine (gridFill, alphabetBoss) ────────────────────────────────

class _GridFillGame extends StatefulWidget {
  const _GridFillGame({required this.board, required this.blanks, required this.accent, required this.title});
  final List<_BoardRow> board;
  final int blanks;
  final Color accent;
  final String title;

  @override
  State<_GridFillGame> createState() => _GridFillGameState();
}

class _GridFillGameState extends State<_GridFillGame> {
  final Set<String> _blankKeys = {}; // "r-c"
  final Set<String> _filledKeys = {};
  late List<String> _tray;
  String? _selChip;
  int _errors = 0;

  String _key(int r, int c) => '$r-$c';

  @override
  void initState() {
    super.initState();
    _build();
  }

  void _build() {
    _blankKeys.clear();
    _filledKeys.clear();
    _errors = 0;
    _selChip = null;
    final cells = <({int r, int c, String kana})>[];
    for (var r = 0; r < widget.board.length; r++) {
      final row = widget.board[r];
      for (var c = 0; c < row.cells.length; c++) {
        final cell = row.cells[c];
        if (cell != null) cells.add((r: r, c: c, kana: cell.kana));
      }
    }
    cells.shuffle(_rng);
    final n = widget.blanks.clamp(1, cells.length);
    final chosen = cells.take(n).toList();
    for (final ch in chosen) {
      _blankKeys.add(_key(ch.r, ch.c));
    }
    _tray = (chosen.map((e) => e.kana).toList())..shuffle(_rng);
  }

  void _tapCell(int r, int c) {
    final key = _key(r, c);
    if (!_blankKeys.contains(key) || _filledKeys.contains(key)) return;
    if (_selChip == null) return;
    final cell = widget.board[r].cells[c]!;
    if (cell.kana == _selChip) {
      HapticFeedback.lightImpact();
      setState(() {
        _filledKeys.add(key);
        _tray.remove(_selChip);
        _selChip = null;
      });
      if (_tray.isEmpty) {
        Future.delayed(const Duration(milliseconds: 380), () {
          if (!mounted) return;
          _showResult(context,
              title: 'ছক পূর্ণ!',
              detail: 'ভুল: $_errors',
              accent: widget.accent,
              icon: Icons.grid_on_rounded,
              onAgain: () => setState(_build));
        });
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(() => _errors++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(widget.title, style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 14))),
              Text('ভুল: $_errors', style: TextStyle(color: _errors > 0 ? AppColors.wrong : AppColors.textMuted, fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var r = 0; r < widget.board.length; r++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          for (var c = 0; c < widget.board[r].cells.length; c++)
                            Expanded(child: Padding(padding: const EdgeInsets.all(3), child: _cell(r, c))),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.bg)),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (_tray.isEmpty)
                  Text('সব বসানো হয়েছে', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                for (final k in _tray)
                  GestureDetector(
                    onTap: () => setState(() => _selChip = _selChip == k ? null : k),
                    child: Container(
                      width: 48,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selChip == k ? widget.accent.withValues(alpha: 0.2) : AppColors.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _selChip == k ? widget.accent : AppColors.border, width: _selChip == k ? 2 : 1.2),
                      ),
                      child: Text(k, style: const TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w900)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(int r, int c) {
    final cell = widget.board[r].cells[c];
    if (cell == null) {
      return const AspectRatio(aspectRatio: 1, child: SizedBox.shrink());
    }
    final key = _key(r, c);
    final isBlank = _blankKeys.contains(key);
    final isFilled = _filledKeys.contains(key);
    final showKana = !isBlank || isFilled;
    return GestureDetector(
      onTap: isBlank && !isFilled ? () => _tapCell(r, c) : null,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isBlank && !isFilled ? AppColors.bg : (isFilled ? widget.accent.withValues(alpha: 0.14) : AppColors.card),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isBlank && !isFilled ? (_selChip != null ? widget.accent.withValues(alpha: 0.5) : AppColors.border) : AppColors.bg,
              width: isBlank && !isFilled ? 1.6 : 1,
            ),
          ),
          child: Text(
            showKana ? cell.kana : '',
            style: TextStyle(color: isFilled ? widget.accent : AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

// ─── Pair-match engine (transformMatch) ───────────────────────────────────────

class _PairTile {
  _PairTile(this.id, this.label, this.pairId);
  final int id;
  final String label;
  final int pairId;
}

class _PairMatchGame extends StatefulWidget {
  const _PairMatchGame({required this.pairs, required this.accent});
  final List<({String a, String b})> pairs;
  final Color accent;

  @override
  State<_PairMatchGame> createState() => _PairMatchGameState();
}

class _PairMatchGameState extends State<_PairMatchGame> {
  late List<_PairTile> _tiles;
  int? _selId;
  final Set<int> _matched = {};
  int _errors = 0;

  @override
  void initState() {
    super.initState();
    _build();
  }

  void _build() {
    _matched.clear();
    _selId = null;
    _errors = 0;
    var id = 0;
    final tiles = <_PairTile>[];
    for (var p = 0; p < widget.pairs.length; p++) {
      tiles.add(_PairTile(id++, widget.pairs[p].a, p));
      tiles.add(_PairTile(id++, widget.pairs[p].b, p));
    }
    tiles.shuffle(_rng);
    _tiles = tiles;
  }

  void _tap(_PairTile t) {
    if (_matched.contains(t.pairId)) return;
    if (_selId == null) {
      setState(() => _selId = t.id);
      return;
    }
    if (_selId == t.id) {
      setState(() => _selId = null);
      return;
    }
    final prev = _tiles.firstWhere((e) => e.id == _selId);
    if (prev.pairId == t.pairId) {
      HapticFeedback.lightImpact();
      setState(() {
        _matched.add(t.pairId);
        _selId = null;
      });
      if (_matched.length == widget.pairs.length) {
        Future.delayed(const Duration(milliseconds: 380), () {
          if (!mounted) return;
          _showResult(context,
              title: 'সব মিলেছে!',
              detail: 'ভুল: $_errors',
              accent: widget.accent,
              icon: Icons.join_inner_rounded,
              onAgain: () => setState(_build));
        });
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _errors++;
        _selId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('পরিষ্কার ↔ দাকুতেন মেলাও', style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 14)),
              Text('ভুল: $_errors', style: TextStyle(color: _errors > 0 ? AppColors.wrong : AppColors.textMuted, fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.0,
              children: [
                for (final t in _tiles)
                  _PairTileWidget(
                    label: t.label,
                    selected: _selId == t.id,
                    matched: _matched.contains(t.pairId),
                    accent: widget.accent,
                    onTap: () => _tap(t),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PairTileWidget extends StatelessWidget {
  const _PairTileWidget({required this.label, required this.selected, required this.matched, required this.accent, required this.onTap});
  final String label;
  final bool selected;
  final bool matched;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = matched ? accent.withValues(alpha: 0.14) : (selected ? AppColors.border : AppColors.bg);
    final border = matched ? accent.withValues(alpha: 0.5) : (selected ? AppColors.textMuted : AppColors.border);
    return GestureDetector(
      onTap: matched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: selected ? 2 : 1.2)),
        child: Center(child: Text(label, style: TextStyle(color: matched ? accent : AppColors.textPrimary, fontSize: 34, fontWeight: FontWeight.w900))),
      ),
    );
  }
}

// ─── Trace-battle engine (traceBattle) ────────────────────────────────────────

class _TraceBattleGame extends StatefulWidget {
  const _TraceBattleGame({required this.targets, required this.accent});
  final List<_Celld> targets;
  final Color accent;

  @override
  State<_TraceBattleGame> createState() => _TraceBattleGameState();
}

class _TraceBattleGameState extends State<_TraceBattleGame> {
  static const _seconds = 45;
  Timer? _timer;
  int _remaining = _seconds;
  int _done = 0;
  bool _running = false;
  late _Celld _target;
  final List<List<Offset>> _strokes = [];
  List<Offset> _current = [];

  @override
  void initState() {
    super.initState();
    _target = widget.targets[_rng.nextInt(widget.targets.length)];
  }

  void _start() {
    setState(() {
      _running = true;
      _remaining = _seconds;
      _done = 0;
      _strokes.clear();
      _current = [];
      _target = widget.targets[_rng.nextInt(widget.targets.length)];
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) _finish();
    });
  }

  void _finish() {
    _timer?.cancel();
    setState(() => _running = false);
    _showResult(context,
        title: 'সময় শেষ!',
        detail: '$_done টি বর্ণ আঁকা হয়েছে',
        accent: widget.accent,
        icon: Icons.timer_rounded,
        onAgain: _start);
  }

  void _nextKana() {
    HapticFeedback.lightImpact();
    setState(() {
      _done++;
      _strokes.clear();
      _current = [];
      _target = widget.targets[_rng.nextInt(widget.targets.length)];
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('আঁকা: $_done', style: TextStyle(color: widget.accent, fontWeight: FontWeight.w800, fontSize: 13)),
              Text('⏱ $_remaining সে', style: TextStyle(color: _remaining <= 10 ? AppColors.wrong : AppColors.textMuted, fontWeight: FontWeight.w900, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.bg)),
                  ),
                ),
                // Faint guide kana
                Center(
                  child: Text(_target.kana, style: TextStyle(fontSize: 200, fontWeight: FontWeight.w900, color: AppColors.border.withValues(alpha: 0.6))),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onPanStart: _running ? (d) => setState(() => _current = [d.localPosition]) : null,
                    onPanUpdate: _running ? (d) => setState(() => _current = [..._current, d.localPosition]) : null,
                    onPanEnd: _running
                        ? (_) => setState(() {
                              if (_current.isNotEmpty) _strokes.add(_current);
                              _current = [];
                            })
                        : null,
                    child: CustomPaint(painter: _StrokePainter([..._strokes, _current], widget.accent), size: Size.infinite),
                  ),
                ),
                if (!_running)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _start,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('শুরু করো', style: TextStyle(fontWeight: FontWeight.w900)),
                      style: ElevatedButton.styleFrom(backgroundColor: widget.accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _running ? () => setState(() { _strokes.clear(); _current = []; }) : null,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('মুছো', style: TextStyle(fontWeight: FontWeight.w800)),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.textMuted, side: BorderSide(color: AppColors.border), padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _running ? _nextKana : null,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('পরবর্তী', style: TextStyle(fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(backgroundColor: widget.accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StrokePainter extends CustomPainter {
  _StrokePainter(this.strokes, this.color);
  final List<List<Offset>> strokes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final p in stroke.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StrokePainter old) => true;
}
