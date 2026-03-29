import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/ielts_controller.dart';
import 'package:ez_trainz/models/ielts.dart';
import 'package:ez_trainz/services/sm2_srs_service.dart';

/// IELTS Academic Vocabulary Builder using SRS flashcards.
class IeltsVocabularyScreen extends StatelessWidget {
  const IeltsVocabularyScreen({super.key});

  static const _indigo = Color(0xFF667EEA);
  static const _indigoDark = Color(0xFF764BA2);

  @override
  Widget build(BuildContext context) {
    final ctrl = IeltsController.to;

    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [_indigo, _indigoDark])),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white38)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Back', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Academic Vocabulary', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('Master high-frequency IELTS words with spaced repetition', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                  const SizedBox(height: 12),
                  Obx(() => Row(children: [
                    _StatBadge(label: 'Due', value: '${ctrl.vocabDueCount.value}', color: const Color(0xFFFFCC02)),
                    const SizedBox(width: 8),
                    _StatBadge(label: 'Total', value: '${ctrl.vocabTotalCount.value}', color: Colors.white70),
                  ])),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (ctrl.vocabSessionQueue.isNotEmpty && !ctrl.vocabSessionDone) {
                  return _VocabReviewSession(ctrl: ctrl);
                }
                if (ctrl.vocabSessionQueue.isNotEmpty && ctrl.vocabSessionDone) {
                  return _VocabSessionSummary(ctrl: ctrl);
                }
                return _VocabHome(ctrl: ctrl);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBadge({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _VocabHome extends StatelessWidget {
  final IeltsController ctrl;
  const _VocabHome({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Start review button
          GestureDetector(
            onTap: () => ctrl.startVocabSession(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Start Review Session', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  SizedBox(height: 2),
                  Text('Review due vocabulary with flashcards', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ])),
              ]),
            ),
          ),

          const SizedBox(height: 24),
          const Text('Word List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 14),

          ...ctrl.vocabulary.map((v) => _VocabWordCard(vocab: v)),
        ],
      ),
    );
  }
}

class _VocabWordCard extends StatelessWidget {
  final IeltsVocabulary vocab;
  const _VocabWordCard({required this.vocab});

  Color _bandColor(IeltsDifficulty d) {
    switch (d) {
      case IeltsDifficulty.band5: return const Color(0xFF4CAF50);
      case IeltsDifficulty.band6: return const Color(0xFF2196F3);
      case IeltsDifficulty.band7: return const Color(0xFFFF9800);
      case IeltsDifficulty.band8: return const Color(0xFFF44336);
      case IeltsDifficulty.band9: return const Color(0xFF9C27B0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(vocab.word, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
          const SizedBox(width: 8),
          Text('(${vocab.partOfSpeech})', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E), fontStyle: FontStyle.italic)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: _bandColor(vocab.bandLevel).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(vocab.bandLevel.name, style: TextStyle(color: _bandColor(vocab.bandLevel), fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(vocab.definition, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
        const SizedBox(height: 6),
        Text('\u201c${vocab.exampleSentence}\u201d', style: const TextStyle(fontSize: 12, color: Color(0xFF888888), fontStyle: FontStyle.italic, height: 1.4)),
        if (vocab.synonyms.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 4, children: [
            const Text('Synonyms: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF667EEA))),
            ...vocab.synonyms.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFEDE7F6), borderRadius: BorderRadius.circular(8)),
              child: Text(s, style: const TextStyle(fontSize: 11, color: Color(0xFF5C6BC0))),
            )),
          ]),
        ],
      ]),
    );
  }
}

