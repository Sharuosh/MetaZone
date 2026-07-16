// File: lib/screens/ar/portal_editor/panels/save_panel.dart
// MetaZone — Portal Save Panel (FINAL PRO Portal-Compatible Edition)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/portal_config.dart';

class SavePanel extends StatefulWidget {
  final PortalConfig config;
  final Function(PortalConfig newConfig) onChanged;
  final Function(String action, PortalConfig config)? onAction;

  const SavePanel({
    super.key,
    required this.config,
    required this.onChanged,
    this.onAction,
  });

  @override
  State<SavePanel> createState() => _SavePanelState();
}

class _SavePanelState extends State<SavePanel> {
  late TextEditingController _nameCtrl;

  bool publishToMarketplace = false;
  bool saveAsTemplate = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.config.presets["portal_name"] ?? "");
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------
  // DEEP COPY HELPER
  // -------------------------------------------------------------
  Map<String, dynamic> deepCopy(Map<String, dynamic> src) {
    return src.map((key, value) {
      if (value is Map<String, dynamic>) {
        return MapEntry(key, deepCopy(value));
      } else {
        return MapEntry(key, value);
      }
    });
  }

  // -------------------------------------------------------------
  // BUILD UPDATED CONFIG
  // -------------------------------------------------------------
  PortalConfig _buildNewConfig() {
    final updatedPresets = Map<String, dynamic>.from(widget.config.presets);

    updatedPresets["portal_name"] = _nameCtrl.text.trim();

    if (saveAsTemplate) {
      final name = _nameCtrl.text.trim().isEmpty
          ? "untitled"
          : _nameCtrl.text.trim();

      updatedPresets["template_$name"] = {
        "shape": widget.config.shape,
        "surface": widget.config.surface,
        "coreType": widget.config.coreType,
        "environment": widget.config.environment,
        "teleportDestination": widget.config.teleportDestination,
        "fx": deepCopy(widget.config.fx),
        "physics": deepCopy(widget.config.physics),
        "animation": deepCopy(widget.config.animation),
        "sound": deepCopy(widget.config.sound),
      };
    }

    return widget.config.copyWith(
      presets: updatedPresets,
    );
  }

  // -------------------------------------------------------------
  // ACTION WRAPPER
  // -------------------------------------------------------------
  void _doAction(String action) {
    final newConfig = _buildNewConfig();
    widget.onChanged(newConfig);
    widget.onAction?.call(action, newConfig);
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Save Portal", style: AppTextStyles.title(size: 18)),
          const SizedBox(height: 16),

          _inputField(
            label: "Portal Name",
            hint: "Enter a name...",
            controller: _nameCtrl,
          ),

          const SizedBox(height: 20),

          _switchTile(
            label: "Save as Template (Preset)",
            value: saveAsTemplate,
            onChanged: (v) => setState(() => saveAsTemplate = v),
          ),

          _switchTile(
            label: "Publish to MetaZone Marketplace",
            value: publishToMarketplace,
            onChanged: (v) => setState(() => publishToMarketplace = v),
          ),

          const SizedBox(height: 22),

          _section("Actions"),
          const SizedBox(height: 12),

          _actionButton(
            icon: Icons.save_rounded,
            label: "Save Draft",
            color: AppColors.primary,
            onTap: () => _doAction("save_draft"),
          ),

          const SizedBox(height: 12),

          _actionButton(
            icon: Icons.file_upload_rounded,
            label: "Export Portal",
            color: Colors.blueAccent,
            onTap: () => _doAction("export"),
          ),

          const SizedBox(height: 12),

          _actionButton(
            icon: Icons.share_rounded,
            label: "Share",
            color: Colors.greenAccent,
            onTap: () => _doAction("share"),
          ),

          const SizedBox(height: 12),

          _actionButton(
            icon: Icons.send_and_archive_rounded,
            label:
            publishToMarketplace ? "Publish to Store" : "Publish",
            color: Colors.purpleAccent,
            onTap: () => _doAction("publish"),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // INPUT FIELD
  // -------------------------------------------------------------
  Widget _inputField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body(size: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.surface.withOpacity(.4),
            border: Border.all(color: Colors.white24),
          ),
          child: TextField(
            controller: controller,
            style: AppTextStyles.body(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.caption(),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // SWITCH TILE
  // -------------------------------------------------------------
  Widget _switchTile({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.body())),
        Switch(
          value: value,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // ACTION BUTTON
  // -------------------------------------------------------------
  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withOpacity(.25),
          border: Border.all(color: color.withOpacity(.55)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(label,
                style: AppTextStyles.body()
                    .copyWith(color: color, fontWeight: FontWeight.bold)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: color.withOpacity(.8)),
          ],
        ),
      ),
    );
  }

  Widget _section(String text) =>
      Text(text, style: AppTextStyles.title(size: 16));
}
