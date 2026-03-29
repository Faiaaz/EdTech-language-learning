import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/controllers/game_controller.dart';
import 'package:ez_trainz/controllers/game_session_controller.dart';
import 'package:ez_trainz/controllers/leaderboard_controller.dart';
import 'package:ez_trainz/controllers/locale_controller.dart';
import 'package:ez_trainz/controllers/program_controller.dart';
import 'package:ez_trainz/controllers/ielts_controller.dart';
import 'package:ez_trainz/controllers/srs_controller.dart';
import 'package:ez_trainz/l10n/app_translations.dart';
import 'package:ez_trainz/screens/course_list_screen.dart';
import 'package:ez_trainz/screens/login_screen.dart';
import 'package:ez_trainz/screens/main_shell_screen.dart';
import 'package:ez_trainz/screens/splash_screen.dart';

const bool _kBypassAuth = false;

void main() {
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
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/courses', page: () => const CourseListScreen()),
      ],
      home: _kBypassAuth ? const MainShellScreen() : const SplashScreen(),
    );
  }
}
