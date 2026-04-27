import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/journey_controller.dart';
import 'package:ez_trainz/models/hat_tier.dart';
import 'package:ez_trainz/screens/lesson1_game_flow_screen.dart';
import 'package:ez_trainz/widgets/layered_avatar.dart';

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
  static const _surface = Color(0xFF111827);

  late final AnimationController _fadeIn;

  @override
  void initState() {
    super.initState();
    JourneyController.to.resetProgress();
    _fadeIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _fadeIn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = JourneyController.to.avatar.value;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
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
                      // Avatar card
                      _AvatarCard(avatar: avatar),

                      const SizedBox(height: 20),

                      // XP bar section
                      const _XpSection(),

                      const SizedBox(height: 28),

                      // Journey path
                      const _JourneyPath(),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),

            // ── Fixed bottom CTA ────────────────────────────────────
            _BottomCard(
              onStart: () => Get.off(() => const Lesson1GameFlowScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar card ─────────────────────────────────────────────────────────────

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({required this.avatar});
  final dynamic avatar;

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
          const SizedBox(height: 20),
          // Avatar — no hat yet
          Center(
            child: LayeredAvatar(
              config: avatar,
              tier: HatTier.none,
              size: 190,
              showHatGear: false,
            ),
          ),
          const SizedBox(height: 10),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR JOURNEY',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _PathNode(
          icon: Icons.person_rounded,
          title: 'The Beginning',
          subtitle: 'Earn XP to start your journey.',
          isActive: true,
          isFirst: true,
          badge: 'NOW',
        ),
        _PathConnector(active: false),
        _PathNode(
          icon: Icons.military_tech_rounded,
          title: "Explorer's Discovery",
          subtitle: 'Earn your first explorer hat.',
          isActive: false,
          trailing: '50 XP',
          highlightTrailing: true,
        ),
        _PathConnector(active: false),
        _PathNode(
          icon: Icons.auto_awesome_rounded,
          title: "Master's Quest",
          subtitle: 'A feather tucked into your hat.',
          isActive: false,
          trailing: '150 XP',
          isLast: true,
        ),
      ],
    );
  }
}

class _PathConnector extends StatelessWidget {
  const _PathConnector({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 21),
      child: CustomPaint(
        size: const Size(2, 32),
        painter: _DashedLinePainter(
          color: active
              ? const Color(0xFFFFE000)
              : Colors.white.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dashH = 4.0;
    const gapH = 4.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
          Offset(size.width / 2, y),
          Offset(size.width / 2, (y + dashH).clamp(0, size.height)),
          paint);
      y += dashH + gapH;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

class _PathNode extends StatelessWidget {
  const _PathNode({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isActive,
    this.isFirst = false,
    this.isLast = false,
    this.badge,
    this.trailing,
    this.highlightTrailing = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isActive;
  final bool isFirst;
  final bool isLast;
  final String? badge;
  final String? trailing;
  final bool highlightTrailing;

  static const _gold = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? _gold.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? _gold.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.07),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? _gold.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.06),
              border: Border.all(
                color: isActive
                    ? _gold.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.12),
                width: 1.5,
              ),
            ),
            child: Icon(
              isActive ? icon : Icons.lock_rounded,
              color: isActive
                  ? _gold
                  : Colors.white.withValues(alpha: 0.25),
              size: isActive ? 22 : 18,
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _gold,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(
                        alpha: isActive ? 0.55 : 0.25),
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          // Trailing XP
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Text(
              trailing!,
              style: TextStyle(
                color: highlightTrailing
                    ? _gold.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.25),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
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
