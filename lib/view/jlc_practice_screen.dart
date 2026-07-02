import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/utils/app_theme.dart';
import 'package:ez_trainz/view/n5_hero_number1_lesson_screen.dart';
import 'package:ez_trainz/view/n5_hi_hello_lesson_screen.dart';
import 'package:ez_trainz/view/n5_weekdays_lesson_screen.dart';
import 'package:ez_trainz/view/n5_akasatana_lesson_screen.dart';
import 'package:ez_trainz/view/n5_kichu_kotha_lesson_screen_v2.dart';
import 'package:ez_trainz/view/pronunciation_coach_screen.dart';

/// প্র্যাকটিস — the 7 N5 practice lessons + the AI pronunciation coach.
///
/// Moved here from the JLC course list (_AnushilanCard); now reached from
/// JLC → Language → Practice. Sits on the global sky→gold gradient.
class JlcPracticeScreen extends StatelessWidget {
  const JlcPracticeScreen({super.key});

  static const _badgeColor = Color(0xFFFF8C00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
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
                            Text(
                              'back'.tr,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: _badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Text('✏️', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'প্র্যাকটিস',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'অনুশীলন করুন ও দক্ষতা বাড়ান',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── LESSON LIST ─────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(
                      'পাঠসমূহ',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  _PracticeLessonCard(
                    number: '১',
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
                    number: '২',
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
                    number: '৩',
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
                    number: '৪',
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
                  const SizedBox(height: 10),
                  _PracticeLessonCard(
                    number: '৫',
                    title: 'পাঠ ৫ঃ বর্ণে বর্ণে বর্ণমালা',
                    subtitle: 'ま-や-ら-わ সারি • নোটবুক আঁকা • ম্যাচ',
                    gradient: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    glow: const Color(0xFF3B82F6),
                    onTap: () => Get.to(
                      () => const N5BorneBorneBornomalaLessonScreen(),
                      transition: Transition.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _PracticeLessonCard(
                    number: '৬',
                    title: 'পাঠ ৬ঃ জাপানের চন্দ্রবিন্দু',
                    subtitle: 'てんてん ゛ ও まる ゜ • がざだばぱ সারি',
                    gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)],
                    glow: const Color(0xFFEF4444),
                    onTap: () => Get.to(
                      () => const N5DakutenLessonScreen(),
                      transition: Transition.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _PracticeLessonCard(
                    number: '৭',
                    title: 'পাঠ ৭ঃ কিছু কথা ছিল...',
                    subtitle: 'わたし/あなた/あのひと • さん • は/です/か',
                    gradient: const [Color(0xFF14B8A6), Color(0xFF0F766E)],
                    glow: const Color(0xFF14B8A6),
                    onTap: () => Get.to(
                      () => const N5KichuKothaLessonScreenV2(),
                      transition: Transition.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _PracticeLessonCard(
                    number: 'AI',
                    title: 'উচ্চারণ কোচ ✨',
                    subtitle: 'শুনুন • বলুন • AI আপনার উচ্চারণ স্কোর করবে',
                    gradient: const [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                    glow: const Color(0xFFEC4899),
                    onTap: () => Get.to(
                      () => const PronunciationCoachScreen(),
                      transition: Transition.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 300),
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

// ── Reusable lesson card used inside প্র্যাকটিস ──────────────────────
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
