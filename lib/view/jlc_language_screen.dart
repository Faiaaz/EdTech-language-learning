import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/models/course.dart';
import 'package:ez_trainz/utils/app_theme.dart';
import 'package:ez_trainz/view/course_list_screen.dart' show JlcLevelScreen;
import 'package:ez_trainz/view/jlc_coming_soon_screen.dart';
import 'package:ez_trainz/view/jlc_practice_screen.dart';

/// JLC → Language inner screen.
///
/// One vertical [CustomScrollView] (single scroll context) holding, top to
/// bottom: a Japan video explainer, a horizontal N5/N4/N3 level strip, and
/// the Practice + Challenge action cards. The level strip scrolls on its own
/// horizontal axis. Stays on the global sky→gold gradient.
class JlcLanguageScreen extends StatelessWidget {
  const JlcLanguageScreen({super.key});

  // Level badge colours — match the JLC course list palette.
  static const _levelColors = <String, Color>{
    'N5': Color(0xFF4CAF50),
    'N4': Color(0xFF2196F3),
    'N3': Color(0xFFFFC107),
  };

  static const _levels = <_LevelMeta>[
    _LevelMeta(level: 'N5', name: 'শিক্ষানবিশ'),
    _LevelMeta(level: 'N4', name: 'প্রাথমিক'),
    _LevelMeta(level: 'N3', name: 'মধ্যবর্তী'),
  ];

  Course? _courseForLevel(String level) {
    for (final c in CourseController.to.courses) {
      if (c.level == level) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER (fixed) ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.textPrimary, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Language',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.accentBlue.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'JLC',
                      style: TextStyle(
                        color: AppColors.accentBlueDk,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── SCROLLABLE BODY (slivers) ───────────────────────
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Video explainer
                  const SliverToBoxAdapter(child: _SectionLabel('জাপান পরিচিতি')),
                  SliverToBoxAdapter(
                    child: _VideoExplainerCard(
                      onTap: () => Get.to(
                        () => const JlcComingSoonScreen(
                          title: 'জাপান পরিচিতি ভিডিও',
                          emoji: '🎬',
                          subtitle:
                              'জাপানের সংস্কৃতি, ভাষা ও জীবন নিয়ে ভিডিও এক্সপ্লেইনার শীঘ্রই যুক্ত হবে।',
                        ),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ),
                  ),
                  // Level selector
                  const SliverToBoxAdapter(
                      child: _SectionLabel('আপনার লেভেল বেছে নিন')),
                  SliverToBoxAdapter(
                    child: Obx(() {
                      // Touch the observable so the strip rebuilds when courses load.
                      final loaded = CourseController.to.courses.isNotEmpty;
                      return SizedBox(
                        height: 116,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                          itemCount: _levels.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            final meta = _levels[i];
                            final course =
                                loaded ? _courseForLevel(meta.level) : null;
                            return _LevelCard(
                              level: meta.level,
                              name: meta.name,
                              color: _levelColors[meta.level] ??
                                  AppColors.accentBlue,
                              lessonCount: course?.lessons.length ?? 0,
                              locked: course == null,
                              active: i == 0,
                              onTap: course == null
                                  ? () => Get.to(
                                        () => JlcComingSoonScreen(
                                          title: '${meta.level} • ${meta.name}',
                                          emoji: '🔒',
                                          subtitle:
                                              'এই লেভেলের পাঠ শীঘ্রই যুক্ত হবে।',
                                          accent: _levelColors[meta.level] ??
                                              AppColors.accentBlue,
                                        ),
                                        transition:
                                            Transition.rightToLeftWithFade,
                                        duration:
                                            const Duration(milliseconds: 300),
                                      )
                                  : () {
                                      CourseController.to.selectCourse(course);
                                      Get.to(
                                        () => JlcLevelScreen(course: course),
                                        transition:
                                            Transition.rightToLeftWithFade,
                                        duration:
                                            const Duration(milliseconds: 300),
                                      );
                                    },
                            );
                          },
                        ),
                      );
                    }),
                  ),
                  // Action cards
                  const SliverToBoxAdapter(
                      child: _SectionLabel('আপনি কী করতে চান?')),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ActionCard(
                              emoji: '📖',
                              label: 'প্র্যাকটিস',
                              sub: 'পাঠ ও অনুশীলন',
                              bg: const Color(0xFFE8F4FD),
                              border: const Color(0xFFB3D1F7),
                              labelColor: const Color(0xFF1565C0),
                              onTap: () => Get.to(
                                () => const JlcPracticeScreen(),
                                transition: Transition.rightToLeftWithFade,
                                duration: const Duration(milliseconds: 300),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ActionCard(
                              emoji: '⚡',
                              label: 'চ্যালেঞ্জ',
                              sub: 'নিজেকে যাচাই করুন',
                              bg: const Color(0xFFFCE8E8),
                              border: const Color(0xFFF7B3B3),
                              labelColor: const Color(0xFFC0392B),
                              onTap: () => Get.to(
                                () => const JlcComingSoonScreen(
                                  title: 'চ্যালেঞ্জ',
                                  emoji: '⚡',
                                  subtitle:
                                      'কুইজ ও টেস্ট দিয়ে নিজেকে যাচাই করার চ্যালেঞ্জ মোড শীঘ্রই আসছে।',
                                  accent: Color(0xFFC0392B),
                                ),
                                transition: Transition.rightToLeftWithFade,
                                duration: const Duration(milliseconds: 300),
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
      ),
    );
  }
}

class _LevelMeta {
  const _LevelMeta({required this.level, required this.name});
  final String level;
  final String name;
}

// ── Section label ────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ── Video explainer card ─────────────────────────────────────────────
// TODO: wire a real player (video_player is in pubspec) once the Japan
// explainer asset/URL is available; for now this is a tappable placeholder.
class _VideoExplainerCard extends StatelessWidget {
  const _VideoExplainerCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                height: 150,
                width: double.infinity,
                color: const Color(0xFF1A1A2E),
                child: Stack(
                  children: [
                    const Positioned(
                      top: 10,
                      left: 14,
                      child: Text(
                        '日本',
                        style: TextStyle(
                          color: Color(0x4DFFFFFF),
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.45),
                              width: 2),
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 26),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '4:32',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'জাপান পরিচিতি — সংস্কৃতি, ভাষা ও জীবন',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'পাঠ শুরুর আগে দেখে নিন • ৪ মিনিট',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Level strip card ─────────────────────────────────────────────────
class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.name,
    required this.color,
    required this.lessonCount,
    required this.locked,
    required this.active,
    required this.onTap,
  });

  final String level;
  final String name;
  final Color color;
  final int lessonCount;
  final bool locked;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tagColor = locked ? AppColors.textDim : color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 138,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.12) : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? color.withValues(alpha: 0.6) : AppColors.border,
            width: active ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  level,
                  style: TextStyle(
                    color: tagColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                if (locked)
                  const Icon(Icons.lock_rounded,
                      color: AppColors.textDim, size: 16),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              name,
              style: TextStyle(
                color: locked ? AppColors.textDim : AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              locked ? 'শীঘ্রই' : '$lessonCount টি পাঠ',
              style: TextStyle(
                color: locked ? AppColors.textDim : color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Practice / Challenge action card ─────────────────────────────────
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.emoji,
    required this.label,
    required this.sub,
    required this.bg,
    required this.border,
    required this.labelColor,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final String sub;
  final Color bg;
  final Color border;
  final Color labelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
