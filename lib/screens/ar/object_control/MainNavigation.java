// File: lib/screens/main_navigation.dart
// MetaZone — Main Navigation (updated to open ARCameraView as the primary AR entry)
// Replaces previous behavior which opened the Portal Viewer directly.
// Ensure ARCameraView exists at: lib/screens/ar/camera-icon/ar_camera_view.dart

import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

// SCREENS
import 'home/home_screen.dart';
import 'home/live_ar_feed_screen.dart';
import 'home/chat/chat_hub_screen.dart';
import 'home/profile/profile_screen.dart';

// AR: open camera-icon-first entry
import 'ar/camera/ar_camera_view.dart';

class MainNavigation extends StatefulWidget {
  final Function(String)? onThemeChanged;

  const MainNavigation({super.key, this.onThemeChanged});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _glowOpacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Widget _screenAt(int index) {
    switch (index) {
      case 0:
        return HomeScreen();
      case 1:
        return const LiveARFeedScreen();
      case 2:
        return const ChatHubScreen();
      case 3:
        return ProfileScreen(onThemeChanged: widget.onThemeChanged);
      default:
        return HomeScreen();
    }
  }

  /// OPEN AR ENTRY — now opens the camera-icon-first AR view (ARCameraView).
  void _openARPortal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ARCameraView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screenAt(_currentIndex),
      bottomNavigationBar: Container(
        height: 84,
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(0.9),
          border: Border(top: BorderSide(color: AppColors.border.withOpacity(.35))),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(Icons.home_rounded, 0, "Home"),
                  _navItem(Icons.explore_rounded, 1, "Feed"),
                  const SizedBox(width: 60), // center slot for AR quick action
                  _navItem(Icons.chat_bubble_rounded, 2, "Chat"),
                  _navItem(Icons.person_rounded, 3, "Profile"),
                ],
              ),
            ),
            Positioned(
              bottom: 22,
              child: GestureDetector(
                onTap: _openARPortal,
                child: AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) {
                    return Transform.scale(
                      scale: _scaleAnim.value,
                      child: Opacity(
                        opacity: _glowOpacity.value,
                        child: Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.neonGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primarySoft,
                                blurRadius: 30,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.black,
                            size: 36,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index, String label) {
    final bool active = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? AppColors.primary : AppColors.textSoft, size: active ? 30 : 23),
            const SizedBox(height: 3),
            Text(label, style: AppTextStyles.caption(size: 10).copyWith(color: active ? AppColors.primary : AppColors.textSoft)),
          ],
        ),
      ),
    );
  }
}
