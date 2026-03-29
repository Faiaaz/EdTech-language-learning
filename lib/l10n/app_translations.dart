import 'package:get/get.dart';

/// GetX Translations — supports English (en_US) and Banglish (bn_BD).
/// Usage: 'key'.tr  |  'key'.trParams({'param': value})
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': _en,
        'bn_BD': _bn,
      };
}

const _en = <String, String>{
  // ── Login ───────────────────────────────────────────────────────
  'login_title': 'Login',
  'login_helper': 'Sign in to your account',
  'login_forgot': 'Forgot Password?',
  'login_signup_prompt': "Don't have an account? Sign Up",
  'login_error': 'Incorrect email or password. Please try again.',
  'login_empty_fields': 'Please enter your email and password.',
  'login_generic_error': 'Something went wrong. Please try again.',
  'sign_in': 'Sign in',
  'forgot_password': 'Forgot Password',
  'or_sign_in_with': 'Or Sign In With',
  'new_here': 'New Here?',
  'lets_sign_up': "Let's Sign Up",
  'enter_email': 'Enter your Email',
  'enter_password': 'Enter your password',

  // ── Sign Up ─────────────────────────────────────────────────────
  'signup_title': 'Create your Account',
  'signup_subtitle': 'Create your account',
  'signup_name_label': 'Full Name',
  'signup_name_hint': 'Enter your full name',
  'signup_email_label': 'Email Address',
  'signup_email_hint': 'Enter your email',
  'signup_phone_label': 'Phone Number',
  'signup_phone_hint': '017XXXXXXXX',
  'signup_pass_label': 'Password',
  'signup_pass_hint': 'Min 8 chars, uppercase, number, symbol',
  'signup_confirm_label': 'Confirm Password',
  'signup_confirm_hint': 'Re-enter your password',
  'signup_button': 'Continue',
  'signup_have_account': 'Already have an account? ',
  'signup_sign_in': 'Sign In',

  // ── Validation ──────────────────────────────────────────────────
  'val_name_required': 'Full name is required',
  'val_name_length': 'Name must be at least 3 characters',
  'val_name_format': 'Name can only contain letters, spaces, or hyphens',
  'val_email_required': 'Email address is required',
  'val_email_format': 'Enter a valid email address',
  'val_phone_required': 'Phone number is required',
  'val_phone_format': 'Enter a valid BD number (e.g. 017XXXXXXXX)',
  'val_pass_required': 'Password is required',
  'val_pass_length': 'Must be at least 8 characters',
  'val_pass_uppercase': 'Must include an uppercase letter',
  'val_pass_number': 'Must include a number',
  'val_pass_special': 'Must include a special character (e.g. @, #, !)',
  'val_confirm_required': 'Please confirm your password',
  'val_confirm_match': 'Passwords do not match',

  // ── Course List ─────────────────────────────────────────────────
  'programs': 'Programs',
  'logout': 'Logout',
  'choose_course': 'Choose a course to start learning',
  'lessons_count': '@count lessons',

  // ── Lesson ──────────────────────────────────────────────────────
  'back': 'Back',
  'lesson_not_found': 'Lesson not found.',
  'failed_load_video': 'Failed to load video',
  'quizzes': 'Quizzes',
  'passing_score': 'Passing score: @score%',
  'start': 'Start',

  // ── Kana Chart ──────────────────────────────────────────────────
  'memory_hint': 'Memory Hint',
  'audio_coming_soon': 'Audio for "@romaji" coming soon!',
  'listen_to': 'Listen to "@romaji"',

  // ── Profile ─────────────────────────────────────────────────────
  'profile': 'Profile',
  'your_information': 'Your information',
  'name_label': 'Name',
  'email_label': 'Email',
  'bio_label': 'Bio',
  'no_bio': 'No bio yet.',
  'profile_logout_confirm': 'Do you want to logout?',
  'profile_logout_yes': 'Yes, Logout',
  'profile_cancel': 'Cancel',

  // ── Language Picker ─────────────────────────────────────────────
  'app_language': 'App Language',
  'language_english': 'English',
  'language_bangla': 'বাংলিশ (Banglish)',

  // ── Nav (bottom bar) ───────────────────────────────────────────
  'nav_learn': 'Learn',
  'nav_practice': 'Practice',
  'nav_profile': 'Profile',
  'nav_community': 'Community',
  'nav_leaderboard': 'Leaderboard',

  // ── Home / Learn tab ──────────────────────────────────────────
  'home_subtitle': 'Which language will you learn today?',
  'choose_language_program': 'Choose a language program',
  'select_one_subtitle': 'Select one to see courses and lessons',

  // ── Coming Soon ────────────────────────────────────────────────
  'coming_soon': 'Coming Soon',

  // ── Forum (Community) ─────────────────────────────────────────
  'forum_title': 'Community Forum',
  'forum_all_posts': 'All posts',
  'forum_threads': 'Threads',
  'forum_empty': 'No posts yet. Start the conversation!',
  'forum_new_post': 'New post',
  'forum_create': 'Create post',
  'forum_title_field': 'Title',
  'forum_body_field': 'What would you like to share?',
  'forum_publish': 'Publish',
  'forum_create_required': 'Please enter a title and message.',
  'forum_post': 'Post',
  'forum_untitled': 'Untitled',
  'forum_comments': 'Comments',
  'forum_no_comments': 'No comments yet. Be the first!',
  'forum_comment_hint': 'Write a comment…',
  'forum_delete_post': 'Delete post?',
  'forum_delete_post_body': 'This cannot be undone.',
  'forum_delete_comment': 'Delete comment?',
  'forum_delete_comment_body': 'Remove this comment?',
  'forum_delete': 'Delete',
  'forum_cancel': 'Cancel',
  'forum_error': 'Forum',

  // ── Splash ──────────────────────────────────────────────────────
  'splash_tagline': 'Learn languages the easy way',
  'splash_loading': 'Loading...',

  // ── Games ─────────────────────────────────────────────────────
  'games_title': 'Games',
  'games_subtitle': 'Practice your skills with fun games',
  'games_empty': 'No games available yet.',
  'game_type': 'Type',
  'game_lesson': 'Lesson',
  'game_status': 'Status',
  'game_active': 'Active',
  'game_inactive': 'Inactive',
  'game_view_history': 'View History',
  'game_delete': 'Delete',
  'game_delete_confirm_title': 'Delete Game',
  'game_delete_confirm_body': 'Are you sure you want to delete this game?',
  'game_history': 'Session History',
  'game_history_empty': 'No sessions yet.',
  'game_score': 'Score',
  'game_correct': 'correct',
  'retry': 'Retry',

  // ── Leaderboard ──────────────────────────────────────────────
  'leaderboard_global': 'Global',
  'leaderboard_empty': 'No leaderboard data yet.',
  'leaderboard_games_played': 'games played',

  // ── User History ──────────────────────────────────────────────
  'history_title': 'My History',
  'history_subtitle': 'All your game attempts',
  'history_empty': 'No game sessions yet. Start playing!',
  'history_total_sessions': 'Sessions',
  'history_best_score': 'Best Score',
  'history_avg_accuracy': 'Avg Accuracy',
  'history_recent': 'Recent Attempts',
  'history_btn': 'My Game History',
  'history_btn_label': 'Activity',

  // ── Submit Score ───────────────────────────────────────────────
  'submit_score': 'Submit Score',
  'submit_score_title': 'Submit Your Score',
  'submit_score_hint': 'Enter your score',
  'submit_score_required': 'Please enter a score',
  'submit_score_invalid': 'Enter a valid score',
  'submit_score_submit': 'Submit',
  'submit_score_success_title': 'Score Submitted!',
  'submit_score_success': 'Your score has been recorded.',

  // ── IELTS Module ──────────────────────────────────────────────
  'ielts_title': 'IELTS Preparation',
  'ielts_subtitle': 'Research-based strategies for top scores',
  'ielts_reading': 'Reading',
  'ielts_listening': 'Listening',
  'ielts_writing': 'Writing',
  'ielts_speaking': 'Speaking',
  'ielts_vocabulary': 'Academic Vocabulary',
  'ielts_games': 'IELTS Mini Games',
  'ielts_band_calc': 'Band Score Calculator',
  'ielts_practice_sessions': 'Practice Sessions',
  'ielts_sessions_completed': 'sessions completed',
  'ielts_sections': 'IELTS Sections',
  'ielts_study_tools': 'Study Tools',
  'ielts_submit': 'Submit Answers',
  'ielts_correct_answers': 'Correct Answers',
  'ielts_show_model': 'Show Model Answer',
  'ielts_hide_model': 'Hide Model Answer',
  'ielts_complete_session': 'Complete Session',
  'ielts_start_review': 'Start Review Session',
  'ielts_due': 'due',
  'ielts_total': 'Total',
};

