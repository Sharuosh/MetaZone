import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/ar_camera_theme.dart';
import 'ar_glass.dart';
import 'object_library.dart';

/// MetaZone Object Placement.
///
/// Complete Flutter presentation and interaction layer.
///
/// Flow:
/// Object Library
///      ↓
/// Object Preview / Details
///      ↓
/// Object Placement
///      ↓
/// Place
///      ↓
/// Object Placement Success
///
/// Flutter owns:
/// - Presentation
/// - Placement guidance
/// - UI states
/// - Scale controls
/// - Rotation controls
/// - Lock state
/// - Cancel confirmation
/// - Navigation callbacks
///
/// UNITY INTEGRATION POINT:
/// - Real surface detection
/// - AR hit testing
/// - World-space coordinates
/// - Object instantiation
/// - Real object movement / rotation / scale
///
/// This widget never fakes Unity AR state.
class ObjectPlacement extends StatefulWidget {
  const ObjectPlacement({
    super.key,
    required this.object,
    required this.onBack,
    required this.onCancel,
    required this.onPlace,
    this.surfaceDetected = false,
    this.onScanRequested,
  });

  final ARLibraryObject object;

  final VoidCallback onBack;
  final VoidCallback onCancel;
  final VoidCallback onPlace;

  /// UNITY INTEGRATION POINT:
  /// Set this to true when Unity/ARCore confirms a valid surface.
  final bool surfaceDetected;

  /// UNITY INTEGRATION POINT:
  /// Called when the user asks Flutter to start/refresh surface scanning.
  final VoidCallback? onScanRequested;

  @override
  State<ObjectPlacement> createState() =>
      _ObjectPlacementState();
}

