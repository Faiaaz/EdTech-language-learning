import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages app locale. Default: Banglish (bn_BD).
/// Persists the user's choice in SharedPreferences.
class LocaleController extends GetxController {
  static LocaleController get to => Get.find();

  static const _prefKey = 'app_locale';
  static const _defaultLocale = Locale('bn', 'BD');

  final _locale = _defaultLocale.obs;
  Locale get locale => _locale.value;
  bool get isEnglish => _locale.value.languageCode == 'en';

  @override
  void onInit() {
    super.onInit();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code == 'en') {
      _applyLocale(const Locale('en', 'US'));
    }
  }

  Future<void> switchToEnglish() => _saveAndApply(const Locale('en', 'US'), 'en');
  Future<void> switchToBanglish() => _saveAndApply(const Locale('bn', 'BD'), 'bn');

  Future<void> _saveAndApply(Locale locale, String code) async {
    _applyLocale(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
  }

  void _applyLocale(Locale locale) {
    _locale.value = locale;
    Get.updateLocale(locale);
  }
}
