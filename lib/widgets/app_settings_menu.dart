import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/view/coming_soon_screen.dart';
import 'package:ez_trainz/view/login_screen.dart';
import 'package:ez_trainz/view/profile_screen.dart';
import 'package:ez_trainz/utils/app_theme.dart';

/// Top-right gear that opens account settings (profile, billing, logout, etc.).
class AppSettingsMenuButton extends StatelessWidget {
  const AppSettingsMenuButton({
    super.key,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.compact = false,
  });

  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final icon = iconColor ?? AppColors.textPrimary;
    final bg = backgroundColor ?? AppColors.card;
    final border = borderColor ?? AppColors.border;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showAppSettingsSheet(context),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 9 : 11,
            vertical: compact ? 7 : 8,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.settings_rounded,
            color: icon,
            size: compact ? 17 : 19,
          ),
        ),
      ),
    );
  }
}

void showAppSettingsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _AppSettingsSheet(),
  );
}

class _AppSettingsSheet extends StatelessWidget {
  const _AppSettingsSheet();

  Future<void> _confirmLogout(BuildContext context) async {
    final yes = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'settings_logout'.tr,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'profile_logout_confirm'.tr,
          style: const TextStyle(color: AppColors.textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('profile_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'profile_logout_yes'.tr,
              style: const TextStyle(
                color: AppColors.wrong,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    if (yes != true) return;
    if (context.mounted) Navigator.of(context).pop();
    AuthController.to.logout();
    Get.offAll(() => const LoginScreen());
  }

  void _openDetail(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Get.to(() => screen);
  }

  void _openRoute(String route) {
    Get.back();
    Get.toNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.to;
    final name = auth.userName.trim().isNotEmpty ? auth.userName.trim() : '—';
    final email =
        auth.userEmail?.trim().isNotEmpty == true ? auth.userEmail!.trim() : '—';
    final phone = auth.signUpPhone.trim().isNotEmpty
        ? auth.signUpPhone.trim()
        : 'settings_phone_empty'.tr;
    final initial = name == '—' ? '?' : name.characters.first.toUpperCase();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.accentBlue, AppColors.accentBlueDk],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                label: 'settings_profile'.tr,
                onTap: () => _openDetail(context, const ProfileScreen()),
              ),
              _SettingsTile(
                icon: Icons.badge_outlined,
                label: 'settings_username_password'.tr,
                subtitle: email,
                onTap: () => _openDetail(
                  context,
                  _AccountDetailScreen(
                    titleKey: 'settings_username_password',
                    rows: [
                      _AccountRow(
                        labelKey: 'settings_username',
                        value: name,
                      ),
                      _AccountRow(
                        labelKey: 'email_label',
                        value: email,
                      ),
                      _AccountRow(
                        labelKey: 'settings_password',
                        value: 'settings_password_masked'.tr,
                      ),
                    ],
                    footnoteKey: 'settings_password_hint',
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.phone_outlined,
                label: 'settings_phone'.tr,
                subtitle: phone,
                onTap: () => _openDetail(
                  context,
                  _AccountDetailScreen(
                    titleKey: 'settings_phone',
                    rows: [
                      _AccountRow(labelKey: 'settings_phone', value: phone),
                    ],
                    footnoteKey: 'settings_phone_hint',
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.trending_up_rounded,
                label: 'settings_progress'.tr,
                onTap: () => _openRoute('/journey'),
              ),
              _SettingsTile(
                icon: Icons.receipt_long_outlined,
                label: 'settings_billing'.tr,
                onTap: () => _openDetail(
                  context,
                  const ComingSoonScreen(titleKey: 'settings_billing'),
                ),
              ),
              const SizedBox(height: 6),
              const Divider(height: 1, color: AppColors.border),
              _SettingsTile(
                icon: Icons.logout_rounded,
                label: 'settings_logout'.tr,
                destructive: true,
                showChevron: false,
                onTap: () => _confirmLogout(context),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.wrong : AppColors.textPrimary;
    final iconBg = destructive
        ? AppColors.wrong.withValues(alpha: 0.1)
        : AppColors.accentBlue.withValues(alpha: 0.1);
    final iconColor = destructive ? AppColors.wrong : AppColors.accentBlueDk;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showChevron)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textDim,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountRow {
  const _AccountRow({required this.labelKey, required this.value});

  final String labelKey;
  final String value;
}

class _AccountDetailScreen extends StatelessWidget {
  const _AccountDetailScreen({
    required this.titleKey,
    required this.rows,
    this.footnoteKey,
  });

  final String titleKey;
  final List<_AccountRow> rows;
  final String? footnoteKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          titleKey.tr,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SkyGoldBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...rows.map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.labelKey.tr,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            row.value,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (footnoteKey != null)
                  Text(
                    footnoteKey!.tr,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
