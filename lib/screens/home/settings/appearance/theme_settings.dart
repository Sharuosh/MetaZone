import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  String selected = "dark";

  @override
  void initState() {
    super.initState();
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    selected = prefs.getString("app_theme") ?? "dark";
    setState(() {});
  }

  Future<void> _changeTheme(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("app_theme", key);

    AppColors.setTheme(key);

    if (mounted) Navigator.pop(context);
  }

  Widget _themeTile({
    required String title,
    required String key,
    required Color previewColor,
    required Gradient gradient,
  }) {
    final active = selected == key;
    return GestureDetector(
      onTap: () => _changeTheme(key),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: active ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: previewColor,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: AppTextStyles.title()),
            ),
            if (active)
              Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Theme", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Choose Theme", style: AppTextStyles.title(size: 18)),
          const SizedBox(height: 16),

          _themeTile(
            title: "Dark Neon (Default)",
            key: "dark",
            previewColor: const Color(0xFF00D1FF),
            gradient: ThemePresets.darkNeon.neonGradient,
          ),

          _themeTile(
            title: "Hologram Purple",
            key: "hologram",
            previewColor: const Color(0xFFB060FF),
            gradient: ThemePresets.hologram.neonGradient,
          ),

          _themeTile(
            title: "Light Futuristic",
            key: "light",
            previewColor: const Color(0xFF00B7D6),
            gradient: ThemePresets.light.neonGradient,
          ),

          const SizedBox(height: 20),
          Text("Theme applies instantly across the app.",
              style: AppTextStyles.caption()),
        ],
      ),
    );
  }
}
