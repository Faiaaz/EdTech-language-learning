import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gif_view/gif_view.dart';
import '../../../view/home_screen.dart';

class AirplaneTransitionController extends GetxController with GetSingleTickerProviderStateMixin {


  late final GifController gifController;
  late final AnimationController fadeOut;

  @override
  void onInit() {
    super.onInit();
    gifController = GifController();
    fadeOut = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    Future.delayed(const Duration(milliseconds: 2300), _navigateToDashboard,);
  }

  Future<void> _navigateToDashboard() async {
    await fadeOut.forward();
    Get.off(()=> HomeScreen(),transition: Transition.noTransition, duration: Duration.zero,);
  }

  @override
  void onClose() {
    gifController.dispose();
    fadeOut.dispose();
    super.onClose();
  }
}