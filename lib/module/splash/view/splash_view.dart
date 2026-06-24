import 'package:ez_trainz/module/module.dart';
import 'package:ez_trainz/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/ez_logo_boxed.dart';


class SplashView extends StatelessWidget {
  SplashView({super.key});

  final SplashController splashController = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final double logoTravelY = (screenH / 2) - 56;

    return Scaffold(
      backgroundColor: const Color(0xFF4DA6E8),
      body: AnimatedBuilder(
        animation: splashController.animations,
        builder: (context, _) {
          final isExiting =
              splashController.exitCtrl.isAnimating || splashController.exitCtrl.isCompleted;
          final taglineOffset = isExiting
              ? splashController.taglineExitOffset.value
              : splashController.taglineInOffset.value;
          final taglineOpacity = isExiting
              ? splashController.taglineExitOpacity.value
              : splashController.taglineInOpacity.value;
          final currentLogoScale =
          isExiting ? splashController.exitLogoScale.value : splashController.logoScale.value;
          final logoTopPos = isExiting
              ? (screenH / 2 - 21) - (splashController.exitLogoY.value * logoTravelY)
              : screenH / 2 - 21;

          return Opacity(
            opacity: isExiting ? splashController.splashOpacity.value.clamp(0.0, 1.0) : 1.0,
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
                          transform: Matrix4.identity()..rotateZ(splashController.currentRotation),
                          child: EzLogoBoxHelperWidget().ezLogoBoxHelperWidget(
                            containerHeight: 42,
                            containerWidth: 52,
                            borderRadius: 10,
                            fontSize: 32
                          ),
                        ),

                        SpaceHelperWidget.h(8),

                        Transform.translate(
                          offset: Offset(isExiting ? 0.0 : splashController.trainzOffset.value, 0,),
                          child: Opacity(
                            opacity: isExiting ? 1.0 : splashController.trainzOpacity.value,
                            child: TextHelperWidget().headingTextWithoutWidth(
                              text: "TRAINZ",
                              textColor: ColorUtils.primeBlue,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              lineHeight: 1,
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
                        style: const TextStyle(
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
    );
  }
}
