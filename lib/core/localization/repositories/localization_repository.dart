import '../models/app_locale.dart';
import '../services/localization_service.dart';

final class LocalizationRepository {
  const LocalizationRepository(
      this._service,
      );

  final LocalizationService _service;

  Future<AppLocale> getCurrentLocale() {
    return _service.loadLocale();
  }

  Future<void> changeLocale(
      AppLocale locale,
      ) {
    return _service.saveLocale(locale);
  }

  Future<void> resetLocale() {
    return _service.clearLocale();
  }
}