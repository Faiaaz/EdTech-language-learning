import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/program_controller.dart';
import 'package:ez_trainz/utils/app_theme.dart';
import 'package:ez_trainz/screens/jlc_coming_soon_screen.dart';
import 'package:ez_trainz/screens/jlc_language_screen.dart';
import 'package:ez_trainz/widgets/app_settings_menu.dart';
import 'package:ez_trainz/widgets/ez_trainz_logo_text.dart';

/// JLC home — four learning paths: Language, Culture, Career, Wisdom.
///
/// Replaces the old course-list landing for JLC. Language opens the inner
/// [JlcLanguageScreen]; the other three open a coming-soon placeholder.
/// Sits on the global sky→gold gradient (transparent scaffold).
class JlcHomeScreen extends StatelessWidget {
  const JlcHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER (Programs · logo · settings) ─────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final logoSideInset = (w * 0.19).clamp(48.0, 92.0);
                      return SizedBox(
                        height: 46,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: w * 0.34),
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
                                          horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.card,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                            color: AppColors.border, width: 1),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.apps_rounded,
                                              color: AppColors.textPrimary,
                                              size: 16),
                                          const SizedBox(width: 5),
                                          Text(
                                            'programs'.tr,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
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
                                  horizontal: logoSideInset),
                              child: const Center(
                                child: EzTrainzLogoText(height: 28),
                              ),
                            ),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: AppSettingsMenuButton(
                                compact: true,
                                iconColor: AppColors.textPrimary,
                                backgroundColor: AppColors.card,
                                borderColor: AppColors.border,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'হ্যালো, ',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                        TextSpan(
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
                  const SizedBox(height: 6),
                  const Text(
                    'Japanese Language Course (JLC)',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            ),
            // ── 4-CARD GRID ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(4, 0, 4, 10),
                      child: Text(
                        'একটি পথ বেছে নিন · CHOOSE A PATH',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.18,
                      children: [
                        _PathCard(
                          emoji: '🇯🇵',
                          label: 'Language',
                          sub: 'JLPT N5 → N3',
                          bg: const Color(0xFFE8F4FD),
                          labelColor: const Color(0xFF1565C0),
                          onTap: () => Get.to(
                            () => const JlcLanguageScreen(),
                            transition: Transition.rightToLeftWithFade,
                            duration: const Duration(milliseconds: 300),
                          ),
                        ),
                        _PathCard(
                          emoji: '⛩️',
                          label: 'Culture',
                          sub: 'রীতি ও সমাজ',
                          bg: const Color(0xFFFCE4EC),
                          labelColor: const Color(0xFF880E4F),
                          onTap: () => Get.to(
                            () => const JlcComingSoonScreen(
                              title: 'Culture · সংস্কৃতি',
                              emoji: '⛩️',
                              subtitle:
                                  'জাপানের রীতিনীতি ও সমাজ নিয়ে কনটেন্ট শীঘ্রই আসছে।',
                              accent: Color(0xFF880E4F),
                            ),
                            transition: Transition.rightToLeftWithFade,
                            duration: const Duration(milliseconds: 300),
                          ),
                        ),
                        _PathCard(
                          emoji: '💼',
                          label: 'Career',
                          sub: 'জাপানে চাকরি',
                          bg: const Color(0xFFE8F5E9),
                          labelColor: const Color(0xFF1B5E20),
                          onTap: () => Get.to(
                            () => const JlcComingSoonScreen(
                              title: 'Career · ক্যারিয়ার',
                              emoji: '💼',
                              subtitle:
                                  'জাপানে চাকরি ও ক্যারিয়ার গাইড শীঘ্রই আসছে।',
                              accent: Color(0xFF1B5E20),
                            ),
                            transition: Transition.rightToLeftWithFade,
                            duration: const Duration(milliseconds: 300),
                          ),
                        ),
                        _PathCard(
                          emoji: '🌸',
                          label: 'Wisdom',
                          sub: 'প্রবাদ ও মনন',
                          bg: const Color(0xFFFFF8E1),
                          labelColor: const Color(0xFFE65100),
                          onTap: () => Get.to(
                            () => const JlcComingSoonScreen(
                              title: 'Wisdom · প্রজ্ঞা',
                              emoji: '🌸',
                              subtitle:
                                  'জাপানি প্রবাদ ও মননশীলতা নিয়ে কনটেন্ট শীঘ্রই আসছে।',
                              accent: Color(0xFFE65100),
                            ),
                            transition: Transition.rightToLeftWithFade,
                            duration: const Duration(milliseconds: 300),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Path card (Language / Culture / Career / Wisdom) ─────────────────
class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.emoji,
    required this.label,
    required this.sub,
    required this.bg,
    required this.labelColor,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final String sub;
  final Color bg;
  final Color labelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sub,
                  style: TextStyle(
                    color: labelColor.withValues(alpha: 0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
