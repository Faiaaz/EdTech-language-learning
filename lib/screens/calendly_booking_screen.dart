import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/utils/app_theme.dart';

class CalendlyBookingScreen extends StatefulWidget {
  const CalendlyBookingScreen({super.key});

  /// Calendly event link. This should point to Fahim's Calendly event type.
  /// If you update the Calendly event in the future, change only this constant.
  static const String baseUrl =
      'https://calendly.com/ezetraining/chat-to-our-staff';

  @override
  State<CalendlyBookingScreen> createState() => _CalendlyBookingScreenState();
}

class _CalendlyBookingScreenState extends State<CalendlyBookingScreen> {
  bool _opening = false;
  bool _openedOnce = false;

  Uri _buildCalendlyUri() {
    final name = AuthController.to.userName.trim();
    final email = (AuthController.to.userEmail ?? '').trim();

    final base = Uri.parse(CalendlyBookingScreen.baseUrl);
    final params = <String, String>{
      if (name.isNotEmpty) 'name': name,
      if (email.isNotEmpty) 'email': email,
      'hide_gdpr_banner': '1',
      'hide_landing_page_details': '1',
      'hide_event_type_details': '1',
    };

    return base.replace(
      queryParameters: {
        ...base.queryParameters,
        ...params,
      },
    );
  }

  Future<void> _openExternal() async {
    if (_opening) return;
    setState(() => _opening = true);
    final uri = _buildCalendlyUri();
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) {
        setState(() {
          _opening = false;
          _openedOnce = true;
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() => _opening = false);
    Get.snackbar(
      'Unable to Open',
      'Could not open the booking page. Please try again later.',
      backgroundColor: AppColors.textPrimary,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SkyGoldBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'nav_call_us'.tr,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'call_us_subtitle'.tr,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.accentBlue, AppColors.accentBlueDk],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentBlue.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.headset_mic_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'call_us_prompt'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _opening ? null : _openExternal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlueDk,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.accentBlueDk.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    icon: _opening
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.calendar_month_rounded),
                    label: Text(
                      _opening
                          ? 'call_us_opening'.tr
                          : 'call_us_book_button'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                if (_openedOnce) ...[
                  const SizedBox(height: 12),
                  Text(
                    'call_us_opened_hint'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
