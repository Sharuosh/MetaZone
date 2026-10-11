import 'package:flutter/material.dart';

import 'app_localizations.dart';

/// ===============================================================
/// MetaZone Localization Setup
/// ===============================================================

abstract final class LocalizationSetup {
  LocalizationSetup._();

  static Locale _currentLocale = const Locale('en');

  static Locale get currentLocale => _currentLocale;

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  static Future<void> setLocale(String languageCode) async {
    final normalized = languageCode.toLowerCase();

    final supported = supportedLocales.any(
          (locale) => locale.languageCode == normalized,
    );

    if (!supported) {
      return;
    }

    _currentLocale = Locale(normalized);
  }

  static AppLocalizations createLocalizations(Locale locale) {
    return AppLocalizations(locale);
  }
}