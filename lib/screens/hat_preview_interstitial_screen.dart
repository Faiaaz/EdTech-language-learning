import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/journey_controller.dart';
import 'package:ez_trainz/screens/lesson1_game_flow_screen.dart';

/// Shown right after the Lesson 1 video finishes (or when the user taps
/// "Next"). Displays the hat-preview reference image so the user can see
/// their current avatar state, then funnels them into the game challenge.
class HatPreviewInterstitialScreen extends StatefulWidget {
  const HatPreviewInterstitialScreen({super.key});

  @override
  State<HatPreviewInterstitialScreen> createState() =>
      _HatPreviewInterstitialScreenState();
}

class _HatPreviewInterstitialScreenState
    extends State<HatPreviewInterstitialScreen>
    with SingleTickerProviderStateMixin {
  static const _gold = Color(0xFFFFE000);
  static const _bg = Color(0xFF0B1326);

  late final AnimationController _slideIn;

  @override
  void initState() {
    super.initState();
    // Reset XP so the hat is earned fresh through the game.
    JourneyController.to.resetProgress();
    _slideIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void dispose() {
    _slideIn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white54),
                ),
              ),
            ),
            // Hero image — fills available space, no scrolling
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    'assets/images/stitch_hat_preview.png',
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            // Slide-up text + CTA
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: _slideIn, curve: Curves.easeOutCubic),
              ),
              child: FadeTransition(
                opacity: _slideIn,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Your hat is waiting!',
                        style: TextStyle(
                          color: _gold,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete the Lesson 1 challenge to unlock your Explorer cap and level up your avatar.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13.5,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          // Replace interstitial with the game so back-press
                          // returns to the lesson video, not here.
                          onPressed: () =>
                              Get.off(() => const Lesson1GameFlowScreen()),
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
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 15),
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
    );
  }
}
