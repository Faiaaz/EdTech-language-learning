/// Banglish UX Copy — 60% Bengali / 40% English
/// EZ TRAINZ Language Learning Platform
///
/// Usage: import and reference keys like `BnStrings.loginTitle`

class BnStrings {
  BnStrings._();

  // ── Login ──────────────────────────────────────────────
  static const loginTitle = 'Login করুন';
  static const loginEmail = 'Email address';
  static const loginPassword = 'Password';
  static const loginButton = 'Login';
  static const loginHelper = 'আপনার একাউন্টে প্রবেশ করুন';
  static const loginForgot = 'Password ভুলে গেছেন?';
  static const loginSignupPrompt = 'একাউন্ট নেই? Sign Up করুন';
  static const loginError = 'Email বা password ভুল হয়েছে। আবার চেষ্টা করুন।';

  // ── Sign Up ────────────────────────────────────────────
  static const signupTitle = 'নতুন Account তৈরি করুন';
  static const signupName = 'আপনার নাম';
  static const signupEmail = 'Email address';
  static const signupPhone = 'মোবাইল নম্বর';
  static const signupPassword = 'Password দিন';
  static const signupPasswordHint = 'কমপক্ষে ৮ অক্ষর দিন';
  static const signupButton = 'Sign Up';
  static const signupTerms =
      'Sign Up করলে আপনি আমাদের Terms ও Privacy Policy মেনে নিচ্ছেন';

  // ── OTP Verification ──────────────────────────────────
  static const otpTitle = 'OTP Verification';
  static const otpInstruction = 'আপনার email-এ পাঠানো ৬ সংখ্যার কোডটি দিন';
  static const otpPlaceholder = '৬ সংখ্যার কোড';
  static const otpButton = 'Verify';
  static const otpResend = 'কোড পাননি? Resend করুন';
  static const otpSuccess = 'সফলভাবে verify হয়েছে!';

  // ── Home ───────────────────────────────────────────────
  static String homeGreeting(String name) => 'স্বাগতম, $name!';
  static const homeSubtitle = 'আজ কোন ভাষা শিখবেন?';
  static const homeJapanese = '🇯🇵 Japanese শিখুন';
  static const homeKorean = '🇰🇷 Korean শিখুন';
  static const homeEnglish = '🇬🇧 English শিখুন';
  static const homeGerman = '🇩🇪 German শিখুন';
  static const homeContinue = 'শেখা চালিয়ে যান';
  static const navHome = 'Home';
  static const navCourses = 'Courses';
  static const navProfile = 'Profile';

  // ── Course List ────────────────────────────────────────
  static const courseListTitle = 'Courses';
  static const courseListSearch = 'Course খুঁজুন...';
  static const courseListFilter = 'Level বাছাই করুন';
  static const courseListBeginner = 'শুরুর ধাপ';
  static const courseListIntermediate = 'মাঝামাঝি ধাপ';
  static String courseListLessonCount(int n) => '${n}টি Lesson';
  static const courseListEmpty = 'এখনো কোনো course যোগ হয়নি';

  // ── Course Detail ──────────────────────────────────────
  static const courseDetailTitle = 'Course বিবরণ';
  static const courseDetailAbout = 'এই Course সম্পর্কে';
  static const courseDetailInstructor = 'শিক্ষক';
  static const courseDetailLevel = 'ধাপ';
  static const courseDetailBeginner = 'শুরুর ধাপ';
  static const courseDetailIntermediate = 'মাঝামাঝি ধাপ';
  static const courseDetailAdvanced = 'উন্নত ধাপ';
  static String courseDetailTotalLessons(int n) => 'মোট Lesson: ${n}টি';
  static const courseDetailProgress = 'আপনার অগ্রগতি';
  static String courseDetailProgressPct(int n) => '$n% সম্পন্ন';
  static const courseDetailStart = 'Course শুরু করুন';
  static const courseDetailContinue = 'শেখা চালিয়ে যান';
  static const courseDetailLessons = 'সব Lesson';
  static const courseDetailLocked = '🔒 আগের Lesson শেষ করুন';

  // ── Kana Chart ─────────────────────────────────────────
  static const kanaTitle = 'Kana Chart';
  static const kanaSubtitle = 'হিরাগানা ও কাতাকানা সব অক্ষর';
  static const kanaTabHiragana = 'হিরাগানা';
  static const kanaTabKatakana = 'কাতাকানা';
  static const kanaMnemonic = 'মনে রাখার কৌশল';
  static const kanaTapHint = 'অক্ষরে ট্যাপ করে উচ্চারণ শুনুন';
  static const kanaStartReview = 'Review শুরু করুন';
  static String kanaMastered(int n) => 'আয়ত্তে আছে: ${n}টি';
  static String kanaRemaining(int n) => 'বাকি আছে: ${n}টি';
  static String kanaRomaji(String value) => 'Romaji: $value';
  static const kanaStrokeOrder = 'লেখার ক্রম';
  static const kanaExample = 'উদাহরণ শব্দ';

