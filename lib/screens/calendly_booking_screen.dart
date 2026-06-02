import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';

class CalendlyBookingScreen extends StatefulWidget {
  const CalendlyBookingScreen({super.key});

  /// Calendly event link. This should point to Fahim's Calendly event type.
  /// If you update the Calendly event in the future, change only this constant.
  static const String baseUrl =
      // Current publicly-bookable event under the "ezetraining" workspace.
      // Replace with Fahim's direct event link when available.
      'https://calendly.com/ezetraining/chat-to-our-staff';

  @override
  State<CalendlyBookingScreen> createState() => _CalendlyBookingScreenState();
}

class _CalendlyBookingScreenState extends State<CalendlyBookingScreen> {
  bool _opening = true;
  bool _openedOnce = false;

  Uri _buildCalendlyUri() {
    final name = AuthController.to.userName.trim();
    final email = (AuthController.to.userEmail ?? '').trim();

    final base = Uri.parse(CalendlyBookingScreen.baseUrl);
    final params = <String, String>{
      // Calendly supports prefilling these fields on the scheduling page.
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

  Future<void> _openExternal(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    Get.snackbar(
      'Unable to Open',
      'Could not open the booking page. Please try again later.',
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void initState() {
    super.initState();
    // Calendly often shows reCAPTCHA inside in-app webviews.
    // The smooth, reliable experience is to open the booking page in the system
    // browser (Safari/Chrome), which is also what users expect for scheduling.
    // ignore: discarded_futures
    Future.microtask(() async {
      final uri = _buildCalendlyUri();
      await _openExternal(uri);
      if (!mounted) return;
      setState(() {
        _opening = false;
        _openedOnce = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'লাইভ ক্লাস বুক করুন',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_opening) ...[
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    'বুকিং পেজ খোলা হচ্ছে…',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ] else ...[
                  Icon(Icons.open_in_browser_rounded,
                      color: Colors.white.withValues(alpha: 0.9), size: 44),
                  const SizedBox(height: 10),
                  Text(
                    _openedOnce
                        ? 'বুকিং পেজ ব্রাউজারে খোলা হয়েছে।'
                        : 'বুকিং পেজ খুলতে সমস্যা হচ্ছে।',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openExternal(_buildCalendlyUri()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text(
                        'ব্রাউজারে খুলুন',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calendly ইন-অ্যাপ WebView এ reCAPTCHA দেখাতে পারে—তাই ব্রাউজার ব্যবহার করা হচ্ছে।',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

