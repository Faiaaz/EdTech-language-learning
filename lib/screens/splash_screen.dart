import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';

import 'package:ez_trainz/screens/login_screen.dart';
import 'package:ez_trainz/widgets/ez_logo_boxed.dart';
import 'package:ez_trainz/utils/spring_curve.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleRotateUpCtrl;
  late AnimationController _rotateBackCtrl;
  late AnimationController _trainzCtrl;
  late AnimationController _taglineInCtrl;
  late AnimationController _exitCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _rotateUp;
  late Animation<double> _rotateBack;
  late Animation<double> _trainzOffset;
  late Animation<double> _trainzOpacity;
  late Animation<double> _taglineInOffset;
  late Animation<double> _taglineInOpacity;
  late Animation<double> _taglineExitOffset;
  late Animation<double> _taglineExitOpacity;
  late Animation<double> _splashOpacity;
  late Animation<double> _exitLogoScale;
  late Animation<double> _exitLogoY;

  @override
  void initState() {
    super.initState();

    _scaleRotateUpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _scaleRotateUpCtrl, curve: Curves.easeOut),
    );
    _rotateUp = Tween<double>(begin: 0.0, end: 45 * math.pi / 180).animate(
      CurvedAnimation(parent: _scaleRotateUpCtrl, curve: Curves.easeOut),
    );

    _rotateBackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rotateBack = Tween<double>(begin: 45 * math.pi / 180, end: 0.0).animate(
      CurvedAnimation(parent: _rotateBackCtrl, curve: Curves.elasticOut),
    );

    _trainzCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _trainzOffset = Tween<double>(begin: -80.0, end: 0.0).animate(
      CurvedAnimation(parent: _trainzCtrl, curve: Curves.elasticOut),
    );
    _trainzOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _trainzCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _taglineInCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _taglineInOffset = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _taglineInCtrl,
        curve: const SpringCurve(
          stiffness: 151.5,
          damping: 18.46,
          mass: 1.0,
        ),
      ),
    );
    _taglineInOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _taglineInCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _taglineExitOffset = Tween<double>(begin: 0.0, end: -350.0).animate(
      CurvedAnimation(
        parent: _exitCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _taglineExitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitCtrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    _splashOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitCtrl,
        curve: const Interval(0.1, 0.9, curve: Curves.easeInOut),
      ),
    );
    _exitLogoScale = Tween<double>(begin: 1.0, end: 0.55).animate(
      CurvedAnimation(
        parent: _exitCtrl,
        curve: const Interval(0.1, 0.8, curve: Curves.easeInOut),
      ),
    );
    _exitLogoY = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _exitCtrl,
        curve: const Interval(0.1, 0.8, curve: Curves.easeInOut),
      ),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _scaleRotateUpCtrl.forward();
    await _rotateBackCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _trainzCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    await _taglineInCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    await _exitCtrl.forward();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scaleRotateUpCtrl.dispose();
    _rotateBackCtrl.dispose();
    _trainzCtrl.dispose();
    _taglineInCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  double get _currentRotation {
    if (_rotateBackCtrl.isAnimating || _rotateBackCtrl.isCompleted) {
      return _rotateBack.value;
    }
    return _rotateUp.value;
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final double logoTravelY = (screenH / 2) - 56;

    return Scaffold(
      backgroundColor: const Color(0xFF4DA6E8),
      body: Stack(
        children: [
          const LoginScreen(),
          AnimatedBuilder(
            animation: Listenable.merge([
              _scaleRotateUpCtrl,
              _rotateBackCtrl,
              _trainzCtrl,
              _taglineInCtrl,
              _exitCtrl,
            ]),
            builder: (context, _) {
              final isExiting =
                  _exitCtrl.isAnimating || _exitCtrl.isCompleted;

              final taglineOffset = isExiting
                  ? _taglineExitOffset.value
                  : _taglineInOffset.value;
              final taglineOpacity = isExiting
                  ? _taglineExitOpacity.value
                  : _taglineInOpacity.value;
              final currentLogoScale =
                  isExiting ? _exitLogoScale.value : _logoScale.value;
              final logoTopPos = isExiting
                  ? (screenH / 2 - 21) - (_exitLogoY.value * logoTravelY)
                  : screenH / 2 - 21;

              return Opacity(
                opacity: isExiting
                    ? _splashOpacity.value.clamp(0.0, 1.0)
                    : 1.0,
                child: Stack(
                  children: [
                    Container(color: Colors.white),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: logoTopPos,
                      child: Transform.scale(
                        scale: currentLogoScale,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..rotateZ(_currentRotation),
                              child: const EZLogoBoxed(),
                            ),
                            const SizedBox(width: 8),
                            Transform.translate(
                              offset: Offset(
                                  isExiting ? 0 : _trainzOffset.value, 0),
                              child: Opacity(
                                opacity:
                                    isExiting ? 1.0 : _trainzOpacity.value,
                                child: const Text(
                                  'TRAINZ',
                                  style: TextStyle(
                                    color: Color(0xFF4DA6E8),
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: screenH / 2 + 30,
                      child: Transform.translate(
                        offset: Offset(taglineOffset, 0),
                        child: Opacity(
                          opacity: taglineOpacity.clamp(0.0, 1.0),
                          child: Text(
                            'splash_tagline'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.3,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
