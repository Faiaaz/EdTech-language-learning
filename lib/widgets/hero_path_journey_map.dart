import 'package:flutter/material.dart';

import 'package:ez_trainz/models/journey_stage.dart';

/// Sophisticated S-shaped journey map.
///
/// Renders the three milestones along a smooth cubic-bezier S-curve.
/// Completed segments glow gold; locked segments are dashed and dim.
/// Each milestone has a medallion node with a label on the opposite
/// side of the curve.
class HeroPathJourneyMap extends StatelessWidget {
  const HeroPathJourneyMap({super.key, required this.stage});

  final JourneyStage stage;

  @override
  Widget build(BuildContext context) {
    const stages = [
      _StageMeta(
        stage: JourneyStage.beginning,
        index: 1,
        title: 'The Beginning',
        subtitle: 'Begin your training arc.',
        reward: 'START',
        anchor: Offset(0.18, 0.10),
        labelOnRight: true,
      ),
      _StageMeta(
        stage: JourneyStage.explorersDiscovery,
        index: 2,
        title: "Explorer's Discovery",
        subtitle: 'Earn your first explorer hat.',
        reward: '50 XP',
        anchor: Offset(0.82, 0.50),
        labelOnRight: false,
      ),
      _StageMeta(
        stage: JourneyStage.mastersQuest,
        index: 3,
        title: "Master's Quest",
        subtitle: 'A feather earned in mastery.',
        reward: '150 XP',
        anchor: Offset(0.18, 0.90),
        labelOnRight: true,
      ),
    ];

    final currentIndex =
        stages.indexWhere((s) => s.stage == stage).clamp(0, stages.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR JOURNEY',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 360,
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final h = c.maxHeight;
              final nodes = stages
                  .map((s) =>
                      Offset(s.anchor.dx * w, s.anchor.dy * h))
                  .toList();

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // The S-curve.
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SPathPainter(
                        nodes: nodes,
                        progress: stages.length == 1
                            ? 1.0
                            : currentIndex / (stages.length - 1),
                      ),
                    ),
                  ),
                  // Labels.
                  for (var i = 0; i < stages.length; i++)
                    _PositionedLabel(
                      meta: stages[i],
                      node: nodes[i],
                      width: w,
                      state: i < currentIndex
                          ? _NodeState.complete
                          : (i == currentIndex
                              ? _NodeState.current
                              : _NodeState.locked),
                    ),
                  // Medallion nodes (drawn last so they sit on top of the curve).
                  for (var i = 0; i < stages.length; i++)
                    Positioned(
                      left: nodes[i].dx - 18,
                      top: nodes[i].dy - 18,
                      child: _Node(
                        state: i < currentIndex
                            ? _NodeState.complete
                            : (i == currentIndex
                                ? _NodeState.current
                                : _NodeState.locked),
                        index: stages[i].index,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StageMeta {
  const _StageMeta({
    required this.stage,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.anchor,
    required this.labelOnRight,
  });
  final JourneyStage stage;
  final int index;
  final String title;
  final String subtitle;
  final String reward;

  /// Normalized position [0..1] within the S-curve canvas.
  final Offset anchor;

  /// Whether the label is placed to the right of the node.
  final bool labelOnRight;
}

enum _NodeState { complete, current, locked }

// ── S-path painter ───────────────────────────────────────────────────────────

class _SPathPainter extends CustomPainter {
  _SPathPainter({required this.nodes, required this.progress});

  final List<Offset> nodes;

  /// Fraction of the path that is "completed/active" [0..1].
  final double progress;

  static const _gold = Color(0xFFFFE000);

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.length < 2) return;

    final fullPath = _buildPath(size);

    // Locked (dashed) base.
    final basePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    _drawDashed(canvas, fullPath, basePaint, dashWidth: 6, gap: 9);

    if (progress <= 0) return;

    // Active sub-path (extract by length).
    final metrics = fullPath.computeMetrics().toList();
    final totalLen = metrics.fold<double>(0, (a, m) => a + m.length);
    final targetLen = totalLen * progress.clamp(0.0, 1.0);

    final active = Path();
    double consumed = 0;
    for (final m in metrics) {
      final remaining = targetLen - consumed;
      if (remaining <= 0) break;
      final take = remaining < m.length ? remaining : m.length;
      active.addPath(m.extractPath(0, take), Offset.zero);
      consumed += take;
    }

    // Soft halo behind the active line.
    final haloPaint = Paint()
      ..color = _gold.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(active, haloPaint);

    // The active gold line (gradient along its bounds).
    final bounds = active.getBounds();
    final activePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF8B8), _gold, Color(0xFFB45309)],
      ).createShader(
        bounds.isEmpty
            ? Rect.fromLTWH(0, 0, size.width, size.height)
            : bounds,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(active, activePaint);
  }

  Path _buildPath(Size size) {
    final p = Path()..moveTo(nodes[0].dx, nodes[0].dy);
    final w = size.width;

    for (var i = 0; i < nodes.length - 1; i++) {
      final from = nodes[i];
      final to = nodes[i + 1];
      // Alternate the bulge direction to create the S.
      // i even → bulge to the right, i odd → bulge to the left.
      final bulge = i.isEven ? 1.0 : -1.0;
      final cx1 = from.dx + bulge * w * 0.55;
      final cx2 = to.dx + bulge * w * 0.55;
      p.cubicTo(cx1, from.dy, cx2, to.dy, to.dx, to.dy);
    }
    return p;
  }

  void _drawDashed(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashWidth,
    required double gap,
  }) {
    for (final m in path.computeMetrics()) {
      double dist = 0;
      while (dist < m.length) {
        final end = (dist + dashWidth).clamp(0.0, m.length);
        canvas.drawPath(m.extractPath(dist, end), paint);
        dist = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SPathPainter old) =>
      old.progress != progress || old.nodes != nodes;
}

// ── Medallion node ───────────────────────────────────────────────────────────

class _Node extends StatelessWidget {
  const _Node({required this.state, required this.index});

  final _NodeState state;
  final int index;

  static const _gold = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    final isCurrent = state == _NodeState.current;
    final isLocked = state == _NodeState.locked;
    final isComplete = state == _NodeState.complete;

    final ring = isLocked
        ? Colors.white.withValues(alpha: 0.20)
        : (isCurrent ? _gold : _gold.withValues(alpha: 0.65));
    final core = isLocked
        ? Colors.transparent
        : (isCurrent ? _gold : _gold.withValues(alpha: 0.30));

    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isCurrent)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _gold.withValues(alpha: 0.50),
                    _gold.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0F172A),
              border: Border.all(color: ring, width: 1.8),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: _gold.withValues(alpha: 0.45),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: isComplete
                ? const Icon(Icons.check_rounded,
                    size: 14, color: _gold)
                : (isLocked
                    ? Icon(Icons.lock_rounded,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.35))
                    : Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: core,
                        ),
                      )),
          ),
          // Tiny step number ribbon under the node.
          Positioned(
            bottom: -2,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: ring.withValues(alpha: 0.6),
                  width: 0.8,
                ),
              ),
              child: Text(
                index.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: ring,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Positioned label next to a node ──────────────────────────────────────────

class _PositionedLabel extends StatelessWidget {
  const _PositionedLabel({
    required this.meta,
    required this.node,
    required this.width,
    required this.state,
  });

  final _StageMeta meta;
  final Offset node;
  final double width;
  final _NodeState state;

  @override
  Widget build(BuildContext context) {
    const labelWidth = 165.0;
    const margin = 28.0;
    final left = meta.labelOnRight
        ? (node.dx + margin)
        : (node.dx - margin - labelWidth);
    final top = node.dy - 28;

    return Positioned(
      left: left,
      top: top,
      width: labelWidth,
      child: _NodeLabel(
        meta: meta,
        state: state,
        alignRight: !meta.labelOnRight,
      ),
    );
  }
}

class _NodeLabel extends StatelessWidget {
  const _NodeLabel({
    required this.meta,
    required this.state,
    required this.alignRight,
  });

  final _StageMeta meta;
  final _NodeState state;
  final bool alignRight;

  static const _gold = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    final isCurrent = state == _NodeState.current;
    final isLocked = state == _NodeState.locked;
    final titleColor =
        isLocked ? Colors.white.withValues(alpha: 0.42) : Colors.white;
    final subtitleColor = isLocked
        ? Colors.white.withValues(alpha: 0.20)
        : Colors.white.withValues(alpha: 0.55);

    final cross =
        alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = alignRight ? TextAlign.right : TextAlign.left;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: cross,
      children: [
        if (isCurrent)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _gold,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'CURRENT CHAPTER',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ),
        Text(
          meta.title,
          textAlign: textAlign,
          style: TextStyle(
            color: titleColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          meta.subtitle,
          textAlign: textAlign,
          style: TextStyle(
            color: subtitleColor,
            fontSize: 11.5,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isCurrent
                ? _gold.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isCurrent
                  ? _gold.withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Text(
            meta.reward,
            style: TextStyle(
              color: isCurrent
                  ? _gold
                  : Colors.white.withValues(alpha: 0.55),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
