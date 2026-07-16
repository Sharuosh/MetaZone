// File: lib/screens/ar/create/ar_object_generator.dart
// MetaZone — AR Object Generator (PRO • Realtime • Gamified)

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/theme.dart';
import '../../../services/user_service.dart';
import '../../../services/ar_counter_service.dart';

class ARObjectGenerator extends StatefulWidget {
  const ARObjectGenerator({super.key});

  @override
  State<ARObjectGenerator> createState() => _ARObjectGeneratorState();
}

class _ARObjectGeneratorState extends State<ARObjectGenerator>
    with SingleTickerProviderStateMixin {
  // ===============================
  // SERVICES
  // ===============================
  final UserService _userService = UserService();
  final ARCounterService _arCounter = ARCounterService();

  // ===============================
  // UI STATE
  // ===============================
  double size = 1.0;
  double glow = 0.4;
  double rotation = 0.0;
  double elevation = 0.0;
  double opacity = 1.0;
  Color color = AppColors.primary;

  late AnimationController _controller;
  late Animation<double> _spin;

  String? _modelName;
  String? _modelPath;
  String? _thumbPath;

  @override
  void initState() {
    super.initState();

    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat();

    _spin = Tween<double>(begin: 0, end: pi * 2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ===============================
  // FILE PICKERS
  // ===============================
  Future<void> _pickModel() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['glb', 'gltf', 'usdz', 'fbx', 'obj'],
    );

    if (res != null && res.files.single.path != null) {
      setState(() {
        _modelName = res.files.single.name;
        _modelPath = res.files.single.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Model selected: $_modelName")),
      );
    }
  }

  Future<void> _pickThumbnail() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);

    if (res != null && res.files.single.path != null) {
      setState(() => _thumbPath = res.files.single.path);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thumbnail selected")),
      );
    }
  }

  // ===============================
  // GENERATE FINAL OBJECT
  // ===============================
  Future<void> _generateFinal() async {
    if (_modelPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a 3D model first")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 1️⃣ Save object meta (basic)
      await FirebaseFirestore.instance.collection("ar_objects").add({
        "ownerId": user.uid,
        "modelName": _modelName,
        "createdAt": FieldValue.serverTimestamp(),
        "config": {
          "size": size,
          "glow": glow,
          "rotation": rotation,
          "elevation": elevation,
          "opacity": opacity,
          "color": color.value,
        }
      });

      // 2️⃣ Realtime counter
      await _arCounter.increment(user.uid, "creationsCount");

      // 3️⃣ Achievements logic
      await _userService.checkAndGrantAchievements(user.uid);

      // 4️⃣ Activity (Profile score)
      await _userService.onUserActivity(user.uid);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("AR Object created • Stats updated"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text("AR Object Generator", style: AppTextStyles.heading()),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => setState(() {
              size = 1.0;
              glow = 0.4;
              rotation = 0.0;
              elevation = 0.0;
              opacity = 1.0;
              color = AppColors.primary;
            }),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildPreview()),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text("Live Preview", style: AppTextStyles.title()),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedBuilder(
                animation: _spin,
                builder: (_, __) {
                  return Transform.rotate(
                    angle: rotation + _spin.value * 0.2,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 160 * size,
                      height: 160 * size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(opacity * .25),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(glow),
                            blurRadius: 50,
                            spreadRadius: 20,
                            offset: Offset(0, elevation * 20),
                          ),
                        ],
                      ),
                      child: Center(
                        child:
                        Icon(Icons.auto_awesome, color: color, size: 60),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildModelInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildModelInfo() {
    return Column(
      children: [
        Text(_modelName ?? "No model selected",
            style: AppTextStyles.body()),
        const SizedBox(height: 6),
        ElevatedButton.icon(
          onPressed: _pickModel,
          icon: const Icon(Icons.upload_file),
          label: const Text("Upload 3D Model"),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _pickThumbnail,
          icon: const Icon(Icons.image),
          label: const Text("Pick Thumbnail"),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _slider("Size", size, 0.5, 2.5, (v) => size = v),
          _slider("Glow", glow, 0.1, 1.5, (v) => glow = v),
          _slider("Opacity", opacity, 0.1, 1.0, (v) => opacity = v),
          _slider("Rotation", rotation, 0, pi * 2, (v) => rotation = v),
          _slider("Elevation", elevation, -1.0, 2.0, (v) => elevation = v),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _generateFinal,
              child: const Text("Generate AR Object"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Column(
      children: [
        Row(
          children: [
            Text(label),
            const Spacer(),
            Text(value.toStringAsFixed(2)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => onChanged(v)),
        ),
      ],
    );
  }
}
