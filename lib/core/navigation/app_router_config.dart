import 'package:flutter/material.dart';

import 'app_route_paths.dart';
import 'app_router_observer.dart';

/// Global configuration for the application's router.
abstract final class AppRouterConfig {
  AppRouterConfig._();

  /// Default page transition duration.
  static const Duration transitionDuration = Duration(
    milliseconds: 250,
  );

  /// Default transition curve.
  static const Curve transitionCurve = Curves.easeOutCubic;

  /// Enable GoRouter diagnostic logs.
  static const bool debugLogDiagnostics = false;

  /// Initial route displayed when the application starts.
  ///
  /// عدل Home إذا كان اسم المسار مختلف داخل AppRoutePaths.
  static const String initialLocation = AppRoutePaths.home;

  /// Root navigator key.
  static final GlobalKey<NavigatorState> rootNavigatorKey =
  GlobalKey<NavigatorState>(
    debugLabel: 'RootNavigator',
  );

  /// Shell navigator key.
  static final GlobalKey<NavigatorState> shellNavigatorKey =
  GlobalKey<NavigatorState>(
    debugLabel: 'ShellNavigator',
  );

  /// Global router observers.
  static final List<NavigatorObserver> observers = [
    AppRouterObserver(),
  ];
}