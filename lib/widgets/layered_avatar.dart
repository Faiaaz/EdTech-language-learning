import 'package:flutter/material.dart';

import 'package:ez_trainz/models/avatar_config.dart';
import 'package:ez_trainz/models/hat_tier.dart';

/// Renders the Explorer avatar as a stack of PNG layers that reveal the
/// reward progression as the user earns XP:
///
///   tier none     → bare boy (no hat, no feather)
///   tier base     → boy + hat
///   tier feather  → + white feather tucked in
///   tier stripe 1 → + green base band colored (soft glow)
///   tier stripe 2 → + blue band
///   tier stripe 3 → + purple band
///   tier stripe 4 → + red band
///   tier master   → + gold tip (strongest glow)
///
/// All layer PNGs share a 1024×1024 canvas authored from the same source
/// illustration, so positions align with zero per-asset math.
class LayeredAvatar extends StatelessWidget {
  const LayeredAvatar({
    super.key,
    required this.config,
    required this.tier,
    this.size = 200,
    this.showHatGear = true,
    this.shimmer = false,
  });

  // Kept in the public API for forward compatibility — not currently used.
  // ignore: unused_element
  final AvatarConfig config;

  final HatTier tier;

  /// Rendered width in logical pixels. Height is equal to width (the art
  /// is authored on a square canvas).
  final double size;

  /// Hide earned gear — used by onboarding previews.
  final bool showHatGear;

  /// Brief glow halo played by equip animations.
  final bool shimmer;

  static const _base = 'assets/avatars/base_boy.png';
  static const _hatted = 'assets/avatars/base_boy_hatted.png';
  static const _featherWhite = 'assets/avatars/feather_white.png';

  /// Stripe unlocks in the order the bands reveal (bottom → tip).
  static const _stripeAssets = <HatTier, String>{
    HatTier.stripe1: 'assets/avatars/stripe_1.png',
    HatTier.stripe2: 'assets/avatars/stripe_2.png',
    HatTier.stripe3: 'assets/avatars/stripe_3.png',
    HatTier.stripe4: 'assets/avatars/stripe_4.png',
    HatTier.master: 'assets/avatars/stripe_5.png',
  };

  bool _reached(HatTier required) => tier.index >= required.index;

  @override
  Widget build(BuildContext context) {
    final bool wearingHat = showHatGear && _reached(HatTier.base);
    final bool wearingFeather = showHatGear && _reached(HatTier.feather);

    final layers = <String>[
      wearingHat ? _hatted : _base,
      if (wearingFeather) _featherWhite,
      if (showHatGear)
        for (final entry in _stripeAssets.entries)
          if (_reached(entry.key)) entry.value,
    ];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (shimmer)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.55),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          for (final asset in layers)
            Positioned.fill(
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),
            ),
        ],
      ),
    );
  }
}
