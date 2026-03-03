import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/controllers/program_controller.dart';
import 'package:ez_trainz/models/program.dart';
import 'package:ez_trainz/screens/course_detail_screen.dart';
import 'package:ez_trainz/screens/main_shell_screen.dart';
import 'package:ez_trainz/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ── Entrance animation ─────────────────────────────────────────
  late AnimationController _entranceCtrl;
  late Animation<double>   _fadeIn;
  late Animation<Offset>   _slideIn;

  // ── Staggered card animations ──────────────────────────────────
  late AnimationController _cardsCtrl;
  late Animation<double>   _card1Fade;
  late Animation<Offset>   _card1Slide;
  late Animation<double>   _card2Fade;
  late Animation<Offset>   _card2Slide;
  late Animation<double>   _card3Fade;
  late Animation<Offset>   _card3Slide;
  late Animation<double>   _card4Fade;
  late Animation<Offset>   _card4Slide;

  // ── Waving arm animation ───────────────────────────────────────
  late AnimationController _waveCtrl;
  late Animation<double>   _waveAngle;

  @override
  void initState() {
    super.initState();

    // Entrance
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn  = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));
    _entranceCtrl.forward();

    // Staggered card animations
    _cardsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _card1Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _card1Slide = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _cardsCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)),
    );

    _card2Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsCtrl, curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
    );
    _card2Slide = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _cardsCtrl, curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic)),
    );

    _card3Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsCtrl, curve: const Interval(0.4, 0.9, curve: Curves.easeOut)),
    );
    _card3Slide = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _cardsCtrl, curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic)),
    );

    _card4Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsCtrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );
    _card4Slide = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _cardsCtrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic)),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _cardsCtrl.forward();
    });

    // Wave — rocks back and forth 5 times then stops
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _waveAngle = Tween<double>(begin: -0.12, end: 0.12).animate(
      CurvedAnimation(parent: _waveCtrl, curve: Curves.easeInOut),
    );

    // Start waving after a short delay
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _wave(5);
    });
  }

  // Recursive wave: rocks n times then stops
  void _wave(int remaining) {
    if (remaining <= 0 || !mounted) return;
    _waveCtrl.forward().then((_) {
      if (!mounted) return;
      _waveCtrl.reverse().then((_) => _wave(remaining - 1));
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _cardsCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  void _onLogout() {
    AuthController.to.logout();
    Get.offAll(() => const LoginScreen());
  }

  void _navigateToProgram(Program program) {
    ProgramController.to.setProgram(program);
    CourseController.to.loadCourses();
    Get.to(
      () => const MainShellScreen(),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstName = AuthController.to.firstName;

    return Scaffold(
      backgroundColor: const Color(0xFF4DA6E8),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideIn,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── TOP BAR ────────────────────────────────────
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
                        GestureDetector(
                          onTap: _onLogout,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white38, width: 1),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.logout_rounded,
                                    color: Colors.white, size: 15),
                                SizedBox(width: 5),
                                Text('Logout',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // ── GREETING ───────────────────────────────────
                    Text(
                      'Hello,',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      '$firstName! 👋',
                      style: const TextStyle(
                        color: Color(0xFFFFE000),
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Choose a language program to start',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── PROGRAM CARDS (JLC, KLC, ELC, GLC) ─────────
                    AnimatedBuilder(
                      animation: _cardsCtrl,
                      builder: (context, _) {
                        return Column(
                          children: [
                            SlideTransition(
                              position: _card1Slide,
                              child: FadeTransition(
                                opacity: _card1Fade,
                                child: _NavCard(
                                  title: Program.jlc.name,
                                  subtitle: Program.jlc.subtitle,
                                  iconWidget: _flagIcon(Program.jlc.flagEmoji),
                                  gradientColors: Program.jlc.gradientColors,
                                  onTap: () => _navigateToProgram(Program.jlc),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SlideTransition(
                              position: _card2Slide,
                              child: FadeTransition(
                                opacity: _card2Fade,
                                child: _NavCard(
                                  title: Program.klc.name,
                                  subtitle: Program.klc.subtitle,
                                  iconWidget: _flagIcon(Program.klc.flagEmoji),
                                  gradientColors: Program.klc.gradientColors,
                                  onTap: () => _navigateToProgram(Program.klc),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SlideTransition(
                              position: _card3Slide,
                              child: FadeTransition(
                                opacity: _card3Fade,
                                child: _NavCard(
                                  title: Program.elc.name,
                                  subtitle: Program.elc.subtitle,
                                  iconWidget: _flagIcon(Program.elc.flagEmoji),
                                  gradientColors: Program.elc.gradientColors,
                                  onTap: () => _navigateToProgram(Program.elc),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SlideTransition(
                              position: _card4Slide,
                              child: FadeTransition(
                                opacity: _card4Fade,
                                child: _NavCard(
                                  title: Program.glc.name,
                                  subtitle: Program.glc.subtitle,
                                  iconWidget: _flagIcon(Program.glc.flagEmoji),
                                  gradientColors: Program.glc.gradientColors,
                                  onTap: () => _navigateToProgram(Program.glc),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // ── WAVING PENGUIN ─────────────────────────────
                    Center(
                      child: AnimatedBuilder(
                        animation: _waveCtrl,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _waveAngle.value,
                            alignment: Alignment.bottomCenter,
                            child: child,
                          );
                        },
                        child: const Image(
                          image: AssetImage(
                              'assets/images/ninja_penguin_transparent.png'),
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── TAGLINE ────────────────────────────────────
                    Center(
                      child: Text(
                        'ভাষা শিখুন, ভবিষ্যৎ গড়ুন',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Flag emoji, no box, slightly larger for natural look ─────────────
Widget _flagIcon(String flagEmoji) {
  return Text(
    flagEmoji,
    style: const TextStyle(fontSize: 38, height: 1.15),
  );
}

// ── NAVIGATION CARD WIDGET ──────────────────────────────────────────
class _NavCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget iconWidget;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _NavCard({
    required this.title,
    required this.subtitle,
    required this.iconWidget,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_NavCard> createState() => _NavCardState();
}

class _NavCardState extends State<_NavCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) {
        _scaleCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(scale: _scale.value, child: child);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.first.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Flag only, no box; reserve width so layout stays even ──
              SizedBox(
                width: 52,
                child: Center(child: widget.iconWidget),
              ),
              const SizedBox(width: 16),

              // ── Title + subtitle ────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Arrow ──────────────────────────────────────
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
