import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/screens/sign_up_screen.dart';

class NihongoTrialGameScreen extends StatefulWidget {
  const NihongoTrialGameScreen({super.key});

  @override
  State<NihongoTrialGameScreen> createState() => _NihongoTrialGameScreenState();
}

class _NihongoTrialGameScreenState extends State<NihongoTrialGameScreen>
    with TickerProviderStateMixin {
  static const _bg = Color(0xFF0B1326);
  static const _gold = Color(0xFFFFE000);

  final _tts = FlutterTts();
  late final PageController _pages;

  late final ConfettiController _confetti;

  int _page = 0;
  bool _quizMode = false;
  int _quizIndex = 0;
  String? _selected;
  bool _checked = false;
  int _score = 0;

  final _vocab = const <_Vocab>[
    _Vocab(
      jp: 'あさ',
      romaji: 'asa',
      en: 'morning',
      bn: 'সকাল',
      bnPronunciation: 'আসা',
      image: 'assets/images/vocab_asa.png',
    ),
    _Vocab(
      jp: 'さようなら',
      romaji: 'sayonara',
      en: 'goodbye',
      bn: 'বিদায়',
      bnPronunciation: 'সায়োনারা',
      image: 'assets/images/vocab_sayonara.png',
    ),
    _Vocab(
      jp: 'いえ',
      romaji: 'ie',
      en: 'house',
      bn: 'বাসা',
      bnPronunciation: 'ইয়ে',
      image: 'assets/images/vocab_ie.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pages = PageController();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _setupTts();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakCurrent());
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage('ja-JP');
    await _tts.setVolume(1.0); // loud
    await _tts.setSpeechRate(0.42); // slow-ish like Duolingo
    await _tts.setPitch(1.0);
  }

  Future<void> _speakVocab(_Vocab item, {bool emphasize = false}) async {
    await _tts.stop();

    // Make "いえ" extra clear: slow down and insert a tiny pause between mora.
    // Many iOS voices tend to blur it into something like "ye".
    if (item.jp == 'いえ') {
      // Speak ONCE (like the others), but adjust delivery slightly to avoid
      // the common iOS blur on this word.
      await _tts.setSpeechRate(emphasize ? 0.28 : 0.36);
      await _tts.setPitch(1.05); // clearer separation on many voices
      await _tts.speak('いえ');
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.42); // restore default
      return;
    }

    await _tts.setSpeechRate(emphasize ? 0.30 : 0.42);
    await _tts.speak(item.jp);
  }

  Future<void> _speakCurrent({bool emphasize = false}) async {
    if (!mounted) return;
    if (_quizMode) {
      final item = _vocab[_quizIndex];
      await _speakVocab(item, emphasize: emphasize);
      return;
    }
    final item = _vocab[_page.clamp(0, _vocab.length - 1)];
    await _speakVocab(item, emphasize: emphasize);
  }

  @override
  void dispose() {
    _pages.dispose();
    _tts.stop();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: math.pi / 2,
              numberOfParticles: 24,
              maxBlastForce: 28,
              minBlastForce: 12,
              gravity: 0.20,
              emissionFrequency: 0.06,
              colors: const [
                Color(0xFFFFE000),
                Color(0xFF3B82F6),
                Color(0xFF10B981),
                Color(0xFF8B5CF6),
                Color(0xFFEF4444),
                Color(0xFFF59E0B),
                Color(0xFFEC4899),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white54),
                      ),
                      Expanded(
                        child: Text(
                          _quizMode ? 'trial_quiz_label'.tr : 'trial_label'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _gold,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          _speakCurrent();
                        },
                        icon: const Icon(Icons.volume_up_rounded,
                            color: _gold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _quizMode
                      ? _QuizHeader(
                          index: _quizIndex + 1,
                          total: _vocab.length,
                          score: _score,
                        )
                      : _LessonHeader(step: _page + 1, total: _vocab.length),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: _quizMode ? _buildQuiz() : _buildLesson(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onPrimary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _primaryLabel,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _primaryLabel {
    if (!_quizMode) {
      return _page == _vocab.length - 1 ? 'trial_start_quiz'.tr : 'next'.tr;
    }
    if (!_checked) return 'check'.tr;
    return _quizIndex == _vocab.length - 1 ? 'trial_finish'.tr : 'trial_continue'.tr;
  }

  void _onPrimary() {
    HapticFeedback.selectionClick();
    if (!_quizMode) {
      if (_page == _vocab.length - 1) {
        setState(() {
          _quizMode = true;
          _quizIndex = 0;
          _selected = null;
          _checked = false;
          _score = 0;
        });
        _speakCurrent();
        return;
      }
      _pages.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    if (!_checked) {
      if (_selected == null) return;
      final correct = _selected == _vocab[_quizIndex].jp;
      setState(() {
        _checked = true;
        if (correct) _score++;
      });
      if (correct) {
        HapticFeedback.heavyImpact();
        _confetti.play();
      } else {
        HapticFeedback.mediumImpact();
      }
      return;
    }

    if (_quizIndex == _vocab.length - 1) {
      _finish();
      return;
    }

    setState(() {
      _quizIndex++;
      _selected = null;
      _checked = false;
    });
    _speakCurrent();
  }

  void _finish() {
    HapticFeedback.heavyImpact();
    Get.dialog(
      _TrialCompleteDialog(score: _score, total: _vocab.length),
      barrierDismissible: false,
    );
  }

  Widget _buildLesson() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF111827)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _gold.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: PageView.builder(
          controller: _pages,
          itemCount: _vocab.length,
          onPageChanged: (i) {
            setState(() => _page = i);
            _speakCurrent();
          },
          itemBuilder: (_, i) {
            final item = _vocab[i];
            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: _VocabSlide(
                vocab: item,
                onSpeak: _speakCurrent,
                onSpeakEmphasize: () => _speakCurrent(emphasize: true),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuiz() {
    final q = _vocab[_quizIndex];
    final options = _vocab.toList();
    options.shuffle(math.Random(1000 + _quizIndex));

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _gold.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: 0.07),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: _gold.withValues(alpha: 0.35)),
                    ),
                    child: const Icon(Icons.quiz_rounded,
                        color: _gold, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'trial_which_matches'.tr,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(q.image, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 14),
              for (final opt in options) ...[
                const SizedBox(height: 10),
                _OptionTile(
                  jp: opt.jp,
                  bnPronunciation: opt.bnPronunciation,
                  selected: _selected == opt.jp,
                  state: _checked
                      ? (opt.jp == q.jp
                          ? _OptionState.correct
                          : (_selected == opt.jp
                              ? _OptionState.wrong
                              : _OptionState.neutral))
                      : _OptionState.neutral,
                  onTap: _checked
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          setState(() => _selected = opt.jp);
                        },
                ),
              ],
              if (_checked) ...[
                const SizedBox(height: 12),
                _ResultPill(
                  correct: _selected == q.jp,
                  jp: q.jp,
                  romaji: q.romaji,
                  en: q.en,
                  bn: q.bn,
                  bnPronunciation: q.bnPronunciation,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Vocab {
  const _Vocab({
    required this.jp,
    required this.romaji,
    required this.en,
    required this.bn,
    required this.bnPronunciation,
    required this.image,
  });
  final String jp;
  final String romaji;
  final String en;
  final String bn;
  final String bnPronunciation;
  final String image;
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({required this.step, required this.total});
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'trial_learn_words'.tr,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          '$step/$total',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _QuizHeader extends StatelessWidget {
  const _QuizHeader({required this.index, required this.total, required this.score});
  final int index;
  final int total;
  final int score;

  static const _gold = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'trial_quick_quiz'.tr,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _gold.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _gold.withValues(alpha: 0.35)),
          ),
          child: Text(
            '$score',
            style: const TextStyle(
              color: _gold,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$index/$total',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _VocabSlide extends StatelessWidget {
  const _VocabSlide({
    required this.vocab,
    required this.onSpeak,
    required this.onSpeakEmphasize,
  });

  final _Vocab vocab;
  final VoidCallback onSpeak;
  final VoidCallback onSpeakEmphasize;

  static const _gold = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(vocab.image, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutBack,
          transitionBuilder: (child, a) => ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(a),
            child: FadeTransition(opacity: a, child: child),
          ),
          child: Column(
            key: ValueKey(vocab.jp),
            children: [
              Text(
                vocab.jp,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${vocab.romaji} · ${vocab.en}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _gold.withValues(alpha: 0.30)),
                ),
                child: Text(
                  Get.locale?.languageCode == 'bn'
                      ? '${vocab.bnPronunciation} এর অর্থ হল ${vocab.bn}'
                      : '${vocab.romaji} ${'trial_means'.tr} ${vocab.en}',
                  style: TextStyle(
                    color: _gold.withValues(alpha: 0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
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
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onSpeakEmphasize();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _gold,
                  side: BorderSide(color: _gold.withValues(alpha: 0.55)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.volume_up_rounded, size: 18),
                label: Text(
                  'trial_slow_loud'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum _OptionState { neutral, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.jp,
    required this.bnPronunciation,
    required this.selected,
    required this.state,
    required this.onTap,
  });

  final String jp;
  final String bnPronunciation;
  final bool selected;
  final _OptionState state;
  final VoidCallback? onTap;

  static const _gold = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    Color border;
    Color bg;
    Color fg;

    switch (state) {
      case _OptionState.correct:
        border = const Color(0xFF10B981);
        bg = const Color(0xFF10B981).withValues(alpha: 0.14);
        fg = const Color(0xFF10B981);
        break;
      case _OptionState.wrong:
        border = const Color(0xFFEF4444);
        bg = const Color(0xFFEF4444).withValues(alpha: 0.14);
        fg = const Color(0xFFEF4444);
        break;
      case _OptionState.neutral:
        border = selected ? _gold.withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.14);
        bg = selected ? _gold.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.05);
        fg = selected ? _gold : Colors.white.withValues(alpha: 0.9);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    jp,
                    style: TextStyle(
                      color: fg,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      bnPronunciation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg.withValues(alpha: 0.78),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: border,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultPill extends StatelessWidget {
  const _ResultPill({
    required this.correct,
    required this.jp,
    required this.romaji,
    required this.en,
    required this.bn,
    required this.bnPronunciation,
  });

  final bool correct;
  final String jp;
  final String romaji;
  final String en;
  final String bn;
  final String bnPronunciation;

  @override
  Widget build(BuildContext context) {
    final c = correct ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: c,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              Get.locale?.languageCode == 'bn'
                  ? '$jp · $romaji · $bnPronunciation এর অর্থ হল $bn'
                  : '$jp · $romaji · $en',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrialCompleteDialog extends StatelessWidget {
  const _TrialCompleteDialog({required this.score, required this.total});

  final int score;
  final int total;

  static const _popupAsset = 'assets/images/trial_end_popup.png';
  static const _subscribePopupAsset = 'assets/images/trial_subscribe_popup.png';
  static const _signupFormPopupAsset = 'assets/images/signup_form_popup.png';

  // Aspect ratio of trial_end_popup.png (width / height).
  // Source image is 620 x 945 → ~0.656.
  static const double _aspect = 620 / 945;
  // Aspect ratio of trial_subscribe_popup.png (width / height).
  // Source image is 832 x 1024 → 0.8125.
  static const double _subscribeAspect = 832 / 1024;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final maxW = math.min(340.0, mq.size.width - 32);

    void onSignUp() {
      Get.dialog(
        _SubscribeUpsellDialog(
          onJoin: () {
            Get.back(); // close subscribe popup
            Get.back(); // close trial end popup
            Get.to(
              () => const SignUpScreen(),
              transition: Transition.downToUp,
              duration: const Duration(milliseconds: 240),
            );
          },
          onSignUp: () {
            Get.dialog(
              _SignupFormImageDialog(
                onContinue: () {
                  Get.back(); // close signup image
                  Get.back(); // close subscribe popup
                  Get.back(); // close trial end popup
                  Get.to(
                    () => const SignUpScreen(),
                    transition: Transition.downToUp,
                    duration: const Duration(milliseconds: 240),
                  );
                },
              ),
              barrierDismissible: true,
            );
          },
        ),
        barrierDismissible: true,
      );
    }

    void onGuest() {
      Get.back(); // close popup
      Get.back(); // leave trial game
    }

    void onSignIn() {
      Get.back();
      Get.toNamed('/login');
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: AspectRatio(
            aspectRatio: _aspect,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    _popupAsset,
                    fit: BoxFit.contain,
                  ),
                ),
                LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    final h = c.maxHeight;
                    return Stack(
                      children: [
                        // Sign Up & Subscribe button hot-zone
                        Positioned(
                          left: w * 0.07,
                          top: h * 0.785,
                          width: w * 0.86,
                          height: h * 0.085,
                          child: _TapZone(onTap: onSignUp),
                        ),
                        // Continue as Guest link hot-zone
                        Positioned(
                          left: w * 0.10,
                          top: h * 0.905,
                          width: w * 0.42,
                          height: h * 0.06,
                          child: _TapZone(onTap: onGuest),
                        ),
                        // Sign In link hot-zone
                        Positioned(
                          left: w * 0.60,
                          top: h * 0.905,
                          width: w * 0.30,
                          height: h * 0.06,
                          child: _TapZone(onTap: onSignIn),
                        ),
                      ],
                    );
                  },
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.white.withValues(alpha: 0.65),
                    splashRadius: 18,
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

class _SubscribeUpsellDialog extends StatelessWidget {
  const _SubscribeUpsellDialog({required this.onJoin, required this.onSignUp});

  final VoidCallback onJoin;
  final VoidCallback onSignUp;

  static const _asset = _TrialCompleteDialog._subscribePopupAsset;
  static const double _aspect = _TrialCompleteDialog._subscribeAspect;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final maxW = math.min(380.0, mq.size.width - 28);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: AspectRatio(
            aspectRatio: _aspect,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    _asset,
                    fit: BoxFit.contain,
                  ),
                ),
                LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    final h = c.maxHeight;
                    return Stack(
                      children: [
                        // Join the Journey button hot-zone
                        Positioned(
                          left: w * 0.38,
                          top: h * 0.86,
                          width: w * 0.44,
                          height: h * 0.095,
                          child: _TapZone(onTap: onJoin),
                        ),
                        // Sign Up button hot-zone (left of Join the Journey)
                        Positioned(
                          left: w * 0.18,
                          top: h * 0.86,
                          width: w * 0.18,
                          height: h * 0.095,
                          child: _TapZone(onTap: onSignUp),
                        ),
                      ],
                    );
                  },
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.white.withValues(alpha: 0.65),
                    splashRadius: 18,
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

class _SignupFormImageDialog extends StatelessWidget {
  const _SignupFormImageDialog({required this.onContinue});

  final VoidCallback onContinue;

  static const _asset = _TrialCompleteDialog._signupFormPopupAsset;
  static const double _aspect = 472 / 1024;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final maxW = math.min(380.0, mq.size.width - 24);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: AspectRatio(
            aspectRatio: _aspect,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    _asset,
                    fit: BoxFit.contain,
                  ),
                ),
                LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    final h = c.maxHeight;
                    return Stack(
                      children: [
                        // Main submit button hot-zone ("চালিয়ে যান")
                        Positioned(
                          left: w * 0.10,
                          top: h * 0.82,
                          width: w * 0.80,
                          height: h * 0.08,
                          child: _TapZone(onTap: onContinue),
                        ),
                      ],
                    );
                  },
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: Colors.white.withValues(alpha: 0.70),
                    splashRadius: 18,
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

class _TapZone extends StatelessWidget {
  const _TapZone({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        splashColor: Colors.white.withValues(alpha: 0.10),
        highlightColor: Colors.white.withValues(alpha: 0.06),
        child: const SizedBox.expand(),
      ),
    );
  }
}
