import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/controllers/program_controller.dart';
import 'package:ez_trainz/models/course.dart';
import 'package:ez_trainz/models/kana.dart';
import 'package:ez_trainz/models/lesson.dart';
import 'package:ez_trainz/models/program.dart';
import 'package:ez_trainz/utils/app_theme.dart';
import 'package:ez_trainz/screens/hiragana_lesson1_screen.dart';
import 'package:ez_trainz/screens/n5_lesson_video_screens.dart';
import 'package:ez_trainz/screens/lesson_screen.dart';
import 'package:ez_trainz/screens/n5_kana_modules_screen.dart';
import 'package:ez_trainz/widgets/app_settings_menu.dart';
import 'package:ez_trainz/widgets/ez_trainz_logo_text.dart';

// ── Level badge colours (shared by the list + JlcLevelScreen) ────────
const Map<String, Color> _kLevelColors = {
  'N5': Color(0xFF4CAF50),
  'N4': Color(0xFF2196F3),
  'N3': Color(0xFFFFC107),
  'N2': Color(0xFFFF9800),
  'N1': Color(0xFFF44336),
};

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

  @override
  Widget build(BuildContext context) {
    final ctrl = CourseController.to;
    final isJlc = ProgramController.to.current == Program.jlc;
    const slateBg = Colors.transparent; // global sky→gold gradient shows through

    final chipBg = isJlc ? AppColors.card : const Color(0xFF1E293B);
    final chipBorder =
        isJlc ? AppColors.border : const Color(0xFF334155);
    final iconOnChip = isJlc ? AppColors.textPrimary : Colors.white;

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
                                              style: TextStyle(
                                                color: iconOnChip,
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
                                child: AppSettingsMenuButton(
                                  compact: true,
                                  iconColor: iconOnChip,
                                  backgroundColor: chipBg,
                                  borderColor: chipBorder,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    if (isJlc) ...[
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'হ্যালো, ',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                              ),
                            ),
                            const TextSpan(
                              text: 'হিরো !',
                              style: TextStyle(
                                color: AppColors.accentBlueDk,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                          ],
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
                            ? AppColors.textMuted
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
                      child: CircularProgressIndicator(
                          color: AppColors.accentBlue),
                    );
                  }

                  if (ctrl.error.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          ctrl.error.value,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 15),
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
                    itemBuilder: (_, i) {
                      final course = ctrl.courses[i];
                      return _ExpandableCourseCard(
                        course: course,
                        jlcLayout: isJlc,
                        isJlcProgram: isJlc,
                        isExpanded: _expandedCourseId == course.id,
                        onToggle: () => _toggleCourse(course.id),
                        levelColors: _kLevelColors,
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
    final screen = n5LessonVideoScreenForId(lesson.id);
    if (screen != null) {
      Get.to(
        () => screen,
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
          return 'পাঠ ১ঃ হিরো নাম্বার ১ 😎';
        case 2:
          return 'পাঠ ২ঃ জাপানিজে হাই-হ্যালো 👋';
        case 3:
          return 'পাঠ ৩ঃ শুক্র-শনি বাকিটা জানি';
        case 13:
          return 'পাঠ ৪ঃ আকাসাতানা';
        case 14:
          return 'পাঠ ৫ঃ বর্ণে বর্ণে বর্ণমালা';
        case 15:
          return 'পাঠ ৬ঃ জাপানের চন্দ্রবিন্দু';
        case 16:
          return 'পাঠ ৭ঃ কিছু কথা ছিল...';
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
          return 'জাপানি অভিবাদন ও দৈনন্দিন বাক্য শিখুন।';
        case 3:
          return 'সপ্তাহের দিন • ক্যালেন্ডার • অভ্যাস';
        case 13:
          return 'হিরাগানা ৫ সারি • কানা চর্চা • ম্যাচ';
        case 14:
          return 'ま-や-ら-わ সারি • নোটবুক আঁকা • ম্যাচ';
        case 15:
          return 'てんてん ゛ ও まる ゜ • がざだばぱ সারি';
        case 16:
          return 'わたし/あなた/あのひと • さん • は/です/か';
      }
    }
    return lesson.description;
  }

  /// Splits a trailing emoji (e.g. 😎 / 👋) off the title so it can render in
  /// its natural colour instead of being recoloured by the title gradient.
  /// Returns (text, emoji); emoji is '' when the title has none.
  (String, String) _splitTrailingEmoji(String s) {
    final runes = s.runes.toList();
    var i = 0;
    while (i < runes.length && runes[i] < 0x1F000) {
      i++;
    }
    if (i == runes.length) return (s, '');
    final text = String.fromCharCodes(runes.sublist(0, i)).trimRight();
    final emoji = String.fromCharCodes(runes.sublist(i));
    return (text, emoji);
  }

  @override
  Widget build(BuildContext context) {
    final (titleText, titleEmoji) = _splitTrailingEmoji(_title);
    // Vibrant brand gradient for the JLC lesson tiles — blue-dominant with a
    // golden-yellow accent only at the tail.
    const vibrantGradient = LinearGradient(
      colors: [Color(0xFF0284C7), Color(0xFF0EA5E9), Color(0xFFFFC107)],
      stops: [0.0, 0.7, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
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
                  gradient: jlcLayout ? vibrantGradient : null,
                  color: jlcLayout ? null : accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: jlcLayout
                      ? null
                      : Border.all(color: accentColor.withValues(alpha: 0.35)),
                  boxShadow: jlcLayout
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0EA5E9).withValues(alpha: 0.30),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: jlcLayout ? Colors.white : accentColor,
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
                    jlcLayout
                        ? Row(
                            children: [
                              Flexible(
                                child: ShaderMask(
                                  shaderCallback: (bounds) =>
                                      vibrantGradient.createShader(bounds),
                                  blendMode: BlendMode.srcIn,
                                  child: Text(
                                    titleText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              // Keep emoji outside shader so it stays natural color.
                              if (titleEmoji.isNotEmpty) ...[
                                const SizedBox(width: 5),
                                Text(
                                  titleEmoji,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ],
                          )
                        : Text(
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
              jlcLayout
                  ? ShaderMask(
                      shaderCallback: (bounds) =>
                          vibrantGradient.createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: const Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    )
                  : Icon(
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

// ── JLC level screen (Language → tap a level → its lessons) ──────────
/// Full-screen view of a single JLC level's lessons. Reuses the same
/// localized lesson tiles + N5 kana shortcut as the course list, so the
/// content matches the previous expandable card exactly. Reached from
/// JlcLanguageScreen.
class JlcLevelScreen extends StatelessWidget {
  const JlcLevelScreen({super.key, required this.course});

  final Course course;

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
    final badgeColor = _kLevelColors[course.level] ?? const Color(0xFF3B82F6);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: AppColors.border, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back_ios_rounded,
                                color: AppColors.textPrimary, size: 14),
                            const SizedBox(width: 4),
                            Text('back'.tr,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          course.level,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _displayTitle,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _displayDescription,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  if (course.level == 'N5') ...[
                    const _N5KanaSection(jlcLayout: true),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'lessons_label'.tr,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
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
                      jlcLayout: true,
                      onTap: () =>
                          _openLessonFromPath(course, course.lessons[i]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
