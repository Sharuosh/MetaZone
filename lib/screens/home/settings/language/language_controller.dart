import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/localization/localization_setup.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/app_localizations_delegate.dart';

class LanguageController {
  static const String prefKey = "app_language";

  static Future<void> changeLanguage(String code) async {
    await LocalizationSetup.setLocale(code);
  }

  static String currentLanguageCode() {
    return LocalizationSetup.currentLocale.languageCode;
  }
}
