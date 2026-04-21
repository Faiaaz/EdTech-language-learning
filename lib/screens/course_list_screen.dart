import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/controllers/program_controller.dart';
import 'package:ez_trainz/models/course.dart';
import 'package:ez_trainz/screens/course_detail_screen.dart';
import 'package:ez_trainz/screens/lms_api_screen.dart';
import 'package:ez_trainz/screens/login_screen.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  // ── Level badge colours ──────────────────────────────────────────
  static const _levelColors = <String, Color>{
    'N5': Color(0xFF4CAF50),
    'N4': Color(0xFF2196F3),
    'N3': Color(0xFFFFC107),
    'N2': Color(0xFFFF9800),
    'N1': Color(0xFFF44336),
  };

  @override
  Widget build(BuildContext context) {
    final ctrl = CourseController.to;

    return Scaffold(
      backgroundColor: const Color(0xFF4DA6E8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP BAR ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          ProgramController.to.clearProgram();
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.apps_rounded,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text('programs'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('EZ',
                              style: TextStyle(
                                color: Color(0xFFFFE000),
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              )),
                          SizedBox(width: 3),
                          Text('TRAINZ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                height: 1,
                              )),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Get.to(() => const LmsApiScreen()),
                        icon: const Icon(Icons.cloud_rounded,
                            color: Colors.white),
                        tooltip: 'LMS API',
                      ),
                      GestureDetector(
                        onTap: () {
                          AuthController.to.logout();
                          Get.offAll(() => const LoginScreen());
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: Colors.white38, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.logout_rounded,
                                  color: Colors.white, size: 15),
                              const SizedBox(width: 5),
                              Text('logout'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── GREETING ─────────────────────────────────
                  Text(
                    'Hello, ${AuthController.to.firstName}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ProgramController.to.hasProgram
                        ? '${ProgramController.to.current!.name} (${ProgramController.to.current!.shortName}) · ${'choose_course'.tr}'
                        : 'choose_course'.tr,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ── COURSE LIST ────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (ctrl.error.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        ctrl.error.value,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: ctrl.courses.length,
                  itemBuilder: (_, i) =>
                      _CourseCard(course: ctrl.courses[i]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── COURSE CARD WIDGET ───────────────────────────────────────────────
class _CourseCard extends StatelessWidget {
  final Course course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final badgeColor = CourseListScreen._levelColors[course.level] ??
        const Color(0xFF4DA6E8);

    return GestureDetector(
      onTap: () {
        CourseController.to.selectCourse(course);
        Get.to(() => const CourseDetailScreen());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            // ── Level badge ────────────────────────────────
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  course.level,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // ── Title + description ────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.description,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'lessons_count'.trParams({'count': course.lessons.length.toString()}),
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFB0B0B0), size: 24),
          ],
        ),
      ),
    );
  }
}
