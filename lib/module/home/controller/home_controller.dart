import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/controllers/program_controller.dart';
import 'package:ez_trainz/view/login_screen.dart';
import 'package:ez_trainz/view/main_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/program.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {


  late AnimationController entranceCtrl;
  late Animation<double> fadeIn;
  late Animation<Offset> slideIn;

  // ── Staggered card animations ──────────────────────────────────
  late AnimationController cardsCtrl;
  late Animation<double> card1Fade;
  late Animation<Offset> card1Slide;
  late Animation<double> card2Fade;
  late Animation<Offset> card2Slide;
  late Animation<double> card3Fade;
  late Animation<Offset> card3Slide;
  late Animation<double> card4Fade;
  late Animation<Offset> card4Slide;
  late Animation<double> card5Fade;
  late Animation<Offset> card5Slide;

  // ── Waving arm animation ───────────────────────────────────────
  late AnimationController waveCtrl;
  late Animation<double> waveAngle;

  @override
  void onInit() {
    super.onInit();

    // Entrance
    entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    fadeIn = CurvedAnimation(parent: entranceCtrl, curve: Curves.easeOut);
    slideIn = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: entranceCtrl, curve: Curves.easeOut));
    entranceCtrl.forward();

    // Staggered card animations
    cardsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    card1Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: cardsCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    card1Slide = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: cardsCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    card2Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: cardsCtrl,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );
    card2Slide = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: cardsCtrl,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    card3Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: cardsCtrl,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );
    card3Slide = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: cardsCtrl,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
      ),
    );
    card4Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: cardsCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    card4Slide = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: cardsCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    card5Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: cardsCtrl,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
    card5Slide = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: cardsCtrl,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      cardsCtrl.forward();
    });

    // Wave — rocks back and forth 5 times then stops
    waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    waveAngle = Tween<double>(begin: -0.12, end: 0.12).animate(
      CurvedAnimation(parent: waveCtrl, curve: Curves.easeInOut),
    );
    Future.delayed(const Duration(milliseconds: 700), () {
      _wave(5);
    });
  }

  void _wave(int remaining) {
    if (remaining <= 0) return;
    waveCtrl.forward().then((_) {
      waveCtrl.reverse().then((_) => _wave(remaining - 1));
    });
  }

  void onLogout() {
    AuthController.to.logout();
    Get.offAll(() => const LoginScreen());
  }

  void navigateToProgram(Program program) {
    ProgramController.to.setProgram(program);
    CourseController.to.loadCourses();
    Get.off(() => const MainShellScreen(),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    entranceCtrl.dispose();
    cardsCtrl.dispose();
    waveCtrl.dispose();
    super.onClose();
  }
}