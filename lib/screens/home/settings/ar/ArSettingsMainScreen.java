import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

// =============== IMPORT ALL AR PAGES ===============
import 'performance.dart';
import 'permissions.dart';
import 'calibration.dart';
import 'ar_engine_info.dart';
import 'hand_tracking.dart';
import 'motion_prediction.dart';
import 'plane_classification.dart';
import 'ar_safe_mode.dart';
import 'ar_logs.dart';
// ==================================================

class ArSettingsMainScreen extends StatelessWidget {
  const ArSettingsMainScreen({super.key});

  Widget _item(
      BuildContext ctx, IconData icon, String title, String sub, Widget page) {
    return Card(
      color: AppColors.card,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.body()),
        subtitle: Text(sub, style: AppTextStyles.caption()),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => page),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(text, style: AppTextStyles.heading(size: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("AR Settings", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // PERFORMANCE
          _sectionTitle("Performance & Quality"),

          _item(
            context,
            Icons.speed,
            "Performance",
            "Rendering, quality, energy modes",
            ARPerformanceScreen(),
          ),

          _item(
            context,
            Icons.engineering,
            "AR Engine Info",
            "Engine version, device support",
            AREngineInfoScreen(),
          ),

          _item(
            context,
            Icons.directions_run,
            "Motion Prediction",
            "Predictive tracking & smoothing",
            MotionPredictionScreen(),
          ),

          // TRACKING
          _sectionTitle("Tracking & Calibration"),

          _item(
            context,
            Icons.track_changes,
            "Calibration",
            "Alignment, tracking reset",
            ARCalibrationScreen(),
          ),

          _item(
            context,
            Icons.layers,
            "Plane Classification",
            "Surface type detection",
            PlaneClassificationScreen(),
          ),

          _item(
            context,
            Icons.front_hand,
            "Hand Tracking",
            "Gesture & hand tracking sensitivity",
            HandTrackingScreen(),
          ),

          // SAFETY
          _sectionTitle("Safety"),

          _item(
            context,
            Icons.health_and_safety,
            "AR Safe Mode",
            "Reduce motion & visual intensity",
            ARSafeModeScreen(),
          ),

          // PERMISSIONS
          _sectionTitle("Permissions"),

          _item(
            context,
            Icons.security,
            "Permissions",
            "Camera, location, motion sensors",
            ARPermissionsScreen(),
          ),

          // DEBUG
          _sectionTitle("Developer / Debug"),

          _item(
            context,
            Icons.bug_report,
            "AR Logs",
            "Enable tracking logs & debug tools",
            ARLogsScreen(),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
