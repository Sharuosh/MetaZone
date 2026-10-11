import 'package:flutter/material.dart';

import '../theme/ar_camera_theme.dart';
import 'ar_glass.dart';

/// Top navigation layer for MetaZone AR Camera V1.
///
/// Layout:
///   Back → MetaZone / Zone → Compass → Controls
///
/// This widget is presentation-only.
/// It does not own navigation or AR state.
class ARTopBar extends StatelessWidget {
  const ARTopBar({
    super.key,
    required this.zoneName,
    required this.onBack,
    required this.onCompassTap,
    required this.onControlsTap,
    this.zoneSubtitle = 'AR Space',
    this.compassActive = false,
  });

  /// Current spatial zone/location shown to the user.
  final String zoneName;

  /// Small contextual label displayed above/beside the zone.
  final String zoneSubtitle;

  final VoidCallback onBack;
  final VoidCallback onCompassTap;
  final VoidCallback onControlsTap;

  /// Visual state of the compass button.
  final bool compassActive;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          ARCameraTheme.horizontalPadding,
          ARCameraTheme.topSafeSpacing,
          ARCameraTheme.horizontalPadding,
          0,
        ),
        child: ARGlass(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 7,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(ARCameraTheme.radiusLarge),
          ),
          blur: ARCameraTheme.glassBlur,
          opacity: ARCameraTheme.glassOpacity,
          child: SizedBox(
            height: ARCameraTheme.topBarHeight - 14,
            child: Row(
              children: [
                _TopBarButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  tooltip: 'Back',
                  onTap: onBack,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: _ZoneIdentity(
                    zoneName: zoneName,
                    subtitle: zoneSubtitle,
                  ),
                ),

                const SizedBox(width: 6),

                _TopBarButton(
                  icon: Icons.explore_outlined,
                  tooltip: 'Compass',
                  active: compassActive,
                  onTap: onCompassTap,
                ),

                const SizedBox(width: 4),

                _TopBarButton(
                  icon: Icons.tune_rounded,
                  tooltip: 'AR Controls',
                  onTap: onControlsTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ZONE IDENTITY
// ============================================================

class _ZoneIdentity extends StatelessWidget {
  const _ZoneIdentity({
    required this.zoneName,
    required this.subtitle,
  });

  final String zoneName;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MetaZone',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ARCameraTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.0,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: ARCameraTheme.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  zoneName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ARCameraTheme.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TOP BAR BUTTON
// ============================================================

class _TopBarButton extends StatelessWidget {
  const _TopBarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            ARCameraTheme.radiusMedium,
          ),
          child: AnimatedContainer(
            duration: ARCameraTheme.motionFast,
            curve: ARCameraTheme.motionCurve,
            width: ARCameraTheme.minTouchTarget,
            height: ARCameraTheme.minTouchTarget,
            decoration: BoxDecoration(
              color: active
                  ? ARCameraTheme.primarySoft
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(
                ARCameraTheme.radiusMedium,
              ),
              border: active
                  ? Border.all(
                color: ARCameraTheme.borderActive,
              )
                  : null,
            ),
            child: Center(
              child: Icon(
                icon,
                size: ARCameraTheme.iconMedium,
                color: active
                    ? ARCameraTheme.primaryBright
                    : ARCameraTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}