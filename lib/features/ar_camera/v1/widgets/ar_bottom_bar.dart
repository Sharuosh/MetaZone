import 'package:flutter/material.dart';

import '../theme/ar_camera_theme.dart';
import 'ar_glass.dart';

/// Bottom navigation for MetaZone AR Camera V1.
///
/// Final V1 structure:
///   Explore  |  Create  |  Profile
///
/// Gallery belongs inside the relevant creation flow.
class ARBottomBar extends StatelessWidget {
  const ARBottomBar({
    super.key,
    required this.onExplore,
    required this.onCreate,
    required this.onProfile,
    this.activeItem = ARBottomBarItem.create,
  });

  final VoidCallback onExplore;
  final VoidCallback onCreate;
  final VoidCallback onProfile;

  final ARBottomBarItem activeItem;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          ARCameraTheme.horizontalPadding,
          0,
          ARCameraTheme.horizontalPadding,
          ARCameraTheme.bottomSafeSpacing,
        ),
        child: ARGlass(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 3,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(18),
          ),
          blur: ARCameraTheme.glassBlurStrong,
          opacity: ARCameraTheme.glassStrongOpacity,
          child: SizedBox(
            height: 34,
            child: Row(
              children: [
                Expanded(
                  child: _BottomBarItem(
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore_rounded,
                    label: 'Explore',
                    active: activeItem == ARBottomBarItem.explore,
                    onTap: onExplore,
                  ),
                ),

                Expanded(
                  child: _CreateButton(
                    active: activeItem == ARBottomBarItem.create,
                    onTap: onCreate,
                  ),
                ),

                Expanded(
                  child: _BottomBarItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile',
                    active: activeItem == ARBottomBarItem.profile,
                    onTap: onProfile,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum ARBottomBarItem {
  explore,
  create,
  profile,
}

// ============================================================
// STANDARD ITEM
// ============================================================

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: double.infinity,
          child: Center(
            child: AnimatedContainer(
              duration: ARCameraTheme.motionFast,
              curve: ARCameraTheme.motionCurve,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: active
                    ? ARCameraTheme.primarySoft
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: active
                    ? Border.all(
                  color: ARCameraTheme.borderActive,
                )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    active ? activeIcon : icon,
                    size: active
                        ? 19
                        : 17,
                    color: active
                        ? ARCameraTheme.primaryBright
                        : ARCameraTheme.textSecondary,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active
                          ? ARCameraTheme.textPrimary
                          : ARCameraTheme.textMuted,
                      fontSize: 9,
                      fontWeight: active
                          ? FontWeight.w700
                          : FontWeight.w500,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CREATE BUTTON
// ============================================================

class _CreateButton extends StatelessWidget {
  const _CreateButton({
    required this.active,
    required this.onTap,
  });

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        button: true,
        label: active ? 'Close Create' : 'Create',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: AnimatedContainer(
              duration: ARCameraTheme.motionNormal,
              curve: ARCameraTheme.motionCurve,
              width: active ? 40 : 38,
              height: active ? 40 : 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? ARCameraTheme.textPrimary
                    : ARCameraTheme.primary,
                border: Border.all(
                  color: active
                      ? ARCameraTheme.border
                      : ARCameraTheme.borderActive,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ARCameraTheme.primary.withValues(
                      alpha: active ? 0.16 : 0.30,
                    ),
                    blurRadius: active ? 14 : 18,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                active
                    ? Icons.close_rounded
                    : Icons.add_rounded,
                size: active ? 19 : 22,
                color: active
                    ? ARCameraTheme.cameraFallback
                    : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}