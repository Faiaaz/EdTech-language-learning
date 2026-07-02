import 'package:ez_trainz/utils/utils.dart';
import 'package:flutter/material.dart';

class NavCardWidget extends StatefulWidget {
  const NavCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconWidget,
    required this.gradientColors,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget iconWidget;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  @override
  State<NavCardWidget> createState() => _NavCardWidgetState();
}

class _NavCardWidgetState extends State<NavCardWidget> with SingleTickerProviderStateMixin  {
  late AnimationController _scaleCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTapDown: (_) {
        _scaleCtrl.forward();
      },
      onTapUp: (_) {
        _scaleCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _scaleCtrl.reverse();
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(scale: _scale.value, child: child);
        },
        child: Container(
          width: 428.w,
          padding: EdgeInsets.symmetric(horizontal: 20.hp, vertical: 18.vp),
          decoration: BoxDecoration(
            color: ColorUtils.white255,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: ColorUtils.border),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.first.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Flag icon in program-color tinted box ───────────────
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: widget.gradientColors.first.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                alignment: Alignment.center,
                child: widget.iconWidget,
              ),

              SpaceHelperWidget.h(16.w),

              // ── Title + subtitle ────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    TextHelperWidget().headingTextWithoutWidth(
                      text: widget.title,
                      textColor: ColorUtils.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      lineHeight: 1.2,
                    ),

                    SpaceHelperWidget.v(3.h),

                    TextHelperWidget().headingTextWithoutWidth(
                      text: widget.subtitle,
                      textColor: ColorUtils.textMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),

                  ],
                ),
              ),

              // ── Arrow ──────────────────────────────────────
              Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: widget.gradientColors.first.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: widget.gradientColors.first,
                  size: 18.r,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
