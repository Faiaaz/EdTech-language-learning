import 'package:flutter/material.dart';

import 'package:ez_trainz/models/hat_tier.dart';

/// Visual ladder of the 7 HatTiers. Past tiers are filled, current is
/// highlighted with a ring, future ones are muted.
class HatProgressionLadder extends StatelessWidget {
  const HatProgressionLadder({
    super.key,
    required this.current,
    required this.totalXp,
  });

  final HatTier current;
  final int totalXp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Master Explorer Path',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            for (final t in HatTier.values)
              _TierRow(
                tier: t,
                unlocked: totalXp >= t.xpRequired,
                isCurrent: t == current,
              ),
          ],
        ),
      ],
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.tier,
    required this.unlocked,
    required this.isCurrent,
  });
  final HatTier tier;
  final bool unlocked;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final accent = tier.stripeColor ?? const Color(0xFFFFE000);
    final bg = unlocked
        ? accent.withValues(alpha: isCurrent ? 0.22 : 0.14)
        : Colors.white.withValues(alpha: 0.06);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: isCurrent
            ? Border.all(color: accent, width: 1.5)
            : Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _TierBadge(tier: tier, unlocked: unlocked),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Lv ${tier.level} · ${tier.label}',
                      style: TextStyle(
                        color: unlocked
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.55),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'NOW',
                          style: TextStyle(
                            color: accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  tier.unlockText,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 11.5,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            tier.xpRequired == 0 ? 'Start' : '${tier.xpRequired}',
            style: TextStyle(
              color: unlocked ? accent : Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier, required this.unlocked});
  final HatTier tier;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final accent = tier.stripeColor ?? const Color(0xFFFFE000);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: unlocked
            ? accent.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.08),
        border: Border.all(
          color: unlocked
              ? accent
              : Colors.white.withValues(alpha: 0.18),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        _iconFor(tier),
        color: unlocked ? accent : Colors.white.withValues(alpha: 0.45),
        size: 18,
      ),
    );
  }

  static IconData _iconFor(HatTier tier) {
    switch (tier) {
      case HatTier.none:
        return Icons.person_rounded;
      case HatTier.base:
        return Icons.military_tech_rounded;
      case HatTier.feather:
        return Icons.auto_awesome;
      case HatTier.stripe1:
      case HatTier.stripe2:
      case HatTier.stripe3:
      case HatTier.stripe4:
        return Icons.local_fire_department_rounded;
      case HatTier.master:
        return Icons.workspace_premium_rounded;
    }
  }
}
