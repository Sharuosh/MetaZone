class NavigationResult<T> {
  const NavigationResult({
    this.value,
    this.cancelled = false,
  });

  final T? value;

  final bool cancelled;

  bool get hasValue => value != null;

  NavigationResult<T> copyWith({
    T? value,
    bool? cancelled,
  }) {
    return NavigationResult<T>(
      value: value ?? this.value,
      cancelled: cancelled ?? this.cancelled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NavigationResult<T> &&
        other.value == value &&
        other.cancelled == cancelled;
  }

  @override
  int get hashCode => Object.hash(
    value,
    cancelled,
  );

  @override
  String toString() {
    return 'NavigationResult(value: $value, cancelled: $cancelled)';
  }
}