import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameFx {
  GameFx() {
    _player = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
  }

  late final AudioPlayer _player;

  Future<void> _play(String file) async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sfx/$file'));
    } catch (_) {}
  }

  Future<void> tap() async {
    HapticFeedback.selectionClick();
    await _play('tap.wav');
  }

  Future<void> snap() async {
    HapticFeedback.lightImpact();
    await _play('snap.wav');
  }

  Future<void> success() async {
    HapticFeedback.mediumImpact();
    await _play('success.wav');
  }

  Future<void> error() async {
    HapticFeedback.heavyImpact();
    await _play('error.wav');
  }

  Future<void> combo() async {
    HapticFeedback.mediumImpact();
    await _play('combo.wav');
  }

  Future<void> progressFill() async {
    await _play('progress_fill.wav');
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

class TapScale extends StatefulWidget {
  const TapScale({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutBack,
        scale: _pressed ? 1.06 : 1,
        child: widget.child,
      ),
    );
  }
}

class ShakeX extends StatelessWidget {
  const ShakeX({
    super.key,
    required this.trigger,
    required this.child,
    this.amplitude = 8,
  });

  final int trigger;
  final Widget child;
  final double amplitude;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(trigger),
      tween: Tween(begin: 0, end: trigger.toDouble()),
      duration: const Duration(milliseconds: 320),
      builder: (_, value, c) {
        final wave = math.sin(value * 36) * amplitude * math.exp(-(value % 1) * 4);
        return Transform.translate(offset: Offset(wave, 0), child: c);
      },
      child: child,
    );
  }
}
