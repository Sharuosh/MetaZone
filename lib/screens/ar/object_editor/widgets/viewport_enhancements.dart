// File: lib/screens/ar/object_editor/widgets/viewport_enhancements.dart
// Viewport Enhancements for MetaZone — Grid, Gizmo placeholders, Bounding Box, Shadow catcher, Ambient indicator

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import 'dart:math';

/// A visual-only viewport overlay intended as a placeholder for the real
/// 3D/Unity rendering. It adds:
/// - Ground grid
/// - Simple shadow catcher
/// - Bounding box (outline) placeholder
/// - Gizmo placeholders for move/rotate/scale (visual + callbacks)
/// - Ambient / directional light indicator
///
/// Integration: place this widget above your AR/Unity viewport (Stack)
/// and forward pointer events to real renderer when ready.

typedef GizmoCallback = void Function(String type, String axis, Offset delta);

class ViewportEnhancements extends StatefulWidget {
  final Size? viewportSize;
  final GizmoCallback? onGizmoDrag;
  final VoidCallback? onTapGizmo;
  final String activeGizmo; // 'move'|'rotate'|'scale'|'none'

  const ViewportEnhancements({
    super.key,
    this.viewportSize,
    this.onGizmoDrag,
    this.onTapGizmo,
    this.activeGizmo = 'move',
  });

  @override
  State<ViewportEnhancements> createState() => _ViewportEnhancementsState();
}

class _ViewportEnhancementsState extends State<ViewportEnhancements> {
  Offset? _dragStart;
  String _dragAxis = 'x';

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: LayoutBuilder(builder: (context, bc) {
        final vw = widget.viewportSize ?? bc.biggest;
        return SizedBox(
          width: vw.width,
          height: vw.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _GridPainter(), size: vw),
              // shadow catcher (bottom)
              Align(alignment: Alignment.bottomCenter, child: _ShadowCatcher(width: vw.width * .9, height: 40)),
              // bounding box overlay in center
              Center(child: CustomPaint(painter: _BoundingBoxPainter(), size: Size(vw.width * .5, vw.height * .45))),

              // gizmo placeholder (centered)
              Center(child: _GizmoWidget(active: widget.activeGizmo, onDrag: _handleGizmoDrag, onTap: widget.onTapGizmo)),

              // ambient light indicator (top-right)
              Positioned(top: 12, right: 12, child: _AmbientLightIndicator()),

              // subtle depth vignette
              Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(.08)])))),
            ],
          ),
        );
      }),
    );
  }

  void _handleGizmoDrag(String gizmoType, String axis, DragUpdateDetails details) {
    widget.onGizmoDrag?.call(gizmoType, axis, details.delta);
  }
}

// ---------------------- Grid Painter ----------------------
class _GridPainter extends CustomPainter {
  final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.6
    ..color = Colors.white24;

  @override
  void paint(Canvas canvas, Size size) {
    final double step = 24.0; // grid spacing
    final center = Offset(size.width / 2, size.height * 0.66);

    // draw radial subtle lines
    for (double x = center.dx % step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, center.dy - 5000), Offset(x, center.dy + 5000), _paint);
    }
    for (double y = center.dy % step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _paint);
    }

    // center thicker line
    final p2 = Paint()..color = AppColors.primary.withOpacity(.12)..strokeWidth = 1.4;
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------- Bounding Box ----------------------
class _BoundingBoxPainter extends CustomPainter {
  final Paint _edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4
    ..color = AppColors.primary.withOpacity(.85);

  final Paint _corner = Paint()
    ..style = PaintingStyle.fill
    ..color = AppColors.primary;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(center: size.center(Offset.zero), width: size.width, height: size.height);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)), _edge);

    // corners
    final double c = 8;
    canvas.drawRect(Rect.fromCenter(center: rect.topLeft +  Offset(c, c), width: 6, height: 6), _corner);
    canvas.drawRect(Rect.fromCenter(center: rect.topRight -  Offset(c, -c), width: 6, height: 6), _corner);
    canvas.drawRect(Rect.fromCenter(center: rect.bottomLeft +  Offset(c, -c), width: 6, height: 6), _corner);
    canvas.drawRect(Rect.fromCenter(center: rect.bottomRight -  Offset(c, c), width: 6, height: 6), _corner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------- Shadow Catcher ----------------------
class _ShadowCatcher extends StatelessWidget {
  final double width;
  final double height;

  const _ShadowCatcher({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: Container(
          width: width * .6,
          height: height * .5,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.24),
            borderRadius: BorderRadius.circular(80),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.35), blurRadius: 18, spreadRadius: -6)],
          ),
        ),
      ),
    );
  }
}

// ---------------------- Ambient Light Indicator ----------------------
class _AmbientLightIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_sunny_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Ambient: 0.8', style: AppTextStyles.caption(size: 12)),
        ],
      ),
    );
  }
}

// ---------------------- Gizmo Widget (visual placeholders) ----------------------
class _GizmoWidget extends StatefulWidget {
  final String active;
  final void Function(String gizmo, String axis, DragUpdateDetails)? onDrag;
  final VoidCallback? onTap;

  const _GizmoWidget({required this.active, this.onDrag, this.onTap});

  @override
  State<_GizmoWidget> createState() => _GizmoWidgetState();
}

class _GizmoWidgetState extends State<_GizmoWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: (d) {
        // map pan to an axis delta placeholder
        widget.onDrag?.call(widget.active, 'x', DragUpdateDetails(globalPosition: d.globalPosition, delta: d.delta));
      },
      child: SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // X axis
            Positioned(left: 8, right: 80, top: 78, child: _axisLine(AppColors.primary.withOpacity(.9), 'X')),
            // Y axis
            Positioned(top: 8, bottom: 80, child: _axisLine(AppColors.primary.withOpacity(.7), 'Y', vertical: true)),
            // Z axis (diagonal)
            Transform.rotate(angle: -pi / 6, child: _axisLine(AppColors.primary.withOpacity(.5), 'Z', diagonal: true)),
            // center handle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.neonGradient,
                boxShadow: [BoxShadow(color: AppColors.primarySoft, blurRadius: 12)],
              ),
              child: const Icon(Icons.open_with, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _axisLine(Color color, String label, {bool vertical = false, bool diagonal = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: vertical ? 2 : 80, height: vertical ? 80 : 2, color: color.withOpacity(.9)),
        const SizedBox(width: 6),
        Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(6)), child: Text(label, style: AppTextStyles.caption(size: 12))),
      ],
    );
  }
}
