import 'dart:async';
import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/services/jlc_tts.dart';
import 'package:ez_trainz/utils/app_theme.dart';
import 'package:ez_trainz/widgets/game_fx.dart';

class N5KichuKothaLessonScreenV2 extends StatefulWidget {
  const N5KichuKothaLessonScreenV2({super.key});

  @override
  State<N5KichuKothaLessonScreenV2> createState() =>
      _N5KichuKothaLessonScreenV2State();
}

enum _Lesson7Tab {
  pronoun,
  builder,
  san,
  question,
  dialogue,
  meaning,
}

class _N5KichuKothaLessonScreenV2State
    extends State<N5KichuKothaLessonScreenV2> {
  static const _tabs = <_Lesson7Tab>[
    _Lesson7Tab.pronoun,
    _Lesson7Tab.builder,
    _Lesson7Tab.san,
    _Lesson7Tab.question,
    _Lesson7Tab.dialogue,
    _Lesson7Tab.meaning,
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
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'পাঠ ৭ঃ কিছু কথা ছিল...',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 19,
                          ),
                        ),
                        Text(
                          'わたし • あなた • あのひと • さん • は/です/か',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _Lesson7TabPills(
                index: _tab,
                onChange: (i) => setState(() => _tab = i),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: switch (_tabs[_tab]) {
                  _Lesson7Tab.pronoun =>
                    const _PronounSorterGame(key: ValueKey('l7_pronoun')),
                  _Lesson7Tab.builder =>
                    const _SentenceBuilderGame(key: ValueKey('l7_builder')),
                  _Lesson7Tab.san =>
                    const _SanTaggerGame(key: ValueKey('l7_san')),
                  _Lesson7Tab.question =>
                    const _QuestionOrStatementGame(
                        key: ValueKey('l7_question')),
                  _Lesson7Tab.dialogue =>
                    const _DialogueRoleSwapGame(key: ValueKey('l7_dialogue')),
                  _Lesson7Tab.meaning =>
                    const _MeaningMatchGame(key: ValueKey('l7_meaning')),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Lesson7TabPills extends StatelessWidget {
  const _Lesson7TabPills({required this.index, required this.onChange});
  final int index;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    const labels = [
      'সম্বোধন',
      'বাক্য সাজাও',
      'সান ট্যাগ',
      'প্রশ্ন/বক্তব্য',
      'ডায়ালগ',
      'অর্থ মিলাও',
    ];
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: i == index
                        ? AppColors.tabActive
                        : Colors.white.withValues(alpha: 0.58),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: i == index ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              if (i != labels.length - 1) const SizedBox(width: 6),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScreenFrame extends StatelessWidget {
  const _ScreenFrame({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(child: child),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Text(
                'またね • মাতা নে',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudBar extends StatelessWidget {
  const _HudBar({
    required this.step,
    required this.total,
    required this.score,
    required this.mistake,
    this.streak = 0,
  });
  final int step;
  final int total;
  final int score;
  final int mistake;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final p = total == 0 ? 0.0 : (step / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Pill(text: 'ধাপ: $step/$total'),
            const SizedBox(width: 8),
            _Pill(text: 'স্কোর: $score'),
            const SizedBox(width: 8),
            _Pill(text: 'ভুল: $mistake'),
            if (streak > 1) ...[
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentYellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.accentYellow),
                ),
                child: Text(
                  '$streak Row Combo!',
                  style: const TextStyle(
                    color: AppColors.audio,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
            const Spacer(),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  alignment: WrapAlignment.end,
                  children: [
                    for (var i = 0; i < score.clamp(0, 5); i++)
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.audio,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 260),
            tween: Tween(begin: 0, end: p),
            builder: (_, value, __) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.tabActive),
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MinimalGameHeader extends StatelessWidget {
  const _MinimalGameHeader({
    required this.step,
    required this.total,
    required this.score,
    required this.streak,
    required this.comboPulse,
  });

  final int step;
  final int total;
  final int score;
  final int streak;
  final int comboPulse;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : (step / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$step/$total',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'স্কোর $score',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            AnimatedScale(
              key: ValueKey('combo_$comboPulse'),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              scale: streak > 1 ? 1.08 : 1,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: streak > 1 ? 1 : 0.0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.accentYellow),
                  ),
                  child: Text(
                    '$streak Row Combo!',
                    style: const TextStyle(
                      color: AppColors.audio,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 320),
            tween: Tween<double>(begin: 0, end: progress),
            builder: (_, value, __) => LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.tabActive),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({
    required this.text,
    this.caption,
  });

  final String text;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.cardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentYellow.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 32,
              height: 1.2,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 10),
            Text(
              caption!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SwipeTransitionCard extends StatelessWidget {
  const _SwipeTransitionCard({
    required this.seed,
    required this.direction,
    required this.child,
  });

  final int seed;
  final int direction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final beginDx = direction == 0 ? 0.24 : direction * 0.36;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 340),
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(beginDx, 0),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
              child: child,
            ),
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey(seed), child: child),
    );
  }
}

class _StickyFeedbackToast extends StatelessWidget {
  const _StickyFeedbackToast({
    required this.text,
    required this.good,
  });

  final String text;
  final bool good;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: text.isEmpty
          ? const SizedBox.shrink()
          : Align(
              key: ValueKey(text),
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: good
                      ? AppColors.correct
                      : AppColors.wrong,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: good
                        ? AppColors.correct
                        : AppColors.wrong,
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
    );
  }
}

class _DualActionButtons extends StatelessWidget {
  const _DualActionButtons({
    required this.leftText,
    required this.rightText,
    required this.onLeft,
    required this.onRight,
  });

  final String leftText;
  final String rightText;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BanglaButton(
            text: leftText,
            outlined: true,
            onTap: onLeft,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BanglaButton(
            text: rightText,
            onTap: onRight,
          ),
        ),
      ],
    );
  }
}

class _BanglaButton extends StatelessWidget {
  const _BanglaButton({
    required this.text,
    required this.onTap,
    this.outlined = false,
    this.icon,
  });
  final String text;
  final VoidCallback onTap;
  final bool outlined;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.tabActive;
    final fg = outlined ? c : Colors.white;
    return TapScale(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : c,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                text,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameBody extends StatelessWidget {
  const _GameBody({
    required this.top,
    required this.middle,
    required this.bottom,
    this.scrollMiddle = true,
  });

  final Widget top;
  final Widget middle;
  final Widget bottom;
  final bool scrollMiddle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        top,
        Expanded(
          child: scrollMiddle ? SingleChildScrollView(child: middle) : middle,
        ),
        const SizedBox(height: 8),
        bottom,
      ],
    );
  }
}

