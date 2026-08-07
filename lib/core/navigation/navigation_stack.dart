import 'dart:collection';

class NavigationStack {
  NavigationStack();

  final ListQueue<String> _stack = ListQueue<String>();

  List<String> get routes => List.unmodifiable(_stack);

  bool get isEmpty => _stack.isEmpty;

  bool get isNotEmpty => _stack.isNotEmpty;

  int get length => _stack.length;

  String? get current =>
      _stack.isEmpty ? null : _stack.last;

  String? get root =>
      _stack.isEmpty ? null : _stack.first;

  void push(String route) {
    _stack.addLast(route);
  }

  String? pop() {
    if (_stack.isEmpty) {
      return null;
    }

    return _stack.removeLast();
  }

  String? peek() {
    if (_stack.isEmpty) {
      return null;
    }

    return _stack.last;
  }

  bool contains(String route) {
    return _stack.contains(route);
  }

  void replace(String route) {
    if (_stack.isNotEmpty) {
      _stack.removeLast();
    }

    _stack.addLast(route);
  }

  void popUntil(String route) {
    while (_stack.isNotEmpty && _stack.last != route) {
      _stack.removeLast();
    }
  }

  void clear() {
    _stack.clear();
  }

  @override
  String toString() {
    return _stack.toList().toString();
  }
}