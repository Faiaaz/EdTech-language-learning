import 'package:flutter/material.dart';

/// EZ TRAINZ wordmark for dark headers (#0F172A background).
class EzTrainzLogoText extends StatelessWidget {
  const EzTrainzLogoText({
    super.key,
    this.height = 30,
    this.alignment = Alignment.center,
  });

  final double height;
  final Alignment alignment;

  static const _assetPath = 'assets/images/ez_trainz_logo_text_clean.png';

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Image.asset(
        _assetPath,
        height: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      ),
    );
  }
}
