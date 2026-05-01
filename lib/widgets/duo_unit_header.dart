import 'package:flutter/material.dart';

/// Big colored unit-banner card that sits above each section of the path.
class DuoUnitHeader extends StatelessWidget {
  const DuoUnitHeader({
    super.key,
    required this.section,
    required this.unit,
    required this.title,
    required this.color,
    this.onGuidebook,
  });

  final int section;
  final int unit;
  final String title;
  final Color color;
  final VoidCallback? onGuidebook;

  Color get _shadow {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.16).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 18),
      decoration: BoxDecoration(
        color: _shadow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.fromLTRB(20, 16, 14, 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SECTION $section, UNIT $unit',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onGuidebook,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.45), width: 1.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu_book_rounded,
                        color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'GUIDE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
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

/// Thin "SECTION X" divider with mascot peeking from the side.
class DuoSectionDivider extends StatelessWidget {
  const DuoSectionDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          const Expanded(
            child: Divider(color: Color(0xFF334155), thickness: 1.2),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Divider(color: Color(0xFF334155), thickness: 1.2),
          ),
        ],
      ),
    );
  }
}
