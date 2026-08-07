class NavigationFailure {
  const NavigationFailure({
    required this.message,
  });

  final String message;

  @override
  String toString() {
    return message;
  }
}