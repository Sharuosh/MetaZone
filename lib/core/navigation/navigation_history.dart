import 'dart:collection';

class NavigationHistory {
  NavigationHistory({
    this.maxEntries = 100,
  });

  final int maxEntries;

  final ListQueue<String> _history = ListQueue<String>();

  List<String> get entries => List.unmodifiable(_history);

  String? get current =>
      _history.isEmpty ? null : _history.last;

  String? get previous {
    if (_history.length < 2) {
      return null;
    }

    return _history.elementAt(_history.length - 2);
  }

  bool get isEmpty => _history.isEmpty;

  int get length => _history.length;

  void push(String route) {
    if (_history.isNotEmpty && _history.last == route) {
      return;
    }

    if (_history.length >= maxEntries) {
      _history.removeFirst();
    }

    _history.addLast(route);
  }

  String? pop() {
    if (_history.isEmpty) {
      return null;
    }

    return _history.removeLast();
  }

  bool contains(String route) {
    return _history.contains(route);
  }

  void clear() {
    _history.clear();
  }

  @override
  String toString() {
    return _history.toList().toString();
  }
}