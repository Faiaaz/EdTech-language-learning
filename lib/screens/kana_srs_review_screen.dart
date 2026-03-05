import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/srs_controller.dart';
import 'package:ez_trainz/models/kana.dart';
import 'package:ez_trainz/services/srs_service.dart';

/// Flashcard review screen for Kana SRS.
///
/// Shows one card at a time. User recalls the reading, taps "Show Answer",
/// then rates their recall as Forgot / Hard / Easy.
class KanaSrsReviewScreen extends StatelessWidget {
  const KanaSrsReviewScreen({super.key});

  static const _sakura = Color(KanaData.sakuraPink);
  static const _sakuraLight = Color(KanaData.sakuraPinkLight);
  static const _sakuraDark = Color(KanaData.sakuraPinkDark);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SrsController>();

    return Scaffold(
      backgroundColor: _sakuraLight,
      body: SafeArea(
        child: Obx(() {
          if (ctrl.sessionDone) return _SessionSummary(ctrl: ctrl);
          return _ReviewBody(ctrl: ctrl);
        }),
      ),
    );
  }
}

// ── Review body ──────────────────────────────────────────────────────────────

class _ReviewBody extends StatelessWidget {
  final SrsController ctrl;
  const _ReviewBody({required this.ctrl});

  static const _sakura = Color(KanaData.sakuraPink);
  static const _sakuraLight = Color(KanaData.sakuraPinkLight);
  static const _sakuraDark = Color(KanaData.sakuraPinkDark);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final card = ctrl.currentCard;
      if (card == null) return const SizedBox.shrink();

      final kana = ctrl.kanaForCard(card);
      final isHiragana = card.id.startsWith('hiragana_');
      final scriptLabel = isHiragana ? 'Hiragana' : 'Katakana';
      final scriptColor = isHiragana ? _sakura : const Color(0xFF7B1FA2);
      final answered = ctrl.isAnswerShown.value;
      final progress = ctrl.sessionProgress;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_sakura, _sakuraDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ctrl.endSession();
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white38, width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_ios_rounded,
                                color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('Back',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${ctrl.currentIndex.value + 1} / ${ctrl.sessionQueue.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Flashcard Review',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // ── Card ────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Script type chip
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: scriptColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        scriptLabel,
                        style: TextStyle(
                          color: scriptColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main kana card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 40, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _sakura.withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // ── Front: character ──
                        Text(
                          card.label,
                          style: TextStyle(
                            fontSize: 96,
                            color: scriptColor,
                            fontWeight: FontWeight.w400,
                            height: 1.0,
                          ),
                        ),

                        if (answered) ...[
                          const SizedBox(height: 24),
                          Divider(
                              color: _sakuraLight, thickness: 1.5),
                          const SizedBox(height: 20),

                          // ── Back: romaji ──
                          if (kana != null) ...[
                            Text(
                              kana.romaji.toUpperCase(),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: scriptColor,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ── Mnemonic ──
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _sakuraLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.lightbulb_rounded,
                                      color: _sakura, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      kana.mnemonic,
                                      style: const TextStyle(
                                        color: Color(0xFF5D4037),
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Text(
                              card.label,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ] else ...[
                          const SizedBox(height: 16),
                          Text(
                            'What is the reading?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Action area ──────────────────────────────────
                  if (!answered)
                    _ShowAnswerButton(
                      onTap: ctrl.showAnswer,
                      color: scriptColor,
                    )
                  else
                    _RatingButtons(ctrl: ctrl),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _ShowAnswerButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  const _ShowAnswerButton({required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, Color.lerp(color, Colors.black, 0.15)!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flip_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Show Answer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingButtons extends StatelessWidget {
  final SrsController ctrl;
  const _RatingButtons({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How well did you remember?',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RatingButton(
                label: 'Forgot',
                icon: Icons.sentiment_very_dissatisfied_rounded,
                color: const Color(0xFFE53935),
                onTap: () => ctrl.submitRating(RecallQuality.blackout),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RatingButton(
                label: 'Hard',
                icon: Icons.sentiment_neutral_rounded,
                color: const Color(0xFFF57C00),
                onTap: () =>
                    ctrl.submitRating(RecallQuality.hardCorrect),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RatingButton(
                label: 'Easy',
                icon: Icons.sentiment_satisfied_alt_rounded,
                color: const Color(0xFF43A047),
                onTap: () => ctrl.submitRating(RecallQuality.perfect),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RatingButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Session summary ──────────────────────────────────────────────────────────

class _SessionSummary extends StatelessWidget {
  final SrsController ctrl;
  const _SessionSummary({required this.ctrl});

  static const _sakura = Color(KanaData.sakuraPink);
  static const _sakuraDark = Color(KanaData.sakuraPinkDark);

  @override
  Widget build(BuildContext context) {
    final reviewed = ctrl.sessionReviewed.value;
    final correct = ctrl.sessionCorrect.value;
    final accuracy =
        reviewed == 0 ? 0 : ((correct / reviewed) * 100).round();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_sakura, _sakuraDark],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Session Complete!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You reviewed $reviewed cards',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 28),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatChip(
                  value: '$correct',
                  label: 'Correct',
                  color: const Color(0xFF43A047),
                ),
                const SizedBox(width: 16),
                _StatChip(
                  value: '${reviewed - correct}',
                  label: 'Missed',
                  color: const Color(0xFFE53935),
                ),
                const SizedBox(width: 16),
                _StatChip(
                  value: '$accuracy%',
                  label: 'Accuracy',
                  color: _sakura,
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Back button
            GestureDetector(
              onTap: () {
                ctrl.endSession();
                Get.back();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 40),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_sakura, _sakuraDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _sakura.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
