import 'package:flutter/material.dart';

import 'app_localizations.dart';

/// ===============================================================
/// MetaZone App Localizations Delegate
/// ===============================================================

final class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return const [
      'en',
      'ar',
    ].contains(locale.languageCode);
  }

  @override
  bool shouldReload(
      covariant LocalizationsDelegate<AppLocalizations> old,
      ) {
    return false;
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);

    await localizations.load();

    return localizations;
  }
}