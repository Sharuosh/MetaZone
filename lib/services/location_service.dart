import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Returns the user's current location.
  ///
  /// Throws:
  /// - Exception when location services are disabled.
  /// - Exception when location permission is denied.
  /// - Exception when location permission is permanently denied.
  Future<Position> getCurrentLocation() async {
    final bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently denied. '
            'Please enable it from app settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );
  }

  /// Emits location updates while the app is running.
  ///
  /// A new position is emitted after the device moves
  /// approximately 3 meters.
  Stream<Position> get locationStream {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      ),
    );
  }

  /// Returns the last known location when available.
  ///
  /// Useful as a fast fallback when a fresh GPS fix takes time.
  Future<Position?> getLastKnownLocation() async {
    return Geolocator.getLastKnownPosition();
  }

  /// Opens the device location settings.
  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  /// Opens the MetaZone app settings.
  Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }

  /// Checks whether the user has granted location permission.
  Future<bool> hasLocationPermission() async {
    final LocationPermission permission =
    await Geolocator.checkPermission();

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Checks whether the device location service is enabled.
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Returns the current location accuracy status.
  ///
  /// On supported platforms this can tell us whether the
  /// user granted precise or reduced/approximate location.
  Future<LocationAccuracyStatus> getLocationAccuracy() {
    return Geolocator.getLocationAccuracy();
  }
}