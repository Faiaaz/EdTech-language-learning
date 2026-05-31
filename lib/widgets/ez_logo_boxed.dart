import 'package:flutter/material.dart';

class EZLogoBoxed extends StatelessWidget {
  const EZLogoBoxed({
    super.key,
    this.width = 52,
    this.height = 42,
    this.fontSize = 22,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double fontSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF4DA6E8),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Text(
          'EZ',
          style: TextStyle(
            color: const Color(0xFFFFE000),
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            height: 1,
          ),
        ),
      ),
    );
  }
}
