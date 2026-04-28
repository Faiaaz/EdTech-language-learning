import 'package:flutter/material.dart';

/// Winding 3-node journey map matching the Hero's Path design.
///
/// [activeIndex] sets the current chapter:
///   0 = The Beginning (game not yet started)
///   1 = Explorer's Discovery (hat just earned)
///   2 = Master's Quest
class JourneyMapWidget extends StatefulWidget {
  const JourneyMapWidget({super.key, required this.activeIndex});
  final int activeIndex;

  @override
  State<JourneyMapWidget> createState() => _JourneyMapWidgetState();
}

class _JourneyMapWidgetState extends State<JourneyMapWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final w = constraints.maxWidth;
      const h = 340.0;

      // Node centre coordinates — create the S-curve layout
      final pos = [
        Offset(w * 0.42, 55),   // The Beginning
        Offset(w * 0.60, 178),  // Explorer's Discovery
        Offset(w * 0.36, 296),  // Master's Quest
      ];

      return SizedBox(
        height: h,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) => Stack(
            clipBehavior: Clip.none,
            children: [
              // Winding path beneath nodes
              CustomPaint(
                size: Size(w, h),
                painter: _PathPainter(
                  positions: pos,
                  activeIndex: widget.activeIndex,
                ),
              ),
              // Nodes
              for (int i = 0; i < 3; i++)
                _NodeOverlay(
                  position: pos[i],
                  nodeIndex: i,
                  activeIndex: widget.activeIndex,
                  pulseT: _pulse.value,
                  titles: const [
                    'The Beginning',
                    "Explorer's Discovery",
                    "Master's Quest",
                  ],
                  icons: const [
                    Icons.person_rounded,
                    Icons.explore_rounded,
                    Icons.auto_awesome_rounded,
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Path painter ─────────────────────────────────────────────────────────────

class _PathPainter extends CustomPainter {
  const _PathPainter({required this.positions, required this.activeIndex});

  final List<Offset> positions;
  final int activeIndex;

  static const _gold = Color(0xFFFFE000);

  @override
  void paint(Canvas canvas, Size size) {
    for (int seg = 0; seg < 2; seg++) {
      final path = _buildCurve(seg);
      final completed = seg < activeIndex;

      if (completed) {
        canvas.drawPath(
          path,
          Paint()
            ..color = _gold
            ..strokeWidth = 5
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      } else {
        _drawDashed(
          canvas,
          path,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.22)
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  // Quadratic bezier that alternates bow direction to create the S-curve.
  Path _buildCurve(int segIndex) {
    final from = positions[segIndex];
    final to = positions[segIndex + 1];
    final midY = (from.dy + to.dy) / 2;

    // Segment 0 bows RIGHT, segment 1 bows LEFT.
    final controlX = segIndex == 0
        ? positions[1].dx + 58
        : positions[2].dx - 58;

    return Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(controlX, midY, to.dx, to.dy);
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint,
      {double dash = 8, double gap = 7}) {
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final end = (dist + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, end), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_PathPainter old) => old.activeIndex != activeIndex;
}

// ── Node overlay ─────────────────────────────────────────────────────────────

class _NodeOverlay extends StatelessWidget {
  const _NodeOverlay({
    required this.position,
    required this.nodeIndex,
    required this.activeIndex,
    required this.pulseT,
    required this.titles,
    required this.icons,
  });

  final Offset position;
  final int nodeIndex;
  final int activeIndex;
  final double pulseT;
  final List<String> titles;
  final List<IconData> icons;

  static const _gold = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    final isActive = nodeIndex == activeIndex;
    final isCompleted = nodeIndex < activeIndex;

    const activeSize = 58.0;
    const inactiveSize = 40.0;
    final nodeSize = isActive ? activeSize : inactiveSize;
    // Outer glow envelope (for Positioned alignment)
    final envelope = isActive ? activeSize + 30.0 : inactiveSize;

    return Positioned(
      // Centre the envelope on position
      left: position.dx - envelope / 2,
      top: position.dy - envelope / 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: envelope,
            height: envelope,
            child: isActive
                ? _ActiveNode(
                    size: nodeSize,
                    icon: icons[nodeIndex],
                    pulseT: pulseT,
                  )
                : Center(
                    child: _InactiveNode(
                      size: nodeSize,
                      isCompleted: isCompleted,
                      icon: icons[nodeIndex],
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          if (isActive) ...[
            Text(
              titles[nodeIndex],
              style: const TextStyle(
                color: _gold,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'CURRENT CHAPTER',
              style: TextStyle(
                color: _gold.withValues(alpha: 0.65),
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 1.3,
              ),
            ),
          ] else
            Text(
              titles[nodeIndex],
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    Colors.white.withValues(alpha: isCompleted ? 0.65 : 0.32),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActiveNode extends StatelessWidget {
  const _ActiveNode({
    required this.size,
    required this.icon,
    required this.pulseT,
  });

  final double size;
  final IconData icon;
  final double pulseT;

  static const _gold = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeInOut.transform(pulseT);
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outermost pulsing ring
        Container(
          width: size + 30,
          height: size + 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _gold.withValues(alpha: 0.06 + 0.06 * t),
          ),
        ),
        // Mid pulsing ring
        Container(
          width: size + 16,
          height: size + 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _gold.withValues(alpha: 0.12 + 0.08 * t),
          ),
        ),
        // Inner solid node
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _gold,
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.5 + 0.2 * t),
                blurRadius: 18 + 6 * t,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.black87, size: 26),
        ),
      ],
    );
  }
}

class _InactiveNode extends StatelessWidget {
  const _InactiveNode({
    required this.size,
    required this.isCompleted,
    required this.icon,
  });

  final double size;
  final bool isCompleted;
  final IconData icon;

  static const _gold = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? _gold.withValues(alpha: 0.18)
            : Colors.transparent,
        border: Border.all(
          color: isCompleted
              ? _gold.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.22),
          width: isCompleted ? 2 : 1.5,
        ),
      ),
      child: Icon(
        isCompleted ? Icons.check_rounded : Icons.lock_rounded,
        color: isCompleted
            ? _gold.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.28),
        size: isCompleted ? 20 : 16,
      ),
    );
  }
}
