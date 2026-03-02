import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/models/lesson.dart';
import 'package:ez_trainz/screens/lesson_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = CourseController.to;
    final course = ctrl.selectedCourse!;

    return Scaffold(
      backgroundColor: const Color(0xFF4DA6E8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Get.back(),
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
                  const SizedBox(height: 24),

                  // ── Course level pill ────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE000),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      course.level,
                      style: const TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Course title ─────────────────────────────
                  Text(
                    course.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Section label ────────────────────────────
                  Text(
                    'Lessons',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // ── LESSONS LIST ───────────────────────────────────
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (ctrl.lessons.isEmpty) {
                  return Center(
                    child: Text(
                      'No lessons available yet.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 15,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: ctrl.lessons.length,
                  itemBuilder: (_, i) => _LessonTile(
                    lesson: ctrl.lessons[i],
                    index: i + 1,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── LESSON TILE WIDGET ───────────────────────────────────────────────
class _LessonTile extends StatelessWidget {
  final Lesson lesson;
  final int index;

  const _LessonTile({required this.lesson, required this.index});

  @override
  Widget build(BuildContext context) {
    final hasVideo = CourseController.to.getVideoUrl(lesson.id) != null;
    final hasQuizzes = lesson.quizzes.isNotEmpty;

    return GestureDetector(
      onTap: () {
        CourseController.to.selectLesson(lesson);
        Get.to(() => const LessonScreen());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Lesson number circle ───────────────────────
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF4DA6E8).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: Color(0xFF4DA6E8),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ── Title + description ────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lesson.description,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasVideo || hasQuizzes) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (hasVideo) ...[
                          const Icon(Icons.play_circle_outline_rounded,
                              color: Color(0xFF4DA6E8), size: 16),
                          const SizedBox(width: 4),
                          const Text('Video',
                              style: TextStyle(
                                color: Color(0xFF4DA6E8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                        if (hasVideo && hasQuizzes)
                          const SizedBox(width: 12),
                        if (hasQuizzes) ...[
                          const Icon(Icons.quiz_outlined,
                              color: Color(0xFFFFA726), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${lesson.quizzes.length} quiz${lesson.quizzes.length > 1 ? 'zes' : ''}',
                            style: const TextStyle(
                              color: Color(0xFFFFA726),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFB0B0B0), size: 22),
          ],
        ),
      ),
    );
  }
}
