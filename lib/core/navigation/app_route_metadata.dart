import 'models/route_transition.dart';

class AppRouteMetadata {
  const AppRouteMetadata({
    required this.title,
    this.description,
    this.requiresAuthentication = false,
    this.requiresOnboarding = false,
    this.showBottomNavigation = false,
    this.showAppBar = false,
    this.showBackButton = true,
    this.fullScreenDialog = false,
    this.maintainState = true,
    this.transition = RouteTransition.fade,
  });

  final String title;

  final String? description;

  final bool requiresAuthentication;

  final bool requiresOnboarding;

  final bool showBottomNavigation;

  final bool showAppBar;

  final bool showBackButton;

  final bool fullScreenDialog;

  final bool maintainState;

  final RouteTransition transition;

  AppRouteMetadata copyWith({
    String? title,
    String? description,
    bool? requiresAuthentication,
    bool? requiresOnboarding,
    bool? showBottomNavigation,
    bool? showAppBar,
    bool? showBackButton,
    bool? fullScreenDialog,
    bool? maintainState,
    RouteTransition? transition,
  }) {
    return AppRouteMetadata(
      title: title ?? this.title,
      description: description ?? this.description,
      requiresAuthentication:
      requiresAuthentication ?? this.requiresAuthentication,
      requiresOnboarding:
      requiresOnboarding ?? this.requiresOnboarding,
      showBottomNavigation:
      showBottomNavigation ?? this.showBottomNavigation,
      showAppBar: showAppBar ?? this.showAppBar,
      showBackButton: showBackButton ?? this.showBackButton,
      fullScreenDialog: fullScreenDialog ?? this.fullScreenDialog,
      maintainState: maintainState ?? this.maintainState,
      transition: transition ?? this.transition,
    );
  }
}