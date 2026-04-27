import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/lightning_streak_controller.dart';

class LightningStreakBar extends StatelessWidget {
  const LightningStreakBar({
    super.key,
    required this.progress,
    required this.hearts,
    this.onClose,
  });

  final double progress; // 0..1
  final int hearts;
  final VoidCallback? onClose;

  static const _track = Color(0xFF2D3A40);
  static const _fill = Color(0xFFFFB020); // Duolingo-ish orange
  static const _pillBg = Color(0xFF16252C);
  static const _pillBorder = Color(0xFF2B3B43);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Row(
          children: [
            _IconChip(
              icon: Icons.close_rounded,
              onTap: onClose,
              tooltip: 'Close',
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: _LightningProgressBar(progress: progress),
              ),
            ),
            const SizedBox(width: 10),
            Obx(() {
              final s = LightningStreakController.to.streak.value;
              return _Pill(
                icon: Icons.bolt_rounded,
                color: const Color(0xFFA3FF12),
                label: '$s',
              );
            }),
            const SizedBox(width: 10),
            _Pill(
              icon: Icons.favorite_rounded,
              color: const Color(0xFFFF4D6D),
              label: '$hearts',
            ),
          ],
        ),
      ),
    );
  }
}

class _LightningProgressBar extends StatefulWidget {
  const _LightningProgressBar({required this.progress});
  final double progress;

  @override
  State<_LightningProgressBar> createState() => _LightningProgressBarState();
}

class _LightningProgressBarState extends State<_LightningProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.progress.clamp(0.0, 1.0);
    return Container(
      height: 12,
      color: LightningStreakBar._track,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final boltX = w * 0.5;
          return Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: p,
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (context, _) {
                      final t = _c.value;
                      // A subtle moving highlight to give “electric” feel.
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(-1 + t * 2, 0),
                            end: Alignment(1 + t * 2, 0),
                            colors: [
                              LightningStreakBar._fill,
                              Color.lerp(LightningStreakBar._fill, Colors.white, 0.30)!,
                              LightningStreakBar._fill,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: LightningStreakBar._fill.withValues(alpha: 0.35),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Lightning strike marker when crossing halfway.
              if (p >= 0.5)
                Positioned(
                  left: boltX - 7,
                  top: -7,
                  child: Container(
                    width: 14,
                    height: 26,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.bolt_rounded,
                      size: 18,
                      color: const Color(0xFFA3FF12),
                      shadows: [
                        Shadow(
                          color: const Color(0xFFA3FF12).withValues(alpha: 0.55),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.color, required this.label});
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: LightningStreakBar._pillBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: LightningStreakBar._pillBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.onTap, this.tooltip});
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF16252C),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF2B3B43)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
    if (tooltip == null) return child;
    return Tooltip(message: tooltip!, child: child);
  }
}

