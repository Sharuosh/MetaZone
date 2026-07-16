// File: lib/screens/ar/create/ar_portal_viewer.dart
// MetaZone — AR Portal Viewer (Merged & Enhanced)
// Keep AppColors & AppTextStyles in core/theme/theme.dart
// Notes:
//  - This file is UI / UX heavy and acts as a shell for real AR runtime (UnityWidget / ARCore).
//  - Look for TODO comments to connect native/Unity / Firestore / deep links.

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/theme/theme.dart';

class ARPortalViewerScreen extends StatefulWidget {
  final String? spotId;
  final String? title;
  final String? owner;

  const ARPortalViewerScreen({super.key, this.spotId, this.title, this.owner});

  @override
  State<ARPortalViewerScreen> createState() => _ARPortalViewerScreenState();
}

class _ARPortalViewerScreenState extends State<ARPortalViewerScreen>
    with TickerProviderStateMixin {
  // ----- State -----
  bool _isLiveAR = false;
  bool _isAnchored = false;
  bool _flash = false;
  bool _saving = false;
  bool _sharing = false;

  // transform
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  double _rotation = 0.0;

  // animations
  late final AnimationController _glowCtrl;
  late final AnimationController _vortexCtrl;
  late final AnimationController _entryCtrl;
  late final Animation<double> _glowAnim;
  late final Animation<double> _vortexAnim;
  late final Animation<double> _entryAnim;

  // anchors demo
  final List<Map<String, dynamic>> _anchors = [];

  // snapshot key
  final GlobalKey _previewKey = GlobalKey();

  // environments
  String _environment = "Sci-Fi Base";
  final List<String> _environments = [
    "Sci-Fi Base",
    "Ancient Temple",
    "Cyber City",
    "Fantasy Forest",
    "Underwater World",
  ];

  // teleport points
  final List<String> _teleportPoints = [
    "Entrance",
    "Hallway",
    "Control Room",
    "Observation Deck",
    "Secret Chamber",
  ];
  String _selectedNode = "Entrance";

  @override
  void initState() {
    super.initState();

    _glowCtrl =
    AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _vortexCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));

    _glowAnim = Tween<double>(begin: 0.86, end: 1.18)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    _vortexAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _vortexCtrl, curve: Curves.linear));
    _entryAnim =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic);

    // demo anchors (placeholder)
    _anchors.addAll(List.generate(2, (i) {
      return {
        'id': 'anchor_$i',
        'title': 'Anchor ${i + 1}',
        'x': (i - 0.5) * 0.35,
        'functions.mz': -0.05 + i * 0.05,
      };
    }));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _vortexCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  // -------------------- ACTIONS / TODO hooks --------------------

  Future<void> _toggleARMode() async {
    // TODO: Initialize UnityWidget / native AR session here (request permissions beforehand).
    setState(() => _isLiveAR = !_isLiveAR);
    if (_isLiveAR) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Live AR placeholder — integrate UnityWidget/AR runtime here')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Stopped AR session (demo)')));
    }
  }

  void _placeOrRemoveAnchor() {
    if (_isAnchored) {
      setState(() {
        _isAnchored = false;
        _anchors.clear();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Anchor removed')));
    } else {
      setState(() {
        _isAnchored = true;
        final id = 'a_${DateTime.now().millisecondsSinceEpoch}';
        _anchors.add({
          'id': id,
          'title': 'Anchor ${_anchors.length + 1}',
          'x': _offset.dx / 200,
          'functions.mz': _offset.dy / 200
        });
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Portal anchored (demo)')));
    }
  }

  Future<void> _snapshot() async {
    setState(() => _flash = true);
    await Future.delayed(const Duration(milliseconds: 160));
    setState(() => _flash = false);

    try {
      final boundary =
      _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final img = await boundary.toImage(pixelRatio: 2.0);
        final b = await img.toByteData(format: ui.ImageByteFormat.png);
        // TODO: save b.buffer.asUint8List() to file or share via method channel / share plugin
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Snapshot captured (demo)')));
      }
    } catch (e) {
      debugPrint('snapshot error: $e');
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() => _saving = false);
    // TODO: upload portal metadata to Firestore (spotId, environment, anchors, thumbnail)
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved to drafts (demo)')));
  }

  Future<void> _share() async {
    setState(() => _sharing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _sharing = false);
    // TODO: create share deep link + copy to clipboard or invoke system share
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Share link copied (demo)')));
  }

  Future<void> _enterPortal() async {
    if (!_isAnchored) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Place portal first')));
      return;
    }
    // cinematic entry
    _entryCtrl.forward(from: 0.0);
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 900));
    // TODO: hand off to AR runtime / UnityWidget and pass anchor info & environment
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Entering Portal (demo)')));
  }

  // -------------------- INTERACTIONS --------------------

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() => _offset += d.delta);
  }

  void _onScale(double s) {
    setState(() => _scale = (s).clamp(0.5, 2.6));
  }

  void _onRotate(double r) {
    setState(() => _rotation = r % (2 * pi));
  }

  // -------------------- UI BUILDERS --------------------

  Widget _action(
      {required IconData icon,
        required String label,
        required VoidCallback onTap,
        Color? bg}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: Colors.black),
      label: Text(label, style: AppTextStyles.caption()),
      style: ElevatedButton.styleFrom(
          backgroundColor: bg ?? AppColors.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
    );
  }

  Widget _portalPreview(double size) {
    return RepaintBoundary(
      key: _previewKey,
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        child: AnimatedBuilder(
          animation: Listenable.merge([_glowCtrl, _vortexCtrl, _entryCtrl]),
          builder: (_, __) {
            final entryVal = _entryAnim.value;
            final entryScale = 1.0 + (entryVal * 1.8);
            final combinedScale = _scale * entryScale * _glowAnim.value;

            return Transform.translate(
              offset: _offset * (1.0 - entryVal * 0.5),
              child: Transform.rotate(
                angle: _rotation * (1.0 - entryVal * 0.6),
                child: Transform.scale(
                  scale: combinedScale,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size * 0.5),
                      boxShadow: [
                        BoxShadow(
                            color:
                            Colors.black.withOpacity(0.28 * _glowAnim.value),
                            blurRadius: 34 * _glowAnim.value)
                      ],
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.16 * _glowAnim.value),
                          AppColors.surface
                        ],
                        stops: const [0.0, 0.96],
                      ),
                      border:
                      Border.all(color: AppColors.border.withOpacity(0.6)),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(
                          painter: _NebulaPainter(
                              progress: _vortexAnim.value, hueSeed: 210),
                        ),
                        CustomPaint(
                          painter: _PortalRingsPainter(
                              progress: _glowAnim.value, entry: entryVal),
                        ),
                        Center(
                          child: Container(
                            width: size * 0.44,
                            height: size * 0.44,
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(size * 0.22),
                              gradient: SweepGradient(
                                colors: [
                                  Colors.deepPurple.shade900,
                                  AppColors.primary,
                                  Colors.cyanAccent.shade100
                                ],
                                stops: const [0.0, 0.6, 1.0],
                              ),
                              boxShadow: const [
                                BoxShadow(color: Colors.white10, blurRadius: 6)
                              ],
                            ),
                            child: Center(
                                child: FaIcon(FontAwesomeIcons.infinity,
                                    color: Colors.white.withOpacity(0.92),
                                    size: size * 0.09)),
                          ),
                        ),

                        // anchors display
                        if (_anchors.isNotEmpty)
                          ..._anchors.map((a) {
                            final dx = (a['x'] as double) * size + size / 2;
                            final dy = (a['functions.mz'] as double) * size + size / 2;
                            return Positioned(
                              left: dx.clamp(8.0, size - 36.0),
                              top: dy.clamp(8.0, size - 36.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border)),
                                child: Text(a['title'],
                                    style: AppTextStyles.caption(size: 12)),
                              ),
                            );
                          }).toList(),

                        // chromatic effect overlay
                        IgnorePointer(
                          ignoring: true,
                          child: Opacity(
                            opacity: 0.06 + (0.04 * _vortexAnim.value),
                            child: CustomPaint(painter: _ChromaticPainter()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHUD(double width) {
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: Row(children: [
        Expanded(
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.88),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border)),
            child: Row(children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.card,
                child: Text((widget.owner ?? 'U')[0],
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title ?? 'Portal',
                          style: AppTextStyles.title(size: 14)),
                      const SizedBox(height: 2),
                      Text(widget.owner ?? 'MetaCreator',
                          style: AppTextStyles.caption()),
                    ]),
              ),
              Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(_isAnchored ? 'Anchored' : 'Preview',
                      style: AppTextStyles.caption())),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border)),
          child: IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              _share();
            },
            icon: const Icon(Icons.share_outlined),
          ),
        )
      ]),
    );
  }

  Widget _buildControlsBottom(BuildContext c) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(
                child: _action(
                    icon: Icons.save, label: 'Save', onTap: _save, bg: AppColors.card)),
            const SizedBox(width: 8),
            Expanded(
                child: _action(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: _share,
                    bg: AppColors.card)),
            const SizedBox(width: 8),
            Expanded(
                child: _action(
                    icon: _isLiveAR ? Icons.stop_circle_outlined : Icons.vrpano,
                    label: _isLiveAR ? 'Stop AR' : 'Start AR',
                    onTap: _toggleARMode,
                    bg: _isLiveAR ? Colors.redAccent : AppColors.primary)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Scale', style: AppTextStyles.caption()),
                      Slider(
                          value: _scale,
                          min: 0.5,
                          max: 2.6,
                          onChanged: (v) => _onScale(v))
                    ])),
            const SizedBox(width: 8),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rotate', style: AppTextStyles.caption()),
                      Slider(
                          value: _rotation,
                          min: 0.0,
                          max: 2 * pi,
                          onChanged: (v) => _onRotate(v))
                    ])),
          ]),
        ]),
      ),
    );
  }

  Widget _buildRightFloating() {
    return Positioned(
      right: 12,
      bottom: 110,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        FloatingActionButton.small(
          heroTag: 'enter',
          onPressed: _enterPortal,
          backgroundColor: _isAnchored ? AppColors.primary : AppColors.card,
          child: Icon(Icons.open_in_full,
              color: _isAnchored ? Colors.black : AppColors.textLight),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.small(
          heroTag: 'anchor',
          onPressed: _placeOrRemoveAnchor,
          backgroundColor: AppColors.surface,
          child: Icon(_isAnchored ? Icons.delete_outline : Icons.push_pin,
              color: AppColors.primary),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.small(
          heroTag: 'snap',
          onPressed: _snapshot,
          backgroundColor: AppColors.surface,
          child: const Icon(Icons.camera_alt_outlined),
        ),
      ]),
    );
  }

  Widget _smallAnchorsList() {
    return Positioned(
        left: 12,
        top: MediaQuery.of(context).size.height * 0.34,
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Anchors', style: AppTextStyles.caption()),
            const SizedBox(height: 8),
            if (_anchors.isEmpty)
              Text('None', style: AppTextStyles.caption())
            else
              ..._anchors
                  .map((a) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(a['title'], style: AppTextStyles.body(size: 12)),
              ))
                  .toList(),
            const SizedBox(height: 8),
            OutlinedButton(
                onPressed: () {
                  _anchors.add({
                    'id': 'a_${DateTime.now().millisecondsSinceEpoch}',
                    'title': 'Anchor ${_anchors.length + 1}',
                    'x': 0.0,
                    'functions.mz': 0.0
                  });
                  setState(() {});
                },
                child: const Text('Add Anchor')),
          ]),
        ));
  }

  // -------------------- MAIN build --------------------

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final previewSize = (w * 0.78).clamp(260.0, 520.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(widget.title ?? 'Portal Viewer', style: AppTextStyles.heading()),
        actions: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
      ),
      body: Stack(children: [
        // background — dark nebula gradient
        Positioned.fill(
            child: Container(
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.2, -0.5),
                      radius: 1.1,
                      colors: [Colors.black, Colors.deepPurple.shade900.withOpacity(0.85)],
                    )))),
        // center preview
        Center(child: _portalPreview(previewSize)),
        if (_flash) Positioned.fill(child: Container(color: Colors.white.withOpacity(0.92))),
        _buildHUD(w),
        _buildControlsBottom(context),
        _buildRightFloating(),
        _smallAnchorsList(),
      ]),
    );
  }
}

