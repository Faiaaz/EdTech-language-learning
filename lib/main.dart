import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/controllers/locale_controller.dart';
import 'package:ez_trainz/controllers/program_controller.dart';
import 'package:ez_trainz/controllers/srs_controller.dart';
import 'package:ez_trainz/l10n/app_translations.dart';
import 'package:ez_trainz/screens/course_list_screen.dart';
import 'package:ez_trainz/screens/login_screen.dart';
import 'package:ez_trainz/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: const Locale('bn', 'BD'),
      fallbackLocale: const Locale('en', 'US'),
      initialBinding: BindingsBuilder(() {
        Get.put(LocaleController(), permanent: true);
        Get.put(AuthController(), permanent: true);
        Get.put(ProgramController(), permanent: true);
        Get.put(CourseController(), permanent: true);
        Get.put(SrsController(), permanent: true);
      }),
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/courses', page: () => const CourseListScreen()),
      ],
      home: const SplashScreen(),
    );
  }
}
