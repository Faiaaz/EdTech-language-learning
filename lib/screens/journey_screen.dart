import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/journey_controller.dart';
import 'package:ez_trainz/models/hat_tier.dart';
import 'package:ez_trainz/models/xp_event.dart';
import 'package:ez_trainz/screens/avatar_onboarding_screen.dart';
import 'package:ez_trainz/widgets/hat_progression_ladder.dart';
import 'package:ez_trainz/widgets/journey_route.dart';
import 'package:ez_trainz/widgets/layered_avatar.dart';
import 'package:ez_trainz/widgets/level_up_overlay.dart';
import 'package:ez_trainz/widgets/xp_bar.dart';

/// Prototype dashboard that demonstrates the full loop:
///   avatar + XP bar + ladder + demo "complete an activity" buttons.
///
/// Showing this screen with `showOnboardCelebration: true` triggers a
/// one-shot Pop & Scale on the avatar — called right after the user
/// finishes picking their avatar.
class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key, this.showOnboardCelebration = false});
  final bool showOnboardCelebration;

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen>
    with TickerProviderStateMixin {
  static const _bg = Color(0xFF0F172A);
  static const _accent = Color(0xFFFFE000);

  late final AnimationController _popAnim;
  late final AnimationController _reactAnim; // avatar "hype" on XP gain
  late final AnimationController _shimmerAnim;

  Worker? _levelUpWorker;

  @override
  void initState() {
    super.initState();
    _popAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _reactAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _shimmerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    if (widget.showOnboardCelebration) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _popAnim.forward());
    } else {
      _popAnim.value = 1.0;
    }

    // First-time users land in onboarding instead of an empty dashboard.
    if (!JourneyController.to.hasOnboarded.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          journeyRoute(const AvatarOnboardingScreen()),
        );
      });
    }

    // Listen for level-ups surfaced by the controller, and play them.
    _levelUpWorker = ever<HatTier?>(JourneyController.to.pendingLevelUp, (t) {
      if (t == null || !mounted) return;
      _shimmerAnim
        ..reset()
        ..forward();
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Level up',
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => LevelUpOverlay(
          tier: t,
          avatarConfig: JourneyController.to.avatar.value,
        ),
        transitionBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          child: child,
        ),
      ).then((_) => JourneyController.to.consumeLevelUp());
    });
  }

  @override
  void dispose() {
    _levelUpWorker?.dispose();
    _popAnim.dispose();
    _reactAnim.dispose();
    _shimmerAnim.dispose();
    super.dispose();
  }

  Future<void> _grant(XpSource source) async {
    _reactAnim
      ..reset()
      ..forward();
    await JourneyController.to.grantXp(source: source);
  }

  @override
  Widget build(BuildContext context) {
    final c = JourneyController.to;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Obx(() {
          final avatar = c.avatar.value;
          final tier = c.tier;
          final total = c.totalXp;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white),
                      ),
                      const Spacer(),
                      const Text(
                        'Your Journey',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            journeyRoute(const AvatarOnboardingScreen()),
                          );
                        },
                        icon: const Icon(Icons.info_outline_rounded,
                            color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: AnimatedBuilder(
                    animation:
                        Listenable.merge([_popAnim, _reactAnim, _shimmerAnim]),
                    builder: (_, child) {
                      final popT = Curves.elasticOut.transform(_popAnim.value);
                      final reactT =
                          Curves.easeOutBack.transform(_reactAnim.value);
                      final scale = (0.7 + 0.3 * popT) *
                          (1.0 + 0.06 * (1 - (reactT - 0.5).abs() * 2));
                      return Transform.translate(
                        offset: Offset(0, -10 * reactT * (1 - reactT)),
                        child: Transform.scale(scale: scale, child: child),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: LayeredAvatar(
                        config: avatar,
                        tier: tier,
                        size: 210,
                        shimmer: _shimmerAnim.isAnimating,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: _accent.withValues(alpha: 0.45)),
                    ),
                    child: Text(
                      'Level ${tier.level} · ${tier.label}',
                      style: const TextStyle(
                        color: _accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
              // Show motivation card at Level 1 before the hat is earned.
              if (tier == HatTier.none)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: _AvatarHatPromptCard(),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: XpBar(
                    progress: c.progressWithinTier,
                    tierLabel: tier.next == null
                        ? 'Master rank reached'
                        : 'Next: ${tier.next!.label}',
                    xpInto: c.xpIntoTier,
                    xpSpan: c.xpForTierSpan,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _DemoActionStrip(
                    totalXp: total,
                    onQuiz: () => _grant(XpSource.quiz),
                    onGame: () => _grant(XpSource.game),
                    onLesson: () => _grant(XpSource.lesson),
                    onReset: () => JourneyController.to.resetProgress(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: HatProgressionLadder(
                    current: tier,
                    totalXp: total,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          );
        }),
      ),
    );
  }
}

class _DemoActionStrip extends StatelessWidget {
  const _DemoActionStrip({
    required this.totalXp,
    required this.onQuiz,
    required this.onGame,
    required this.onLesson,
    required this.onReset,
  });

  final int totalXp;
  final VoidCallback onQuiz;
  final VoidCallback onGame;
  final VoidCallback onLesson;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on_rounded,
                  color: Color(0xFFFFE000), size: 18),
              const SizedBox(width: 6),
              const Text(
                'Try the XP loop',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                '$totalXp XP',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(
                  icon: Icons.quiz_rounded,
                  label: 'Quiz +50',
                  color: const Color(0xFF3B82F6),
                  onTap: onQuiz),
              _pill(
                  icon: Icons.sports_esports_rounded,
                  label: 'Game +75',
                  color: const Color(0xFF10B981),
                  onTap: onGame),
              _pill(
                  icon: Icons.menu_book_rounded,
                  label: 'Lesson +40',
                  color: const Color(0xFF8B5CF6),
                  onTap: onLesson),
              _pill(
                  icon: Icons.restart_alt_rounded,
                  label: 'Reset',
                  color: Colors.white24,
                  outlined: true,
                  onTap: onReset),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: outlined
              ? Colors.transparent
              : color.withValues(alpha: 0.2),
          border: Border.all(
              color: outlined ? Colors.white38 : color.withValues(alpha: 0.55)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: outlined ? Colors.white70 : color.withAlpha(255)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: outlined ? Colors.white70 : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Motivational card shown when the user is at Level 1 (no hat yet).
/// Pulses with a golden glow to draw attention to the upgrade path.
class _AvatarHatPromptCard extends StatefulWidget {
  const _AvatarHatPromptCard();

  @override
  State<_AvatarHatPromptCard> createState() => _AvatarHatPromptCardState();
}

class _AvatarHatPromptCardState extends State<_AvatarHatPromptCard>
    with SingleTickerProviderStateMixin {
  static const _gold = Color(0xFFFFE000);

  late final AnimationController _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) {
        final t = Curves.easeInOut.transform(_pulseAnim.value);
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2235),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _gold.withValues(alpha: 0.22 + 0.28 * t),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.06 + 0.10 * t),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: _gold.withValues(alpha: 0.38)),
            ),
            child: const Icon(
              Icons.military_tech_rounded,
              color: _gold,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This is your avatar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enhance your avatar by finishing the Lesson 1 challenge',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 12.5,
                    height: 1.38,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: _gold,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
