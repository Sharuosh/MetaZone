import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/theme_mode_model.dart';

/// ---------------------------------------------------------------------------
/// MetaZone Theme Repository
/// ---------------------------------------------------------------------------
///
/// Responsibilities:
/// • Read theme preference from local storage.
/// • Save theme preference.
/// • Remove stored preference.
/// • Never notify UI.
/// • Never create ThemeData.
/// • Never contain business logic.
///
/// This is the ONLY class allowed to communicate with
/// SharedPreferences for Theme.
/// ---------------------------------------------------------------------------

abstract interface class ThemeRepository {
  Future<void> initialize();

  bool get isInitialized;

  Future<MetaZoneThemeMode> loadThemeMode();

  Future<void> saveThemeMode(
      MetaZoneThemeMode mode,
      );

  Future<void> clearThemeMode();

  Future<bool> hasStoredTheme();
}

/// ---------------------------------------------------------------------------
/// SharedPreferences Implementation
/// ---------------------------------------------------------------------------

final class SharedPreferencesThemeRepository
    implements ThemeRepository {
  SharedPreferencesThemeRepository();

  static const String _storageKey =
      'metazone_theme_mode';

  SharedPreferences? _preferences;

  @override
  bool get isInitialized =>
      _preferences != null;

  @override
  Future<void> initialize() async {
    if (_preferences != null) {
      return;
    }

    _preferences =
    await SharedPreferences.getInstance();
  }

  SharedPreferences get _storage {
    final preferences = _preferences;

    if (preferences == null) {
      throw StateError(
        'ThemeRepository has not been initialized.',
      );
    }

    return preferences;
  }

  @override
  Future<MetaZoneThemeMode> loadThemeMode() async {
    await initialize();

    final value = _storage.getString(
      _storageKey,
    );

    return MetaZoneThemeModeParser.fromStorage(
      value,
    );
  }

  @override
  Future<void> saveThemeMode(
      MetaZoneThemeMode mode,
      ) async {
    await initialize();

    await _storage.setString(
      _storageKey,
      MetaZoneThemeModeParser.toStorage(
        mode,
      ),
    );
  }

  @override
  Future<void> clearThemeMode() async {
    await initialize();

    await _storage.remove(
      _storageKey,
    );
  }

  @override
  Future<bool> hasStoredTheme() async {
    await initialize();

    return _storage.containsKey(
      _storageKey,
    );
  }

  @visibleForTesting
  SharedPreferences? get preferences =>
      _preferences;
}