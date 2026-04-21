import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/lms_controller.dart';
import 'package:ez_trainz/models/lms_api_models.dart';

class LmsCourseDetailScreen extends StatelessWidget {
  const LmsCourseDetailScreen({super.key, required this.course});

  final LmsCourseSummary course;

  static const _bg = Color(0xFF4DA6E8);
  static const _accent = Color(0xFFFFE000);

  Future<void> _progressDialog(BuildContext context, {String? presetLessonId}) async {
    final lessonCtrl = TextEditingController(text: presetLessonId ?? '');
    final pctCtrl = TextEditingController(text: '100');
    var completed = true;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: const Text('Update lesson progress'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: lessonCtrl,
                    decoration: const InputDecoration(
                      labelText: 'lessonId',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: pctCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'progressPct (0–100)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('completed'),
                    value: completed,
                    onChanged: (v) => setLocal(() => completed = v),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text('profile_cancel'.tr)),
                ElevatedButton(
                  onPressed: () async {
                    final lid = lessonCtrl.text.trim();
                    if (lid.isEmpty) return;
                    final pct = double.tryParse(pctCtrl.text.trim()) ?? 0;
                    await LmsController.to.updateLessonProgress(
                      lessonId: lid,
                      completed: completed,
                      progressPct: pct,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      final err = LmsController.to.error.value;
                      Get.snackbar(
                        err.isEmpty ? 'Saved' : 'Error',
                        err.isEmpty ? 'Lesson progress updated.' : err,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: err.isEmpty ? Colors.white : Colors.redAccent,
                        colorText: err.isEmpty ? const Color(0xFF1A1A2E) : Colors.white,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: const Color(0xFF1A1A2E),
                  ),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    lessonCtrl.dispose();
    pctCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: Text(
          course.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (course.level != null && course.level!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F4FD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        course.level!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ),
                  if (course.description != null && course.description!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      course.description!,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        height: 1.35,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    '${course.lessons.length} lessons',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Lessons',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _progressDialog(context),
                  icon: const Icon(Icons.edit_calendar_rounded, color: _accent),
                  label: const Text(
                    'Progress',
                    style: TextStyle(color: _accent, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (course.lessons.isEmpty)
              Text(
                'No lessons in this payload.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
              )
            else
              ...course.lessons.map(
                (l) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    title: Text(
                      l.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      'id: ${l.id}',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _progressDialog(context, presetLessonId: l.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
