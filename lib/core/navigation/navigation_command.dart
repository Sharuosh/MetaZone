class NavigationCommand {
  const NavigationCommand({
    required this.route,
    this.extra,
  });

  final String route;

  final Object? extra;
}