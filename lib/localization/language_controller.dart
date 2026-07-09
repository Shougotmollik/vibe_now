import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_localizations.dart';

class LanguageController extends GetxController {
  static LanguageController get to => Get.find<LanguageController>();

  final Rx<Locale> _locale = AppLocalizations.fallbackLocale.obs;

  Locale get locale => _locale.value;

  // Load saved language preference on app startup
  Future<void> loadSavedLanguage() async {
    final savedLocale = await LanguageStorage.getSavedLanguage();
    _locale.value = savedLocale;
  }

  /// Switch to a new language. Saves preference and updates locale.
  Future<void> changeLanguage(Locale newLocale) async {
    if (!AppLocalizations.supportedLocales.contains(newLocale)) return;
    _locale.value = newLocale;
    await LanguageStorage.saveLanguage(newLocale);
    // Force GoRouter rebuild via the refresh notifier
    _localeNotifier.value++;
    update();
  }

  // Get current language code string (e.g. 'en', 'de')
  String get currentLanguageCode => _locale.value.languageCode;

  // Whether the current locale is German
  bool get isGerman => _locale.value.languageCode == 'de';

  // Whether the current locale is English
  bool get isEnglish => _locale.value.languageCode == 'en';

  // ValueNotifier for GoRouter refreshListenable
  static final ValueNotifier<int> _localeNotifier = ValueNotifier<int>(0);

  // Expose the notifier for GoRouter
  static ValueNotifier<int> get localeNotifier => _localeNotifier;
}
