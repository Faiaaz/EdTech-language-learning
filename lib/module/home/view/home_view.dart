import 'package:ez_trainz/models/program.dart';
import 'package:ez_trainz/module/module.dart';
import 'package:ez_trainz/utils/utils.dart';
import 'package:ez_trainz/view/trial_game_language_picker_screen.dart';
import 'package:ez_trainz/widgets/ez_trainz_logo_text.dart';
import 'package:ez_trainz/widgets/streak_pill.dart';
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
        height: 926.h,
        width: 428.w,
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
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // ── TOP BAR ──────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const EzTrainzLogoText(
                            height: 30,
                            alignment: Alignment.centerLeft,
                          ),
                          const StreakPill(),
                          GestureDetector(
                            onTap: homeController.onLogout,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.border, width: 1),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.logout_rounded,
                                      color: AppColors.textPrimary, size: 15),
                                  const SizedBox(width: 5),
                                  Text(
                                    'logout'.tr,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ── SUBTITLE ─────────────────────────────────
                      Text(
                        'choose_program'.tr,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── TRIAL GAME CARD ───────────────────────────
                      AnimatedBuilder(
                        animation: homeController.cardsCtrl,
                        builder: (context, _) => SlideTransition(
                          position: homeController.card1Slide,
                          child: FadeTransition(
                            opacity: homeController.card1Fade,
                            child: _TrialGameCard(
                              onTap: () => Get.to(
                                    () => const TrialGameLanguagePickerScreen(),
                                transition: Transition.rightToLeftWithFade,
                                duration: const Duration(milliseconds: 260),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── PROGRAM CARDS ─────────────────────────────
                      AnimatedBuilder(
                        animation: homeController.cardsCtrl,
                        builder: (context, _) => Column(
                          children: [
                            SlideTransition(
                              position: homeController.card2Slide,
                              child: FadeTransition(
                                opacity: homeController.card2Fade,
                                child: _NavCard(
                                  title: Program.jlc.name,
                                  subtitle: Program.jlc.subtitle,
                                  iconWidget:
                                  _flagIcon(Program.jlc.flagEmoji),
                                  gradientColors: Program.jlc.gradientColors,
                                  onTap: () => homeController.navigateToProgram(Program.jlc),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SlideTransition(
                              position: homeController.card3Slide,
                              child: FadeTransition(
                                opacity: homeController.card3Fade,
                                child: _NavCard(
                                  title: Program.klc.name,
                                  subtitle: Program.klc.subtitle,
                                  iconWidget:
                                  _flagIcon(Program.klc.flagEmoji),
                                  gradientColors: Program.klc.gradientColors,
                                  onTap: () => homeController.navigateToProgram(Program.klc),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SlideTransition(
                              position: homeController.card4Slide,
                              child: FadeTransition(
                                opacity: homeController.card4Fade,
                                child: _NavCard(
                                  title: Program.elc.name,
                                  subtitle: Program.elc.subtitle,
                                  iconWidget:
                                  _flagIcon(Program.elc.flagEmoji),
                                  gradientColors: Program.elc.gradientColors,
                                  onTap: () => homeController.navigateToProgram(Program.elc),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SlideTransition(
                              position: homeController.card5Slide,
                              child: FadeTransition(
                                opacity: homeController.card5Fade,
                                child: _NavCard(
                                  title: Program.glc.name,
                                  subtitle: Program.glc.subtitle,
                                  iconWidget:
                                  _flagIcon(Program.glc.flagEmoji),
                                  gradientColors: Program.glc.gradientColors,
                                  onTap: () => homeController.navigateToProgram(Program.glc),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── WAVING PENGUIN ────────────────────────────
                      Center(
                        child: AnimatedBuilder(
                          animation: homeController.waveCtrl,
                          builder: (context, child) => Transform.rotate(
                            angle: homeController.waveAngle.value,
                            alignment: Alignment.bottomCenter,
                            child: child,
                          ),
                          child: const Image(
                            image: AssetImage(
                                'assets/images/ninja_penguin_transparent.png'),
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── TAGLINE ───────────────────────────────────
                      Center(
                        child: Text(
                          'home_tagline'.tr,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
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
