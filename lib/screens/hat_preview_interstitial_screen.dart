import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/journey_controller.dart';
import 'package:ez_trainz/screens/lesson1_game_flow_screen.dart';
import 'package:ez_trainz/widgets/hero_path_journey_map.dart';

class HatPreviewInterstitialScreen extends StatefulWidget {
  const HatPreviewInterstitialScreen({
    super.key,
    this.resetOnEntry = true,
    this.celebrate = false,
  });

  /// If `true`, [JourneyController.resetProgress] is called on entry
  /// (treating this as a fresh start). When the user comes here from
  /// [HatEarnedScreen] via "Claim Your Hat", set this to `false` so the
  /// hat they just earned persists.
  final bool resetOnEntry;

  /// If `true`, plays a confetti / haptic celebration on entry to carry
  /// the hat-earned moment through to this screen.
  final bool celebrate;

  @override
  State<HatPreviewInterstitialScreen> createState() =>
      _HatPreviewInterstitialScreenState();
}

class _HatPreviewInterstitialScreenState
    extends State<HatPreviewInterstitialScreen>
    with TickerProviderStateMixin {
  static const _gold = Color(0xFFFFE000);
  static const _bg = Color(0xFF0B1326);
  static const _surface = Color(0xFF111827);

  late final AnimationController _fadeIn;
  late final ConfettiController _confettiLeft;
  late final ConfettiController _confettiCenter;
  late final ConfettiController _confettiRight;

  @override
  void initState() {
    super.initState();
    if (widget.resetOnEntry) {
      JourneyController.to.resetProgress();
    }
    _fadeIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _confettiLeft =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiCenter =
        ConfettiController(duration: const Duration(seconds: 4));
    _confettiRight =
        ConfettiController(duration: const Duration(seconds: 3));
    if (widget.celebrate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        HapticFeedback.heavyImpact();
        _confettiCenter.play();
        Future.delayed(const Duration(milliseconds: 120), () {
          if (mounted) _confettiLeft.play();
        });
        Future.delayed(const Duration(milliseconds: 240), () {
          if (mounted) _confettiRight.play();
        });
      });
    }
  }

  @override
  void dispose() {
    _fadeIn.dispose();
    _confettiLeft.dispose();
    _confettiCenter.dispose();
    _confettiRight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_rounded,
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
                      const Icon(Icons.settings_rounded,
                          color: Colors.white30, size: 22),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                // ── Scrollable body ──────────────────────────────────────
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Column(
                        children: [
                          const _AvatarCard(),
                          const SizedBox(height: 20),
                          const _XpSection(),
                          const SizedBox(height: 28),
                          const _JourneyPath(),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
                // ── Fixed bottom CTA ────────────────────────────────────
                _BottomCard(
                  onStart: () =>
                      Get.off(() => const Lesson1GameFlowScreen()),
                ),
              ],
            ),
          ),
          // ── Confetti emitters (only fire if `celebrate` is true) ──
          Positioned(
            top: 0,
            left: 24,
            child: ConfettiWidget(
              confettiController: _confettiLeft,
              blastDirection: math.pi / 2 + 0.4,
              numberOfParticles: 18,
              maxBlastForce: 24,
              minBlastForce: 10,
              gravity: 0.20,
              emissionFrequency: 0.05,
              colors: _confettiColors,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCenter,
              blastDirection: math.pi / 2,
              numberOfParticles: 28,
              maxBlastForce: 32,
              minBlastForce: 14,
              gravity: 0.22,
              emissionFrequency: 0.04,
              colors: _confettiColors,
            ),
          ),
          Positioned(
            top: 0,
            right: 24,
            child: ConfettiWidget(
              confettiController: _confettiRight,
              blastDirection: math.pi / 2 - 0.4,
              numberOfParticles: 18,
              maxBlastForce: 24,
              minBlastForce: 10,
              gravity: 0.20,
              emissionFrequency: 0.05,
              colors: _confettiColors,
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

// ── Avatar card ─────────────────────────────────────────────────────────────

class _AvatarCard extends StatelessWidget {
  const _AvatarCard();

  static const _gold = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withValues(alpha: 0.75), width: 2),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: 0.18),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Girl avatar — no hat yet
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/girl_avatar_no_hat.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 12),
          // Level badge
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
              border:
                  Border.all(color: _gold.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events_rounded,
                    color: _gold.withValues(alpha: 0.85), size: 16),
                const SizedBox(width: 6),
                const Text(
                  'Level 1 · Novice',
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
    );
  }
}

// ── XP bar ──────────────────────────────────────────────────────────────────

class _XpSection extends StatelessWidget {
  const _XpSection();

  static const _gold = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EXPERIENCE',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '0 / 50 XP',
              style: const TextStyle(
                color: _gold,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Track
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            // Fill — 0% (empty at start)
            Container(
              height: 8,
              width: 0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), _gold],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Earn 50 XP to unlock Explorer',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Journey path ─────────────────────────────────────────────────────────────

class _JourneyPath extends StatelessWidget {
  const _JourneyPath();

  @override
  Widget build(BuildContext context) {
    return Obx(() => HeroPathJourneyMap(stage: JourneyController.to.stage.value));
  }
}

// ── Bottom CTA card ──────────────────────────────────────────────────────────

class _BottomCard extends StatelessWidget {
  const _BottomCard({required this.onStart});
  final VoidCallback onStart;

  static const _gold = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          top: BorderSide(color: _gold.withValues(alpha: 0.18)),
        ),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Your hat is waiting!',
            style: TextStyle(
              color: _gold,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Complete the Lesson 1 challenge to unlock your Explorer cap and level up your avatar.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 13,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.bolt_rounded, size: 20),
              label: const Text(
                'Start the Challenge',
                style:
                    TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
