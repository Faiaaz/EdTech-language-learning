import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/view/forum_screen.dart';
import 'package:ez_trainz/view/leaderboard_screen.dart';
import 'package:ez_trainz/utils/app_theme.dart';
import 'package:ez_trainz/widgets/app_settings_menu.dart';
import 'package:ez_trainz/widgets/ez_trainz_logo_text.dart';

/// "For You" feed — EZ Trainz reels, tips, and curated content.
class ForYouScreen extends StatelessWidget {
  const ForYouScreen({super.key});

  static const _reels = [
    _ReelItem(
      titleKey: 'for_you_reel_1_title',
      subtitleKey: 'for_you_reel_1_sub',
      imageAsset: 'assets/images/ninja_penguin_transparent.png',
      accent: AppColors.accentBlue,
    ),
    _ReelItem(
      titleKey: 'for_you_reel_2_title',
      subtitleKey: 'for_you_reel_2_sub',
      imageAsset: 'assets/images/ez_trainz_logo.png',
      accent: AppColors.accentYellow,
    ),
    _ReelItem(
      titleKey: 'for_you_reel_3_title',
      subtitleKey: 'for_you_reel_3_sub',
      imageAsset: 'assets/images/logo.jpg',
      accent: AppColors.accentPurple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SkyGoldBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: EzTrainzLogoText(
                        height: 28,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    const AppSettingsMenuButton(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                child: Text(
                  'for_you_title'.tr,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  'for_you_subtitle'.tr,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    ..._reels.map((reel) => _ReelCard(reel: reel)),
                    const SizedBox(height: 8),
                    _QuickLinkRow(
                      icon: Icons.people_alt_rounded,
                      labelKey: 'nav_community',
                      onTap: () => Get.to(() => const ForumScreen()),
                    ),
                    const SizedBox(height: 10),
                    _QuickLinkRow(
                      icon: Icons.emoji_events_rounded,
                      labelKey: 'nav_leaderboard',
                      onTap: () => Get.to(() => const LeaderboardScreen()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReelItem {
  const _ReelItem({
    required this.titleKey,
    required this.subtitleKey,
    required this.imageAsset,
    required this.accent,
  });

  final String titleKey;
  final String subtitleKey;
  final String imageAsset;
  final Color accent;
}

class _ReelCard extends StatelessWidget {
  const _ReelCard({required this.reel});

  final _ReelItem reel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: reel.accent.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          reel.accent.withValues(alpha: 0.25),
                          AppColors.skyMid,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      reel.imageAsset,
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.play_circle_fill_rounded,
                        size: 72,
                        color: reel.accent,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'for_you_reel_badge'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reel.titleKey.tr,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  reel.subtitleKey.tr,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLinkRow extends StatelessWidget {
  const _QuickLinkRow({
    required this.icon,
    required this.labelKey,
    required this.onTap,
  });

  final IconData icon;
  final String labelKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accentBlueDk, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  labelKey.tr,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textDim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
