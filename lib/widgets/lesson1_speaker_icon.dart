import 'package:flutter/material.dart';

/// Lesson 1 speaker visual (blue core + yellow ring/icon) to match the
/// provided reference style.
class Lesson1SpeakerIcon extends StatelessWidget {
  const Lesson1SpeakerIcon({
    super.key,
    this.size = 48,
    this.showGlow = true,
  });

  final double size;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final borderWidth = (size * 0.06).clamp(1.2, 3.0);
    final iconSize = size * 0.5;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
        ),
        border: Border.all(
          color: const Color(0xFFFFE000),
          width: borderWidth,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: const Color(0xFF1E40AF).withValues(alpha: 0.28),
                  blurRadius: size * 0.34,
                  spreadRadius: size * 0.02,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          Icons.volume_up_rounded,
          size: iconSize,
          color: const Color(0xFFFFE000),
        ),
      ),
    );
  }
}
