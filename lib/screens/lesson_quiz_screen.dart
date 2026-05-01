import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/hearts_controller.dart';
import 'package:ez_trainz/controllers/lesson_quiz_controller.dart';
import 'package:ez_trainz/models/lesson_challenge.dart';
import 'package:ez_trainz/widgets/heart_empty_bottom_sheet.dart';

class LessonQuizScreen extends StatefulWidget {
  const LessonQuizScreen({
    super.key,
    required this.challenges,
    this.practiceMode = false,
    this.showRomaji = false,
  });

  final List<LessonChallenge> challenges;

  /// If true, wrong answers do not consume hearts.
  final bool practiceMode;

  /// If true, show romaji beneath Japanese content when present.
  final bool showRomaji;

  @override
  State<LessonQuizScreen> createState() => _LessonQuizScreenState();
}

class _LessonQuizScreenState extends State<LessonQuizScreen>
    with TickerProviderStateMixin {
  static const _bg = Color(0xFF0B1326);
  static const _gold = Color(0xFFFFE000);
  static const _ok = Color(0xFF10B981);
  static const _bad = Color(0xFFEF4444);

  late final LessonQuizController c;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shake;

  late final AnimationController _flashCtrl;
  late final Animation<double> _flash;

  @override
  void initState() {
    super.initState();
    c = Get.put(
      LessonQuizController(
        challenges: widget.challenges,
        practiceMode: widget.practiceMode,
        showRomaji: widget.showRomaji,
      ),
      tag: _tag,
    );

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _shake = CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeOutBack);

    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _flash = CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut);
  }

  String get _tag => widget.hashCode.toString();

  @override
  void dispose() {
    Get.delete<LessonQuizController>(tag: _tag, force: true);
    _shakeCtrl.dispose();
    _flashCtrl.dispose();
    super.dispose();
  }

  Future<void> _onCta() async {
    switch (c.cta.value) {
      case LessonQuizCtaState.check:
        if (c.selectedChoiceId.value == null) return;
        final correct = c.checkAnswer();
        if (correct) {
          HapticFeedback.heavyImpact();
          SystemSound.play(SystemSoundType.click);
          await _flashCtrl.forward(from: 0);
        } else {
          HapticFeedback.mediumImpact();
          SystemSound.play(SystemSoundType.alert);
          await _shakeCtrl.forward(from: 0);
          if (!widget.practiceMode && HeartsController.to.isEmpty) {
            // Block further progress until user dismisses.
            // ignore: use_build_context_synchronously
            Get.bottomSheet(
              HeartEmptyBottomSheet(onClose: () => Get.back()),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            );
          }
        }
        setState(() {});
        return;

      case LessonQuizCtaState.continueNext:
        final hasNext = c.advance();
        if (!hasNext) {
          // Step 2 will replace this with LessonResultScreen.
          Get.back(result: true);
        } else {
          HapticFeedback.selectionClick();
        }
        setState(() {});
        return;

      case LessonQuizCtaState.tryAgain:
        c.retry();
        HapticFeedback.selectionClick();
        setState(() {});
        return;
    }
  }

  Color _ctaColor() {
    return switch (c.cta.value) {
      LessonQuizCtaState.check => _gold,
      LessonQuizCtaState.continueNext => _ok,
      LessonQuizCtaState.tryAgain => _bad,
    };
  }

  String _ctaLabel() {
    return switch (c.cta.value) {
      LessonQuizCtaState.check => 'check'.tr,
      LessonQuizCtaState.continueNext => 'next'.tr,
      LessonQuizCtaState.tryAgain => 'retry'.tr,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _flashCtrl,
                builder: (_, __) {
                  final v = _flash.value;
                  final correct = c.lastAnswerCorrect.value == true;
                  final wrong = c.lastAnswerCorrect.value == false;
                  final col = correct
                      ? _ok.withValues(alpha: 0.22 * v)
                      : wrong
                          ? _bad.withValues(alpha: 0.18 * v)
                          : Colors.transparent;
                  return IgnorePointer(child: ColoredBox(color: col));
                },
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => _confirmExit(),
                        icon: const Icon(Icons.close_rounded),
                        color: Colors.white70,
                      ),
                      Expanded(child: _ProgressBar(controller: c)),
                      const SizedBox(width: 10),
                      _HeartsPill(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: AnimatedBuilder(
                      animation: _shakeCtrl,
                      builder: (context, child) {
                        final t = _shake.value;
                        final wrong = c.lastAnswerCorrect.value == false;
                        final dx = wrong ? math.sin(t * math.pi * 6) * 8 : 0.0;
                        return Transform.translate(
                          offset: Offset(dx, 0),
                          child: child,
                        );
                      },
                      child: _QuizCard(controller: c),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onCta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _ctaColor(),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        _ctaLabel(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmExit() {
    // Step 3 will implement a proper ExitConfirmationSheet.
    Get.back(result: false);
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.controller});

  final LessonQuizController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final i = controller.index.value;
      final total = controller.total;
      final v = total == 0 ? 0.0 : (i + 1) / total;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: v.clamp(0, 1),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFE000)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${i + 1} / $total',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    });
  }
}

class _HeartsPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hearts = HeartsController.to.hearts.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_rounded, color: Color(0xFFFFE000), size: 16),
            const SizedBox(width: 6),
            Text(
              '$hearts/${HeartsController.maxHearts}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({required this.controller});

  final LessonQuizController controller;

  static const _card = Color(0xFF111827);
  static const _gold = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final challenge = controller.current;
      final selected = controller.selectedChoiceId.value;
      final checked = controller.cta.value != LessonQuizCtaState.check;
      final correctId = challenge.correctChoiceId;
      final showRomaji = controller.showRomaji;

      return Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _gold.withValues(alpha: 0.16)),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: 0.06),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              challenge.prompt,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (challenge.jp != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  children: [
                    Text(
                      challenge.jp!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    if (showRomaji && challenge.romaji != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        challenge.romaji!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: challenge.choices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final choice = challenge.choices[i];
                  final isSelected = selected == choice.id;
                  final isCorrect = checked && choice.id == correctId;
                  final isWrongSelected =
                      checked && isSelected && choice.id != correctId;
                  final border = isCorrect
                      ? const Color(0xFF10B981)
                      : isWrongSelected
                          ? const Color(0xFFEF4444)
                          : isSelected
                              ? _gold
                              : Colors.white.withValues(alpha: 0.10);

                  final bg = isCorrect
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : isWrongSelected
                          ? const Color(0xFFEF4444).withValues(alpha: 0.10)
                          : Colors.white.withValues(alpha: 0.04);

                  return InkWell(
                    onTap: () => controller.select(choice.id),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: border.withValues(alpha: 0.75)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              choice.label,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.90),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (isCorrect)
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF10B981)),
                          if (isWrongSelected)
                            const Icon(Icons.cancel_rounded,
                                color: Color(0xFFEF4444)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

