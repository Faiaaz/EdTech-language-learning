import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/screens/course_list_screen.dart';
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
    _waveCtrl.dispose();
    super.dispose();
  }

  void _onLogout() {
    AuthController.to.logout();
    Get.offAll(() => const LoginScreen());
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

                  const SizedBox(height: 48),

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
                    'Ready to learn something new today?',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── START LEARNING BUTTON ────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.to(() => const CourseListScreen()),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE000),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFE000).withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_rounded,
                                color: Color(0xFF1A1A2E), size: 22),
                            SizedBox(width: 10),
                            Text('Browse Courses',
                                style: TextStyle(
                                  color: Color(0xFF1A1A2E),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

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
                        height: 260,
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

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
