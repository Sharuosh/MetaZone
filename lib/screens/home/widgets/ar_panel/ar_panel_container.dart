// lib/screens/home/widgets/ar_panel/ar_panel_container.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

enum ARPanelTool { portal, generator, map }

class ARPanelContainer extends StatelessWidget {
  final Animation<double> animation;
  final bool isOpen;
  final VoidCallback? onClose;
  final void Function(ARPanelTool tool)? onOpenTool;

  const ARPanelContainer({
    required this.animation,
    this.isOpen = false,
    this.onClose,
    this.onOpenTool,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final t = animation.value;
        final top = -220 + (t * 220);

        return Positioned(
          top: top,
          left: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: t < 0.02,
            child: Opacity(
              opacity: 0.98,
              child: Column(
                children: [
                  _glassHeader(context, t),
                  const SizedBox(height: 8),
                  _toolsPanel(t),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ======================================================
  ///                    HEADER (GLASS)
  /// ======================================================
  Widget _glassHeader(BuildContext context, double t) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppColors.blurLevel * t,
          sigmaY: AppColors.blurLevel * t,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(AppColors.glassOpacity),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.glow.withOpacity(0.25 * t * AppColors.neonIntensity),
                blurRadius: 24 * AppColors.depthLevel,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onClose,
                child: Row(
                  children: [
                    Transform.rotate(
                      angle: (1 - t) * -0.4,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSoft,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("AR Command Panel", style: AppTextStyles.title(size: 15)),
                        Text("Spatial tools & portals", style: AppTextStyles.caption(size: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("AR settings (demo)")),
                  );
                },
                icon: Icon(Icons.settings, color: AppColors.textSoft),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// ======================================================
  ///                    TOOLS PANEL
  /// ======================================================
  Widget _toolsPanel(double t) {
    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, (1 - t) * -10),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppColors.surfaceGradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primarySoft.withOpacity(0.15 * t),
                blurRadius: 20 * AppColors.depthLevel,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _panelTile("Portal", Icons.wifi_tethering, () => onOpenTool?.call(ARPanelTool.portal)),
              _panelTile("Generator", Icons.widgets, () => onOpenTool?.call(ARPanelTool.generator)),
              _panelTile("Map", Icons.map, () => onOpenTool?.call(ARPanelTool.map)),
            ],
          ),
        ),
      ),
    );
  }

  /// ======================================================
  ///                    TILE
  /// ======================================================
  Widget _panelTile(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: AppColors.card.withOpacity(0.9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySoft.withOpacity(0.25),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: AppColors.primary, size: 32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.caption(size: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
