import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/controllers/game_controller.dart';
import 'package:ez_trainz/controllers/game_session_controller.dart';
import 'package:ez_trainz/controllers/forum_controller.dart';
import 'package:ez_trainz/controllers/leaderboard_controller.dart';
import 'package:ez_trainz/controllers/locale_controller.dart';
import 'package:ez_trainz/controllers/program_controller.dart';
import 'package:ez_trainz/controllers/ielts_controller.dart';
import 'package:ez_trainz/controllers/srs_controller.dart';
import 'package:ez_trainz/controllers/lms_controller.dart';
import 'package:ez_trainz/controllers/gamification_content_controller.dart';
import 'package:ez_trainz/controllers/roster_controller.dart';
import 'package:ez_trainz/l10n/app_translations.dart';
import 'package:ez_trainz/screens/course_list_screen.dart';
import 'package:ez_trainz/screens/login_screen.dart';
import 'package:ez_trainz/screens/main_shell_screen.dart';
import 'package:ez_trainz/screens/splash_screen.dart';

const bool _kBypassAuth = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(LocaleController(), permanent: true);
  final auth = Get.put(AuthController(), permanent: true);
  Get.put(ProgramController(), permanent: true);
  Get.put(CourseController(), permanent: true);
  Get.put(SrsController(), permanent: true);
  Get.put(IeltsController(), permanent: true);
  Get.put(GameController(), permanent: true);
  Get.put(GameSessionController(), permanent: true);
  Get.put(LeaderboardController(), permanent: true);
  Get.put(ForumController(), permanent: true);
  Get.put(LmsController(), permanent: true);
  Get.put(GamificationContentController(), permanent: true);
  Get.put(RosterController(), permanent: true);

  await auth.restoreSession();

  if (_kBypassAuth) {
    auth.setSession(token: 'dev-bypass-token', name: 'Dev User', email: 'dev@example.com');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: LocaleController.to.locale,
      fallbackLocale: const Locale('en', 'US'),
      builder: (context, child) {
        if (!kIsWeb || child == null) return child ?? const SizedBox.shrink();
        return _WebPhonePreview(child: child);
      },
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/courses', page: () => const CourseListScreen()),
      ],
      home: _kBypassAuth ? const MainShellScreen() : const SplashScreen(),
    );
  }
}

/// On Chrome/desktop, render the app inside a fixed phone-sized viewport
/// so layouts match iPhone designs (no desktop stretching).
class _WebPhonePreview extends StatelessWidget {
  const _WebPhonePreview({required this.child});

  final Widget child;

  static const Size _iPhoneLogicalSize = Size(390, 844); // iPhone 12/13/14-ish
  static const EdgeInsets _iPhoneSafePadding = EdgeInsets.only(top: 44, bottom: 34);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final phoneMq = mq.copyWith(
      size: _iPhoneLogicalSize,
      padding: _iPhoneSafePadding,
      // Keep the user's text scaling, but clamp to avoid desktop zoom blowing up UI.
      textScaler: mq.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.15),
    );

    return ColoredBox(
      color: const Color(0xFF0F172A), // dark slate backdrop
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: Container(
            width: _iPhoneLogicalSize.width,
            height: _iPhoneLogicalSize.height,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xAA000000),
                  blurRadius: 30,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: MediaQuery(
                data: phoneMq,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
