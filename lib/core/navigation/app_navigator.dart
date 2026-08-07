import 'package:flutter/material.dart';

abstract final class AppNavigator {
  AppNavigator._();

  static final GlobalKey<NavigatorState> key =
  GlobalKey<NavigatorState>();
}