import 'package:flutter/material.dart';

import 'package:ez_trainz/view/n5_akasatana_lesson_screen.dart';
import 'package:ez_trainz/view/n5_hi_hello_lesson_screen.dart';
import 'package:ez_trainz/view/n5_kichu_kotha_lesson_screen_v2.dart';
import 'package:ez_trainz/view/n5_weekdays_lesson_screen.dart';
import 'package:ez_trainz/utils/lesson_practice_config.dart';
import 'package:ez_trainz/widgets/lesson_practice_game_cards.dart';
import 'package:ez_trainz/widgets/lesson_video_practice_screen.dart';

/// Returns the video+games screen for N5 lessons ২–৭, or null for other ids.
Widget? n5LessonVideoScreenForId(int lessonId) {
  switch (lessonId) {
    case 2:
      return const HiHelloLesson2Screen();
    case 3:
      return const WeekdaysLesson3Screen();
    case 13:
      return const AkasatanaLesson4Screen();
    case 14:
      return const BornomalaLesson5Screen();
    case 15:
      return const DakutenLesson6Screen();
    case 16:
      return const KichuKothaLesson7Screen();
    default:
      return null;
  }
}

void _openGame(
  BuildContext context,
  Widget Function({
    required int initialTab,
    required bool showTabs,
    int? sessionRounds,
  }) screen,
  int tab, {
  bool practice = false,
}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => screen(
        initialTab: tab,
        showTabs: false,
        sessionRounds: practice ? kLessonPracticeQuestions : null,
      ),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    ),
  );
}

void _openPracticeGame(
  BuildContext context,
  Widget Function({
    required int initialTab,
    required bool showTabs,
    int? sessionRounds,
  }) screen,
  int tab,
) =>
    _openGame(context, screen, tab, practice: true);

// ── পাঠ ২ঃ জাপানিজে হাই-হ্যালো ─────────────────────────────────────
class HiHelloLesson2Screen extends StatelessWidget {
  const HiHelloLesson2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonVideoPracticeScreen(
      titleKey: 'hi_hello_l2_screen_title',
      practiceGames: [
        LessonPracticeGame(
          label: 'শুনে বলো',
          sub: 'শুনে সঠিক বাক্য বাছাই',
          icon: Icons.headphones_rounded,
          colors: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5HiHelloLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            0,
          ),
        ),
        LessonPracticeGame(
          label: 'পড়ে বলো',
          sub: 'পড়ে উত্তর দাও',
          icon: Icons.menu_book_rounded,
          colors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5HiHelloLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            1,
          ),
        ),
        LessonPracticeGame(
          label: 'বলে দেখাও',
          sub: 'উচ্চারণ অনুশীলন',
          icon: Icons.mic_rounded,
          colors: const [Color(0xFF14B8A6), Color(0xFF0F766E)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5HiHelloLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            2,
          ),
        ),
        LessonPracticeGame(
          label: 'ফ্ল্যাশকার্ড',
          sub: 'শব্দ মুখস্থ করো',
          icon: Icons.style_rounded,
          colors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5HiHelloLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            3,
          ),
        ),
      ],
      challengeGames: [
        LessonPracticeGame(
          label: 'কুইজ রান',
          sub: 'দ্রুত উত্তরের পরীক্ষা',
          icon: Icons.quiz_rounded,
          colors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5HiHelloLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            4,
          ),
        ),
        LessonPracticeGame(
          label: 'ফ্রেজ ম্যাচ',
          sub: 'জাপানি-বাংলা মিলাও',
          icon: Icons.swap_horiz_rounded,
          colors: const [Color(0xFFEC4899), Color(0xFFBE185D)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5HiHelloLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            5,
          ),
        ),
        LessonPracticeGame(
          label: 'রাশ বস',
          sub: 'সময়ের বিরুদ্ধে খেলো',
          icon: Icons.bolt_rounded,
          colors: const [Color(0xFFEF4444), Color(0xFFB91C1C)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5HiHelloLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            6,
          ),
        ),
      ],
    );
  }
}

