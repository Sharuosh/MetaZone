import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'weather_snapshot.dart';

class WeatherService {
  WeatherService({
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _baseUrl =
      'https://api.open-meteo.com/v1/forecast';

  Future<WeatherSnapshot> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final Response<dynamic> response =
      await _dio.get<dynamic>(
        _baseUrl,
        queryParameters: <String, dynamic>{
          'latitude': latitude,
          'longitude': longitude,
          'current':
          'temperature_2m,weather_code,is_day',
          'temperature_unit': 'celsius',
          'timezone': 'auto',
          'forecast_days': 1,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Weather request failed with status '
              '${response.statusCode}.',
        );
      }

      final dynamic rawData = response.data;

      if (rawData is! Map) {
        throw Exception(
          'Invalid weather response.',
        );
      }

      final dynamic rawCurrent =
      rawData['current'];

      if (rawCurrent is! Map) {
        throw Exception(
          'Current weather data is missing.',
        );
      }

      final Map<String, dynamic> current =
      Map<String, dynamic>.from(rawCurrent);

      final dynamic rawTemperature =
      current['temperature_2m'];

      final dynamic rawWeatherCode =
      current['weather_code'];

      final dynamic rawIsDay =
      current['is_day'];

      if (rawTemperature is! num ||
          rawWeatherCode is! num ||
          rawIsDay is! num) {
        throw Exception(
          'Incomplete current weather data.',
        );
      }

      final double temperature =
      rawTemperature.toDouble();

      final int weatherCode =
      rawWeatherCode.toInt();

      final bool isDay =
          rawIsDay.toInt() == 1;

      final WeatherDescription description =
      _describeWeather(
        weatherCode: weatherCode,
        isDay: isDay,
      );

      return WeatherSnapshot(
        temperatureCelsius: temperature,
        weatherCode: weatherCode,
        isDay: isDay,
        label: description.label,
        icon: description.icon,
        observedAt: DateTime.now(),
      );
    } on DioException catch (error) {
      throw Exception(
        'Unable to load weather: '
            '${error.message ?? 'Network error'}',
      );
    }
  }

  WeatherDescription _describeWeather({
    required int weatherCode,
    required bool isDay,
  }) {
    switch (weatherCode) {
      case 0:
        return WeatherDescription(
          label:
          isDay ? 'Clear sky' : 'Clear night',
          icon:
          isDay
              ? Icons.wb_sunny_rounded
              : Icons.nightlight_round,
        );

      case 1:
        return WeatherDescription(
          label: 'Mainly clear',
          icon:
          isDay
              ? Icons.wb_sunny_outlined
              : Icons.nightlight_outlined,
        );

      case 2:
        return WeatherDescription(
          label: 'Partly cloudy',
          icon:
          isDay
              ? Icons.cloud_rounded
              : Icons.nights_stay_rounded,
        );

      case 3:
        return const WeatherDescription(
          label: 'Overcast',
          icon: Icons.cloud_rounded,
        );

      case 45:
      case 48:
        return const WeatherDescription(
          label: 'Foggy',
          icon: Icons.cloud_rounded,
        );

      case 51:
      case 53:
      case 55:
        return const WeatherDescription(
          label: 'Drizzle',
          icon: Icons.grain_rounded,
        );

      case 56:
      case 57:
        return const WeatherDescription(
          label: 'Freezing drizzle',
          icon: Icons.ac_unit_rounded,
        );

      case 61:
      case 63:
      case 65:
        return const WeatherDescription(
          label: 'Rain',
          icon: Icons.water_drop_rounded,
        );

      case 66:
      case 67:
        return const WeatherDescription(
          label: 'Freezing rain',
          icon: Icons.ac_unit_rounded,
        );

      case 71:
      case 73:
      case 75:
        return const WeatherDescription(
          label: 'Snow',
          icon: Icons.ac_unit_rounded,
        );

      case 77:
        return const WeatherDescription(
          label: 'Snow grains',
          icon: Icons.grain_rounded,
        );

      case 80:
      case 81:
      case 82:
        return const WeatherDescription(
          label: 'Rain showers',
          icon: Icons.umbrella_rounded,
        );

      case 85:
      case 86:
        return const WeatherDescription(
          label: 'Snow showers',
          icon: Icons.ac_unit_rounded,
        );

      case 95:
        return const WeatherDescription(
          label: 'Thunderstorm',
          icon: Icons.thunderstorm_rounded,
        );

      case 96:
      case 99:
        return const WeatherDescription(
          label: 'Thunderstorm with hail',
          icon: Icons.thunderstorm_rounded,
        );

      default:
        return WeatherDescription(
          label: 'Weather',
          icon:
          isDay
              ? Icons.wb_sunny_rounded
              : Icons.nightlight_round,
        );
    }
  }
}

class WeatherDescription {
  const WeatherDescription({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}