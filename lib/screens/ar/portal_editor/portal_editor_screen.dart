// File: lib/screens/ar/portal_editor/portal_editor_screen.dart
// MetaZone – AR Portal Editor (Ultra PRO – Full Integration)

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/theme.dart';

// SERVICES
import '../../../services/user_service.dart';
import '../../../services/ar_counter_service.dart';

// MODEL
import 'models/portal_config.dart';

// WIDGETS
import 'panels/widgets/portal_viewport.dart';
import 'panels/widgets/editor_top_bar.dart';
import 'panels/widgets/editor_left_tools.dart';
import 'panels/widgets/editor_right_panel.dart';

// PANELS
import 'panels/shape_panel.dart';
import 'panels/surface_panel.dart';
import 'panels/portal_core_panel.dart';
import 'panels/teleport_panel.dart';
import 'panels/effects_panel.dart';
import 'panels/physics_panel.dart';
import 'panels/environment_panel.dart';
import 'panels/color_panel.dart';
import 'panels/material_panel.dart';
import 'panels/skybox_panel.dart';
import 'panels/animation_panel.dart';
import 'panels/sound_panel.dart';
import 'panels/save_panel.dart';
import 'panels/fx_panel.dart';
import 'panels/presets_panel.dart';
import 'panels/lighting_panel.dart';
import 'panels/transform_panel.dart';

class ARPortalEditorScreen extends StatefulWidget {
  const ARPortalEditorScreen({super.key});

  @override
  State<ARPortalEditorScreen> createState() => _ARPortalEditorScreenState();
}

class _ARPortalEditorScreenState extends State<ARPortalEditorScreen>
    with TickerProviderStateMixin {
  // ===============================
  // SERVICES
  // ===============================
  final UserService _userService = UserService();
  final ARCounterService _arCounter = ARCounterService();

  // ===============================
  // PORTAL CONFIG
  // ===============================
  PortalConfig config = PortalConfig();
  String activeTool = "shape";
  late int panelIndex;

  final Map<String, int> toolToIndex = const {
    "shape": 0,
    "surface": 1,
    "core": 2,
    "teleport": 3,
    "effects": 4,
    "physics": 5,
    "environment": 6,
    "color": 7,
    "material": 8,
    "skybox": 9,
    "animation": 10,
    "sound": 11,
    "fx": 12,
    "presets": 13,
    "save": 14,
    "lighting": 15,
    "transform": 16,
  };

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    panelIndex = toolToIndex[activeTool] ?? 0;

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: .96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void updateConfig(PortalConfig newConfig) {
    setState(() => config = newConfig);
  }

  // ================================================================
  // UI
  // ================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          PortalViewport(config: config, pulse: _pulseScale),

          PortalEditorTopBar(
            onSave: _savePortal,
            onExport: _exportConfig,
          ),

          PortalEditorLeftTools(
            activeTool: activeTool,
            onSelect: (t) {
              setState(() {
                activeTool = t;
                panelIndex = toolToIndex[t] ?? 0;
              });
            },
          ),

          PortalEditorRightPanel(
            child: _panels(),
          ),
        ],
      ),
    );
  }

  Widget _panels() {
    return IndexedStack(
      index: panelIndex,
      children: [
        ShapePanel(config: config, onChanged: updateConfig),
        SurfacePanel(config: config, onChanged: updateConfig),
        CorePanel(config: config, onChanged: updateConfig),
        TeleportPanel(config: config, onChanged: updateConfig),
        PortalEffectsPanel(config: config, onChanged: updateConfig),
        PortalPhysicsPanel(config: config, onChanged: updateConfig),
        EnvironmentPanel(config: config, onChanged: updateConfig),
        ColorPanel(config: config, onChanged: updateConfig),
        MaterialPanel(config: config, onChanged: updateConfig),
        SkyboxPanel(config: config, onChanged: updateConfig),
        AnimationPanel(config: config, onChanged: updateConfig),
        SoundPanel(config: config, onChanged: updateConfig),
        FXPanel(config: config, onChanged: updateConfig),
        PresetsPanel(config: config, onChanged: updateConfig),
        SavePanel(
          config: config,
          onChanged: updateConfig,
          onAction: _handleSavePanelAction,
        ),
        LightingPanel(config: config, onChanged: updateConfig),
        TransformPanel(config: config, onChanged: updateConfig),
      ],
    );
  }

  // ================================================================
  // SAVE PORTAL → REALTIME COUNTER + ACHIEVEMENTS + ACTIVITY
  // ================================================================
  Future<void> _savePortal() async {
    try {
      final encoded = config.encode();
      debugPrint("Saving Portal → $encoded");

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ✅ Realtime AR Counter (SAFE)
      await _arCounter.increment(user.uid, "arSpotsCount");

      // ✅ Achievements Logic
      await _userService.checkAndGrantAchievements(user.uid);

      // ✅ Activity tracking (Profile completion / engagement)
      await _userService.onUserActivity(user.uid);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Portal saved • AR updated • Achievements checked"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save portal: $e")),
      );
    }
  }

  // ================================================================
  // EXPORT
  // ================================================================
  void _exportConfig() {
    try {
      final json = config.encode();
      debugPrint("EXPORT JSON → $json");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Portal exported as JSON")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to export portal: $e")),
      );
    }
  }

  void _handleSavePanelAction(String action, PortalConfig cfg) {
    debugPrint("SavePanel action → $action");
  }
}
