import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import 'package:ez_trainz/models/avatar_config.dart';
import 'package:ez_trainz/models/hat_tier.dart';

/// Modal-style celebration shown when the user crosses a tier boundary.
///
/// For [HatTier.base] (Explorer unlock), an animated avatar transition
/// plays — avatar without hat → hat materialises on head — to make the
/// hat-obtain moment feel special.
class LevelUpOverlay extends StatefulWidget {
  const LevelUpOverlay({super.key, required this.tier, this.avatarConfig});
  final HatTier tier;

  /// Needed for the hat-reveal animation on the Explorer tier.
  final AvatarConfig? avatarConfig;

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with TickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _cardAnim;
  late final AnimationController _shimmerAnim;

  // For HatTier.base: starts false (no hat shown), flips to true to
  // reveal the hat on the avatar after a short dramatic pause.
  bool _hatRevealed = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _cardAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _shimmerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confetti.play();
      _cardAnim.forward();
      _shimmerAnim.repeat();
    });

    // Dramatic pause before the hat materialises on the avatar.
    if (widget.tier == HatTier.base) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _hatRevealed = true);
      });
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    _cardAnim.dispose();
    _shimmerAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.tier.stripeColor ?? const Color(0xFFFFE000);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Dimmed backdrop
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),
        ),
        // Confetti burst from top-center
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirection: math.pi / 2, // downward
            numberOfParticles: 24,
            maxBlastForce: 22,
            minBlastForce: 8,
            gravity: 0.25,
            emissionFrequency: 0.05,
            colors: const [
              Color(0xFFFFE000),
              Color(0xFF3B82F6),
              Color(0xFF10B981),
              Color(0xFF8B5CF6),
              Color(0xFFEF4444),
              Color(0xFFF59E0B),
            ],
          ),
        ),
        // Card — not using AnimatedBuilder child: optimisation so that
        // setState(_hatRevealed) triggers a rebuild of the card.
        AnimatedBuilder(
          animation: _cardAnim,
          builder: (_, __) {
            final t = Curves.elasticOut.transform(_cardAnim.value);
            return Opacity(
              opacity: _cardAnim.value.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.6 + 0.4 * t,
                child: _RewardCard(
                  tier: widget.tier,
                  accent: accent,
                  shimmer: _shimmerAnim,
                  avatarConfig: widget.avatarConfig,
                  hatRevealed: _hatRevealed,
                  onDismiss: () => Navigator.of(context).maybePop(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.tier,
    required this.accent,
    required this.shimmer,
    required this.onDismiss,
    this.avatarConfig,
    this.hatRevealed = false,
  });

  final HatTier tier;
  final Color accent;
  final Animation<double> shimmer;
  final VoidCallback onDismiss;
  final AvatarConfig? avatarConfig;
  final bool hatRevealed;

  @override
  Widget build(BuildContext context) {
    final showHatReveal = tier == HatTier.base && avatarConfig != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'LEVEL UP',
            style: TextStyle(
              color: accent,
              fontSize: 12,
              letterSpacing: 3,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Level ${tier.level}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tier.label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Hat materialise animation — only for the Explorer (base) tier.
          if (showHatReveal) ...[
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                // Glow halo behind avatar that pulses when hat appears.
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: hatRevealed ? 1.0 : 0.0,
                  child: Container(
                    width: 134,
                    height: 134,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.45),
                          blurRadius: 32,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: Tween<double>(begin: 0.65, end: 1.0).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                    ),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: ClipRRect(
                    key: ValueKey(hatRevealed),
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      hatRevealed
                          ? 'assets/images/girl_avatar_hatted.png'
                          : 'assets/images/girl_avatar_no_hat.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // "Hat get!" badge that pops in when the hat appears.
                if (hatRevealed)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack,
                      builder: (_, v, child) => Transform.scale(
                        scale: v,
                        child: child,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          '🎩 Earned!',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          // Reward plate with shimmer sweep
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 72,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      border: Border.all(color: accent.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        tier.unlockText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: shimmer,
                    builder: (_, __) {
                      return Positioned(
                        left: -80 + shimmer.value * 400,
                        top: 0,
                        bottom: 0,
                        width: 80,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.0),
                                  Colors.white.withValues(alpha: 0.35),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Keep Going',
                style:
                    TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
