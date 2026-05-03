import 'dart:math' as math;

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
import 'package:ez_trainz/screens/n5_kana_modules_screen.dart';

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
                    itemCount: ctrl.courses.length,
                    itemBuilder: (_, i) {
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
                        _LessonPathView(
                          course: course,
                          accentColor: badgeColor,
                          showJapanMap: isJlcProgram,
                          lightBackdrop: false,
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

// ── S-curve path + lesson nodes (tap node → lesson / video) ───────────
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

class _LessonPathView extends StatelessWidget {
  const _LessonPathView({
    required this.course,
    required this.accentColor,
    this.showJapanMap = false,
    this.lightBackdrop = true,
  });

  final Course course;
  final Color accentColor;
  final bool showJapanMap;
  final bool lightBackdrop;

  static const _nodeSize = 52.0;
  static const _nodeRadius = 26.0;
  static const _vStep = 56.0;

  /// One full sine period along the trail → smooth “S” flow top to bottom.
  List<Offset> _computeCenters(double width, int n) {
    final cx = width * 0.5;
    final amp = (width * 0.30).clamp(48.0, width * 0.36);
    final centers = <Offset>[];
    if (n == 1) {
      centers.add(Offset(cx, _nodeRadius));
      return centers;
    }
    for (var i = 0; i < n; i++) {
      final t = i / (n - 1);
      final x = cx + amp * math.sin(2 * math.pi * t);
      final y = _nodeRadius + i * _vStep;
      centers.add(Offset(x, y));
    }
    return centers;
  }

  @override
  Widget build(BuildContext context) {
    final lessons = course.lessons;
    final n = lessons.length;
    if (n == 0) {
      return const SizedBox.shrink();
    }

    final pathStroke = Color.lerp(accentColor, const Color(0xFF0F172A), 0.22)!;
    final pathHighlight =
        Color.lerp(accentColor, Colors.white, 0.35)!.withValues(alpha: 0.95);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final centers = _computeCenters(w, n);
        final h = _nodeRadius + (n - 1) * _vStep + _nodeRadius + 16;

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                if (showJapanMap)
                  CustomPaint(
                    size: Size(w, h),
                    painter: _JapanMapBackdropPainter(
                      lightTheme: lightBackdrop,
                    ),
                  ),
                CustomPaint(
                  size: Size(w, h),
                  painter: _LessonTrailPainter(
                    centers: centers,
                    strokeColor: pathStroke,
                    highlightColor: pathHighlight,
                  ),
                ),
                for (var i = 0; i < n; i++)
                  Positioned(
                    left: centers[i].dx - _nodeRadius,
                    top: centers[i].dy - _nodeRadius,
                    width: _nodeSize,
                    height: _nodeSize,
                    child: _LessonPathNode(
                      index: i + 1,
                      accentColor: accentColor,
                      nodeSize: _nodeSize,
                      onTap: () =>
                          _openLessonFromPath(course, lessons[i]),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Soft ocean + stylized Japan archipelago (decorative, low contrast).
class _JapanMapBackdropPainter extends CustomPainter {
  _JapanMapBackdropPainter({required this.lightTheme});

  final bool lightTheme;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final ocean = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: lightTheme
            ? const [
                Color(0xFFE5F2FA),
                Color(0xFFD2E9F6),
                Color(0xFFC2E0F1),
              ]
            : const [
                Color(0xFF1E3A4C),
                Color(0xFF152A38),
                Color(0xFF0F1F2C),
              ],
      ).createShader(rect);
    canvas.drawRect(rect, ocean);

    final mist = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.15, -0.35),
        radius: 1.15,
        colors: [
          Colors.white.withValues(alpha: lightTheme ? 0.45 : 0.08),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, mist);

    final landFill = Paint()
      ..color = lightTheme
          ? const Color(0xFF6FA68D).withValues(alpha: 0.20)
          : const Color(0xFF5EB89A).withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    final landEdge = Paint()
      ..color = lightTheme
          ? const Color(0xFF4F8F72).withValues(alpha: 0.14)
          : const Color(0xFF7CB89F).withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final land = _stylizedJapanPath(size);
    canvas.drawPath(land, landFill);
    canvas.drawPath(land, landEdge);
  }

  /// Normalized island blobs → reads as Japan at a glance, not GIS-accurate.
  Path _stylizedJapanPath(Size size) {
    final w = size.width;
    final h = size.height;
    void oval(Path p, double cx, double cy, double rw, double rh) {
      p.addOval(
        Rect.fromCenter(
          center: Offset(cx * w, cy * h),
          width: rw * w,
          height: rh * h,
        ),
      );
    }

    final p = Path();
    oval(p, 0.62, 0.14, 0.16, 0.11);
    oval(p, 0.58, 0.38, 0.14, 0.42);
    oval(p, 0.52, 0.72, 0.12, 0.14);
    oval(p, 0.46, 0.84, 0.10, 0.09);
    oval(p, 0.38, 0.58, 0.08, 0.12);
    return p;
  }

  @override
  bool shouldRepaint(covariant _JapanMapBackdropPainter oldDelegate) {
    return oldDelegate.lightTheme != lightTheme;
  }
}

/// Catmull–Rom → cubic Beziers: smooth curve through every node (no kinks).
class _LessonTrailPainter extends CustomPainter {
  _LessonTrailPainter({
    required this.centers,
    required this.strokeColor,
    required this.highlightColor,
  });

  final List<Offset> centers;
  final Color strokeColor;
  final Color highlightColor;

  static Offset _pointAt(List<Offset> p, int i) {
    if (i < 0) {
      return p[0] - (p[1] - p[0]);
    }
    if (i >= p.length) {
      return p[p.length - 1] + (p[p.length - 1] - p[p.length - 2]);
    }
    return p[i];
  }

  static Path _catmullRomPath(List<Offset> p) {
    final path = Path();
    if (p.isEmpty) return path;
    path.moveTo(p[0].dx, p[0].dy);
    if (p.length == 1) return path;

    for (var i = 0; i < p.length - 1; i++) {
      final p0 = p[i];
      final p1 = p[i + 1];
      final prev = _pointAt(p, i - 1);
      final next = _pointAt(p, i + 2);
      final c1 = p0 + (p1 - prev) / 6;
      final c2 = p1 - (next - p0) / 6;
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p1.dx, p1.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.length < 2) return;

    final path = _catmullRomPath(centers);

    final outer = Paint()
      ..color = strokeColor.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    canvas.drawPath(path, outer);

    final inner = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    canvas.drawPath(path, inner);
  }

  @override
  bool shouldRepaint(covariant _LessonTrailPainter oldDelegate) {
    return oldDelegate.centers != centers ||
        oldDelegate.strokeColor != strokeColor;
  }
}

class _LessonPathNode extends StatelessWidget {
  const _LessonPathNode({
    required this.index,
    required this.accentColor,
    required this.nodeSize,
    required this.onTap,
  });

  final int index;
  final Color accentColor;
  final double nodeSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor,
                Color.lerp(accentColor, const Color(0xFF0F172A), 0.25)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.45),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: SizedBox(
            width: nodeSize,
            height: nodeSize,
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
