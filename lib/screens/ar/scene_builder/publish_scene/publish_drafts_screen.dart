// File: publish_drafts_screen.dart
// MetaZone — Scene Builder Drafts (Ultra PRO 2025 • FIXED & CLEAN)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

// Model
import '../../../../models/publish_scene_payload.dart';

// Publish Screen (REQUIRES sceneJson + thumbnailBase64)
import '../publish_scene/publish_scene_screen.dart';

class PublishDraftsScreen extends StatefulWidget {
  const PublishDraftsScreen({super.key});

  @override
  State<PublishDraftsScreen> createState() => _PublishDraftsScreenState();
}

class _PublishDraftsScreenState extends State<PublishDraftsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;

  // ======================================================
  // Dummy Draft Payloads (FIXED TO MATCH MODEL)
  // ======================================================
  final List<PublishScenePayload> drafts = [
    PublishScenePayload(
      id: "1",
      title: "Sci-Fi Energy Core",
      description: "A futuristic glowing chamber with energy pulses.",
      category: "Sci-Fi",
      privacy: "Private",
      tags: ["Energy", "SciFi"],
      coverUrl: "https://picsum.photos/seed/scifi1/800/500",
      locationLocked: false,
      monetizationEnabled: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sceneDataJson: "{}",        // placeholder
      thumbnailBase64: "",        // placeholder
    ),
    PublishScenePayload(
      id: "2",
      title: "Mystic Forest Portal",
      description: "Fog, neon trees and a magical portal in the middle.",
      category: "Fantasy",
      privacy: "Public",
      tags: ["Forest", "Magic"],
      coverUrl: "https://picsum.photos/seed/fantasy1/800/500",
      locationLocked: false,
      monetizationEnabled: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sceneDataJson: "{}",
      thumbnailBase64: "",
    ),
    PublishScenePayload(
      id: "3",
      title: "Cyberpunk Alley",
      description: "Rainy neon street with animated holograms.",
      category: "Environment",
      privacy: "Unlisted",
      tags: ["Neon", "City"],
      coverUrl: "https://picsum.photos/seed/cyber1/800/500",
      locationLocked: false,
      monetizationEnabled: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sceneDataJson: "{}",
      thumbnailBase64: "",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeCtrl,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(),
                const SizedBox(height: 20),

                Text("Your Drafts", style: AppTextStyles.heading(size: 22)),
                const SizedBox(height: 8),

                Text(
                  "Continue editing any unfinished AR scenes.",
                  style: AppTextStyles.caption(),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView.separated(
                    itemCount: drafts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) => _draftCard(drafts[i]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ======================================================
  // TOP BAR
  // ======================================================
  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.card.withOpacity(.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withOpacity(.4)),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Text("Drafts", style: AppTextStyles.title(size: 22)),
      ],
    );
  }

  // ======================================================
  // DRAFT CARD
  // ======================================================
  Widget _draftCard(PublishScenePayload scene) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PublishSceneScreen(
              sceneJson: scene.sceneDataJson ?? "{}",  // FIX
              thumbnailBase64: scene.thumbnailBase64 ?? "",  // FIX
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(.25),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withOpacity(.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(
                scene.coverUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scene.title, style: AppTextStyles.title(size: 16)),
                  const SizedBox(height: 6),
                  Text(
                    scene.description,
                    style: AppTextStyles.caption(size: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _infoChip(scene.category),
                      const SizedBox(width: 6),
                      _infoChip("Privacy: ${scene.privacy}"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // CHIP STYLE
  // ======================================================
  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withOpacity(.3)),
      ),
      child: Text(text, style: AppTextStyles.caption(size: 11)),
    );
  }
}
