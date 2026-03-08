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

  // ── Language Picker ─────────────────────────────────────────────
  'app_language': 'App Language',
  'language_english': 'English',
  'language_bangla': 'বাংলিশ (Banglish)',

  // ── Splash ──────────────────────────────────────────────────────
  'splash_tagline': 'Learn languages the easy way',
  'splash_loading': 'Loading...',
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

  // ── Language Picker ─────────────────────────────────────────────
  'app_language': 'অ্যাপের ভাষা',
  'language_english': 'English',
  'language_bangla': 'বাংলিশ (Banglish)',

  // ── Splash ──────────────────────────────────────────────────────
  'splash_tagline': 'ভাষা শেখা এখন সহজ',
  'splash_loading': 'প্রস্তুত হচ্ছে...',
};
