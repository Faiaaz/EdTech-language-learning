import 'package:flutter/material.dart';

/// Visual reward tier earned by accumulating XP. The order here is the
/// on-screen progression ladder:
/// 1. Novice (no gear) -> 2. Base Hat -> 3. Feather -> 4-7. Four
/// colored stripes -> 8. Master (final glowing gold stripe).
enum HatTier {
  none(
    level: 1,
    xpRequired: 0,
    label: 'Novice',
    unlockText:
        'Earn XP from quizzes, games, and lessons to unlock your first hat.',
    stripeColor: null,
  ),
  base(
    level: 2,
    xpRequired: 50,
    label: 'Explorer',
    unlockText: 'First milestone! You just earned your explorer cap.',
    stripeColor: null,
  ),
  feather(
    level: 3,
    xpRequired: 150,
    label: 'First Quest',
    unlockText: 'A feather is tucked into your hat for your first quest.',
    stripeColor: null,
  ),
  stripe1(
    level: 4,
    xpRequired: 300,
    label: 'Milestone I',
    unlockText: 'Finish a skill milestone. Earn a blue stripe.',
    stripeColor: Color(0xFF3B82F6),
  ),
  stripe2(
    level: 5,
    xpRequired: 600,
    label: 'Milestone II',
    unlockText: 'Second skill milestone. Green stripe.',
    stripeColor: Color(0xFF10B981),
  ),
  stripe3(
    level: 6,
    xpRequired: 1000,
    label: 'Milestone III',
    unlockText: 'Third milestone. Purple stripe.',
    stripeColor: Color(0xFF8B5CF6),
  ),
  stripe4(
    level: 7,
    xpRequired: 1500,
    label: 'Milestone IV',
    unlockText: 'Fourth milestone. Red stripe.',
    stripeColor: Color(0xFFEF4444),
  ),
  master(
    level: 8,
    xpRequired: 2200,
    label: 'Master Explorer',
    unlockText: 'Master rank. Final golden stripe, glowing.',
    stripeColor: Color(0xFFF59E0B),
  );

  const HatTier({
    required this.level,
    required this.xpRequired,
    required this.label,
    required this.unlockText,
    required this.stripeColor,
  });

  final int level;
  final int xpRequired;
  final String label;
  final String unlockText;

  /// Present for stripe tiers (3..7). Null for base and feather.
  final Color? stripeColor;

  /// Which tier corresponds to a given XP amount. At 0 XP the user is
  /// in `HatTier.none` — no gear is rendered on the avatar yet.
  static HatTier fromXp(int xp) {
    HatTier tier = HatTier.none;
    for (final t in HatTier.values) {
      if (xp >= t.xpRequired) tier = t;
    }
    return tier;
  }

  /// The next tier above this one, or null if already at master.
  HatTier? get next {
    final idx = HatTier.values.indexOf(this);
    if (idx + 1 >= HatTier.values.length) return null;
    return HatTier.values[idx + 1];
  }

  /// XP needed to reach [next] from the start of this tier. Used for
  /// drawing the progress bar segment.
  int get xpToNext {
    final n = next;
    if (n == null) return 0;
    return n.xpRequired - xpRequired;
  }
}
