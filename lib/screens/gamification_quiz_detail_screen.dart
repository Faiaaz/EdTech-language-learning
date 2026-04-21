import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/gamification_content_controller.dart';
import 'package:ez_trainz/models/gamification_api_models.dart';

class GamificationQuizDetailScreen extends StatefulWidget {
  const GamificationQuizDetailScreen({super.key, required this.quiz});

  final GamQuizDetail quiz;

  @override
  State<GamificationQuizDetailScreen> createState() =>
      _GamificationQuizDetailScreenState();
}

class _GamificationQuizDetailScreenState extends State<GamificationQuizDetailScreen> {
  static const _bg = Color(0xFF4DA6E8);
  static const _accent = Color(0xFFFFE000);

  final _answerCtrls = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    for (final q in widget.quiz.questions) {
      if (q.id.isEmpty) continue;
      _answerCtrls[q.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _answerCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final answers = <Map<String, dynamic>>[];
    for (final q in widget.quiz.questions) {
      if (q.id.isEmpty) continue;
      final t = _answerCtrls[q.id]?.text.trim() ?? '';
      answers.add({'questionId': q.id, 'answer': t});
    }

    await GamificationContentController.to.submitQuiz(
      quizId: widget.quiz.id,
      answers: answers,
    );

    final err = GamificationContentController.to.error.value;
    final res = GamificationContentController.to.submitResult.value;

    if (!mounted) return;
    if (err.isNotEmpty) {
      Get.snackbar(
        'Submit failed',
        err,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (res == null) {
      Get.snackbar(
        'Submitted',
        'No structured result returned.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFF1A1A2E),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quiz result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (res.score != null) Text('Score: ${res.score}'),
            if (res.correct != null && res.total != null)
              Text('Correct: ${res.correct} / ${res.total}'),
            if (res.passed != null) Text('Passed: ${res.passed! ? 'Yes' : 'No'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final passing = widget.quiz.passingScore;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: Text(
          widget.quiz.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButton: Obx(() {
        final busy = GamificationContentController.to.isLoading.value;
        return FloatingActionButton.extended(
          onPressed: busy ? null : _submit,
          backgroundColor: _accent,
          foregroundColor: const Color(0xFF1A1A2E),
          icon: busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1A1A2E),
                  ),
                )
              : const Icon(Icons.send_rounded),
          label: Text(
            busy ? 'Submitting…' : 'Submit',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        );
      }),
      body: Obx(() {
        final busy = GamificationContentController.to.isLoading.value;
        return Column(
          children: [
            if (busy)
              const LinearProgressIndicator(
                minHeight: 2,
                color: _accent,
                backgroundColor: Colors.white24,
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  if (passing != null)
                    Text(
                      'Passing score: $passing',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (widget.quiz.questions.isEmpty)
                    Text(
                      'No questions in this quiz payload.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                    )
                  else
                    ...widget.quiz.questions.map((q) {
                      final ctrl = _answerCtrls[q.id];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q.prompt,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  height: 1.25,
                                ),
                              ),
                              if (q.options != null && q.options!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: q.options!
                                      .map(
                                        (o) => Chip(
                                          label: Text(o),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                              const SizedBox(height: 10),
                              TextField(
                                controller: ctrl,
                                enabled: !busy,
                                decoration: const InputDecoration(
                                  labelText: 'Your answer',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'questionId: ${q.id}',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
