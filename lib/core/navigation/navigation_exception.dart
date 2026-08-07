class NavigationException implements Exception {
  const NavigationException(
      this.message,
      );

  final String message;

  @override
  String toString() {
    return 'NavigationException($message)';
  }
}