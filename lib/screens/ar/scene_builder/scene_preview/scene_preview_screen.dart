// MetaZone – Scene Preview Screen (Ultra PRO 2025)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../widgets/scene_thumbnail.dart';

class ScenePreviewScreen extends StatefulWidget {
  final String title;
  final String description;
  final String? coverUrl;
  final List<String> tags;

  // Scene stats (UI only)
  final int objects;
  final int lights;
  final int physicsObjects;
  final double sceneArea; // m²

  const ScenePreviewScreen({
    super.key,
    required this.title,
    required this.description,
    required this.coverUrl,
    required this.tags,
    required this.objects,
    required this.lights,
    required this.physicsObjects,
    required this.sceneArea,
  });

  @override
  State<ScenePreviewScreen> createState() => _ScenePreviewScreenState();
}

class _ScenePreviewScreenState extends State<ScenePreviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _topBar(),
                const SizedBox(height: 20),
                _coverPreview(),
                const SizedBox(height: 22),
                _titleSection(),
                const SizedBox(height: 20),
                _descriptionSection(),
                const SizedBox(height: 20),
                _sceneStats(),
                const SizedBox(height: 20),
                _tagsSection(),
                const SizedBox(height: 40),
                _bottomButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // TOP BAR
  // =============================================================
  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card.withOpacity(.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Text("Preview Scene", style: AppTextStyles.title(size: 22)),
        const Spacer(),
      ],
    );
  }

  // =============================================================
  // COVER PREVIEW
  // =============================================================
  Widget _coverPreview() {
    return SceneThumbnail(
      title: widget.title,
      subtitle: "Preview cover",
      imageUrl: widget.coverUrl,
      height: 200,
    );
  }

  // =============================================================
  // TITLE SECTION
  // =============================================================
  Widget _titleSection() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        widget.title,
        style: AppTextStyles.title(size: 26),
      ),
    );
  }

  // =============================================================
  // DESCRIPTION SECTION
  // =============================================================
  Widget _descriptionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surface.withOpacity(.18),
        border: Border.all(color: AppColors.border.withOpacity(.3)),
      ),
      child: Text(
        widget.description,
        style: AppTextStyles.body(size: 14),
      ),
    );
  }

  // =============================================================
  // STATS PANEL
  // =============================================================
  Widget _sceneStats() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Scene Summary", style: AppTextStyles.title(size: 16)),
          const SizedBox(height: 12),

          _statItem(Icons.view_in_ar, "Objects", "${widget.objects}"),
          const SizedBox(height: 10),

          _statItem(Icons.lightbulb, "Lights", "${widget.lights}"),
          const SizedBox(height: 10),

          _statItem(Icons.science, "Physics Entities",
              "${widget.physicsObjects}"),
          const SizedBox(height: 10),

          _statItem(Icons.square_foot, "Scene Area",
              "${widget.sceneArea.toStringAsFixed(1)} m²"),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 10),
        Text(label, style: AppTextStyles.body(size: 14)),
        const Spacer(),
        Text(value,
            style: AppTextStyles.title(size: 14)
                .copyWith(color: AppColors.primary)),
      ],
    );
  }

  // =============================================================
  // TAGS SECTION
  // =============================================================
  Widget _tagsSection() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 10,
        children: widget.tags
            .map((tag) => Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(.3)),
          ),
          child: Text(tag, style: AppTextStyles.caption(size: 12)),
        ))
            .toList(),
      ),
    );
  }

  // =============================================================
  // BOTTOM BUTTONS
  // =============================================================
  Widget _bottomButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.surface.withOpacity(.15),
              border: Border.all(color: AppColors.border.withOpacity(.3)),
            ),
            child: Center(
              child: Text("Back to Edit", style: AppTextStyles.title(size: 15)),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                "Publish Now",
                style: AppTextStyles.title(size: 15).copyWith(color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
