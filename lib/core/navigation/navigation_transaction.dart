class NavigationTransaction {
  NavigationTransaction({
    required this.id,
    required this.route,
  });

  final String id;

  final String route;

  bool completed = false;

  void finish() {
    completed = true;
  }
}