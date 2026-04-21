import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/ielts_controller.dart';
import 'package:ez_trainz/models/ielts.dart';

/// IELTS Listening practice with transcripts and comprehension questions.
class IeltsListeningScreen extends StatelessWidget {
  const IeltsListeningScreen({super.key});

  static const _blue = Color(0xFF2196F3);
  static const _blueDark = Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    final ctrl = IeltsController.to;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [_blue, _blueDark]),
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
                  Text('listening_practice'.tr, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('listening_practice_desc'.tr,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('select_section'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 14),
                    ...List.generate(ctrl.listeningSections.length, (i) {
                      final s = ctrl.listeningSections[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            ctrl.selectListening(i);
                            Get.to(
                              () => _ListeningPractice(ctrl: ctrl),
                              transition: Transition.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 300),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(color: _blue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                                  child: Center(child: Text('S${s.sectionNumber}', style: const TextStyle(color: _blue, fontSize: 16, fontWeight: FontWeight.w900))),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                                      const SizedBox(height: 4),
                                      Text('${s.questions.length} questions \u2022 ${s.context}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF90CAF9)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.lightbulb_rounded, color: Color(0xFF1976D2), size: 20),
                            const SizedBox(width: 8),
                            Text('listening_tips'.tr, style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 14, fontWeight: FontWeight.w800)),
                          ]),
                          const SizedBox(height: 10),
                          const Text('\u2022 Read questions before listening to know what to listen for\n\u2022 Pay attention to signpost words: "however", "firstly", "in contrast"\n\u2022 Watch for distractors — answers may be corrected or changed\n\u2022 Spelling counts! Practice common academic word spellings\n\u2022 Numbers and names are frequently tested',
                              style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF1565C0))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListeningPractice extends StatelessWidget {
  final IeltsController ctrl;
  const _ListeningPractice({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              color: const Color(0xFF2196F3),
              child: Row(
                children: [
                  GestureDetector(onTap: () => Get.back(), child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(ctrl.currentListening.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Obx(() {
                  final section = ctrl.currentListening;
                  final submitted = ctrl.listeningSubmitted.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Context badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Section ${section.sectionNumber} \u2022 ${section.context}',
                            style: const TextStyle(color: Color(0xFF1976D2), fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 8),
                      Text(section.description, style: const TextStyle(fontSize: 14, color: Color(0xFF555555), height: 1.4)),

                      const SizedBox(height: 16),

                      // Transcript toggle
                      GestureDetector(
                        onTap: () => ctrl.toggleTranscript(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF90CAF9)),
                          ),
                          child: Row(
                            children: [
                              Icon(ctrl.showTranscript.value ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: const Color(0xFF2196F3), size: 20),
                              const SizedBox(width: 10),
                              Text(ctrl.showTranscript.value ? 'Hide Transcript' : 'Show Transcript',
                                  style: const TextStyle(color: Color(0xFF1976D2), fontSize: 14, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),

                      if (ctrl.showTranscript.value) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                          ),
                          child: Text(section.transcript, style: const TextStyle(fontSize: 14, height: 1.7, color: Color(0xFF333333))),
                        ),
                      ],

                      const SizedBox(height: 20),
                      Text('questions'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 14),

                      ...List.generate(section.questions.length, (i) {
                        final q = section.questions[i];
                        return _ListeningQuestionCard(index: i, question: q, ctrl: ctrl, submitted: submitted);
                      }),

                      const SizedBox(height: 20),
                      if (!submitted)
                        GestureDetector(
                          onTap: () => ctrl.submitListening(),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1565C0)]),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(child: Text('submit_answers'.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
                          ),
                        ),

                      if (submitted)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1565C0)]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 48),
                              const SizedBox(height: 12),
                              Text('${ctrl.listeningScore.value} / ${section.questions.length}',
                                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text('correct_answers'.tr, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () {
                                  ctrl.listeningSubmitted.value = false;
                                  ctrl.listeningAnswers.clear();
                                  Get.back();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                  child: Text('try_another_section'.tr, style: const TextStyle(color: Color(0xFF1565C0), fontSize: 14, fontWeight: FontWeight.w700)),
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

class _ListeningQuestionCard extends StatelessWidget {
  final int index;
  final IeltsQuestion question;
  final IeltsController ctrl;
  final bool submitted;

  const _ListeningQuestionCard({required this.index, required this.question, required this.ctrl, required this.submitted});

  @override
  Widget build(BuildContext context) {
    final userAnswer = ctrl.listeningAnswers[question.id] ?? '';
    final isCorrect = userAnswer.trim().toLowerCase() == question.correctAnswer.trim().toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: submitted ? Border.all(color: isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFF44336), width: 2) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: const Color(0xFF2196F3).withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Center(child: Text('${index + 1}', style: const TextStyle(color: Color(0xFF2196F3), fontSize: 13, fontWeight: FontWeight.w800))),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(6)),
              child: Text(question.type.name, style: const TextStyle(color: Color(0xFFE65100), fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 10),
          Text(question.questionText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E), height: 1.4)),
          const SizedBox(height: 12),

          if (question.options.isNotEmpty)
            ...question.options.map((opt) {
              final isSelected = userAnswer == opt || userAnswer == opt.substring(0, 1);
              return GestureDetector(
                onTap: submitted ? null : () => ctrl.setListeningAnswer(question.id, opt.contains(')') ? opt.substring(0, 1) : opt),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2196F3).withValues(alpha: 0.1) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFE0E0E0), width: isSelected ? 2 : 1),
                  ),
                  child: Text(opt, style: TextStyle(fontSize: 13, color: isSelected ? const Color(0xFF1565C0) : const Color(0xFF333333), fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                ),
              );
            }),

          if (question.options.isEmpty)
            TextField(
              onChanged: (val) => ctrl.setListeningAnswer(question.id, val),
              enabled: !submitted,
              decoration: InputDecoration(
                hintText: 'type_answer'.tr,
                hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
                filled: true, fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),

          if (submitted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFF44336), size: 18),
                  const SizedBox(width: 6),
                  Text(isCorrect ? 'Correct!' : 'Incorrect \u2014 Answer: ${question.correctAnswer}',
                      style: TextStyle(color: isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828), fontSize: 13, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 8),
                Text(question.explanation, style: const TextStyle(fontSize: 12, color: Color(0xFF555555), height: 1.4)),
                if (question.tip != null) ...[
                  const SizedBox(height: 6),
                  Text('\u{1F4A1} ${'tip_prefix'.tr}: ${question.tip!}', style: const TextStyle(fontSize: 12, color: Color(0xFFF57F17), fontWeight: FontWeight.w600)),
                ],
              ]),
            ),
          ],
        ],
      ),
    );
  }
}
