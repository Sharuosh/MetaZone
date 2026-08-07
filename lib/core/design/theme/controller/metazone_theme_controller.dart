import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../metazone_theme.dart';
import '../metazone_theme_data.dart';
import '../metazone_theme_extension.dart';
import '../models/theme_mode_model.dart';
import '../service/theme_service.dart';

final class MetaZoneThemeController extends ChangeNotifier {
  MetaZoneThemeController({
    required ThemeService service,
  }) : _service = service {
    _service.addListener(_onServiceChanged);
  }

  final ThemeService _service;

  void _onServiceChanged() {
    notifyListeners();
  }

  Future<void> initialize() async {
    await _service.initialize(
      platformBrightness:
      WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
  }

  ThemeService get service => _service;

  ThemeData get themeData => _service.themeData;

  ThemeData get lightThemeData => _service.lightThemeData;

  ThemeData get darkThemeData => _service.darkThemeData;

  MetaZoneTheme get theme => _service.theme;

  MetaZoneTheme get lightTheme => _service.lightTheme;

  MetaZoneTheme get darkTheme => _service.darkTheme;

  MetaZoneThemeExtension get extension => _service.extension;

  ThemeMode get flutterThemeMode => _service.flutterThemeMode;

  Brightness get brightness => _service.brightness;

  MetaZoneThemeMode get mode => _service.mode;

  bool get initialized => _service.initialized;

  bool get isLight => _service.isLight;

  bool get isDark => _service.isDark;

  bool get isSystem => _service.isSystem;

  Future<void> setThemeMode(
      MetaZoneThemeMode mode,
      ) =>
      _service.setThemeMode(mode);

  Future<void> setLightTheme() =>
      _service.setLightTheme();

  Future<void> setDarkTheme() =>
      _service.setDarkTheme();

  Future<void> setSystemTheme() =>
      _service.setSystemTheme();

  Future<void> clearPreference() =>
      _service.clearPreference();

  void updatePlatformBrightness(
      Brightness brightness,
      ) =>
      _service.updatePlatformBrightness(brightness);

  Map<String, dynamic> get diagnostics =>
      _service.diagnostics;

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }
}