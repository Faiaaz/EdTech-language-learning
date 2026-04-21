import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/controllers/ielts_controller.dart';
import 'package:ez_trainz/controllers/program_controller.dart';
import 'package:ez_trainz/screens/ielts_reading_screen.dart';
import 'package:ez_trainz/screens/ielts_listening_screen.dart';
import 'package:ez_trainz/screens/ielts_writing_screen.dart';
import 'package:ez_trainz/screens/ielts_speaking_screen.dart';
import 'package:ez_trainz/screens/ielts_vocabulary_screen.dart';
import 'package:ez_trainz/screens/ielts_mini_games_screen.dart';
import 'package:ez_trainz/screens/ielts_band_calculator_screen.dart';
import 'package:ez_trainz/screens/login_screen.dart';

/// Main IELTS hub — entry point for the English Language and Career module.
/// Shows the 4 IELTS sections + vocabulary builder + games + band calculator.
class IeltsDashboardScreen extends StatelessWidget {
  const IeltsDashboardScreen({super.key});

  // ELC gradient: pink → red
  static const _pink = Color(0xFFF093FB);
  static const _red = Color(0xFFF5576C);
  static const _bgLight = Color(0xFFFFF0F5);

  @override
  Widget build(BuildContext context) {
    final ctrl = IeltsController.to;

    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_pink, _red],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => ProgramController.to.clearProgram(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white38),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.apps_rounded, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text('programs'.tr, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          AuthController.to.logout();
                          Get.offAll(() => const LoginScreen());
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white38),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.logout_rounded, color: Colors.white, size: 15),
                              const SizedBox(width: 5),
                              Text('logout'.tr, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Hello, ${AuthController.to.firstName}!',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'IELTS Preparation',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, height: 1.1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Research-based strategies for top scores',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
                  ),
                ],
              ),
            ),

            // ── PROGRESS BAR ──────────────────────────────────
            Obx(() {
              final total = ctrl.totalReadingDone.value +
                  ctrl.totalListeningDone.value +
                  ctrl.totalWritingDone.value +
                  ctrl.totalSpeakingDone.value;
              return Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: _pink.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_pink, _red]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('practice_sessions'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 4),
                          Text('sessions_completed'.trParams({'total': '$total'}), style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _pink.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$total',
                        style: const TextStyle(color: _red, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // ── MODULE GRID ───────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ielts_sections_label'.tr,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 14),

                    // 4 IELTS sections
                    Row(
                      children: [
                        Expanded(
                          child: _SectionCard(
                            icon: Icons.menu_book_rounded,
                            title: 'ielts_reading'.tr,
                            subtitle: 'reading_desc'.trParams({'count': '${ctrl.passages.length}'}),
                            color: const Color(0xFF4CAF50),
                            onTap: () => Get.to(
                              () => const IeltsReadingScreen(),
                              transition: Transition.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 300),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SectionCard(
                            icon: Icons.headphones_rounded,
                            title: 'ielts_listening'.tr,
                            subtitle: 'listening_desc'.trParams({'count': '${ctrl.listeningSections.length}'}),
                            color: const Color(0xFF2196F3),
                            onTap: () => Get.to(
                              () => const IeltsListeningScreen(),
                              transition: Transition.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 300),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SectionCard(
                            icon: Icons.edit_note_rounded,
                            title: 'ielts_writing'.tr,
                            subtitle: 'writing_desc'.trParams({'count': '${ctrl.writingTasks.length}'}),
                            color: const Color(0xFFFF9800),
                            onTap: () => Get.to(
                              () => const IeltsWritingScreen(),
                              transition: Transition.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 300),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SectionCard(
                            icon: Icons.record_voice_over_rounded,
                            title: 'ielts_speaking'.tr,
                            subtitle: 'speaking_desc'.trParams({'count': '${ctrl.speakingTopics.length}'}),
                            color: const Color(0xFF9C27B0),
                            onTap: () => Get.to(
                              () => const IeltsSpeakingScreen(),
                              transition: Transition.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 300),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'study_tools'.tr,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 14),

                    // Vocabulary Builder
                    _ToolCard(
                      icon: Icons.auto_stories_rounded,
                      title: 'academic_vocab'.tr,
                      subtitle: 'academic_vocab_desc'.tr,
                      gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                      trailing: Obx(() => Text(
                        '${ctrl.vocabDueCount.value} ${'ielts_due'.tr}',
                        style: TextStyle(
                          color: ctrl.vocabDueCount.value > 0 ? const Color(0xFFFFCC02) : Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      )),
                      onTap: () => Get.to(
                        () => const IeltsVocabularyScreen(),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Mini Games
                    _ToolCard(
                      icon: Icons.sports_esports_rounded,
                      title: 'ielts_mini_games'.tr,
                      subtitle: 'ielts_mini_games_desc'.tr,
                      gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                      trailing: Text(
                        'games_count'.trParams({'count': '${ctrl.miniGames.length}'}),
                        style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      onTap: () => Get.to(
                        () => const IeltsMiniGamesScreen(),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Band Calculator
                    _ToolCard(
                      icon: Icons.calculate_rounded,
                      title: 'band_calc'.tr,
                      subtitle: 'band_calc_desc'.tr,
                      gradient: const [Color(0xFFFF9800), Color(0xFFF44336)],
                      trailing: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                      onTap: () => Get.to(
                        () => const IeltsBandCalculatorScreen(),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tips card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFE082)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.tips_and_updates_rounded, color: Color(0xFFFFA000), size: 20),
                              const SizedBox(width: 8),
                              Text('top_score_tips'.tr, style: const TextStyle(color: Color(0xFFF57F17), fontSize: 14, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const _TipItem(text: 'Practice all 4 sections equally for balanced improvement'),
                          const SizedBox(height: 6),
                          const _TipItem(text: 'Learn academic vocabulary with spaced repetition daily'),
                          const SizedBox(height: 6),
                          const _TipItem(text: 'Time yourself during reading — 20 min per passage'),
                          const SizedBox(height: 6),
                          const _TipItem(text: 'Study model answers to understand band 8+ writing'),
                          const SizedBox(height: 6),
                          const _TipItem(text: 'Record yourself speaking to identify areas for improvement'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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

// ── Section Card (2x2 grid) ────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }
}

// ── Tool Card (full-width) ──────────────────────────────────────────
class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final Widget trailing;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: gradient.first.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
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
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;
  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('  \u2022  ', style: TextStyle(color: Color(0xFFFFA000), fontSize: 13)),
        Expanded(
          child: Text(text, style: const TextStyle(color: Color(0xFF5D4037), fontSize: 13, height: 1.3)),
        ),
      ],
    );
  }
}