// ── পাঠ ৩ঃ শুক্র-শনি বাকিটা জানি ───────────────────────────────────
class WeekdaysLesson3Screen extends StatelessWidget {
  const WeekdaysLesson3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonVideoPracticeScreen(
      titleKey: 'n5_l3_screen_title',
      practiceGames: [
        LessonPracticeGame(
          label: 'শুনে বলো',
          sub: 'শুনে সঠিক দিন বাছাই',
          icon: Icons.headphones_rounded,
          colors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5WeekdaysLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            0,
          ),
        ),
        LessonPracticeGame(
          label: 'পড়ে বলো',
          sub: 'পড়ে উত্তর দাও',
          icon: Icons.menu_book_rounded,
          colors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5WeekdaysLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            1,
          ),
        ),
        LessonPracticeGame(
          label: 'বলে দেখাও',
          sub: 'উচ্চারণ অনুশীলন',
          icon: Icons.mic_rounded,
          colors: const [Color(0xFF14B8A6), Color(0xFF0F766E)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5WeekdaysLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            2,
          ),
        ),
        LessonPracticeGame(
          label: 'ক্রম বলো',
          sub: 'সপ্তাহের দিন ক্রমে বলো',
          icon: Icons.record_voice_over_rounded,
          colors: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5WeekdaysLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            3,
          ),
        ),
        LessonPracticeGame(
          label: 'ফ্ল্যাশকার্ড',
          sub: 'দিনের নাম মুখস্থ করো',
          icon: Icons.style_rounded,
          colors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5WeekdaysLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            4,
          ),
        ),
      ],
      challengeGames: [
        LessonPracticeGame(
          label: 'কুইজ রান',
          sub: 'দ্রুত উত্তরের পরীক্ষা',
          icon: Icons.quiz_rounded,
          colors: const [Color(0xFFEF4444), Color(0xFFB91C1C)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5WeekdaysLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            5,
          ),
        ),
        LessonPracticeGame(
          label: 'ডে ম্যাচ',
          sub: 'জাপানি-বাংলা মিলাও',
          icon: Icons.swap_horiz_rounded,
          colors: const [Color(0xFFEC4899), Color(0xFFBE185D)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5WeekdaysLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            6,
          ),
        ),
        LessonPracticeGame(
          label: 'নেক্সট ডে',
          sub: 'পরের দিন ধরো',
          icon: Icons.bolt_rounded,
          colors: const [Color(0xFF10B981), Color(0xFF059669)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5WeekdaysLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            7,
          ),
        ),
      ],
    );
  }
}

// ── পাঠ ৪ঃ আকাসাতানা ───────────────────────────────────────────────
class AkasatanaLesson4Screen extends StatelessWidget {
  const AkasatanaLesson4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonVideoPracticeScreen(
      titleKey: 'n5_l4_screen_title',
      practiceGames: [
        LessonPracticeGame(
          label: 'আঁকা',
          sub: 'হিরাগানা আঁকার অনুশীলন',
          icon: Icons.draw_rounded,
          colors: const [Color(0xFF10B981), Color(0xFF059669)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5AkasatanaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            0,
          ),
        ),
        LessonPracticeGame(
          label: 'নোটবুক',
          sub: 'নোটবুকে লিখে শিখো',
          icon: Icons.menu_book_rounded,
          colors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5AkasatanaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            1,
          ),
        ),
        LessonPracticeGame(
          label: 'ফ্ল্যাশকার্ড',
          sub: 'কানা মুখস্থ করো',
          icon: Icons.style_rounded,
          colors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5AkasatanaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            2,
          ),
        ),
        LessonPracticeGame(
          label: 'অনুশীলন শিট',
          sub: 'পিডিএফ ডাউনলোড করো',
          icon: Icons.picture_as_pdf_rounded,
          colors: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5AkasatanaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            5,
          ),
        ),
        LessonPracticeGame(
          label: 'ছক পূরণ',
          sub: 'খালি ঘরে কানা বসাও',
          icon: Icons.grid_on_rounded,
          colors: const [Color(0xFF10B981), Color(0xFF059669)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5AkasatanaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            6,
          ),
        ),
        LessonPracticeGame(
          label: 'স্বর কলাম',
          sub: 'কোন স্বর-কলাম বাছো',
          icon: Icons.view_column_rounded,
          colors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5AkasatanaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            8,
          ),
        ),
      ],
      challengeGames: [
        LessonPracticeGame(
          label: 'কুইজ রান',
          sub: 'দ্রুত উত্তরের পরীক্ষা',
          icon: Icons.quiz_rounded,
          colors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5AkasatanaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            3,
          ),
        ),
        LessonPracticeGame(
          label: 'কানা ম্যাচ',
          sub: 'জাপানি-বাংলা মিলাও',
          icon: Icons.swap_horiz_rounded,
          colors: const [Color(0xFFEC4899), Color(0xFFBE185D)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5AkasatanaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            4,
          ),
        ),
        LessonPracticeGame(
          label: 'সারি দৌড়',
          sub: 'সারি ক্রমে সাজাও',
          icon: Icons.sort_rounded,
          colors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5AkasatanaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            7,
          ),
        ),
        LessonPracticeGame(
          label: 'শুনে খুঁজো',
          sub: 'শুনে সঠিক কানা চাপো',
          icon: Icons.hearing_rounded,
          colors: const [Color(0xFFEC4899), Color(0xFFBE185D)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5AkasatanaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            9,
          ),
        ),
      ],
    );
  }
}

