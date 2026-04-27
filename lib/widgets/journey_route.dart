import 'package:flutter/material.dart';

/// Shared cubic-bezier page transition used across the Journey feature.
/// Keeps navigation feeling premium and consistent.
PageRouteBuilder<T> journeyRoute<T>(Widget page,
    {Duration duration = const Duration(milliseconds: 420)}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final eased = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: eased,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(eased),
          child: child,
        ),
      );
    },
  );
}
