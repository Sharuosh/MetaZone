import 'package:flutter/material.dart';

import 'package:meta_zone/core/theme/theme.dart';
import 'package:meta_zone/screens/home/data/home_repository.dart';
import 'package:meta_zone/screens/home/domain/home_model.dart';
import 'package:meta_zone/screens/home/domain/home_section_model.dart';
import 'package:meta_zone/screens/home/presentation/home_screen.dart';
import 'package:meta_zone/screens/map/metazone_map_screen.dart';
import 'package:meta_zone/screens/zone/zone_profile_screen.dart';

/// MetaZone V2 navigation shell.
/// Home is the current feature slice; Map is now an in-app MapLibre surface.
class MainNavigation extends StatefulWidget {
  const MainNavigation({
    super.key,
    this.onThemeChanged,
  });

  final Function(String)? onThemeChanged;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  HomeData? _mapHomeData;
  List<NearbyPlace> _mapDirectoryPlaces = const <NearbyPlace>[];
  bool _mapDataLoading = true;
  String? _mapDataError;

  @override
  void initState() {
    super.initState();
    _loadMapDirectory();
  }

  Future<void> _loadMapDirectory() async {
    try {
      // Load the location that matches the pilot directory instead of showing
      // Egypt-wide context while the records are all in New Damietta.
      final HomeRepository repository = HomeRepository();
      final HomeData data = await repository.loadHome();
      final List<NearbyPlace> directory = await repository.loadDirectory(
        area: data.locationName,
      );
      if (!mounted) return;
      setState(() {
        _mapHomeData = data;
        _mapDirectoryPlaces = directory;
        _mapDataError = null;
        _mapDataLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('MetaZone map directory load failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _mapDataError = 'Could not load the MetaZone directory.';
        _mapDataLoading = false;
      });
    }
  }

  List<NearbyPlace> get _mapPlaces => _mapDirectoryPlaces;

  void _openZoneFromMap(NearbyPlace place) {
    final HomeData? data = _mapHomeData;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ZoneProfileScreen(
          place: place,
          locationName: data?.locationName ?? 'Egypt',
          happenings: data?.happenings ?? const <Happening>[],
        ),
      ),
    );
  }

  Widget _buildMapTab() {
    if (_mapDataLoading && _mapHomeData == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_mapHomeData == null && _mapDataError != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.map_outlined, size: 48, color: AppColors.primary),
                  const SizedBox(height: 14),
                  Text(
                    _mapDataError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.text),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _mapDataLoading = true;
                        _mapDataError = null;
                      });
                      _loadMapDirectory();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MetaZoneMapScreen(
      locationName: _mapHomeData?.locationName ?? 'New Damietta, Damietta',
      places: _mapPlaces,
      onPlaceSelected: _openZoneFromMap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _index,
        children: <Widget>[
          const HomeScreen(),
          // Avoid mounting a native map while its tab is not selected.
          _index == 1
              ? _buildMapTab()
              : const SizedBox.shrink(),
          const _ComingSoonScreen(
            icon: Icons.add_circle_outline_rounded,
            title: 'Create',
            message: 'Create actions will be connected next.',
          ),
          const _ComingSoonScreen(
            icon: Icons.auto_awesome_rounded,
            title: 'MetaZone AI',
            message: 'AI will connect to Places and Actions next.',
          ),
          _ComingSoonScreen(
            icon: Icons.person_outline_rounded,
            title: 'Profile',
            message: 'Profile will be connected in a later slice.',
            actionLabel: 'Appearance',
            onAction: () => widget.onThemeChanged?.call('system'),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (int value) => setState(() => _index = value),
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primary.withValues(alpha: 0.18),
      height: 76,
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map_rounded),
          label: 'Map',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline_rounded),
          selectedIcon: Icon(Icons.add_circle_rounded),
          label: 'Create',
        ),
        NavigationDestination(
          icon: Icon(Icons.auto_awesome_outlined),
          selectedIcon: Icon(Icons.auto_awesome_rounded),
          label: 'AI',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 56, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSoft,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              if (actionLabel != null && onAction != null) ...<Widget>[
                const SizedBox(height: 18),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
