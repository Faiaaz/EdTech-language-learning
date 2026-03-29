import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/controllers/program_controller.dart';
import 'package:ez_trainz/models/program.dart';
import 'package:ez_trainz/screens/forum_screen.dart';
import 'package:ez_trainz/screens/course_list_screen.dart';
import 'package:ez_trainz/screens/games_screen.dart';
import 'package:ez_trainz/screens/ielts_dashboard_screen.dart';
import 'package:ez_trainz/screens/leaderboard_screen.dart';
import 'package:ez_trainz/screens/profile_screen.dart';
import 'package:ez_trainz/widgets/language_switcher.dart';

/// Main container after login. Fixed bottom nav with five tabs.
/// Learn tab shows program picker (JLC/KLC/ELC/GLC) or course list when a program is selected.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  static const _navBgColor = Color(0xFF4DA6E8);
  static const _selectedColor = Color(0xFFFFE000);
  static const _unselectedColor = Colors.white70;

  static const _tabs = [
    _NavItem(icon: Icons.school_rounded, labelKey: 'nav_learn'),
    _NavItem(icon: Icons.fitness_center_rounded, labelKey: 'nav_practice'),
    _NavItem(icon: Icons.person_rounded, labelKey: 'nav_profile'),
    _NavItem(icon: Icons.people_rounded, labelKey: 'nav_community'),
    _NavItem(icon: Icons.emoji_events_rounded, labelKey: 'nav_leaderboard'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Obx(() {
            if (!ProgramController.to.hasProgram) {
              return const _ProgramPickerView();
            }
            // Route ELC (English) to the IELTS dashboard
            if (ProgramController.to.current == Program.elc) {
              return const IeltsDashboardScreen();
            }
            return const CourseListScreen();
          }),
          const GamesScreen(),
          const ProfileScreen(),
          const ForumScreen(),
          const LeaderboardScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _navBgColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final selected = _currentIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? _selectedColor.withValues(alpha: 0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          size: 24,
                          color: selected ? _selectedColor : _unselectedColor,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.labelKey.tr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? _selectedColor : _unselectedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
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
    return Scaffold(
      backgroundColor: const Color(0xFF4DA6E8),
      body: SafeArea(
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
                  const LanguageSwitcher(),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'choose_language_program'.tr,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'select_one_subtitle'.tr,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
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
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
