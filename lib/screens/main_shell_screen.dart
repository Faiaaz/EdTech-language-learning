import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/controllers/program_controller.dart';
import 'package:ez_trainz/models/program.dart';
import 'package:ez_trainz/screens/collectibles_screen.dart';
import 'package:ez_trainz/screens/course_list_screen.dart';
import 'package:ez_trainz/screens/forum_screen.dart';
import 'package:ez_trainz/screens/games_screen.dart';
import 'package:ez_trainz/screens/ielts_dashboard_screen.dart';
import 'package:ez_trainz/screens/leaderboard_screen.dart';
import 'package:ez_trainz/screens/profile_screen.dart';
import 'package:ez_trainz/screens/trial_game_language_picker_screen.dart';
import 'package:ez_trainz/widgets/ez_trainz_logo_text.dart';
import 'package:ez_trainz/widgets/language_switcher.dart';
import 'package:ez_trainz/widgets/streak_pill.dart';
import 'package:ez_trainz/utils/app_theme.dart';

/// Main container after login. Fixed bottom nav (Learn, Practice, Collect, Profile, Community, Leaderboard).
/// Learn tab shows program picker (JLC/KLC/ELC/GLC) or course list when a program is selected.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  static const _navBgColor = AppColors.card;
  static const _selectedColor = AppColors.accentBlueDk;
  static const _unselectedColor = AppColors.textMuted;

  static const _tabs = [
    _NavItem(icon: Icons.school_rounded, labelKey: 'nav_learn'),
    _NavItem(icon: Icons.fitness_center_rounded, labelKey: 'nav_practice'),
    _NavItem(icon: Icons.park_rounded, labelKey: 'nav_collectibles'),
    _NavItem(icon: Icons.person_rounded, labelKey: 'nav_profile'),
    _NavItem(icon: Icons.people_alt_rounded, labelKey: 'nav_community'),
    _NavItem(icon: Icons.emoji_events_rounded, labelKey: 'nav_leaderboard'),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProgramController>(
      builder: (_) {
        return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: IndexedStack(
          sizing: StackFit.expand,
          index: _currentIndex,
          children: [
            GetBuilder<ProgramController>(
              builder: (_) {
                if (!ProgramController.to.hasProgram) {
                  return const _ProgramPickerView();
                }
                if (ProgramController.to.current == Program.elc) {
                  return const IeltsDashboardScreen();
                }
                return const CourseListScreen();
              },
            ),
            const GamesScreen(),
            const CollectiblesScreen(),
            const ProfileScreen(),
            const ForumScreen(),
            const LeaderboardScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: _navBgColor,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final selected = _currentIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? _selectedColor.withValues(alpha: 0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? _selectedColor.withValues(alpha: 0.55)
                              : Colors.transparent,
                          width: 1.4,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tab.icon,
                            size: 22,
                            color: selected
                                ? _selectedColor
                                : _unselectedColor,
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              tab.labelKey.tr,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                height: 1.1,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? _selectedColor
                                    : _unselectedColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.labelKey});
  final IconData icon;
  final String labelKey;
}

/// Shown in Learn tab when no program is selected. Tapping a card sets program and loads courses.
class _ProgramPickerView extends StatelessWidget {
  const _ProgramPickerView();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SkyGoldBackground(
        child: SafeArea(
        child: SizedBox.expand(
          child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const EzTrainzLogoText(
                    height: 30,
                    alignment: Alignment.centerLeft,
                  ),
                  const StreakPill(),
                  const LanguageSwitcher(),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'choose_language_program'.tr,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'select_one_subtitle'.tr,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Image(
                  image: const AssetImage(
                    'assets/images/ninja_penguin_transparent.png',
                  ),
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              _TrialGameCard(
                onTap: () => Get.to(
                  () => const TrialGameLanguagePickerScreen(),
                  transition: Transition.rightToLeftWithFade,
                  duration: const Duration(milliseconds: 260),
                ),
              ),
              const SizedBox(height: 14),
              _ProgramCard(program: Program.jlc),
              const SizedBox(height: 14),
              _ProgramCard(program: Program.klc),
              const SizedBox(height: 14),
              _ProgramCard(program: Program.elc),
              const SizedBox(height: 14),
              _ProgramCard(program: Program.glc),
              const SizedBox(height: 32),
            ],
          ),
        ),
        ),
        ),
      ),
    );
  }
}

class _TrialGameCard extends StatelessWidget {
  const _TrialGameCard({required this.onTap});

  final VoidCallback onTap;

  static const _gold = AppColors.accentYellow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.cardAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _gold, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBlue.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.accentBlue.withValues(alpha: 0.25)),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.bolt_rounded,
                  color: AppColors.accentBlueDk, size: 30),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trial Game',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Try a language in 60 seconds with a mini-game.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TRY',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.black87, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program});
  final Program program;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ProgramController.to.setProgram(program);
        CourseController.to.loadCourses();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: program.gradientColors.first.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: program.gradientColors.first.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                program.flagEmoji,
                style: const TextStyle(fontSize: 26, height: 1.2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    program.subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: program.gradientColors.first.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_rounded,
                  color: program.gradientColors.first, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
