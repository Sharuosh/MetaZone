import 'package:flutter/material.dart';

abstract final class AppConstants {
  const AppConstants._();

  static const Duration apiTimeout = Duration(seconds: 30);

  static const Duration cacheDuration = Duration(hours: 1);

  static const Duration debounceDuration = Duration(
    milliseconds: 400,
  );

  static const Duration defaultAnimationDuration = Duration(
    milliseconds: 250,
  );

  static const int defaultPageSize = 20;

  static const int maxUploadSize = 50 * 1024 * 1024;

  static const double defaultBorderRadius = 16;

  static const double defaultPadding = 16;

  static const double defaultSpacing = 12;
}