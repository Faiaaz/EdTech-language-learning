import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

class SpringCurveWidget extends Curve {
  final double stiffness;
  final double damping;
  final double mass;

  const SpringCurveWidget({
    required this.stiffness,
    required this.damping,
    required this.mass,
  });

  @override
  double transformInternal(double t) {
    final sim = SpringSimulation(
      SpringDescription(mass: mass, stiffness: stiffness, damping: damping),
      0.0,
      1.0,
      0.0,
    );
    return sim.x(t * 1.2).clamp(0.0, 1.0);
  }
}