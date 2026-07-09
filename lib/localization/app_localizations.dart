import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations_en.dart';
import 'app_localizations_de.dart';

// ==================================================================
//  THE MAIN LOCALIZATION CLASS
// ==================================================================
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// THE ONLY METHOD YOU NEED TO CALL IN YOUR UI:
  ///   final loc = AppLocalizations.of(context);
  ///   loc.translate('signIn') → "Anmelden" or "Sign In"
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Our delegate — tells Flutter how to load translations
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// All delegates needed (ours + Flutter's built-in)
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate, // Date formats, etc.
    GlobalWidgetsLocalizations.delegate, // Text direction (RTL)
    GlobalCupertinoLocalizations.delegate, // Cupertino widgets
  ];

  /// LIST ALL LANGUAGES HERE:
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('de'), // German
  ];

  /// Default language when nothing is saved
  static const Locale fallbackLocale = Locale('en');

  /// Loads the correct translation map based on current locale
  late final Map<String, String> _localizedStrings = _loadStrings();

  Map<String, String> _loadStrings() {
    switch (locale.languageCode) {
      case 'de':
        return AppLocalizationsDe.strings;
      case 'en':
      default:
        return AppLocalizationsEn.strings;
    }
  }

  /// TRANSLATE: looks up a key and returns the translated text.
  /// If the key is missing, it returns the key itself so you
  /// can see what's missing during development.
  String translate(String key) {
    return _localizedStrings[key] ?? '**$key**';
  }

  /// Returns 'en', 'de', etc. — the current language code
  String get currentLanguageCode => locale.languageCode;
}

// ==================================================================
//  LOCALIZATIONS DELEGATE
// ==================================================================
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// ==================================================================
//  LANGUAGE STORAGE — Saves user's choice to device
// ==================================================================
class LanguageStorage {
  static const String _key = 'app_language';

  /// Load saved language. Returns fallback if nothing saved.
  static Future<Locale> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && ['en', 'de'].contains(code)) {
      return Locale(code);
    }
    return AppLocalizations.fallbackLocale;
  }

  /// Save the user's language choice
  static Future<void> saveLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}
