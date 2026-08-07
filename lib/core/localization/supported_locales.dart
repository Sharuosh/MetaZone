import 'models/app_locale.dart';

abstract final class SupportedLocales {
  const SupportedLocales._();

  static const List<AppLocale> all = [
    AppLocale.english,
    AppLocale.arabic,
  ];

  static AppLocale fromCode(String code) {
    return all.firstWhere(
          (locale) => locale.code == code,
      orElse: () => AppLocale.english,
    );
  }
}