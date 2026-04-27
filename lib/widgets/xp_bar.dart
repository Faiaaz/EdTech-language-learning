import 'package:flutter/material.dart';

/// Thin animated XP bar. Shows progress within the current tier with a
/// soft glow, current/next XP labels, and the tier label on the left.
class XpBar extends StatelessWidget {
  const XpBar({
    super.key,
    required this.progress,
    required this.tierLabel,
    required this.xpInto,
    required this.xpSpan,
    this.accent = const Color(0xFFFFE000),
  });

  /// 0..1 within the current tier.
  final double progress;
  final String tierLabel;
  final int xpInto;

  /// Total XP to go from this tier to the next. 0 if at max tier.
  final int xpSpan;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final atMax = xpSpan == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              tierLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              atMax ? 'MAX' : '$xpInto / $xpSpan XP',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (_, c) {
            final fillWidth = c.maxWidth * clamped;
            return Stack(
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  height: 10,
                  width: fillWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withValues(alpha: 0.75)],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.55),
                        blurRadius: 10,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