class _ContextBanner extends StatelessWidget {
  const _ContextBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accentYellow.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
      ),
    );
  }
}

class _OptionArea extends StatelessWidget {
  const _OptionArea({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 230),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Align(alignment: Alignment.topLeft, child: child),
    );
  }
}

class _ActionFooter extends StatelessWidget {
  const _ActionFooter({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _FeedbackBadge extends StatelessWidget {
  const _FeedbackBadge({required this.text, required this.good});

  final String text;
  final bool good;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (good ? AppColors.correct : AppColors.wrong)
            .withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: good ? AppColors.correct : AppColors.wrong,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: good ? AppColors.correct : AppColors.wrong,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _L7Tts {
  _L7Tts() {
    _boot = _init();
  }

  final JlcTts _tts = JlcTts();
  late final Future<void> _boot;

  Future<void> _init() async {
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);
    await _tts.prefetchTexts(_ttsWords);
  }

  Future<void> speak(String text) async {
    await _boot;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}

const _ttsWords = <String>[
  'わたし',
  'あなた',
  'あのひと',
  'がくせい',
  'せんせい',
  'なまえ',
  'さん',
  'わたしはにほんごのがくせいです',
  'あなたはせんせいですか',
  'あのひとはがくせいです',
  'わたしはせんせいです',
  'あなたはにほんごのがくせいですか',
  'あなたのなまえはなんですか',
  'あのひとはせんせいですか',
  'わたしのなまえはスロビです',
  'あのひとはにほんごのせんせいです',
];

class _PronounQ {
  const _PronounQ(this.contextBn, this.correct);
  final String contextBn;
  final String correct;
}

const _pronounQs = <_PronounQ>[
  _PronounQ('নিজেকে বলছি', 'わたし'),
  _PronounQ('সামনের ব্যক্তিকে বলছি', 'あなた'),
  _PronounQ('দূরে থাকা/অনুপস্থিত কাউকে বলছি', 'あのひと'),
  _PronounQ('নিজের পরিচয় দিচ্ছি', 'わたし'),
  _PronounQ('প্রশ্ন করছি: “আপনি?”', 'あなた'),
  _PronounQ('ওই মানুষটার কথা বলছি', 'あのひと'),
];

class _PronounSorterGame extends StatefulWidget {
  const _PronounSorterGame({super.key});

  @override
  State<_PronounSorterGame> createState() => _PronounSorterGameState();
}

class _PronounSorterGameState extends State<_PronounSorterGame> {
  static const _total = 8;
  final _rng = math.Random();
  final _tts = _L7Tts();
  final _fx = GameFx();
  late ConfettiController _confetti;
  late _PronounQ _q;
  int _step = 1;
  int _score = 0;
  int _mistake = 0;
  int _streak = 0;
  String? _picked;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 650));
    _q = _pronounQs[_rng.nextInt(_pronounQs.length)];
  }

  void _next() {
    if (_step >= _total) {
      _showFinishDialog(context, _score, _total);
      return;
    }
    setState(() {
      _step++;
      _picked = null;
      _q = _pronounQs[_rng.nextInt(_pronounQs.length)];
    });
  }

  void _pick(String value) {
    if (_picked != null) return;
    final ok = value == _q.correct;
    unawaited(_fx.tap());
    setState(() {
      _picked = value;
      if (ok) {
        _score++;
        _streak++;
      } else {
        _mistake++;
        _streak = 0;
      }
    });
    if (ok) {
      _confetti.play();
      unawaited(_streak > 1 ? _fx.combo() : _fx.success());
    } else {
      unawaited(_fx.error());
    }
    Future.delayed(const Duration(milliseconds: 620), _next);
  }

  @override
  void dispose() {
    _tts.stop();
    _fx.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const options = ['わたし', 'あなた', 'あのひと'];
    return _ScreenFrame(
      title: 'সর্বনাম চিনুন',
      subtitle: '(প্রেক্ষাপট দেখে সঠিক সর্বনাম বেছে নাও)',
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: _GameBody(
              top: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HudBar(
                    step: _step,
                    total: _total,
                    score: _score,
                    mistake: _mistake,
                    streak: _streak,
                  ),
                  _ContextBanner(text: 'পরিস্থিতি: ${_q.contextBn}'),
                ],
              ),
              middle: _OptionArea(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final o in options)
                      _ChoiceCard(
                        label: o,
                        selected: _picked == o,
                        correct: _picked != null && o == _q.correct,
                        wrong: _picked == o && o != _q.correct,
                        onTap: () => _pick(o),
                      ),
                  ],
                ),
              ),
              bottom: _ActionFooter(
                child: Row(
                  children: [
                    Expanded(
                      child: _BanglaButton(
                        text: 'সঠিকটা শুনি',
                        icon: Icons.volume_up_rounded,
                        onTap: () => _tts.speak(_q.correct),
                        outlined: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'পরিস্থিতি দেখে বাছাই করো',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                maxBlastForce: 12,
                minBlastForce: 5,
                numberOfParticles: 18,
                gravity: 0.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuilderSentence {
  const _BuilderSentence(this.tokens, this.bnHint);
  final List<String> tokens;
  final String bnHint;
}

const _builderSentences = <_BuilderSentence>[
  _BuilderSentence(
    ['わたし', 'は', 'にほんご', 'の', 'がくせい', 'です'],
    'আমি জাপানি ভাষার ছাত্র।',
  ),
  _BuilderSentence(
    ['あなた', 'は', 'せんせい', 'です', 'か'],
    'আপনি কি শিক্ষক?',
  ),
  _BuilderSentence(
    ['あのひと', 'は', 'がくせい', 'です'],
    'ওই ব্যক্তি ছাত্র।',
  ),
  _BuilderSentence(
    ['わたし', 'は', 'せんせい', 'です'],
    'আমি শিক্ষক।',
  ),
  _BuilderSentence(
    ['あなた', 'は', 'にほんご', 'の', 'がくせい', 'です', 'か'],
    'আপনি কি জাপানি ভাষার ছাত্র?',
  ),
  _BuilderSentence(
    ['あなた', 'の', 'なまえ', 'は', 'なん', 'です', 'か'],
    'আপনার নাম কী?',
  ),
  _BuilderSentence(
    ['あのひと', 'は', 'せんせい', 'です', 'か'],
    'ওই ব্যক্তি কি শিক্ষক?',
  ),
  _BuilderSentence(
    ['わたし', 'の', 'なまえ', 'は', 'スロビ', 'です'],
    'আমার নাম সুরভি।',
  ),
  _BuilderSentence(
    ['あのひと', 'は', 'にほんご', 'の', 'せんせい', 'です'],
    'ওই ব্যক্তি জাপানি ভাষার শিক্ষক।',
  ),
];

class _SentenceBuilderGame extends StatefulWidget {
  const _SentenceBuilderGame({super.key});

  @override
  State<_SentenceBuilderGame> createState() => _SentenceBuilderGameState();
}

class _SentenceBuilderGameState extends State<_SentenceBuilderGame> {
  final _rng = math.Random();
  final _tts = _L7Tts();
  final _fx = GameFx();
  late ConfettiController _confetti;
  int _step = 1;
  int _score = 0;
  int _mistake = 0;
  int _streak = 0;
  int _comboPulse = 0;
  int _shakeTick = 0;
  int _hintStep = 0;
  int? _lastQuestionIndex;
  late _BuilderSentence _q;
  late List<String> _bank;
  final List<String> _picked = [];
  bool _solved = false;
  bool _hintVisible = false;
  String _feedback = '';
  String _afterExplain = '';

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 700));
    _setRound();
  }

  void _setRound() {
    final nextIndex = _nextQuestionIndex();
    _q = _builderSentences[nextIndex];
    _lastQuestionIndex = nextIndex;
    _bank = List<String>.of(_q.tokens)..shuffle(_rng);
    _picked.clear();
    _feedback = '';
    _afterExplain = '';
    _solved = false;
    _hintVisible = false;
    _hintStep = 0;
    unawaited(_tts.stop());
    setState(() {});
  }

  int _nextQuestionIndex() {
    if (_builderSentences.length <= 1) return 0;
    var idx = _rng.nextInt(_builderSentences.length);
    while (idx == _lastQuestionIndex) {
      idx = _rng.nextInt(_builderSentences.length);
    }
    return idx;
  }

  bool _isParticle(String t) => t == 'は' || t == 'の' || t == 'か';

  Color _tokenColor(String t) {
    if (_isParticle(t)) return AppColors.audio;
    if (t == 'です') return AppColors.correct;
    return AppColors.tabActive;
  }

  void _check() {
    if (_solved) return;
    unawaited(_fx.tap());
    if (_picked.length != _q.tokens.length) {
      setState(() => _feedback = 'সব শব্দ বসিয়ে তারপর পরীক্ষা করো।');
      unawaited(_fx.error());
      return;
    }
    final ok = listEquals(_picked, _q.tokens);
    setState(() {
      if (ok) {
        _solved = true;
        _score++;
        _streak++;
        _comboPulse++;
        _feedback = 'দারুণ! ঠিকমতো সাজিয়েছো।';
      } else {
        _mistake++;
        _streak = 0;
        _shakeTick++;
        _feedback = 'ক্রমটা ঠিক হয়নি, আবার চেষ্টা করো।';
      }
      _afterExplain = 'সঠিক বাক্য: ${_q.tokens.join(' ')}';
    });
    if (!ok) {
      unawaited(_fx.error());
      return;
    }
    _confetti.play();
    unawaited(_streak > 1 ? _fx.combo() : _fx.success());
    unawaited(_fx.progressFill());
    Future.delayed(const Duration(milliseconds: 820), () {
      if (!mounted) return;
      if (_step >= 6) {
        _showFinishDialog(context, _score, 6);
      } else {
        setState(() => _step++);
        _setRound();
      }
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _fx.dispose();
    _confetti.dispose();
    super.dispose();
  }

  void _hint() {
    setState(() => _hintVisible = !_hintVisible);
  }

  @override
  Widget build(BuildContext context) {
    return _ScreenFrame(
      title: '🧩 বাক্য সাজাও',
      subtitle: 'は / の / か, です সহ সঠিক sentence বানাও',
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: _GameBody(
              scrollMiddle: false,
              top: _MinimalGameHeader(
                step: _step,
                total: 6,
                score: _score,
                streak: _streak,
                comboPulse: _comboPulse,
              ),
              middle: _OptionArea(
                child: ShakeX(
                  trigger: _shakeTick,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            tooltip: 'Hint',
                            onPressed: _hint,
                            icon: Icon(
                              Icons.help_outline_rounded,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      _ContextCard(
                        text: _q.bnHint,
                        caption: _hintVisible
                            ? 'ইঙ্গিত: প্রথম শব্দ "${_q.tokens.first}"'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DragTarget<String>(
                        onWillAcceptWithDetails: (_) => !_solved,
                        onAcceptWithDetails: (details) {
                          if (_solved) return;
                          final token = details.data;
                          if (_bank.remove(token)) {
                            _picked.add(token);
                            setState(() {});
                            unawaited(_fx.snap());
                          }
                        },
                        builder: (_, __, ___) => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox.shrink(),
                          if (_picked.isEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (var i = 0; i < _q.tokens.length; i++)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                      color: Colors.transparent,
                                    ),
                                    child: Text(
                                      '___',
                                      style: TextStyle(
                                        color: AppColors.textDim,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (var i = 0; i < _picked.length; i++)
                                  AnimatedScale(
                                    duration: const Duration(milliseconds: 120),
                                    scale: _hintStep == 1 &&
                                            _picked[i] == _q.tokens.first &&
                                            i == 0
                                        ? 1.1
                                        : 1,
                                    child: Chip(
                                      label: Text(
                                        _picked[i],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800),
                                      ),
                                      backgroundColor: _tokenColor(_picked[i]),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final t in _bank)
                                  LongPressDraggable<String>(
                                    data: t,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: Chip(
                                        label: Text(
                                          t,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        backgroundColor: _tokenColor(t),
                                      ),
                                    ),
                                    childWhenDragging: Chip(
                                      label: Text(
                                        t,
                                        style: TextStyle(
                                          color: AppColors.textDim,
                                        ),
                                      ),
                                      backgroundColor: AppColors.border,
                                    ),
                                    onDragStarted: () => unawaited(_fx.tap()),
                                    onDragCompleted: () {},
                                    child: ActionChip(
                                      label: Text(
                                        t,
                                        style: TextStyle(
                                          color: _hintStep == 1 &&
                                                  t == _q.tokens.first
                                              ? AppColors.audio
                                              : null,
                                        ),
                                      ),
                                      onPressed: _solved
                                          ? null
                                          : () {
                                              _bank.remove(t);
                                              _picked.add(t);
                                              setState(() {});
                                              unawaited(_fx.snap());
                                            },
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              ),
              bottom: _ActionFooter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _BanglaButton(
                            text: 'পেছাও',
                            outlined: true,
                            onTap: _solved || _picked.isEmpty
                                ? () {}
                                : () {
                                    _bank.add(_picked.removeLast());
                                    setState(() {});
                                    unawaited(_fx.tap());
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _BanglaButton(
                            text: 'পরীক্ষা করো',
                            icon: Icons.task_alt_rounded,
                            onTap: _check,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _BanglaButton(
                            text: '💡 ইঙ্গিত',
                            icon: Icons.lightbulb_circle_rounded,
                            outlined: true,
                            onTap: _hint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Opacity(
                            opacity: _solved ? 1 : 0.45,
                            child: IgnorePointer(
                              ignoring: !_solved,
                              child: _BanglaButton(
                                text: 'উচ্চারণ শোনো',
                                icon: Icons.volume_up_rounded,
                                outlined: true,
                                onTap: () => _tts.speak(_q.tokens.join('')),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 20,
                gravity: 0.3,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 66,
            child: _StickyFeedbackToast(
              text: _afterExplain.isEmpty ? _feedback : '$_feedback • $_afterExplain',
              good: _feedback.startsWith('দারুণ'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SanQ {
  const _SanQ(this.label, this.needSan, this.note);
  final String label;
  final bool needSan;
  final String note;
}

const _sanQs = <_SanQ>[
  _SanQ('スズキ', true, 'অন্য কারও নামের পরে さん'),
  _SanQ('トヨタ', true, 'কোম্পানি নামের সাথেও さん'),
  _SanQ('田中', true, 'শিক্ষক/সহকর্মীর নামেও さん'),
  _SanQ('আমার নিজের নাম', false, 'নিজের নামে さん নয়'),
  _SanQ('あなた', false, 'pronoun-এর পরে さん বসে না'),
];

class _SanTaggerGame extends StatefulWidget {
  const _SanTaggerGame({super.key});

  @override
  State<_SanTaggerGame> createState() => _SanTaggerGameState();
}

class _SanTaggerGameState extends State<_SanTaggerGame> {
  final _fx = GameFx();
  late ConfettiController _confetti;
  int _idx = 0;
  int _score = 0;
  int _mistake = 0;
  int _streak = 0;
  int _comboPulse = 0;
  int _cardSeed = 0;
  int _swipeDirection = 1;
  bool _locked = false;
  bool _hintVisible = false;
  String _feedback = '';
  String _afterExplain = '';

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 650));
  }

  void _pick(bool useSan) {
    if (_locked) return;
    unawaited(_fx.tap());
    final q = _sanQs[_idx];
    final ok = useSan == q.needSan;
    _swipeDirection = useSan ? 1 : -1;
    setState(() {
      _locked = true;
      if (ok) {
        _score++;
        _streak++;
        _comboPulse++;
        _feedback = 'সঠিক';
      } else {
        _mistake++;
        _streak = 0;
        _feedback = 'ভুল';
      }
      _afterExplain = q.note;
    });
    if (ok) {
      _confetti.play();
      unawaited(_streak > 1 ? _fx.combo() : _fx.success());
    } else {
      unawaited(_fx.error());
    }
    Future.delayed(const Duration(milliseconds: 520), () {
      if (!mounted) return;
      if (_idx == _sanQs.length - 1) {
        _showFinishDialog(context, _score, _sanQs.length);
      } else {
        setState(() {
          _idx++;
          _cardSeed++;
          _locked = false;
          _feedback = '';
          _afterExplain = '';
          _hintVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _fx.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _sanQs[_idx];
    return _ScreenFrame(
      title: 'সান ট্যাগিং',
      subtitle: 'ট্যাপ করে ঠিক অপশন বেছে নাও',
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: _GameBody(
              top: _MinimalGameHeader(
                step: _idx + 1,
                total: _sanQs.length,
                score: _score,
                streak: _streak,
                comboPulse: _comboPulse,
              ),
              middle: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Hint',
                          onPressed: () =>
                              setState(() => _hintVisible = !_hintVisible),
                          icon: Icon(
                            Icons.help_outline_rounded,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    _SwipeTransitionCard(
                      seed: _cardSeed,
                      direction: _swipeDirection,
                      child: _ContextCard(text: q.label),
                    ),
                    if (_hintVisible) ...[
                      const SizedBox(height: 10),
                      Text(
                        q.note,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              bottom: _ActionFooter(
                child: _DualActionButtons(
                  leftText: 'লাগবে না',
                  rightText: 'সান লাগবে',
                  onLeft: _locked ? () {} : () => _pick(false),
                  onRight: _locked ? () {} : () => _pick(true),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 16,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 66,
            child: _StickyFeedbackToast(
              text: _afterExplain.isEmpty
                  ? _feedback
                  : '$_feedback • $_afterExplain',
              good: _feedback == 'সঠিক',
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionQ {
  const _QuestionQ(this.jp, this.bn, this.isQuestion);
  final String jp;
  final String bn;
  final bool isQuestion;
}

const _questionQs = <_QuestionQ>[
  _QuestionQ('あなたはがくせいですか', 'আপনি কি ছাত্র?', true),
  _QuestionQ('わたしはせんせいです', 'আমি শিক্ষক।', false),
  _QuestionQ('あなたのなまえはなんですか', 'আপনার নাম কী?', true),
  _QuestionQ('あのひとはがくせいです', 'ওই ব্যক্তি ছাত্র।', false),
];

class _QuestionOrStatementGame extends StatefulWidget {
  const _QuestionOrStatementGame({super.key});

  @override
  State<_QuestionOrStatementGame> createState() =>
      _QuestionOrStatementGameState();
}

class _QuestionOrStatementGameState extends State<_QuestionOrStatementGame> {
  static const _total = 8;
  final _rng = math.Random();
  final _fx = GameFx();
  late ConfettiController _confetti;
  late _QuestionQ _q;
  int _step = 1;
  int _score = 0;
  int _mistake = 0;
  int _streak = 0;
  int _comboPulse = 0;
  int _cardSeed = 0;
  int _swipeDirection = 1;
  String _feedback = '';
  String _afterExplain = '';
  bool _hintVisible = false;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 650));
    _q = _questionQs[_rng.nextInt(_questionQs.length)];
  }

  void _pick(bool asQuestion) {
    if (_locked) return;
    unawaited(_fx.tap());
    final ok = asQuestion == _q.isQuestion;
    _swipeDirection = asQuestion ? 1 : -1;
    setState(() {
      _locked = true;
      if (ok) {
        _score++;
        _streak++;
        _comboPulse++;
        _feedback = 'সঠিক';
      } else {
        _mistake++;
        _streak = 0;
        _feedback = 'ভুল';
      }
      _afterExplain = 'এটি ${_q.isQuestion ? 'প্রশ্ন' : 'বক্তব্য'}';
    });
    if (ok) {
      _confetti.play();
      unawaited(_streak > 1 ? _fx.combo() : _fx.success());
    } else {
      unawaited(_fx.error());
    }
    Future.delayed(const Duration(milliseconds: 620), () {
      if (!mounted) return;
      if (_step >= _total) {
        _showFinishDialog(context, _score, _total);
      } else {
        setState(() {
          _step++;
          _cardSeed++;
          _locked = false;
          _feedback = '';
          _afterExplain = '';
          _hintVisible = false;
          _q = _questionQs[_rng.nextInt(_questionQs.length)];
        });
      }
    });
  }

  @override
  void dispose() {
    _fx.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ScreenFrame(
      title: 'প্রশ্ন/বক্তব্য',
      subtitle: 'বাক্য পড়ে ধরো এটি কোন ধরন',
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: _GameBody(
              top: _MinimalGameHeader(
                step: _step,
                total: _total,
                score: _score,
                streak: _streak,
                comboPulse: _comboPulse,
              ),
              middle: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Hint',
                          onPressed: () =>
                              setState(() => _hintVisible = !_hintVisible),
                          icon: Icon(
                            Icons.help_outline_rounded,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    _SwipeTransitionCard(
                      seed: _cardSeed,
                      direction: _swipeDirection,
                      child: _ContextCard(text: _q.jp),
                    ),
                    if (_hintVisible) ...[
                      const SizedBox(height: 10),
                      Text(
                        _q.bn,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              bottom: _ActionFooter(
                child: _DualActionButtons(
                  leftText: 'বক্তব্য',
                  rightText: 'প্রশ্ন',
                  onLeft: _locked ? () {} : () => _pick(false),
                  onRight: _locked ? () {} : () => _pick(true),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 16,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 66,
            child: _StickyFeedbackToast(
              text: _afterExplain.isEmpty
                  ? _feedback
                  : '$_feedback • $_afterExplain',
              good: _feedback == 'সঠিক',
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogueQ {
  const _DialogueQ({
    required this.question,
    required this.pattern,
    required this.answer,
    required this.options,
  });
  final String question;
  final String pattern;
  final String answer;
  final List<String> options;
}

const _dialogueQs = <_DialogueQ>[
  _DialogueQ(
    question: 'あなたのなまえはなんですか？',
    pattern: 'わたしは ____ です。',
    answer: 'スロビ',
    options: ['スロビ', 'あなた', 'あのひと', 'せんせい'],
  ),
  _DialogueQ(
    question: 'あのひとはがくせいですか？',
    pattern: 'はい、____ はがくせいです。',
    answer: 'あのひと',
    options: ['あのひと', 'わたし', 'さん', 'なまえ'],
  ),
  _DialogueQ(
    question: 'あなたはせんせいですか？',
    pattern: 'いいえ、____ はがくせいです。',
    answer: 'わたし',
    options: ['わたし', 'あなた', 'あのひと', 'さん'],
  ),
  _DialogueQ(
    question: 'あなたはにほんごのがくせいですか？',
    pattern: 'はい、____ はにほんごのがくせいです。',
    answer: 'わたし',
    options: ['わたし', 'あなた', 'あのひと', 'せんせい'],
  ),
  _DialogueQ(
    question: 'あのひとのなまえはなんですか？',
    pattern: '____ のなまえはスズキです。',
    answer: 'あのひと',
    options: ['あのひと', 'わたし', 'あなた', 'さん'],
  ),
  _DialogueQ(
    question: 'わたしはせんせいですか？',
    pattern: 'いいえ、____ はせんせいじゃないです。',
    answer: 'あなた',
    options: ['あなた', 'わたし', 'あのひと', 'にほんご'],
  ),
  _DialogueQ(
    question: 'あなたのなまえはなんですか？',
    pattern: '____ はタナカです。',
    answer: 'わたし',
    options: ['わたし', 'あなた', 'あのひと', 'せんせい'],
  ),
  _DialogueQ(
    question: 'あのひとはせんせいですか？',
    pattern: 'はい、____ はせんせいです。',
    answer: 'あのひと',
    options: ['あのひと', 'わたし', 'あなた', 'なまえ'],
  ),
  _DialogueQ(
    question: 'あなたはがくせいですか？',
    pattern: 'いいえ、____ はせんせいです。',
    answer: 'わたし',
    options: ['わたし', 'あなた', 'あのひと', 'さん'],
  ),
  _DialogueQ(
    question: 'わたしのなまえはスズキですか？',
    pattern: 'いいえ、____ のなまえはスロビです。',
    answer: 'わたし',
    options: ['わたし', 'あなた', 'あのひと', 'せんせい'],
  ),
];

class _DialogueRoleSwapGame extends StatefulWidget {
  const _DialogueRoleSwapGame({super.key});

  @override
  State<_DialogueRoleSwapGame> createState() => _DialogueRoleSwapGameState();
}

class _DialogueRoleSwapGameState extends State<_DialogueRoleSwapGame> {
  static const _total = 7;
  final _rng = math.Random();
  final _tts = _L7Tts();
  final _fx = GameFx();
  late ConfettiController _confetti;
  final List<int> _recentDialogueIdx = [];
  int? _lastDialogueIdx;
  late _DialogueQ _q;
  int _step = 1;
  int _score = 0;
  int _mistake = 0;
  int _streak = 0;
  String? _picked;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 700));
    _setNextDialogue();
  }

  void _setNextDialogue() {
    final nextIdx = _pickDialogueIndex();
    _lastDialogueIdx = nextIdx;
    _recentDialogueIdx.add(nextIdx);
    final maxRecent = _dialogueQs.length >= 8 ? 3 : 2;
    if (_recentDialogueIdx.length > maxRecent) {
      _recentDialogueIdx.removeAt(0);
    }
    _q = _dialogueQs[nextIdx];
  }

  int _pickDialogueIndex() {
    if (_dialogueQs.length <= 1) return 0;
    final blocked = <int>{
      if (_lastDialogueIdx != null) _lastDialogueIdx!,
      ..._recentDialogueIdx,
    };
    final candidates = <int>[
      for (var i = 0; i < _dialogueQs.length; i++)
        if (!blocked.contains(i)) i,
    ];
    if (candidates.isEmpty) {
      return (_lastDialogueIdx == null)
          ? _rng.nextInt(_dialogueQs.length)
          : (_lastDialogueIdx! + 1 + _rng.nextInt(_dialogueQs.length - 1)) %
              _dialogueQs.length;
    }
    return candidates[_rng.nextInt(candidates.length)];
  }

  void _pick(String item) {
    if (_picked != null) return;
    unawaited(_fx.tap());
    final ok = item == _q.answer;
    setState(() {
      _picked = item;
      if (ok) {
        _score++;
        _streak++;
      } else {
        _mistake++;
        _streak = 0;
      }
    });
    if (ok) {
      _confetti.play();
      unawaited(_streak > 1 ? _fx.combo() : _fx.success());
    } else {
      unawaited(_fx.error());
    }
    Future.delayed(const Duration(milliseconds: 640), () {
      if (!mounted) return;
      if (_step >= _total) {
        _showFinishDialog(context, _score, _total);
      } else {
        setState(() {
          _step++;
          _picked = null;
          _setNextDialogue();
        });
      }
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _fx.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ScreenFrame(
      title: '🗣️ চরিত্র বদল ডায়ালগ',
      subtitle: 'প্রশ্ন-উত্তরের ফাঁকা জায়গা পূরণ করো',
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: _GameBody(
              top: _HudBar(
                step: _step,
                total: _total,
                score: _score,
                mistake: _mistake,
                streak: _streak,
              ),
              middle: _OptionArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ContextBanner(text: 'পরিস্থিতি: ${_q.question}'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardAlt,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _q.pattern,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final o in _q.options)
                          _ChoiceCard(
                            label: o,
                            selected: _picked == o,
                            correct: _picked != null && o == _q.answer,
                            wrong: _picked == o && o != _q.answer,
                            onTap: () => _pick(o),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              bottom: _ActionFooter(
                child: Row(
                  children: [
                    Expanded(
                      child: _BanglaButton(
                        text: 'প্রশ্নটা শুনি',
                        icon: Icons.volume_up_rounded,
                        outlined: true,
                        onTap: () => _tts
                            .speak(_q.question.replaceAll('？', '').replaceAll('?', '')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeaningWord {
  const _MeaningWord({
    required this.jp,
    required this.phoneticBn,
    required this.meaningBn,
  });
  final String jp;
  final String phoneticBn;
  final String meaningBn;
}

const _meaningWords = <_MeaningWord>[
  _MeaningWord(jp: 'わたし', phoneticBn: 'ওয়াতাশি', meaningBn: 'আমি'),
  _MeaningWord(jp: 'あなた', phoneticBn: 'আনাতা', meaningBn: 'তুমি/আপনি'),
  _MeaningWord(jp: 'あのひと', phoneticBn: 'আনোহিতো', meaningBn: 'ওই ব্যক্তি'),
  _MeaningWord(jp: 'がくせい', phoneticBn: 'গাকুসেই', meaningBn: 'ছাত্র/ছাত্রী'),
  _MeaningWord(jp: 'せんせい', phoneticBn: 'সেনসেই', meaningBn: 'শিক্ষক'),
  _MeaningWord(jp: 'なまえ', phoneticBn: 'নামায়ে', meaningBn: 'নাম'),
  _MeaningWord(jp: 'さん', phoneticBn: 'সান', meaningBn: 'সম্মানসূচক'),
];

class _MeaningMatchGame extends StatefulWidget {
  const _MeaningMatchGame({super.key});

  @override
  State<_MeaningMatchGame> createState() => _MeaningMatchGameState();
}

class _MeaningMatchGameState extends State<_MeaningMatchGame> {
  static const _total = 8;
  final _rng = math.Random();
  final _tts = _L7Tts();
  final _fx = GameFx();
  late ConfettiController _confetti;
  late _MeaningWord _q;
  late List<String> _options;
  int _step = 1;
  int _score = 0;
  int _mistake = 0;
  int _streak = 0;
  String? _picked;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 680));
    _next();
  }

  void _next() {
    _q = _meaningWords[_rng.nextInt(_meaningWords.length)];
    final pool = _meaningWords
        .map((w) => w.meaningBn)
        .where((m) => m != _q.meaningBn)
        .toList()
      ..shuffle(_rng);
    _options = [_q.meaningBn, ...pool.take(3)]..shuffle(_rng);
    _picked = null;
    setState(() {});
  }

  void _pick(String m) {
    if (_picked != null) return;
    unawaited(_fx.tap());
    final ok = m == _q.meaningBn;
    setState(() {
      _picked = m;
      if (ok) {
        _score++;
        _streak++;
      } else {
        _mistake++;
        _streak = 0;
      }
    });
    if (ok) {
      _confetti.play();
      unawaited(_streak > 1 ? _fx.combo() : _fx.success());
    } else {
      unawaited(_fx.error());
    }
    Future.delayed(const Duration(milliseconds: 620), () {
      if (!mounted) return;
      if (_step >= _total) {
        _showFinishDialog(context, _score, _total);
      } else {
        setState(() => _step++);
        _next();
      }
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _fx.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ScreenFrame(
      title: '🏷️ অর্থ মিলাও',
      subtitle: 'জাপানি + বাংলা ধ্বনি দেখে অর্থ বেছে নাও',
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: _GameBody(
              top: _HudBar(
                step: _step,
                total: _total,
                score: _score,
                mistake: _mistake,
                streak: _streak,
              ),
              middle: _OptionArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ContextBanner(text: 'পরিস্থিতি: ${_q.jp} (${_q.phoneticBn})'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final o in _options)
                          _ChoiceCard(
                            label: o,
                            selected: _picked == o,
                            correct: _picked != null && o == _q.meaningBn,
                            wrong: _picked == o && o != _q.meaningBn,
                            onTap: () => _pick(o),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              bottom: _ActionFooter(
                child: Row(
                  children: [
                    Expanded(
                      child: _BanglaButton(
                        text: 'উচ্চারণ শুনি',
                        icon: Icons.volume_up_rounded,
                        outlined: true,
                        onTap: () => _tts.speak(_q.jp),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _picked == null ? 'একটি অপশন বেছে নাও' : 'চালিয়ে যাও',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.label,
    required this.selected,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    var border = AppColors.border;
    var bg = AppColors.card;
    if (correct) {
      border = AppColors.correct;
      bg = AppColors.correct.withValues(alpha: 0.16);
    } else if (wrong) {
      border = AppColors.wrong;
      bg = AppColors.wrong.withValues(alpha: 0.16);
    } else if (selected) {
      border = AppColors.tabActive;
      bg = AppColors.tabActive.withValues(alpha: 0.14);
    }
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: border.withValues(alpha: 0.28),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 22,
        ),
      ),
    );
    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: selected ? 1.03 : 1,
      child: ShakeX(
        trigger: wrong ? 1 : 0,
        child: TapScale(
          onTap: onTap,
          child: card,
        ),
      ),
    );
  }
}

void _showFinishDialog(BuildContext context, int score, int total) {
  final ratio = total == 0 ? 0 : score / total;
  final tier = ratio >= 0.85
      ? 'মিষ্টি 🌟'
      : ratio >= 0.6
          ? 'ঝাল ⚡'
          : 'টক 🍋';
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('ধাপ শেষ'),
      content: Text('তোমার স্কোর: $score / $total\nরেটিং: $tier\nまたね • মাতা নে'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ঠিক আছে'),
        ),
      ],
    ),
  );
}
