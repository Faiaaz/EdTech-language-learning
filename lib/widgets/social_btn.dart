import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Circular Facebook (white “f” on brand blue).
class FacebookSocialBtn extends StatelessWidget {
  const FacebookSocialBtn({super.key});

  static const _size = 48.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const FaIcon(
        FontAwesomeIcons.facebookF,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}

/// Circular Google (multicolor “G” on white).
class GoogleSocialBtn extends StatelessWidget {
  const GoogleSocialBtn({super.key});

  static const _size = 48.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEA4335),
            Color(0xFFFBBC05),
            Color(0xFF34A853),
            Color(0xFF4285F4),
          ],
          stops: [0.0, 0.35, 0.65, 1.0],
        ).createShader(bounds),
        child: const FaIcon(
          FontAwesomeIcons.google,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
