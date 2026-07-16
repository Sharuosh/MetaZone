// File: lib/screens/ar/scene_builder/publish_scene/publish_preview_screen.dart
// MetaZone — Publish Preview (Ultra PRO Final Step)
// This screen allows the user to preview the scene before final publishing.

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../ar/scene_builder/scene_preview/scene_preview_screen.dart';
import 'publish_success_screen.dart';

import '../../../../models/publish_scene_payload.dart';

class PublishPreviewScreen extends StatelessWidget {
  final PublishScenePayload payload;

  const PublishPreviewScreen({
    super.key,
    required this.payload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _previewThumbnail(),
                  const SizedBox(height: 20),

                  _infoTile("Title", payload.title),
                  _infoTile("Description", payload.description.isEmpty ? "No description" : payload.description),
                  _infoTile("Category", payload.category),
                  _infoTile("Privacy", payload.privacy),
                  _infoTile("Tags", payload.tags.isEmpty ? "None" : payload.tags.join(", ")),
                  const SizedBox(height: 20),

                  _open3DPreviewButton(context),

                  const SizedBox(height: 40),
                  _publishNowButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // TOP BAR
  // ======================================================
  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card.withOpacity(.25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border.withOpacity(.4)),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Text("Preview Before Publish", style: AppTextStyles.title(size: 20)),
        ],
      ),
    );
  }

  // ======================================================
  // Thumbnail preview
  // ======================================================
  Widget _previewThumbnail() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(.4)),
        color: Colors.black26,
      ),
      child: payload.thumbnailBase64.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          base64Decode(payload.thumbnailBase64),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      )
          : Center(
        child: Text(
          "No thumbnail",
          style: AppTextStyles.caption(),
        ),
      ),
    );
  }

  // ======================================================
  // Info Tile
  // ======================================================
  Widget _infoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(.35)),
      ),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.caption()),
          const Spacer(),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.body().copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // OPEN FULL 3D PREVIEW
  // ======================================================
  Widget _open3DPreviewButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScenePreviewScreen(
              title: payload.title,
              description: payload.description.isEmpty
                  ? "No description"
                  : payload.description,
              coverUrl: payload.coverUrl,
              tags: payload.tags,

              // FIXED — stats removed because not in model
              objects: 0,
              lights: 0,
              physicsObjects: 0,
              sceneArea: 0.0,
            ),
          ),
        );
      },
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(.35)),
          color: AppColors.card.withOpacity(.24),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.view_in_ar, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                "Open 3D Preview",
                style: AppTextStyles.title(size: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // PUBLISH BUTTON
  // ======================================================
  Widget _publishNowButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PublishSuccessScreen(payload: payload),
          ),
        );
      },
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: AppColors.neonGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primarySoft.withOpacity(.4),
              blurRadius: 22,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Publish Now",
            style: AppTextStyles.title(size: 16)
                .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
