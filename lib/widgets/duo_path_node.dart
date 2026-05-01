import 'package:flutter/material.dart';

/// Visual state of a Duolingo-style lesson node.
enum DuoNodeState { locked, active, completed, checkpoint }

/// Circular 3D-shadow lesson button used along the path.
class DuoPathNode extends StatelessWidget {
  const DuoPathNode({
    super.key,
    required this.state,
    required this.icon,
    this.size = 78,
    this.onTap,
    this.tint,
  });

  final DuoNodeState state;
  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  /// Override the auto-resolved fill color (used for checkpoints).
  final Color? tint;

  static const _yellow       = Color(0xFFFFE000);
  static const _yellowShadow = Color(0xFFB89800);
  static const _green        = Color(0xFF22C55E);
  static const _greenShadow  = Color(0xFF15803D);
  static const _grey         = Color(0xFF475569);
  static const _greyShadow   = Color(0xFF1E293B);
  static const _purple       = Color(0xFF8B5CF6);
  static const _purpleShadow = Color(0xFF6D28D9);

  Color get _fill => switch (state) {
        DuoNodeState.locked     => _grey,
        DuoNodeState.active     => tint ?? _yellow,
        DuoNodeState.completed  => _green,
        DuoNodeState.checkpoint => tint ?? _purple,
      };

  Color get _shadow => switch (state) {
        DuoNodeState.locked     => _greyShadow,
        DuoNodeState.active     => tint == null ? _yellowShadow : _darken(tint!),
        DuoNodeState.completed  => _greenShadow,
        DuoNodeState.checkpoint => tint == null ? _purpleShadow : _darken(tint!),
      };

  Color get _iconColor =>
      state == DuoNodeState.locked ? const Color(0xFF94A3B8) : Colors.white;

  static Color _darken(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - 0.18).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final s = size;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: s,
        height: s + 8,
        child: Stack(
          children: [
            // 3D shadow ring (lower disc)
            Positioned(
              left: 0,
              right: 0,
              top: 8,
              child: Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  color: _shadow,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Top button
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  color: _fill,
                  shape: BoxShape.circle,
                  border: Border.all(color: _shadow, width: 2),
                ),
                child: Icon(icon, size: s * 0.45, color: _iconColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating "START" callout bubble that sits above the active node.
class DuoStartBadge extends StatelessWidget {
  const DuoStartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Text(
            'START',
            style: TextStyle(
              color: Color(0xFFFFE000),
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 1.5,
            ),
          ),
        ),
        // Small downward arrow
        ClipPath(
          clipper: _DownArrowClipper(),
          child: Container(width: 14, height: 7, color: Colors.white),
        ),
      ],
    );
  }
}

class _DownArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
