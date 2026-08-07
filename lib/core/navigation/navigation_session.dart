import 'navigation_history.dart';
import 'navigation_stack.dart';

class NavigationSession {
  NavigationSession({
    NavigationHistory? history,
    NavigationStack? stack,
  })  : history = history ?? NavigationHistory(),
        stack = stack ?? NavigationStack();

  final NavigationHistory history;

  final NavigationStack stack;

  String? get currentRoute => stack.current;

  String? get previousRoute => history.previous;

  bool get hasRoute => stack.isNotEmpty;

  void push(String route) {
    history.push(route);
    stack.push(route);
  }

  void replace(String route) {
    history.push(route);
    stack.replace(route);
  }

  String? pop() {
    history.pop();
    return stack.pop();
  }

  void popUntil(String route) {
    stack.popUntil(route);

    while (history.current != null &&
        history.current != stack.current) {
      history.pop();
    }
  }

  bool contains(String route) {
    return stack.contains(route);
  }

  void reset() {
    history.clear();
    stack.clear();
  }

  @override
  String toString() {
    return '''
NavigationSession(
  current: $currentRoute,
  previous: $previousRoute,
  stack: ${stack.routes},
)
''';
  }
}