// ── SRS Review Session ──────────────────────────────────────────────
class _VocabReviewSession extends StatelessWidget {
  final IeltsController ctrl;
  const _VocabReviewSession({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final card = ctrl.currentVocabCard;
    if (card == null) return const SizedBox.shrink();

    final vocab = ctrl.vocabForCard(card);
    final shown = ctrl.isVocabAnswerShown.value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${ctrl.currentVocabIndex.value + 1} / ${ctrl.vocabSessionQueue.length}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF667EEA))),
            Text('${ctrl.vocabSessionCorrect.value} correct', style: const TextStyle(fontSize: 14, color: Color(0xFF4CAF50), fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (ctrl.currentVocabIndex.value + 1) / ctrl.vocabSessionQueue.length,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF667EEA)),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 24),

          // Flashcard
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey('${card.id}_$shown'),
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFF667EEA).withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(children: [
                Text(card.label, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1A1A2E))),
                if (vocab != null) ...[
                  const SizedBox(height: 4),
                  Text('(${vocab.partOfSpeech})', style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E), fontStyle: FontStyle.italic)),
                ],
                const SizedBox(height: 6),
                Text('What does this word mean?', style: const TextStyle(fontSize: 14, color: Color(0xFF888888))),
                if (shown && vocab != null) ...[
                  const Divider(height: 32),
                  Text(vocab.definition, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333), height: 1.4), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text('\u201c${vocab.exampleSentence}\u201d', style: const TextStyle(fontSize: 13, color: Color(0xFF888888), fontStyle: FontStyle.italic, height: 1.4), textAlign: TextAlign.center),
                  if (vocab.collocations.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(spacing: 6, runSpacing: 4, children: vocab.collocations.map((c) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFEDE7F6), borderRadius: BorderRadius.circular(10)),
                      child: Text(c, style: const TextStyle(fontSize: 12, color: Color(0xFF5C6BC0), fontWeight: FontWeight.w600)),
                    )).toList()),
                  ],
                ],
              ]),
            ),
          ),

          const SizedBox(height: 24),

          if (!shown)
            GestureDetector(
              onTap: () => ctrl.showVocabAnswer(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(child: Text('Show Answer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
              ),
            ),

          if (shown) ...[
            const Text('How well did you know this?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
            const SizedBox(height: 14),
            Row(children: [
              _RatingButton(label: 'Forgot', color: const Color(0xFFF44336), onTap: () => ctrl.submitVocabRating(RecallQuality.wrong)),
              const SizedBox(width: 8),
              _RatingButton(label: 'Hard', color: const Color(0xFFFF9800), onTap: () => ctrl.submitVocabRating(RecallQuality.hardCorrect)),
              const SizedBox(width: 8),
              _RatingButton(label: 'Easy', color: const Color(0xFF4CAF50), onTap: () => ctrl.submitVocabRating(RecallQuality.correctWithHesitation)),
              const SizedBox(width: 8),
              _RatingButton(label: 'Perfect', color: const Color(0xFF2196F3), onTap: () => ctrl.submitVocabRating(RecallQuality.perfect)),
            ]),
          ],
        ],
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _RatingButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))),
        ),
      ),
    );
  }
}

// ── Session Summary ─────────────────────────────────────────────────
class _VocabSessionSummary extends StatelessWidget {
  final IeltsController ctrl;
  const _VocabSessionSummary({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final reviewed = ctrl.vocabSessionReviewed.value;
    final correct = ctrl.vocabSessionCorrect.value;
    final pct = reviewed > 0 ? (correct / reviewed * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFF667EEA).withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(children: [
              const Icon(Icons.celebration_rounded, color: Color(0xFF667EEA), size: 56),
              const SizedBox(height: 16),
              const Text('Session Complete!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _SummaryStatCircle(value: '$reviewed', label: 'Reviewed', color: const Color(0xFF667EEA)),
                _SummaryStatCircle(value: '$correct', label: 'Correct', color: const Color(0xFF4CAF50)),
                _SummaryStatCircle(value: '$pct%', label: 'Accuracy', color: const Color(0xFFFF9800)),
              ]),
            ]),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => ctrl.endVocabSession(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(child: Text('Done', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStatCircle extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _SummaryStatCircle({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
        child: Center(child: Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900))),
      ),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
    ]);
  }
}
