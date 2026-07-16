import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final String locale;

  AppLocalizations(this.locale);

  static Map<String, dynamic>? _localizedStrings;

  /// تحميل ملف JSON الخاص باللغة
  Future<bool> load() async {
    try {
      final jsonString =
      await rootBundle.loadString('assets/lang/$locale.json');

      _localizedStrings = json.decode(jsonString);
      return true;
    } catch (e) {
      print("❌ Localization Load Error: $e");
      _localizedStrings = {};
      return false;
    }
  }

  /// 🔹 دالة الترجمة الأساسية
  String tr(String key) {
    return _localizedStrings?[key] ?? key;
  }

  /// 🔹 دالة translate() — مطلوبة لـ LocalizationDebug
  String translate(String key) {
    return _localizedStrings?[key] ?? "MISSING";
  }

  /// 🔹 إرجاع كل مفاتيح الترجمة لمود debug
  List<String> get allKeys {
    if (_localizedStrings == null) return [];
    return _localizedStrings!.keys.toList();
  }

  /// 🔹 Localizations.of() handler
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
}
