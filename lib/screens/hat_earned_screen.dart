import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/journey_controller.dart';
import 'package:ez_trainz/models/xp_event.dart';
import 'package:ez_trainz/widgets/hero_path_journey_map.dart';
import 'package:ez_trainz/screens/hat_preview_interstitial_screen.dart';

/// Shown after the Lesson 1 game session completes.
/// Grants game XP (unlocking the Explorer hat), then celebrates with
/// confetti, the crowned-achievement screenshot, and a congratulations card.
class HatEarnedScreen extends StatefulWidget {
  const HatEarnedScreen({super.key});

  @override
  State<HatEarnedScreen> createState() => _HatEarnedScreenState();
}

class _HatEarnedScreenState extends State<HatEarnedScreen>
    with TickerProviderStateMixin {
  static const _gold = Color(0xFFFFE000);
  static const _bg = Color(0xFF0B1326);

  late final ConfettiController _confettiCenter;
  late final ConfettiController _confettiLeft;
  late final ConfettiController _confettiRight;
  late final AnimationController _imageScale;
  late final AnimationController _cardSlide;
  late final AnimationController _sparkle;

  @override
  void initState() {
    super.initState();
    _confettiCenter =
        ConfettiController(duration: const Duration(seconds: 6));
    _confettiLeft =
        ConfettiController(duration: const Duration(seconds: 5));
    _confettiRight =
        ConfettiController(duration: const Duration(seconds: 5));
    _imageScale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardSlide = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _sparkle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await JourneyController.to.grantXp(
        source: XpSource.game,
        silentLevelUp: true,
      );
      JourneyController.to.consumeLevelUp();

      if (!mounted) return;
      HapticFeedback.heavyImpact();
      _confettiCenter.play();
      _imageScale.forward();
      _sparkle.forward();
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted) _confettiLeft.play();
      });
      Future.delayed(const Duration(milliseconds: 360), () {
        if (mounted) _confettiRight.play();
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) HapticFeedback.mediumImpact();
      });
      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted) _cardSlide.forward();
    });
  }

  @override
  void dispose() {
    _confettiCenter.dispose();
    _confettiLeft.dispose();
    _confettiRight.dispose();
    _imageScale.dispose();
    _cardSlide.dispose();
    _sparkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Triple confetti cascade — left, center, right.
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCenter,
              blastDirection: math.pi / 2,
              numberOfParticles: 40,
              maxBlastForce: 34,
              minBlastForce: 14,
              gravity: 0.22,
              emissionFrequency: 0.04,
              colors: _confettiColors,
            ),
          ),
          Positioned(
            top: 0,
            left: 24,
            child: ConfettiWidget(
              confettiController: _confettiLeft,
              blastDirection: math.pi / 2 + 0.5,
              numberOfParticles: 22,
              maxBlastForce: 26,
              minBlastForce: 12,
              gravity: 0.22,
              emissionFrequency: 0.05,
              colors: _confettiColors,
            ),
          ),
          Positioned(
            top: 0,
            right: 24,
            child: ConfettiWidget(
              confettiController: _confettiRight,
              blastDirection: math.pi / 2 - 0.5,
              numberOfParticles: 22,
              maxBlastForce: 26,
              minBlastForce: 12,
              gravity: 0.22,
              emissionFrequency: 0.05,
              colors: _confettiColors,
            ),
          ),
          // Main layout (match Hero's Path novice UI)
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white54),
                      ),
                      const Expanded(
                        child: Text(
                          "HERO'S PATH",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _gold,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      children: [
                        // Avatar card (matches novice card; hatted) with
                        // a soft gold sparkle ring sweeping behind it.
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _sparkle,
                              builder: (_, __) {
                                final t = Curves.easeOutCubic
                                    .transform(_sparkle.value);
                                return IgnorePointer(
                                  child: Container(
                                    width: 320 * (0.85 + 0.15 * t),
                                    height: 320 * (0.85 + 0.15 * t),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          _gold.withValues(
                                              alpha: 0.25 * (1 - t * 0.4)),
                                          _gold.withValues(alpha: 0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            AnimatedBuilder(
                              animation: _imageScale,
                              builder: (_, child) {
                                final t = Curves.easeOutCubic
                                    .transform(_imageScale.value.clamp(0.0, 1.0));
                                return Opacity(
                                  opacity: t,
                                  child: Transform.translate(
                                    offset: Offset(0, (1 - t) * 12),
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: _gold.withValues(alpha: 0.75),
                                  width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: _gold.withValues(alpha: 0.18),
                                  blurRadius: 28,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    'assets/images/girl_avatar_hatted.png',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _gold.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                        color: _gold.withValues(alpha: 0.5),
                                        width: 1.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.emoji_events_rounded,
                                          color:
                                              _gold.withValues(alpha: 0.85),
                                          size: 16),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Level 2 · Explorer',
                                        style: TextStyle(
                                          color: _gold,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // XP section (now filled)
                        Obx(() {
                          final total = JourneyController.to.totalXp;
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'EXPERIENCE',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.45),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  Text(
                                    '${total.clamp(0, 50)} / 50 XP',
                                    style: const TextStyle(
                                      color: _gold,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Stack(
                                children: [
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor:
                                        (total / 50).clamp(0.0, 1.0),
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF3B82F6), _gold],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 28),
                        // Journey map (Explorer's Discovery reached)
                        Obx(() =>
                            HeroPathJourneyMap(stage: JourneyController.to.stage.value)),
                        const SizedBox(height: 18),
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.08),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _cardSlide,
                            curve: Curves.easeOutCubic,
                          )),
                          child: FadeTransition(
                            opacity: _cardSlide,
                            child: Column(
                              children: [
                                const Text(
                                  'Congratulations!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "You've earned a hat",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Get.offAll(
                          () => const HatPreviewInterstitialScreen(
                            resetOnEntry: false,
                            celebrate: true,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Claim Your Hat',
                        style:
                            TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _confettiColors = <Color>[
  Color(0xFFFFE000),
  Color(0xFF3B82F6),
  Color(0xFF10B981),
  Color(0xFF8B5CF6),
  Color(0xFFEF4444),
  Color(0xFFF59E0B),
  Color(0xFFEC4899),
];
