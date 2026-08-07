abstract interface class NavigationPolicy {
  const NavigationPolicy();

  bool allow(
      String route,
      );
}