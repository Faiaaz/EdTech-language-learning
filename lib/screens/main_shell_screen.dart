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
import 'package:ez_trainz/widgets/language_switcher.dart';
import 'package:ez_trainz/widgets/streak_pill.dart';

/// Main container after login. Fixed bottom nav (Learn, Practice, Collect, Profile, Community, Leaderboard).
/// Learn tab shows program picker (JLC/KLC/ELC/GLC) or course list when a program is selected.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  static const _navBgColor = Color(0xFF1E293B);
  /// Aligns bottom bar with JLC course list sky-blue theme (was clashing with slate).
  static const _jlcLearnNavBg = Color(0xFF1A4A7A);
  static const _selectedColor = Color(0xFFFFE000);
  static const _unselectedColor = Color(0xFF94A3B8);

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
        final jlcLearn = _currentIndex == 0 &&
            ProgramController.to.current == Program.jlc;
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
        decoration: BoxDecoration(
          color: jlcLearn ? _jlcLearnNavBg : _navBgColor,
          border: Border(
            top: BorderSide(
              color: jlcLearn
                  ? const Color(0xFF4DA6E8).withValues(alpha: 0.42)
                  : const Color(0xFF334155),
              width: 1,
            ),
          ),
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
      color: const Color(0xFF0F172A),
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
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('EZ',
                          style: TextStyle(
                            color: Color(0xFFFFE000),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          )),
                      SizedBox(width: 3),
                      Text('TRAINZ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            height: 1,
                          )),
                    ],
                  ),
                  const StreakPill(),
                  const LanguageSwitcher(),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'choose_language_program'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'select_one_subtitle'.tr,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
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
    );
  }
}

class _TrialGameCard extends StatelessWidget {
  const _TrialGameCard({required this.onTap});

  final VoidCallback onTap;

  static const _gold = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _gold.withValues(alpha: 0.35), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.22),
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
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.24)),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.bolt_rounded,
                  color: _gold, size: 30),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trial Game',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Try a language in 60 seconds with a mini-game.',
                    style: TextStyle(
                      color: Colors.white70,
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
          gradient: LinearGradient(
            colors: program.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: program.gradientColors.first.withValues(alpha: 0.35),
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
                color: Colors.white.withValues(alpha: 0.22),
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
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    program.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
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
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: const Color(0xFF1E293B), size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
