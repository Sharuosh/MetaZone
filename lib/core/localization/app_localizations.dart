import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ===============================================================
/// MetaZone App Localizations
/// ===============================================================

final class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  late final Map<String, String> _translations;

  /// -------------------------------------------------------------
  /// Access from widget tree
  /// -------------------------------------------------------------

  static AppLocalizations of(BuildContext context) {
    final instance = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );

    assert(
    instance != null,
    'AppLocalizations not found in widget tree.',
    );

    return instance!;
  }

  /// -------------------------------------------------------------
  /// Load translation file
  /// -------------------------------------------------------------

  Future<bool> load() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/translations/${locale.languageCode}.json',
      );

      final Map<String, dynamic> jsonMap =
      json.decode(jsonString) as Map<String, dynamic>;

      _translations = jsonMap.map(
            (key, value) => MapEntry(
          key,
          value.toString(),
        ),
      );

      return true;
    } catch (e) {
      _translations = <String, String>{};

      debugPrint(
        'MetaZone Localization load failed '
            'for ${locale.languageCode}: $e',
      );

      return false;
    }
  }

  /// -------------------------------------------------------------
  /// Translate
  /// -------------------------------------------------------------

  String translate(String key) {
    return _translations[key] ?? key;
  }

  /// Callable localization API:
  ///
  /// AppLocalizations.of(context)('home1.title')
  ///

  String call(String key) {
    return translate(key);
  }

  /// -------------------------------------------------------------
  /// Check key
  /// -------------------------------------------------------------

  bool contains(String key) {
    return _translations.containsKey(key);
  }

  /// -------------------------------------------------------------
  /// All translation keys
  /// -------------------------------------------------------------

  List<String> get allKeys {
    return List.unmodifiable(_translations.keys);
  }

  /// -------------------------------------------------------------
  /// Read-only translation map
  /// -------------------------------------------------------------

  Map<String, String> get values {
    return Map.unmodifiable(_translations);
  }
}