// =================== Painters ===================

class _NebulaPainter extends CustomPainter {
  final double progress;
  final int hueSeed;
  _NebulaPainter({required this.progress, this.hueSeed = 200});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = max(size.width, size.height) * 0.6;

    final g = ui.Gradient.radial(center, radius, [
      HSVColor.fromAHSV(1.0, (hueSeed + 0) % 360, 0.5, 0.08).toColor(),
      HSVColor.fromAHSV(1.0, (hueSeed + 40) % 360, 0.6, 0.06).toColor(),
      Colors.transparent,
    ], [0.0, 0.5 + 0.2 * sin(progress * pi * 2), 1.0]);

    final paint = Paint()..shader = g..blendMode = BlendMode.plus;
    canvas.drawRect(rect, paint);

    // soft stars / particles
    final rnd = Random(4321 + (progress * 1000).toInt());
    for (int i = 0; i < 18; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final r = 0.8 + rnd.nextDouble() * 2.6;
      final p = Paint()..color = Colors.white.withOpacity(0.02 + rnd.nextDouble() * 0.06);
      canvas.drawCircle(Offset(x, y), r, p);
    }
  }

  @override
  bool shouldRepaint(covariant _NebulaPainter old) =>
      old.progress != progress || old.hueSeed != hueSeed;
}

