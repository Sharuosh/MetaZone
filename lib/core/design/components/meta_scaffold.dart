import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// ===============================================================
/// MetaZone Scaffold
/// ===============================================================

class MetaScaffold extends StatelessWidget {
  const MetaScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.padding = AppSpacing.screen,
    this.safeArea = true,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });

  final Widget child;

  final PreferredSizeWidget? appBar;

  final Widget? floatingActionButton;

  final Widget? bottomNavigationBar;

  final Widget? drawer;

  final Widget? endDrawer;

  final EdgeInsetsGeometry padding;

  final bool safeArea;

  final bool extendBody;

  final bool extendBodyBehindAppBar;

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Widget body = Padding(
      padding: padding,
      child: child,
    );

    if (safeArea) {
      body = SafeArea(child: body);
    }

    return Scaffold(
      backgroundColor:
      backgroundColor ?? AppColors.background,
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      extendBody: extendBody,
      extendBodyBehindAppBar:
      extendBodyBehindAppBar,
      body: body,
    );
  }
}