  // ── SRS Flashcard Review ───────────────────────────────
  static const srsTitle = 'Flashcard Review';
  static const srsInstruction = 'কার্ডটি দেখুন, তারপর উল্টান';
  static const srsFlip = 'উল্টান';
  static const srsRatingPrompt = 'কতটুকু মনে ছিল?';
  static const srsForgot = 'ভুলে গেছি 😅';
  static const srsHard = 'কঠিন ছিল';
  static const srsEasy = 'সহজ ছিল ✨';
  static String srsRemaining(int n) => 'আর ${n}টি বাকি';
  static const srsCompleteTitle = '🎉 আজকের Review শেষ!';
  static const srsCompleteSubtitle = 'দারুণ করেছেন! কাল আবার দেখা হবে।';
  static String srsStatsReviewed(int n) => 'Review করেছেন: ${n}টি';
  static String srsStatsAccuracy(int n) => 'সঠিক উত্তর: $n%';

  // ── Lesson + Video ─────────────────────────────────────
  static String lessonTitle(int n) => 'Lesson $n';
  static const lessonSubtitle = 'পাঠ বিবরণী';
  static const lessonVideoTitle = 'ভিডিও দেখুন';
  static const lessonPlay = 'Play';
  static const lessonBuffering = 'লোড হচ্ছে...';
  static const lessonVideoError =
      'ভিডিও চালানো যাচ্ছে না। Internet সংযোগ দেখুন।';
  static String lessonDuration(String duration) => 'সময়কাল: $duration';
  static const lessonNotes = 'পাঠের নোট';
  static const lessonNext = 'পরবর্তী Lesson →';
  static const lessonPrev = '← আগের Lesson';
  static const lessonMarkComplete = 'সম্পন্ন হিসেবে চিহ্নিত করুন';
  static const lessonCompleted = '✅ সম্পন্ন হয়েছে';
  static const lessonDownload = 'Download করে রাখুন';

  // ── Quiz ───────────────────────────────────────────────
  static const quizTitle = 'Quiz';
  static const quizInstruction = 'সঠিক উত্তরটি বাছাই করুন';
  static String quizCounter(int current, int total) =>
      'প্রশ্ন $current / $total';
  static const quizSubmit = 'Submit';
  static const quizNext = 'পরের প্রশ্ন →';
  static const quizCorrect = '✅ একদম সঠিক!';
  static String quizWrong(String answer) =>
      '❌ ভুল হয়ে গেছে। সঠিক উত্তর: $answer';
  static const quizHint = '💡 একটু Hint দিন';
  static const quizSkip = 'এড়িয়ে যান';
  static String quizTimer(String time) => 'সময় বাকি: $time';
  static const quizResultTitle = '🎉 Quiz শেষ!';
  static String quizScore(int n, int total) => 'আপনার Score: $n / $total';
  static const quizPass = 'দারুণ! আপনি পাশ করেছেন! 🔥';
  static const quizFail = 'আরেকটু চেষ্টা করলেই হবে। আবার দিন!';
  static const quizRetry = 'আবার Quiz দিন';
  static const quizBackToLesson = 'Lesson-এ ফিরে যান';

  // ── Splash ─────────────────────────────────────────────
  static const splashAppName = 'EZ TRAINZ';
  static const splashTagline = 'ভাষা শেখা এখন সহজ';
  static const splashLoading = 'প্রস্তুত হচ্ছে...';

  // ── Settings ───────────────────────────────────────────
  static const settingsTitle = 'Settings';
  static const settingsNotification = 'Notification চালু করুন';
  static const settingsNotificationDesc =
      'প্রতিদিন মনে করিয়ে দেবে পড়ার কথা';
  static const settingsLanguage = 'অ্যাপের ভাষা';
  static const settingsDarkMode = 'Dark Mode';
  static const settingsAbout = 'আমাদের সম্পর্কে';
  static String settingsVersion(String v) => 'Version $v';
  static const settingsClearData = 'সব Data মুছে ফেলুন';
  static const settingsClearConfirm =
      'এটি করলে আপনার সব অগ্রগতি মুছে যাবে। আপনি কি নিশ্চিত?';
  static const settingsConfirmYes = 'হ্যাঁ, মুছে ফেলুন';
  static const settingsCancel = 'বাদ দিন';

  // ── Profile ────────────────────────────────────────────
  static const profileTitle = 'Profile';
  static const profileName = 'নাম';
  static const profileEmail = 'Email';
  static const profilePhone = 'মোবাইল নম্বর';
  static const profileEdit = 'Edit Profile';
  static const profileLanguagePref = 'পছন্দের ভাষা';
  static const profileLogout = 'Logout';
  static const profileLogoutConfirm = 'আপনি কি Logout করতে চান?';
  static const profileLogoutYes = 'হ্যাঁ, Logout করুন';
  static const profileCancel = 'বাদ দিন';

  // ── Error / Empty States ───────────────────────────────
  static const errorNoInternet =
      'Internet সংযোগ নেই। আবার চেষ্টা করুন।';
  static const errorRetry = 'আবার চেষ্টা করুন';
  static const errorServer =
      'কিছু একটা সমস্যা হয়েছে। একটু পরে আবার আসুন।';
  static const errorEmptyCourses = 'এখনো কোনো Course পাওয়া যায়নি';
  static const errorNoReviews =
      '🎉 আজ কোনো Review নেই! বিশ্রাম নিন।';
  static const error404 = 'হায়! এই pageটি খুঁজে পাওয়া যাচ্ছে না 😕';
}