class _PortalRingsPainter extends CustomPainter {
  final double progress;
  final double entry;
  _PortalRingsPainter({required this.progress, required this.entry});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final baseR = min(size.width, size.height) * 0.46;

    final outer = Paint()
      ..shader = ui.Gradient.radial(center, baseR * 1.02, [
        Colors.cyan.withOpacity(0.9 * progress),
        Colors.purple.withOpacity(0.6 * progress)
      ], [0.0, 1.0])
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0 * (0.8 + 0.6 * progress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, baseR * (1.0 + entry * 0.35), outer);

    for (int i = 0; i < 4; i++) {
      final d = baseR * (0.8 - i * 0.12 + 0.03 * sin(progress * pi * 2 + i));
      final a = Paint()
        ..color = Colors.white.withOpacity(0.02 + (0.05 * (4 - i)) * progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4 + i * 0.6;
      canvas.drawCircle(center, d, a);
    }

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.sweep(center, [Colors.cyan.withOpacity(0.8 * progress), Colors.transparent],
          [0.0, 0.9]);
    final rArc = baseR * 0.62;
    final sweep = pi / 3 + 0.2 * sin(progress * pi * 2);
    canvas.drawArc(Rect.fromCircle(center: center, radius: rArc), progress * pi * 2, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _PortalRingsPainter old) =>
      old.progress != progress || old.entry != entry;
}

class _ChromaticPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final p = Paint()..blendMode = BlendMode.plus;
    p.color = Colors.blue.withOpacity(0.01);
    canvas.drawRect(rect, p);
    final p2 = Paint()..blendMode = BlendMode.plus;
    p2.color = Colors.red.withOpacity(0.008);
    canvas.drawRect(rect.shift(const Offset(1.2, -1.2)), p2);
  }

  @override
  bool shouldRepaint(covariant _ChromaticPainter old) => false;
}
