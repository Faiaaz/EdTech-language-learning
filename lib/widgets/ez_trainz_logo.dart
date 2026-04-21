import 'package:flutter/material.dart';

class EzTrainzLogo extends StatelessWidget {
  const EzTrainzLogo({
    super.key,
    this.ezSize = 50,
    this.trainzFontSize = 24,
    this.gap = 10,
  });

  final double ezSize;
  final double trainzFontSize;
  final double gap;

  static const _yellow = Color(0xFFFFE000);
  static const _blue = Color(0xFF1E88E5);
  static const _blueDark = Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    final ezFontSize = ezSize * 0.44;
    final badgeRadius = BorderRadius.circular(ezSize * 0.16);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: ezSize,
          height: ezSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _yellow,
            borderRadius: badgeRadius,
            border: Border.all(color: _blue, width: ezSize * 0.06),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: ezSize * 0.25,
                offset: Offset(0, ezSize * 0.12),
              ),
            ],
          ),
          child: _OutlinedText(
            'EZ',
            fill: _blue,
            stroke: _blueDark,
            strokeWidth: ezSize * 0.055,
            style: TextStyle(
              fontSize: ezFontSize,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: -0.6,
            ),
          ),
        ),
        SizedBox(width: gap),
        _OutlinedText(
          'TRAINZ',
          fill: _blue,
          stroke: _yellow,
          strokeWidth: trainzFontSize * 0.18,
          style: TextStyle(
            fontSize: trainzFontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.3,
            height: 1,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: trainzFontSize * 0.35,
                offset: Offset(0, trainzFontSize * 0.10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OutlinedText extends StatelessWidget {
  const _OutlinedText(
    this.text, {
    required this.fill,
    required this.stroke,
    required this.strokeWidth,
    required this.style,
  });

  final String text;
  final Color fill;
  final Color stroke;
  final double strokeWidth;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = stroke,
          ),
        ),
        Text(
          text,
          style: style.copyWith(color: fill),
        ),
      ],
    );
  }
}

