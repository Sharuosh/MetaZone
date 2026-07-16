// File: lib/screens/ar/create/ar_hub_screen.dart
// MetaZone — AR HUB (Ultra PRO Command Center)

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// AR TOOLS
import '../scene_builder/ar_scene_builder_screen.dart';
import '../object_editor/ar_object_editor_screen.dart';
import '../portal_editor/portal_editor_screen.dart';
import '../scene_builder/scene_library/scene_library_screen.dart';
import '../scene_builder/scene_preview/scene_preview_screen.dart';
import '../scene_builder/publish_scene/publish_scene_screen.dart';
import '../create/object_placement/ar_object_placement_screen.dart';
import '../anchors/anchors_manager_screen.dart';
import '../create/ar_object_generator.dart';
import '../object_interaction/ar_object_interaction.dart';
import '../create/ar_portal_viewer.dart';

class ARHubScreen extends StatefulWidget {
  const ARHubScreen({super.key});

  @override
  State<ARHubScreen> createState() => _ARHubScreenState();
}

class _ARHubScreenState extends State<ARHubScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scale = Tween(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    _glow = Tween(begin: .35, end: .85).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(child: _background()),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 44),
              children: [
                _header(),
                const SizedBox(height: 36),

                _section("CORE AR SYSTEM"),
                _coreGrid(),
                const SizedBox(height: 40),

                _section("BUILD & EDIT"),
                _grid([
                  _card("Scene Builder", "Create full AR scenes",
                      Icons.build_rounded, const ARSceneBuilderScreen()),
                  _card("Object Editor", "Materials & transforms",
                      Icons.edit_rounded, const ARObjectEditorScreen()),
                  _card("Portal Editor", "Design AR portals",
                      Icons.hdr_strong_rounded, const ARPortalEditorScreen()),
                  _card("Generator", "AI powered AR objects",
                      Icons.auto_awesome, const ARObjectGenerator()),
                ]),
                const SizedBox(height: 40),

                _section("PREVIEW & DEPLOY"),
                _grid([
                  _card("Library", "Scenes & assets",
                      Icons.library_books_rounded, const SceneLibraryScreen()),
                  _card(
                    "Preview",
                    "Test before publish",
                    Icons.remove_red_eye_rounded,
                    ScenePreviewScreen(
                      title: "Preview Scene",
                      description: "No description.",
                      coverUrl: null,
                      tags: const [],
                      objects: 0,
                      lights: 0,
                      physicsObjects: 0,
                      sceneArea: 0.0,
                    ),
                  ),
                  _card(
                    "Publish",
                    "Deploy to MetaZone",
                    Icons.upload_rounded,
                    PublishSceneScreen(
                      sceneJson: "{}",
                      thumbnailBase64: "",
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====================== UI ======================

  Widget _header() {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        return Transform.scale(
          scale: _scale.value,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: AppColors.neonGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySoft.withOpacity(_glow.value),
                  blurRadius: 36,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("AR HUB",
                    style: AppTextStyles.heading(size: 24)
                        .copyWith(color: Colors.black)),
                const SizedBox(height: 6),
                Text(
                  "MetaZone Command Center",
                  style:
                  AppTextStyles.body().copyWith(color: Colors.black87),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(title, style: AppTextStyles.title(size: 17)),
    );
  }

  Widget _coreGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 18,
      mainAxisSpacing: 18,
      childAspectRatio: 1.3,
      children: [
        _coreCard("Placement", Icons.place_rounded,
            const ARObjectPlacementScreen()),
        _coreCard("Anchors", Icons.anchor_rounded,
            const AnchorsManagerScreen()),
        _coreCard("Interaction", Icons.touch_app,
          ARObjectInteraction(
            objectId: "demo_object_001",
            objectName: "Object",
          ),
        ),
        _coreCard("Portal Viewer", Icons.vrpano_rounded,
            const ARPortalViewerScreen()),
      ],
    );
  }

  Widget _grid(List<Widget> items) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.18,
      children: items,
    );
  }

  Widget _card(
      String title, String subtitle, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () => _open(screen),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withOpacity(.45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _icon(icon),
            const Spacer(),
            Text(title, style: AppTextStyles.title(size: 14)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: AppTextStyles.caption(), maxLines: 2),
          ],
        ),
      ),
    );
  }

  Widget _coreCard(String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () => _open(screen),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: AppColors.neonGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primarySoft,
              blurRadius: 26,
            )
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 34, color: Colors.black),
              const SizedBox(height: 10),
              Text(title,
                  style: AppTextStyles.title(size: 14)
                      .copyWith(color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon(IconData icon) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: AppColors.neonGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: Colors.black, size: 26),
    );
  }

  Widget _background() {
    return CustomPaint(
      painter: _ARNoisePainter(),
      child: Container(),
    );
  }
}

// ====================== BACKGROUND ======================

class _ARNoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(.03);

    for (int i = 0; i < 10; i++) {
      final y = size.height * (.1 * i);
      final path = Path();
      path.moveTo(0, y);
      path.quadraticBezierTo(
        size.width * .5,
        y + sin(i.toDouble()) * 16,
        size.width,
        y,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
