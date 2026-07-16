import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';
import 'app_localizations_delegate.dart';

// ✔ المسار الصحيح حسب مشروعك
import '../../screens/home/settings/language/supported_locales.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

class LocalizationSetup {
  static late Locale currentLocale;

  /// Notifier لإعادة بناء الـ UI عند تغيير اللغة
  static final ValueNotifier<Locale> localeNotifier =
  ValueNotifier<Locale>(const Locale('en'));

  /// تحميل اللغة عند تشغيل التطبيق
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString("app_language") ?? 'en';

    currentLocale = Locale(saved);
    localeNotifier.value = currentLocale;
  }

  /// تغيير اللغة + حفظها
  static Future<void> setLocale(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("app_language", langCode);

    currentLocale = Locale(langCode);
    localeNotifier.value = currentLocale; // 🔥 تحديث فوري للـ UI
  }

  /// اللغات المدعومة
  static List<Locale> supportedLocales = SupportedLocales.locales;

  /// الـ delegates
  static final List<LocalizationsDelegate<dynamic>> delegates = [
    AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}
