// File: lib/screens/ar/portal_editor/panels/shape_panel.dart
// MetaZone — Portal Editor > Shape Panel (Pro, 2025 Modern UI)
// Fully self-contained panel UI (design-focused). Connectors / callbacks can be added where needed.
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/portal_config.dart';
import 'dart:math' as math;

class ShapePanel extends StatefulWidget {
  final PortalConfig? config;
  final Function(PortalConfig newConfig)? onChanged;

  const ShapePanel({
    super.key,
    this.config,
    this.onChanged,
  });

  @override
  State<ShapePanel> createState() => _ShapePanelState();
}

class _ShapePanelState extends State<ShapePanel> {
  // Shape options
  final List<String> shapes = [
    "Circular",
    "Rectangular",
    "Arch",
    "Hexagon",
    "Ring",
    "Custom"
  ];
  String _selectedShape = "Circular";

  // Geometry
  double _width = 1.0; // normalized 0.2 .. 3.0
  double _height = 1.0;
  double _depth = 0.06;
  double _rotation = 0.0; // degrees
  double _borderRadius = 0.12; // 0..1
  bool _doubleSided = true;

  // Edge / framing
  double _edgeThickness = 0.08;
  double _edgeGlow = 0.45;
  Color _edgeColor = AppColors.primary;

  // Presets
  final Map<String, Map<String, dynamic>> _presets = {
    "Portal — Classic": {
      "shape": "Circular",
      "width": 1.0,
      "height": 1.6,
      "depth": 0.06,
      "edgeThickness": 0.08,
      "edgeGlow": 0.5
    },
    "Portal — Window": {
      "shape": "Rectangular",
      "width": 1.4,
      "height": 1.0,
      "depth": 0.04,
      "edgeThickness": 0.06,
      "edgeGlow": 0.25
    },
    "Portal — Arch": {
      "shape": "Arch",
      "width": 1.2,
      "height": 1.7,
      "depth": 0.08,
      "edgeThickness": 0.12,
      "edgeGlow": 0.7
    },
  };

  // UI helpers
  String _selectedPreset = "";

  @override
  void initState() {
    super.initState();

    // If a PortalConfig was provided, try to initialize from it (best-effort)
    if (widget.config != null) {
      final c = widget.config!;
      // map simple shape names if provided
      _selectedShape = _mapConfigShape(c.shape) ?? _selectedShape;

      // If user previously stored shape state in presets['last_shape'], restore
      try {
        final last = (c.presets["last_shape"] ?? {}) as Map<String, dynamic>?;
        if (last != null) {
          _selectedShape = last["shape"] ?? _selectedShape;
          _width = (last["width"] is num) ? (last["width"] as num).toDouble() : _width;
          _height = (last["height"] is num) ? (last["height"] as num).toDouble() : _height;
          _depth = (last["depth"] is num) ? (last["depth"] as num).toDouble() : _depth;
          _rotation = (last["rotation"] is num) ? (last["rotation"] as num).toDouble() : _rotation;
          _borderRadius = (last["borderRadius"] is num) ? (last["borderRadius"] as num).toDouble() : _borderRadius;
          _edgeThickness = (last["edgeThickness"] is num) ? (last["edgeThickness"] as num).toDouble() : _edgeThickness;
          _edgeGlow = (last["edgeGlow"] is num) ? (last["edgeGlow"] as num).toDouble() : _edgeGlow;
          if (last["edgeColor"] is int) _edgeColor = Color(last["edgeColor"]);
          _doubleSided = last["doubleSided"] ?? _doubleSided;
        }
      } catch (_) {
        // ignore parse issues — fail gracefully
      }
    }
  }

  String? _mapConfigShape(String s) {
    final lower = s.toLowerCase();
    if (lower.contains("circ") || lower == "circle") return "Circular";
    if (lower.contains("rect") || lower.contains("square")) return "Rectangular";
    if (lower.contains("arch")) return "Arch";
    if (lower.contains("hex")) return "Hexagon";
    if (lower.contains("ring")) return "Ring";
    return null;
  }

