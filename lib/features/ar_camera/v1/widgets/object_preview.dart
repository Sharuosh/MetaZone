import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/ar_camera_theme.dart';
import 'ar_glass.dart';
import 'object_library.dart';

/// MetaZone Object Preview / Details.
///
/// Flutter-side presentation layer between:
///
/// Object Library
///      ↓
/// Object Preview / Details
///      ↓
/// Object Placement
///
/// Flutter owns the complete presentation and interaction layer.
/// The actual 3D asset rendering can later be connected to Unity
/// without changing this screen's navigation contract.
///
/// UNITY INTEGRATION POINT:
/// - Real 3D model preview
/// - Materials / textures
/// - Lighting
/// - Animation
/// - Real-time model rendering
///
/// Flutter:
/// - Object information
/// - Preview container
/// - Navigation
/// - Place action
/// - Loading / visual states
/// - Accessibility
class ObjectPreview extends StatefulWidget {
  const ObjectPreview({
    super.key,
    required this.object,
    required this.onBack,
    required this.onPlace,
  });

  final ARLibraryObject object;
  final VoidCallback onBack;
  final VoidCallback onPlace;

  @override
  State<ObjectPreview> createState() => _ObjectPreviewState();
}

class _ObjectPreviewState extends State<ObjectPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _previewAnimation;

  bool _isOpeningPlacement = false;

  // Flutter-only preview controls. The final 3D renderer can consume
  // the same values when Unity is connected.
  double _previewScale = 1.0;
  double _previewRotation = 0.0;
  bool _autoRotate = true;
  bool _detailsExpanded = false;

  @override
  void initState() {
    super.initState();

    _previewAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _previewAnimation.dispose();
    super.dispose();
  }

  void _handlePlace() {
    if (_isOpeningPlacement) {
      return;
    }

    setState(() {
      _isOpeningPlacement = true;
    });

    widget.onPlace();
  }

  void _resetPreview() {
    setState(() {
      _previewScale = 1.0;
      _previewRotation = 0.0;
    });
  }

  void _toggleAutoRotate() {
    setState(() {
      _autoRotate = !_autoRotate;
    });
  }

  void _setPreviewScale(double value) {
    setState(() {
      _previewScale = value;
    });
  }

  void _rotatePreview(double delta) {
    setState(() {
      _previewRotation += delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SafeArea(
        child: Stack(
          children: [
            // ======================================================
            // BACKDROP
            // ======================================================

            Positioned.fill(
              child: IgnorePointer(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5,
                    sigmaY: 5,
                  ),
                  child: ColoredBox(
                    color: Colors.black.withValues(
                      alpha: 0.18,
                    ),
                  ),
                ),
              ),
            ),

            // ======================================================
            // CONTENT
            // ======================================================

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  12,
                  12,
                  12,
                ),
                child: _PreviewPanel(
                  object: widget.object,
                  previewAnimation: _previewAnimation,
                  isOpeningPlacement: _isOpeningPlacement,
                  previewScale: _previewScale,
                  previewRotation: _previewRotation,
                  autoRotate: _autoRotate,
                  detailsExpanded: _detailsExpanded,
                  onBack: widget.onBack,
                  onPlace: _handlePlace,
                  onResetPreview: _resetPreview,
                  onToggleAutoRotate: _toggleAutoRotate,
                  onScaleChanged: _setPreviewScale,
                  onRotate: _rotatePreview,
                  onToggleDetails: () {
                    setState(() {
                      _detailsExpanded = !_detailsExpanded;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// PREVIEW PANEL
// ==================================================================

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.object,
    required this.previewAnimation,
    required this.isOpeningPlacement,
    required this.previewScale,
    required this.previewRotation,
    required this.autoRotate,
    required this.detailsExpanded,
    required this.onBack,
    required this.onPlace,
    required this.onResetPreview,
    required this.onToggleAutoRotate,
    required this.onScaleChanged,
    required this.onRotate,
    required this.onToggleDetails,
  });

  final ARLibraryObject object;
  final Animation<double> previewAnimation;
  final bool isOpeningPlacement;
  final double previewScale;
  final double previewRotation;
  final bool autoRotate;
  final bool detailsExpanded;

  final VoidCallback onBack;
  final VoidCallback onPlace;
  final VoidCallback onResetPreview;
  final VoidCallback onToggleAutoRotate;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<double> onRotate;
  final VoidCallback onToggleDetails;

  @override
  Widget build(BuildContext context) {
    return ARGlass(
      padding: const EdgeInsets.all(12),
      borderRadius: const BorderRadius.all(
        Radius.circular(22),
      ),
      blur: ARCameraTheme.glassBlurStrong,
      opacity: ARCameraTheme.glassStrongOpacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ========================================================
          // HANDLE
          // ========================================================

          Semantics(
            label: 'Object preview panel',
            child: Container(
              width: 34,
              height: 3,
              decoration: BoxDecoration(
                color: ARCameraTheme.textMuted,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ========================================================
          // HEADER
          // ========================================================

          Row(
            children: [
              _SmallButton(
                icon: Icons.arrow_back_rounded,
                semanticLabel: 'Back to Object Library',
                onTap: onBack,
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'Object Preview',
                  style: TextStyle(
                    color: ARCameraTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              _SmallButton(
                icon: Icons.close_rounded,
                semanticLabel: 'Close Object Preview',
                onTap: onBack,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ========================================================
          // OBJECT PREVIEW
          // ========================================================

          _ObjectPreviewStage(
            object: object,
            animation: previewAnimation,
            scale: previewScale,
            rotation: previewRotation,
            autoRotate: autoRotate,
            onReset: onResetPreview,
            onToggleAutoRotate: onToggleAutoRotate,
            onScaleChanged: onScaleChanged,
            onRotate: onRotate,
          ),

          const SizedBox(height: 12),

          // ========================================================
          // OBJECT INFORMATION
          // ========================================================

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              object.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ARCameraTheme.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              _CategoryChip(
                label: object.category,
              ),
              if (object.featured) ...[
                const SizedBox(width: 7),
                const _CategoryChip(
                  label: 'Featured',
                  accent: true,
                ),
              ],
            ],
          ),

          const SizedBox(height: 9),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              object.description,
              maxLines: detailsExpanded ? null : 3,
              overflow: detailsExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: const TextStyle(
                color: ARCameraTheme.textSecondary,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),

          const SizedBox(height: 5),

          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              button: true,
              expanded: detailsExpanded,
              label: detailsExpanded
                  ? 'Hide object details'
                  : 'Show more object details',
              child: TextButton.icon(
                onPressed: onToggleDetails,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(1, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: ARCameraTheme.primaryBright,
                ),
                icon: AnimatedRotation(
                  turns: detailsExpanded ? 0.5 : 0,
                  duration: ARCameraTheme.motionFast,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                  ),
                ),
                label: Text(
                  detailsExpanded ? 'Show less' : 'More details',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ========================================================
          // QUICK INFO
          // ========================================================

          const Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.view_in_ar_rounded,
                  title: 'AR Object',
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.open_with_rounded,
                  title: 'Place freely',
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.touch_app_rounded,
                  title: 'Interactive',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ========================================================
          // PLACE BUTTON
          // ========================================================

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed:
              isOpeningPlacement ? null : onPlace,
              style: ElevatedButton.styleFrom(
                backgroundColor: ARCameraTheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                ARCameraTheme.primary.withValues(
                  alpha: 0.45,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: AnimatedSwitcher(
                duration: ARCameraTheme.motionFast,
                child: isOpeningPlacement
                    ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.8,
                    color: Colors.white,
                  ),
                )
                    : const Row(
                  key: ValueKey('place'),
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_location_alt_rounded,
                      size: 18,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'Place in AR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// PREVIEW STAGE
// ==================================================================

class _ObjectPreviewStage extends StatelessWidget {
  const _ObjectPreviewStage({
    required this.object,
    required this.animation,
    required this.scale,
    required this.rotation,
    required this.autoRotate,
    required this.onReset,
    required this.onToggleAutoRotate,
    required this.onScaleChanged,
    required this.onRotate,
  });

  final ARLibraryObject object;
  final Animation<double> animation;
  final double scale;
  final double rotation;
  final bool autoRotate;
  final VoidCallback onReset;
  final VoidCallback onToggleAutoRotate;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<double> onRotate;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final pulse = 0.97 + (animation.value * 0.06);
        final ringOpacity = 0.08 + (animation.value * 0.06);
        final automaticRotation =
        autoRotate ? (animation.value - 0.5) * 0.16 : 0.0;

        return Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: ARCameraTheme.glassSoftColor,
            border: Border.all(color: ARCameraTheme.border),
          ),
          child: Stack(
            children: [
              // Spatial stage.
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleUpdate: (details) {
                    if (details.scale != 1.0) {
                      final nextScale =
                      (scale * details.scale).clamp(0.70, 1.45);
                      onScaleChanged(nextScale);
                    }
                    if (details.rotation.abs() > 0.001) {
                      onRotate(details.rotation);
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.scale(
                        scale: pulse,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ARCameraTheme.primary.withValues(
                                alpha: ringOpacity,
                              ),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 105,
                        height: 105,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ARCameraTheme.primarySoft,
                          border: Border.all(
                            color: ARCameraTheme.borderActive,
                          ),
                        ),
                      ),

                      // ==================================================
                      // UNITY INTEGRATION POINT
                      // ==================================================
                      // This icon is the Flutter fallback preview.
                      // Unity will replace this visual with the actual
                      // 3D asset renderer without changing the surrounding
                      // Flutter controls or navigation contract.
                      Transform.rotate(
                        angle: rotation + automaticRotation,
                        child: Transform.scale(
                          scale: scale,
                          child: Icon(
                            object.icon,
                            size: 62,
                            color: ARCameraTheme.primaryBright,
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 12,
                        child: _GestureHint(
                          autoRotate: autoRotate,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 10,
                left: 10,
                child: _StageBadge(
                  icon: Icons.view_in_ar_rounded,
                  label: 'AR Ready',
                ),
              ),

              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  children: [
                    _StageControl(
                      icon: autoRotate
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      tooltip: autoRotate
                          ? 'Pause preview motion'
                          : 'Play preview motion',
                      onTap: onToggleAutoRotate,
                      active: autoRotate,
                    ),
                    const SizedBox(width: 6),
                    _StageControl(
                      icon: Icons.refresh_rounded,
                      tooltip: 'Reset preview',
                      onTap: onReset,
                    ),
                  ],
                ),
              ),

              Positioned(
                left: 10,
                bottom: 10,
                child: _ScaleControl(
                  value: scale,
                  onChanged: onScaleChanged,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GestureHint extends StatelessWidget {
  const _GestureHint({required this.autoRotate});

  final bool autoRotate;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: ARCameraTheme.motionNormal,
      opacity: autoRotate ? 0.85 : 0.55,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: ARCameraTheme.glassStrongColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ARCameraTheme.border),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app_rounded,
              size: 11,
              color: ARCameraTheme.textSecondary,
            ),
            SizedBox(width: 5),
            Text(
              'Drag • Pinch • Rotate',
              style: TextStyle(
                color: ARCameraTheme.textSecondary,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageBadge extends StatelessWidget {
  const _StageBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: ARCameraTheme.glassStrongColor,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: ARCameraTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: ARCameraTheme.primaryBright,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: ARCameraTheme.textSecondary,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StageControl extends StatelessWidget {
  const _StageControl({
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
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: ARCameraTheme.motionFast,
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: active
                  ? ARCameraTheme.primarySoft
                  : ARCameraTheme.glassStrongColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active
                    ? ARCameraTheme.borderActive
                    : ARCameraTheme.border,
              ),
            ),
            child: Icon(
              icon,
              size: 15,
              color: active
                  ? ARCameraTheme.primaryBright
                  : ARCameraTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScaleControl extends StatelessWidget {
  const _ScaleControl({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: ARCameraTheme.glassStrongColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ARCameraTheme.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.zoom_out_map_rounded,
            size: 13,
            color: ARCameraTheme.textSecondary,
          ),
          Expanded(
            child: Slider(
              value: value,
              min: 0.70,
              max: 1.45,
              onChanged: onChanged,
              activeColor: ARCameraTheme.primaryBright,
              inactiveColor: ARCameraTheme.border,
              thumbColor: ARCameraTheme.primaryBright,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// INFO ITEM
// ==================================================================

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: ARCameraTheme.textSecondary,
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ARCameraTheme.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// CATEGORY CHIP
// ==================================================================

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    this.accent = false,
  });

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: accent
            ? ARCameraTheme.primarySoft
            : ARCameraTheme.glassSoftColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accent
              ? ARCameraTheme.borderActive
              : ARCameraTheme.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent
              ? ARCameraTheme.primaryBright
              : ARCameraTheme.textSecondary,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ==================================================================
// SMALL BUTTON
// ==================================================================

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: ARCameraTheme.glassSoftColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ARCameraTheme.border,
              ),
            ),
            child: Icon(
              icon,
              size: 17,
              color: ARCameraTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}