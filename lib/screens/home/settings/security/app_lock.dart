import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  bool _pinEnabled = false;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("App Lock", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SwitchListTile(
            value: _pinEnabled,
            onChanged: (v) => setState(() => _pinEnabled = v),
            title: const Text("Enable PIN / Pattern Lock"),
            subtitle: const Text("Lock MetaZone app when opened"),
          ),
          SwitchListTile(
            value: _biometricEnabled,
            onChanged: (v) => setState(() => _biometricEnabled = v),
            title: const Text("Biometric Unlock"),
            subtitle: const Text("Use fingerprint or face unlock"),
          ),
          const SizedBox(height: 20),
          if (_pinEnabled)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {},
              child: const Text("Set / Change PIN"),
            ),
        ],
      ),
    );
  }
}