  // Build a PortalConfig reflecting current UI state — stored safely inside presets
  PortalConfig _buildConfigFromState() {
    final payload = {
      "shape": _selectedShape,
      "width": _width,
      "height": _height,
      "depth": _depth,
      "rotation": _rotation,
      "borderRadius": _borderRadius,
      "edgeThickness": _edgeThickness,
      "edgeGlow": _edgeGlow,
      "edgeColor": _edgeColor.value,
      "doubleSided": _doubleSided,
    };

    if (widget.config != null) {
      final mergedPresets = Map<String, dynamic>.from(widget.config!.presets);
      mergedPresets["last_shape"] = payload;
      return widget.config!.copyWith(presets: mergedPresets);
    } else {
      return PortalConfig(presets: {"last_shape": payload});
    }
  }

  void _emitConfigUpdate() {
    try {
      final newConfig = _buildConfigFromState();
      widget.onChanged?.call(newConfig);
    } catch (_) {
      // ignore — best effort only
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Portal Shape", style: AppTextStyles.title(size: 16)),
        const SizedBox(height: 12),

        // Preview + quick actions row
        Row(
          children: [
            // Live preview (stylized)
            _previewCard(),

            const SizedBox(width: 12),

            // Quick controls & presets
            Expanded(child: Column(children: [
              _shapeDropdown(),
              const SizedBox(height: 10),
              _presetsRow(),
            ])),
          ],
        ),

        const SizedBox(height: 14),

        // Geometry sliders
        _sectionTitle("Geometry"),
        const SizedBox(height: 8),
        _labeledSlider("Width", _width, 0.2, 3.0, (v) => setState(() => _width = v),
            suffix: "m"),
        _labeledSlider("Height", _height, 0.2, 3.5, (v) => setState(() => _height = v),
            suffix: "m"),
        _labeledSlider("Depth (thickness)", _depth, 0.01, 0.25, (v) => setState(() => _depth = v),
            suffix: "m"),
        _labeledSlider("Border radius", _borderRadius, 0.0, 1.0, (v) => setState(() => _borderRadius = v),
            smallNumbers: true),

        const SizedBox(height: 12),
        _sectionTitle("Transform"),
        const SizedBox(height: 8),
        _labeledSlider("Rotation", _rotation, 0.0, 360.0, (v) => setState(() => _rotation = v),
            suffix: "°", smallNumbers: true),

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _toggleTile("Double-sided", _doubleSided, (v) => setState(() => _doubleSided = v))),
            const SizedBox(width: 10),
            Expanded(child: _toggleTile("Snap to ground", true, (v) => {/* placeholder */})),

          ],
        ),

        const SizedBox(height: 14),
        _sectionTitle("Edge & Frame"),
        const SizedBox(height: 8),
        _labeledSlider("Edge thickness", _edgeThickness, 0.01, 0.5,
                (v) => setState(() => _edgeThickness = v), suffix: "m", smallNumbers: true),
        _labeledSlider("Glow intensity", _edgeGlow, 0.0, 1.0, (v) => setState(() => _edgeGlow = v),
            smallNumbers: true),

        const SizedBox(height: 8),
        Row(
          children: [
            Text("Edge color", style: AppTextStyles.body()),
            const SizedBox(width: 10),
            _colorSwatch(AppColors.primary, () => setState(() => _edgeColor = AppColors.primary)),
            const SizedBox(width: 8),
            _colorSwatch(Colors.cyan, () => setState(() => _edgeColor = Colors.cyan)),
            const SizedBox(width: 8),
            _colorSwatch(Colors.purple, () => setState(() => _edgeColor = Colors.purple)),
            const SizedBox(width: 8),
            _colorSwatch(Colors.orange, () => setState(() => _edgeColor = Colors.orange)),
            const Spacer(),
            _glassMiniButton(Icons.colorize_rounded, () {
              // Advanced color picker can be opened here
            }),
          ],
        ),

        const SizedBox(height: 18),

        // Footer actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _resetToDefaults();
                  _emitConfigUpdate();
                },
                child: Text("Reset", style: AppTextStyles.body()),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _applyShape();
                  _emitConfigUpdate();
                },
                child: Text("Apply to Scene", style: AppTextStyles.body(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGradient.colors.first,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --------------------- UI pieces ---------------------

  Widget _sectionTitle(String text) {
    return Text(text, style: AppTextStyles.title(size: 14));
  }

  Widget _previewCard() {
    // Stylized preview representing the portal shape and edge glow
    final borderGlow = _edgeGlow.clamp(0.0, 1.0);
    return Container(
      width: 120,
      height: 160,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surface,
        border: Border.all(color: AppColors.border.withOpacity(.6)),
        boxShadow: [
          BoxShadow(
            color: _edgeColor.withOpacity(0.06 + borderGlow * .2),
            blurRadius: 12 + borderGlow * 18,
            spreadRadius: 1 + borderGlow * 3,
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // subtle background grid to imply depth
          Positioned.fill(
            child: Opacity(
              opacity: 0.06,
              child: Image.asset(
                "assets/images/grid.png",
                fit: BoxFit.cover,
                package: null,
                // NOTE: if you don't have this asset, it will be ignored at runtime — purely decorative
              ),
            ),
          ),

          // The portal silhouette
          Transform.rotate(
            angle: (_rotation / 180) * 3.1415,
            child: _portalShapePreview(),
          ),

          // tiny label
          Positioned(
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.card.withOpacity(.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_selectedShape, style: AppTextStyles.caption()),
            ),
          )
        ],
      ),
    );
  }

  Widget _portalShapePreview() {
    // Render a simplified silhouette depending on selected shape.
    final edgeColor = _edgeColor;
    final thickness = (12 * (_edgeThickness.clamp(0.01, 0.5)));
    final radius = (_borderRadius * 36);

    switch (_selectedShape) {
      case "Circular":
        return Container(
          width: 72 * _width.clamp(.6, 1.6),
          height: 100 * _height.clamp(.6, 1.6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
            border: Border.all(color: edgeColor.withOpacity(0.95), width: thickness),
            boxShadow: [
              BoxShadow(color: edgeColor.withOpacity(_edgeGlow), blurRadius: 8 * _edgeGlow)
            ],
          ),
        );

      case "Rectangular":
        return Container(
          width: 86 * _width.clamp(.6, 1.6),
          height: 112 * _height.clamp(.6, 1.6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: Colors.black,
            border: Border.all(color: edgeColor.withOpacity(0.95), width: thickness),
            boxShadow: [
              BoxShadow(color: edgeColor.withOpacity(_edgeGlow), blurRadius: 8 * _edgeGlow)
            ],
          ),
        );

      case "Arch":
        return CustomPaint(
          size: Size(96 * _width.clamp(.6, 1.6), 120 * _height.clamp(.6, 1.6)),
          painter: _ArchPainter(edgeColor, thickness, _edgeGlow, radius),
        );

      case "Hexagon":
        return CustomPaint(
          size: Size(96 * _width.clamp(.6, 1.6), 96 * _height.clamp(.6, 1.6)),
          painter: _PolygonPainter(6, edgeColor, thickness, _edgeGlow),
        );

      case "Ring":
        return Container(
          width: 92 * _width.clamp(.6, 1.6),
          height: 92 * _height.clamp(.6, 1.6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(color: edgeColor.withOpacity(0.9), width: thickness + 4),
            boxShadow: [
              BoxShadow(color: edgeColor.withOpacity(_edgeGlow), blurRadius: 10 * _edgeGlow)
            ],
          ),
          child: Center(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );

      default:
        return Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: edgeColor.withOpacity(0.95), width: thickness),
          ),
        );
    }
  }

  Widget _shapeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedShape,
          isExpanded: true,
          items: shapes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() {
            _selectedShape = v ?? shapes.first;
          }),
          dropdownColor: AppColors.card,
          style: AppTextStyles.body(),
        ),
      ),
    );
  }

  Widget _presetsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Presets", style: AppTextStyles.caption()),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _presets.entries.map((e) {
              final name = e.key;
              final data = e.value;
              final selected = _selectedPreset == name;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPreset = name;
                      _applyPreset(data);
                    });
                    _emitConfigUpdate();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: selected ? AppColors.primary.withOpacity(.12) : AppColors.card,
                      border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(name, style: AppTextStyles.caption(size: 12)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _labeledSlider(String label, double value, double min, double max, ValueChanged<double> onChange,
      {String? suffix, bool smallNumbers = false}) {
    String fmt(double v) {
      if (smallNumbers) return v.toStringAsFixed(2);
      if (max - min > 10) return v.toStringAsFixed(0);
      return v.toStringAsFixed(2);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(label, style: AppTextStyles.body()),
          const Spacer(),
          Text("${fmt(value)}${suffix ?? ""}", style: AppTextStyles.caption(size: 12)),
        ]),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChange,
          activeColor: AppColors.primary,
          inactiveColor: Colors.white24,
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _toggleTile(String title, bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(.4)),
        ),
        child: Row(
          children: [
            Text(title, style: AppTextStyles.body()),
            const Spacer(),
            Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _colorSwatch(Color color, VoidCallback onTap) {
    final selected = color.value == _edgeColor.value;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: selected ? 34 : 28,
        height: selected ? 34 : 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withOpacity(.18)),
          boxShadow: selected ? [BoxShadow(color: color.withOpacity(.28), blurRadius: 8)] : [],
        ),
      ),
    );
  }

  Widget _glassMiniButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(.45),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border.withOpacity(.4)),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  // --------------------- Actions ---------------------

  void _resetToDefaults() {
    setState(() {
      _selectedShape = "Circular";
      _width = 1.0;
      _height = 1.0;
      _depth = 0.06;
      _rotation = 0.0;
      _borderRadius = 0.12;
      _edgeThickness = 0.08;
      _edgeGlow = 0.45;
      _edgeColor = AppColors.primary;
      _doubleSided = true;
      _selectedPreset = "";
    });
  }

  void _applyShape() {
    // Hook: emit shape configuration to AR engine / parent screen
    // Example payload (later connect to Unity / backend):
    final payload = {
      "shape": _selectedShape,
      "width": _width,
      "height": _height,
      "depth": _depth,
      "rotation": _rotation,
      "borderRadius": _borderRadius,
      "edgeThickness": _edgeThickness,
      "edgeGlow": _edgeGlow,
      "edgeColor": _edgeColor.value,
      "doubleSided": _doubleSided,
    };

    // For now, quick feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Applied ${_selectedShape} — ${payload.map((k, v) => MapEntry(k, v.toString())).toString()}")),
    );
  }

  void _applyPreset(Map<String, dynamic> data) {
    setState(() {
      _selectedShape = data["shape"] ?? _selectedShape;
      _width = (data["width"] is num) ? (data["width"] as num).toDouble() : _width;
      _height = (data["height"] is num) ? (data["height"] as num).toDouble() : _height;
      _depth = (data["depth"] is num) ? (data["depth"] as num).toDouble() : _depth;
      _edgeThickness = (data["edgeThickness"] is num) ? (data["edgeThickness"] as num).toDouble() : _edgeThickness;
      _edgeGlow = (data["edgeGlow"] is num) ? (data["edgeGlow"] as num).toDouble() : _edgeGlow;
    });
  }
}

