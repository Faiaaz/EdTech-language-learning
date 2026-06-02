import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Spiral-bound notepad shell for drawing surfaces.
///
/// The binding coils run down the page's left edge and are distributed so the
/// first and last coils sit a margin inside the page — they never overflow the
/// top or bottom. There is no stacked "extra page" strip.
class SpiralNotepadFrame extends StatelessWidget {
  const SpiralNotepadFrame({
    super.key,
    required this.child,
    required this.pageWidth,
    required this.pageHeight,
  });

  final Widget child;
  final double pageWidth;
  final double pageHeight;

  static const _paper = Color(0xFFFFFBEB);
  static const _paperEdge = Color(0xFFE7DCC8);

  /// Left edge x of the paper page; coils wrap over this line.
  static const _pageLeft = 28.0;

  /// Vertical inset for the first/last coil so they stay inside the page.
  static const _coilMargin = 24.0;

  int get _ringCount =>
      ((pageHeight - 2 * _coilMargin) / 34).round().clamp(12, 18);

  @override
  Widget build(BuildContext context) {
    final totalW = _pageLeft + pageWidth + 4;
    final totalH = pageHeight;
    final rings = _ringCount;

    return Center(
      child: SizedBox(
        width: totalW,
        height: totalH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Paper page ───────────────────────────────────────────
            Positioned(
              left: _pageLeft,
              top: 0,
              width: pageWidth,
              height: pageHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _paper,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    topLeft: Radius.circular(2),
                    bottomLeft: Radius.circular(2),
                  ),
                  border: Border.all(color: _paperEdge, width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.32),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 6,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(9),
                    bottomRight: Radius.circular(9),
                    topLeft: Radius.circular(1),
                    bottomLeft: Radius.circular(1),
                  ),
                  child: child,
                ),
              ),
            ),

            // ── Spiral binding (coils over the left edge) ────────────
            Positioned(
              left: 0,
              top: 0,
              width: _pageLeft + 18,
              height: pageHeight,
              child: CustomPaint(
                painter: _SpiralBindingPainter(
                  pageHeight: pageHeight,
                  edgeX: _pageLeft,
                  coilMargin: _coilMargin,
                  ringCount: rings,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpiralBindingPainter extends CustomPainter {
  const _SpiralBindingPainter({
    required this.pageHeight,
    required this.edgeX,
    required this.coilMargin,
    required this.ringCount,
  });

  final double pageHeight;
  final double edgeX;
  final double coilMargin;
  final int ringCount;

  double get _spacing =>
      (pageHeight - 2 * coilMargin) / (ringCount - 1);

  @override
  void paint(Canvas canvas, Size size) {
    _drawSpine(canvas);
    for (var i = 0; i < ringCount; i++) {
      final cy = coilMargin + _spacing * i;
      _drawCoil(canvas, Offset(edgeX - 4, cy), i);
    }
  }

  /// Subtle dark spine strip running just left of the page edge.
  void _drawSpine(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 2, edgeX - 6, pageHeight - 4),
      const Radius.circular(5),
    );
    final stripPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(4, 0),
        Offset(edgeX - 2, 0),
        [
          const Color(0xFF1E293B),
          const Color(0xFF334155),
          const Color(0xFF475569),
          const Color(0xFF334155),
        ],
        [0.0, 0.35, 0.65, 1.0],
      );
    canvas.drawRRect(rect, stripPaint);

    final edge = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rect, edge);
  }

  void _drawCoil(Canvas canvas, Offset center, int index) {
    const coilW = 30.0;
    const coilH = 14.0;

    // Drop shadow under the coil.
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(1.5, 2.5),
        width: coilW,
        height: coilH,
      ),
      shadow,
    );

    // Back segment (behind paper) — darker, tighter arc on the left.
    final backRect = Rect.fromCenter(
      center: center + const Offset(-2, 0),
      width: coilW * 0.72,
      height: coilH * 0.85,
    );
    final backPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(backRect.left, backRect.top),
        Offset(backRect.right, backRect.bottom),
        [
          const Color(0xFF64748B),
          const Color(0xFF475569),
        ],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(backRect, math.pi * 0.55, math.pi * 0.95, false, backPaint);

    // Front segment — metallic silver coil wrapping over the page edge.
    final frontRect = Rect.fromCenter(
      center: center + const Offset(4, 0),
      width: coilW,
      height: coilH,
    );
    final frontPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(frontRect.left, frontRect.center.dy - coilH),
        Offset(frontRect.right, frontRect.center.dy + coilH),
        [
          const Color(0xFFE2E8F0),
          const Color(0xFF94A3B8),
          const Color(0xFFF8FAFC),
          const Color(0xFFCBD5E1),
        ],
        [0.0, 0.35, 0.62, 1.0],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(frontRect, math.pi * 0.08, math.pi * 1.55, false, frontPaint);

    // Specular highlight on the front arc.
    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
          center: center + const Offset(4, -1.2), width: coilW, height: coilH * 0.7),
      math.pi * 0.25,
      math.pi * 0.85,
      false,
      highlight,
    );

    // Inner hole ring where the coil threads through the paper.
    final hole = Paint()
      ..color = const Color(0xFF64748B).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center + const Offset(6, 0), 2.6, hole);

    // Wire connector down to the next coil.
    if (index < ringCount - 1) {
      final wire = Paint()
        ..color = const Color(0xFF94A3B8).withValues(alpha: 0.45)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center + const Offset(-4, coilH * 0.35),
        Offset(center.dx - 4, center.dy + _spacing - coilH * 0.35),
        wire,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpiralBindingPainter oldDelegate) =>
      oldDelegate.pageHeight != pageHeight ||
      oldDelegate.ringCount != ringCount;
}
