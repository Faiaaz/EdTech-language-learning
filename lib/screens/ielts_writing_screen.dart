import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/ielts_controller.dart';

/// IELTS Writing practice with prompts, outlines, model answers, and criteria.
class IeltsWritingScreen extends StatelessWidget {
  const IeltsWritingScreen({super.key});

  static const _orange = Color(0xFFFF9800);
  static const _orangeDark = Color(0xFFE65100);

  @override
  Widget build(BuildContext context) {
    final ctrl = IeltsController.to;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [_orange, _orangeDark])),
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
                  const Text('Writing Practice', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('Practice Task 1 & Task 2 with model answers', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select a Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 14),
                    ...List.generate(ctrl.writingTasks.length, (i) {
                      final t = ctrl.writingTasks[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            ctrl.selectWritingTask(i);
                            Get.to(() => _WritingPractice(ctrl: ctrl), transition: Transition.rightToLeftWithFade, duration: const Duration(milliseconds: 300));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Row(children: [
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(color: _orange.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                                child: Center(child: Text('T${t.taskNumber}', style: const TextStyle(color: _orangeDark, fontSize: 16, fontWeight: FontWeight.w900))),
                              ),
                              const SizedBox(width: 14),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(t.description, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                                const SizedBox(height: 4),
                                Text('${t.wordLimit}+ words \u2022 ${t.timeLimitMinutes} min \u2022 ${t.difficulty.name}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                              ])),
                              const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B0B0)),
                            ]),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                    // Writing criteria info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFFCC80))),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.grading_rounded, color: Color(0xFFE65100), size: 20),
                            SizedBox(width: 8),
                            Text('Writing Assessment Criteria', style: TextStyle(color: Color(0xFFBF360C), fontSize: 14, fontWeight: FontWeight.w800)),
                          ]),
                          SizedBox(height: 10),
                          Text('\u2022 Task Response (25%) — Address all parts of the prompt\n\u2022 Coherence & Cohesion (25%) — Organize logically with linking words\n\u2022 Lexical Resource (25%) — Use varied, accurate vocabulary\n\u2022 Grammar Range & Accuracy (25%) — Mix sentence structures',
                              style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF4E342E))),
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

class _WritingPractice extends StatelessWidget {
  final IeltsController ctrl;
  const _WritingPractice({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              color: const Color(0xFFFF9800),
              child: Row(children: [
                GestureDetector(onTap: () => Get.back(), child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Text('Task ${ctrl.currentWritingTask.taskNumber}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text('${ctrl.writingWordCount.value} words', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                )),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Obx(() {
                  final task = ctrl.currentWritingTask;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Prompt
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFFCC80)),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFFF9800).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                              child: Text('Task ${task.taskNumber} \u2022 ${task.timeLimitMinutes} min \u2022 ${task.wordLimit}+ words',
                                  style: const TextStyle(color: Color(0xFFE65100), fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ]),
                          const SizedBox(height: 12),
                          Text(task.prompt, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E), height: 1.5)),
                        ]),
                      ),

                      const SizedBox(height: 16),

                      // Outline
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(14)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Row(children: [
                            Icon(Icons.format_list_numbered_rounded, color: Color(0xFFE65100), size: 18),
                            SizedBox(width: 8),
                            Text('Suggested Outline', style: TextStyle(color: Color(0xFFBF360C), fontSize: 14, fontWeight: FontWeight.w800)),
                          ]),
                          const SizedBox(height: 10),
                          ...task.sampleOutline.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('${e.key + 1}. ', style: const TextStyle(color: Color(0xFFE65100), fontSize: 13, fontWeight: FontWeight.w700)),
                              Expanded(child: Text(e.value, style: const TextStyle(color: Color(0xFF4E342E), fontSize: 13, height: 1.4))),
                            ]),
                          )),
                        ]),
                      ),

                      const SizedBox(height: 16),

                      // User writing area
                      const Text('Your Essay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
                        child: TextField(
                          onChanged: (val) => ctrl.updateEssay(val),
                          maxLines: 12,
                          decoration: InputDecoration(
                            hintText: 'Start writing your essay here...',
                            hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Word count indicator
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ctrl.writingWordCount.value >= task.wordLimit
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFCE4EC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(children: [
                          Icon(
                            ctrl.writingWordCount.value >= task.wordLimit ? Icons.check_circle_rounded : Icons.info_rounded,
                            color: ctrl.writingWordCount.value >= task.wordLimit ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${ctrl.writingWordCount.value} / ${task.wordLimit} words ${ctrl.writingWordCount.value >= task.wordLimit ? "(target reached!)" : "(keep writing)"}',
                            style: TextStyle(
                              color: ctrl.writingWordCount.value >= task.wordLimit ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                              fontSize: 13, fontWeight: FontWeight.w700,
                            ),
                          ),
                        ]),
                      ),

                      const SizedBox(height: 20),

                      // Model answer toggle
                      GestureDetector(
                        onTap: () => ctrl.toggleModelAnswer(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFE65100)]),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              ctrl.showModelAnswer.value ? 'Hide Model Answer' : 'Show Model Answer',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),

                      if (ctrl.showModelAnswer.value) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Row(children: [
                              Icon(Icons.star_rounded, color: Color(0xFF4CAF50), size: 20),
                              SizedBox(width: 8),
                              Text('Model Answer (Band 7-8)', style: TextStyle(color: Color(0xFF2E7D32), fontSize: 14, fontWeight: FontWeight.w800)),
                            ]),
                            const SizedBox(height: 12),
                            Text(task.modelAnswer, style: const TextStyle(fontSize: 14, height: 1.7, color: Color(0xFF333333))),
                            const SizedBox(height: 16),
                            const Text('Assessment Criteria:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                            const SizedBox(height: 8),
                            ...task.criteria.map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
                                  child: Text('${(c.weight * 100).round()}%', style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                                  Text(c.description, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                ])),
                              ]),
                            )),
                          ]),
                        ),
                      ],
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
