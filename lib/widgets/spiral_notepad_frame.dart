import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Decorative spiral-bound notepad shell for drawing surfaces.
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

  static const _bindingWidth = 46.0;
  static const _pageInsetLeft = 24.0;
  static const _pageTopInset = 8.0;

  int get _ringCount =>
      ((pageHeight - _pageTopInset - 24) / 34).round().clamp(12, 18);

  @override
  Widget build(BuildContext context) {
    final totalW = pageWidth + _pageInsetLeft + 12;
    final totalH = pageHeight + _pageTopInset + 6;
    final rings = _ringCount;

    return Center(
      child: SizedBox(
        width: totalW,
        height: totalH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: _pageInsetLeft,
              top: _pageTopInset,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _paper,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                    bottomLeft: Radius.circular(3),
                  ),
                  border: Border.all(color: _paperEdge, width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.32),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                    bottomLeft: Radius.circular(2),
                  ),
                  child: child,
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: _bindingWidth,
              child: CustomPaint(
                painter: _SpiralBindingPainter(
                  pageHeight: totalH,
                  pageTop: _pageTopInset,
                  ringCount: rings,
                ),
              ),
            ),
            Positioned(
              left: _pageInsetLeft - 2,
              top: _pageTopInset - 2,
              child: CustomPaint(
                size: Size(14, totalH - _pageTopInset + 2),
                painter: _PunchHolesPainter(
                  ringCount: rings,
                  pageTop: _pageTopInset,
                  pageHeight: totalH,
                ),
              ),
            ),
            Positioned(
              left: _pageInsetLeft + 4,
              top: 2,
              child: Container(
                width: pageWidth - 4,
                height: 10,
                decoration: BoxDecoration(
                  color: _paper.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Perforation holes where coils pass through the paper edge.
class _PunchHolesPainter extends CustomPainter {
  const _PunchHolesPainter({
    required this.ringCount,
    required this.pageTop,
    required this.pageHeight,
  });

  final int ringCount;
  final double pageTop;
  final double pageHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final spacing = (pageHeight - pageTop - 36) / (ringCount - 1);
    final holePaint = Paint()..color = const Color(0xFFCBD5E1).withValues(alpha: 0.55);
    final innerPaint = Paint()..color = const Color(0xFF94A3B8).withValues(alpha: 0.35);

    for (var i = 0; i < ringCount; i++) {
      final cy = pageTop + 18 + spacing * i;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(10, cy), width: 10, height: 10),
        -math.pi / 2,
        math.pi,
        false,
        holePaint..strokeWidth = 2.2..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(Offset(10, cy), 2.2, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PunchHolesPainter oldDelegate) => false;
}

class _SpiralBindingPainter extends CustomPainter {
  const _SpiralBindingPainter({
    required this.pageHeight,
    required this.pageTop,
    required this.ringCount,
  });

  final double pageHeight;
  final double pageTop;
  final int ringCount;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBindingStrip(canvas, size);

    final spacing = (pageHeight - pageTop - 36) / (ringCount - 1);
    for (var i = 0; i < ringCount; i++) {
      final cy = pageTop + 18 + spacing * i;
      _drawCoil(canvas, Offset(22, cy), i);
    }
  }

  void _drawBindingStrip(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(6, pageTop - 2, 28, pageHeight - pageTop + 4),
      const Radius.circular(5),
    );

    final stripPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(6, 0),
        Offset(34, 0),
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
      Rect.fromCenter(center: center + const Offset(4, -1.2), width: coilW, height: coilH * 0.7),
      math.pi * 0.25,
      math.pi * 0.85,
      false,
      highlight,
    );

    // Inner hole ring.
    final hole = Paint()
      ..color = const Color(0xFF64748B).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center + const Offset(6, 0), 2.6, hole);

    // Subtle wire connector to next coil (every other for visual rhythm).
    if (index < ringCount - 1) {
      final nextY = center.dy +
          (pageHeight - pageTop - 36) / (ringCount - 1);
      final wire = Paint()
        ..color = const Color(0xFF94A3B8).withValues(alpha: 0.45)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center + const Offset(-4, coilH * 0.35),
        Offset(center.dx - 4, nextY - coilH * 0.35),
        wire,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpiralBindingPainter oldDelegate) => false;
}
