import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  late final Map<String, String> _translations;

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

  Future<void> load() async {
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
  }

  String translate(
      String key,
      ) {
    return _translations[key] ?? key;
  }

  String call(
      String key,
      ) {
    return translate(key);
  }

  bool contains(
      String key,
      ) {
    return _translations.containsKey(key);
  }

  Map<String, String> get values =>
      Map.unmodifiable(_translations);
}