class _ObjectPlacementState extends State<ObjectPlacement>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // UI STATE
  // ============================================================

  late double _scale;

  late double _rotation;

  bool _locked = false;

  bool _isScanning = false;

  bool _isPlacing = false;

  // ============================================================
  // ANIMATION
  // ============================================================

  late final AnimationController _scanAnimation;

  @override
  void initState() {
    super.initState();

    _scale = 1.0;
    _rotation = 0.0;

    _scanAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    if (!widget.surfaceDetected) {
      _scanAnimation.repeat();
      _isScanning = true;
    }
  }

  @override
  void didUpdateWidget(
      covariant ObjectPlacement oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (widget.surfaceDetected !=
        oldWidget.surfaceDetected) {
      if (widget.surfaceDetected) {
        _scanAnimation.stop();

        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }
      } else {
        _scanAnimation.repeat();

        if (mounted) {
          setState(() {
            _isScanning = true;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _scanAnimation.dispose();
    super.dispose();
  }

  // ============================================================
  // COMPUTED STATE
  // ============================================================

  bool get _surfaceReady =>
      widget.surfaceDetected;

  // ============================================================
  // SCALE
  // ============================================================

  void _setScale(double value) {
    if (_locked || !mounted) {
      return;
    }

    final nextScale = value.clamp(0.25, 3.0).toDouble();

    if (_scale == nextScale) {
      return;
    }

    setState(() {
      _scale = nextScale;
    });

    // UNITY INTEGRATION POINT:
    // Send scale value to Unity.
  }

  void _resetScale() {
    if (_locked) {
      return;
    }

    _setScale(1.0);
  }

  // ============================================================
  // ROTATION
  // ============================================================

  void _setRotation(double value) {
    if (_locked || !mounted) {
      return;
    }

    final nextRotation = value.clamp(-180.0, 180.0).toDouble();

    if (_rotation == nextRotation) {
      return;
    }

    setState(() {
      _rotation = nextRotation;
    });

    // UNITY INTEGRATION POINT:
    // Send rotation value to Unity.
  }

  void _resetRotation() {
    if (_locked) {
      return;
    }

    _setRotation(0.0);
  }

  // ============================================================
  // LOCK
  // ============================================================

  void _toggleLock() {
    if (_isPlacing || !mounted) {
      return;
    }

    setState(() {
      _locked = !_locked;
    });

    // UNITY INTEGRATION POINT:
    // Enable / disable manipulation in Unity.
  }

  // ============================================================
  // SCAN
  // ============================================================

  void _requestScan() {
    if (_isScanning || _isPlacing || !mounted) {
      return;
    }

    setState(() {
      _isScanning = true;
    });

    _scanAnimation.repeat();

    widget.onScanRequested?.call();

    // UNITY INTEGRATION POINT:
    // Start / refresh AR surface detection.
  }

  // ============================================================
  // PLACE
  // ============================================================

  Future<void> _placeObject() async {
    if (!_surfaceReady || _isPlacing || !mounted) {
      return;
    }

    setState(() {
      _isPlacing = true;
    });

    try {
      // UNITY INTEGRATION POINT:
      // Ask Unity to instantiate the selected object
      // at the detected AR pose using:
      // - _scale
      // - _rotation
      // - widget.object.id

      widget.onPlace();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'The object could not be placed. Please try again.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacing = false;
        });
      }
    }
  }

  // ============================================================
  // CANCEL
  // ============================================================

  Future<void> _confirmCancel() async {
    if (_isPlacing || !mounted) {
      return;
    }

    final shouldCancel =
    await showDialog<bool>(
      context: context,
      barrierColor:
      Colors.black.withValues(alpha: 0.55),
      builder: (context) {
        return _PlacementConfirmationDialog(
          object: widget.object,
          onCancel: () =>
              Navigator.of(context).pop(true),
          onKeepEditing: () =>
              Navigator.of(context).pop(false),
        );
      },
    );

    if (shouldCancel == true && mounted) {
      widget.onCancel();
    }
  }

  // ============================================================
  // BACK
  // ============================================================

  void _handleBack() {
    widget.onBack();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SafeArea(
        child: Stack(
          children: [
            // ======================================================
            // TOP BAR
            // ======================================================

            Positioned(
              top: 8,
              left: 12,
              right: 12,
              child: _PlacementTopBar(
                object: widget.object,
                surfaceReady: _surfaceReady,
                locked: _locked,
                onBack: _handleBack,
                onLock: _toggleLock,
                onCancel: _confirmCancel,
              ),
            ),

            // ======================================================
            // CENTER RETICLE
            // ======================================================

            Center(
              child: _PlacementReticle(
                detected: _surfaceReady,
                scanning: _isScanning,
                animation: _scanAnimation,
              ),
            ),

            // ======================================================
            // OBJECT INFORMATION
            // ======================================================

            Positioned(
              left: 12,
              right: 12,
              bottom: 194,
              child: Center(
                child: _ObjectLabel(
                  object: widget.object,
                  detected: _surfaceReady,
                  scale: _scale,
                  rotation: _rotation,
                ),
              ),
            ),

            // ======================================================
            // BOTTOM PANEL
            // ======================================================

            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: _PlacementBottomPanel(
                object: widget.object,
                detected: _surfaceReady,
                locked: _locked,
                scale: _scale,
                rotation: _rotation,
                isPlacing: _isPlacing,
                scanning: _isScanning,
                onScan: _requestScan,
                onScaleChanged: _setScale,
                onScaleReset: _resetScale,
                onRotationChanged: _setRotation,
                onRotationReset: _resetRotation,
                onCancel: _confirmCancel,
                onPlace: _placeObject,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// TOP BAR
// ==================================================================

class _PlacementTopBar extends StatelessWidget {
  const _PlacementTopBar({
    required this.object,
    required this.surfaceReady,
    required this.locked,
    required this.onBack,
    required this.onLock,
    required this.onCancel,
  });

  final ARLibraryObject object;
  final bool surfaceReady;
  final bool locked;

  final VoidCallback onBack;
  final VoidCallback onLock;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PlacementButton(
          icon: Icons.arrow_back_rounded,
          semanticLabel: 'Back',
          onTap: onBack,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: ARGlass(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            borderRadius:
            const BorderRadius.all(
              Radius.circular(14),
            ),
            blur: ARCameraTheme.glassBlur,
            opacity:
            ARCameraTheme.glassStrongOpacity,
            child: Row(
              children: [
                Icon(
                  object.icon,
                  size: 16,
                  color:
                  ARCameraTheme.primaryBright,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    object.name,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      color:
                      ARCameraTheme.textPrimary,
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                _StatusDot(
                  ready: surfaceReady,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        _PlacementButton(
          icon: locked
              ? Icons.lock_rounded
              : Icons.lock_open_rounded,
          semanticLabel:
          locked ? 'Unlock Object' : 'Lock Object',
          active: locked,
          onTap: onLock,
        ),

        const SizedBox(width: 8),

        _PlacementButton(
          icon: Icons.close_rounded,
          semanticLabel: 'Cancel Placement',
          onTap: onCancel,
        ),
      ],
    );
  }
}

// ==================================================================
// STATUS DOT
// ==================================================================

class _StatusDot extends StatelessWidget {
  const _StatusDot({
    required this.ready,
  });

  final bool ready;

  @override
  Widget build(BuildContext context) {
    final color = ready
        ? ARCameraTheme.success
        : ARCameraTheme.warning;

    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(
              alpha: 0.45,
            ),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// RETICLE
// ==================================================================

class _PlacementReticle extends StatelessWidget {
  const _PlacementReticle({
    required this.detected,
    required this.scanning,
    required this.animation,
  });

  final bool detected;
  final bool scanning;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final accent = detected
        ? ARCameraTheme.success
        : ARCameraTheme.primaryBright;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final pulse = scanning
            ? 0.94 + (animation.value * 0.10)
            : 1.0;

        return Transform.scale(
          scale: pulse,
          child: AnimatedContainer(
            duration:
            ARCameraTheme.motionNormal,
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(
                alpha: 0.035,
              ),
              border: Border.all(
                color: accent.withValues(
                  alpha: detected ? 0.85 : 0.60,
                ),
                width: detected ? 1.5 : 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(
                    alpha: detected ? 0.22 : 0.12,
                  ),
                  blurRadius: detected ? 30 : 22,
                ),
              ],
            ),
            child: Center(
              child: AnimatedContainer(
                duration:
                ARCameraTheme.motionNormal,
                width: detected ? 18 : 12,
                height: detected ? 18 : 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(
                    alpha:
                    detected ? 0.9 : 0.45,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================================================================
// OBJECT LABEL
// ==================================================================

class _ObjectLabel extends StatelessWidget {
  const _ObjectLabel({
    required this.object,
    required this.detected,
    required this.scale,
    required this.rotation,
  });

  final ARLibraryObject object;
  final bool detected;
  final double scale;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return ARGlass(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 9,
      ),
      borderRadius:
      const BorderRadius.all(
        Radius.circular(15),
      ),
      blur: ARCameraTheme.glassBlur,
      opacity:
      ARCameraTheme.glassStrongOpacity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            object.icon,
            size: 16,
            color: detected
                ? ARCameraTheme.success
                : ARCameraTheme.primaryBright,
          ),

          const SizedBox(width: 7),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                detected
                    ? 'Ready to place'
                    : 'Finding a surface',
                style: const TextStyle(
                  color:
                  ARCameraTheme.textPrimary,
                  fontSize: 10,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${object.name}  •  ${(scale * 100).round()}%  •  ${rotation.round()}°',
                style: const TextStyle(
                  color:
                  ARCameraTheme.textMuted,
                  fontSize: 8,
                  fontWeight:
                  FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// BOTTOM PANEL
// ==================================================================

class _PlacementBottomPanel
    extends StatelessWidget {
  const _PlacementBottomPanel({
    required this.object,
    required this.detected,
    required this.locked,
    required this.scale,
    required this.rotation,
    required this.isPlacing,
    required this.scanning,
    required this.onScan,
    required this.onScaleChanged,
    required this.onScaleReset,
    required this.onRotationChanged,
    required this.onRotationReset,
    required this.onCancel,
    required this.onPlace,
  });

  final ARLibraryObject object;
  final bool detected;
  final bool locked;

  final double scale;
  final double rotation;

  final bool isPlacing;
  final bool scanning;

  final VoidCallback onScan;
  final ValueChanged<double> onScaleChanged;
  final VoidCallback onScaleReset;

  final ValueChanged<double> onRotationChanged;
  final VoidCallback onRotationReset;

  final VoidCallback onCancel;
  final VoidCallback onPlace;

  @override
  Widget build(BuildContext context) {
    return ARGlass(
      padding: const EdgeInsets.all(11),
      borderRadius:
      const BorderRadius.all(
        Radius.circular(20),
      ),
      blur: ARCameraTheme.glassBlurStrong,
      opacity:
      ARCameraTheme.glassStrongOpacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ========================================================
          // TITLE
          // ========================================================

          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                  ARCameraTheme.primarySoft,
                  border: Border.all(
                    color:
                    ARCameraTheme.borderActive,
                  ),
                ),
                child: Icon(
                  object.icon,
                  size: 17,
                  color:
                  ARCameraTheme.primaryBright,
                ),
              ),

              const SizedBox(width: 9),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Place object',
                      style: TextStyle(
                        color:
                        ARCameraTheme.textPrimary,
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Find a surface, adjust the object, then place it.',
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                        ARCameraTheme.textMuted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              if (locked)
                const Icon(
                  Icons.lock_rounded,
                  size: 15,
                  color:
                  ARCameraTheme.warning,
                ),
            ],
          ),

          const SizedBox(height: 10),

          // ========================================================
          // SCALE
          // ========================================================

          _AdjustmentRow(
            icon: Icons.open_in_full_rounded,
            label: 'Scale',
            value:
            '${(scale * 100).round()}%',
            enabled: !locked,
            onReset: onScaleReset,
            slider: Slider(
              value: scale,
              min: 0.25,
              max: 3.0,
              divisions: 55,
              onChanged:
              locked ? null : onScaleChanged,
            ),
          ),

          // ========================================================
          // ROTATION
          // ========================================================

          _AdjustmentRow(
            icon: Icons.rotate_right_rounded,
            label: 'Rotation',
            value:
            '${rotation.round()}°',
            enabled: !locked,
            onReset: onRotationReset,
            slider: Slider(
              value: rotation,
              min: -180,
              max: 180,
              divisions: 72,
              onChanged:
              locked ? null : onRotationChanged,
            ),
          ),

          const SizedBox(height: 6),

          // ========================================================
          // ACTIONS
          // ========================================================

          Row(
            children: [
              Expanded(
                child: _SecondaryAction(
                  icon:
                  Icons.center_focus_strong_rounded,
                  label: detected
                      ? 'Rescan'
                      : 'Scan',
                  enabled: !scanning && !isPlacing,
                  onTap: onScan,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _PrimaryAction(
                  enabled:
                  detected && !isPlacing,
                  loading: isPlacing,
                  icon:
                  Icons.add_location_alt_rounded,
                  label: 'Place',
                  onTap:
                  detected && !isPlacing
                      ? onPlace
                      : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          TextButton(
            onPressed: isPlacing ? null : onCancel,
            style: TextButton.styleFrom(
              foregroundColor:
              ARCameraTheme.textMuted,
              minimumSize:
              const Size(
                double.infinity,
                28,
              ),
              tapTargetSize:
              MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 9,
                fontWeight:
                FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// ADJUSTMENT ROW
// ==================================================================

class _AdjustmentRow extends StatelessWidget {
  const _AdjustmentRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onReset,
    required this.slider,
  });

  final IconData icon;
  final String label;
  final String value;

  final bool enabled;
  final VoidCallback onReset;

  final Slider slider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: enabled
              ? ARCameraTheme.textSecondary
              : ARCameraTheme.textMuted,
        ),

        const SizedBox(width: 7),

        SizedBox(
          width: 48,
          child: Text(
            label,
            style: TextStyle(
              color: enabled
                  ? ARCameraTheme.textSecondary
                  : ARCameraTheme.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Expanded(
          child: slider,
        ),

        SizedBox(
          width: 36,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: enabled
                  ? ARCameraTheme.textPrimary
                  : ARCameraTheme.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        IconButton(
          tooltip: 'Reset $label',
          onPressed:
          enabled ? onReset : null,
          padding: EdgeInsets.zero,
          constraints:
          const BoxConstraints(
            minWidth: 28,
            minHeight: 28,
          ),
          icon: const Icon(
            Icons.refresh_rounded,
            size: 14,
          ),
          color:
          ARCameraTheme.textSecondary,
        ),
      ],
    );
  }
}

// ==================================================================
// PRIMARY ACTION
// ==================================================================

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.enabled,
    required this.loading,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool enabled;
  final bool loading;

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? ARCameraTheme.primary
              : ARCameraTheme.glassSoftColor,
          foregroundColor: enabled
              ? Colors.white
              : ARCameraTheme.textMuted,
          disabledBackgroundColor:
          ARCameraTheme.glassSoftColor,
          disabledForegroundColor:
          ARCameraTheme.textMuted,
          elevation: 0,
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(13),
            side: BorderSide(
              color: enabled
                  ? ARCameraTheme.borderActive
                  : ARCameraTheme.border,
            ),
          ),
        ),
        child: loading
            ? const SizedBox(
          width: 16,
          height: 16,
          child:
          CircularProgressIndicator(
            strokeWidth: 1.7,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style:
              const TextStyle(
                fontSize: 11,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// SECONDARY ACTION
// ==================================================================

class _SecondaryAction
    extends StatelessWidget {
  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          foregroundColor:
          enabled
              ? ARCameraTheme.textPrimary
              : ARCameraTheme.textMuted,
          side: const BorderSide(
            color: ARCameraTheme.border,
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(13),
          ),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style:
              const TextStyle(
                fontSize: 10,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// TOP BUTTON
// ==================================================================

class _PlacementButton
    extends StatelessWidget {
  const _PlacementButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(13),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius:
              BorderRadius.circular(13),
              child: AnimatedContainer(
                duration:
                ARCameraTheme.motionFast,
                width: 40,
                height: 40,
                decoration:
                BoxDecoration(
                  color: active
                      ? ARCameraTheme.primarySoft
                      : ARCameraTheme
                      .glassStrongColor,
                  borderRadius:
                  BorderRadius.circular(13),
                  border: Border.all(
                    color: active
                        ? ARCameraTheme
                        .borderActive
                        : ARCameraTheme.border,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: active
                      ? ARCameraTheme
                      .primaryBright
                      : ARCameraTheme
                      .textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// CANCEL DIALOG
// ==================================================================

class _PlacementConfirmationDialog
    extends StatelessWidget {
  const _PlacementConfirmationDialog({
    required this.object,
    required this.onCancel,
    required this.onKeepEditing,
  });

  final ARLibraryObject object;

  final VoidCallback onCancel;
  final VoidCallback onKeepEditing;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
      const EdgeInsets.symmetric(
        horizontal: 28,
      ),
      child: ARGlass(
        padding: const EdgeInsets.all(18),
        borderRadius:
        const BorderRadius.all(
          Radius.circular(24),
        ),
        blur:
        ARCameraTheme.glassBlurStrong,
        opacity:
        ARCameraTheme.glassStrongOpacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                ARCameraTheme.warning
                    .withValues(
                  alpha: 0.12,
                ),
                border: Border.all(
                  color:
                  ARCameraTheme.warning
                      .withValues(
                    alpha: 0.30,
                  ),
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 22,
                color:
                ARCameraTheme.warning,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Cancel placement?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                ARCameraTheme.textPrimary,
                fontSize: 15,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Your current ${object.name} placement settings will be discarded.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color:
                ARCameraTheme.textSecondary,
                fontSize: 10,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                    onKeepEditing,
                    style:
                    OutlinedButton.styleFrom(
                      foregroundColor:
                      ARCameraTheme
                          .textPrimary,
                      side:
                      const BorderSide(
                        color:
                        ARCameraTheme
                            .border,
                      ),
                      minimumSize:
                      const Size(
                        0,
                        40,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                            12),
                      ),
                    ),
                    child:
                    const Text(
                      'Keep Editing',
                      style:
                      TextStyle(
                        fontSize: 9,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: ElevatedButton(
                    onPressed: onCancel,
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      ARCameraTheme
                          .error,
                      foregroundColor:
                      Colors.white,
                      elevation: 0,
                      minimumSize:
                      const Size(
                        0,
                        40,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                            12),
                      ),
                    ),
                    child:
                    const Text(
                      'Cancel',
                      style:
                      TextStyle(
                        fontSize: 9,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
