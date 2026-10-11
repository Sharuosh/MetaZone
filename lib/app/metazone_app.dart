import 'package:flutter/material.dart';

import '../core/theme/theme.dart';
import '../screens/main_navigation.dart';

/// ===============================================================
/// MetaZone Application
/// ===============================================================
///
/// Application root.
/// - Uses the MetaZone Design System
/// - Uses Material 3
/// - Starts directly at MainNavigation
/// - Keeps dark/light theme support
/// ===============================================================

final class MetaZoneApp extends StatelessWidget {
  const MetaZoneApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MetaZone',

      theme: MetaZoneTheme.light(),
      darkTheme: MetaZoneTheme.dark(),
      themeMode: ThemeMode.system,

      home: const MainNavigation(),
    );
  }
}