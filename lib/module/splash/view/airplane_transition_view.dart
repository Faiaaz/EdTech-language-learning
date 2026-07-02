import 'package:ez_trainz/module/module.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ez_trainz/utils/utils.dart';
import 'package:gif_view/gif_view.dart';


class AirplaneTransitionView extends StatelessWidget {
  AirplaneTransitionView({super.key});

  final AirplaneTransitionController airplaneTransitionController = Get.put(AirplaneTransitionController());

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: airplaneTransitionController.fadeOut,
      builder: (_, child) => FadeTransition(
        opacity: ReverseAnimation(airplaneTransitionController.fadeOut),
        child: child,
      ),
      child: Scaffold(
        backgroundColor: ColorUtils.skyColor,
        body: Stack(
          children: [
            /// Seamless Sky Gradient
            Container(
              height: 926.h,
              width: 428.w,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ColorUtils.deepSkyColor,
                    ColorUtils.skyColor,
                    ColorUtils.lightSkyColor,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),

            /// Airplane GIF — Edgeless & centered
            Center(
              child: GifView.asset(
                'assets/images/popup_screen.gif',
                controller: airplaneTransitionController.gifController,
                width: 428.w,
                fit: BoxFit.contain,
                loop: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
