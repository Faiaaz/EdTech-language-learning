import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/controllers/program_controller.dart';
import 'package:ez_trainz/models/program.dart';
import 'package:ez_trainz/view/calendly_booking_screen.dart';
import 'package:ez_trainz/view/course_list_screen.dart';
import 'package:ez_trainz/view/for_you_screen.dart';
import 'package:ez_trainz/view/games_screen.dart';
import 'package:ez_trainz/view/ielts_dashboard_screen.dart';
import 'package:ez_trainz/view/jlc_home_screen.dart';
import 'package:ez_trainz/view/library_screen.dart';
import 'package:ez_trainz/view/trial_game_language_picker_screen.dart';
import 'package:ez_trainz/widgets/app_settings_menu.dart';
import 'package:ez_trainz/widgets/ez_trainz_logo_text.dart';
import 'package:ez_trainz/widgets/language_switcher.dart';
import 'package:ez_trainz/widgets/streak_pill.dart';
import 'package:ez_trainz/utils/app_theme.dart';

/// Main container after login. Bottom nav: Learn, Game, EZ (For You), Call Us, Library.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  static const _navBgColor = AppColors.card;

  static const _tabs = [
    _NavItem(icon: Icons.school_rounded, labelKey: 'nav_learn'),
    _NavItem(icon: Icons.sports_esports_rounded, labelKey: 'nav_game'),
    _NavItem.center(labelKey: 'nav_for_you'),
    _NavItem(icon: Icons.headset_mic_rounded, labelKey: 'nav_call_us'),
    _NavItem(icon: Icons.local_library_rounded, labelKey: 'nav_library'),
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
                    if (ProgramController.to.current == Program.jlc) {
                      return const JlcHomeScreen();
                    }
                    return const CourseListScreen();
                  },
                ),
                const GamesScreen(),
                const ForYouScreen(),
                _currentIndex == 3
                    ? const CalendlyBookingScreen()
                    : const SizedBox.shrink(),
                const LibraryScreen(),
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
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(_tabs.length, (i) {
                    final tab = _tabs[i];
                    final selected = _currentIndex == i;
                    if (tab.isCenter) {
                      return Expanded(child: _EzCenterNavButton(
                        selected: selected,
                        onTap: () => setState(() => _currentIndex = i),
                      ));
                    }
                    return Expanded(
                      child: _NavTabButton(
                        tab: tab,
                        selected: selected,
                        onTap: () => setState(() => _currentIndex = i),
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
  const _NavItem({
    required this.icon,
    required this.labelKey,
  }) : isCenter = false;

  const _NavItem.center({required this.labelKey})
      : icon = Icons.circle,
        isCenter = true;

  final IconData icon;
  final String labelKey;
  final bool isCenter;
}

class _NavTabButton extends StatelessWidget {
  const _NavTabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final _NavItem tab;
  final bool selected;
  final VoidCallback onTap;

  static const _selectedColor = AppColors.accentBlueDk;
  static const _unselectedColor = AppColors.textMuted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              color: selected ? _selectedColor : _unselectedColor,
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
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? _selectedColor : _unselectedColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EzCenterNavButton extends StatefulWidget {
  const _EzCenterNavButton({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  State<_EzCenterNavButton> createState() => _EzCenterNavButtonState();
}

class _EzCenterNavButtonState extends State<_EzCenterNavButton>
    with SingleTickerProviderStateMixin {
  static const _yellow = Color(0xFFFFE000);
  static const _yellowLight = Color(0xFFFFF176);
  static const _blue = Color(0xFF1E88E5);
  static const _blueMid = Color(0xFF1565C0);
  static const _blueDark = Color(0xFF0D47A1);

  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.selected) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _EzCenterNavButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _pulse.repeat(reverse: true);
    } else if (!widget.selected && oldWidget.selected) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final breathe = widget.selected ? _pulse.value : 0.0;
              final yellowGlow = 0.38 + breathe * 0.42;
              final blueGlow = 0.30 + breathe * 0.20;
              final textGlow = 0.55 + breathe * 0.45;
              return Transform.translate(
                offset: Offset(0, widget.selected ? -8 : -3),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _yellow.withValues(alpha: yellowGlow),
                        blurRadius: 20 + breathe * 18,
                        spreadRadius: 2 + breathe * 5,
                      ),
                      BoxShadow(
                        color: _yellowLight.withValues(alpha: 0.25 + breathe * 0.2),
                        blurRadius: 10 + breathe * 8,
                        spreadRadius: breathe * 2,
                      ),
                      BoxShadow(
                        color: _blue.withValues(alpha: blueGlow),
                        blurRadius: 24 + breathe * 12,
                        spreadRadius: breathe * 2,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: _blueDark.withValues(alpha: 0.24),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        center: Alignment(-0.32, -0.42),
                        radius: 1.05,
                        colors: [
                          Color(0xFF42A5F5),
                          _blue,
                          _blueMid,
                          _blueDark,
                        ],
                        stops: [0.0, 0.35, 0.72, 1.0],
                      ),
                      border: Border.all(
                        color: widget.selected
                            ? _yellowLight
                            : _yellow.withValues(alpha: 0.82),
                        width: widget.selected ? 3 : 2.4,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: const Alignment(0.2, 0.85),
                                radius: 0.95,
                                colors: [
                                  Colors.transparent,
                                  _blueDark.withValues(alpha: 0.45),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 14,
                          right: 14,
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.42),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        _GlowingEzText(intensity: textGlow),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'nav_for_you'.tr,
              maxLines: 1,
              style: TextStyle(
                fontSize: 9,
                height: 1.1,
                fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
                color: widget.selected
                    ? AppColors.accentBlueDk
                    : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowingEzText extends StatelessWidget {
  const _GlowingEzText({required this.intensity});

  final double intensity;

  static const _yellow = Color(0xFFFFE000);
  static const _yellowLight = Color(0xFFFFF59D);
  static const _yellowHot = Color(0xFFFFFDE7);
  static const _blueDark = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    const fontSize = 21.0;
    const letterSpacing = -0.9;
    final outerBlur = 14.0 + intensity * 16;
    final midBlur = 8.0 + intensity * 10;
    final innerBlur = 3.0 + intensity * 4;

    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          'EZ',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: letterSpacing,
            color: _yellow.withValues(alpha: 0.18),
            shadows: [
              Shadow(color: _yellow, blurRadius: outerBlur),
              Shadow(color: _yellowLight, blurRadius: outerBlur * 0.7),
            ],
          ),
        ),
        Text(
          'EZ',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: letterSpacing,
            color: _yellow.withValues(alpha: 0.45),
            shadows: [
              Shadow(color: _yellow, blurRadius: midBlur),
            ],
          ),
        ),
        Text(
          'EZ',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: letterSpacing,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.6
              ..color = _blueDark.withValues(alpha: 0.85),
          ),
        ),
        Text(
          'EZ',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: letterSpacing,
            color: Color.lerp(_yellow, _yellowHot, intensity * 0.55)!,
            shadows: [
              Shadow(color: _yellowHot, blurRadius: innerBlur),
              Shadow(color: _yellowLight, blurRadius: midBlur * 0.55),
              const Shadow(
                color: Color(0x660D47A1),
                offset: Offset(0, 1.2),
                blurRadius: 0,
              ),
            ],
          ),
        ),
      ],
    );
  }
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
                  const SizedBox(width: 8),
                  const AppSettingsMenuButton(compact: true),
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
