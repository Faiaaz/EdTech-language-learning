import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/controllers/program_controller.dart';
import 'package:ez_trainz/models/course.dart';
import 'package:ez_trainz/models/kana.dart';
import 'package:ez_trainz/models/lesson.dart';
import 'package:ez_trainz/models/program.dart';
import 'package:ez_trainz/screens/hiragana_lesson1_screen.dart';
import 'package:ez_trainz/screens/lesson_screen.dart';
import 'package:ez_trainz/screens/login_screen.dart';
import 'package:ez_trainz/screens/n5_hero_number1_lesson_screen.dart';
import 'package:ez_trainz/screens/n5_hi_hello_lesson_screen.dart';
import 'package:ez_trainz/screens/n5_kana_modules_screen.dart';
import 'package:ez_trainz/screens/n5_akasatana_lesson_screen.dart';
import 'package:ez_trainz/screens/n5_weekdays_lesson_screen.dart';
import 'package:ez_trainz/widgets/ez_trainz_logo_text.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  int? _expandedCourseId;

  void _toggleCourse(int courseId) {
    setState(() {
      _expandedCourseId = _expandedCourseId == courseId ? null : courseId;
    });
  }

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
    const slateBg = Color(0xFF0F172A);

    final chipBg = isJlc
        ? Colors.white.withValues(alpha: 0.22)
        : const Color(0xFF1E293B);
    final chipBorder =
        isJlc ? Colors.white.withValues(alpha: 0.35) : const Color(0xFF334155);
    final iconOnChip = isJlc ? Colors.white : const Color(0xFF1E293B);

    return Material(
      color: slateBg,
      child: SafeArea(
        bottom: false,
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                                        Get.back();
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
                                child: const Center(
                                  child: EzTrainzLogoText(height: 28),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
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
                    itemCount: ctrl.courses.length + (isJlc ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (isJlc && i == ctrl.courses.length) {
                        return const _AnushilanCard();
                      }
                      final course = ctrl.courses[i];
                      return _ExpandableCourseCard(
                        course: course,
                        jlcLayout: isJlc,
                        isJlcProgram: isJlc,
                        isExpanded: _expandedCourseId == course.id,
                        onToggle: () => _toggleCourse(course.id),
                        levelColors: _levelColors,
                      );
                    },
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

// ── EXPANDABLE COURSE CARD ───────────────────────────────────────────
class _ExpandableCourseCard extends StatelessWidget {
  final Course course;
  final bool jlcLayout;
  final bool isJlcProgram;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Map<String, Color> levelColors;

  const _ExpandableCourseCard({
    required this.course,
    required this.jlcLayout,
    required this.isJlcProgram,
    required this.isExpanded,
    required this.onToggle,
    required this.levelColors,
  });

  bool get _isBn => (Get.locale?.languageCode ?? '').toLowerCase() == 'bn';

  String get _displayTitle {
    if (_isBn) {
      switch (course.level) {
        case 'N5':
          return 'N5 শিক্ষানবিশ';
        case 'N4':
          return 'N4 প্রাথমিক';
      }
    }
    return course.title;
  }

  String get _displayDescription {
    if (_isBn) {
      switch (course.level) {
        case 'N5':
          return 'একদম নতুনদের জন্য জাপানি ভাষার পরিচিতি কোর্স';
        case 'N4':
          return 'সহজ ব্যাকরণ ও কাঞ্জি দিয়ে শেখা চালিয়ে যান';
      }
    }
    return course.description;
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor =
        levelColors[course.level] ?? const Color(0xFF3B82F6);

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

    final innerBg =
        jlcLayout ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final innerBorder = jlcLayout
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF334155);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: badgeColor
                            .withValues(alpha: jlcLayout ? 0.18 : 0.15),
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
                          Text(_displayTitle, style: titleStyle),
                          const SizedBox(height: 4),
                          Text(
                            _displayDescription,
                            style: descStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'lessons_count'.trParams({
                              'count': course.lessons.length.toString(),
                            }),
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: jlcLayout
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: innerBg,
                      border: Border(
                        top: BorderSide(color: innerBorder),
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(15),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isJlcProgram && course.level == 'N5') ...[
                          _N5KanaSection(jlcLayout: jlcLayout),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          'lessons_label'.tr,
                          style: TextStyle(
                            color: jlcLayout
                                ? const Color(0xFF64748B)
                                : Colors.white.withValues(alpha: 0.55),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (var i = 0; i < course.lessons.length; i++) ...[
                          if (i != 0) const SizedBox(height: 10),
                          _LessonListTile(
                            index: i + 1,
                            lesson: course.lessons[i],
                            courseLevel: course.level,
                            accentColor: badgeColor,
                            jlcLayout: jlcLayout,
                            onTap: () =>
                                _openLessonFromPath(course, course.lessons[i]),
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// ── N5 writing-system shortcut (JLC, same target as course detail) ────
class _N5KanaSection extends StatelessWidget {
  const _N5KanaSection({required this.jlcLayout});

  final bool jlcLayout;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: jlcLayout
          ? const Color(0xFF64748B)
          : Colors.white.withValues(alpha: 0.55),
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('writing_systems'.tr, style: labelStyle),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Get.to(
            () => const N5KanaModulesScreen(),
            transition: Transition.rightToLeftWithFade,
            duration: const Duration(milliseconds: 300),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(KanaData.sakuraPink),
                  Color(KanaData.sakuraPinkDark),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(KanaData.sakuraPink)
                      .withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'あア',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'hiragana_katakana'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'kana_module_desc'.tr,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 11,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF1E293B),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Lesson routing (tap → lesson / video) ────────────────────────────
void _openLessonFromPath(Course course, Lesson lesson) {
  CourseController.to.selectCourse(course);
  CourseController.to.selectLesson(lesson);
  if (lesson.id == 1) {
    Get.to(
      () => const HiraganaLesson1Screen(),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 300),
    );
  } else {
    Get.to(
      () => const LessonScreen(),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 300),
    );
  }
}

class _LessonListTile extends StatelessWidget {
  const _LessonListTile({
    required this.index,
    required this.lesson,
    required this.courseLevel,
    required this.accentColor,
    required this.jlcLayout,
    required this.onTap,
  });

  final int index;
  final Lesson lesson;
  final String courseLevel;
  final Color accentColor;
  final bool jlcLayout;
  final VoidCallback onTap;

  bool get _isBn => (Get.locale?.languageCode ?? '').toLowerCase() == 'bn';

  String get _title {
    if (_isBn && courseLevel == 'N5') {
      switch (lesson.id) {
        case 1:
          return 'পাঠ ১: হিরাগানা (প্রথম ভাগ)';
        case 2:
          return 'পাঠ ২: সংখ্যা';
        case 3:
          return 'পাঠ ৩: মৌলিক ব্যাকরণ';
        case 13:
          return 'পাঠ ৪: হিরাগানা (দ্বিতীয় ভাগ)';
        case 14:
          return 'পাঠ ৫: হিরাগানা (তৃতীয় ভাগ)';
      }
    }
    return lesson.title;
  }

  String get _description {
    if (_isBn && courseLevel == 'N5') {
      switch (lesson.id) {
        case 1:
          return 'হিরাগানা পরিচয় — জাপানি ভাষার এই মৌলিক ও কণ্ঠস্থ অক্ষরলিপি।';
        case 2:
          return 'জাপানিতে ১ থেকে ১০ পর্যন্ত গোনা শিখুন।';
        case 3:
          return 'জাপানি বাক্যের মৌলিক গঠন শিখুন।';
        case 13:
          return 'হিরাগানা শেখা চালিয়ে যান — স, ত, ন ও হ সারি।';
        case 14:
          return 'হিরাগানা সম্পূর্ণ করুন — ম, য, র, ও সারি এবং “ん” অক্ষর।';
      }
    }
    return lesson.description;
  }

  @override
  Widget build(BuildContext context) {
    final titleColor =
        jlcLayout ? const Color(0xFF0F172A) : Colors.white.withValues(alpha: 0.9);
    final subColor = jlcLayout
        ? const Color(0xFF334155)
        : Colors.white.withValues(alpha: 0.55);
    final tileBg = jlcLayout ? Colors.white : const Color(0xFF0B1220);
    final tileBorder = jlcLayout
        ? const Color(0xFFE2E8F0)
        : Colors.white.withValues(alpha: 0.10);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: tileBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tileBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor.withValues(alpha: 0.35)),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: subColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.play_circle_fill_rounded,
                color: accentColor.withValues(alpha: 0.9),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── অনুশীলন card (JLC-only static card with lessons) ───────────────
class _AnushilanCard extends StatefulWidget {
  const _AnushilanCard();

  @override
  State<_AnushilanCard> createState() => _AnushilanCardState();
}

class _AnushilanCardState extends State<_AnushilanCard> {
  bool _expanded = false;

  static const _badgeColor = Color(0xFFFF8C00);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(15),
                bottom: _expanded ? Radius.zero : const Radius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          '✏️',
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'অনুশীলন',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'অনুশীলন করুন ও দক্ষতা বাড়ান',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '৩টি পাঠ',
                            style: TextStyle(
                              color: _badgeColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: const Icon(
                        Icons.expand_more_rounded,
                        color: Color(0xFF64748B),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      border: Border(
                        top: BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(15),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'পাঠসমূহ',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _PracticeLessonCard(
                          number: '１',
                          title: 'পাঠ ১ঃ হিরো নাম্বার ১',
                          subtitle: 'জাপানি সংখ্যা • হিরাগানা • গেম',
                          gradient: const [Color(0xFFFF8C00), Color(0xFFFF5722)],
                          glow: const Color(0xFFFF8C00),
                          onTap: () => Get.to(
                            () => const N5HeroNumber1LessonScreen(),
                            transition: Transition.rightToLeftWithFade,
                            duration: const Duration(milliseconds: 300),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _PracticeLessonCard(
                          number: '２',
                          title: 'পাঠ ২ঃ জাপানিজে হাই-হ্যালো',
                          subtitle: 'অভিবাদন • শুভেচ্ছা • কথোপকথন',
                          gradient: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
                          glow: const Color(0xFF06B6D4),
                          onTap: () => Get.to(
                            () => const N5HiHelloLessonScreen(),
                            transition: Transition.rightToLeftWithFade,
                            duration: const Duration(milliseconds: 300),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _PracticeLessonCard(
                          number: '３',
                          title: 'পাঠ ৩ঃ শুক্র-শনি বাকিটা জানি',
                          subtitle: 'সপ্তাহের দিন • ক্যালেন্ডার • অভ্যাস',
                          gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                          glow: const Color(0xFF8B5CF6),
                          onTap: () => Get.to(
                            () => const N5WeekdaysLessonScreen(),
                            transition: Transition.rightToLeftWithFade,
                            duration: const Duration(milliseconds: 300),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _PracticeLessonCard(
                          number: '４',
                          title: 'পাঠ ৪ঃ আকাসাতানা',
                          subtitle: 'হিরাগানা ৫ সারি • কানা চর্চা • ম্যাচ',
                          gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                          glow: const Color(0xFF10B981),
                          onTap: () => Get.to(
                            () => const N5AkasatanaLessonScreen(),
                            transition: Transition.rightToLeftWithFade,
                            duration: const Duration(milliseconds: 300),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// ── Reusable lesson card used inside অনুশীলন ─────────────────────────
class _PracticeLessonCard extends StatelessWidget {
  const _PracticeLessonCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.glow,
    required this.onTap,
  });

  final String number;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final Color glow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: glow.withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
