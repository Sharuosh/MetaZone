import 'package:flutter/widgets.dart';

abstract final class NavigationKeys {
  const NavigationKeys._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
  GlobalKey<NavigatorState>(
    debugLabel: 'rootNavigator',
  );

  static final GlobalKey<NavigatorState> shellNavigatorKey =
  GlobalKey<NavigatorState>(
    debugLabel: 'shellNavigator',
  );

  static final GlobalKey<NavigatorState> homeNavigatorKey =
  GlobalKey<NavigatorState>(
    debugLabel: 'homeNavigator',
  );

  static final GlobalKey<NavigatorState> exploreNavigatorKey =
  GlobalKey<NavigatorState>(
    debugLabel: 'exploreNavigator',
  );

  static final GlobalKey<NavigatorState> createNavigatorKey =
  GlobalKey<NavigatorState>(
    debugLabel: 'createNavigator',
  );

  static final GlobalKey<NavigatorState> marketplaceNavigatorKey =
  GlobalKey<NavigatorState>(
    debugLabel: 'marketplaceNavigator',
  );

  static final GlobalKey<NavigatorState> profileNavigatorKey =
  GlobalKey<NavigatorState>(
    debugLabel: 'profileNavigator',
  );
}