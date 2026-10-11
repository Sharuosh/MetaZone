import 'dart:async';
import 'dart:ui' as ui;

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'location_snapshot.dart';

class LocationServiceException implements Exception {
  final String message;

  const LocationServiceException(this.message);

  @override
  String toString() {
    return 'LocationServiceException: $message';
  }
}

class LocationService {
  LocationService({
    Geocoding? geocoding,
  }) : _geocoding = geocoding ??
      Geocoding(
        locale: const ui.Locale(
          'ar',
          'EG',
        ),
      );

  final Geocoding _geocoding;

  Future<LocationSnapshot?> getCurrentLocation({
    bool useLastKnownFallback = true,
  }) async {
    final bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (useLastKnownFallback) {
        return _getLastKnownLocation();
      }

      throw const LocationServiceException(
        'Location services are disabled.',
      );
    }

    final LocationPermission permission =
    await _ensurePermission();

    if (permission == LocationPermission.denied) {
      if (useLastKnownFallback) {
        return _getLastKnownLocation();
      }

      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      if (useLastKnownFallback) {
        return _getLastKnownLocation();
      }

      throw const LocationServiceException(
        'Location permission is permanently denied.',
      );
    }

    try {
      final Position position =
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );

      return _buildSnapshot(position);
    } catch (_) {
      if (useLastKnownFallback) {
        final LocationSnapshot? fallback =
        await _getLastKnownLocation();

        if (fallback != null) {
          return fallback;
        }
      }

      rethrow;
    }
  }

  Future<LocationPermission> _ensurePermission() async {
    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
      await Geolocator.requestPermission();
    }

    return permission;
  }

  Future<LocationSnapshot?> _getLastKnownLocation() async {
    try {
      final Position? position =
      await Geolocator.getLastKnownPosition();

      if (position == null) {
        return null;
      }

      return _buildSnapshot(position);
    } catch (_) {
      return null;
    }
  }

  Future<LocationSnapshot> _buildSnapshot(
      Position position,
      ) async {
    String? governorateName;
    String? cityName;
    String? countryCode;
    String? formattedAddress;

    try {
      final List<Placemark> placemarks =
      await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks.first;

        governorateName =
            _cleanValue(placemark.administrativeArea) ??
                _cleanValue(
                  placemark.subAdministrativeArea,
                );

        cityName =
            _cleanValue(placemark.locality) ??
                _cleanValue(placemark.subLocality);

        countryCode =
            _cleanValue(placemark.isoCountryCode);

        formattedAddress =
            _buildFormattedAddress(placemark);

        governorateName =
            _normalizeGovernorateName(
              governorateName,
            );
      }
    } catch (_) {
      // Location coordinates are still useful even
      // when reverse geocoding is temporarily unavailable.
    }

    return LocationSnapshot(
      latitude: position.latitude,
      longitude: position.longitude,
      governorateName: governorateName,
      cityName: cityName,
      countryCode: countryCode,
      formattedAddress: formattedAddress,
    );
  }

  String? _cleanValue(String? value) {
    final cleaned = value?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }

  String? _buildFormattedAddress(
      Placemark placemark,
      ) {
    final parts = <String>[
      if (_cleanValue(placemark.name) != null)
        _cleanValue(placemark.name)!,
      if (_cleanValue(placemark.subLocality) != null)
        _cleanValue(placemark.subLocality)!,
      if (_cleanValue(placemark.locality) != null)
        _cleanValue(placemark.locality)!,
      if (_cleanValue(
        placemark.administrativeArea,
      ) !=
          null)
        _cleanValue(
          placemark.administrativeArea,
        )!,
      if (_cleanValue(placemark.country) != null)
        _cleanValue(placemark.country)!,
    ];

    if (parts.isEmpty) {
      return null;
    }

    return parts.join('، ');
  }

  String? _normalizeGovernorateName(
      String? value,
      ) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final normalized = value
        .trim()
        .replaceFirst(
      RegExp(
        r'^محافظة\s+',
        caseSensitive: false,
      ),
      '',
    )
        .replaceFirst(
      RegExp(
        r'\s+Governorate$',
        caseSensitive: false,
      ),
      '',
    )
        .trim();

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() async {
    return Geolocator.openAppSettings();
  }

  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() {
    return Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() {
    return Geolocator.requestPermission();
  }
}