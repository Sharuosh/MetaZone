// lib/screens/marketplace/preview_ar.dart
// MetaZone – AR Product Preview (Ultra Edition)

import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class PreviewARScreen extends StatefulWidget {
  final String productTitle;
  final String productModel3D; // path or ID
  final double price;

  const PreviewARScreen({
    super.key,
    required this.productTitle,
    required this.productModel3D,
    required this.price,
  });

  @override
  State<PreviewARScreen> createState() => _PreviewARScreenState();
}

class _PreviewARScreenState extends State<PreviewARScreen>
    with TickerProviderStateMixin {
  bool _arStarted = false;
  bool _showShadow = true;
  bool _showGrid = true;
  bool _showInfo = true;

  double _scale = 1.0;
  double _rotation = 0.0;
  Offset _offset = Offset.zero;

  late AnimationController pulse;

  @override
  void initState() {
    super.initState();
    pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  // UI BEGINS
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _topBar(),
      body: Stack(
        children: [
          _arPlaceholderLayer(),
          if (_showGrid) _gridOverlay(),
          if (_showInfo && !_arStarted) _tapToStartHint(),
          _floatingModelPreview(size),
          _bottomControls(),
        ],
      ),
    );
  }

  // TOP BAR
  AppBar _topBar() {
    return AppBar(
      title: Text("AR Preview", style: AppTextStyles.heading()),
      backgroundColor: Colors.black.withOpacity(0.4),
      actions: [
        IconButton(
          icon: Icon(_showGrid ? Icons.grid_off : Icons.grid_on),
          onPressed: () => setState(() => _showGrid = !_showGrid),
        ),
        IconButton(
          icon: Icon(_showInfo ? Icons.info_outline : Icons.info),
          onPressed: () => setState(() => _showInfo = !_showInfo),
        ),
      ],
    );
  }

  // CAMERA BACKGROUND PLACEHOLDER
  Widget _arPlaceholderLayer() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            colors: [
              Colors.black,
              Colors.purple.shade900.withOpacity(.45),
            ],
          ),
        ),
        child: Center(
          child: Text(
            _arStarted ? "AR Active…" : "Camera Feed Placeholder",
            style: AppTextStyles.caption(),
          ),
        ),
      ),
    );
  }

  // MODEL PREVIEW (DRAG + ROTATE + SCALE)
  Widget _floatingModelPreview(Size size) {
    if (!_arStarted) return const SizedBox();

    return Positioned(
      top: size.height * 0.32 + _offset.dy,
      left: size.width / 2 - 75 + _offset.dx,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => _offset += d.delta),
        onScaleUpdate: (d) =>
            setState(() => _scale = (_scale * d.scale).clamp(0.3, 3.5)),
        onLongPress: () => setState(() => _rotation += pi / 6),
        child: Transform(
          transform: Matrix4.identity()
            ..scale(_scale)
            ..rotateY(_rotation),
          alignment: Alignment.center,
          child: _renderObject(),
        ),
      ),
    );
  }

  // The glowing container representing the 3D model
  Widget _renderObject() {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) {
        return Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(.4 + pulse.value * 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 35,
                color: AppColors.primary.withOpacity(.5),
              )
            ],
          ),
          child: Center(
            child: Icon(Icons.chair_alt,
                size: 70, color: AppColors.primary.withOpacity(.9)),
          ),
        );
      },
    );
  }

  // GRID OVERLAY
  Widget _gridOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _GridPainter(),
        ),
      ),
    );
  }

  // TAP TO START MESSAGE
  Widget _tapToStartHint() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app, color: AppColors.primary, size: 40),
          const SizedBox(height: 10),
          Text("Tap anywhere to start AR",
              style: AppTextStyles.title(size: 16)),
        ],
      ),
    );
  }

  // BOTTOM ACTIONS
  Widget _bottomControls() {
    return Positioned(
      bottom: 25,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _circleBtn(Icons.refresh, "Reset", () {
            setState(() {
              _offset = Offset.zero;
              _scale = 1.0;
              _rotation = 0.0;
            });
          }),

          _circleBtn(Icons.light_mode,
              _showShadow ? "Shadow Off" : "Shadow On",
                  () => setState(() => _showShadow = !_showShadow)),

          _circleBtn(
            _arStarted ? Icons.stop_circle : Icons.play_circle_fill,
            _arStarted ? "Stop" : "Start",
                () => setState(() => _arStarted = !_arStarted),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, String label, VoidCallback tap) {
    return Column(
      children: [
        GestureDetector(
          onTap: tap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.card,
              border: Border.all(color: AppColors.primary),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.caption(size: 11)),
      ],
    );
  }
}

// CUSTOM GRID PAINTER
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 0.6;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
