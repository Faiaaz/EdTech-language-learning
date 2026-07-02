import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/controllers/locale_controller.dart';
import 'package:ez_trainz/view/pronunciation_benchmark_screen.dart';
import 'package:ez_trainz/view/user_history_screen.dart';
import 'package:ez_trainz/utils/app_theme.dart';
import 'package:ez_trainz/widgets/app_settings_menu.dart';

/// Basic user information: Name, Email, Bio. Matches JLC/KLC/ELC/GLC theme.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _bgColor = Colors.transparent;
  static const _accentColor = AppColors.accentYellow;

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.to;
    final name = auth.userName.isNotEmpty ? auth.userName : '—';
    final email = auth.userEmail?.isNotEmpty == true ? auth.userEmail! : '—';
    final bio = auth.userBio?.isNotEmpty == true ? auth.userBio! : 'no_bio'.tr;

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // ── Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('EZ',
                          style: TextStyle(
                            color: Color(0xFFFFE000),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          )),
                      SizedBox(width: 3),
                      Text('TRAINZ',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            height: 1,
                          )),
                    ],
                  ),
                  const AppSettingsMenuButton(),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'profile'.tr,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'your_information'.tr,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Info cards + language picker ────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _ProfileRow(
                      icon: Icons.person_outline_rounded,
                      label: 'name_label'.tr,
                      value: name,
                    ),
                    const SizedBox(height: 14),
                    _ProfileRow(
                      icon: Icons.email_outlined,
                      label: 'email_label'.tr,
                      value: email,
                    ),
                    const SizedBox(height: 14),
                    _ProfileRow(
                      icon: Icons.info_outline_rounded,
                      label: 'bio_label'.tr,
                      value: bio,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 14),

                    // ── Journey & Achievements ────────────────────
                    GestureDetector(
                      onTap: () => Get.toNamed('/journey'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _accentColor.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.explore_rounded,
                                  color: _accentColor, size: 22),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Journey & Achievements',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Customize your avatar, earn XP, and unlock gear',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                color: AppColors.textMuted, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── My History button ────────────────────────
                    GestureDetector(
                      onTap: () => Get.to(() => const UserHistoryScreen()),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.history_rounded,
                                  color: const Color(0xFF3B82F6), size: 22),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'history_btn_label'.tr,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'history_btn'.tr,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                color: AppColors.textMuted, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Language Picker ──────────────────────────
                    _LanguagePickerCard(),

                    // ── Dev: pronunciation accuracy benchmark ────
                    if (kDebugMode) ...[
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () => Get.to(
                            () => const PronunciationBenchmarkScreen()),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(0xFF8B5CF6)
                                    .withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.analytics_outlined,
                                  color: Color(0xFF8B5CF6), size: 22),
                              SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'উচ্চারণ Accuracy Benchmark (dev)',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  color: AppColors.textMuted, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Language Picker Card ───────────────────────────────────────────────
class _LanguagePickerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locale = LocaleController.to;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.language_rounded,
                    color: const Color(0xFF3B82F6), size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                'app_language'.tr,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _LangButton(
                      label: 'language_english'.tr,
                      selected: locale.isEnglish,
                      onTap: locale.switchToEnglish,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LangButton(
                      label: 'language_bangla'.tr,
                      selected: !locale.isEnglish,
                      onTap: locale.switchToBanglish,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3B82F6) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF3B82F6) : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  final IconData icon;
  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF3B82F6), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
