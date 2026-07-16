import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

import 'theme_settings.dart';
import 'neon_settings.dart';
import 'ui_depth.dart';
import 'background_effects.dart';
import 'glass_morphism.dart';
import 'texture_sharpness.dart';
import 'animation_speed.dart';

class AppearanceMainScreen extends StatelessWidget {
  const AppearanceMainScreen({super.key});

  Widget _item(BuildContext c, IconData icon, String title, String sub, Widget page) {
    return Card(
      color: AppColors.card,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.body()),
        subtitle: Text(sub, style: AppTextStyles.caption()),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Text(text, style: AppTextStyles.heading(size: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Appearance", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _title("Theme"),
          _item(
            context,
            Icons.color_lens,
            "Themes",
            "Dark Neon, Hologram, Light Mode",
            const ThemeSettingsScreen(),
          ),

          _title("Neon & Glow"),
          _item(
            context,
            Icons.bolt,
            "Neon Settings",
            "Glow, intensity & color",
            const NeonSettingsScreen(),
          ),

          _title("Depth / 3D UI"),
          _item(
            context,
            Icons.blur_on,
            "UI Depth",
            "3D layers, shadows, parallax",
            const UIDepthScreen(),
          ),

          _title("Background Effects"),
          _item(
            context,
            Icons.image,
            "Background Effects",
            "Galaxy, particles, animations",
            const BackgroundEffectsScreen(),
          ),

          _title("Glass & Layers"),
          _item(
            context,
            Icons.layers,
            "Glass Morphism",
            "Transparency & blur power",
            const GlassMorphismScreen(),
          ),

          _title("Advanced Controls"),
          _item(
            context,
            Icons.details,
            "Texture Sharpness",
            "Improve UI clarity",
            const TextureSharpnessScreen(),
          ),

          _item(
            context,
            Icons.speed,
            "Animation Speed",
            "UI transition timing",
            const AnimationSpeedScreen(),
          ),
        ],
      ),
    );
  }
}
