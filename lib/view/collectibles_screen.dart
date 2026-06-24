import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/collectibles_controller.dart';
import 'package:ez_trainz/widgets/tree_shadow.dart';

class CollectiblesScreen extends StatefulWidget {
  const CollectiblesScreen({super.key});

  @override
  State<CollectiblesScreen> createState() => _CollectiblesScreenState();
}

class _CollectiblesScreenState extends State<CollectiblesScreen>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFF0B1326);
  static const _gold = Color(0xFFFFE000);

  late final AnimationController _sway;
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _sway = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _sway.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = CollectiblesController.to;
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          const TreeShadow(alignment: Alignment.bottomRight),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: math.pi / 2,
              numberOfParticles: 18,
              maxBlastForce: 22,
              minBlastForce: 10,
              gravity: 0.20,
              emissionFrequency: 0.07,
              colors: const [
                Color(0xFFFFE000),
                Color(0xFF3B82F6),
                Color(0xFF10B981),
                Color(0xFF8B5CF6),
                Color(0xFFF59E0B),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'COLLECTIBLES',
                    style: TextStyle(
                      color: _gold,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Grow your tree as you finish lessons.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 13.5,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Obx(() {
                      final leaves = ctrl.leaves;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(22),
                            border:
                                Border.all(color: _gold.withValues(alpha: 0.18)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: _gold.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: _gold.withValues(alpha: 0.35)),
                                    ),
                                    child: const Icon(Icons.park_rounded,
                                        color: _gold, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Your Tree',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                          color:
                                              Colors.white.withValues(alpha: 0.10)),
                                    ),
                                    child: Text(
                                      '${leaves.length} leaf${leaves.length == 1 ? '' : 'es'}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.75),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Expanded(
                                child: _TreeCanvas(
                                  sway: _sway,
                                  leafCount: leaves.length,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (leaves.isEmpty)
                                Text(
                                  'Finish Lesson 1 to earn your first leaf.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.55),
                                    fontSize: 12.5,
                                  ),
                                )
                              else
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Latest: ${leaves.last.toLocal()}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.45),
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _gold,
        foregroundColor: Colors.black87,
        onPressed: () {
          _confetti.play();
        },
        icon: const Icon(Icons.auto_awesome_rounded),
        label: const Text('Celebrate',
            style: TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _TreeCanvas extends StatelessWidget {
  const _TreeCanvas({
    required this.sway,
    required this.leafCount,
  });

  final Animation<double> sway;
  final int leafCount;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sway,
      builder: (_, __) {
        final t = Curves.easeInOut.transform(sway.value);
        final angle = (t - 0.5) * 0.08;
        return Center(
          child: Transform.rotate(
            angle: angle,
            alignment: Alignment.bottomCenter,
            child: CustomPaint(
              size: const Size(280, 300),
              painter: _TreePainter(leafCount: leafCount),
            ),
          ),
        );
      },
    );
  }
}

class _TreePainter extends CustomPainter {
  _TreePainter({required this.leafCount});

  final int leafCount;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ground shadow.
    final ground = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.35),
          Colors.black.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.80, w, h * 0.25));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.52, h * 0.92), width: w * 0.82, height: h * 0.14),
      ground,
    );

    // Trunk.
    final trunk = Paint()
      ..color = const Color(0xFF5B3A1A)
      ..style = PaintingStyle.fill;
    final trunkPath = Path()
      ..moveTo(w * 0.46, h * 0.92)
      ..cubicTo(w * 0.44, h * 0.78, w * 0.46, h * 0.60, w * 0.48, h * 0.46)
      ..cubicTo(w * 0.50, h * 0.30, w * 0.55, h * 0.26, w * 0.56, h * 0.42)
      ..cubicTo(w * 0.58, h * 0.60, w * 0.58, h * 0.78, w * 0.56, h * 0.92)
      ..close();
    canvas.drawPath(trunkPath, trunk);

    // Canopy glow.
    final canopyGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF10B981).withValues(alpha: 0.28),
          const Color(0xFF10B981).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(w * 0.12, h * 0.02, w * 0.80, h * 0.70));
    canvas.drawCircle(Offset(w * 0.55, h * 0.28), w * 0.33, canopyGlow);

    // Canopy.
    final canopy = Paint()..color = const Color(0xFF0EA45A);
    canvas.drawCircle(Offset(w * 0.55, h * 0.26), w * 0.28, canopy);
    canvas.drawCircle(Offset(w * 0.38, h * 0.30), w * 0.22, canopy);
    canvas.drawCircle(Offset(w * 0.70, h * 0.32), w * 0.20, canopy);

    // Leaves collectible icons.
    final leafPaint = Paint()..color = const Color(0xFFFFE000);
    final count = leafCount.clamp(0, 12);
    for (var i = 0; i < count; i++) {
      final a = (i / math.max(1, count)) * math.pi * 1.2 + 0.2;
      final r = w * 0.18 + (i % 3) * 8;
      final cx = w * 0.54 + math.cos(a) * r;
      final cy = h * 0.28 + math.sin(a) * r * 0.75;
      final leaf = Path()
        ..moveTo(cx, cy)
        ..quadraticBezierTo(cx + 8, cy - 10, cx + 16, cy)
        ..quadraticBezierTo(cx + 8, cy + 10, cx, cy)
        ..close();
      canvas.drawPath(leaf, leafPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) =>
      oldDelegate.leafCount != leafCount;
}

