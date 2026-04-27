import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/journey_controller.dart';
import 'package:ez_trainz/models/xp_event.dart';

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

  late final ConfettiController _confetti;
  late final AnimationController _imageScale;
  late final AnimationController _cardSlide;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 5));
    _imageScale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardSlide = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Award game XP — pushes total to ≥50, unlocking the Explorer hat.
      await JourneyController.to.grantXp(source: XpSource.game);
      // Consume the pending level-up so JourneyScreen's overlay doesn't
      // double-fire; this screen IS the celebration.
      JourneyController.to.consumeLevelUp();

      if (!mounted) return;
      _confetti.play();
      _imageScale.forward();
      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted) _cardSlide.forward();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    _imageScale.dispose();
    _cardSlide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Confetti from top-center
          ConfettiWidget(
            confettiController: _confetti,
            blastDirection: math.pi / 2,
            numberOfParticles: 36,
            maxBlastForce: 30,
            minBlastForce: 12,
            gravity: 0.22,
            emissionFrequency: 0.04,
            colors: const [
              Color(0xFFFFE000),
              Color(0xFF3B82F6),
              Color(0xFF10B981),
              Color(0xFF8B5CF6),
              Color(0xFFEF4444),
              Color(0xFFF59E0B),
            ],
          ),
          // Main layout
          SafeArea(
            child: Column(
              children: [
                // Dismiss button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white38),
                    ),
                  ),
                ),
                // Achievement image — avatar WITH hat
                Expanded(
                  child: AnimatedBuilder(
                    animation: _imageScale,
                    builder: (_, child) {
                      final t =
                          Curves.elasticOut.transform(_imageScale.value);
                      return Transform.scale(
                          scale: 0.5 + 0.5 * t, child: child);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/images/stitch_crowned_achievement.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                // Slide-up congratulations card
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _cardSlide,
                    curve: Curves.easeOutCubic,
                  )),
                  child: FadeTransition(
                    opacity: _cardSlide,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        border: Border(
                          top: BorderSide(
                            color: _gold.withValues(alpha: 0.25),
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _gold.withValues(alpha: 0.10),
                            blurRadius: 28,
                            offset: const Offset(0, -8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Badge chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: _gold.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: _gold.withValues(alpha: 0.45),
                              ),
                            ),
                            child: const Text(
                              '🎩  Explorer Unlocked',
                              style: TextStyle(
                                color: _gold,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
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
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Get.back(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _gold,
                                foregroundColor: Colors.black87,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Claim Your Hat',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15),
                              ),
                            ),
                          ),
                        ],
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
