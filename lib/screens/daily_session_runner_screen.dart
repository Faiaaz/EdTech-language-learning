import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/lms_controller.dart';
import 'package:ez_trainz/controllers/journey_controller.dart';
import 'package:ez_trainz/controllers/srs_controller.dart';
import 'package:ez_trainz/controllers/streak_controller.dart';
import 'package:ez_trainz/models/daily_session.dart';
import 'package:ez_trainz/models/lesson.dart';
import 'package:ez_trainz/models/xp_event.dart';
import 'package:ez_trainz/services/daily_session_planner.dart';
import 'package:ez_trainz/services/sm2_srs_service.dart';

class DailySessionRunnerScreen extends StatefulWidget {
  const DailySessionRunnerScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<DailySessionRunnerScreen> createState() => _DailySessionRunnerScreenState();
}

class _DailySessionRunnerScreenState extends State<DailySessionRunnerScreen> {
  static const _bg = Color(0xFF4DA6E8);
  static const _accent = Color(0xFFFFE000);

  late final DailySessionPlan _plan;
  int _stepIndex = 0;

  @override
  void initState() {
    super.initState();
    final srs = SrsController.to;
    // Register LMS quiz titles so they can enter the review pool over time.
    srs.registerLmsCards(
      lessonId: widget.lesson.id.toString(),
      lessonTitle: widget.lesson.title,
      quizTitles: widget.lesson.quizzes.map((q) => q.title).toList(),
    );

    _plan = const DailySessionPlanner().build(
      lesson: widget.lesson,
      dueCards: srs.dueCards,
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = _plan.steps;
    final total = steps.length;
    final progress = total == 0 ? 0.0 : (_stepIndex / total).clamp(0.0, 1.0);
    final step = steps.isEmpty ? null : steps[_stepIndex.clamp(0, total - 1)];

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white38, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Exit',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(_stepIndex + 1).clamp(1, total)} / $total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(_accent),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: step == null
                    ? const Center(child: Text('No steps'))
                    : _StepBody(
                        step: step,
                        onNext: _next,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _next() {
    if (!mounted) return;
    if (_stepIndex >= _plan.steps.length - 1) {
      // Session complete → protect streak.
      final earnedStreak = !StreakController.to.isTodayComplete;
      // ignore: discarded_futures
      StreakController.to.markTodayCompleted();
      // Fire-and-forget LMS progress update when available.
      // ignore: discarded_futures
      LmsController.to.updateLessonProgress(
        lessonId: widget.lesson.id.toString(),
        completed: true,
        progressPct: 100,
      );
      // Optional XP hooks (re-uses Journey/level-up system).
      // ignore: discarded_futures
      JourneyController.to.grantXp(
        source: XpSource.lesson,
        note: 'Daily session: ${widget.lesson.title}',
      );
      if (earnedStreak) {
        // ignore: discarded_futures
        JourneyController.to.grantXp(source: XpSource.dailyStreak, note: 'Daily session streak');
      }
      Get.back();
      return;
    }
    setState(() => _stepIndex++);
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.step, required this.onNext});

  final DailySessionStep step;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return switch (step) {
      SrsReviewStep s => _SrsReview(step: s, onDone: onNext),
      MicroLessonStep s => _MicroLesson(step: s, onNext: onNext),
      QuickCheckStep s => _QuickCheck(step: s, onNext: onNext),
      WrapUpStep s => _WrapUp(step: s, onFinish: onNext),
    };
  }
}

class _SrsReview extends StatefulWidget {
  const _SrsReview({required this.step, required this.onDone});
  final SrsReviewStep step;
  final VoidCallback onDone;

  @override
  State<_SrsReview> createState() => _SrsReviewState();
}

class _SrsReviewState extends State<_SrsReview> {
  int _i = 0;
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final cards = widget.step.cards;
    if (cards.isEmpty) {
      return _EmptyBlock(
        title: 'Reviews',
        subtitle: 'No reviews due right now.',
        onNextLabel: 'Continue',
        onNext: widget.onDone,
      );
    }

    final card = cards[_i.clamp(0, cards.length - 1)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick reviews',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Card ${_i + 1} of ${cards.length}',
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: () => setState(() => _showAnswer = !_showAnswer),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF4DA6E8).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF4DA6E8).withValues(alpha: 0.25)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _showAnswer ? card.label : 'Tap to reveal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _showAnswer ? 18 : 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A2E),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _showAnswer ? 'How well did you remember it?' : card.id,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF6B7280).withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: !_showAnswer
              ? _PrimaryButton(label: 'Reveal', onTap: () => setState(() => _showAnswer = true))
              : Row(
                  children: [
                    Expanded(
                      child: _PillButton(
                        label: 'Forgot',
                        color: const Color(0xFFE53935),
                        onTap: () => _rate(card.id, RecallQuality.blackout),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PillButton(
                        label: 'Hard',
                        color: const Color(0xFFF57C00),
                        onTap: () => _rate(card.id, RecallQuality.hardCorrect),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PillButton(
                        label: 'Easy',
                        color: const Color(0xFF43A047),
                        onTap: () => _rate(card.id, RecallQuality.perfect),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  void _rate(String cardId, RecallQuality q) {
    SrsController.to.reviewCard(cardId, q);
    if (_i >= widget.step.cards.length - 1) {
      widget.onDone();
      return;
    }
    setState(() {
      _i++;
      _showAnswer = false;
    });
  }
}

class _MicroLesson extends StatelessWidget {
  const _MicroLesson({required this.step, required this.onNext});
  final MicroLessonStep step;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              step.excerpt,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _PrimaryButton(label: 'Continue', onTap: onNext),
      ],
    );
  }
}

class _QuickCheck extends StatelessWidget {
  const _QuickCheck({required this.step, required this.onNext});
  final QuickCheckStep step;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          step.prompt,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 16,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Pick one:',
          style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        _PrimaryButton(
          label: 'I got it',
          onTap: onNext,
        ),
        const SizedBox(height: 10),
        _SecondaryButton(
          label: 'Not yet (show me again later)',
          onTap: onNext,
        ),
        const Spacer(),
      ],
    );
  }
}

class _WrapUp extends StatefulWidget {
  const _WrapUp({required this.step, required this.onFinish});
  final WrapUpStep step;
  final VoidCallback onFinish;

  @override
  State<_WrapUp> createState() => _WrapUpState();
}

class _WrapUpState extends State<_WrapUp> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 900))
      ..play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 24,
            emissionFrequency: 0.08,
            gravity: 0.35,
            shouldLoop: false,
            colors: const [
              Color(0xFFFFE000),
              Color(0xFF4DA6E8),
              Color(0xFF43A047),
              Color(0xFFE53935),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE000).withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  size: 46, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 18),
            Text(
              step.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              step.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            _PrimaryButton(label: 'Finish', onTap: widget.onFinish),
          ],
        ),
      ],
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({
    required this.title,
    required this.subtitle,
    required this.onNextLabel,
    required this.onNext,
  });

  final String title;
  final String subtitle;
  final String onNextLabel;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
        ),
        const Spacer(),
        _PrimaryButton(label: onNextLabel, onTap: onNext),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE000),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFE000).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1.4),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

