import 'dart:async';

import 'package:flutter/material.dart';

import 'package:meta_zone/core/location/location_service.dart';
import 'package:meta_zone/core/location/location_snapshot.dart';
import 'package:meta_zone/core/weather/weather_service.dart';
import 'package:meta_zone/core/weather/weather_snapshot.dart';
import 'package:meta_zone/screens/home/data/governorate_visual_catalog.dart';

import 'data/home_repository.dart';
import 'domain/home_model.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    HomeRepository? repository,
    LocationService? locationService,
    WeatherService? weatherService,
  })  : _repository = repository ?? HomeRepository(),
        _locationService =
            locationService ?? LocationService(),
        _weatherService =
            weatherService ?? WeatherService();

  final HomeRepository _repository;
  final LocationService _locationService;
  final WeatherService _weatherService;

  HomeData? data;
  LocationSnapshot? currentLocation;
  WeatherSnapshot? weather;

  bool isLoading = false;
  bool isLocationLoading = false;
  bool isWeatherLoading = false;

  String? errorMessage;
  String? locationErrorMessage;
  String? weatherErrorMessage;

  Timer? _visualTimer;
  Timer? _weatherTimer;

  bool _disposed = false;
  int _requestId = 0;

  String? get governorateBackgroundAsset {
    final String? governorate =
        currentLocation?.governorateName;

    final String? locationName =
        data?.locationName;

    final String? resolvedName =
        governorate ?? locationName;

    if (resolvedName == null ||
        resolvedName.trim().isEmpty) {
      debugPrint(
        'MetaZone: No governorate name available '
            'for visual background.',
      );

      return null;
    }

    final String? asset =
    GovernorateVisualCatalog.assetForDateTime(
      resolvedName,
    );

    debugPrint(
      'MetaZone Visual → '
          'location="$resolvedName" '
          'period=$currentVisualPeriodCode '
          'asset="$asset"',
    );

    return asset;
  }

  String get currentVisualPeriodCode {
    return GovernorateVisualCatalog
        .periodCodeForDateTime();
  }

  String get weatherTemperature {
    return weather?.temperatureLabel ?? '--';
  }

  String get weatherLabel {
    return weather?.label ?? 'Weather unavailable';
  }

  IconData get weatherIcon {
    final Object? icon = weather?.icon;

    return icon is IconData
        ? icon
        : Icons.cloud_rounded;
  }

  Future<void> load() async {
    final int requestId = ++_requestId;

    _setLoading(true);
    _clearError();

    isLocationLoading = true;
    locationErrorMessage = null;

    notifyListeners();

    LocationSnapshot? location;

    try {
      try {
        location = await _locationService.getCurrentLocation(
          useLastKnownFallback: true,
        );

        if (!_disposed &&
            requestId == _requestId) {
          currentLocation = location;
        }
      } catch (error, stackTrace) {
        debugPrint(
          'MetaZone location failed: $error',
        );

        debugPrintStack(
          stackTrace: stackTrace,
        );

        if (!_disposed &&
            requestId == _requestId) {
          locationErrorMessage =
          'Location is unavailable right now.';
        }
      } finally {
        if (!_disposed &&
            requestId == _requestId) {
          isLocationLoading = false;
          notifyListeners();
        }
      }

      if (_disposed ||
          requestId != _requestId) {
        return;
      }

      final String locationName =
          location?.displayLocationName ??
              'Around you';

      if (location != null) {
        await _loadWeather(
          location: location,
          requestId: requestId,
        );
      } else {
        weatherErrorMessage =
        'Weather location unavailable.';
      }

      if (_disposed ||
          requestId != _requestId) {
        return;
      }

      final HomeData result =
      await _repository.loadHome(
        locationName: locationName,
      );

      if (_disposed ||
          requestId != _requestId) {
        return;
      }

      data = result;

      _scheduleNextVisualChange();

      notifyListeners();
    } catch (error, stackTrace) {
      if (_disposed ||
          requestId != _requestId) {
        return;
      }

      debugPrint(
        'MetaZone Home load failed: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      errorMessage =
      'مش قادرين نحدّث MetaZone دلوقتي. جرّب تاني.';
    } finally {
      if (!_disposed &&
          requestId == _requestId) {
        _setLoading(false);
      }
    }
  }

  Future<void> refresh() async {
    await load();
  }

  Future<void> retryLocation() async {
    if (_disposed) return;

    isLocationLoading = true;
    locationErrorMessage = null;

    notifyListeners();

    try {
      final LocationSnapshot? location =
      await _locationService.getCurrentLocation(
        useLastKnownFallback: false,
      );

      if (_disposed) return;

      currentLocation = location;
      isLocationLoading = false;
      locationErrorMessage = null;

      notifyListeners();

      await load();
    } catch (error, stackTrace) {
      debugPrint(
        'MetaZone location retry failed: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (_disposed) return;

      isLocationLoading = false;

      locationErrorMessage =
      'مش قادرين نحدد موقعك دلوقتي.';

      notifyListeners();
    }
  }

  Future<void> _loadWeather({
    required LocationSnapshot location,
    required int requestId,
  }) async {
    if (_disposed ||
        requestId != _requestId) {
      return;
    }

    isWeatherLoading = true;
    weatherErrorMessage = null;

    notifyListeners();

    try {
      final WeatherSnapshot result =
      await _weatherService.getCurrentWeather(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      if (_disposed ||
          requestId != _requestId) {
        return;
      }

      weather = result;
      weatherErrorMessage = null;
    } catch (error, stackTrace) {
      debugPrint(
        'MetaZone weather failed: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (_disposed ||
          requestId != _requestId) {
        return;
      }

      weatherErrorMessage =
      'Weather is unavailable right now.';
    } finally {
      if (!_disposed &&
          requestId == _requestId) {
        isWeatherLoading = false;

        notifyListeners();

        _scheduleWeatherRefresh();
      }
    }
  }

  void _scheduleWeatherRefresh() {
    _weatherTimer?.cancel();

    if (_disposed) return;

    _weatherTimer = Timer(
      const Duration(minutes: 30),
          () {
        if (_disposed) return;

        _refreshWeatherOnly();
      },
    );
  }

  Future<void> _refreshWeatherOnly() async {
    if (_disposed) return;

    final LocationSnapshot? location =
        currentLocation;

    if (location == null) {
      return;
    }

    final int requestId = _requestId;

    await _loadWeather(
      location: location,
      requestId: requestId,
    );
  }

  void _scheduleNextVisualChange() {
    _visualTimer?.cancel();

    if (_disposed) return;

    final DateTime now = DateTime.now();
    final DateTime nextBoundary =
    _nextVisualBoundary(now);

    final Duration duration =
    nextBoundary.difference(now);

    _visualTimer = Timer(
      duration.isNegative
          ? const Duration(seconds: 1)
          : duration,
          () {
        if (_disposed) return;

        notifyListeners();

        _scheduleNextVisualChange();
      },
    );
  }

  DateTime _nextVisualBoundary(
      DateTime now,
      ) {
    final DateTime today6 = DateTime(
      now.year,
      now.month,
      now.day,
      6,
    );

    final DateTime today14 = DateTime(
      now.year,
      now.month,
      now.day,
      14,
    );

    final DateTime today22 = DateTime(
      now.year,
      now.month,
      now.day,
      22,
    );

    if (now.isBefore(today6)) {
      return today6;
    }

    if (now.isBefore(today14)) {
      return today14;
    }

    if (now.isBefore(today22)) {
      return today22;
    }

    return DateTime(
      now.year,
      now.month,
      now.day + 1,
      6,
    );
  }

  void clearError() {
    if (_disposed) return;

    if (errorMessage == null) {
      return;
    }

    errorMessage = null;

    notifyListeners();
  }

  Future<bool> openLocationSettings() {
    return _locationService.openLocationSettings();
  }

  Future<bool> openAppSettings() {
    return _locationService.openAppSettings();
  }

  void _setLoading(bool value) {
    if (_disposed) return;

    if (isLoading == value) {
      return;
    }

    isLoading = value;

    notifyListeners();
  }

  void _clearError() {
    if (_disposed) return;

    if (errorMessage == null) {
      return;
    }

    errorMessage = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestId++;

    _visualTimer?.cancel();
    _visualTimer = null;

    _weatherTimer?.cancel();
    _weatherTimer = null;

    super.dispose();
  }
}