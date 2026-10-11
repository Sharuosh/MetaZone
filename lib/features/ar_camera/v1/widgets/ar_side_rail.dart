import 'package:flutter/material.dart';

import '../theme/ar_camera_theme.dart';
import 'ar_glass.dart';

/// Collapsible action rail for MetaZone AR Camera V1.
///
/// Collapsed:
///   ◀
///
/// Expanded:
///   Capture
///   Scan
///   Layers
///
/// This widget is presentation-only.
/// Actions are supplied by the parent screen.
class ARSideRail extends StatelessWidget {
  const ARSideRail({
    super.key,
    required this.expanded,
    required this.onToggle,
    required this.onCapture,
    required this.onScan,
    required this.onLayers,
    this.captureActive = false,
    this.scanActive = false,
    this.layersActive = false,
  });

  final bool expanded;

  final VoidCallback onToggle;
  final VoidCallback onCapture;
  final VoidCallback onScan;
  final VoidCallback onLayers;

  final bool captureActive;
  final bool scanActive;
  final bool layersActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: ARCameraTheme.railAnimationDuration,
      curve: ARCameraTheme.railAnimationCurve,
      width: expanded
          ? ARCameraTheme.sideRailExpandedWidth
          : ARCameraTheme.sideRailWidth,
      child: ARGlass(
        padding: const EdgeInsets.all(6),
        borderRadius: const BorderRadius.all(
          Radius.circular(ARCameraTheme.radiusLarge),
        ),
        blur: ARCameraTheme.glassBlur,
        opacity: ARCameraTheme.glassOpacity,
        child: AnimatedSwitcher(
          duration: ARCameraTheme.motionNormal,
          switchInCurve: ARCameraTheme.motionCurve,
          switchOutCurve: Curves.easeIn,
          child: expanded
              ? _ExpandedRail(
            key: const ValueKey('expanded'),
            onToggle: onToggle,
            onCapture: onCapture,
            onScan: onScan,
            onLayers: onLayers,
            captureActive: captureActive,
            scanActive: scanActive,
            layersActive: layersActive,
          )
              : _CollapsedRail(
            key: const ValueKey('collapsed'),
            onToggle: onToggle,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// COLLAPSED RAIL
// ============================================================

class _CollapsedRail extends StatelessWidget {
  const _CollapsedRail({
    super.key,
    required this.onToggle,
  });

  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: _RailIconButton(
        icon: Icons.chevron_left_rounded,
        tooltip: 'Open AR controls',
        onTap: onToggle,
      ),
    );
  }
}

// ============================================================
// EXPANDED RAIL
// ============================================================

class _ExpandedRail extends StatelessWidget {
  const _ExpandedRail({
    super.key,
    required this.onToggle,
    required this.onCapture,
    required this.onScan,
    required this.onLayers,
    required this.captureActive,
    required this.scanActive,
    required this.layersActive,
  });

  final VoidCallback onToggle;
  final VoidCallback onCapture;
  final VoidCallback onScan;
  final VoidCallback onLayers;

  final bool captureActive;
  final bool scanActive;
  final bool layersActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RailHeader(
          onClose: onToggle,
        ),

        const SizedBox(height: 4),

        _RailAction(
          icon: Icons.camera_alt_outlined,
          activeIcon: Icons.camera_alt_rounded,
          label: 'Capture',
          active: captureActive,
          onTap: onCapture,
        ),

        const SizedBox(height: 4),

        _RailAction(
          icon: Icons.center_focus_strong_outlined,
          activeIcon: Icons.center_focus_strong_rounded,
          label: 'Scan',
          active: scanActive,
          onTap: onScan,
        ),

        const SizedBox(height: 4),

        _RailAction(
          icon: Icons.layers_outlined,
          activeIcon: Icons.layers_rounded,
          label: 'Layers',
          active: layersActive,
          onTap: onLayers,
        ),
      ],
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class _RailHeader extends StatelessWidget {
  const _RailHeader({
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'AR Controls',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ARCameraTheme.textPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          _RailIconButton(
            icon: Icons.chevron_right_rounded,
            tooltip: 'Close AR controls',
            onTap: onClose,
            size: 28,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ACTION
// ============================================================

class _RailAction extends StatelessWidget {
  const _RailAction({
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
        borderRadius: BorderRadius.circular(
          ARCameraTheme.radiusMedium,
        ),
        child: AnimatedContainer(
          duration: ARCameraTheme.motionFast,
          curve: ARCameraTheme.motionCurve,
          height: 48,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
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
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: active
                      ? ARCameraTheme.primary.withValues(
                    alpha: 0.16,
                  )
                      : Colors.white.withValues(
                    alpha: 0.055,
                  ),
                  borderRadius: BorderRadius.circular(
                    ARCameraTheme.radiusSmall,
                  ),
                ),
                child: Icon(
                  active ? activeIcon : icon,
                  size: ARCameraTheme.iconMedium,
                  color: active
                      ? ARCameraTheme.primaryBright
                      : ARCameraTheme.textSecondary,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: active
                        ? ARCameraTheme.textPrimary
                        : ARCameraTheme.textSecondary,
                    fontSize: 11.5,
                    fontWeight: active
                        ? FontWeight.w700
                        : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ICON BUTTON
// ============================================================

class _RailIconButton extends StatelessWidget {
  const _RailIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 48,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final double size;

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
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Icon(
                icon,
                size: ARCameraTheme.iconMedium,
                color: ARCameraTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}