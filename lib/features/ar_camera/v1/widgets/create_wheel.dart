import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/ar_camera_theme.dart';

/// MetaZone Create Wheel.
///
/// Final Flutter presentation layer for the AR creation launcher.
///
/// Flow:
/// AR Camera
///    ↓
/// Create Wheel
///    ├── Object
///    ├── Comment
///    └── Memory
///
/// This widget owns the complete Wheel presentation and interaction.
/// The destination flows are provided through callbacks.
class CreateWheel extends StatefulWidget {
  const CreateWheel({
    super.key,
    required this.visible,
    required this.onClose,
    required this.onObject,
    required this.onComment,
    required this.onMemory,
  });

  final bool visible;

  final VoidCallback onClose;
  final VoidCallback onObject;
  final VoidCallback onComment;
  final VoidCallback onMemory;

  @override
  State<CreateWheel> createState() => _CreateWheelState();
}

class _CreateWheelState extends State<CreateWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: ARCameraTheme.motionSmooth,
      reverseDuration: ARCameraTheme.motionNormal,
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scale = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: ARCameraTheme.motionCurve,
      ),
    );

    if (widget.visible) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant CreateWheel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible == oldWidget.visible) {
      return;
    }

    if (widget.visible) {
      _controller.forward(from: 0);
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Semantics(
        label: 'Create Wheel',
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ======================================================
            // BACKDROP
            // ======================================================

            Positioned.fill(
              child: FadeTransition(
                opacity: _fade,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onClose,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 5,
                      sigmaY: 5,
                    ),
                    child: ColoredBox(
                      color: Colors.black.withValues(
                        alpha: 0.20,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ======================================================
            // WHEEL
            // ======================================================

            Center(
              child: ScaleTransition(
                scale: _scale,
                child: FadeTransition(
                  opacity: _fade,
                  child: _CreateWheelContent(
                    onClose: widget.onClose,
                    onObject: widget.onObject,
                    onComment: widget.onComment,
                    onMemory: widget.onMemory,
                  ),
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
// WHEEL CONTENT
// ==================================================================

class _CreateWheelContent extends StatelessWidget {
  const _CreateWheelContent({
    required this.onClose,
    required this.onObject,
    required this.onComment,
    required this.onMemory,
  });

  final VoidCallback onClose;
  final VoidCallback onObject;
  final VoidCallback onComment;
  final VoidCallback onMemory;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    final wheelSize = screenSize.shortestSide < 380
        ? 276.0
        : 300.0;

    return SizedBox(
      width: wheelSize,
      height: wheelSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ========================================================
          // OUTER ORBIT
          // ========================================================

          IgnorePointer(
            child: Container(
              width: wheelSize * 0.79,
              height: wheelSize * 0.79,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ARCameraTheme.border.withValues(
                    alpha: 0.65,
                  ),
                  width: 1,
                ),
              ),
            ),
          ),

          // ========================================================
          // INNER ORBIT
          // ========================================================

          IgnorePointer(
            child: Container(
              width: wheelSize * 0.61,
              height: wheelSize * 0.61,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ARCameraTheme.primary.withValues(
                    alpha: 0.11,
                  ),
                  width: 1,
                ),
              ),
            ),
          ),

          // ========================================================
          // MEMORY
          // ========================================================

          Positioned(
            top: wheelSize * 0.007,
            child: _CreateOption(
              icon: Icons.auto_awesome_motion_rounded,
              label: 'Memory',
              accent: ARCameraTheme.primaryBright,
              semanticLabel: 'Create Memory',
              onTap: onMemory,
            ),
          ),

          // ========================================================
          // OBJECT
          // ========================================================

          Positioned(
            left: wheelSize * 0.013,
            top: wheelSize * 0.373,
            child: _CreateOption(
              icon: Icons.view_in_ar_rounded,
              label: 'Object',
              accent: ARCameraTheme.primaryBright,
              semanticLabel: 'Create Object',
              onTap: onObject,
            ),
          ),

          // ========================================================
          // COMMENT
          // ========================================================

          Positioned(
            right: wheelSize * 0.013,
            top: wheelSize * 0.373,
            child: _CreateOption(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Comment',
              accent: ARCameraTheme.spatial,
              semanticLabel: 'Create Comment',
              onTap: onComment,
            ),
          ),

          // ========================================================
          // CENTER CLOSE
          // ========================================================

          _CreateCenterButton(
            onTap: onClose,
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// CREATE OPTION
// ==================================================================

class _CreateOption extends StatefulWidget {
  const _CreateOption({
    required this.icon,
    required this.label,
    required this.accent,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  State<_CreateOption> createState() => _CreateOptionState();
}

class _CreateOptionState extends State<_CreateOption> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted || _pressed == value) {
      return;
    }

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) {
          _setPressed(false);
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.93 : 1.0,
          duration: ARCameraTheme.motionFast,
          curve: ARCameraTheme.motionCurve,
          child: SizedBox(
            width: 78,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================================================
                // ICON SURFACE
                // ==================================================

                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 12,
                      sigmaY: 12,
                    ),
                    child: AnimatedContainer(
                      duration: ARCameraTheme.motionFast,
                      curve: ARCameraTheme.motionCurve,
                      width: _pressed ? 60 : 58,
                      height: _pressed ? 60 : 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _pressed
                            ? ARCameraTheme.glassColor
                            : ARCameraTheme.glassStrongColor,
                        border: Border.all(
                          color: widget.accent.withValues(
                            alpha: _pressed ? 0.62 : 0.42,
                          ),
                          width: _pressed ? 1.2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.accent.withValues(
                              alpha: _pressed ? 0.28 : 0.18,
                            ),
                            blurRadius: _pressed ? 24 : 20,
                            spreadRadius: _pressed ? 2 : 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: 21,
                        color: ARCameraTheme.textPrimary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ==================================================
                // LABEL
                // ==================================================

                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ARCameraTheme.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1,
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

// ==================================================================
// CENTER CLOSE BUTTON
// ==================================================================

class _CreateCenterButton extends StatefulWidget {
  const _CreateCenterButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  State<_CreateCenterButton> createState() =>
      _CreateCenterButtonState();
}

class _CreateCenterButtonState
    extends State<_CreateCenterButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted || _pressed == value) {
      return;
    }

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close Create Wheel',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) {
          _setPressed(false);
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: ARCameraTheme.motionFast,
          curve: ARCameraTheme.motionCurve,
          child: Container(
            width: _pressed ? 64 : 66,
            height: _pressed ? 64 : 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ARCameraTheme.glassStrongColor,
              border: Border.all(
                color: _pressed
                    ? ARCameraTheme.primaryBright
                    : ARCameraTheme.borderActive,
                width: _pressed ? 1.5 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: ARCameraTheme.primary.withValues(
                    alpha: _pressed ? 0.36 : 0.28,
                  ),
                  blurRadius: _pressed ? 30 : 26,
                  spreadRadius: _pressed ? 2 : 1,
                ),
              ],
            ),
            child: AnimatedRotation(
              turns: _pressed ? 0.02 : 0,
              duration: ARCameraTheme.motionFast,
              child: const Icon(
                Icons.close_rounded,
                size: 23,
                color: ARCameraTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}