import 'package:flutter/material.dart';

/// Discrete frame change, no fade (crisp, natural).
/// Ping-pong 1→2→3→2→1. Each frame held then instant switch — no blur.
class AnimatedCharacter extends StatefulWidget {
  const AnimatedCharacter({super.key});

  @override
  State<AnimatedCharacter> createState() => _AnimatedCharacterState();
}

class _AnimatedCharacterState extends State<AnimatedCharacter> {
  final List<String> _frames = [
    'assets/images/character_1.png',
    'assets/images/character_2.png',
    'assets/images/character_3.png',
    'assets/images/character_2.png',
  ];

  int _current = 0;

  @override
  void initState() {
    super.initState();
    _scheduleNext();
  }

  void _scheduleNext() {
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      setState(() {
        _current = (_current + 1) % _frames.length;
      });
      _scheduleNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _frames[_current],
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}
