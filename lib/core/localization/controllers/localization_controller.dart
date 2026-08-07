import 'package:flutter/material.dart';

import '../models/app_locale.dart';
import '../repositories/localization_repository.dart';

final class LocalizationController extends ChangeNotifier {
  LocalizationController(
      this._repository,
      );

  final LocalizationRepository _repository;

  AppLocale _currentLocale = AppLocale.english;

  AppLocale get currentLocale => _currentLocale;

  Locale get flutterLocale => _currentLocale.locale;

  bool get isRTL => _currentLocale.isRTL;

  bool get isEnglish => _currentLocale.code == 'en';

  bool get isArabic => _currentLocale.code == 'ar';

  Future<void> initialize() async {
    _currentLocale = await _repository.getCurrentLocale();
    notifyListeners();
  }

  Future<void> changeLocale(
      AppLocale locale,
      ) async {
    if (_currentLocale == locale) return;

    await _repository.changeLocale(locale);

    _currentLocale = locale;

    notifyListeners();
  }

  Future<void> reset() async {
    await _repository.resetLocale();

    _currentLocale = AppLocale.english;

    notifyListeners();
  }
}