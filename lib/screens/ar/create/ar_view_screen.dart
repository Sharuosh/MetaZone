// File: lib/screens/ar/create/ar_view_screen.dart
// MetaZone — AR Live View (Flutter ↔ Unity Bridge)

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class ARViewScreen extends StatefulWidget {
  const ARViewScreen({super.key});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  UnityWidgetController? _unityController;
  bool _isUnityReady = false;

  // ===============================
  // Unity Lifecycle
  // ===============================
  void _onUnityCreated(UnityWidgetController controller) {
    _unityController = controller;
  }

  void _onUnityMessage(dynamic message) {
    debugPrint("Unity → Flutter: $message");
  }

  void _onUnityLoaded() {
    setState(() => _isUnityReady = true);
  }

  // ===============================
  // Unity Commands
  // ===============================
  void _placeObject() {
    if (!_isUnityReady) return;

    _unityController?.postMessage(
      'FlutterBridge', // GameObject name in Unity
      'PlaceObject',   // Method name
      'cube',          // Payload (type / id)
    );
  }

  void _clearScene() {
    if (!_isUnityReady) return;

    _unityController?.postMessage(
      'FlutterBridge',
      'ClearScene',
      '',
    );
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ================= UNITY VIEW =================
          UnityWidget(
            onUnityCreated: _onUnityCreated,
            onUnityMessage: _onUnityMessage,
            onUnityLoaded: _onUnityLoaded,
            useAndroidViewSurface: false, // 🔥 ده أهم سطر
            fullscreen: true,
          ),

          // ================= TOP BAR =================
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

          // ================= BOTTOM CONTROLS =================
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _mainActionButton(
                  icon: Icons.add_circle,
                  label: "Place Object",
                  onTap: _placeObject,
                ),
                const SizedBox(height: 12),
                if (!_isUnityReady)
                  Text(
                    "Loading AR Engine...",
                    style: AppTextStyles.caption(
                      size: 12,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================
  // UI Components
  // ===============================
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
          border: Border.all(color: AppColors.primary.withOpacity(.35)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(.35),
              blurRadius: 20,
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primary, size: 26),
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
            child: Icon(icon, size: 40, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
