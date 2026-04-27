import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/journey_controller.dart';
import 'package:ez_trainz/models/avatar_config.dart';
import 'package:ez_trainz/models/hat_tier.dart';
import 'package:ez_trainz/screens/journey_screen.dart';
import 'package:ez_trainz/widgets/layered_avatar.dart';

/// Welcome screen that introduces the Explorer character and kicks off the
/// XP journey. Since the avatar art is fixed, there is no per-user styling
/// step — one tap and you're in.
class AvatarOnboardingScreen extends StatefulWidget {
  const AvatarOnboardingScreen({super.key});

  @override
  State<AvatarOnboardingScreen> createState() => _AvatarOnboardingScreenState();
}

class _AvatarOnboardingScreenState extends State<AvatarOnboardingScreen>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFF0F172A);
  static const _accent = Color(0xFFFFE000);

  late final AnimationController _popAnim;

  @override
  void initState() {
    super.initState();
    _popAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();
  }

  @override
  void dispose() {
    _popAnim.dispose();
    super.dispose();
  }

  Future<void> _onStart() async {
    await JourneyController.to.setAvatar(AvatarConfig.defaults);
    if (!mounted) return;
    Get.offAll(() => const JourneyScreen(showOnboardCelebration: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _onStart,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Meet your Explorer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Earn XP from quizzes, games, and lessons to level up and '
                'unlock gear for your explorer.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _popAnim,
                    builder: (_, child) {
                      final t = Curves.elasticOut.transform(_popAnim.value);
                      return Transform.scale(
                        scale: 0.7 + 0.3 * t,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            _accent.withValues(alpha: 0.18),
                            _accent.withValues(alpha: 0.0),
                          ],
                          radius: 0.9,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const LayeredAvatar(
                        config: AvatarConfig.defaults,
                        tier: HatTier.none,
                        size: 220,
                        showHatGear: false,
                      ),
                    ),
                  ),
                ),
              ),
              const _ProgressionPreview(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Start my journey',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressionPreview extends StatelessWidget {
  const _ProgressionPreview();

  @override
  Widget build(BuildContext context) {
    final steps = [
      (Icons.emoji_events_rounded, 'Earn XP', const Color(0xFFFFE000)),
      (Icons.auto_awesome_rounded, 'Unlock gear', const Color(0xFF4DA6E8)),
      (Icons.military_tech_rounded, 'Master rank', const Color(0xFF10B981)),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final (icon, label, color) in steps)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: color.withValues(alpha: 0.55)),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
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
