import 'package:flutter/widgets.dart';

final class RouteDefinition {
  const RouteDefinition({
    required this.name,
    required this.path,
    required this.builder,
  });

  final String name;

  final String path;

  final Widget Function(
      BuildContext,
      ) builder;
}