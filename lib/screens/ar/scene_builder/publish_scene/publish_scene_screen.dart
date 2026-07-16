// File: publish_scene_screen.dart
// MetaZone — Publish Scene (Ultra PRO Edition 2025)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

// Widgets (UPDATED REQUIRED PARAMETERS)
import 'widgets/cover_picker.dart';
import 'widgets/category_selector.dart';
import 'widgets/privacy_selector.dart';
import 'widgets/tag_input.dart';
import 'widgets/location_lock.dart';
import 'widgets/monetization_panel.dart';
import 'widgets/publish_progress_modal.dart';
import 'widgets/draft_save_banner.dart';
import 'widgets/publish_error_card.dart';

// Model
import '../../../../models/publish_scene_payload.dart';

// Success Screen
import 'publish_success_screen.dart';

class PublishSceneScreen extends StatefulWidget {
  final String sceneJson;
  final String thumbnailBase64;

  const PublishSceneScreen({
    super.key,
    required this.sceneJson,
    required this.thumbnailBase64,
  });

  @override
  State<PublishSceneScreen> createState() => _PublishSceneScreenState();
}

class _PublishSceneScreenState extends State<PublishSceneScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;

  // FORM FIELDS
  String title = "";
  String description = "";
  String coverUrl = "";
  String category = "Environment";
  String privacy = "Public";
  List<String> tags = [];

  bool locationLocked = false;
  double locationRadius = 50;

  bool monetizationEnabled = false;
  double price = 2.99;

  bool saving = false;
  bool error = false;
  bool draftSaved = false;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => draftSaved = true);
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ======================================================
  // SUBMIT PUBLISH
  // ======================================================
  void _publish() async {
    if (title.isEmpty || coverUrl.isEmpty) {
      setState(() => error = true);
      return;
    }

    setState(() {
      saving = true;
      error = false;
    });

    await Future.delayed(const Duration(seconds: 2));

    final payload = PublishScenePayload(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      coverUrl: coverUrl,
      category: category,
      tags: tags,
      privacy: privacy,
      locationLocked: locationLocked,
      monetizationEnabled: monetizationEnabled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sceneDataJson: widget.sceneJson,
      thumbnailBase64: widget.thumbnailBase64,
    );

    setState(() => saving = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PublishSuccessScreen(payload: payload),
      ),
    );
  }

  // ======================================================
  // UI BUILD
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeCtrl,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _topBar(),
                  const SizedBox(height: 16),

                  if (draftSaved)
                    const DraftSaveBanner(status: "saved"),

                  const SizedBox(height: 16),

                  // Cover Picker (REQUIRED PARAM FIXED)
                  CoverPicker(
                    onPicked: (url) => setState(() => coverUrl = url),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  _inputField(
                    label: "Title",
                    hint: "Name your AR Scene",
                    onChanged: (v) => title = v,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  _inputField(
                    label: "Description",
                    hint: "Describe what users will experience...",
                    maxLines: 4,
                    onChanged: (v) => description = v,
                  ),
                  const SizedBox(height: 20),

                  // Category Selector (REQUIRED categories FIXED)
                  CategorySelector(
                    categories: const [
                      "Environment",
                      "Sci-Fi",
                      "Fantasy",
                      "Architecture",
                      "Interactive",
                      "Portal",
                    ],
                    onSelect: (c) => setState(() => category = c),
                  ),
                  const SizedBox(height: 20),

                  // Privacy Selector (FIXED required fields)
                  PrivacySelector(
                    selected: privacy,
                    onSelect: (p) => setState(() => privacy = p),
                  ),
                  const SizedBox(height: 20),

                  // Tags Input (FIXED required tags param)
                  TagInput(
                    tags: tags,
                    onChanged: (list) => setState(() => tags = list),
                  ),
                  const SizedBox(height: 24),

                  // Location Lock (FIXED param names)
                  LocationLock(
                    enabled: locationLocked,
                    radius: locationRadius,
                    onToggle: (v) => setState(() => locationLocked = v),
                    onRadiusChange: (v) => setState(() => locationRadius = v),
                  ),
                  const SizedBox(height: 20),

                  // Monetization Panel (FIXED required parameters)
                  MonetizationPanel(
                    enabled: monetizationEnabled,
                    price: price,
                    onToggle: (v) => setState(() => monetizationEnabled = v),
                    onPriceChanged: (v) => setState(() => price = v),
                  ),
                  const SizedBox(height: 32),

                  _publishButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),

        // Publish Progress Overlay
        if (saving)
          const PublishProgressModal(
            progress: 0.2,
            statusText: "Publishing Scene...",
          ),

        // Error Card FIXED (required title/message)
        if (error)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: PublishErrorCard(
              title: "Publish Failed",
              message: "Missing title or cover.",
              onRetry: () {
                setState(() => error = false);
                _publish();
              },
            ),
          ),
      ],
    );
  }

  // ======================================================
  // Top Bar
  // ======================================================
  Widget _topBar() {
    return Row(
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
            child: const Icon(Icons.close, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        Text("Publish Scene", style: AppTextStyles.title(size: 22)),
      ],
    );
  }

  // ======================================================
  // Input Field
  // ======================================================
  Widget _inputField({
    required String label,
    required String hint,
    required Function(String) onChanged,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption(size: 13)),
        const SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: AppColors.surface.withOpacity(.25),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border.withOpacity(.4)),
            ),
          ),
        ),
      ],
    );
  }

  // ======================================================
  // Publish Button
  // ======================================================
  Widget _publishButton() {
    return GestureDetector(
      onTap: saving ? null : _publish,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: saving
              ? LinearGradient(colors: [Colors.grey[700]!, Colors.grey[800]!])
              : AppColors.neonGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!saving)
              BoxShadow(
                color: AppColors.primarySoft.withOpacity(.4),
                blurRadius: 22,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Center(
          child: saving
              ? const CircularProgressIndicator(color: Colors.black)
              : Text(
            "Publish Now",
            style: AppTextStyles.title(size: 16)
                .copyWith(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
