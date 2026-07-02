import 'package:ez_trainz/models/program.dart';
import 'package:ez_trainz/module/module.dart';
import 'package:ez_trainz/utils/utils.dart';
import 'package:ez_trainz/view/trial_game_language_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_theme.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 926.h(),
        width: 428.w(),
        decoration: BoxDecoration(
          gradient: ColorUtils.pageGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: homeController.fadeIn,
            child: SlideTransition(
              position: homeController.slideIn,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.hp()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      SpaceHelperWidget.v(16.h()),

                      // ── TOP BAR ──────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          EzTrainzLogoTextWidget().ezTrainzLogoTextWidget(
                            imagePath: ImageUtils.ezTrainzLogoTextCleanImage,
                            sourceType: ImageSourceType.asset,
                            height: 30,
                            width: 150,
                            alignment: Alignment.centerLeft
                          ),

                          StreakPillWidget(),

                          InkWell(
                            onTap: homeController.onLogout,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.h(), vertical: 8.w()),
                              decoration: BoxDecoration(
                                color: ColorUtils.white255,
                                borderRadius: BorderRadius.circular(20.r()),
                                border: Border.all(color: ColorUtils.border, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.logout_rounded, color: ColorUtils.textPrimary, size: 15.r()),

                                  SpaceHelperWidget.h(5.w()),

                                  TextHelperWidget().headingTextWithoutWidth(
                                    text: 'logout'.tr,
                                    textColor: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SpaceHelperWidget.v(16.h()),

                      // ── SUBTITLE ─────────────────────────────────

                      TextHelperWidget().headingTextWithoutWidth(
                        text: 'choose_program'.tr,
                        textColor: ColorUtils.textMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),


                      SpaceHelperWidget.v(16.h()),


                      // ── TRIAL GAME CARD ───────────────────────────
                      AnimatedBuilder(
                        animation: homeController.cardsCtrl,
                        builder: (context, _) => SlideTransition(
                          position: homeController.card1Slide,
                          child: FadeTransition(
                            opacity: homeController.card1Fade,
                            child: TrialGameCardWidget().trialGameCardWidget(
                              onTap: () => Get.off(()=>TrialGameLanguagePickerScreen(),
                                transition: Transition.rightToLeftWithFade,
                                duration: const Duration(milliseconds: 260),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SpaceHelperWidget.v(14.h()),


                      // ── PROGRAM CARDS ─────────────────────────────
                      AnimatedBuilder(
                        animation: homeController.cardsCtrl,
                        builder: (context, _) {
                          return Column(
                            children: [

                              SlideTransition(
                                position: homeController.card2Slide,
                                child: FadeTransition(
                                  opacity: homeController.card2Fade,
                                  child: NavCardWidget(
                                    title: Program.jlc.name,
                                    subtitle: Program.jlc.subtitle,
                                    iconWidget: TextHelperWidget().flagIcon(Program.jlc.flagEmoji),
                                    gradientColors: Program.jlc.gradientColors,
                                    onTap: () => homeController.navigateToProgram(Program.jlc),
                                  ),
                                ),
                              ),

                              SpaceHelperWidget.v(14.h()),

                              SlideTransition(
                                position: homeController.card3Slide,
                                child: FadeTransition(
                                  opacity: homeController.card3Fade,
                                  child: NavCardWidget(
                                    title: Program.klc.name,
                                    subtitle: Program.klc.subtitle,
                                    iconWidget: TextHelperWidget().flagIcon(Program.klc.flagEmoji),
                                    gradientColors: Program.klc.gradientColors,
                                    onTap: () => homeController.navigateToProgram(Program.klc),
                                  ),
                                ),
                              ),

                              SpaceHelperWidget.v(14.h()),

                              SlideTransition(
                                position: homeController.card4Slide,
                                child: FadeTransition(
                                  opacity: homeController.card4Fade,
                                  child: NavCardWidget(
                                    title: Program.elc.name,
                                    subtitle: Program.elc.subtitle,
                                    iconWidget: TextHelperWidget().flagIcon(Program.elc.flagEmoji),
                                    gradientColors: Program.elc.gradientColors,
                                    onTap: () => homeController.navigateToProgram(Program.elc),
                                  ),
                                ),
                              ),

                              SpaceHelperWidget.v(14.h()),

                              SlideTransition(
                                position: homeController.card5Slide,
                                child: FadeTransition(
                                  opacity: homeController.card5Fade,
                                  child: NavCardWidget(
                                    title: Program.glc.name,
                                    subtitle: Program.glc.subtitle,
                                    iconWidget: TextHelperWidget().flagIcon(Program.glc.flagEmoji),
                                    gradientColors: Program.glc.gradientColors,
                                    onTap: () => homeController.navigateToProgram(Program.glc),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      SpaceHelperWidget.v(28.h()),


                      // ── WAVING PENGUIN ────────────────────────────

                      Center(
                        child: AnimatedBuilder(
                          animation: homeController.waveCtrl,
                          builder: (context, child) => Transform.rotate(
                            angle: homeController.waveAngle.value,
                            alignment: Alignment.bottomCenter,
                            child: child,
                          ),
                          child: ImageHelperWidget().imageHelperWidget(
                            imagePath: ImageUtils.homeScreenDoyoImage,
                            height: 180,
                            width: 140,
                            sourceType: ImageSourceType.asset,
                          )
                        ),
                      ),

                      SpaceHelperWidget.v(20.h()),


                      // ── TAGLINE ───────────────────────────────────

                      TextHelperWidget().headingTextWithoutWidth(
                        text: 'home_tagline'.tr,
                        textColor: ColorUtils.textMuted,
                        fontSize: 15,
                        alignment: Alignment.center,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),


                      SpaceHelperWidget.v(32.h()),


                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}