// =====================================================
//  Custom painters for preview shapes (Arch + Polygons)
// =====================================================

class _ArchPainter extends CustomPainter {
  final Color edgeColor;
  final double stroke;
  final double glow;
  final double radius;

  _ArchPainter(this.edgeColor, this.stroke, this.glow, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke.clamp(1.0, 18.0)
      ..color = edgeColor.withOpacity(0.95)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow * 8);

    final rect = Rect.fromLTWH(0, size.height * 0.18, size.width, size.height * 0.9);
    final rrect = RRect.fromRectAndCorners(rect, topLeft: Radius.circular(radius), topRight: Radius.circular(radius));
    canvas.drawRRect(rrect, paint);

    // inner fill to simulate the portal opening
    final fill = Paint()..color = Colors.black;
    final inner = Rect.fromLTWH(size.width * 0.12, size.height * 0.36, size.width * 0.76, size.height * 0.48);
    canvas.drawRRect(RRect.fromRectAndCorners(inner, topLeft: Radius.circular(radius * 0.6), topRight: Radius.circular(radius * 0.6)), fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PolygonPainter extends CustomPainter {
  final int sides;
  final Color edgeColor;
  final double stroke;
  final double glow;

  _PolygonPainter(this.sides, this.edgeColor, this.stroke, this.glow);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke.clamp(1.0, 16.0)
      ..color = edgeColor.withOpacity(0.95)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow * 6);

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;
    final path = Path();

    for (int i = 0; i < sides; i++) {
      final theta = (i / sides) * 2 * 3.1415926 - 3.1415926 / 2;
      final x = cx + r * Math.cos(theta);
      final y = cy + r * Math.sin(theta);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);

    // fill center
    final fill = Paint()..color = Colors.black;
    canvas.drawPath(path, fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Small math helpers because 'dart:math' wasn't imported to avoid collisions with project imports.
/// Use direct names to keep this file dependency-light.
class Math {
  static double cos(double x) => math.cos(x);
  static double sin(double x) => math.sin(x);
}
