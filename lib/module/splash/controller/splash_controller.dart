import 'dart:math' as math;
import 'package:ez_trainz/module/module.dart';
import 'package:ez_trainz/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashController extends GetxController with GetTickerProviderStateMixin {

  late AnimationController scaleRotateUpCtrl;
  late AnimationController rotateBackCtrl;
  late AnimationController trainzCtrl;
  late AnimationController taglineInCtrl;
  late AnimationController exitCtrl;

  late Animation<double> logoScale;
  late Animation<double> rotateUp;
  late Animation<double> rotateBack;
  late Animation<double> trainzOffset;
  late Animation<double> trainzOpacity;
  late Animation<double> taglineInOffset;
  late Animation<double> taglineInOpacity;
  late Animation<double> taglineExitOffset;
  late Animation<double> taglineExitOpacity;
  late Animation<double> splashOpacity;
  late Animation<double> exitLogoScale;
  late Animation<double> exitLogoY;

  late Listenable animations;

  @override
  void onInit() {
    super.onInit();
    _setupAnimations();
    _startAnimation();
  }

  void _setupAnimations() {
    scaleRotateUpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: scaleRotateUpCtrl, curve: Curves.easeOut),
    );
    rotateUp = Tween<double>(begin: 0.0, end: 45 * math.pi / 180).animate(
      CurvedAnimation(parent: scaleRotateUpCtrl, curve: Curves.easeOut),
    );

    rotateBackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    rotateBack = Tween<double>(begin: 45 * math.pi / 180, end: 0.0).animate(
      CurvedAnimation(parent: rotateBackCtrl, curve: Curves.elasticOut),
    );

    trainzCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    trainzOffset = Tween<double>(begin: -80.0, end: 0.0).animate(
      CurvedAnimation(parent: trainzCtrl, curve: Curves.elasticOut),
    );
    trainzOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: trainzCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    taglineInCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    taglineInOffset = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: taglineInCtrl,
        curve: const SpringCurveWidget(
          stiffness: 151.5,
          damping: 18.46,
          mass: 1.0,
        ),
      ),
    );
    taglineInOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: taglineInCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    taglineExitOffset = Tween<double>(begin: 0.0, end: -350.0).animate(
      CurvedAnimation(
        parent: exitCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    taglineExitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: exitCtrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    splashOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: exitCtrl,
        curve: const Interval(0.1, 0.9, curve: Curves.easeInOut),
      ),
    );
    exitLogoScale = Tween<double>(begin: 1.0, end: 0.55).animate(
      CurvedAnimation(
        parent: exitCtrl,
        curve: const Interval(0.1, 0.8, curve: Curves.easeInOut),
      ),
    );
    exitLogoY = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: exitCtrl,
        curve: const Interval(0.1, 0.8, curve: Curves.easeInOut),
      ),
    );

    animations = Listenable.merge([
      scaleRotateUpCtrl,
      rotateBackCtrl,
      trainzCtrl,
      taglineInCtrl,
      exitCtrl,
    ]);
  }

  Future<void> _startAnimation() async {
    await Future.delayed(Duration(milliseconds: 300),() async {
      await scaleRotateUpCtrl.forward();
      await rotateBackCtrl.forward();
      await Future.delayed(Duration(milliseconds: 100),() async {
        await trainzCtrl.forward();
        await Future.delayed(Duration(milliseconds: 150),() async {
          await taglineInCtrl.forward();
          await Future.delayed(Duration(milliseconds: 800),() async {
            await exitCtrl.forward();
            Get.off(()=>AirplaneTransitionView(), transition: Transition.noTransition,);
          });
        });
      });
    });
  }

  double get currentRotation {
    if (rotateBackCtrl.isAnimating || rotateBackCtrl.isCompleted) {
      return rotateBack.value;
    }
    return rotateUp.value;
  }

  @override
  void onClose() {
    scaleRotateUpCtrl.dispose();
    rotateBackCtrl.dispose();
    trainzCtrl.dispose();
    taglineInCtrl.dispose();
    exitCtrl.dispose();
    super.onClose();
  }
}