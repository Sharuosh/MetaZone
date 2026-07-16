// File: lib/screens/ar/scene_builder/ar_scene_builder_screen.dart
// MetaZone – AR Scene Builder (Responsive Mobile + Tablet + Desktop)

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// Panels
import 'panels/left_assets_panel.dart';
import 'panels/right_tools_panel.dart';
import 'panels/right_properties_panel.dart';
import 'panels/bottom_timeline_panel.dart';
import 'panels/top_scene_header.dart';

// Features
import 'object_actions/object_quick_actions_menu.dart';
import 'scene_analytics/scene_analytics_panel.dart';
import 'scene_library/scene_library_screen.dart';
import 'scene_preview/scene_preview_screen.dart';
import 'publish_scene/publish_scene_screen.dart';

// Overlays
import 'publish_scene/widgets/publish_progress_modal.dart';
import 'publish_scene/widgets/draft_save_banner.dart';

class ARSceneBuilderScreen extends StatefulWidget {
  const ARSceneBuilderScreen({super.key});

  @override
  State<ARSceneBuilderScreen> createState() => _ARSceneBuilderScreenState();
}

class _ARSceneBuilderScreenState extends State<ARSceneBuilderScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;

  bool analyticsOpen = false;

  OverlayEntry? _draftBannerEntry;
  OverlayEntry? _progressModalEntry;

  Timer? _publishTimer;
  double _publishProgress = 0.0;
  String _publishStatus = "Preparing...";

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _publishTimer?.cancel();
    _removeDraftBanner();
    _removeProgressModal();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeCtrl,
          child: Column(
            children: [
              const TopSceneHeader(),
              const SizedBox(height: 8),

              /// 🔑 RESPONSIVE CORE
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isMobile = constraints.maxWidth < 900;

                    if (isMobile) {
                      /// 📱 MOBILE / TABLET
                      return Column(
                        children: [
                          Expanded(child: _buildViewport()),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 190,
                            child: const LeftAssetsPanel(),
                          ),
                        ],
                      );
                    }

                    /// 🖥️ LARGE TABLET / DESKTOP
                    return Row(
                      children: [
                        const LeftAssetsPanel(),
                        const SizedBox(width: 12),
                        Expanded(child: _buildViewport()),
                        const SizedBox(width: 12),
                        _buildRightColumn(),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 6),
              const BottomTimelinePanel(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // VIEWPORT
  // ============================================================
  Widget _buildViewport() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card.withOpacity(.16),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withOpacity(.32)),
            ),
            child: const Center(
              child: Text(
                "Viewport Placeholder\nUnity / AR will render here",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ),

        Positioned(
          left: 12,
          top: 12,
          child: Row(
            children: [
              _smallActionPill(
                icon: Icons.library_books_rounded,
                label: "Library",
                onTap: _openLibrary,
              ),
              const SizedBox(width: 8),
              _smallActionPill(
                icon: Icons.remove_red_eye_rounded,
                label: "Preview",
                onTap: _openPreview,
              ),
              const SizedBox(width: 8),
              _smallActionPill(
                icon: Icons.upload_rounded,
                label: "Publish",
                onTap: _beginPublishFlow,
              ),
            ],
          ),
        ),

        Positioned(
          top: 12,
          right: 12,
          child: _analyticsToggle(),
        ),

        Positioned(
          right: 12,
          top: 70,
          child: ObjectQuickActionsMenu(
            onFocus: () => _showSnackbar("Focus"),
            onDuplicate: () => _showSnackbar("Duplicate"),
            onBringForward: () => _showSnackbar("Bring Forward"),
            onSendBackward: () => _showSnackbar("Send Backward"),
            onLock: () => _showSnackbar("Lock"),
            onToggleGizmos: () => _showSnackbar("Gizmos"),
            onDelete: () => _showSnackbar("Delete"),
          ),
        ),

        if (analyticsOpen)
          Positioned(
            right: 0,
            top: 60,
            bottom: 60,
            child: SceneAnalyticsPanel(
              objectsCount: 16,
              lightsCount: 4,
              physicsCount: 3,
              materialsCount: 10,
              estimatedPolygons: 92.4,
              memoryUsageMB: 312,
              perfScore: 68,
            ),
          ),
      ],
    );
  }

  // ============================================================
  // UI HELPERS
  // ============================================================
  Widget _smallActionPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(.26)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.text),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.caption(size: 12)),
          ],
        ),
      ),
    );
  }

  Widget _analyticsToggle() {
    return GestureDetector(
      onTap: () => setState(() => analyticsOpen = !analyticsOpen),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppColors.neonGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: const [
            Icon(Icons.insights_outlined, size: 16, color: Colors.black),
            SizedBox(width: 6),
            Text("Analytics",
                style: TextStyle(color: Colors.black, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildRightColumn() {
    return SizedBox(
      width: 420,
      child: Column(
        children: const [
          RightToolsPanel(),
          SizedBox(height: 10),
          Expanded(child: RightPropertiesPanel()),
        ],
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================
  void _openLibrary() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SceneLibraryScreen()),
    );
  }

  void _openPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScenePreviewScreen(
          title: "Untitled Scene",
          description: "No description",
          coverUrl: null,
          tags: const [],
          objects: 0,
          lights: 0,
          physicsObjects: 0,
          sceneArea: 0.0,
        ),
      ),
    );
  }

  void _openPublishScreenWithPayload(String json, String thumbnail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublishSceneScreen(
          sceneJson: json,
          thumbnailBase64: thumbnail,
        ),
      ),
    );
  }

  // ============================================================
  // PUBLISH FLOW
  // ============================================================
  void _beginPublishFlow() {
    _showProgressModal(initialStatus: "Preparing assets...", cancelable: true);

    _publishProgress = 0.02;
    _publishStatus = "Preparing assets...";

    const totalSteps = 5;
    int step = 0;

    _publishTimer?.cancel();
    _publishTimer = Timer.periodic(const Duration(milliseconds: 600), (t) {
      step++;
      _publishProgress += 0.18;

      if (step == 2) _publishStatus = "Uploading assets...";
      if (step == 3) _publishStatus = "Processing...";
      if (step == 4) _publishStatus = "Optimizing...";

      if (step >= totalSteps) {
        _publishProgress = 1.0;
        _publishStatus = "Finalizing...";

        Future.delayed(const Duration(milliseconds: 600), () {
          _removeProgressModal();
          _openPublishScreenWithPayload(
            '{"meta":"unity_scene_stub"}',
            "",
          );
        });

        t.cancel();
      } else {
        _updateProgressModal(_publishProgress, _publishStatus);
      }
    });
  }

  // ============================================================
  // OVERLAYS
  // ============================================================
  void _showProgressModal({
    required String initialStatus,
    bool cancelable = false,
  }) {
    _removeProgressModal();

    _progressModalEntry = OverlayEntry(
      builder: (_) => PublishProgressModal(
        progress: _publishProgress,
        statusText: initialStatus,
        onCancel: cancelable
            ? () {
          _publishTimer?.cancel();
          _removeProgressModal();
          _showDraftBanner("error");
        }
            : null,
      ),
    );

    Overlay.of(context, rootOverlay: true)?.insert(_progressModalEntry!);
  }

  void _updateProgressModal(double p, String status) {
    _progressModalEntry?.remove();
    _progressModalEntry = OverlayEntry(
      builder: (_) => PublishProgressModal(
        progress: p,
        statusText: status,
      ),
    );
    Overlay.of(context, rootOverlay: true)?.insert(_progressModalEntry!);
  }

  void _removeProgressModal() {
    _progressModalEntry?.remove();
    _progressModalEntry = null;
  }

  void _showDraftBanner(String status) {
    _removeDraftBanner();
    _draftBannerEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: 20,
        left: 20,
        right: 20,
        child: DraftSaveBanner(status: status),
      ),
    );
    Overlay.of(context, rootOverlay: true)?.insert(_draftBannerEntry!);
  }

  void _removeDraftBanner() {
    _draftBannerEntry?.remove();
    _draftBannerEntry = null;
  }

  // ============================================================
  // SNACKBAR
  // ============================================================
  void _showSnackbar(String txt) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(txt)),
    );
  }
}