// ── পাঠ ৫ঃ বর্ণে বর্ণে বর্ণমালা ────────────────────────────────────
class BornomalaLesson5Screen extends StatelessWidget {
  const BornomalaLesson5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonVideoPracticeScreen(
      titleKey: 'n5_l5_screen_title',
      practiceGames: [
        LessonPracticeGame(
          label: 'আঁকা',
          sub: 'হিরাগানা আঁকার অনুশীলন',
          icon: Icons.draw_rounded,
          colors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5BorneBorneBornomalaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            0,
          ),
        ),
        LessonPracticeGame(
          label: 'নোটবুক',
          sub: 'নোটবুকে লিখে শিখো',
          icon: Icons.menu_book_rounded,
          colors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5BorneBorneBornomalaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            1,
          ),
        ),
        LessonPracticeGame(
          label: 'ফ্ল্যাশকার্ড',
          sub: 'কানা মুখস্থ করো',
          icon: Icons.style_rounded,
          colors: const [Color(0xFF14B8A6), Color(0xFF0F766E)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5BorneBorneBornomalaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            2,
          ),
        ),
        LessonPracticeGame(
          label: 'অনুশীলন শিট',
          sub: 'পিডিএফ ডাউনলোড করো',
          icon: Icons.picture_as_pdf_rounded,
          colors: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5BorneBorneBornomalaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            5,
          ),
        ),
        LessonPracticeGame(
          label: 'ফাঁক খোঁজো',
          sub: 'や/わ সারির ব্যতিক্রম',
          icon: Icons.search_rounded,
          colors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5BorneBorneBornomalaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            6,
          ),
        ),
        LessonPracticeGame(
          label: 'শব্দ গড়ো',
          sub: 'কানা দিয়ে শব্দ বানাও',
          icon: Icons.spellcheck_rounded,
          colors: const [Color(0xFF10B981), Color(0xFF059669)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5BorneBorneBornomalaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            7,
          ),
        ),
      ],
      challengeGames: [
        LessonPracticeGame(
          label: 'কুইজ রান',
          sub: 'দ্রুত উত্তরের পরীক্ষা',
          icon: Icons.quiz_rounded,
          colors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5BorneBorneBornomalaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            3,
          ),
        ),
        LessonPracticeGame(
          label: 'কানা ম্যাচ',
          sub: 'জাপানি-বাংলা মিলাও',
          icon: Icons.swap_horiz_rounded,
          colors: const [Color(0xFFEC4899), Color(0xFFBE185D)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5BorneBorneBornomalaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            4,
          ),
        ),
        LessonPracticeGame(
          label: 'বর্ণমালা বস',
          sub: 'পুরো বর্ণমালা সাজাও',
          icon: Icons.dashboard_customize_rounded,
          colors: const [Color(0xFF6366F1), Color(0xFF4338CA)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5BorneBorneBornomalaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            8,
          ),
        ),
        LessonPracticeGame(
          label: 'ট্রেস ব্যাটল',
          sub: 'সময়ের মধ্যে যত পারো আঁকো',
          icon: Icons.gesture_rounded,
          colors: const [Color(0xFFEF4444), Color(0xFFB91C1C)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5BorneBorneBornomalaLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            9,
          ),
        ),
      ],
    );
  }
}

