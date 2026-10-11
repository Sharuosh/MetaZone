import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/ar_camera_theme.dart';
import 'ar_glass.dart';
import 'object_library.dart';

/// MetaZone Spatial Object Editor V2.
///
/// Flutter owns the editor experience, tool state, gestures, feedback and
/// callbacks. Unity remains responsible for the real world-space transform,
/// anchors, raycasts, depth/occlusion and the actual 3D scene mutation.
class ObjectSelectedEditor extends StatefulWidget {
  const ObjectSelectedEditor({
    super.key,
    required this.object,
    required this.onDone,
    required this.onDelete,
    required this.onDuplicate,
    required this.onEdit,
  });

  final ARLibraryObject object;
  final VoidCallback onDone;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onEdit;

  @override
  State<ObjectSelectedEditor> createState() => _ObjectSelectedEditorState();
}

class _ObjectSelectedEditorState extends State<ObjectSelectedEditor>
    with SingleTickerProviderStateMixin {
  EditorTool _activeTool = EditorTool.move;
  bool _locked = false;
  bool _showActions = false;
  bool _showPrecision = false;

  double _scale = 1.0;
  double _rotation = 0.0;
  Offset _offset = Offset.zero;

  Offset _gestureStartOffset = Offset.zero;
  Offset _gestureStartFocalPoint = Offset.zero;
  double _gestureStartScale = 1.0;
  double _gestureStartRotation = 0.0;


  late final AnimationController _selectionPulse;

  @override
  void initState() {
    super.initState();
    _selectionPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _selectionPulse.dispose();
    super.dispose();
  }

  void _selectTool(EditorTool tool) {
    if (_locked || _activeTool == tool) return;
    setState(() {
      _activeTool = tool;
      _showPrecision = true;
    });
  }

  void _resetTransform() {
    if (_locked) return;
    setState(() {
      _scale = 1.0;
      _rotation = 0.0;
      _offset = Offset.zero;
    });
  }

  void _beginGesture(ScaleStartDetails details) {
    if (_locked) return;
    _gestureStartOffset = _offset;
    _gestureStartFocalPoint = details.focalPoint;
    _gestureStartScale = _scale;
    _gestureStartRotation = _rotation;

  }

  void _updateGesture(ScaleUpdateDetails details) {
    if (_locked) return;

    setState(() {
      switch (_activeTool) {
        case EditorTool.move:
          _offset = _gestureStartOffset +
              (details.focalPoint - _gestureStartFocalPoint);
          break;
        case EditorTool.scale:
          _scale = (_gestureStartScale * details.scale).clamp(0.25, 3.0);
          break;
        case EditorTool.rotate:
          if (details.rotation != 0) {
            _rotation = _normalizeDegrees(
              _gestureStartRotation + details.rotation * 180 / math.pi,
            );
          }
          break;
      }
    });

    // UNITY INTEGRATION POINT:
    // Forward the active transform command/value to Unity here.
  }

  double _normalizeDegrees(double value) {
    var result = value % 360;
    if (result > 180) result -= 360;
    if (result < -180) result += 360;
    return result;
  }

  void _setScale(double value) {
    if (_locked) return;
    setState(() => _scale = value.clamp(0.25, 3.0));
    // UNITY INTEGRATION POINT: send scale to Unity.
  }

  void _setRotation(double value) {
    if (_locked) return;
    setState(() => _rotation = _normalizeDegrees(value));
    // UNITY INTEGRATION POINT: send rotation to Unity.
  }

  void _nudge(Offset delta) {
    if (_locked) return;
    setState(() => _offset += delta);
    // UNITY INTEGRATION POINT: send positional nudge to Unity.
  }

  Future<void> _deleteObject() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.52),
      useSafeArea: true,
      builder: (_) => const _DeleteConfirmationSheet(),
    );
    if (confirmed == true && mounted) widget.onDelete();
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1100),
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 110),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (_showActions || _showPrecision) {
                    setState(() {
                      _showActions = false;
                      _showPrecision = false;
                    });
                  }
                },
              ),
            ),

            Center(
              child: Transform.translate(
                offset: _offset,
                child: _SelectedSpatialObject(
                  object: widget.object,
                  scale: _scale,
                  rotation: _rotation,
                  locked: _locked,
                  pulse: _selectionPulse,
                  onScaleStart: _beginGesture,
                  onScaleUpdate: _updateGesture,
                ),
              ),
            ),

            Positioned(
              top: 8,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _GlassIconButton(
                    icon: Icons.arrow_back_rounded,
                    label: 'Back',
                    onTap: widget.onDone,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _ObjectHeader(object: widget.object, locked: _locked)),
                  const SizedBox(width: 8),
                  _GlassIconButton(
                    icon: _locked ? Icons.lock_rounded : Icons.lock_open_rounded,
                    label: _locked ? 'Unlock' : 'Lock',
                    active: _locked,
                    onTap: () => setState(() => _locked = !_locked),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Center(
                child: _SelectionStatus(
                  object: widget.object,
                  tool: _activeTool,
                  locked: _locked,
                ),
              ),
            ),

            Positioned(
              right: 12,
              top: 112,
              child: _ActionRail(
                expanded: _showActions,
                onToggle: () => setState(() => _showActions = !_showActions),
                onDuplicate: () {
                  widget.onDuplicate();
                  _showFeedback('Object duplicated');
                },
                onEdit: widget.onEdit,
                onDelete: _deleteObject,
              ),
            ),

            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: _EditorDock(
                activeTool: _activeTool,
                locked: _locked,
                showPrecision: _showPrecision,
                scale: _scale,
                rotation: _rotation,
                onToolChanged: _selectTool,
                onPrecisionToggle: () => setState(() => _showPrecision = !_showPrecision),
                onScaleChanged: _setScale,
                onRotationChanged: _setRotation,
                onNudge: _nudge,
                onReset: _resetTransform,
                onDone: widget.onDone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum EditorTool { move, rotate, scale }

class _SelectedSpatialObject extends StatelessWidget {
  const _SelectedSpatialObject({
    required this.object,
    required this.scale,
    required this.rotation,
    required this.locked,
    required this.pulse,
    required this.onScaleStart,
    required this.onScaleUpdate,
  });

  final ARLibraryObject object;
  final double scale;
  final double rotation;
  final bool locked;
  final Animation<double> pulse;
  final GestureScaleStartCallback onScaleStart;
  final GestureScaleUpdateCallback onScaleUpdate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: locked ? null : onScaleStart,
      onScaleUpdate: locked ? null : onScaleUpdate,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, child) {
          final glow = 0.18 + pulse.value * 0.16;
          return Transform.rotate(
            angle: rotation * math.pi / 180,
            child: Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: locked
                            ? ARCameraTheme.warning.withValues(alpha: 0.38)
                            : ARCameraTheme.primaryBright.withValues(alpha: 0.42),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (locked
                              ? ARCameraTheme.warning
                              : ARCameraTheme.primary)
                              .withValues(alpha: glow),
                          blurRadius: 32,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: ARCameraTheme.glassStrongColor,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: ARCameraTheme.borderActive),
                    ),
                    child: Icon(
                      object.icon,
                      size: 50,
                      color: ARCameraTheme.primaryBright,
                    ),
                  ),
                  if (!locked) ...[
                    const _AxisHandle(alignment: Alignment.topCenter, axis: 'Y'),
                    const _AxisHandle(alignment: Alignment.centerRight, axis: 'X'),
                  ],
                  Positioned(
                    bottom: -25,
                    child: _TransformReadout(
                      scale: scale,
                      rotation: rotation,
                      locked: locked,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AxisHandle extends StatelessWidget {
  const _AxisHandle({required this.alignment, required this.axis});
  final Alignment alignment;
  final String axis;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ARCameraTheme.glassStrongColor,
          border: Border.all(color: ARCameraTheme.borderActive),
        ),
        child: Center(
          child: Text(
            axis,
            style: const TextStyle(
              color: ARCameraTheme.textPrimary,
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _TransformReadout extends StatelessWidget {
  const _TransformReadout({required this.scale, required this.rotation, required this.locked});
  final double scale;
  final double rotation;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return ARGlass(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      blur: ARCameraTheme.glassBlur,
      opacity: ARCameraTheme.glassStrongOpacity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            locked ? Icons.lock_rounded : Icons.open_with_rounded,
            size: 11,
            color: locked ? ARCameraTheme.warning : ARCameraTheme.textSecondary,
          ),
          const SizedBox(width: 5),
          Text(
            '${scale.toStringAsFixed(2)}×  •  ${rotation.toStringAsFixed(0)}°',
            style: const TextStyle(
              color: ARCameraTheme.textSecondary,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ObjectHeader extends StatelessWidget {
  const _ObjectHeader({required this.object, required this.locked});
  final ARLibraryObject object;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return ARGlass(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      blur: ARCameraTheme.glassBlur,
      opacity: ARCameraTheme.glassStrongOpacity,
      child: Row(
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(
              color: ARCameraTheme.primarySoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(object.icon, size: 15, color: ARCameraTheme.primaryBright),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  object.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ARCameraTheme.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  locked ? 'Locked' : 'Spatial editor',
                  style: TextStyle(
                    color: locked ? ARCameraTheme.warning : ARCameraTheme.textMuted,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionStatus extends StatelessWidget {
  const _SelectionStatus({required this.object, required this.tool, required this.locked});
  final ARLibraryObject object;
  final EditorTool tool;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final label = locked ? 'Object locked' : '${tool.label} • ${object.name}';
    return ARGlass(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      borderRadius: const BorderRadius.all(Radius.circular(13)),
      blur: ARCameraTheme.glassBlur,
      opacity: ARCameraTheme.glassOpacity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            locked ? Icons.lock_rounded : tool.icon,
            size: 13,
            color: locked ? ARCameraTheme.warning : ARCameraTheme.primaryBright,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: locked ? ARCameraTheme.warning : ARCameraTheme.textSecondary,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

extension on EditorTool {
  String get label {
    switch (this) {
      case EditorTool.move:
        return 'Move';
      case EditorTool.rotate:
        return 'Rotate';
      case EditorTool.scale:
        return 'Scale';
    }
  }

  IconData get icon {
    switch (this) {
      case EditorTool.move:
        return Icons.open_with_rounded;
      case EditorTool.rotate:
        return Icons.rotate_right_rounded;
      case EditorTool.scale:
        return Icons.unfold_more_rounded;
    }
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({
    required this.expanded,
    required this.onToggle,
    required this.onDuplicate,
    required this.onEdit,
    required this.onDelete,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onDuplicate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ARGlass(
      padding: const EdgeInsets.all(4),
      borderRadius: const BorderRadius.all(Radius.circular(17)),
      blur: ARCameraTheme.glassBlur,
      opacity: ARCameraTheme.glassStrongOpacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RailButton(
            icon: expanded ? Icons.close_rounded : Icons.more_horiz_rounded,
            label: expanded ? 'Close actions' : 'Object actions',
            onTap: onToggle,
          ),
          AnimatedSize(
            duration: ARCameraTheme.motionNormal,
            curve: ARCameraTheme.motionCurve,
            child: expanded
                ? Column(
              children: [
                const _RailDivider(),
                _RailButton(icon: Icons.copy_rounded, label: 'Duplicate', onTap: onDuplicate),
                const _RailDivider(),
                _RailButton(icon: Icons.tune_rounded, label: 'Edit details', onTap: onEdit),
                const _RailDivider(),
                _RailButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  destructive: true,
                  onTap: onDelete,
                ),
              ],
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _RailDivider extends StatelessWidget {
  const _RailDivider();
  @override
  Widget build(BuildContext context) => Container(width: 30, height: 1, color: ARCameraTheme.border);
}

class _RailButton extends StatelessWidget {
  const _RailButton({required this.icon, required this.label, required this.onTap, this.destructive = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 43,
          child: Icon(
            icon,
            size: 17,
            color: destructive ? ARCameraTheme.error : ARCameraTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _EditorDock extends StatelessWidget {
  const _EditorDock({
    required this.activeTool,
    required this.locked,
    required this.showPrecision,
    required this.scale,
    required this.rotation,
    required this.onToolChanged,
    required this.onPrecisionToggle,
    required this.onScaleChanged,
    required this.onRotationChanged,
    required this.onNudge,
    required this.onReset,
    required this.onDone,
  });

  final EditorTool activeTool;
  final bool locked;
  final bool showPrecision;
  final double scale;
  final double rotation;
  final ValueChanged<EditorTool> onToolChanged;
  final VoidCallback onPrecisionToggle;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<double> onRotationChanged;
  final ValueChanged<Offset> onNudge;
  final VoidCallback onReset;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return ARGlass(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 9),
      borderRadius: const BorderRadius.all(Radius.circular(22)),
      blur: ARCameraTheme.glassBlurStrong,
      opacity: ARCameraTheme.glassStrongOpacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: _ToolChip(tool: EditorTool.move, active: activeTool == EditorTool.move, locked: locked, onTap: () => onToolChanged(EditorTool.move))),
              const SizedBox(width: 6),
              Expanded(child: _ToolChip(tool: EditorTool.rotate, active: activeTool == EditorTool.rotate, locked: locked, onTap: () => onToolChanged(EditorTool.rotate))),
              const SizedBox(width: 6),
              Expanded(child: _ToolChip(tool: EditorTool.scale, active: activeTool == EditorTool.scale, locked: locked, onTap: () => onToolChanged(EditorTool.scale))),
              const SizedBox(width: 6),
              _DockIconButton(
                icon: showPrecision ? Icons.keyboard_arrow_down_rounded : Icons.tune_rounded,
                label: showPrecision ? 'Hide precision' : 'Precision controls',
                onTap: locked ? null : onPrecisionToggle,
              ),
            ],
          ),
          AnimatedSize(
            duration: ARCameraTheme.motionNormal,
            curve: ARCameraTheme.motionCurve,
            child: showPrecision
                ? Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _PrecisionArea(
                activeTool: activeTool,
                locked: locked,
                scale: scale,
                rotation: rotation,
                onScaleChanged: onScaleChanged,
                onRotationChanged: onRotationChanged,
                onNudge: onNudge,
                onReset: onReset,
              ),
            )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: locked ? null : onReset,
                  icon: const Icon(Icons.restart_alt_rounded, size: 15),
                  label: const Text('Reset', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ARCameraTheme.textSecondary,
                    disabledForegroundColor: ARCameraTheme.textMuted,
                    side: const BorderSide(color: ARCameraTheme.border),
                    minimumSize: const Size.fromHeight(38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: onDone,
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Done', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ARCameraTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
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

class _ToolChip extends StatelessWidget {
  const _ToolChip({required this.tool, required this.active, required this.locked, required this.onTap});
  final EditorTool tool;
  final bool active;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: '${tool.label} tool',
      child: InkWell(
        onTap: locked ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: ARCameraTheme.motionFast,
          curve: ARCameraTheme.motionCurve,
          height: 42,
          decoration: BoxDecoration(
            color: active ? ARCameraTheme.primarySoft : ARCameraTheme.glassSoftColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: active ? ARCameraTheme.borderActive : ARCameraTheme.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tool.icon, size: 16, color: active ? ARCameraTheme.primaryBright : ARCameraTheme.textSecondary),
              const SizedBox(width: 5),
              Text(
                tool.label,
                style: TextStyle(
                  color: active ? ARCameraTheme.textPrimary : ARCameraTheme.textSecondary,
                  fontSize: 9,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockIconButton extends StatelessWidget {
  const _DockIconButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedOpacity(
          duration: ARCameraTheme.motionFast,
          opacity: onTap == null ? 0.4 : 1,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: ARCameraTheme.glassSoftColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ARCameraTheme.border),
            ),
            child: Icon(icon, size: 18, color: ARCameraTheme.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _PrecisionArea extends StatelessWidget {
  const _PrecisionArea({
    required this.activeTool,
    required this.locked,
    required this.scale,
    required this.rotation,
    required this.onScaleChanged,
    required this.onRotationChanged,
    required this.onNudge,
    required this.onReset,
  });

  final EditorTool activeTool;
  final bool locked;
  final double scale;
  final double rotation;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<double> onRotationChanged;
  final ValueChanged<Offset> onNudge;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    switch (activeTool) {
      case EditorTool.move:
        return _MovePrecision(locked: locked, onNudge: onNudge);
      case EditorTool.rotate:
        return _SliderControl(
          label: 'Rotation',
          value: rotation,
          min: -180,
          max: 180,
          suffix: '°',
          icon: Icons.rotate_right_rounded,
          locked: locked,
          onChanged: onRotationChanged,
          onReset: onReset,
        );
      case EditorTool.scale:
        return _SliderControl(
          label: 'Scale',
          value: scale,
          min: 0.25,
          max: 3,
          suffix: '×',
          icon: Icons.unfold_more_rounded,
          locked: locked,
          onChanged: onScaleChanged,
          onReset: onReset,
        );
    }
  }
}

class _MovePrecision extends StatelessWidget {
  const _MovePrecision({required this.locked, required this.onNudge});
  final bool locked;
  final ValueChanged<Offset> onNudge;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Fine movement', style: TextStyle(color: ARCameraTheme.textSecondary, fontSize: 9, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _NudgeButton(icon: Icons.keyboard_arrow_left_rounded, label: 'Left', enabled: !locked, onTap: () => onNudge(const Offset(-4, 0))),
            const SizedBox(width: 5),
            Column(
              children: [
                _NudgeButton(icon: Icons.keyboard_arrow_up_rounded, label: 'Up', enabled: !locked, onTap: () => onNudge(const Offset(0, -4))),
                const SizedBox(height: 5),
                _NudgeButton(icon: Icons.keyboard_arrow_down_rounded, label: 'Down', enabled: !locked, onTap: () => onNudge(const Offset(0, 4))),
              ],
            ),
            const SizedBox(width: 5),
            _NudgeButton(icon: Icons.keyboard_arrow_right_rounded, label: 'Right', enabled: !locked, onTap: () => onNudge(const Offset(4, 0))),
          ],
        ),
      ],
    );
  }
}

class _NudgeButton extends StatelessWidget {
  const _NudgeButton({required this.icon, required this.label, required this.enabled, required this.onTap});
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(11),
        child: AnimatedOpacity(
          duration: ARCameraTheme.motionFast,
          opacity: enabled ? 1 : 0.35,
          child: Container(
            width: 34,
            height: 28,
            decoration: BoxDecoration(
              color: ARCameraTheme.glassSoftColor,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: ARCameraTheme.border),
            ),
            child: Icon(icon, size: 16, color: ARCameraTheme.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _SliderControl extends StatelessWidget {
  const _SliderControl({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.icon,
    required this.locked,
    required this.onChanged,
    required this.onReset,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String suffix;
  final IconData icon;
  final bool locked;
  final ValueChanged<double> onChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: ARCameraTheme.primaryBright),
            const SizedBox(width: 6),
            Expanded(child: Text(label, style: const TextStyle(color: ARCameraTheme.textSecondary, fontSize: 9, fontWeight: FontWeight.w700))),
            Text('${value.toStringAsFixed(2)}$suffix', style: const TextStyle(color: ARCameraTheme.textPrimary, fontSize: 9, fontWeight: FontWeight.w700)),
            const SizedBox(width: 5),
            InkWell(
              onTap: locked ? null : onReset,
              borderRadius: BorderRadius.circular(9),
              child: const Padding(
                padding: EdgeInsets.all(3),
                child: Icon(Icons.refresh_rounded, size: 13, color: ARCameraTheme.textMuted),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 13),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: locked ? null : onChanged,
            activeColor: ARCameraTheme.primaryBright,
            inactiveColor: ARCameraTheme.border,
          ),
        ),
      ],
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.label, required this.onTap, this.active = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: ARCameraTheme.motionFast,
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: active ? ARCameraTheme.primarySoft : ARCameraTheme.glassStrongColor,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: active ? ARCameraTheme.borderActive : ARCameraTheme.border),
          ),
          child: Icon(icon, size: 17, color: active ? ARCameraTheme.primaryBright : ARCameraTheme.textPrimary),
        ),
      ),
    );
  }
}

class _DeleteConfirmationSheet extends StatelessWidget {
  const _DeleteConfirmationSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: ARGlass(
        padding: const EdgeInsets.all(16),
        borderRadius: const BorderRadius.all(Radius.circular(22)),
        blur: ARCameraTheme.glassBlurStrong,
        opacity: ARCameraTheme.glassStrongOpacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 34, height: 3, decoration: BoxDecoration(color: ARCameraTheme.textMuted, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 14),
            const Icon(Icons.delete_outline_rounded, size: 30, color: ARCameraTheme.error),
            const SizedBox(height: 10),
            const Text('Delete object?', style: TextStyle(color: ARCameraTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('This removes the object from the current editing flow.', textAlign: TextAlign.center, style: TextStyle(color: ARCameraTheme.textSecondary, fontSize: 9, height: 1.4)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(foregroundColor: ARCameraTheme.textSecondary, side: const BorderSide(color: ARCameraTheme.border), minimumSize: const Size.fromHeight(43), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                    child: const Text('Cancel', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(backgroundColor: ARCameraTheme.error, foregroundColor: Colors.white, elevation: 0, minimumSize: const Size.fromHeight(43), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                    child: const Text('Delete', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
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
