import 'package:ez_trainz/module/module.dart';
import 'package:ez_trainz/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SplashView extends StatelessWidget {
  SplashView({super.key});

  final SplashController splashController = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtils.primeBlue,
      body: AnimatedBuilder(
        animation: splashController.animations,
        builder: (context, _) {
          final isExiting = splashController.exitCtrl.isAnimating || splashController.exitCtrl.isCompleted;
          final taglineOffset = isExiting ? splashController.taglineExitOffset.value : splashController.taglineInOffset.value;
          final taglineOpacity = isExiting ? splashController.taglineExitOpacity.value : splashController.taglineInOpacity.value;
          final currentLogoScale = isExiting ? splashController.exitLogoScale.value : splashController.logoScale.value;
          return Opacity(
            opacity: isExiting ? splashController.splashOpacity.value.clamp(0.0, 1.0) : 1.0,
            child: Container(
              height: 926.h,
              width: 428.w,
              decoration: BoxDecoration(
                color: ColorUtils.white255,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Transform.scale(
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
                            fontSize: 32,
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

                  SpaceHelperWidget.v(15),

                  Transform.translate(
                    offset: Offset(taglineOffset, 0),
                    child: Opacity(
                      opacity: taglineOpacity.clamp(0.0, 1.0),
                      child: TextHelperWidget().headingTextWithoutWidth(
                        alignment: Alignment.center,
                        text: 'splash_tagline'.tr,
                        textAlign: TextAlign.center,
                        textColor: ColorUtils.primeGray,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                        lineHeight: 1,
                      ),
                    ),
                  )

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
