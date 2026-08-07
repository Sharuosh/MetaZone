// File: lib/screens/ar/create/ar_view_screen.dart
// MetaZone — AR Live View (Flutter ↔ Unity Bridge)

import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

import '../../../core/theme/theme.dart';
import '../../../services/unity_bridge.dart';

class ARViewScreen extends StatefulWidget {
  const ARViewScreen({super.key});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  bool _isUnityReady = false;

  // ==========================================================
  // Unity Messages
  // ==========================================================

  void _onUnityMessage(String message) {
    debugPrint("Unity → Flutter : $message");

    switch (message) {
      case "UNITY_READY":
        if (!_isUnityReady) {
          setState(() {
            _isUnityReady = true;
          });

          UnityBridge.instance.attach();
        }
        break;

      case "SCENE_SAVED":
        debugPrint("Scene Saved");
        break;

      case "SCENE_LOADED":
        debugPrint("Scene Loaded");
        break;

      default:
        debugPrint(message);
        break;
    }
  }

  @override
  void dispose() {
    UnityBridge.instance.detach();
    super.dispose();
  }

  // ==========================================================
  // Unity Commands
  // ==========================================================

  void _selectDefaultObject() {
    if (!_isUnityReady) return;

    UnityBridge.instance.selectAsset("cube_001");
  }

  void _clearScene() {
    if (!_isUnityReady) return;

    UnityBridge.instance.clearScene();
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ==================================================
          // UNITY VIEW
          // ==================================================

          Positioned.fill(
            child: EmbedUnity(
              onMessageFromUnity: _onUnityMessage,
            ),
          ),

          // ==================================================
          // TOP BAR
          // ==================================================

          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _glassButton(
                  icon: Icons.close,
                  onTap: () => Navigator.pop(context),
                ),
                _glassButton(
                  icon: Icons.layers_clear,
                  onTap: _clearScene,
                ),
              ],
            ),
          ),

          // ==================================================
          // BOTTOM CONTROLS
          // ==================================================

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _mainActionButton(
                  icon: Icons.view_in_ar,
                  label: "Select Object",
                  onTap: _selectDefaultObject,
                ),

                const SizedBox(height: 12),

                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isUnityReady ? 0 : 1,
                  child: Text(
                    "Loading AR Engine...",
                    style: AppTextStyles.caption(
                      size: 12,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // UI Components
  // ==========================================================

  Widget _glassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withOpacity(.35),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(.35),
              blurRadius: 20,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 26,
        ),
      ),
    );
  }

  Widget _mainActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.neonGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(.45),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 40,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            label,
            style: AppTextStyles.caption(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}