// ── পাঠ ৬ঃ জাপানের চন্দ্রবিন্দু ────────────────────────────────────
class DakutenLesson6Screen extends StatelessWidget {
  const DakutenLesson6Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonVideoPracticeScreen(
      titleKey: 'n5_l6_screen_title',
      practiceGames: [
        LessonPracticeGame(
          label: 'আঁকা',
          sub: 'দাকুতেন কানা আঁকো',
          icon: Icons.draw_rounded,
          colors: const [Color(0xFFEF4444), Color(0xFFDC2626)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5DakutenLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            0,
          ),
        ),
        LessonPracticeGame(
          label: 'নোটবুক',
          sub: 'নোটবুকে লিখে শিখো',
          icon: Icons.menu_book_rounded,
          colors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5DakutenLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            1,
          ),
        ),
        LessonPracticeGame(
          label: 'ফ্ল্যাশকার্ড',
          sub: 'কানা মুখস্থ করো',
          icon: Icons.style_rounded,
          colors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5DakutenLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            2,
          ),
        ),
        LessonPracticeGame(
          label: 'অনুশীলন শিট',
          sub: 'পিডিএফ ডাউনলোড করো',
          icon: Icons.picture_as_pdf_rounded,
          colors: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5DakutenLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            5,
          ),
        ),
        LessonPracticeGame(
          label: 'মার্ক লাগাও',
          sub: '゛ / ゜ দিয়ে রূপ বদলাও',
          icon: Icons.add_circle_outline_rounded,
          colors: const [Color(0xFFEF4444), Color(0xFFDC2626)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5DakutenLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            6,
          ),
        ),
        LessonPracticeGame(
          label: 'রূপান্তর জোড়া',
          sub: 'পরিষ্কার ↔ দাকুতেন মেলাও',
          icon: Icons.join_inner_rounded,
          colors: const [Color(0xFFEC4899), Color(0xFFBE185D)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5DakutenLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            9,
          ),
        ),
      ],
      challengeGames: [
        LessonPracticeGame(
          label: 'কুইজ রান',
          sub: 'দ্রুত উত্তরের পরীক্ষা',
          icon: Icons.quiz_rounded,
          colors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5DakutenLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            3,
          ),
        ),
        LessonPracticeGame(
          label: 'কানা ম্যাচ',
          sub: 'জাপানি-বাংলা মিলাও',
          icon: Icons.swap_horiz_rounded,
          colors: const [Color(0xFFEC4899), Color(0xFFBE185D)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5DakutenLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            4,
          ),
        ),
        LessonPracticeGame(
          label: 'てんてん নাকি まる',
          sub: 'কোন চিহ্ন চিনে নাও',
          icon: Icons.contrast_rounded,
          colors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5DakutenLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            7,
          ),
        ),
        LessonPracticeGame(
          label: 'শুনে আলাদা করো',
          sub: 'か vs が — শুনে বাছো',
          icon: Icons.hearing_rounded,
          colors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5DakutenLessonScreen(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            8,
          ),
        ),
      ],
    );
  }
}

// ── পাঠ ৭ঃ কিছু কথা ছিল... ──────────────────────────────────────────
class KichuKothaLesson7Screen extends StatelessWidget {
  const KichuKothaLesson7Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonVideoPracticeScreen(
      titleKey: 'n5_l7_screen_title',
      practiceGames: [
        LessonPracticeGame(
          label: 'সম্বোধন',
          sub: 'ওয়াতাশি/আনাতা শিখো',
          icon: Icons.person_rounded,
          colors: const [Color(0xFF14B8A6), Color(0xFF0F766E)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5KichuKothaLessonScreenV2(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            0,
          ),
        ),
        LessonPracticeGame(
          label: 'বাক্য সাজাও',
          sub: 'শব্দ ক্রমে সাজাও',
          icon: Icons.reorder_rounded,
          colors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5KichuKothaLessonScreenV2(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            1,
          ),
        ),
        LessonPracticeGame(
          label: 'সান ট্যাগ',
          sub: 'সান যোগ করো',
          icon: Icons.label_rounded,
          colors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          onTap: (context) => _openPracticeGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5KichuKothaLessonScreenV2(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            2,
          ),
        ),
      ],
      challengeGames: [
        LessonPracticeGame(
          label: 'প্রশ্ন/বক্তব্য',
          sub: 'প্রশ্ন নাকি বিবৃতি?',
          icon: Icons.help_outline_rounded,
          colors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5KichuKothaLessonScreenV2(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            3,
          ),
        ),
        LessonPracticeGame(
          label: 'ডায়ালগ',
          sub: 'কথোপকথন অনুশীলন',
          icon: Icons.forum_rounded,
          colors: const [Color(0xFFEC4899), Color(0xFFBE185D)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5KichuKothaLessonScreenV2(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            4,
          ),
        ),
        LessonPracticeGame(
          label: 'অর্থ মিলাও',
          sub: 'জাপানি-বাংলা মিলাও',
          icon: Icons.swap_horiz_rounded,
          colors: const [Color(0xFFEF4444), Color(0xFFB91C1C)],
          onTap: (context) => _openGame(
            context,
            ({required initialTab, required showTabs, int? sessionRounds}) =>
                N5KichuKothaLessonScreenV2(
                  initialTab: initialTab,
                  showTabs: showTabs,
                  sessionRounds: sessionRounds,
                ),
            5,
          ),
        ),
      ],
    );
  }
}
