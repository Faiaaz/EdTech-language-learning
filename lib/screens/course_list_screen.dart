import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/controllers/program_controller.dart';
import 'package:ez_trainz/models/course.dart';
import 'package:ez_trainz/models/program.dart';
import 'package:ez_trainz/screens/course_detail_screen.dart';
import 'package:ez_trainz/screens/lms_api_screen.dart';
import 'package:ez_trainz/screens/login_screen.dart';
import 'package:ez_trainz/widgets/streak_pill.dart';

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
    final isJlc = ProgramController.to.current == Program.jlc;
    const jlcBlue = Color(0xFF4DA6E8);
    const slateBg = Color(0xFF0F172A);

    final chipBg = isJlc
        ? Colors.white.withValues(alpha: 0.22)
        : const Color(0xFF1E293B);
    final chipBorder =
        isJlc ? Colors.white.withValues(alpha: 0.35) : const Color(0xFF334155);
    final iconOnChip =
        isJlc ? Colors.white : const Color(0xFF1E293B);

    // Single Scaffold lives on MainShellScreen; nested Scaffolds break IndexedStack layout.
    return Material(
      color: isJlc ? jlcBlue : slateBg,
      child: SafeArea(
        bottom: false,
        child: SizedBox.expand(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP BAR (stacked: no horizontal overlap) ─────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final logoSideInset =
                          (w * 0.19).clamp(48.0, 92.0);
                      return SizedBox(
                        height: 46,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: w * 0.34,
                                ),
                                child: FittedBox(
                                  alignment: Alignment.centerLeft,
                                  fit: BoxFit.scaleDown,
                                  child: GestureDetector(
                                    onTap: () {
                                      ProgramController.to.clearProgram();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: chipBg,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                          color: chipBorder,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.apps_rounded,
                                            color: iconOnChip,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'programs'.tr,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: logoSideInset,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      'EZ',
                                      style: TextStyle(
                                        color: Color(0xFFFFE000),
                                        fontSize: 21,
                                        fontWeight: FontWeight.w900,
                                        height: 1,
                                      ),
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'TRAINZ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.4,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const StreakPill(),
                                  IconButton(
                                    onPressed: () =>
                                        Get.to(() => const LmsApiScreen()),
                                    icon: const Icon(
                                      Icons.cloud_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    tooltip: 'LMS API',
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 40,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      AuthController.to.logout();
                                      Get.offAll(() => const LoginScreen());
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: chipBg,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                          color: chipBorder,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.logout_rounded,
                                            color: iconOnChip,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 3),
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: w * 0.22,
                                            ),
                                            child: Text(
                                              'logout'.tr,
                                              maxLines: 1,
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),

                  // ── GREETING ─────────────────────────────────
                  if (isJlc) ...[
                    Text(
                      'hello'.tr,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      '${AuthController.to.firstName}!',
                      style: const TextStyle(
                        color: Color(0xFFFFE000),
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Hello, ${AuthController.to.firstName}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    ProgramController.to.hasProgram
                        ? '${ProgramController.to.current!.name} (${ProgramController.to.current!.shortName}) · ${'choose_course'.tr}'
                        : 'choose_course'.tr,
                    style: TextStyle(
                      color: isJlc
                          ? Colors.white.withValues(alpha: 0.92)
                          : const Color(0xFF94A3B8),
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
                  padding: EdgeInsets.fromLTRB(
                    24,
                    0,
                    24,
                    isJlc ? 20 : 16,
                  ),
                  itemCount: ctrl.courses.length,
                  itemBuilder: (_, i) => _CourseCard(
                    course: ctrl.courses[i],
                    jlcLayout: isJlc,
                  ),
                );
              }),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// ── COURSE CARD WIDGET ───────────────────────────────────────────────
class _CourseCard extends StatelessWidget {
  final Course course;
  final bool jlcLayout;

  const _CourseCard({
    required this.course,
    this.jlcLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = CourseListScreen._levelColors[course.level] ??
        const Color(0xFF3B82F6);

    final titleStyle = TextStyle(
      color: jlcLayout ? const Color(0xFF0F172A) : Colors.white,
      fontSize: 17,
      fontWeight: FontWeight.w700,
    );
    final descStyle = TextStyle(
      color: jlcLayout ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
      fontSize: 13,
      fontWeight: FontWeight.w400,
    );
    return GestureDetector(
      onTap: () {
        CourseController.to.selectCourse(course);
        Get.to(() => const CourseDetailScreen());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: jlcLayout ? Colors.white : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: jlcLayout
                ? const Color(0xFFE2E8F0)
                : const Color(0xFF334155),
          ),
          boxShadow: [
            BoxShadow(
              color: jlcLayout
                  ? const Color(0xFF0F172A).withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: jlcLayout ? 16 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: jlcLayout ? 0.18 : 0.15),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: titleStyle),
                  const SizedBox(height: 4),
                  Text(
                    course.description,
                    style: descStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'lessons_count'.trParams(
                        {'count': course.lessons.length.toString()}),
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
                color: Color(0xFF94A3B8), size: 24),
          ],
        ),
      ),
    );
  }
}
