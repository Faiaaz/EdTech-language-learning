import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/controllers/program_controller.dart';
import 'package:ez_trainz/models/program.dart';
import 'package:ez_trainz/view/collectibles_screen.dart';
import 'package:ez_trainz/view/course_list_screen.dart';
import 'package:ez_trainz/view/ielts_dashboard_screen.dart';
import 'package:ez_trainz/utils/app_theme.dart';

/// Library / shop hub — collectibles, career videos, and exam content.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SkyGoldBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                child: Text(
                  'nav_library'.tr,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Text(
                  'library_subtitle'.tr,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    _LibraryCard(
                      icon: Icons.park_rounded,
                      titleKey: 'library_collectibles_title',
                      subtitleKey: 'library_collectibles_sub',
                      gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                      onTap: () => Get.to(() => const CollectiblesScreen()),
                    ),
                    const SizedBox(height: 14),
                    _LibraryCard(
                      icon: Icons.work_outline_rounded,
                      titleKey: 'library_career_title',
                      subtitleKey: 'library_career_sub',
                      gradient: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      onTap: _openCareerVideos,
                    ),
                    const SizedBox(height: 14),
                    _LibraryCard(
                      icon: Icons.school_outlined,
                      titleKey: 'library_exam_title',
                      subtitleKey: 'library_exam_sub',
                      gradient: const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                      onTap: _openExamContent,
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

  void _openCareerVideos() {
    if (!ProgramController.to.hasProgram) {
      Get.snackbar(
        'library_career_title'.tr,
        'library_pick_program'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.textPrimary,
        colorText: Colors.white,
      );
      return;
    }
    Get.to(() => const CourseListScreen());
  }

  void _openExamContent() {
    ProgramController.to.setProgram(Program.elc);
    CourseController.to.loadCourses();
    Get.to(() => const IeltsDashboardScreen());
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.16),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleKey.tr,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitleKey.tr,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textDim,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