const _bn = <String, String>{
  // ── Login ───────────────────────────────────────────────────────
  'login_title': 'Login করুন',
  'login_helper': 'আপনার একাউন্টে প্রবেশ করুন',
  'login_forgot': 'Password ভুলে গেছেন?',
  'login_signup_prompt': 'একাউন্ট নেই? Sign Up করুন',
  'login_error': 'Email বা password ভুল হয়েছে। আবার চেষ্টা করুন।',
  'login_empty_fields': 'আপনার email এবং password দিন।',
  'login_generic_error': 'কিছু একটা সমস্যা হয়েছে। আবার চেষ্টা করুন।',
  'sign_in': 'Sign in',
  'forgot_password': 'Password ভুলে গেছেন?',
  'or_sign_in_with': 'অথবা এর মাধ্যমে Login করুন',
  'new_here': 'নতুন এখানে?',
  'lets_sign_up': 'Sign Up করুন',
  'enter_email': 'Email address দিন',
  'enter_password': 'Password দিন',

  // ── Sign Up ─────────────────────────────────────────────────────
  'signup_title': 'নতুন Account তৈরি করুন',
  'signup_subtitle': 'আপনার অ্যাকাউন্ট তৈরি করুন',
  'signup_name_label': 'আপনার নাম',
  'signup_name_hint': 'পুরো নাম দিন',
  'signup_email_label': 'Email address',
  'signup_email_hint': 'আপনার email দিন',
  'signup_phone_label': 'মোবাইল নম্বর',
  'signup_phone_hint': '017XXXXXXXX',
  'signup_pass_label': 'Password দিন',
  'signup_pass_hint': 'কমপক্ষে ৮ অক্ষর দিন',
  'signup_confirm_label': 'Password নিশ্চিত করুন',
  'signup_confirm_hint': 'আবার password দিন',
  'signup_button': 'Continue',
  'signup_have_account': 'একাউন্ট আছে? ',
  'signup_sign_in': 'Sign In করুন',

  // ── Validation ──────────────────────────────────────────────────
  'val_name_required': 'নাম দেওয়া বাধ্যতামূলক',
  'val_name_length': 'নাম কমপক্ষে ৩ অক্ষরের হতে হবে',
  'val_name_format': 'নামে শুধু অক্ষর, স্পেস বা হাইফেন ব্যবহার করুন',
  'val_email_required': 'Email address দেওয়া বাধ্যতামূলক',
  'val_email_format': 'সঠিক email address দিন',
  'val_phone_required': 'ফোন নম্বর দেওয়া বাধ্যতামূলক',
  'val_phone_format': 'সঠিক BD নম্বর দিন (যেমন 017XXXXXXXX)',
  'val_pass_required': 'Password দেওয়া বাধ্যতামূলক',
  'val_pass_length': 'কমপক্ষে ৮ অক্ষর হতে হবে',
  'val_pass_uppercase': 'বড় হাতের অক্ষর অন্তর্ভুক্ত করুন',
  'val_pass_number': 'সংখ্যা অন্তর্ভুক্ত করুন',
  'val_pass_special': 'বিশেষ চিহ্ন অন্তর্ভুক্ত করুন (যেমন @, #, !)',
  'val_confirm_required': 'আপনার password নিশ্চিত করুন',
  'val_confirm_match': 'Password মিলছে না',

  // ── Course List ─────────────────────────────────────────────────
  'programs': 'Programs',
  'logout': 'Logout',
  'choose_course': 'শেখা শুরু করতে একটি course বেছে নিন',
  'lessons_count': '@count টি Lesson',

  // ── Lesson ──────────────────────────────────────────────────────
  'back': 'Back',
  'lesson_not_found': 'Lesson পাওয়া যায়নি।',
  'failed_load_video': 'Video লোড করা যাচ্ছে না',
  'quizzes': 'Quizzes',
  'passing_score': 'Passing score: @score%',
  'start': 'Start',

  // ── Kana Chart ──────────────────────────────────────────────────
  'memory_hint': 'মনে রাখার কৌশল',
  'audio_coming_soon': '"@romaji"-এর অডিও শীঘ্রই আসছে!',
  'listen_to': '"@romaji" শুনুন',

  // ── Profile ─────────────────────────────────────────────────────
  'profile': 'Profile',
  'your_information': 'আপনার তথ্য',
  'name_label': 'নাম',
  'email_label': 'Email',
  'bio_label': 'Bio',
  'no_bio': 'এখনো কোনো bio নেই।',
  'profile_logout_confirm': 'আপনি কি Logout করতে চান?',
  'profile_logout_yes': 'হ্যাঁ, Logout করুন',
  'profile_cancel': 'বাদ দিন',

  // ── Language Picker ─────────────────────────────────────────────
  'app_language': 'অ্যাপের ভাষা',
  'language_english': 'English',
  'language_bangla': 'বাংলিশ (Banglish)',

  // ── Nav (bottom bar) ───────────────────────────────────────────
  'nav_learn': 'শিখুন',
  'nav_practice': 'প্র্যাকটিস',
  'nav_profile': 'প্রোফাইল',
  'nav_community': 'কমিউনিটি',
  'nav_leaderboard': 'লিডারবোর্ড',

  // ── Home / Learn tab ──────────────────────────────────────────
  'home_subtitle': 'আজ কোন ভাষা শিখবেন?',
  'choose_language_program': 'কোন ভাষা শিখবেন বেছে নিন',
  'select_one_subtitle': 'একটি বেছে নিন এবং কোর্স ও লেসন দেখুন',

  // ── Coming Soon ────────────────────────────────────────────────
  'coming_soon': 'শীঘ্রই আসছে',

  // ── Forum (Community) ─────────────────────────────────────────
  'forum_title': 'কমিউনিটি ফোরাম',
  'forum_all_posts': 'সব পোস্ট',
  'forum_threads': 'থ্রেড',
  'forum_empty': 'এখনো কোনো পোস্ট নেই। আলোচনা শুরু করুন!',
  'forum_new_post': 'নতুন পোস্ট',
  'forum_create': 'পোস্ট তৈরি',
  'forum_title_field': 'শিরোনাম',
  'forum_body_field': 'আপনি কী শেয়ার করতে চান?',
  'forum_publish': 'প্রকাশ করুন',
  'forum_create_required': 'শিরোনাম ও বার্তা দিন।',
  'forum_post': 'পোস্ট',
  'forum_untitled': 'শিরোনামহীন',
  'forum_comments': 'মন্তব্য',
  'forum_no_comments': 'এখনো মন্তব্য নেই। প্রথম হন!',
  'forum_comment_hint': 'মন্তব্য লিখুন…',
  'forum_delete_post': 'পোস্ট মুছবেন?',
  'forum_delete_post_body': 'এটি ফেরানো যাবে না।',
  'forum_delete_comment': 'মন্তব্য মুছবেন?',
  'forum_delete_comment_body': 'এই মন্তব্য সরাবেন?',
  'forum_delete': 'মুছুন',
  'forum_cancel': 'বাদ দিন',
  'forum_error': 'ফোরাম',

  // ── Splash ──────────────────────────────────────────────────────
  'splash_tagline': 'ভাষা শেখা এখন সহজ',
  'splash_loading': 'প্রস্তুত হচ্ছে...',

  // ── Games ─────────────────────────────────────────────────────
  'games_title': 'Games',
  'games_subtitle': 'মজার game খেলে skill প্র্যাকটিস করুন',
  'games_empty': 'এখনো কোনো game নেই।',
  'game_type': 'ধরন',
  'game_lesson': 'Lesson',
  'game_status': 'অবস্থা',
  'game_active': 'সক্রিয়',
  'game_inactive': 'নিষ্ক্রিয়',
  'game_view_history': 'History দেখুন',
  'game_delete': 'মুছুন',
  'game_delete_confirm_title': 'Game মুছুন',
  'game_delete_confirm_body': 'আপনি কি এই game মুছতে চান?',
  'game_history': 'Session History',
  'game_history_empty': 'এখনো কোনো session নেই।',
  'game_score': 'Score',
  'game_correct': 'সঠিক',
  'retry': 'আবার চেষ্টা করুন',

  // ── Leaderboard ──────────────────────────────────────────────
  'leaderboard_global': 'Global',
  'leaderboard_empty': 'এখনো leaderboard data নেই।',
  'leaderboard_games_played': 'টি game খেলেছেন',

  // ── User History ──────────────────────────────────────────────
  'history_title': 'আমার History',
  'history_subtitle': 'আপনার সব game attempt',
  'history_empty': 'এখনো কোনো session নেই। খেলা শুরু করুন!',
  'history_total_sessions': 'Session',
  'history_best_score': 'সেরা Score',
  'history_avg_accuracy': 'গড় নির্ভুলতা',
  'history_recent': 'সাম্প্রতিক Attempt',
  'history_btn': 'আমার Game History',
  'history_btn_label': 'কার্যকলাপ',

  // ── Submit Score ───────────────────────────────────────────────
  'submit_score': 'Score জমা দিন',
  'submit_score_title': 'Score জমা দিন',
  'submit_score_hint': 'Score লিখুন',
  'submit_score_required': 'Score দিন',
  'submit_score_invalid': 'সঠিক Score দিন',
  'submit_score_submit': 'জমা দিন',
  'submit_score_success_title': 'Score জমা হয়েছে!',
  'submit_score_success': 'আপনার score সংরক্ষিত হয়েছে।',

  // ── IELTS Module ──────────────────────────────────────────────
  'ielts_title': 'IELTS প্রস্তুতি',
  'ielts_subtitle': 'Top score-এর জন্য গবেষণা-ভিত্তিক কৌশল',
  'ielts_reading': 'Reading',
  'ielts_listening': 'Listening',
  'ielts_writing': 'Writing',
  'ielts_speaking': 'Speaking',
  'ielts_vocabulary': 'Academic শব্দভাণ্ডার',
  'ielts_games': 'IELTS Mini Games',
  'ielts_band_calc': 'Band Score Calculator',
  'ielts_practice_sessions': 'Practice Sessions',
  'ielts_sessions_completed': 'টি session সম্পন্ন',
  'ielts_sections': 'IELTS Sections',
  'ielts_study_tools': 'Study Tools',
  'ielts_submit': 'উত্তর জমা দিন',
  'ielts_correct_answers': 'সঠিক উত্তর',
  'ielts_show_model': 'Model Answer দেখুন',
  'ielts_hide_model': 'Model Answer লুকান',
  'ielts_complete_session': 'Session সম্পন্ন করুন',
  'ielts_start_review': 'Review Session শুরু করুন',
  'ielts_due': 'বাকি',
  'ielts_total': 'মোট',
};
