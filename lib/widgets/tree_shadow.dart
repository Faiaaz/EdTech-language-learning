import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// A subtle blurred \"tree shadow\" silhouette used as atmospheric background.
class TreeShadow extends StatelessWidget {
  const TreeShadow({super.key, this.alignment = Alignment.bottomRight});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.28,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: CustomPaint(
              size: const Size(340, 420),
              painter: _TreeShadowPainter(),
            ),
          ),
        ),
      ),
    );
  }
}

class _TreeShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final trunkPaint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final canopyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF000000).withValues(alpha: 0.55),
          const Color(0xFF000000).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Canopy blobs.
    final canopy = Path()
      ..addOval(Rect.fromCircle(center: Offset(w * 0.62, h * 0.30), radius: w * 0.26))
      ..addOval(Rect.fromCircle(center: Offset(w * 0.44, h * 0.33), radius: w * 0.22))
      ..addOval(Rect.fromCircle(center: Offset(w * 0.56, h * 0.18), radius: w * 0.20))
      ..addOval(Rect.fromCircle(center: Offset(w * 0.70, h * 0.22), radius: w * 0.19));
    canvas.drawPath(canopy, canopyPaint);

    // Trunk.
    final trunk = Path()
      ..moveTo(w * 0.58, h * 0.48)
      ..cubicTo(w * 0.54, h * 0.62, w * 0.56, h * 0.80, w * 0.52, h * 0.96)
      ..lineTo(w * 0.66, h * 0.96)
      ..cubicTo(w * 0.64, h * 0.78, w * 0.66, h * 0.62, w * 0.64, h * 0.48)
      ..close();
    canvas.drawPath(trunk, trunkPaint);

    // Ground shadow.
    final ground = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF000000).withValues(alpha: 0.32),
          const Color(0xFF000000).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(w * 0.20, h * 0.82, w * 0.80, h * 0.22));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.64, h * 0.94), width: w * 0.78, height: h * 0.12),
      ground,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

