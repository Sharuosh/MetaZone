// File: lib/screens/main_navigation.dart

import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/app_text_styles.dart';

// Screens
import 'home/home_screen.dart';
import 'home/live_ar_feed_screen.dart';
import 'home/chat/chat_hub_screen.dart';
import 'home/profile/profile_screen.dart';

// AR Camera
import 'package:meta_zone/features/ar_camera/presentation/ar_camera_live_view.dart';
class MainNavigation extends StatefulWidget {
  final Function(String)? onThemeChanged;

  const MainNavigation({
    super.key,
    this.onThemeChanged,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {

  int _index = 0;

  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Widget _screen() {
    switch (_index) {
      case 0:
        return const HomeScreen();

      case 1:
        return const LiveARFeedScreen();

      case 2:
        return const ChatHubScreen();

      case 3:
        return ProfileScreen(
          onThemeChanged: widget.onThemeChanged,
        );

      default:
        return const HomeScreen();
    }
  }

  void _openARCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ARCameraShell(),      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screen(),
      bottomNavigationBar: Container(
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(.92),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceAround,
              children: [

                _nav(
                  Icons.home_rounded,
                  "Home",
                  0,
                ),

                _nav(
                  Icons.explore_rounded,
                  "Feed",
                  1,
                ),

                const SizedBox(width: 72),

                _nav(
                  Icons.chat_bubble_rounded,
                  "Chat",
                  2,
                ),

                _nav(
                  Icons.person_rounded,
                  "Profile",
                  3,
                ),
              ],
            ),

            Positioned(
              bottom: 14,
              child: GestureDetector(
                onTap: _openARCamera,
                child: ScaleTransition(
                  scale: Tween(
                    begin: 1.0,
                    end: 1.15,
                  ).animate(_pulse),
                  child: Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient:
                      AppColors.neonGradient,
                      boxShadow: [
                        BoxShadow(
                          color:
                          AppColors.primarySoft,
                          blurRadius: 38,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 36,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nav(
      IconData icon,
      String label,
      int i,
      ) {
    final active = _index == i;

    return GestureDetector(
      onTap: () {
        setState(() {
          _index = i;
        });
      },
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [

          Icon(
            icon,
            size: active ? 30 : 24,
            color: active
                ? AppColors.primary
                : AppColors.textSoft,
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              color: active
                  ? AppColors.primary
                  : AppColors.textSoft,
            ),
          ),
        ],
      ),
    );
  }
}