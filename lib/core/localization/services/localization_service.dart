import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_locale.dart';
import '../supported_locales.dart';

final class LocalizationService {
  LocalizationService({
    SharedPreferences? preferences,
  }) : _preferences = preferences;

  static const String _languageKey = 'app_language';

  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    return _preferences ?? await SharedPreferences.getInstance();
  }

  Future<AppLocale> loadLocale() async {
    final prefs = await _prefs;

    final code = prefs.getString(_languageKey);

    if (code == null) {
      return AppLocale.english;
    }

    return SupportedLocales.fromCode(code);
  }

  Future<void> saveLocale(AppLocale locale) async {
    final prefs = await _prefs;

    await prefs.setString(
      _languageKey,
      locale.code,
    );
  }

  Future<void> clearLocale() async {
    final prefs = await _prefs;

    await prefs.remove(_languageKey);
  }

  Future<Locale> currentFlutterLocale() async {
    final locale = await loadLocale();
    return locale.locale;
  }
}
