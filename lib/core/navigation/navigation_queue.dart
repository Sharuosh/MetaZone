import 'dart:collection';

import 'navigation_command.dart';

class NavigationQueue {
  final Queue<NavigationCommand> _queue =
  Queue<NavigationCommand>();

  bool get isEmpty => _queue.isEmpty;

  int get length => _queue.length;

  void add(
      NavigationCommand command,
      ) {
    _queue.addLast(command);
  }

  NavigationCommand? next() {
    if (_queue.isEmpty) {
      return null;
    }

    return _queue.removeFirst();
  }

  void clear() {
    _queue.clear();
  }
}