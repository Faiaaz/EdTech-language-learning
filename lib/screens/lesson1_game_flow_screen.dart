import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/lightning_streak_controller.dart';
import 'package:ez_trainz/models/hiragana_lesson_data.dart';
import 'package:ez_trainz/screens/hat_earned_screen.dart';
import 'package:ez_trainz/widgets/lightning_streak_bar.dart';

/// Duolingo-style lesson flow that starts immediately after Lesson 1.
/// Includes lightning streak + smooth drawing validator (pixel similarity).
class Lesson1GameFlowScreen extends StatefulWidget {
  const Lesson1GameFlowScreen({super.key});

  @override
  State<Lesson1GameFlowScreen> createState() => _Lesson1GameFlowScreenState();
}

enum _StepType { mcqKana, listenKana, drawKana, vocabPic }

enum _DrawDifficulty { ghost, skeleton, memory }

class _LessonStep {
  const _LessonStep.kanaMcq(this.promptRomaji, {required this.options})
      : type = _StepType.mcqKana,
        kana = null,
        vocab = null;

  const _LessonStep.listen(this.kana, {required this.options})
      : type = _StepType.listenKana,
        promptRomaji = null,
        vocab = null;

  const _LessonStep.draw(this.kana)
      : type = _StepType.drawKana,
        promptRomaji = null,
        options = const [],
        vocab = null;

  const _LessonStep.vocab(this.vocab)
      : type = _StepType.vocabPic,
        promptRomaji = null,
        options = const [],
        kana = null;

  final _StepType type;
  final String? promptRomaji;
  final String? kana;
  final List<String> options;
  final VocabWord? vocab;
}

