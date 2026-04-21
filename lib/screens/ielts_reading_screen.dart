import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/ielts_controller.dart';
import 'package:ez_trainz/models/ielts.dart';

/// IELTS Reading practice screen with timed passages and multiple question types.
class IeltsReadingScreen extends StatelessWidget {
  const IeltsReadingScreen({super.key});

  static const _green = Color(0xFF4CAF50);
  static const _greenDark = Color(0xFF2E7D32);
  static const _bgLight = Color(0xFFF1F8E9);

  @override
  Widget build(BuildContext context) {
    final ctrl = IeltsController.to;

    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ─────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [_green, _greenDark]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white38),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text('back'.tr, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Reading Practice',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Practice with academic passages and question types',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                  ),
                ],
              ),
            ),

            // ── PASSAGE LIST / PRACTICE ────────────────────
            Expanded(
              child: Obx(() {
                if (ctrl.readingSubmitted.value) {
                  return _ReadingResults(ctrl: ctrl);
                }
                return _PassageSelector(ctrl: ctrl);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassageSelector extends StatelessWidget {
  final IeltsController ctrl;
  const _PassageSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('select_passage'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 14),
          ...List.generate(ctrl.passages.length, (i) {
            final p = ctrl.passages[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  ctrl.selectPassage(i);
                  Get.to(
                    () => _ReadingPractice(ctrl: ctrl),
                    transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 300),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text('P${i + 1}', style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 16, fontWeight: FontWeight.w900)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                            const SizedBox(height: 4),
                            Text('${p.questions.length} questions \u2022 ${p.timeLimitMinutes} min \u2022 ${p.difficulty.name}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B0B0)),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Reading strategies
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFA5D6A7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded, color: Color(0xFF388E3C), size: 20),
                    const SizedBox(width: 8),
                    Text('reading_strategies'.tr, style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 14, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 10),
                const _StrategyItem(title: 'Skim first', text: 'Read the passage quickly to get the main idea before looking at questions'),
                const SizedBox(height: 8),
                const _StrategyItem(title: 'Scan for keywords', text: 'Look for specific words from questions in the passage'),
                const SizedBox(height: 8),
                const _StrategyItem(title: 'Don\'t spend too long', text: 'If stuck on a question, move on and come back later'),
                const SizedBox(height: 8),
                const _StrategyItem(title: 'Watch for synonyms', text: 'IELTS paraphrases — the answer may use different words'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StrategyItem extends StatelessWidget {
  final String title;
  final String text;
  const _StrategyItem({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('\u2022 ', style: TextStyle(color: Color(0xFF388E3C), fontSize: 14, fontWeight: FontWeight.w700)),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: '$title: ', style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 13, fontWeight: FontWeight.w700)),
                TextSpan(text: text, style: const TextStyle(color: Color(0xFF33691E), fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Active Reading Practice ──────────────────────────────────────────
class _ReadingPractice extends StatelessWidget {
  final IeltsController ctrl;
  const _ReadingPractice({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              color: const Color(0xFF4CAF50),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ctrl.currentPassage.title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Obx(() {
                  final passage = ctrl.currentPassage;
                  final submitted = ctrl.readingSubmitted.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Passage text
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(passage.source, style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              passage.passage,
                              style: const TextStyle(fontSize: 14, height: 1.7, color: Color(0xFF333333)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      Text('questions'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 14),

                      // Questions
                      ...List.generate(passage.questions.length, (i) {
                        final q = passage.questions[i];
                        return _QuestionCard(
                          index: i,
                          question: q,
                          ctrl: ctrl,
                          submitted: submitted,
                        );
                      }),

                      const SizedBox(height: 20),

                      // Submit button
                      if (!submitted)
                        GestureDetector(
                          onTap: () => ctrl.submitReading(),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text('submit_answers'.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ),

                      // Results summary
                      if (submitted)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                '${ctrl.readingScore.value} / ${passage.questions.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text('correct_answers'.tr, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () {
                                  ctrl.readingSubmitted.value = false;
                                  ctrl.readingAnswers.clear();
                                  Get.back();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                  child: Text('try_another_passage'.tr, style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 14, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final IeltsQuestion question;
  final IeltsController ctrl;
  final bool submitted;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.ctrl,
    required this.submitted,
  });

  @override
  Widget build(BuildContext context) {
    final userAnswer = ctrl.readingAnswers[question.id] ?? '';
    final isCorrect = userAnswer.trim().toLowerCase() == question.correctAnswer.trim().toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: submitted
            ? Border.all(color: isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFF44336), width: 2)
            : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('${index + 1}', style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 13, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  question.type.name,
                  style: const TextStyle(color: Color(0xFF1976D2), fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(question.questionText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E), height: 1.4)),
          const SizedBox(height: 12),

          // Options or text input
          if (question.options.isNotEmpty)
            ...question.options.map((opt) {
              final optLetter = opt.substring(0, 1);
              final isSelected = userAnswer == optLetter ||
                  userAnswer == opt ||
                  userAnswer.toLowerCase() == opt.toLowerCase();
              return GestureDetector(
                onTap: submitted ? null : () => ctrl.setReadingAnswer(question.id, opt.contains(')') ? opt.substring(0, 1) : opt),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(opt, style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF333333),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  )),
                ),
              );
            }),

          if (question.options.isEmpty)
            TextField(
              onChanged: (val) => ctrl.setReadingAnswer(question.id, val),
              enabled: !submitted,
              decoration: InputDecoration(
                hintText: 'type_answer'.tr,
                hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),

          // Show explanation after submission
          if (submitted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isCorrect ? 'Correct!' : 'Incorrect — Answer: ${question.correctAnswer}',
                        style: TextStyle(
                          color: isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(question.explanation, style: const TextStyle(fontSize: 12, color: Color(0xFF555555), height: 1.4)),
                  if (question.tip != null) ...[
                    const SizedBox(height: 6),
                    Text('\u{1F4A1} ${'tip_prefix'.tr}: ${question.tip!}', style: const TextStyle(fontSize: 12, color: Color(0xFFF57F17), fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReadingResults extends StatelessWidget {
  final IeltsController ctrl;
  const _ReadingResults({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _ReadingPractice(ctrl: ctrl);
  }
}
