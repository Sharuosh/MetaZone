import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../metazone_theme.dart';
import '../metazone_theme_data.dart';
import '../metazone_theme_extension.dart';
import '../models/theme_mode_model.dart';
import '../repository/theme_repository.dart';
import '../state/theme_state.dart';

/// ---------------------------------------------------------------------------
/// MetaZone Theme Service
/// ---------------------------------------------------------------------------
///
/// Responsibilities:
/// • Own the Theme State.
/// • Handle all Theme business rules.
/// • Load & save user preference.
/// • Build ThemeData once and cache it.
/// • Expose current ThemeData.
/// • Expose current MetaZoneTheme.
/// • Notify listeners when state changes.
///
/// This service NEVER talks directly to UI.
/// The Controller will delegate to this class.
///
/// ---------------------------------------------------------------------------

final class ThemeService extends ChangeNotifier {
  ThemeService({
    required ThemeRepository repository,
  }) : _repository = repository;

  final ThemeRepository _repository;

  ThemeState _state = ThemeState.initial();

  bool _initialized = false;

  late final MetaZoneTheme _lightTheme =
  throw UnimplementedError('Light theme factory not implemented.');

  late final MetaZoneTheme _darkTheme =
  throw UnimplementedError('Dark theme factory not implemented.');

  late final ThemeData _lightThemeData =
  MetaZoneThemeData.build(
    _lightTheme,
  );

  late final ThemeData _darkThemeData =
  MetaZoneThemeData.build(
    _darkTheme,
  );

  bool get initialized => _initialized;

  ThemeState get state => _state;

  MetaZoneThemeMode get mode =>
      _state.themeMode;

  ThemeMode get flutterThemeMode =>
      _state.flutterThemeMode;

  Brightness get brightness =>
      _state.effectiveBrightness;

  bool get isLight => _state.isLight;

  bool get isDark => _state.isDark;

  bool get isSystem => _state.isSystem;

  ThemeData get themeData =>
      brightness == Brightness.dark
          ? _darkThemeData
          : _lightThemeData;

  MetaZoneTheme get theme =>
      brightness == Brightness.dark
          ? _darkTheme
          : _lightTheme;

  MetaZoneThemeExtension get extension =>
      themeData.extension<
          MetaZoneThemeExtension>()!;

  ThemeData get lightThemeData =>
      _lightThemeData;

  ThemeData get darkThemeData =>
      _darkThemeData;

  MetaZoneTheme get lightTheme =>
      _lightTheme;

  MetaZoneTheme get darkTheme =>
      _darkTheme;

  Future<void> initialize({
    required Brightness platformBrightness,
  }) async {
    if (_initialized) {
      return;
    }

    await _repository.initialize();

    final mode =
    await _repository.loadThemeMode();

    _state = ThemeState(
      themeMode: mode,
      platformBrightness: platformBrightness,
    );

    _initialized = true;

    notifyListeners();
  }

  Future<void> setThemeMode(
      MetaZoneThemeMode mode,
      ) async {
    if (_state.themeMode == mode) {
      return;
    }

    _state = _state.copyWith(
      themeMode: mode,
    );

    await _repository.saveThemeMode(
      mode,
    );

    notifyListeners();
  }

  Future<void> setLightTheme() =>
      setThemeMode(
        MetaZoneThemeMode.light,
      );

  Future<void> setDarkTheme() =>
      setThemeMode(
        MetaZoneThemeMode.dark,
      );

  Future<void> setSystemTheme() =>
      setThemeMode(
        MetaZoneThemeMode.system,
      );

  Future<void> clearPreference() async {
    await _repository.clearThemeMode();

    _state = _state.copyWith(
      themeMode:
      MetaZoneThemeMode.system,
    );

    notifyListeners();
  }

  void updatePlatformBrightness(
      Brightness brightness,
      ) {
    if (_state.platformBrightness ==
        brightness) {
      return;
    }

    _state = _state.copyWith(
      platformBrightness: brightness,
    );

    notifyListeners();
  }

  ThemeData themeFor(
      Brightness brightness,
      ) {
    return brightness ==
        Brightness.dark
        ? _darkThemeData
        : _lightThemeData;
  }

  MetaZoneTheme metaThemeFor(
      Brightness brightness,
      ) {
    return brightness ==
        Brightness.dark
        ? _darkTheme
        : _lightTheme;
  }

  Future<void> reload() async {
    _initialized = false;

    await initialize(
      platformBrightness:
      _state.platformBrightness,
    );
  }

  Map<String, dynamic> get diagnostics {
    return {
      'initialized': _initialized,
      'themeMode': mode.name,
      'brightness':
      brightness.name,
      'platformBrightness':
      _state.platformBrightness.name,
      'effectiveBrightness':
      brightness.name,
    };
  }

  @override
  void dispose() {
    super.dispose();
  }
}