class _Lesson1GameFlowScreenState extends State<Lesson1GameFlowScreen>
    with SingleTickerProviderStateMixin {
  // Lesson 1 cloud-blue background.
  static const _bgTop = Color(0xFFF2FBFF);
  static const _bgMid = Color(0xFFBFEFFF);
  static const _bgBottom = Color(0xFF2BA8D6);
  static const _green = Color(0xFF9AE11B);

  final _rng = math.Random();
  final _tts = FlutterTts();

  late final List<_LessonStep> _steps;
  int _i = 0;

  int _hearts = 5;
  bool _locked = false;
  String? _selected;

  late final AnimationController _midThunder;
  bool _midThunderPlayed = false;

  // Drawing state (Duolingo-look; validate on CHECK for robustness).
  List<List<Offset>> _drawNormStrokes = const []; // normalized 0..1 inside square
  bool _checkingDraw = false;
  int? _drawPct;
  _DrawEval? _drawEval;
  _DrawDifficulty _drawDifficulty = _DrawDifficulty.ghost;

  @override
  void initState() {
    super.initState();
    _steps = _buildSteps();
    _midThunder = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    // ignore: discarded_futures
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.46);
      await _tts.setPitch(1.05);
      await _tts.setVolume(1.0);
    } catch (_) {}
  }

  @override
  void dispose() {
    // ignore: discarded_futures
    _tts.stop();
    _midThunder.dispose();
    super.dispose();
  }

  List<_LessonStep> _buildSteps() {
    final kana = HiraganaLesson1Data.kanaList.map((k) => k.kana).toList();
    final romaji = HiraganaLesson1Data.kanaList.map((k) => k.romaji).toList();
    final steps = <_LessonStep>[];

    // MCQ: select correct character for romaji.
    for (var idx = 0; idx < 5; idx++) {
      final r = romaji[idx];
      final correctKana = kana[idx];
      final opts = <String>{correctKana};
      while (opts.length < 4) {
        opts.add(kana[_rng.nextInt(kana.length)]);
      }
      steps.add(_LessonStep.kanaMcq(r, options: opts.toList()..shuffle(_rng)));
    }

    // Listening: "What do you hear?"
    for (var idx = 5; idx < 8; idx++) {
      final correct = kana[idx];
      final opts = <String>{correct};
      while (opts.length < 4) {
        opts.add(kana[_rng.nextInt(kana.length)]);
      }
      steps.add(_LessonStep.listen(correct, options: opts.toList()..shuffle(_rng)));
    }

    // Drawing: 2 kana.
    steps.add(_LessonStep.draw('あ'));
    steps.add(_LessonStep.draw('う'));

    // Vocab picture.
    for (final v in HiraganaLesson1Data.vocabList) {
      steps.add(_LessonStep.vocab(v));
    }

    return steps;
  }

  double get _progress => (_i / math.max(1, _steps.length)).clamp(0.0, 1.0);

  _LessonStep get _step => _steps[_i];

  Future<void> _markCorrect() async {
    await LightningStreakController.to.correct();
    setState(() {
      _locked = true;
    });
  }

  Future<void> _markWrong() async {
    await LightningStreakController.to.wrong();
    HapticFeedback.lightImpact();
    setState(() {
      _hearts = math.max(0, _hearts - 1);
      _locked = true;
    });
  }

  void _next() {
    HapticFeedback.selectionClick();
    setState(() {
      _selected = null;
      _locked = false;
      _drawNormStrokes = const [];
      _checkingDraw = false;
      _drawPct = null;
      _drawEval = null;
      if (_i < _steps.length - 1) {
        _i++;
      } else {
        // Replace game screen with the hat-earned celebration.
        Get.off(() => const HatEarnedScreen());
      }
    });

    // One-time thunder when crossing halfway.
    if (!_midThunderPlayed && _progress >= 0.5) {
      _midThunderPlayed = true;
      // ignore: discarded_futures
      HapticFeedback.heavyImpact();
      // ignore: discarded_futures
      _midThunder.forward(from: 0);
    }
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgMid, _bgBottom],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Dark scrim so white UI stays readable.
            Container(color: const Color(0xFF061118).withValues(alpha: 0.52)),
            Stack(
              children: [
                Column(
                  children: [
                    LightningStreakBar(
                      progress: _progress,
                      hearts: _hearts,
                      onClose: () => Get.back(),
                    ),
                    Expanded(
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Header(title: _titleForStep(_step)),
                              const SizedBox(height: 14),
                              Expanded(child: _buildStepBody()),
                              const SizedBox(height: 12),
                              _BottomButton(
                                enabled: _canCheck(),
                                label: 'CONTINUE',
                                color: _canCheck()
                                    ? _green
                                    : const Color(0xFF3A4A53),
                                onTap: () async {
                                  await _checkAndAdvance();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _midThunder,
                    builder: (context, _) {
                      final t = _midThunder.value; // 0..1
                      if (t <= 0) return const SizedBox.shrink();
                      // Quick flash: bright -> dim -> fade.
                      final flash = (t < 0.25)
                          ? (t / 0.25)
                          : (t < 0.55 ? (1 - (t - 0.25) / 0.30) : 0.0);
                      final dim = (t < 0.25)
                          ? 0.0
                          : ((t - 0.25) / 0.75).clamp(0.0, 1.0);
                      return Stack(
                        children: [
                          // Dim layer.
                          Container(
                            color: Colors.black.withValues(alpha: 0.35 * dim),
                          ),
                          // Lightning flash.
                          Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.topCenter,
                                radius: 1.2,
                                colors: [
                                  const Color(0xFFBFE9FF)
                                      .withValues(alpha: 0.75 * flash),
                                  const Color(0xFF43B9FF)
                                      .withValues(alpha: 0.22 * flash),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.35, 1.0],
                              ),
                            ),
                          ),
                          // Bolt icon pop.
                          Center(
                            child: Transform.scale(
                              scale: 0.9 + 0.25 * flash,
                              child: Icon(
                                Icons.bolt_rounded,
                                size: 120,
                                color: const Color(0xFFA3FF12)
                                    .withValues(alpha: 0.9 * flash),
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFFA3FF12)
                                        .withValues(alpha: 0.75 * flash),
                                    blurRadius: 28,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _canCheck() {
    return switch (_step.type) {
      _StepType.drawKana => _drawNormStrokes.any((s) => s.isNotEmpty) && !_checkingDraw,
      _ => _selected != null && !_locked,
    };
  }

  Future<void> _checkAndAdvance() async {
    if (_locked) return;
    if (!_canCheck()) return;
    final ok = await _check();
    // One-tap flow: after feedback, advance automatically.
    // ignore: discarded_futures
    Future<void>.delayed(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      _next();
    });
    // Extra haptic to make the CTA feel punchy.
    if (ok) {
      // ignore: discarded_futures
      HapticFeedback.selectionClick();
    }
  }

  String _titleForStep(_LessonStep s) {
    return switch (s.type) {
      _StepType.mcqKana => 'Select the correct character',
      _StepType.listenKana => 'What do you hear?',
      _StepType.drawKana => 'Draw this character',
      _StepType.vocabPic => 'Pick the correct word',
    };
  }

  Widget _buildStepBody() {
    return switch (_step.type) {
      _StepType.mcqKana => _KanaMcq(
          prompt: 'Select the correct character for “${_step.promptRomaji}”',
          options: _step.options,
          selected: _selected,
          locked: _locked,
          onPick: (v) => setState(() => _selected = v),
        ),
      _StepType.listenKana => _ListenKana(
          options: _step.options,
          selected: _selected,
          locked: _locked,
          onPlay: () => _speak(_step.kana!),
          onPick: (v) => setState(() => _selected = v),
        ),
      _StepType.drawKana => _DrawKana(
          kana: _step.kana!,
          romaji: HiraganaLesson1Data.kanaList
              .firstWhere((k) => k.kana == _step.kana!)
              .romaji,
          model: _TraceModels.byKana(_step.kana!),
          strokes: _drawNormStrokes,
          checking: _checkingDraw,
          pct: _drawPct,
          eval: _drawEval,
          difficulty: _drawDifficulty,
          onClear: () => setState(() {
            _drawNormStrokes = const [];
            _drawPct = null;
            _drawEval = null;
          }),
          onStrokesChanged: (s) => setState(() {
            _drawNormStrokes = s;
            _drawPct = null;
            _drawEval = null;
          }),
        ),
      _StepType.vocabPic => _VocabPic(
          vocab: _step.vocab!,
          selected: _selected,
          locked: _locked,
          onPick: (v) => setState(() => _selected = v),
        ),
    };
  }

  Future<bool> _check() async {
    if (_locked) return false;
    final ok = switch (_step.type) {
      _StepType.mcqKana =>
        _selected == HiraganaLesson1Data.kanaList.firstWhere((k) => k.romaji == _step.promptRomaji).kana,
      _StepType.listenKana => _selected == _step.kana,
      _StepType.vocabPic => _selected == _step.vocab!.kana,
      _StepType.drawKana => await _checkDrawing(kana: _step.kana!),
    };

    if (ok) {
      // ignore: discarded_futures
      HapticFeedback.mediumImpact();
    } else {
      // ignore: discarded_futures
      HapticFeedback.heavyImpact();
    }

    if (ok) {
      await _markCorrect();
    } else {
      await _markWrong();
    }
    return ok;
  }

  Future<bool> _checkDrawing({required String kana}) async {
    if (_checkingDraw) return false;
    final hasInk = _drawNormStrokes.any((s) => s.isNotEmpty);
    if (!hasInk) return false;
    setState(() => _checkingDraw = true);

    try {
      final model = _TraceModels.byKana(kana);
      final eval = _scoreDrawing(model, _drawNormStrokes);
      setState(() {
        _drawEval = eval;
        _drawPct = eval.score.round();
      });
      if (eval.score >= 80 && _drawDifficulty == _DrawDifficulty.ghost) {
        setState(() => _drawDifficulty = _DrawDifficulty.skeleton);
      } else if (eval.score >= 90 && _drawDifficulty == _DrawDifficulty.skeleton) {
        setState(() => _drawDifficulty = _DrawDifficulty.memory);
      }
      return eval.score >= 65;
    } finally {
      if (mounted) setState(() => _checkingDraw = false);
    }
  }

  _DrawEval _scoreDrawing(_TraceModel model, List<List<Offset>> user) {
    // Stroke order enforcement: score by index. Extra strokes penalize slightly.
    final refStrokes = model.strokes.map((s) => s.points).toList();
    final strokeCount = math.min(refStrokes.length, user.length);
    final per = <double>[];
    for (var i = 0; i < strokeCount; i++) {
      per.add(_scoreStroke(refStrokes[i], user[i]));
    }
    // Missing strokes get 0.
    while (per.length < refStrokes.length) {
      per.add(0);
    }
    // Extra strokes mild penalty.
    final extra = math.max(0, user.length - refStrokes.length);
    final base = per.isEmpty ? 0.0 : per.reduce((a, b) => a + b) / per.length;
    final penalty = (extra * 4).clamp(0, 20);
    final finalScore = (base - penalty).clamp(0.0, 100.0);
    return _DrawEval(score: finalScore, perStroke: per);
  }

  double _scoreStroke(List<Offset> ref, List<Offset> usr) {
    if (usr.length < 2 || ref.length < 2) return 0;
    final a = _resample(ref, 32);
    final b = _resample(usr, 32);

    // DTW distance in normalized space.
    final dist = _dtw(a, b);

    // Endpoint weighting.
    final startErr = (a.first - b.first).distance;
    final endErr = (a.last - b.last).distance;

    // Direction check (simple).
    final ra = (a.last - a.first);
    final rb = (b.last - b.first);
    final dirOk = (ra.distance > 0.0001 && rb.distance > 0.0001)
        ? ((ra.dx * rb.dx + ra.dy * rb.dy) / (ra.distance * rb.distance))
        : 0.0;
    final dirPenalty = dirOk < 0.2 ? 12.0 : 0.0;

    // Map to score.
    // Empirically: good tracing yields dist ~0.03-0.08. Bad scribble >>0.15
    final core = (100 * math.exp(-dist * 10)).clamp(0.0, 100.0);
    final ep = (100 * math.exp(-(startErr + endErr) * 7)).clamp(0.0, 100.0);
    final score = (0.72 * core + 0.28 * ep) - dirPenalty;
    return score.clamp(0.0, 100.0);
  }

  List<Offset> _resample(List<Offset> pts, int n) {
    if (pts.length == 1) return List.filled(n, pts.first);
    final dists = <double>[0];
    var total = 0.0;
    for (var i = 1; i < pts.length; i++) {
      total += (pts[i] - pts[i - 1]).distance;
      dists.add(total);
    }
    if (total <= 0.0001) return List.filled(n, pts.first);
    final out = <Offset>[];
    for (var i = 0; i < n; i++) {
      final t = (total * i) / (n - 1);
      var j = 1;
      while (j < dists.length && dists[j] < t) {
        j++;
      }
      if (j >= dists.length) {
        out.add(pts.last);
        continue;
      }
      final t0 = dists[j - 1];
      final t1 = dists[j];
      final f = (t1 - t0) <= 0.0001 ? 0.0 : ((t - t0) / (t1 - t0));
      out.add(Offset.lerp(pts[j - 1], pts[j], f)!);
    }
    return out;
  }

  double _dtw(List<Offset> a, List<Offset> b) {
    final n = a.length;
    final m = b.length;
    const inf = 1e9;
    var prev = List<double>.filled(m + 1, inf);
    var cur = List<double>.filled(m + 1, inf);
    prev[0] = 0;
    for (var i = 1; i <= n; i++) {
      cur[0] = inf;
      for (var j = 1; j <= m; j++) {
        final cost = (a[i - 1] - b[j - 1]).distance;
        final best = math.min(prev[j], math.min(cur[j - 1], prev[j - 1]));
        cur[j] = cost + best;
      }
      final tmp = prev;
      prev = cur;
      cur = tmp;
    }
    final norm = (n + m).toDouble();
    return (prev[m] / norm);
  }
}

class _DrawEval {
  const _DrawEval({required this.score, required this.perStroke});
  final double score;
  final List<double> perStroke;
}

class _Header extends StatelessWidget {
  const _Header({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/ninja_penguin_transparent.png',
          width: 58,
          height: 58,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomButton extends StatefulWidget {
  const _BottomButton({
    required this.enabled,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final bool enabled;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_BottomButton> createState() => _BottomButtonState();
}

class _BottomButtonState extends State<_BottomButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    final color = widget.color;
    return Listener(
      onPointerDown: (_) {
        if (!enabled) return;
        setState(() => _pressed = true);
      },
      onPointerUp: (_) {
        if (_pressed) setState(() => _pressed = false);
      },
      onPointerCancel: (_) {
        if (_pressed) setState(() => _pressed = false);
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        scale: _pressed ? 0.985 : 1.0,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: enabled
                ? () {
                    HapticFeedback.selectionClick();
                    widget.onTap();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: enabled ? Colors.black : Colors.white54,
              disabledBackgroundColor: const Color(0xFF2B3B43),
              elevation: enabled ? 10 : 0,
              shadowColor: enabled
                  ? color.withValues(alpha: 0.35)
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              widget.label,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, letterSpacing: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.child,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final Widget child;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? Colors.white.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.22);
    final tint =
        selected ? const Color(0xFF43B9FF) : const Color(0xFFBFEFFF);
    return _GlassInkCard(
      borderRadius: 16,
      onTap: locked ? null : onTap,
      borderColor: border,
      borderWidth: selected ? 1.6 : 1,
      tint: tint,
      child: Center(child: child),
    );
  }
}

class _KanaMcq extends StatelessWidget {
  const _KanaMcq({
    required this.prompt,
    required this.options,
    required this.selected,
    required this.locked,
    required this.onPick,
  });

  final String prompt;
  final List<String> options;
  final String? selected;
  final bool locked;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prompt,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              for (final k in options)
                _ChoiceCard(
                  child: Text(
                    k,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 52,
                    ),
                  ),
                  selected: selected == k,
                  locked: locked,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onPick(k);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ListenKana extends StatelessWidget {
  const _ListenKana({
    required this.options,
    required this.selected,
    required this.locked,
    required this.onPlay,
    required this.onPick,
  });

  final List<String> options;
  final String? selected;
  final bool locked;
  final VoidCallback onPlay;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tap what you hear',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: GestureDetector(
            onTap: locked ? null : onPlay,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFF43B9FF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.volume_up_rounded,
                  color: Colors.black, size: 46),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              for (final k in options)
                _ChoiceCard(
                  child: Text(
                    k,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 52,
                    ),
                  ),
                  selected: selected == k,
                  locked: locked,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onPick(k);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DrawKana extends StatelessWidget {
  const _DrawKana({
    required this.kana,
    required this.romaji,
    required this.model,
    required this.strokes,
    required this.checking,
    required this.pct,
    required this.eval,
    required this.difficulty,
    required this.onClear,
    required this.onStrokesChanged,
  });

  final String kana;
  final String romaji;
  final _TraceModel model;
  final List<List<Offset>> strokes;
  final bool checking;
  final int? pct;
  final _DrawEval? eval;
  final _DrawDifficulty difficulty;
  final VoidCallback onClear;
  final ValueChanged<List<List<Offset>>> onStrokesChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trace the character',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            GestureDetector(
              onTap: () => HapticFeedback.selectionClick(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF43B9FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.volume_up_rounded,
                    color: Colors.black, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kana,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  romaji,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _GlassSurface(
            radius: 18,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: LayoutBuilder(
                builder: (context, c) {
                  return Stack(
                    children: [
                      _DuolingoTraceCanvas(
                        key: ValueKey<String>('trace_${model.kana}'),
                        model: model,
                        strokes: strokes,
                        onStrokesChanged: onStrokesChanged,
                        eval: eval,
                        difficulty: difficulty,
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: _MiniClear(onTap: checking ? null : onClear),
                      ),
                      if (pct != null)
                        Positioned(
                          left: 10,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.10)),
                            ),
                            child: Text(
                              '$pct%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      if (checking)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFFB020),
                            strokeWidth: 3,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassSurface extends StatelessWidget {
  const _GlassSurface({required this.child, required this.radius});
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TraceModels {
  static _TraceModel byKana(String kana) {
    return switch (kana) {
      // Approximate Duolingo stroke guides for Lesson 1 MVP.
      'あ' => _TraceModel(
          kana: 'あ',
          ghostScale: 1.0,
          strokes: [
            // Horizontal top
            _TraceStroke(points: const [
              Offset(0.18, 0.22),
              Offset(0.82, 0.22),
            ]),
            // Vertical down
            _TraceStroke(points: const [
              Offset(0.52, 0.16),
              Offset(0.52, 0.72),
            ]),
            // Loop + tail (single continuous stroke)
            _TraceStroke(points: const [
              // start left-mid, go down-left, around, then finish with a tail
              Offset(0.30, 0.46),
              Offset(0.20, 0.62),
              Offset(0.28, 0.78),
              Offset(0.50, 0.84),
              Offset(0.72, 0.74),
              Offset(0.74, 0.58),
              Offset(0.58, 0.52),
              Offset(0.38, 0.60),
              Offset(0.30, 0.70),
              // tail up-right then down-right (matches the visible “finish”)
              Offset(0.56, 0.48),
              Offset(0.70, 0.56),
              Offset(0.62, 0.78),
            ]),
          ],
        ),
      'う' => _TraceModel(
          kana: 'う',
          ghostScale: 1.0,
          strokes: [
            // Small top stroke (slight curve)
            _TraceStroke(points: const [
              Offset(0.32, 0.26),
              Offset(0.52, 0.24),
              Offset(0.72, 0.26),
            ]),
            // Main sweeping curve + hook
            _TraceStroke(points: const [
              // start under the top stroke (center-ish), drop down, then sweep into hook
              Offset(0.56, 0.36),
              Offset(0.52, 0.48),
              Offset(0.44, 0.60),
              Offset(0.50, 0.72),
              Offset(0.64, 0.82),
              Offset(0.78, 0.74),
              Offset(0.72, 0.58),
            ]),
          ],
        ),
      _ => _TraceModel(
          kana: kana,
          ghostScale: 1.0,
          strokes: const [
            _TraceStroke(points: [Offset(0.25, 0.25), Offset(0.75, 0.75)]),
          ],
        ),
    };
  }
}

class _TraceModel {
  const _TraceModel({
    required this.kana,
    required this.strokes,
    required this.ghostScale,
  });
  final String kana;
  final List<_TraceStroke> strokes;
  final double ghostScale;
}

class _TraceStroke {
  const _TraceStroke({required this.points});
  final List<Offset> points; // normalized 0..1
}

class _DuolingoTraceCanvas extends StatefulWidget {
  const _DuolingoTraceCanvas({
    super.key,
    required this.model,
    required this.strokes,
    required this.onStrokesChanged,
    required this.eval,
    required this.difficulty,
  });

  final _TraceModel model;
  final List<List<Offset>> strokes;
  final ValueChanged<List<List<Offset>>> onStrokesChanged;
  final _DrawEval? eval;
  final _DrawDifficulty difficulty;

  @override
  State<_DuolingoTraceCanvas> createState() => _DuolingoTraceCanvasState();
}

class _DuolingoTraceCanvasState extends State<_DuolingoTraceCanvas>
    with SingleTickerProviderStateMixin {
  int? _activePointer;

  final _local = <List<Offset>>[];
  List<Offset>? _current;

  Color? _liveInkColor;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _DuolingoTraceCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent clears strokes, we must clear our internal buffer too,
    // otherwise the next pointer down resurrects previous ink.
    final nowEmpty = widget.strokes.isEmpty || widget.strokes.every((s) => s.isEmpty);
    if (nowEmpty) {
      _local.clear();
      _current = null;
      _liveInkColor = null;
    } else if (!identical(oldWidget.strokes, widget.strokes) &&
        _local.length != widget.strokes.length) {
      _local
        ..clear()
        ..addAll(widget.strokes.map((s) => List<Offset>.of(s)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final hasInk = widget.strokes.any((s) => s.isNotEmpty);
        final showGuide = widget.difficulty != _DrawDifficulty.memory;
        return Listener(
          onPointerDown: (e) => _onDown(e, c.biggest),
          onPointerMove: (e) => _onMove(e, c.biggest),
          onPointerUp: _onUp,
          onPointerCancel: _onUp,
          child: Stack(
            children: [
              const ColoredBox(color: Color(0xFF0B1419)),
              CustomPaint(
                painter: _TracePainter(
                  model: widget.model,
                  strokeIndex: math.min(
                    math.max(0, widget.strokes.length - 1),
                    widget.model.strokes.length - 1,
                  ),
                  strokeT: _liveStrokeT(),
                  completed: false,
                  userStrokes: widget.strokes,
                  eval: widget.eval,
                  difficulty: widget.difficulty,
                  showGuide: showGuide && !hasInk,
                  liveInkColor: _liveInkColor,
                ),
                size: Size.infinite,
              ),
            ],
          ),
        );
      },
    );
  }

  void _onDown(PointerDownEvent e, Size size) {
    if (_activePointer != null && _activePointer != e.pointer) return;
    _activePointer = e.pointer;
    // ignore: discarded_futures
    HapticFeedback.selectionClick();
    setState(() {
      // Ensure buffer matches parent (e.g. after Clear).
      if (_local.isEmpty && widget.strokes.isNotEmpty) {
        _local.addAll(widget.strokes.map((s) => List<Offset>.of(s)));
      }
      _current = <Offset>[_toNorm(e.localPosition, size)];
      _local.add(_current!);
    });
    widget.onStrokesChanged(_copy(_local));
  }

  void _onMove(PointerMoveEvent e, Size size) {
    if (_activePointer != e.pointer) return;
    final c = _current;
    if (c != null) {
      final n = _toNorm(e.localPosition, size);
      if (c.isNotEmpty && (c.last - n).distance < 0.004) return;
      setState(() {
        c.add(n);
        _liveInkColor = _liveColorForCurrentStroke();
      });
    }
    widget.onStrokesChanged(_copy(_local));
  }

  void _onUp(PointerEvent e) {
    if (_activePointer == e.pointer) _activePointer = null;
    _current = null;
    _liveInkColor = null;
    // ignore: discarded_futures
    HapticFeedback.selectionClick();
  }

  double _liveStrokeT() {
    final cur = _current;
    if (cur == null) return 0;
    return (cur.length / 36).clamp(0.0, 1.0);
  }

  Color? _liveColorForCurrentStroke() {
    if (widget.eval != null) return null;
    final strokeIdx = widget.strokes.length - 1;
    if (strokeIdx < 0 || strokeIdx >= widget.model.strokes.length) {
      return Colors.white;
    }
    final user = widget.strokes.isNotEmpty ? widget.strokes.last : const <Offset>[];
    if (user.length < 2) return Colors.white;
    final ref = widget.model.strokes[strokeIdx].points;
    final a = _resampleForLive(ref, 32);
    final b = _resampleForLive(user, 32);
    var sum = 0.0;
    for (var i = 0; i < 32; i++) {
      sum += (a[i] - b[i]).distance;
    }
    final avg = sum / 32;
    if (avg < 0.05) return const Color(0xFFB6F6C9);
    if (avg < 0.085) return const Color(0xFFFFD86B);
    return const Color(0xFFFFB4B4);
  }

  List<Offset> _resampleForLive(List<Offset> pts, int n) {
    if (pts.length == 1) return List.filled(n, pts.first);
    final dists = <double>[0];
    var total = 0.0;
    for (var i = 1; i < pts.length; i++) {
      total += (pts[i] - pts[i - 1]).distance;
      dists.add(total);
    }
    if (total <= 0.0001) return List.filled(n, pts.first);
    final out = <Offset>[];
    for (var i = 0; i < n; i++) {
      final t = (total * i) / (n - 1);
      var j = 1;
      while (j < dists.length && dists[j] < t) {
        j++;
      }
      if (j >= dists.length) {
        out.add(pts.last);
        continue;
      }
      final t0 = dists[j - 1];
      final t1 = dists[j];
      final f = (t1 - t0) <= 0.0001 ? 0.0 : ((t - t0) / (t1 - t0));
      out.add(Offset.lerp(pts[j - 1], pts[j], f)!);
    }
    return out;
  }

  Offset _toNorm(Offset local, Size size) {
    final s = math.min(size.width, size.height);
    final left = (size.width - s) / 2;
    final top = (size.height - s) / 2;
    final dx = ((local.dx - left) / s).clamp(0.0, 1.0);
    final dy = ((local.dy - top) / s).clamp(0.0, 1.0);
    return Offset(dx, dy);
  }

  List<List<Offset>> _copy(List<List<Offset>> inStrokes) {
    return inStrokes.map((s) => List<Offset>.of(s)).toList();
  }
}

class _MiniClear extends StatelessWidget {
  const _MiniClear({required this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF12242B),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF2B3B43)),
          ),
          child: Text(
            'Clear',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}


class _TracePainter extends CustomPainter {
  _TracePainter({
    required this.model,
    required this.strokeIndex,
    required this.strokeT,
    required this.completed,
    required this.userStrokes,
    required this.eval,
    required this.difficulty,
    required this.showGuide,
    required this.liveInkColor,
  });

  final _TraceModel model;
  final int strokeIndex;
  final double strokeT;
  final bool completed;
  final List<List<Offset>> userStrokes;
  final _DrawEval? eval;
  final _DrawDifficulty difficulty;
  final bool showGuide;
  final Color? liveInkColor;

  static const _ghost = Color(0xFF2D3A40);
  static const _grid = Color(0xFF223038);
  static const _guide = Color(0xFF43B9FF);
  static const _ink = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    final left = (size.width - s) / 2;
    final top = (size.height - s) / 2;
    final rect = Rect.fromLTWH(left, top, s, s);

    // Crosshair grid.
    final gridPaint = Paint()
      ..color = _grid
      ..strokeWidth = 1.2;
    canvas.drawLine(
        Offset(rect.center.dx, rect.top),
        Offset(rect.center.dx, rect.bottom),
        gridPaint);
    canvas.drawLine(
        Offset(rect.left, rect.center.dy),
        Offset(rect.right, rect.center.dy),
        gridPaint);

    // Difficulty scaling: ghost → skeleton → memory.
    final ghostAlpha = switch (difficulty) {
      _DrawDifficulty.ghost => 1.0,
      _DrawDifficulty.skeleton => 0.18,
      _DrawDifficulty.memory => 0.0,
    };
    if (ghostAlpha > 0) {
      final tp = TextPainter(
        text: TextSpan(
          text: model.kana,
          style: TextStyle(
            fontSize: s * 0.72 * model.ghostScale,
            fontWeight: FontWeight.w900,
            color: _ghost.withValues(alpha: 0.85 * ghostAlpha),
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      tp.layout(maxWidth: s);
      tp.paint(canvas, Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2));
    }

    // Guide for current stroke (hidden in memory unless hint).
    if (!completed && showGuide) {
      final stroke = model.strokes[strokeIndex];
      final pts = stroke.points
          .map((n) => Offset(rect.left + n.dx * s, rect.top + n.dy * s))
          .toList();
      if (pts.length >= 2) {
        final path = _smoothPath(pts);
        final dashed = _dashPath(path, dash: 10, gap: 7);
        final guidePaint = Paint()
          ..color = _guide
          ..strokeWidth = 6
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(dashed, guidePaint);

        // Highlight completed portion (solid).
        final metrics = path.computeMetrics().toList();
        if (metrics.isNotEmpty) {
          final m = metrics.first;
          final doneLen = (m.length * strokeT).clamp(0.0, m.length);
          final donePath = m.extractPath(0, doneLen);
          final donePaint = Paint()
            ..color = _guide.withValues(alpha: 0.95)
            ..strokeWidth = 8
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;
          canvas.drawPath(donePath, donePaint);
        }

        // Arrow at start.
        final a = pts.first;
        final b = pts.length > 1 ? pts[1] : pts.first + const Offset(1, 0);
        final dir = (b - a);
        final len = dir.distance == 0 ? 1.0 : dir.distance;
        final u = dir / len;
        final center = a;
        final circlePaint = Paint()..color = _guide;
        canvas.drawCircle(center, 16, circlePaint);
        final arrowPaint = Paint()
          ..color = const Color(0xFF0B1419)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;
        final p1 = center + u * 6;
        final ortho = Offset(-u.dy, u.dx);
        canvas.drawLine(p1, p1 - u * 10 + ortho * 8, arrowPaint);
        canvas.drawLine(p1, p1 - u * 10 - ortho * 8, arrowPaint);
      }
    }

    // User ink (color per-stroke after evaluation).
    final inkPaint = Paint()
      ..color = _ink
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (var si = 0; si < userStrokes.length; si++) {
      final stroke = userStrokes[si];
      if (stroke.length < 2) continue;
      final strokeScore = (eval != null && si < eval!.perStroke.length) ? eval!.perStroke[si] : null;
      final c = strokeScore == null
          ? ((si == userStrokes.length - 1 && liveInkColor != null) ? liveInkColor! : _ink)
          : (strokeScore >= 70
              ? const Color(0xFFB6F6C9)
              : (strokeScore >= 45 ? const Color(0xFFFFD86B) : const Color(0xFFFFB4B4)));
      inkPaint.color = c;
      // Strokes here are normalized (0..1). Map into the same square rect.
      final first = Offset(rect.left + stroke.first.dx * s, rect.top + stroke.first.dy * s);
      final path = Path()..moveTo(first.dx, first.dy);
      for (var i = 1; i < stroke.length - 1; i++) {
        final a = Offset(rect.left + stroke[i].dx * s, rect.top + stroke[i].dy * s);
        final b = Offset(rect.left + stroke[i + 1].dx * s, rect.top + stroke[i + 1].dy * s);
        final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
        path.quadraticBezierTo(a.dx, a.dy, mid.dx, mid.dy);
      }
      final last = Offset(rect.left + stroke.last.dx * s, rect.top + stroke.last.dy * s);
      path.lineTo(last.dx, last.dy);
      canvas.drawPath(path, inkPaint);
    }
  }

  Path _dashPath(Path source, {required double dash, required double gap}) {
    final out = Path();
    for (final m in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < m.length) {
        final len = math.min(dash, m.length - distance);
        out.addPath(m.extractPath(distance, distance + len), Offset.zero);
        distance += dash + gap;
      }
    }
    return out;
  }

  Path _smoothPath(List<Offset> pts) {
    if (pts.length < 2) return Path();
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    if (pts.length == 2) {
      path.lineTo(pts.last.dx, pts.last.dy);
      return path;
    }
    for (var i = 1; i < pts.length - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      path.quadraticBezierTo(a.dx, a.dy, mid.dx, mid.dy);
    }
    path.lineTo(pts.last.dx, pts.last.dy);
    return path;
  }

  @override
  bool shouldRepaint(covariant _TracePainter oldDelegate) => true;
}

class _VocabPic extends StatelessWidget {
  const _VocabPic({
    required this.vocab,
    required this.selected,
    required this.locked,
    required this.onPick,
  });

  final VocabWord vocab;
  final String? selected;
  final bool locked;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final opts = HiraganaLesson1Data.vocabList.map((v) => v.kana).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Which word matches this picture?',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        _GlassSurface(
          radius: 18,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(vocab.imagePath, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 14),
        for (final k in opts)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _WordChip(
              word: k,
              selected: selected == k,
              locked: locked,
              onTap: () {
                HapticFeedback.selectionClick();
                onPick(k);
              },
            ),
          ),
      ],
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.word,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final String word;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? Colors.white.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.22);
    final tint =
        selected ? const Color(0xFF43B9FF) : const Color(0xFFBFEFFF);
    return _GlassInkCard(
      borderRadius: 16,
      onTap: locked ? null : onTap,
      borderColor: border,
      borderWidth: selected ? 1.6 : 1,
      tint: tint,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              word,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 26,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.75)),
        ],
      ),
    );
  }
}

class _GlassInkCard extends StatelessWidget {
  const _GlassInkCard({
    required this.child,
    required this.borderRadius,
    required this.borderColor,
    required this.borderWidth,
    required this.tint,
    this.onTap,
    this.padding,
  });

  final Widget child;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final Color tint;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: borderColor, width: borderWidth),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tint.withValues(alpha: 0.18),
                      Colors.white.withValues(alpha: 0.04),
                    ],
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

