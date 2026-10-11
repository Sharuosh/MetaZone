import 'package:flutter/material.dart';

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.temperatureCelsius,
    required this.weatherCode,
    required this.isDay,
    required this.label,
    required this.icon,
    this.observedAt,
  });

  final double temperatureCelsius;
  final int weatherCode;
  final bool isDay;
  final String label;
  final IconData icon;
  final DateTime? observedAt;

  String get temperatureLabel {
    return '${temperatureCelsius.round()}°C';
  }

  WeatherSnapshot copyWith({
    double? temperatureCelsius,
    int? weatherCode,
    bool? isDay,
    String? label,
    IconData? icon,
    DateTime? observedAt,
  }) {
    return WeatherSnapshot(
      temperatureCelsius:
      temperatureCelsius ?? this.temperatureCelsius,
      weatherCode:
      weatherCode ?? this.weatherCode,
      isDay:
      isDay ?? this.isDay,
      label:
      label ?? this.label,
      icon:
      icon ?? this.icon,
      observedAt:
      observedAt ?? this.observedAt,
    );
  }
}